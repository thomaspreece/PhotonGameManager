'WindowsCheck is dependant on code file so is contained in each Photon*****.bmx master file

Function TempFolderCleanup()
	If FileType(TEMPFOLDER + "Lua") = 2 Then
		DeleteDir(TEMPFOLDER + "Lua", 1)
	EndIf
	If FileType(TEMPFOLDER + "ArtWork") = 2 Then
		DeleteDir(TEMPFOLDER + "ArtWork", 1)
	EndIf
	If FileType(TEMPFOLDER + "Thumbs") = 2 Then
		DeleteDir(TEMPFOLDER + "Thumbs", 1)
	EndIf
	If FileType(TEMPFOLDER + "GDFExtract") = 2 Then
		DeleteDir(TEMPFOLDER + "GDFExtract", 1)
	EndIf
End Function

Function SetupPlatforms()
	GlobalPlatforms = New PlatformReader
	If FileType(SETTINGSFOLDER + "Platforms.xml") = 1 Then
		GlobalPlatforms.ReadInPlatforms()	
	Else
		GlobalPlatforms.PopulateDefaultPlatforms()
		GlobalPlatforms.ReadInPlatforms()
	EndIf
	
	DefaultPlatforms = New PlatformReader
	If FileType(TEMPFOLDER + "DefaultPlatforms.xml") = 1 Then
		DefaultPlatforms.ReadInPlatforms(TEMPFOLDER + "DefaultPlatforms.xml")	
	Else
		DefaultPlatforms.PopulateDefaultPlatforms(TEMPFOLDER + "DefaultPlatforms.xml")
		DefaultPlatforms.ReadInPlatforms(TEMPFOLDER + "DefaultPlatforms.xml")	
	EndIf
End Function

Function ResourcesCheck()
	Local PlatDir:Int, File:String, PlatName:String
	Local Plat:PlatformType
	Local PlatformsEmpty:Int = 0
	If FileType(RESFOLDER + "Menu" + FolderSlash + "PlatformNums") = 2 Then
		
	Else
		CreateFolder(RESFOLDER + "Menu" + FolderSlash + "PlatformNums")
	EndIf
	
	If FileType(RESFOLDER + "Menu" + FolderSlash + "Platforms") = 2 Then
		PlatDir = ReadDir(RESFOLDER + "Menu" + FolderSlash + "Platforms")
		PlatformsEmpty = True
		Repeat
			File = NextFile(PlatDir)
			If File = "." Or File = ".." Then Continue
			If File = "" Then Exit
			PlatformsEmpty = False
			If File = "Nintendo Game Boy Advance.jpg" Then
				PlatName = "Nintendo Gameboy Advance"
			ElseIf File = "Nintendo Game Boy.jpg" Then
				PlatName = "Nintendo Gameboy"
			ElseIf File = "Sony PlayStation.jpg" Then
				PlatName = "Sony Playstation"
			Else
				PlatName = StripExt(File)
			EndIf
			Plat = GlobalPlatforms.GetPlatformByName(PlatName )
			If Plat.ID = 0 Then
			
			Else
				If FileType(RESFOLDER + "Menu" + FolderSlash + "PlatformNums" + FolderSlash + String(Plat.ID) + ".jpg") = 1 Then
				
				Else
					CopyFile(RESFOLDER + "Menu" + FolderSlash + "Platforms" + FolderSlash + File, RESFOLDER + "Menu" + FolderSlash + "PlatformNums" + FolderSlash + String(Plat.ID) + ".jpg")
					If FileType(RESFOLDER + "Menu" + FolderSlash + "PlatformNums" + FolderSlash + String(Plat.ID) + ".jpg") = 1 Then
						DeleteFile(RESFOLDER + "Menu" + FolderSlash + "Platforms" + FolderSlash + File)
					EndIf
				EndIf
			EndIf
		Forever
		CloseDir(PlatDir)
		If PlatformsEmpty = True Then
			DeleteDir(RESFOLDER + "Menu" + FolderSlash + "Platforms")
		EndIf
	EndIf
End Function

Function OldPlatformListChecks()
	If GlobalPlatforms = Null Then
		CustomRuntimeError("OldPlatformListChecks: GlobalPlatforms Null")
	EndIf
	PrintF("Checking for Old Platform Lists")
	Local Line:String, EmuPath:String, PlatName:String
	Local ReadPlatform:TStream
	Local MovePlat = False
	Local a:Int, b:Int
	Local Platform:PlatformType
	Local CustomPlatNumber = DEFAULTPLATFORMNUM + 1
	
	If FileType("Platforms.txt") = 1 Then
		MovePlat = True
		PrintF("Upgrading Original Platforms.txt")
	EndIf
	If FileType(SETTINGSFOLDER + "Platforms.txt") = 1 And MovePlat = True Then
		MovePlat = False
		DeleteFile("Platforms.txt")
		PrintF("New Platforms.txt Found, deleting old Platforms.txt")
	EndIf
	If MovePlat = True Then
		CopyFile("Platforms.txt",SETTINGSFOLDER + "Platforms.txt")
		DeleteFile("Platforms.txt")
	EndIf
	

	If FileType(SETTINGSFOLDER + "Platforms.txt") = 1 Then
		
		For Platform = EachIn GlobalPlatforms.PlatformList
			CustomPlatNumber = Max(CustomPlatNumber, Platform.ID)
		Next
	
	
		ReadPlatform = ReadFile(SETTINGSFOLDER + "Platforms.txt")
		Repeat
			Line = ReadLine(ReadPlatform)
			EmuPath = ""
			PlatName = ""
			For a = 1 To Len(Line)
				If Mid(Line, a, 1) = ">" Then
					EmuPath = Right(Line, Len(Line) - a)
					PlatName = Left(Line, a - 1)
					Exit
				EndIf
			Next
			
			Platform = GlobalPlatforms.GetPlatformByName(PlatName)
			If Platform.ID = 0 Then
				'Platform is custom and not added
				Platform.ID = CustomPlatNumber
				CustomPlatNumber = CustomPlatNumber + 1
				Platform.Name = PlatName
				Platform.Emulator = EmuPath
				ListAddLast(GlobalPlatforms.PlatformList, Platform)
			Else
				If EmuPath = "" Or EmuPath = " " Then
					'Do nothing
				Else
					If Platform.Emulator = "" Or Platform.Emulator = Null Or Platform.Emulator = " " Then
						Platform.Emulator = EmuPath
					EndIf
				EndIf
			EndIf
			
			If Eof(ReadPlatform) Then
				Exit
			EndIf
		Forever
		GlobalPlatforms.SavePlatforms()
		CloseFile(ReadPlatform)
		DeleteFile(SETTINGSFOLDER + "Platforms.txt")
	EndIf

End Function

Function DebugCheck()
	If FileType("DebugLog.txt") = 1 Then
		DebugLogEnabled = True
	EndIf
End Function

Function FolderCheck()

	'Check for folders that are 100% required and should of been added with install
	If FileType(StripSlash(RESFOLDER) ) <> 2 Then
		CustomRuntimeError("Resources folder missing! Please resinstall Photon to fix this error")
		PrintF("No Res Folder: " + RESFOLDER)
	EndIf	
	?Win32
	If FileType(StripSlash(APPFOLDER) ) <> 2 Then
		CustomRuntimeError("Plugins folder missing! Please resinstall Photon to fix this error")
		PrintF("No App Folder: " + APPFOLDER)
	EndIf	
	If FileType(StripSlash(DEFAULTMOUNTERFOLDER) ) <> 2 Then
		CustomRuntimeError("Mounter folder missing! Please resinstall Photon to fix this error")
		PrintF("No Mounter Folder: " + DEFAULTMOUNTERFOLDER)
	EndIf	
	?	
	If FileType(StripSlash(LUAFOLDER) ) <> 2 Then
		CustomRuntimeError("Lua folder missing! Please resinstall Photon to fix this error")
		PrintF("No Lua Folder: " + LUAFOLDER)
	EndIf	
	If FileType(StripSlash(LUAFOLDER + FolderSlash + "Game") ) <> 2 Then
		CustomRuntimeError("Lua Game folder missing! Please resinstall Photon to fix this error")
		PrintF("No Lua Folder: " + LUAFOLDER + FolderSlash + "Game")
	EndIf		
	If FileType(StripSlash(LUAFOLDER + FolderSlash + "Patch") ) <> 2 Then
		CustomRuntimeError("Lua Patch folder missing! Please resinstall Photon to fix this error")
		PrintF("No Lua Folder: " + LUAFOLDER + FolderSlash + "Patch")
	EndIf		
	If FileType(StripSlash(LUAFOLDER + FolderSlash + "Cheat") ) <> 2 Then
		CustomRuntimeError("Lua Cheat folder missing! Please resinstall Photon to fix this error")
		PrintF("No Lua Folder: " + LUAFOLDER + FolderSlash + "Cheat")
	EndIf		
	If FileType(StripSlash(LUAFOLDER + FolderSlash + "Walkthrough") ) <> 2 Then
		CustomRuntimeError("Lua Walkthrough folder missing! Please resinstall Photon to fix this error")
		PrintF("No Lua Folder: " + LUAFOLDER + FolderSlash + "Walkthrough")
	EndIf		
	If FileType(StripSlash(LUAFOLDER + FolderSlash + "Manual") ) <> 2 Then
		CustomRuntimeError("Lua Manual folder missing! Please resinstall Photon to fix this error")
		PrintF("No Lua Folder: " + LUAFOLDER + FolderSlash + "Manual")
	EndIf	
	

	'Check for folders in Documents. Files not critical and are created on demand
	If FileType(StripSlash(LOGFOLDER) ) = 0 Then
		CreateDir(StripSlash(LOGFOLDER), 1 )
		PrintF("Creating Log Folder: " + LOGFOLDER)
	EndIf		
	If FileType(StripSlash(SETTINGSFOLDER) ) = 0 Then
		CreateDir(StripSlash(SETTINGSFOLDER), 1 )
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
	
	?Win32
	'Generate Mounter folder from default mounter folder
	Local ReadMounters:Int, File:String
	
	If FileType(StripSlash(MOUNTERFOLDER) ) <> 2 Then
		PrintF("Creating Mounter Folder: " + MOUNTERFOLDER)
		CreateDir(StripSlash(MOUNTERFOLDER), 1 )
		PrintF("Copying Mounters from default folder")
		ReadMounters = ReadDir(DEFAULTMOUNTERFOLDER)
		Repeat
			File = NextFile(ReadMounters)
			If File = "." Or File = ".." Then Continue
			If File = "" Then Exit
			If File = "ReadMe.txt" Then Continue
			CopyFile(DEFAULTMOUNTERFOLDER + FolderSlash + File, MOUNTERFOLDER + FolderSlash + File)
		Forever
		CloseDir(ReadMounters)
	EndIf				
	?
	
End Function
