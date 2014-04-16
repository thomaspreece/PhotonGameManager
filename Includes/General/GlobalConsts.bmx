'Used in ShellExecute / Downloaders Version of ShellExecute
Const SEE_MASK_NOCLOSEPROCESS = $00000040
Const INFINITE = $FFFFFFFF
'

If FolderSlash = "/" Or FolderSlash = "\" Then
	
Else
	CustomRuntimeError("GlobalConsts - No FolderSlash")
EndIf 

?Win32
Global FRONTENDPROGRAM:String = "PhotonFrontend.exe"
Global MANAGERPROGRAM:String = "PhotonManager.exe"
Global EXPLORERPROGRAM:String = "PhotonExplorer.exe"
Global DOWNLOADERPROGRAM:String = "PhotonDownloader.exe"
Global UPDATEPROGRAM:String = "PhotonUpdate.exe"
?Linux
Global FRONTENDPROGRAM:String = Chr(34)+RealPath("PhotonFrontend")+Chr(34)
Global MANAGERPROGRAM:String = Chr(34)+RealPath("PhotonManager")+Chr(34)
Global EXPLORERPROGRAM:String = Chr(34)+RealPath("PhotonExplorer")+Chr(34)
Global DOWNLOADERPROGRAM:String = Chr(34)+RealPath("PhotonDownloader")+Chr(34)
Global UPDATEPROGRAM:String = Chr(34)+RealPath("PhotonUpdate")+Chr(34)
?MacOS
Global FRONTENDPROGRAM:String = Chr(34)+RealPath("PhotonFrontend.app")+"/Contents/MacOS/PhotonFrontend"+Chr(34)
Global MANAGERPROGRAM:String = Chr(34)+RealPath("PhotonManager.app")+"/Contents/MacOS/PhotonManager"+Chr(34)
Global EXPLORERPROGRAM:String = Chr(34)+RealPath("PhotonExplorer.app")+"/Contents/MacOS/PhotonExplorer"+Chr(34)
Global DOWNLOADERPROGRAM:String = Chr(34)+RealPath("PhotonDownloader.app")+"/Contents/MacOS/PhotonDownloader"+Chr(34)
Global UPDATEPROGRAM:String = Chr(34)+RealPath("PhotonUpdate.app")+"/Contents/MacOS/PhotonUpdate"+Chr(34)
?

Global SkipBatchWait:Int = 0 
Global FinishProgramRunning:Int = 0


Global GAMEDATAFOLDER:String = TempFolderPath+"Games"+FolderSlash
Global SETTINGSFOLDER:String = TempFolderPath+"Settings"+FolderSlash
Global TEMPFOLDER:String = TempFolderPath+"Temp"+FolderSlash
Global LOGFOLDER:String = TempFolderPath+"Log"+FolderSlash


Global MOUNTERFOLDER:String = "Mounters"+FolderSlash
Global RESFOLDER:String = "Resources"+FolderSlash
Global APPFOLDER:String = "Plugins"+FolderSlash

?Win32
Global SevenZipPath:String = APPFOLDER + "critical\7zip\7z.exe"
?Not Win32
Global SevenZipPath:String = APPFOLDER + "critical/7zip/7z"
?
Global ResourceExtractPath:String = APPFOLDER + "critical\ResourcesExtract\ResourcesExtract.exe"

Global CurrentVersion:String = "V4.10"

Global WinDir:String = ""
Global WinBit:Int
Global WinExplorer:Int

Global Country:String = "UK"
Global Debug:Int = False
?Debug
	Debug=True
?	
Global DebugLogEnabled:Int = False

Global CabinateEnable:Int = False 
Global SilentRunnerEnabled:Int = True 

Global LogName:String = "Log.txt"
Global LogName2:String = "Log2.txt"
Global Connected:Int = 0

Global WriteLog:TStream
Global SettingFile:SettingsType = New SettingsType

Global EvaluationMode:Int = True

Global PLATFORMS:String[] = ["All" , ..
"3DO", ..
"Arcade", ..
"Atari 2600", ..
"Atari 5200", ..
"Atari 7800", ..
"Atari Jaguar" , ..
"Atari Jaguar CD", ..
"Atari XE", ..
"Colecovision", ..
"Commodore 64", ..
"Intellivision", ..
"Mac OS", ..
"Microsoft Xbox", ..
"Microsoft Xbox 360", ..
"NeoGeo", ..
"Nintendo 64", ..
"Nintendo DS", ..
"Nintendo Entertainment System (NES)", ..
"Nintendo Gameboy", ..
"Nintendo Gameboy Advance", ..
"Nintendo GameCube", ..
"Nintendo Wii", ..
"Nintendo Wii U", ..
"PC", ..
"Sega 32X", ..
"Sega CD", ..
"Sega Dreamcast", ..
"Sega Game Gear", ..
"Sega Genesis", ..
"Sega Master System", ..
"Sega Mega Drive", ..
"Sega Saturn", ..
"Sony Playstation", ..
"Sony Playstation 2", ..
"Sony Playstation 3", ..
"Sony Playstation Vita", ..
"Sony PSP", ..
"Super Nintendo (SNES)", ..
"TurboGrafx 16" ]

Global JPLATFORMS:String[] = ["3DO", ..
"Arcade", ..
"Atari 2600", ..
"Atari 5200", ..
"Atari 7800", ..
"Atari Jaguar", ..
"Atari Jaguar CD", ..
"Atari XE" , ..
"Colecovision", ..
"Commodore 64", ..
"Intellivision", ..
"Mac OS", ..
"Microsoft Xbox", ..
"Microsoft Xbox 360", ..
"NeoGeo", ..
"Nintendo 64", ..
"Nintendo DS", ..
"Nintendo Entertainment System (NES)", ..
"Nintendo Gameboy", ..
"Nintendo Gameboy Advance", ..
"Nintendo GameCube", ..
"Nintendo Wii", ..
"Nintendo Wii U", ..
"PC", ..
"Sega 32X", ..
"Sega CD", ..
"Sega Dreamcast", ..
"Sega Game Gear", ..
"Sega Genesis", ..
"Sega Master System", ..
"Sega Mega Drive", ..
"Sega Saturn", ..
"Sony Playstation", ..
"Sony Playstation 2", ..
"Sony Playstation 3", ..
"Sony Playstation Vita", ..
"Sony PSP", ..
"Super Nintendo (SNES)", ..
"TurboGrafx 16" ]

Global CERTIFICATES:String[] = ["Select..." , ..
"EC - Early Childhood" , ..
"E - Everyone" , ..
"E10+ - Everyone 10+" , ..
"T - Teen" , ..
"M - Mature" , ..
"RP - Rating Pending"]

Global SORTS:String[] = ["Alphabetical - Ascending" , ..
"Alphabetical - Descending" , ..
"Genre" , ..
"Release Date" , ..
"Developer" , ..
"Publisher" , ..
"Rating" , ..
"Completed" ]

Global RATINGLIST:String[] = ["Select..." , "1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" , "10"]

