'MARK: JoyStick
Global JOY_BIGCOVER = 4
Global JOY_FLIPCOVER = 6
Global JOY_ENTER = 2
Global JOY_MENU = 9
Global JOY_FILTER = 8
Global JOY_CANCEL = 3
Global JOY_INFO = 1

'MARK: Keyboard
Global KEYBOARD_BIGCOVER = KEY_1
Global KEYBOARD_FLIPCOVER = KEY_2
Global KEYBOARD_RIGHT = KEY_RIGHT
Global KEYBOARD_LEFT = KEY_LEFT
Global KEYBOARD_UP = KEY_UP
Global KEYBOARD_DOWN = KEY_DOWN
Global KEYBOARD_ENTER = KEY_ENTER
Global KEYBOARD_INFO = KEY_I
Global KEYBOARD_ESC = KEY_ESCAPE
Global KEYBOARD_MENU = KEY_M
Global KEYBOARD_FILTER = KEY_F


'MARK: System
Const FRAMERATE:Int = 60
Const RENDERRATE:Float = 0.5
Global RenderLoop:Int = False 
Global RenderFrameNumber:Float = 0
Global GAMECACHELIMIT:Int = 10
Global LowMemory:Int = False
Global LowProcessor:Int = False  
'Global CORENUM:Int = 2
Global WideScreen:Int = 0
Global SpeedRatio# = 1
Global ExitProgramCall:Int = False
Global MenuActivated:Int = False
Global CurrentInterface:GeneralType
Global CurrentInterfaceNumber:Int

Global FilterMenuEnabled:Int = False
Global FilterType:String = "All Games"
Global FilterName:String = ""

Global GWidth:Int = 800
Global GHeight:Int = 600
Global GMode:Int = 0

Global ForceTextureReset:Int = False 
Global TouchKeyboardEnabled:Int = True

Global KeyboardLayout:String[] = ["1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" , "0" ,..
			"q" , "w" , "e" , "r" , "t" , "y" , "u" , "i" , "o" , "p" ,..
			"a" , "s" , "d" , "f" , "g" , "h" , "j" , "k" , "l" , "BkSp"  ,..
			"ESC" , "z" , "x" , "c" , "v" , "b" , "n" , "m" ,  "Space" , "Enter" ]

'MARK: Game
Global GameArray:String[0]
Global GameArrayLen:Int
Global CurrentGamePos:Int = 0
Global Filter:String = ""
Global GamesPlatformFilter:String = ""
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
Global ExtraResNeeded:String = ""
Global VerticalCoverLoad:Int = 0
'Global Shot1Needed:Int = 1
'Global Shot2Needed:Int = 1

'MARK: Texture/Process Lists
Global TextureQueue:TList = CreateList()
Global ProcessStack:TList = CreateList()
Global ProcessedTextures:TList = CreateList()
Global InUseTextures:TList = CreateList()

'MARK: Mutex/Semaphore/Thread Signals
Global Mutex_Print:TMutex = CreateMutex()
Global Mutex_DebugLog:TMutex = CreateMutex()
Global StartupThread:TSemaphore = CreateSemaphore(0)
Global WaitingThread:TSemaphore = CreateSemaphore(0)
Global Mutex_ResetTextureThread:TMutex = CreateMutex()
Global Mutex_CloseTextureThread:TMutex = CreateMutex()
Global Mutex_TextureQueue:TMutex = CreateMutex()
Global Mutex_ProcessStack:TMutex = CreateMutex()
Global Mutex_ThreadStatus:TMutex = CreateMutex()
Global ResetTextureThread:Int = 0
Global CloseTextureThread:Int = 0
Global ThreadStatus:Int = 0


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










