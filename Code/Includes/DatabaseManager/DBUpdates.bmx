Function DBUpdate1()
	Local GameDir:Int
	Local GameNode:GameType = New GameType
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
	CloseDir(GameDir)
	
	GameDir = ReadDir(GAMEDATAFOLDER)
	Repeat
		item = NextFile(GameDir)
		If item = "" then Exit
		If item = "." Or item = ".." then Continue
		
		If GameNode.GetGame(item) = - 1 then
		
		Else
			GameNode.SaveGame()
		EndIf
	Forever
	CloseDir(GameDir)		
End Function
