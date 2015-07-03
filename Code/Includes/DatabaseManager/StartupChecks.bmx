Function GamesCheck()
	PrintF("Checking Games")
	Local DBVersion:Int
	Local DBVersionFile:TStream
	Repeat
	
		If FileType(GAMEDATAFOLDER + "DBVersion.txt") = 1 then
			DBVersionFile = ReadFile(GAMEDATAFOLDER + "DBVersion.txt")
			DBVersion = Int(ReadLine(DBVersionFile) )
			If DBVersion = 0 then DBVersion = 1
			CloseFile(DBVersionFile)
		Else
			DBVersion = 1
		EndIf
		
		Select DBVersion
			Case 1
				'Moving From Patch 4.09+
				PrintF("Updating DBVersion From 1 to 2")
				DBUpdate1()
				DBVersion = 2
			Default
				'Latest Version
				Return
		End Select
		
		DBVersionFile = WriteFile(GAMEDATAFOLDER + "DBVersion.txt")
		WriteLine(DBVersionFile, String(DBVersion) )
		CloseFile(DBVersionFile)
	Forever
End Function