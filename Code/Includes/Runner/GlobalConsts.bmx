Global RunnerButtonCloseOnly:int = False
Global OriginWaitEnabled = True
Global SkipBatchWait:int = 0
Global FinishProgramRunning:int = 0

Global ProcessQueryDelay:int = 50
Global PluginQueryDelay:int = 50

Global PhotonRunnerApp:PhotonRunner

Const PR_EB = 1390
Const PR_T = 1625
Const PR_KT = 1626
Const PR_T2 = 1627
Const PR_SPT = 1628


Global EXEExcludeList:TList = CreateList()
Global PROGRAMICON2:String = RESFOLDER + "Runner2.ico"

Global CmdLineGameName:String = ""
Global CmdLineGameTab:String = ""
Global CmdLineCabinate:int = 0 '0-No Cabinate, 1-FrontEnd, 2-Explorer


Global Trailercurl:TCurlEasy
Global GameNode:GameReadType
Global CurrentSearchLine:String

Global InternetTimeout:Int 

Global HotKey:GlobalHotkey = New GlobalHotkey
Global Beep=LoadSound(RESFOLDER+"BEEP.wav")

Const BannerFloat:Float = 5



Global PRRed:int = 185'190
Global PRGreen:int = 210'190
Global PRBlue:int = 255'255

Const SizeOf_PE32 = 296
Const TH32CS_SNAPHEAPLIST = $1
Const TH32CS_SNAPPROCESS = $2
Const TH32CS_SNAPTHREAD = $4
Const TH32CS_SNAPMODULE = $8
Const TH32CS_SNAPALL = (TH32CS_SNAPHEAPLIST | TH32CS_SNAPPROCESS | TH32CS_SNAPTHREAD | TH32CS_SNAPMODULE)
Const TH32CS_INHERIT = $80000000
Const INVALID_HANDLE_VALUE = -1
Const MAX_PATH = 260

?Win32
k32 = LoadLibraryA ("kernel32.dll")

If Not k32 Then Notify "No kernel! Yikes!"; End

Global CreateToolhelp32Snapshot (flags, th32processid) "Win32" = GetProcAddress (k32, "CreateToolhelp32Snapshot")
Global Process32First (snapshot, entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Process32First")
Global Process32Next (snapshot, entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Process32Next")
Global Module32First (snapshot, entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Module32First")
Global Module32Next (snapshot, entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Module32Next")
Global Thread32First (snapshot, entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Thread32First")
Global Thread32Next (snapshot, entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Thread32Next")
Global Heap32First (snapshot, entry:Byte Ptr, th32heapid) "Win32" = GetProcAddress (k32, "Heap32First")
Global Heap32Next (entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Heap32Next")
Global Heap32ListFirst (snapshot, entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Heap32ListFirst")
Global Heap32ListNext (snapshot, entry:Byte Ptr) "Win32" = GetProcAddress (k32, "Heap32ListNext")
Global Toolhelp32ReadProcessMemory (th32processid, baseaddress, buffer:Byte Ptr, Read_bytes, _bytesread) "Win32" = GetProcAddress (k32, "Toolhelp32ReadProcessMemory")
'Global CloseHandle (_Object) "Win32" = GetProcAddress (k32, "CloseHandle")

Global PE32List:TList = CreateList ()
Global MainProcessList:ProcessListingType
Global PROC_COUNT
?

'Global RunnerEXENumber:Int
'Global RunnerGameName:String
'Global RunnerMode:Int

Global GAMEFAQPLATFORMS:String[] = ["All Platforms", ..
"3DS", ..
"DS", ..
"iPhone/iPod", ..
"Mobile", ..
"PC", ..
"PlayStation 2", ..
"PlayStation 3", ..
"PlayStation Vita", ..
"Wii", ..
"Wii U", ..
"Xbox 360", ..
"3DO", ..
"Acorn Archimedes", ..
"Adventurevision", ..
"Amiga", ..
"Amiga CD32", ..
"Amstrad CPC", ..
"Android", ..
"APF-*1000/IM", ..
"Apple II", ..
"Arcade Games", ..
"Arcadia 2001", ..
"Astrocade", ..
"Atari 2600", ..
"Atari 5200", ..
"Atari 7800", ..
"Atari 8-bit", ..
"Atari ST", ..
"Bandai Pippin", ..
"BBC Micro", ..
"BBS Door", ..
"BlackBerry", ..
"Casio Loopy", ..
"Cassette Vision", ..
"CD-I", ..
"Channel F", ..
"Colecovision", ..
"Commodore 64", ..
"Commodore PET", ..
"CPS Changer", ..
"CreatiVision", ..
"Dreamcast", ..
"DVD Player", ..
"e-Reader", ..
"EACA Colour Genie 2000", ..
"Famicom Disk System", ..
"Flash", ..
"FM Towns", ..
"FM-7", ..
"Game Boy", ..
"Game Boy Advance", ..
"Game Boy Color", ..
"Game.com", ..
"GameCube", ..
"GameGear", ..
"Genesis", ..
"Gizmondo", ..
"GP32", ..
"Intellivision", ..
"Interton VC4000", ..
"Jaguar", ..
"Jaguar CD", ..
"LaserActive", ..
"Lynx", ..
"Macintosh", ..
"Mattel Aquarius", ..
"Microvision", ..
"MSX", ..
"N-Gage", ..
"NEC PC88", ..
"NEC PC98", ..
"Neo-Geo CD", ..
"NeoGeo", ..
"NeoGeo Pocket Color", ..
"NES", ..
"Nintendo 64", ..
"Nintendo 64DD", ..
"Nuon", ..
"Odyssey", ..
"Odyssey^2", ..
"Online/Browser", ..
"Oric 1/Atmos", ..
"OS/2", ..
"Palm OS Classic", ..
"Palm webOS", ..
"PC-FX", ..
"Pinball", ..
"Playdia", ..
"PlayStation", ..
"PSP", ..
"RCA Studio II", ..
"Redemption", ..
"Saturn", ..
"Sega 32X", ..
"Sega CD", ..
"Sega Master System", ..
"SG-1000", ..
"Sharp X1", ..
"Sharp X68000", ..
"Sinclair ZX81/Spectrum", ..
"SNES", ..
"Sord M5", ..
"Super Cassette Vision", ..
"SuperVision", ..
"Tandy Color Computer", ..
"TI-99/4A", ..
"Turbo CD", ..
"TurboGrafx-16", ..
"Unix/Linux", ..
"Vectrex", ..
"VIC-20", ..
"Virtual Boy", ..
"Windows Mobile", ..
"WonderSwan", ..
"WonderSwan Color", ..
"Xbox", ..
"Zeebo", ..
"Zodiac"]

