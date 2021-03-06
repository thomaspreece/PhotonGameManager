Global PROGRAMICON:String = RESFOLDER + "Manager.ico"
'Global ExtractProgLoc:String = APPFOLDER+"ResourcesExtract\ResourcesExtract.exe"

Global wxEVT_COMMAND_SEARCHPANEL_SELECTED:Int = wxNewEventType()
Global wxEVT_COMMAND_SEARCHPANEL_SOURCECHANGED:Int = wxNewEventType()
Global wxEVT_COMMAND_SEARCHPANEL_NEWSEARCH:Int = wxNewEventType()


Const DEFAULTPLATFORMNUM:Int = 200


?Threaded
Global LogWinListMutex:TMutex = CreateMutex()
?
Global LogWinList:TList = CreateList()

?Threaded
Global LogOpenMutex:TMutex = CreateMutex()
?
Global LogOpen:int = 0

Global TempDebugLogEnabled = False 

Global SteamFolder:String = ""
Global SteamID:String = ""
Global ReloadApp = False

Global ArtworkCompression:Int = 85
Global GraphicsW:Int = 800
Global GraphicsH:Int = 600
Global GMode:Int = 1
Global GAMECACHELIMIT:Int = 10
Global LowMemory:Int = 0
Global LowProcessor:Int = 0
Global TouchKeyboardEnabled:Int = True 
Global ShowScreenButton:Int = True
Global ShowInfoButton:Int = True
Global ShowMenu:Int = True
Global ShowNavigation:Int = True
Global ShowSearchBox:Int = True

Global RunnerButtonCloseOnly:Int = False 
Global OriginWaitEnabled = True 
Global AntiAliasSetting:Int = 0
Global OnlineAddSource:String = ""	
Global OnlineAddPlatform:String = ""

Global EditGameName:String = ""
Global PMHideHelp:Int = 0

Global PRProcessQueryDelay:Int = 50
Global PRPluginQueryDelay:Int = 50

Global PMRed:Int = 185'190
Global PMGreen:Int = 210'190
Global PMBlue:Int = 255'255

Global PMRed2:Int = 215
Global PMGreen2:Int = 230
Global PMBlue2:Int = 255

Global PMRedF:Int = 0
Global PMGreenF:Int = 0
Global PMBlueF:Int = 0

Global PERed:Int = 185'190
Global PEGreen:Int = 210'190
Global PEBlue:Int = 255'255

Global PERed2:Int = 215 '215
Global PEGreen2:Int = 230 '230
Global PEBlue2:Int = 255 '255

Global PERed3:Int = 215 '215
Global PEGreen3:Int = 230 '230
Global PEBlue3:Int = 255 '255
?Win32
Global PMFont:wxFont = New wxFont.CreateFontWithAttributes(11, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL)
?MacOS
Global PMFont:wxFont = New wxFont.CreateFontWithAttributes(11, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL, 0,"LucidaGrande")
?Linux
Global PMFont:wxFont = New wxFont.CreateFontWithAttributes(11, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL)
?

Global PMMaximize:Int = 1

Global PMDefaultGameLua:String = "thegamesdb.net"
Global PMFetchAllArt:Int = 0

Global PM_GE_AddAllEXEs:Int = 0

Const GNTextH:Int = 0

Const MW_AGB = 41
Const MW_EGB = 42
Const MW_EB = 43
Const MW_UFG = 44
Const MW_GS = 45
Const MW_UGM = 46
Const MW_A = 47

Const EGL_ADD = 51
Const EGL_DEL = 52	
Const EGL_CAN = 53
Const EGL_SAVE = 54
Const EGL_EXIT = 55
Const EGL_PL = 56
Const EGL_SL = 57
Const EGL_FTB = 58
Const EGL_GL = 59
Const EGL_UPD = 60
Const LW_L = 61
Const SI_W = 62
Const SI_UIB = 63
Const SI_CB = 64
Const SI_BB = 65
Const EGL_DP_GN = 66
Const EGL_DP_GD = 67
Const EGL_DP_GRD = 68
Const EGL_DP_GR = 69
Const EGL_DP_GC = 70
Const EGL_DP_GDev = 71
Const EGL_DP_GPub = 72
Const EGL_DP_GG = 73
Const EGL_DP_GP = 74
Const EGL_AP_FBABB = 75
Const EGL_AP_BBABB = 76
Const EGL_AP_BGABB = 77
Const EGL_AP_BABB = 78
Const EGL_AP_IABB = 79
Const EGL_EP_EXEP = 80
Const EGL_EP_EXEB = 81
Const EGL_EP_CLO = 82
Const EGL_EP_EO = 87
Const EGL_DP_GCO = 88
Const EGL_DP_GPlay = 89
Const EGL_DP_GVid = 105
Const EGL_DP_TB = 106
Const EGL_A_RAO = 107
Const EGL_PreBF_WTF = 108
Const EGL_PostBF_WTF = 109


Const MI_CBL = 83
Const MI_SA = 84
Const MI_DA = 85
Const OI_GN = 86

'87-89 taken

Const MS_ST = 90
Const MS_SB = 91
Const MS_SL = 92
Const MS_EB = 93
Const MS_FB = 94
Const MS_PL = 95

Const EL_BB = 96
Const EL_OK = 97
Const EL_TP = 98

Const EGL_EEP_LC = 99
Const EGL_EEP_ADD = 100
Const EGL_EEP_DEL = 101
Const EGL_EEP_EXEP = 102
Const EGL_EEP_EXEB = 103
Const EGL_EEP_EXEN = 104
'105-109 Taken

'Const 110 - 190 Reserved

Const IM_MB = 191
Const IM_OB = 192
Const IM_BB = 193

Const SM_MB = 194
Const SM_OB = 195
Const SM_BB = 196
Const SM_CB = 197

Const AGM_MB = 200
Const AGM_OB = 201
Const AGM_SB = 202
Const AGM_IGB = 203
Const AGM_BB = 204

Const IP_M1_I1 = 210
Const IP_M1_I2 = 211
Const IP_M1_I3 = 212

Const IP_M2_I1 = 220
Const IP_M2_I2 = 221
Const IP_M2_I3 = 222

Const IP_M3_I1 = 230
Const IP_M3_I2 = 231
Const IP_M3_I3 = 232
Const IP_M3_I4 = 233

Const IP_M4_I1 = 240
Const IP_M4_I2 = 241
Const IP_M4_I3 = 242
Const IP_M4_I4 = 243

Const IP_M5_I1 = 250
Const IP_M5_I2 = 251
Const IP_M5_I3 = 252
Const IP_M5_I4 = 253
Const IP_M5_I5 = 254

Const EGL_PreBF_EXEP = 260
Const EGL_PreBF_EXEB = 261
Const EGL_PostBF_EXEP = 262
Const EGL_PostBF_EXEB = 263
Const EGL_AM_MC = 264
Const EGL_AM_MP = 265
Const EGL_AM_MB = 266
Const EGL_AM_VDC = 267
Const EGL_AM_UC = 268
Const EGL_AM_ISOP = 269
Const EGL_AM_ISOB = 270
Const EGL_A_SWE = 271
Const EGL_A_AddF = 272
Const EGL_A_AddE = 273
Const EGL_A_Del = 274
Const EGL_ULT = 275
Const EGL_OO = 276
Const EGL_M1_I1 = 277
Const EGL_M1_I2 = 278
Const EGL_GN = 279
Const EGL_EN = 280
Const EGL_EP_EO_B = 281

Const OA_PC = 300
Const OA_SP = 301
Const OA_SB = 302
Const OA_SU = 303
Const OA_EXIT = 304
Const OA_P3_AB = 305
Const OA_P3_SB = 306
Const OA_P3_CB = 307
Const OA_P3_SCB = 308

Const MS_EL = 350
Const MS_CB = 351

Const SCA_BB = 400
Const SCA_NTB = 401
Const SCA_ITB = 402
Const SCA_HB = 403

Const AP_OB = 450
Const AP_BB = 451
Const AP_AL = 452
Const AP_AP = 453
Const AP_SP = 454

Const SetM_DB = 475
Const SetM_GB = 476
Const SetM_PB = 477
Const SetM_BB = 478
Const SetM_DRB = 479

Const SW_BB = 500
Const SW_OB = 501
Const SW_SB = 502
Const SW_SP = 503
Const SW_CL = 504
Const SW_DF = 505
Const SW_R = 506
Const SW_M = 507
Const SW_LM = 508
Const SW_GC = 509
Const SW_LP = 510
Const SW_TK = 511
Const SW_SID = 512
Const SW_SIDG = 513
Const SW_C = 514 
Const SW_OP = 515 
Const SW_ODB = 516 
Const SW_KI = 517
Const SW_JI = 518
Const SW_OA1 = 519
Const SW_OA2 = 520
Const SW_OW = 521
Const SW_BCO = 522
Const SW_AA = 523
Const SW_STI = 524
Const SW_STS = 525
Const SW_MZ = 526
Const SW_DGL = 527
Const SW_DAA = 528
Const SW_DL = 529
Const SW_TFB = 530
Const SW_LFB = 531
Const SW_SFB = 532
Const SW_GFB = 533
Const SW_PQD = 534

Const PW_BB = 600
Const PW_OB = 601

Const PPPW_SB = 650
Const HKPW_KCB = 651
Const HKPW_SB = 652
Const HKPW_BB = 653
Const HKPW_T = 654
Const PPPW_BB = 655

'700-799 Reserved


Const SOI2_SIL = 800
Const SOI2_P3_AB = 801
Const SOI2_P3_SB = 802
Const SOI2_P3_CB = 803
Const SOI2_P3_SCB = 804
Const SOI2_EXIT = 805

Const EGL_OPT = 850
Const EGL_DP_ATB = 851

Const KIW_BB = 900
Const KIW_OB = 901
Const KIW_B = 902 
'Researved 902-999
Const KIW_T = 1001
Const KIW_JKT = 1002


Const AM_BB = 1100
Const AM_AB = 1101
Const AM_UN = 1102
Const AM_UK = 1103

Const OI2_EXIT = 1200
Const OI2_SAVE = 1201
Const OI2_SEL = 1202
Const OI2_DESEL = 1203

Const DSP_SS = 1300
Const DSP_ST = 1301
Const DSP_SB = 1302
Const DSP_SL = 1303
Const DSP_SP = 1304
Const DSP_HLC = 1305
Const DSP_T = 1306

Const MS_DSP = 1350

Const LW_T = 1400
Const LW_T2 = 1401

'Const 1510-1599 reserved

Const PL_ADD = 1601
Const PL_OK = 1602
Const PL_BB = 1603
Const PL_ED = 1604
Const PL_DEL = 1605
Const PL_PLC = 1606
Const PL_RD = 1607

Const AEPL_BB = 1701
Const AEPL_SA = 1702
Const AEPL_EB = 1703
Const AEPL_TDD = 1704

Global KeyboardInputText:String[] = ["Big Cover","Flip Cover", "Right", "Left" , "Up", "Down", "OK" , "Info", "Back", "Menu", "Search", "Rotate Platforms", "View ScreenShots", "End" ]
Global JoyStickInputText:String[] = ["Big Cover","Flip Cover", "OK" , "Menu" ,  "Search" , "Back", "Info", "Rotate Platforms", "View ScreenShots", "End" ]

Const EP_EXE_DescribeText1:String = "Below you can select what file PhotonFrontend or PhotonExplorer will run for this game ~n" + ..
"and any other command line options you require for this game. ~n" + ..
"If you do not know what 'command line options' are, then you don't need them. ~n"
Const EP_EXE_DescribeText2:String = "Below you can select what rom file PhotonFrontend or PhotonExplorer will pass to the emulator for this platform ~n" + ..
"and any other command line options you require for this rom to be passed to emulator. ~n" + ..
"Note: rom file will be inserted into [ROMPATH] and command line into [EXTRA-CMD] ~n" + ..
"see 'Emulators' tab from main menu for more info"

Const EP_EEXE_DescribeText1:String = "Below you can select other executables for this game that can be run from Frontend"

Const EP_TP2_Text:String = "Use the below option to override the default emulator for this single rom. Best use for this ~n" + ..
"option is for single games that have problems with the default platform emulator.~n" + ..
"Note: setting this option will mean that any change to the general platform emulator will not affect~n" + ..
"this rom."

Const OA_RP_Text:String = "~n Choose the executable from below that starts the game. ~n"
Const OA_LP_Text:String = "~n Search and select the game that is contained in this folder/file ~n"

Const SCA_ET_Text:String = "From here you can enter steam games manually using their ID, it is recommended to use the online steam import wizard first if possible. ~n" + ..
"If you are unsure on how to retrieve a steam game's ID click on help below."

Const BF_ET_Text:String = "Here you can select batch files to run before and after a game has run. ~n" + ..
"This is useful for loading your own programs or external scripts like autohotkey. ~n" + ..
"Note: Batch files are not loaded when executables other than the main game executable are run. ~n"

Const AM_ET_Text:String = "Here you can setup the AutoMounter for this game. ~n" + ..
"The Function of AutoMounter is to load game disc images automatically when you play a game. ~n" + ..
"Note: Changing 'Mounter Path' will change 'Mounter Path' for all games using this Mounter! ~n" +..
"Note2: AutoMount is not loaded when executables other than the main game executable are run. ~n"

Const A_ET_Text:String = "Here Are Some Advanced Options For This Game "
Const A_ET_Text2:String = "Watch Executable List"


Const EGL_Help_Details:String = "Details Tab Help ~nHere you can change various text information and categories for the game. ~nThe 'Youtube Video Code' field should be 11 characters long and can be found by taking the youtube video link and copying the 11 characters after the 'v=' part of the link. Press the 'Auto Find Trailer' button to automatically search youtube for a trailer and fill in the 'Youtube Video Code' field and press the 'View Trailer' button to open a browser to the Youtube video pointed to by the 'Youtube Video Code' field. "

Const EGL_Help_Artwork:String = "Artwork Tab Help ~nHere you can change the artwork that is used in PhotonExplorer and PhotonFrontend. ~nRight click on the artwork or click on the change button to bring up an options menu for each piece of artwork."

Const EGL_Help_Runner_Options:String = "Runner Options Tab Help ~nHere you can change settings for PhotonRunner, the program that handles running your games, batch files,AutoMounter and plugins. ~n~n" + ..
"Watch Executable List Help ~n" + ..
"PhotonRunner looks for which executables are running and will close when it cannot find the games main executable. If you want it to not close until another executable has also closed, add it to the below list and then PhotonRunner will then not close until your main executable and all those specified in the list below have finished. ~n Use the folder button to add all the executables within the folder to the list. "

Const EGL_Help_AutoMount:String = "AutoMount Tab Help ~nHere you can setup the AutoMounter for this game, which basically allows you to mount game disc images automatically when you start a game and optionally unmount them when finished. ~n~n" + ..
"Note: You will need the relevant software installed for this to work. ~n" + ..
"Note #2: Changing 'Mounter Path' will change it for all games using this specific Mounter. ~n" +..
"Note #3: AutoMount is not loaded when executables other than the main game executable are run. ~n"


Const EGL_Help_Batch:String = "Batch Files Tab Help ~nHere you can select batch files to run before and after your game has run. This is useful for loading your own programs or external scripts like autohotkey.~n~n" + ..
"Note: Batch files are not loaded when executables other than the main game executable are run. ~n"

Const EGL_Help_Other_Executables:String = "Other Executables Tab Help ~nBelow you can select other executables for this game that can be run from PhotonFrontend and PhotonExplorer by selecting them from the menu. ~n~nNote: Batch files and AutoMount are not run when you select to run one of these executables."

Const EGL_Help_ROM:String = "Rom Path Tab Help ~nBelow you can select what rom file PhotonFrontend or PhotonExplorer will pass to the emulator for this platform and any other command line options you require for this rom to be passed to emulator. 'Rom Path' will be inserted into [ROMPATH] and 'Extra Command Line Options' into [EXTRA-CMD] of the Platform emulator. ~n" + ..
"See 'Platforms' tab from main menu for more info ~n~nEmulator Override~n"+ ..
"Use this option to override the default emulator for this single rom. Best use for this option is for those few games that have problems with the default platform emulator.~n" + ..
"Note: setting this option will mean that any change to the general platform emulator will not affect this rom."

Const EGL_Help_Run:String = "Run Executable Path Tab Help ~nBelow you can select what executable PhotonFrontend or PhotonExplorer will run for this game and any other command line options you require for this game. ~n" + ..
"If you do not know what 'command line options' are, then you don't need them. ~n"

Global ShowUselessNotifys = True
Global ExtraKeyData:String = ""
Global Log1:LogWindow


Global SearchBeep:TSound 
Global CurrentSearchLine:String = ""
Global INum:Int = 0

Global PerminantPGMOff:Int = 0
Global EXEDatabaseOff:Int = 0

Global ProcessSpace1:TProcess
Global Process1Running:Int = 0
Global ProcessSpace2:TProcess
Global Process2Running:Int = 0
Global ProcessSpace3:TProcess
Global Process3Running:Int = 0
Global ProcessSpace4:TProcess
Global Process4Running:Int = 0
Global ProcessSpace5:TProcess
Global Process5Running:Int = 0
