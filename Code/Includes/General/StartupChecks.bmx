
Function FolderCheck()
	If FileType(StripSlash(LOGFOLDER) ) = 0 then
		CreateDir(StripSlash(LOGFOLDER), 1 )
		PrintF("Creating Log Folder: " + LOGFOLDER)
	EndIf		
	If FileType(StripSlash(SETTINGSFOLDER) ) = 0 then
		CreateDir(StripSlash(SETTINGSFOLDER),1 )
		PrintF("Creating Settings Folder: " + SETTINGSFOLDER)
	EndIf
	If FileType(StripSlash(GAMEDATAFOLDER) ) = 0 Then
		CreateDir(StripSlash(GAMEDATAFOLDER),1 )
		PrintF("Creating Games Folder: " + GAMEDATAFOLDER)
	EndIf
	If FileType(StripSlash(TEMPFOLDER) ) = 0 Then
		CreateDir(StripSlash(TEMPFOLDER),1 )
		PrintF("Creating Temp Folder: " + TEMPFOLDER)
	EndIf
	If FileType(StripSlash(RESFOLDER) ) = 0 Then
		CreateDir(StripSlash(RESFOLDER),1 )
		PrintF("Creating Res Folder: " + RESFOLDER)
	EndIf	
	If FileType(StripSlash(APPFOLDER) ) = 0 then
		CreateDir(StripSlash(APPFOLDER),1 )
		PrintF("Creating App Folder: " + APPFOLDER)
	EndIf	
	If FileType(StripSlash(MOUNTERFOLDER) ) = 0 then
		CreateDir(StripSlash(MOUNTERFOLDER),1 )
		PrintF("Creating Mounter Folder: " + MOUNTERFOLDER)
	EndIf		
	If FileType(StripSlash(LUAFOLDER) ) = 0 then
		CreateDir(StripSlash(LUAFOLDER),1 )
		PrintF("Creating Mounter Folder: " + LUAFOLDER)
	EndIf		
	If FileType(StripSlash(LUAFOLDER + FolderSlash + "Game") ) = 0 then
		CreateDir(StripSlash(LUAFOLDER + FolderSlash + "Game"), 1 )
		PrintF("Creating Mounter Folder: " + LUAFOLDER + FolderSlash + "Game")
	EndIf		
	
End Function

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
