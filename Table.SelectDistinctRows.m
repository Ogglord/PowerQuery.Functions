/* 

Similar to Table.Distinct but applies a sort critera and buffers before removing duplicates.
This will ensure a sort priority is taken into consideration. Early versions of Power Query did not necesarily keep Sort order when using Table.Distinct. This might be fixed now? 

Usage:
	// This will remove duplicate "Id", and keep the one with "lowest" priority
	
	Table.SelectDistinctRows = Load("Table.SelectDistinctRows"),
	#"Removed Duplicates" = Table.SelectDistinctRows(source, {"Id"}, {{"Id", Order.Ascending}, {"Priority", Order.Ascending}}),
in 
	#"Removed Duplicates"
	
*/
(source as table, distinct as list, comparisonCriteria as list) =>
let    
	/* Prepare criteria for throwing error when field is null*/
	Sort = Table.Sort(source,comparisonCriteria),
	Buffer = Table.Buffer(Sort),
	#"Result" = Table.Distinct(Buffer, distinct)
	in
#"Result"