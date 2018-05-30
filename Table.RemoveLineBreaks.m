/* 
https://github.com/Ogglord/pquery

Removes line breaks and _x000D_ string of all columns in a table, or from a select list of columns in a table. Useful when loading files from incompatible encoding */
(Source as table, optional nullableListOfColumns as nullable list) as table =>
let
	ListOfColumns = if nullableListOfColumns <> null then nullableListOfColumns else Table.ColumnNames(Source),
    Operations = List.Transform(ListOfColumns, each {_, each try Text.Trim(Text.Replace(Text.Replace(_,"#(lf)"," "),"_x000D_","")) otherwise _}),
    Result = Table.TransformColumns(Source,Operations)
	
in

Result
