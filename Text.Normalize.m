/*
Replaces illegal characters in a text string, see example of illegal characters and their replacement in "SWIFT - IllegalCharacters.xlsx"

Usage:
	...
	Text.Normalize = Load("Text.Normalize"),
	Normalize = Table.TransformColumns(source, {{"Comment", Text.Normalize}})
in
	Normalize
	
*/
(Text as text, optional defListOfReplacements as table) as text =>   
    let

    /* We might have to load list from SharePoint */
    LoadedBinary = Excel.Workbook(Binary.Buffer(File.Contents("C:\svn\ETL\Power Query\M scripts\SWIFT - IllegalCharacters.xlsx")), null, true),
    LoadedTable  = LoadedBinary{[Item="IllegalCharacters",Kind="Table"]}[Data],
    ReplacedNull = Table.ReplaceValue(LoadedTable,null,"",Replacer.ReplaceValue,{"Replacement"}),
    GetReplacementsFromFile = Table.Distinct(ReplacedNull),


   
    /* Check if a default list of replacement chars was provided... */
    ListOfReplacements = if (defListOfReplacements<>null) then defListOfReplacements else GetReplacementsFromFile,

    /* Replace */
    Result = List.Accumulate(Table.ToRows(ListOfReplacements),Text,(String,ReplacePair) => Text.Replace(String,ReplacePair{0},ReplacePair{1}))
  in 
  Result
