Global RunnerButtonCloseOnly:int = False
Global OriginWaitEnabled = True 

Global wxEVT_COMMAND_SEARCHPANEL_SOURCECHANGED:int = wxNewEventType()

Const GES_GL = 1001
Const GES_PL = 1002
Const GES_FTB = 1003
Const GES_SL = 1004
Const GES_TB = 1005
Const GES_GN = 1006
Const GES = 1007
Const GES_TW = 1008

Const IP_M1_I1 = 1100
Const IP_M1_I2 = 1101
Const IP_M1_I3 = 1102
Const IP_M1_I4 = 1103
Const IP_M1_I5 = 1104
Const GES_SWS = 1105

Const GL_M1_RG = 1201
'1201 - 1299 reserved

Const GL_SM1_IV = 1300
Const GL_SM1_LI = 1301
Const GL_SM1_LNI = 1302

Const GL_SM2_FA = 1325
Const GL_SM2_FAN = 1326
Const GL_SM2_IA = 1327
Const GL_SM2_BA = 1328

Const GL_SM3_16 = 1350
Const GL_SM3_32 = 1351
Const GL_SM3_64 = 1352
Const GL_SM3_128 = 1353
Const GL_SM3_256 = 1354
Const GL_SM3_512 = 1355

Const GL_SM4_Y = 1375
Const GL_SM4_N = 1376

Const GL_SM5_Y = 1377
Const GL_SM5_N = 1378

Const GL_FM_Key = 1379
Const GL_FM_Exit = 1380

Const PR_EB = 1390

Const GS_OSB = 1400

Const GP_SP_ST = 1450
Const GP_PL = 1451
Const GP_SP_SB = 1452
Const GP_DP = 1453
Const GLP_PL = 1454
Const GLP_PFL = 1455
Const GP_GPN = 1456

Const GM_DM = 1457
Const GM_ML = 1458
Const GM_SP_SB = 1459
Const GM_SP_ST = 1460
Const GLM_ML = 1461
Const GM_GPN = 1462

Const GW_GWN = 1463
Const GLW_WL = 1464
Const GLW_WFL = 1465
Const GW_SP_SB = 1466
Const GW_SP_ST = 1467
Const GW_WL = 1468
Const GW_DW = 1469
Const GW_SP_SC = 1470

Const GC_GCN = 1471
Const GLC_CL = 1472
Const GC_SC_SC = 1473
Const GC_SC_ST = 1474
Const GC_SC_SB = 1475
Const GC_CL = 1476
Const GC_DC  = 1477

Const GDP_GRC = 1500
Const GDP_GCC = 1501

Const PM_I1 = 1600
Const PM_I2 = 1601
Const PM_I3 = 1602
Const PM_I4 = 1603
Const PM_I5 = 1604

Const PR_T = 1625
Const PR_KT = 1626
Const PR_T2 = 1627

Const SRT1 = 1700
Const SRT2 = 1701
Const SRT3 = 1702

Const GW_DP_DT = 1800
Const GW_DP_DSo = 1801
Const GW_DP_DSe = 1802
Const GM_DP_DL = 1803
Const GM_DP_SB = 1804
Const GM_DP_SHL = 1805
Const GW_DP_DP = 1806
Const GM_DP_LS = 1807

Const LT1 = 1851
Const WS = 1852
Const RT1 = 1853
Const MT1 = 1854
Const FT1 = 1855

Global PROGRAMICON:String = RESFOLDER + "Explorer.ico"
?Win32
Const BackEnd:String = wxMEDIABACKEND_WMP10
Const ShowPlayerCtrls:int = 0
?


Global CmdLineGameName:String = ""
Global CmdLineGameTab:String = ""
Global CmdLineCabinate:Int = 0 '0-No Cabinate, 1-FrontEnd, 2-Explorer
Global IconSize = 32
Global GameListStyle = wxLC_ICON | wxSUNKEN_BORDER | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE
Global GameListIconType:Int = 5
Global GameListText:Int = 1
Global ShowIcons:Int = 1
Global GenericArt:Int = 0 '0 use generic, -1 hide generic

Global Trailercurl:TCurlEasy
Global GameNode:GameReadType
Global CurrentSearchLine:String

Global InternetTimeout:Int 

Global Beep = LoadSound(RESFOLDER + "BEEP.wav")

Const BannerFloat:Float = 5



Global PERed:int = 185'190
Global PEGreen:int = 210'190
Global PEBlue:int = 255'255

Global PERed2:int = 215 '215
Global PEGreen2:int = 230 '230
Global PEBlue2:int = 255 '255

Global PERed3:int = 215 '215
Global PEGreen3:int = 230 '230
Global PEBlue3:int = 255 '255

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

