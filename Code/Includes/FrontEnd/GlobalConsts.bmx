'MARK: JoyStick
Global JOY_BIGCOVER = 4
Global JOY_FLIPCOVER = 6
Global JOY_ENTER = 2
Global JOY_MENU = 9
Global JOY_FILTER = 8
Global JOY_CANCEL = 3
Global JOY_INFO = 1
Global JOY_PLATROTATE = 5
Global JOY_SCREEN = 7
Global JOY_END = 10


'MARK: Keyboard
Global KEYBOARD_BIGCOVER = KEY_1
Global KEYBOARD_FLIPCOVER = KEY_2
Global KEYBOARD_RIGHT = KEY_RIGHT
Global KEYBOARD_LEFT = KEY_LEFT
Global KEYBOARD_UP = KEY_UP
Global KEYBOARD_DOWN = KEY_DOWN
Global KEYBOARD_ENTER = KEY_ENTER
Global KEYBOARD_INFO = KEY_I
Global KEYBOARD_ESC = KEY_F1 'Now the back Button
Global KEYBOARD_MENU = KEY_M
Global KEYBOARD_FILTER = KEY_F
Global KEYBOARD_PLATROTATE = KEY_P
Global KEYBOARD_SCREEN = KEY_S
Global KEYBOARD_END = KEY_ESCAPE



'MARK: System
Const FRAMERATE:Int = 60
Const RENDERRATE:Float = 0.5
Global RenderLoop:Int = False 
Global RenderFrameNumber:Float = 0
Global GAMECACHELIMIT:int = 10
Global LowMemory:Int = False
Global TempLowMemoryControl:Int = False 
Global MaxFrontCovers:Int = 50
Global LowProcessor:Int = False  
'Global CORENUM:Int = 2
Global WideScreen:Int = 0
Global SpeedRatio# = 1
Global ExitProgramCall:Int = False
Global MenuActivated:Int = False
Global CurrentInterface:GeneralType
Global CurrentInterfaceNumber:Int

Global FilterMenuEnabled:Int = False
Global HaltStack:Int = False


Global GWidth:Int = 800
Global GHeight:Int = 600
Global GMode:Int = 0
Global AntiAliasSetting:Int = 0

Global ForceTextureReset:Int = False 
Global TouchKeyboardEnabled:Int = True
Global ShowScreenButton:int = True
Global ShowInfoButton:int = True
Global ShowMenuButton:int = True
Global ShowSearchBar:int = True
Global ShowNavigation:int = True

Global KeyboardLayout:String[] = ["1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" , "0" ,..
			"Q" , "W" , "E" , "R" , "T" , "Y" , "U" , "I" , "O" , "P" , ..
			"A" , "S" , "D" , "F" , "G" , "H" , "J" , "K" , "L" , "BkSp" , ..
			"Cancel" , "Z" , "X" , "C" , "V" , "B" , "N" , "M" , "Space" , "Go" ]

'MARK: Game
Global GameArray:String[0]
Global GameArrayLen:Int
Global GameArrayUpdated:Int = 0 

Global UsedPlatformList:TList 

Global CurrentGamePos:Int = 0
Global Filter:String = ""

Global FilterType:String = "All Games"
Global FilterName:String = ""

Global GamesPlatformFilter:int = 0
Global GamesGenreFilter:String = ""
Global GamesRelFilter:String = ""
Global GamesCompFilter:String = ""
Global GamesRateFilter:String = ""
Global GamesPlayerFilter:String = ""
Global GamesCoopFilter:String = ""
Global GamesDeveloperFilter:String = ""
Global GamesPublisherFilter:String = ""
Global GamesCertificateFilter:String = ""
Global GamesSortFilter:String = ""

Global TextScrollRate:Float = 0.1

'MARK: Menu
Global MainMenuPos = -1

'MARK: Timers
Global FrameTimer:Int = MilliSecs()
Global OverProcessTime:Int = 0
Global RendersWithoutProcess:Int = 0

'MARK: Objects
Global UpdateTypeList:TList = CreateList()
Global Camera:TCamera
Global GameNode:GameReadType = New GameReadType

'MARK: Fonts
Global NameFont:TImageFont
Global MainTextFont:TImageFont
Global MenuButtonFont:TImageFont
Global MenuButtonFont2:TImageFont
Global MenuFont:TImageFont
Global BigMenuFont:TImageFont
Global FilterFont:TImageFont
Global SmallMenuButtonFont:TImageFont

'MARK: Mouse
Global MouseStart:Int[2]
Global MouseEnd:Int[2]
Global MouseSwipe:Int = 0
Global MouseSwipeTime:Int = 0
Global MouseClick:Int = 0

'MARK: Texture Process Options
Global FrontNeeded:Int = 1
Global BackNeeded:Int = 1
Global ScreenNeeded:Int = 1
Global BannerNeeded:Int = 1
'Global ExtraResNeeded:String = ""
'Global VerticalCoverLoad:Int = 0
'Global Shot1Needed:Int = 1
'Global Shot2Needed:Int = 1

'MARK: Texture/Process Lists
Global TextureQueue:TList = CreateList()
Global ProcessStack:TList = CreateList()
Global ProcessedTextures:TList = CreateList()
Global InUseTextures:TList = CreateList()

'MARK: Mutex/Semaphore/Thread Signals
Global StartupThread:TSemaphore = CreateSemaphore(0)
Global WaitingThread:TSemaphore = CreateSemaphore(0)
Global Mutex_ResetTextureThread:TMutex = CreateMutex()
Global Mutex_CloseTextureThread:TMutex = CreateMutex()
Global Mutex_TextureQueue:TMutex = CreateMutex()
Global Mutex_ProcessStack:TMutex = CreateMutex()
Global Mutex_ThreadStatus:TMutex = CreateMutex()
Global ResetTextureThread:Int = 0
Global CloseTextureThread:int = 0
Global ThreadStatus:Int = 0

Global WaitingThread2:TSemaphore = CreateSemaphore(0)
Global StartupThread2:TSemaphore = CreateSemaphore(0)

Global Mutex_UpdateStackThreadResources:TMutex = CreateMutex()


Global USTR_CGP:Int = 0
Global USTR_GCL:Int = 0
Global USTR_GAL:Int = 0
Global USTR_LM:Int = 0
Global USTR_CIN:Int = 0
Global USTR_GA:String[]
Global USTR_UGA:Int = 0 'Update GameArray?

Rem
Global RTextureQueue:TList = CreateList()
Global ThreadsAwake:Int = 0
Global CurrentGamePosThreaded:Int = 0
Global GameArrayLenThreaded:Int = 0
Global GameArrayThreaded:String[0]

Global Mutex_TextureTypes:TMutex = CreateMutex()
Global Mutex_GameArrayThreaded:TMutex = CreateMutex()
Global Mutex_RTextureQueue:TMutex = CreateMutex()
Global Mutex_CurrentGamePosThreaded:TMutex = CreateMutex()
Global Mutex_ProcessedTextures:TMutex = CreateMutex()
Global Mutex_InUseTextures:TMutex = CreateMutex()
Global SubThreadSleepMutex:TMutex = CreateMutex()
Global SubThreadSleep:TCondVar = CreateCondVar()
Global Mutex_TextureLock:TMutex = CreateMutex()
endrem










