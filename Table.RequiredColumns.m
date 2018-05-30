/* 
https://github.com/Ogglord/pquery

Assume you have a table - and you want to ensure there are no missing values (null or  "") in some of them. 
This function can add the missing columns in an errorColumn or throw an error on the first missing value.

Usage:
#"Check Columns" = Table.RequiredColumns(source, {"Id", "Name"}, true, "Missing Columns")
	in 
#"Check Columns"



*/
(exportTable as table, requiredColumns as list, optional addErrorColumn as nullable logical, optional errorColumnName as nullable text) =>
let    
	/* Prepare criteria for throwing error when field is null*/
	#"Required Columns" = Table.AddColumn(Table.FromList(requiredColumns, null ,{"Column Name"}), "Criteria", each  "([#"""&[Column Name]&"""] = null)"), /* Does this work - the below section does // oscar 29 jan 2018 */
	#"CriteriaText" = Text.Combine(#"Required Columns"[Criteria], " or "),
	
	/* Prepare criteria for adding an error column to the table */
	#"Required Columns v2" = Table.AddColumn(Table.FromList(requiredColumns, null ,{"Column Name"}), "Criteria", each  "if ([#"""&[Column Name]&"""] = null or [#"""&[Column Name]&"""] = """" ) then """&[Column Name]&""" else null "),
    #"CriteriaText v2" = Text.Combine(#"Required Columns v2"[Criteria], " , "),
	#"Column Name" = if errorColumnName = null then "ErrorText" else errorColumnName,
	#"Added Criteria Column" = Table.AddColumn(exportTable, "CriteriaText", each "{" & #"CriteriaText v2" & "}"),
	#"Added Error Column" = Table.AddColumn(#"Added Criteria Column", #"Column Name", each Expression.Evaluate([CriteriaText], [ _=_ ])),
	#"Transform Error Column" = Table.TransformColumns(#"Added Error Column", {{#"Column Name", each Text.Combine(_,", ")}}),
	
	/* Evaluate condiditons*/
    #"Invalid Rows" = try Table.SelectRows(exportTable, each Expression.Evaluate(#"CriteriaText", [ _=_ ])) otherwise error "Could not check for null, possibly missing columns!",
    #"Validate Export Columns"= if not Table.IsEmpty( #"Invalid Rows") then error Error.Record("Mapping Error", "At least one column contains null", CriteriaText)
        else exportTable,
	#"Result" = if addErrorColumn = null or addErrorColumn = false then #"Validate Export Columns" else #"Transform Error Column"
	in 

#"Result"