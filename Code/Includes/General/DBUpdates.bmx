Function DBUpdate1()
	Local GameDir:Int
	Local item:String, newitem:String
	GameDir = ReadDir(GAMEDATAFOLDER)
	Repeat
		item = NextFile(GameDir)
		If item = "" then Exit
		If item = "." Or item = ".." then Continue
		
		newitem = Lower(GameReadType.GameNameDirFilter(item) )
		PrintF("Comparing " + item + " and " + newitem)
		If newitem = item then
		
		Else
			RenameFile(GAMEDATAFOLDER + item , GAMEDATAFOLDER + newitem )
		EndIf
	Forever
End Function
