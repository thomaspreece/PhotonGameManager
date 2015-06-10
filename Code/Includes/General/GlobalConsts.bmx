'Used in ShellExecute / Downloaders Version of ShellExecute
Const SEE_MASK_NOCLOSEPROCESS = $00000040
Const INFINITE = $FFFFFFFF
'

Global SubVersion:String
Global OSubVersion:String


'LuaVM Stuff
Global LuaVM:Byte Ptr
Global LuaBlank:String = "function GetPlatforms(PlatformID,List)~nend~nfunction GetText()~nend~nfunction SearchGame(Text,Platform,ListDepth,List)~nend"
Global SearchSourceLuaList:String[]
Global CurlUseragent:String = "Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0"

?Threaded
Global LuaEventMutex:TMutex = CreateMutex()
Global LuaMutex:TMutex = CreateMutex()
?
Global LuaEvent:String = ""




Global GlobalPlatforms:PlatformReader


?Threaded
Global Mutex_Print:TMutex = CreateMutex()
Global Mutex_DebugLog:TMutex = CreateMutex()
?

If FolderSlash = "/" Or FolderSlash = "\" Then
	
Else
	CustomRuntimeError("GlobalConsts - No FolderSlash")
EndIf 

Include "ProgramPaths.bmx"


Global SkipBatchWait:int = 0
Global FinishProgramRunning:int = 0

Global CurrentVersion:String = "V4.12"

Global WinDir:String = ""
Global WinBit:int
Global WinExplorer:int

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

