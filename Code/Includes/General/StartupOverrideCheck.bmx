
Function OverrideCheck:String(FolderSlash:String)
	Local ReadLocationOverride:TStream, WriteLocationOverride:TStream
	Local TempFolderPath:String
	Local UserDocsDir:String = GetUserDocumentsDir()
	If FileType("SaveLocationOverride.txt") = 1 then
		ReadLocationOverride = ReadFile("SaveLocationOverride.txt")
		TempFolderPath = ReadLine(ReadLocationOverride)
		CloseFile(ReadLocationOverride)
		If Right(TempFolderPath, 1) = FolderSlash then
		
		Else
			TempFolderPath = TempFolderPath + FolderSlash
		EndIf
	Else
		If FileType(UserDocsDir + FolderSlash + "PhotonV4") = 2 then
			TempFolderPath = UserDocsDir + FolderSlash + "PhotonV4" + FolderSlash		
		Else
			'Backwards Compatability: Check for GameManagerV4 Folder and rename to PhotonV4
			If FileType(UserDocsDir + FolderSlash + "GameManagerV4") = 2 then
				RenameFile(UserDocsDir + FolderSlash + "GameManagerV4", UserDocsDir + FolderSlash + "PhotonV4")
			EndIf
						
			If FileType(UserDocsDir + FolderSlash + "PhotonV4") <> 2 then	
				CreateFolder(UserDocsDir + FolderSlash + "PhotonV4")
			EndIf		
			TempFolderPath = UserDocsDir + FolderSlash + "PhotonV4" + FolderSlash		
		EndIf

	EndIf
	Return TempFolderPath
End Function