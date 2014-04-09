Global PROGRAMICON:String = RESFOLDER+"Database.ico"
'Global ExtractProgLoc:String = APPFOLDER+"ResourcesExtract\ResourcesExtract.exe"

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
	

Global EditGameName:String = ""

Const GNTextH:Int = 0

Const MW_AGB = 41 
Const MW_EGB = 42
Const MW_EB = 43
Const MW_UFG = 44
Const MW_GS = 45
Const MW_UGM = 46

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
Const SW_OP = 513
Const SW_ODB = 514
Const SW_KI = 515
Const SW_JI = 516
Const SW_OA1 = 517
Const SW_OA2 = 518

Const PW_BB = 600
Const PW_OB = 601

Const PPPW_SB = 650
Const HKPW_KCB = 651
Const HKPW_SB = 652

'700-799 Reserved


Const SOI2_SIL = 800
Const SOI2_P3_AB = 801
Const SOI2_P3_SB = 802
Const SOI2_P3_CB = 803
Const SOI2_P3_SCB = 804
Const SOI2_EXIT = 805

Const EGL_OPT = 850

Const KIW_BB = 900
Const KIW_OB = 901
Const KIW_B = 902 
'Researved 902-915
Const KIW_T = 916
Const KIW_JKT = 917

Global KeyboardInputText:String[] = ["Big Cover","Flip Cover", "Right", "Left" , "Up", "Down", "OK" , "Info", "Back/End", "Menu", "Search" ]
Global JoyStickInputText:String[] = ["Big Cover","Flip Cover", "OK" , "Menu" ,  "Search" , "Back", "Info"]

Const EP_EXE_DescribeText1:String = "Below you can select what file GameManager will run for this game ~n" + ..
"and any other command line options you require for this game. ~n" + ..
"If you do not know what 'command line options' are, then you don't need them. ~n"
Const EP_EXE_DescribeText2:String = "Below you can select what rom file GameManager will pass to the emulator for this platform ~n" + ..
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

Const SCA_ET_Text:String = "From here you can enter steam games manually using there ID, it is recommended to use the online or manual steam import wizards first before using this. ~n" + ..
"If you are unsure on how to retrieve a steam game's ID click on help below."

Const BF_ET_Text:String = "Here you can select batch files to run before and after a game has run. ~n" + ..
"This is useful for loading your own programs or external scripts like autohotkey. ~n" + ..
"Note: Batch files are not loaded when executables other than the main game executable are run. ~n"

Const AM_ET_Text:String = "Here you can setup the AutoMounter for this game. ~n" + ..
"The Function of AutoMounter is to load game disc images automatically when you play a game. ~n" + ..
"Note: Changing 'Mounter Path' will change 'Mounter Path' for all games using this Mounter! ~n" +..
"Note2: AutoMount is not loaded when executables other than the main game executable are run. ~n"

Const A_ET_Text:String = "Here are some advanced options for this game ~n"

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
