
Function OverrideCheck:String(FolderSlash:String)
	Local ReadLocationOverride:TStream
	Local TempFolderPath:String
	
	If FileType("SaveLocationOverride.txt") = 1 then
		ReadLocationOverride = ReadFile("SaveLocationOverride.txt")
		TempFolderPath = ReadLine(ReadLocationOverride)
		CloseFile(ReadLocationOverride)
		If Right(TempFolderPath, 1) = FolderSlash then
		
		Else
			TempFolderPath = TempFolderPath + FolderSlash
		EndIf
	Else
		If FileType(GetUserDocumentsDir() + FolderSlash + "GameManagerV4") <> 2 then
			CreateFolder(GetUserDocumentsDir() + FolderSlash + "GameManagerV4")
		EndIf 
		TempFolderPath = GetUserDocumentsDir() + FolderSlash + "GameManagerV4" + FolderSlash
	EndIf
	Return TempFolderPath
End Function