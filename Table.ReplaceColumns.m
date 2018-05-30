/*
https://github.com/Ogglord/pquery


//Replaces a column with another
/*
	pairs should be a list of pairs - string[2] where the first column replaces the second
  Usage:
    Table.ReplaceColumns = Load("Table.ReplaceColumns"),
    Tbl = #table({"Tel.", "Phone #"},{{"234", null},{null, "123"}}),
    Table.ReplaceColumns(Tbl, {{"Tel.", "Phone #"}})
 Result: #table({"Tel."},{{"123"}})
*/

(Source as table, pairs as list) as table => let
   
    colToRemove = List.Combine(List.Transform( pairs, each {List.Single(List.RemoveFirstN(_,1))})),
	renamingInstructions = List.Transform( pairs, each _),
    RemovedColumns = try Table.RemoveColumns(Source,colToRemove) otherwise Source,
    RenamedColumns = Table.RenameColumns(RemovedColumns,renamingInstructions)
in 
	RenamedColumns

 
