Framework BRL.FileSystem
Import BRL.StandardIO
Import BRL.Threads
Import BRL.Max2D
Import BRL.Freetypefont
Import Bah.libcurlssl

Import sidesign.minib3d

Import Bah.libxml
Import Bah.Regex
Import BaH.Volumes
Import PUB.FreeProcess
Import Pub.FreeJoy

'TODO: Get close window cross button to actually end the program


'NOTHING IMPORTANT HERE!
'Max2D - MouseX,MouseY incorrect on Ubuntu V.M - Fine on native Ubuntu!
'BUG: Windows 8 Doesn't work - Believed to be fixed
'All subfiles checked, no pending fixes found
'FIX: Flushkeys/ flushmouse in important events to stop key pileup
'MAYBE FIX: Reorganise loader into items required on screen straight away and remaining items for the gamecache
'Ex: Backgrounds for all other games on InfoView should be loaded after all covers
'NOTE: Be extremely careful with applyed textures, make sure they arn't removed!
'END OF NOTHING IMPORTANT HERE!


?Linux
Import "-ldl"
?


?Not Win32
Global FolderSlash:String="/"

?Win32
Import "Icons\PhotonFrontEnd.o"
Global FolderSlash:String ="\"
?

AppTitle = "PhotonFrontEnd"

Include "Includes\General\StartupOverrideCheck.bmx"
Local TempFolderPath:String = OverrideCheck(FolderSlash)

Include "Includes\FrontEnd\GlobalConsts.bmx"
Include "Includes\General\GlobalConsts.bmx"

AppTitle = "Photon"
' Revision Version Generation Code
' @bmk include Includes/General/Increment.bmk
' @bmk doOverallVersionFiles Version/OverallVersion.txt
?Win32
' @bmk doIncrement Version/PF-Version.txt 1
?Mac
' @bmk doIncrement Version/PF-Version.txt 2
?Linux
' @bmk doIncrement Version/PF-Version.txt 3
?
Incbin "Version/PF-Version.txt"
Incbin "Version/OverallVersion.txt"

SubVersion = ExtractSubVersion(LoadText("incbin::Version/PF-Version.txt"), 1)
OSubVersion = ExtractSubVersion(LoadText("incbin::Version/OverallVersion.txt"), 1)

Print "Version = " + CurrentVersion
Print "SubVersion = " + SubVersion
Print "OSubVersion = " + OSubVersion

DebugCheck()
FolderCheck()

LogName = "Log-FrontEnd"+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
CreateFile(LOGFOLDER + LogName)
LogName2 = "Log-FrontEnd-2ndCore"+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
CreateFile(LOGFOLDER+LogName2)



Local StartWait:int = 0
Local ForceFront:int = 0

Local PastArgument:String 
For Argument$ = EachIn AppArgs$
	Select PastArgument
		Case "-Debug","Debug"
			If Int(Argument) = 1 Then 
				DebugLogEnabled = True
			EndIf 
			PastArgument = ""
		Case "-Wait","Wait"
			StartWait = Int(Argument)
			PastArgument = ""	
		Case "-ForceFront","ForceFront"	
			ForceFront = Int(Argument)
			PastArgument = ""		
		Default
			Select Argument
				Case "-Debug","Debug","-Wait","Wait","-ForceFront","ForceFront"	
					PastArgument = Argument
			End Select
	End Select
Next

If DebugLogEnabled=False Then 
	DeleteFile(LOGFOLDER + LogName)
	DeleteFile(LOGFOLDER + LogName2)
EndIf 


Include "Includes\General\General.bmx"
Include "Includes\General\ValidationFunctions.bmx"
Include "Includes\FrontEnd\General.bmx"


CheckKey()
If EvaluationMode = True Then 
	Notify "You are running in evaluation mode, this limits you to 5 games."
EndIf 

CheckInternet()
CheckVersion()

SettingFile.ParseFile(SETTINGSFOLDER + "FrontEnd.xml")

WindowsCheck()

SetupPlatforms()
OldPlatformListChecks()
'CORENUM = 2'CpuCount()
'PrintF("Found "+CORENUM+" Cores/Threads")


PopulateGames()
PopulateUsedPlatformList()

If GameArrayLen < 1 Then 
	If Confirm("You don't have any games in your libary yet. Would you like to load PhotonManager?") = 1 Then 
		RunProcess(MANAGERPROGRAM,1)
		End
	Else
		End
	EndIf 
EndIf 
'CurrentGamePos = 10

Local Depth:Int = 32

LoadGlobalSettings()

If Abs(Float(GWidth) / GHeight - Float(4) / 3) < 0.1 Then
	WideScreen = 0
Else
	WideScreen = 1
EndIf

Local GRAPHICS_MULTISAMPLE

Select AntiAliasSetting
	Case 2
		GRAPHICS_MULTISAMPLE = $40
	Case 4
		GRAPHICS_MULTISAMPLE = $80
	Case 8
		GRAPHICS_MULTISAMPLE = $100
	Case 16
		GRAPHICS_MULTISAMPLE = $200
	Default
		GRAPHICS_MULTISAMPLE = 0		
End Select

'Works Perfectly with my NVIDIA CARD, doesn't work with internal graphics


PrintF("WideScreen: "+WideScreen)
PrintF("Starting Graphics with: "+GWidth+"x"+GHeight+" "+Depth+"bit "+"mode "+GMode+" @"+FRAMERATE)
Delay(StartWait)


Graphics3D GWidth , GHeight , Depth , GMode , FRAMERATE , GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER|GRAPHICS_ACCUMBUFFER|GRAPHICS_MULTISAMPLE

?Win32
If ForceFront=1 Then
	hWnd=GetActiveWindow()
	OurThreadID = GetCurrentThreadId()
	
	Local ahwnd:Byte Ptr 
	CurrentThreadID = GetWindowThreadProcessId(GetForegroundWindow(),ahwnd)
	
	PrintF("Our Thread: "+OurThreadID)
	PrintF("Current Thread: "+CurrentThreadID)
	PrintF("Win: "+hWnd)
	
	If OurThreadID<>CurrentThreadID Then 
		AttachThreadInput(OurThreadID,CurrentThreadID,True)
	EndIf 
	
	SetForegroundWindow(hWnd)
	BringWindowToTop(hWnd)
	'SetActiveWindow(hWnd)
	
	If OurThreadID<>CurrentThreadID Then 
		AttachThreadInput(OurThreadID,CurrentThreadID,False)
	EndIf 
EndIf 
?


PrintF("Graphics Set")

'MARK: INITIAL SETUP
CAMERA = CreateCamera()
PositionEntity CAMERA , 0 , 0 , - 4

Local Tex:TTexture
Local GreyTex:TTexture
Tex = LoadTexture(RESFOLDER + "NoCover.jpg")
If Tex = Null Then RuntimeError "NoCover.jpg not found"
Tex = LoadTexture(RESFOLDER + "Loading.jpg")
If Tex = Null Then RuntimeError "Loading.jpg not found"

Tex = LoadTexture(RESFOLDER + "NoBanner.png",2)
If Tex = Null Then RuntimeError "NoBanner.png not found"
Tex = LoadTexture(RESFOLDER + "BannerLoading.png")
If Tex = Null Then RuntimeError "BannerLoading.png not found"
Tex = LoadTexture(RESFOLDER + "Black.jpg")
If Tex = Null Then RuntimeError "Black.jpg not found"

Tex = LoadTexture(RESFOLDER + "NoBack.jpg")
If Tex = Null Then RuntimeError "NoBack.jpg not found"
Tex = LoadTexture(RESFOLDER + "BackLoading.jpg")
If Tex = Null Then RuntimeError "BackLoading.jpg not found"
GreyTex = LoadTexture(RESFOLDER + "Gray.jpg")
If GreyTex = Null Then RuntimeError "Gray.jpg not found"


SkyBox:TMesh = CreateSphere(8)
ScaleEntity(SkyBox , 1000, 1000, 1000)
EntityFX(SkyBox , 1)
FlipMesh(SkyBox)
EntityTexture(SkyBox , GreyTex)



Menu:MenuWrapperType = New MenuWrapperType
Menu.Init()

Local RePopulate = False

CurrentInterfaceNumber = Int(SettingFile.GetSetting("Interface") )
CurrentInterface = New GeneralType
If SettingFile.GetSetting("CurrentGamePos") <> "" Then
	CurrentGamePos = Int(SettingFile.GetSetting("CurrentGamePos") )
	If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1
	If CurrentGamePos < 0 Then CurrentGamePos = 0
EndIf 
If SettingFile.GetSetting("Filter") <> "" Then		
	Filter = SettingFile.GetSetting("Filter")
	RePopulate=True 
EndIf	
If SettingFile.GetSetting("FilterType") <> "" Then		
	FilterType = SettingFile.GetSetting("FilterType")
	RePopulate=True 	
EndIf	
If SettingFile.GetSetting("FilterName") <> "" then		
	FilterName = SettingFile.GetSetting("FilterName")
	RePopulate=True 	
EndIf	

If SettingFile.GetSetting("GamesSortFilter") <> "" Then		
	GamesSortFilter = SettingFile.GetSetting("GamesSortFilter")
	RePopulate=True 	
EndIf	

If SettingFile.GetSetting("GamesPlatformFilter") <> "" Then		
	GamesPlatformFilter = int(SettingFile.GetSetting("GamesPlatformFilter") )
	RePopulate = True 	
EndIf	
If SettingFile.GetSetting("GamesGenreFilter") <> "" Then		
	GamesGenreFilter = SettingFile.GetSetting("GamesGenreFilter")
	RePopulate = True 	
EndIf	
If SettingFile.GetSetting("GamesRelFilter") <> "" Then		
	GamesRelFilter = SettingFile.GetSetting("GamesRelFilter")
	RePopulate=True 	
EndIf	
If SettingFile.GetSetting("GamesCompFilter") <> "" Then		
	GamesCompFilter = SettingFile.GetSetting("GamesCompFilter")
	RePopulate=True 	
EndIf	
If SettingFile.GetSetting("GamesRateFilter") <> "" Then		
	GamesRateFilter = SettingFile.GetSetting("GamesRateFilter")
	RePopulate=True 	
EndIf	
If SettingFile.GetSetting("GamesPlayerFilter") <> "" Then		
	GamesPlayerFilter = SettingFile.GetSetting("GamesPlayerFilter")
	RePopulate=True 	
EndIf	
If SettingFile.GetSetting("GamesCoopFilter") <> "" Then		
	GamesCoopFilter = SettingFile.GetSetting("GamesCoopFilter")
	RePopulate=True 	
EndIf	
If SettingFile.GetSetting("GamesDeveloperFilter") <> "" Then		
	GamesDeveloperFilter = SettingFile.GetSetting("GamesDeveloperFilter")
	RePopulate=True 	
EndIf	
If SettingFile.GetSetting("GamesPublisherFilter") <> "" Then		
	GamesPublisherFilter = SettingFile.GetSetting("GamesPublisherFilter")
	RePopulate=True 	
EndIf	
If SettingFile.GetSetting("GamesCertificateFilter") <> "" Then		
	GamesCertificateFilter = SettingFile.GetSetting("GamesCertificateFilter")
	RePopulate=True 	
EndIf	


'Keyboard Read
If Int(SettingFile.GetSetting("KEYBOARD_BIGCOVER")) <> 0 Then
	KEYBOARD_BIGCOVER = Int(SettingFile.GetSetting("KEYBOARD_BIGCOVER"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_FLIPCOVER")) <> 0 Then
	KEYBOARD_FLIPCOVER = Int(SettingFile.GetSetting("KEYBOARD_FLIPCOVER"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_RIGHT")) <> 0 Then
	KEYBOARD_RIGHT = Int(SettingFile.GetSetting("KEYBOARD_RIGHT"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_LEFT")) <> 0 Then
	KEYBOARD_LEFT = Int(SettingFile.GetSetting("KEYBOARD_LEFT"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_UP")) <> 0 Then
	KEYBOARD_UP = Int(SettingFile.GetSetting("KEYBOARD_UP"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_DOWN")) <> 0 Then
	KEYBOARD_DOWN = Int(SettingFile.GetSetting("KEYBOARD_DOWN"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_ENTER")) <> 0 Then
	KEYBOARD_ENTER = Int(SettingFile.GetSetting("KEYBOARD_ENTER"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_INFO")) <> 0 Then
	KEYBOARD_INFO = Int(SettingFile.GetSetting("KEYBOARD_INFO"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_ESC")) <> 0 Then
	KEYBOARD_ESC = Int(SettingFile.GetSetting("KEYBOARD_ESC"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_MENU")) <> 0 Then
	KEYBOARD_MENU = Int(SettingFile.GetSetting("KEYBOARD_MENU"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_FILTER")) <> 0 Then
	KEYBOARD_FILTER = Int(SettingFile.GetSetting("KEYBOARD_FILTER"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_PLATROTATE")) <> 0 Then
	KEYBOARD_PLATROTATE = Int(SettingFile.GetSetting("KEYBOARD_PLATROTATE"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_SCREEN")) <> 0 Then
	KEYBOARD_SCREEN = Int(SettingFile.GetSetting("KEYBOARD_SCREEN"))
EndIf 
If Int(SettingFile.GetSetting("KEYBOARD_END")) <> 0 Then
	KEYBOARD_END = Int(SettingFile.GetSetting("KEYBOARD_END"))
EndIf 

'JoyStickRead
If Int(SettingFile.GetSetting("JOY_BIGCOVER")) <> 0 Then
	JOY_BIGCOVER = Int(SettingFile.GetSetting("JOY_BIGCOVER"))
EndIf 
If Int(SettingFile.GetSetting("JOY_FLIPCOVER")) <> 0 Then
	JOY_FLIPCOVER = Int(SettingFile.GetSetting("JOY_FLIPCOVER"))
EndIf 
If Int(SettingFile.GetSetting("JOY_ENTER")) <> 0 Then
	JOY_ENTER = Int(SettingFile.GetSetting("JOY_ENTER"))
EndIf 
If Int(SettingFile.GetSetting("JOY_MENU")) <> 0 Then
	JOY_MENU = Int(SettingFile.GetSetting("JOY_MENU"))
EndIf 
If Int(SettingFile.GetSetting("JOY_FILTER")) <> 0 Then
	JOY_FILTER = Int(SettingFile.GetSetting("JOY_FILTER"))
EndIf 
If Int(SettingFile.GetSetting("JOY_CANCEL")) <> 0 Then
	JOY_CANCEL = Int(SettingFile.GetSetting("JOY_CANCEL"))
EndIf 
If Int(SettingFile.GetSetting("JOY_INFO")) <> 0 Then
	JOY_INFO = Int(SettingFile.GetSetting("JOY_INFO"))
EndIf 
If Int(SettingFile.GetSetting("JOY_PLATROTATE")) <> 0 Then
	JOY_PLATROTATE = Int(SettingFile.GetSetting("JOY_PLATROTATE"))
EndIf 
If Int(SettingFile.GetSetting("JOY_SCREEN")) <> 0 Then
	JOY_SCREEN = Int(SettingFile.GetSetting("JOY_SCREEN"))
EndIf 
If Int(SettingFile.GetSetting("JOY_END")) <> 0 Then
	JOY_END = Int(SettingFile.GetSetting("JOY_END"))
EndIf

If RePopulate=True Then
	PopulateGames()
EndIf 

If SettingFile.GetSetting("Interface") = "" Then 
	ChangeInterface(1)
Else
	ChangeInterface(Int(SettingFile.GetSetting("Interface")))
EndIf


ExitLoop:ExitType = New ExitType
ExitLoop.Init()

'MARK: Thread Load

Local TexThread:TThread = CreateThread(MainTextureLoadThread , "2")
DetachThread(TexThread)

Local StackThread:TThread = CreateThread(UpdateStackThread , "3")
DetachThread(StackThread)

'UpdateStack()
WaitSemaphore(WaitingThread) 'Wait for thread to be ready
PostSemaphore(StartupThread) 'Signal to start

LockMutex(Mutex_UpdateStackThreadResources)
USTR_CGP = CurrentGamePos
USTR_GAL = GameArrayLen
USTR_GA = GameArray
USTR_UGA = True 
GameArrayUpdated = False 
USTR_CIN = CurrentInterfaceNumber
USTR_GCL = GAMECACHELIMIT
USTR_LM = LowMemory
UnlockMutex(Mutex_UpdateStackThreadResources)

WaitSemaphore(WaitingThread2)
PostSemaphore(StartupThread2)

Local obj:GeneralType
Local OldCurrentGamePos:Int = - 1
Local OldFilter:String = ""
Local StartMouseTimer:Int
Local EndMouseTimer:Int
Local SwipeMode:Int = False
Local BlitzMaxInit:Int = 1
Local UpdateTypeListRev:TList
Local logicrenders:Int 
Local renders:Int
Local fps:Int 
Local logicfps:Int

GameNode.GetGame(GameArray[CurrentGamePos])

LoadFonts()
Local old_ms = MilliSecs()
Local SecondTimer = MilliSecs()


'MARK: MAIN LOOP
Repeat
	'MARK: 3D stuff
	For obj = EachIn UpdateTypeList
		obj.Update()
	Next	
	If RenderLoop = True then
		LockMutex(TTexture.Mutex_tex_list)
		RenderWorld 'CRASH-4
		UnlockMutex(TTexture.Mutex_tex_list)
	EndIf 
	
	'MARK: miniB3D 2D
	logicrenders=logicrenders+1
	If RenderLoop=True Then 
		renders=renders+1
	EndIf 		
			
	If MilliSecs() - old_ms >= 1000
		old_ms=MilliSecs()
		logicfps=logicrenders
		fps=renders
		logicrenders = 0
		renders = 0
		SpeedRatio = Float(60)/logicfps
	EndIf
		?Debug
		'If GameArrayLen > 0 Then
		'	Text 0 , 65 , "Game: " + CurrentGamePos + " Name: " + GameArray[CurrentGamePos]
		'EndIf
		'Text 0 , 50 , "L-FPS: " + logicfps
		'Text 0 , 65 , "FPS: " + fps
		Text 100 , 30 , MouseX()
		Text 100 , 40 , MouseY()	
		Text 100,  50 , GCMemAlloced()
		Text 100,  60 , bb
		'Text 100 , 50 , GWidth * (Float(780) / 800)
		LockMutex(TTexture.Mutex_UsedSpace)
		Text 100 , 70 , Int(TTexture.UsedSpace)/1000000
		UnlockMutex(TTexture.Mutex_UsedSpace)
		?
		
		
	BeginMax2D()
		
	'MARK: Max2D stuff
		If BlitzMaxInit = 1 Then
			SetBlend(ALPHABLEND)
			BlitzMaxInit = 0
		EndIf
		
		UpdateTypeListRev = UpdateTypeList.Reversed()
		For obj = EachIn UpdateTypeListRev 
			obj.Max2D()
		Next		

		
		
	EndMax2D()
	If RenderLoop = True 	
		Flip	
	EndIf 
	FrameLimiter()
	RenderLimiter()
	MemoryLimiter()
	
	If MouseDown(1) Then
		If SwipeMode = True Then	
			If MilliSecs() - StartMouseTimer > 100 Then
				StartMouseTimer = MilliSecs()
				MouseStart[0] = MouseX()
				MouseStart[1] = MouseY()
				MouseSwipe = 2
				IsMouseDown = False				
			EndIf
		Else
			If IsMouseDown = False Then	
				IsMouseDown = True 
				StartMouseTimer = MilliSecs()
				MouseStart[0] = MouseX()
				MouseStart[1] = MouseY()
			Else
				If MilliSecs() - StartMouseTimer > 1000 Then
					SwipeMode = True
					IsMouseDown = True
					PrintF("SwipeMode On")
				EndIf
			EndIf
		EndIf
	Else
		If SwipeMode = True Then
			SwipeMode = False
			MouseSwipe = 0
			IsMouseDown = False
			PrintF("SwipeMode Off")
		Else
			If IsMouseDown = True Then
				EndMouseTimer = MilliSecs()
				IsMouseDown = False
				MouseEnd[0] = MouseX()
				MouseEnd[1] = MouseY()	
				If Abs(MouseEnd[0] - MouseStart[0]	) < (Float(20)/800)*GWidth And Abs(MouseEnd[1] - MouseStart[1]) < (Float(20)/600)*GHeight Then
					MouseClick = 1
				Else
					If Abs(MouseEnd[1] - MouseStart[1]) < (Float(50)/600)*GHeight Then
						MouseSwipe = 1
						MouseSwipeTime = EndMouseTimer - StartMouseTimer
					ElseIf Abs(MouseEnd[0] - MouseStart[0]	) < (Float(50)/800)*GWidth
						MouseSwipe = 4
						MouseSwipeTime = EndMouseTimer - StartMouseTimer
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If MouseHit(2) Then
		MouseClick = 2
	EndIf
	
	ExitLoop.UpdateKeyboard()
	ExitLoop.UpdateJoy()	
	For obj = EachIn UpdateTypeList
		If obj.UpdateKeyboard()=True Then Exit
	Next
	For obj = EachIn UpdateTypeList	
		If obj.UpdateMouse()= True Then Exit 
	Next		
	For obj = EachIn UpdateTypeList	
		If obj.UpdateJoy()= True Then Exit 
	Next		
	
	MouseClick = 0
	If MouseSwipe < 3 Then MouseSwipe = 0
	
	If GameArrayLen > 0 Then
		Repeat
			Local RepeatPosLoop = False
			If CurrentGamePos > GameArrayLen - 1 Then
				CurrentGamePos = CurrentGamePos - GameArrayLen
				RepeatPosLoop = True 
			EndIf
			If CurrentGamePos < 0 Then
				CurrentGamePos = CurrentGamePos + GameArrayLen
				RepeatPosLoop = True 
			EndIf
			If RepeatPosLoop = False Then Exit
		Forever
	EndIf

	If OldFilter <> Filter Then
		OldFilter = Filter
		CurrentInterface.Clear()
		PopulateGames()
		CurrentInterface.Init()
		OldCurrentGamePos = -1
	EndIf 

	If OldCurrentGamePos <> CurrentGamePos Or ForceTextureReset = True Then
		
		LockMutex(Mutex_ResetTextureThread)
		ResetTextureThread = 1	
		UnlockMutex(Mutex_ResetTextureThread)	
		OldCurrentGamePos = CurrentGamePos
		
		'Update Stack Thread stuff
		LockMutex(Mutex_UpdateStackThreadResources)
		USTR_CGP = CurrentGamePos
		If GameArrayUpdated = True Then
			USTR_GA = GameArray
			USTR_UGA = True 
			GameArrayUpdated = False 
		EndIf 
		UnlockMutex(Mutex_UpdateStackThreadResources)
		
		If HaltStack <> True Then
			PostSemaphore(StartupThread2)	
		EndIf 
		
		
		If GameArrayLen > 0 Then
			GameNode.GetGame(GameArray[CurrentGamePos])
		Else
			GameNode.Name = ""
		EndIf
		PostSemaphore(StartupThread)
		ForceTextureReset = False 
	EndIf
	
	If MilliSecs() - SecondTimer > 1000 then
		If TryLockMutex(Mutex_ThreadStatus) Then 
			If ThreadStatus = 0 Then
				If TryLockMutex(Mutex_ProcessStack) Then
					If ProcessStack.Count() > 0 Then
						PrintF("Forced Startup")
						PostSemaphore(StartupThread)
					EndIf 
					UnlockMutex(Mutex_ProcessStack)
				EndIf
			EndIf
		UnlockMutex(Mutex_ThreadStatus)
		EndIf
		SecondTimer = MilliSecs()
	EndIf
	

	If ExitProgramCall = True Then Exit
Forever

LockMutex(Mutex_CloseTextureThread)
CloseTextureThread = 1
UnlockMutex(Mutex_CloseTextureThread)
LockMutex(Mutex_ResetTextureThread)
ResetTextureThread = 1	
UnlockMutex(Mutex_ResetTextureThread)
EndProgram()

Function EndProgram()
	SettingFile.SaveSetting("CurrentGamePos" , CurrentGamePos)
	SettingFile.SaveSetting("Filter" , Filter)
	SettingFile.SaveSetting("Interface" , CurrentInterfaceNumber)	
	
	SettingFile.SaveSetting("FilterType" , FilterType)	
	SettingFile.SaveSetting("FilterName" , FilterName)	
	SettingFile.SaveSetting("GamesSortFilter" , GamesSortFilter)	

	SettingFile.SaveSetting("GamesPlatformFilter" , GamesPlatformFilter)		
	SettingFile.SaveSetting("GamesGenreFilter" , GamesGenreFilter)		
	SettingFile.SaveSetting("GamesRelFilter" , GamesRelFilter)		
	SettingFile.SaveSetting("GamesCompFilter" , GamesCompFilter)		
	SettingFile.SaveSetting("GamesRateFilter" , GamesRateFilter)		
	SettingFile.SaveSetting("GamesPlayerFilter" , GamesPlayerFilter)		
	SettingFile.SaveSetting("GamesCoopFilter" , GamesCoopFilter)		
	SettingFile.SaveSetting("GamesDeveloperFilter" , GamesDeveloperFilter)		
	SettingFile.SaveSetting("GamesPublisherFilter" , GamesPublisherFilter)		
	SettingFile.SaveSetting("GamesCertificateFilter" , GamesCertificateFilter)		

	
	SettingFile.SaveFile()		
	Local Tex:TTexture
	Repeat
		Tex = TTexture(TTexture.tex_list.RemoveFirst())
		If Tex = Null Then Exit
		FreeTexture(Tex)
	Forever
	SettingFile.CloseFile()
	End
End Function

Include "Includes\FrontEnd\MainMenu.bmx"
Include "Includes\FrontEnd\ThreadedGraphics.bmx"
Include "Includes\FrontEnd\InterfaceObjects.bmx"
Include "Includes\FrontEnd\InfoScreen.bmx"
Include "Includes\FrontEnd\Menu.bmx"
Include "Includes\FrontEnd\Completed-Rating.bmx"
Include "Includes\FrontEnd\Interfaces.bmx"

Function ResetInterface()
	CurrentInterface.Clear()
	CurrentInterface = GeneralType(New CoverFlowInterface)
	CurrentInterface.Init()
End Function

Function ResetFilters()
	Filter = ""
	GamesPlatformFilter = 0
	GamesGenreFilter = ""	
	GamesRelFilter = ""
	GamesCompFilter = ""
	GamesRateFilter = ""
	GamesPlayerFilter = ""
	GamesCoopFilter = ""
	GamesDeveloperFilter  = ""
	GamesPublisherFilter = ""
	GamesCertificateFilter = ""
	GamesSortFilter = "" 		
End Function

Function ChangeInterface(Number:Int,Clear:Int = True, ClearAllTextures:Int = True )
	FlushKeys()
	FlushMouse()
	FlushJoy()
	Local Tex:TTexture
	Local File:String 
	
	If Clear = True Then 
		CurrentInterface.Clear()
	EndIf	
	
	If ClearAllTextures = True Then 
		'Clear out all textures 
		LockMutex(TTexture.Mutex_tex_list)
		For Tex = EachIn TTexture.tex_list
			File = Tex.file
			If Left(File , Len(GAMEDATAFOLDER) ) = GAMEDATAFOLDER Then			
				ListRemove(TTexture.tex_list , Tex)
				ListRemove(ProcessedTextures , File)
				PrintF("Freed: "+File)
				FreeTexture(Tex)
				Tex = Null		
			EndIf 
		Next 
		UnlockMutex(TTexture.Mutex_tex_list)
		LockMutex(TTexture.Mutex_UsedSpace)
		TTexture.UsedSpace = 0
		UnlockMutex(TTexture.Mutex_UsedSpace)		
	EndIf 
	Select Number
		Case 7
			CurrentInterface = GeneralType(New ScreenShotInterface)
			HaltStack = True 
		Case 6
			CurrentInterface = GeneralType(New CoverWallInterface)
			CurrentInterfaceNumber = 6
			HaltStack = False 
		Case 5
			CurrentInterface = GeneralType(New BannerFlowInterface)
			CurrentInterfaceNumber = 5
			HaltStack = False 
		Case 4
			CurrentInterface = GeneralType(New ListViewInterface)
			CurrentInterfaceNumber = 4
			HaltStack = False 
		Case 3
			CurrentInterface = GeneralType(New InfoViewBannerInterface)
			CurrentInterfaceNumber = 3
			HaltStack = False 
		Case 2
			CurrentInterface = GeneralType(New InfoViewInterface)
			CurrentInterfaceNumber = 2
			HaltStack = False 
		Case 1
			CurrentInterface = GeneralType(New CoverFlowInterface)
			CurrentInterfaceNumber = 1
			HaltStack = False 
		Case 0
			CurrentInterface = GeneralType(New MainMenuType)
			HaltStack = True 
		Default
			RuntimeError "Error invalid interface number"
	End Select 
	
	LockMutex(Mutex_UpdateStackThreadResources)
	USTR_CIN = CurrentInterfaceNumber
	UnlockMutex(Mutex_UpdateStackThreadResources)
	
	CurrentInterface.Init()
	ForceTextureReset = True 
End Function

Function PopulateUsedPlatformList()
	UsedPlatformList = CreateList()
	Local GameNode:GameReadType = New GameReadType
	For a = 0 To GameArrayLen - 1
		GameNode.GetGame(GameArray[a])
		If ListContains(UsedPlatformList , String(GameNode.PlatformNum) ) <> 1 And GameNode.PlatformNum <> 0 then
			ListAddLast(UsedPlatformList , String(GameNode.PlatformNum) )
		EndIf
	Next
End Function 

Function PopulateGames()
	Local temp:String
	Local tempGameList:TList = CreateList()
	Local a:Int = 0
	Local AddGame:Int = False
	Local GameNode:GameReadType = New GameReadType
	Local EvaluationGameNum = 0
	Local ReadGameFolder:Int 
	If Left(Filter,1) = " " Then Filter = ""
	ReadGameFolder = ReadDir(GAMEDATAFOLDER)
	Repeat

		AddGame = True 
		temp = NextFile(ReadGameFolder)
		If temp="" Then Exit
		If temp="." Or temp=".." Then Continue
		If FileType(GAMEDATAFOLDER + temp) = 2 Then
			GameNode.GetGame(temp)
			If Filter <> "" Then
				If Len(Filter) > 1 Then
					If Instr(Lower(GameNode.Name) , Lower(Filter) ) = 0 Then
						'ListAddLast(tempGameList , temp)
						AddGame = False 
					EndIf
				Else
					If Lower(Left(GameNode.Name , 1) ) <> Lower(Filter) Then
						'ListAddLast(tempGameList , temp)
						AddGame = False
					EndIf
				EndIf
			'Else
			'	ListAddLast(tempGameList , temp)
			EndIf
			
			If GamesPlatformFilter <> 0 And GameNode.PlatformNum <> GamesPlatformFilter
				AddGame = False
			EndIf 
			
			If GamesGenreFilter <> "" And ListContains(GameNode.Genres , GamesGenreFilter) <> 1 then
				AddGame = False
			EndIf
			
			If GamesRelFilter <> "" And Left(GameNode.ReleaseDate , 4) <> GamesRelFilter Then
				AddGame = False
			EndIf
			
			If GamesCompFilter <> "" Then
				If GamesCompFilter = "Completed" And GameNode.Completed = 0 Then
					AddGame = False 
				EndIf
				If GamesCompFilter = "Not Completed" And GameNode.Completed = 1 Then
					AddGame = False 
				EndIf				
			EndIf
			
			If GamesRateFilter <> "" And GamesRateFilter <> GameNode.Rating Then
				AddGame = False 
			EndIf		
	
			If GamesPlayerFilter <> "" And GamesPlayerFilter <> GameNode.Players Then
				AddGame = False 
			EndIf							

			If GamesCoopFilter <> "" And GamesCoopFilter <> GameNode.Coop Then
				AddGame = False 
			EndIf					

			If GamesDeveloperFilter <> "" And GamesDeveloperFilter <> GameNode.Dev Then
				AddGame = False 
			EndIf					
			
			If GamesPublisherFilter <> "" And GamesPublisherFilter <> GameNode.Pub Then
				AddGame = False 
			EndIf					

			If GamesCertificateFilter <> "" And GamesCertificateFilter <> GameNode.Cert Then
				AddGame = False 
			EndIf					

			If AddGame = True Then
				
				ListAddLast(tempGameList , temp)
				EvaluationGameNum = EvaluationGameNum + 1
				If EvaluationGameNum > 4 And EvaluationMode = True Then 
					Exit
				EndIf 
			EndIf 
		EndIf
	Forever
	CloseDir(ReadGameFolder)
	
	tempGameList = ApplySort(tempGameList)
	
	
	GameArray = GameArray[..tempGameList.count()]
	GameArrayUpdated = True 
	For temp = EachIn tempGameList
		GameArray[a] = temp
		a = a + 1
	Next
	GameArrayLen = Len(GameArray)
	
	If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1
	If CurrentGamePos = -1 Then CurrentGamePos=0
End Function

Function ApplySort:TList(GamesTList:TList)
	PrintF("PopulateTList Running")
	Local GamesTSList:TList = CreateList()
	'Local GameDir:Int
	Local item:String
	Local itemPlat:String
	Local itemDate:String
	Local itemDev:String
	Local itemPub:String
	Local itemGen:String
	Local itemScore:String
	'Local SearchTerm:String
	Local itemCompleted:String
	Local PlatformName:String
	
	If GamesSortFilter <> "" Then 
		For item$ = EachIn GamesTList
			GameNode:GameReadType = New GameReadType
			If GameNode.GetGame(item) = - 1 Then
				
			Else
				Select GamesSortFilter
					Case "Platform"
						PlatformName = GlobalPlatforms.GetPlatformByID(GameNode.PlatformNum).Name
						If PlatformName = "" then
							ListAddLast(GamesTSList, "zzzz>" + item)
						Else
							ListAddLast(GamesTSList, PlatformName + ">" + item)
						EndIf	

					Case "Players"
						If GameNode.Players = "" Then
							ListAddLast(GamesTSList,"zzzz>"+item)
						Else
							ListAddLast(GamesTSList,GameNode.Players+">"+item)
						EndIf	
											
					Case "Co-Op"
						If GameNode.Coop="" Then
							ListAddLast(GamesTSList,"zzzz>"+item)
						Else
							ListAddLast(GamesTSList,GameNode.Coop+">"+item)
						EndIf	
											
					Case "Certificate"
						If GameNode.Cert="" Then
							ListAddLast(GamesTSList,"zzzz>"+item)
						Else
							ListAddLast(GamesTSList,GameNode.Cert+">"+item)
						EndIf	
											
					Case "Genre"
						Local GenreList:String = "",SingleGenre:String = ""
						For SingleGenre = EachIn GameNode.Genres
							GenreList = GenreList + SingleGenre + "/"
						Next		
						GenreList = Left(GenreList , Len(GenreList)-1)
						If GenreList="" Then
							ListAddLast(GamesTSList,"zzzz>"+item)
						Else
							ListAddLast(GamesTSList,GenreList+">"+item)
						EndIf							
					Case "Developer"
						If GameNode.Dev="" Then
							ListAddLast(GamesTSList,"zzzz>"+item)
						Else
							ListAddLast(GamesTSList,GameNode.Dev+">"+item)
						EndIf	
					Case "Publisher"						
						If GameNode.Pub="" Then
							ListAddLast(GamesTSList,"zzzz>"+item)
						Else
							ListAddLast(GamesTSList,GameNode.Pub+">"+item)
						EndIf	
					Case "Rating"							
						If GameNode.Rating="" Or GameNode.Rating="0" Then
							ListAddLast(GamesTSList,"z9>"+item)
						Else
							If itemScore=10 Then
								ListAddLast(GamesTSList,"a0>"+item)
							Else
								ListAddLast(GamesTSList,"a"+(10-Int(GameNode.Rating))+">"+item)
							EndIf
						EndIf		
					Case "Completed"
						If GameNode.Completed="" Then
							ListAddLast(GamesTSList,"0>"+item)
						Else
							ListAddLast(GamesTSList,GameNode.Completed+">"+item)
						EndIf																					
					Case "Release Date"
						If GetDateFromCorrectFormat(GameNode.ReleaseDate)="" Then
							ListAddLast(GamesTSList,"9999/99/99>"+item)
						Else
							ListAddLast(GamesTSList,GameNode.ReleaseDate+">"+item)
						EndIf
					Default
						PrintF("unrecognised filter: "+GamesSortFilter)
				End Select
			EndIf
		Next	
		SortList(GamesTSList , True)
		PrintF("Adding Games back into GamesTList")
		GamesTList = CreateList()
		For item$=EachIn GamesTSList
			For a=1 To Len(item)
				If Mid(item,a,1)=">" Then
					ListAddLast(GamesTList,Right(item,Len(item)-a))
					Exit
				EndIf
			Next
		Next	
		PrintF("Sort Applied")
	Else		
		SortList(GamesTList , True)
	EndIf 
	Return GamesTList
End Function	

Function GetBoundingBox:Float[](ent:TMesh)
	Local ReturnValue:Float[4]
	ReturnValue[0] = -1
	ReturnValue[1] = -1
	ReturnValue[2] = -1
	ReturnValue[3] = -1
	If ent = Null Return ReturnValue
	If EntityInView(ent,CAMERA)=0 Return ReturnValue
	leftmost#=10000
	rightmost#=-10000
	topmost#=10000
	bottommost#=-10000
	For i=1 To CountSurfaces(ent)
		s=GetSurface(ent,1)
		For v=0 To CountVertices(s)-1
			TFormPoint VertexX(s,v),VertexY(s,v),VertexZ(s,v),ent,0
			CameraProject CAMERA,TFormedX(),TFormedY(),TFormedZ()
			If ProjectedX()<leftmost leftmost=ProjectedX()
			If ProjectedX()>rightmost rightmost=ProjectedX()
			If ProjectedY()<topmost topmost=ProjectedY()
			If ProjectedY()>bottommost bottommost=ProjectedY()
		Next
	Next
	ReturnValue[0] = leftmost
	ReturnValue[1] = topmost
	ReturnValue[2] = rightmost
	ReturnValue[3] = bottommost
	Return ReturnValue
End Function

Function LoadFonts()
	NameFont = LoadImageFont(RESFOLDER + "ariblk.ttf" , (Float(30) / 768) * GHeight)
	MenuButtonFont = LoadImageFont(RESFOLDER + "arial.ttf" , (Float(20) / 768) * GHeight)
	MainTextFont = LoadImageFont(RESFOLDER + "arial.ttf" , (Float(18) / 768) * GHeight)
	SmallMenuButtonFont = LoadImageFont(RESFOLDER + "arial.ttf" , (Float(17)/768)*GHeight)

	MenuFont = LoadImageFont(RESFOLDER + "ariblk.ttf" , (Float(20) / 768) * GHeight)
	FilterFont = LoadImageFont(RESFOLDER + "arial.ttf" , (Float(22) / 768) * GHeight)
	BigMenuFont = LoadImageFont(RESFOLDER + "ariblk.ttf" , (Float(25) / 768) * GHeight) 
	If FilterFont = Null Or MainTextFont = Null Or NameFont = Null Or MenuButtonFont = Null Or MenuFont = Null Or BigMenuFont = Null  Then
		RuntimeError "Font Load Error"
	EndIf
End Function

Function LoadGlobalSettings()
	ReadSettings:SettingsType = New SettingsType
	ReadSettings.ParseFile(SETTINGSFOLDER + "GeneralSettings.xml" , "GeneralSettings")
	If ReadSettings.GetSetting("Country")<>"" Then 
		Country = ReadSettings.GetSetting("Country")
	EndIf
	If ReadSettings.GetSetting("PGMOff") <> "" then
		PerminantPGMOff = Int(ReadSettings.GetSetting("PGMOff") )
	EndIf	
	If ReadSettings.GetSetting("GraphicsWidth") <> "" Then	
		GWidth = Int(ReadSettings.GetSetting("GraphicsWidth"))
	EndIf
	If ReadSettings.GetSetting("GraphicsHeight") <> "" Then	
		GHeight = Int(ReadSettings.GetSetting("GraphicsHeight"))
	EndIf 		
	If ReadSettings.GetSetting("GraphicsMode") <> "" Then	
		GMode = Int(ReadSettings.GetSetting("GraphicsMode"))
	EndIf	
	If ReadSettings.GetSetting("GameCache") <> "" Then	
		GAMECACHELIMIT = Int(ReadSettings.GetSetting("GameCache"))
	EndIf 	
	If ReadSettings.GetSetting("LowMem") <> "" Then		
		LowMemory = Int(ReadSettings.GetSetting("LowMem"))
	EndIf 	
	If ReadSettings.GetSetting("LowProc") <> "" Then		
		LowProcessor = Int(ReadSettings.GetSetting("LowProc"))
	EndIf	
	If ReadSettings.GetSetting("TouchKey") <> "" Then		
		TouchKeyboardEnabled = Int(ReadSettings.GetSetting("TouchKey"))
	EndIf	
	
	If ReadSettings.GetSetting("ShowInfoButton") <> "" Then		
		ShowInfoButton = Int(ReadSettings.GetSetting("ShowInfoButton"))
	EndIf		
	If ReadSettings.GetSetting("ShowScreenButton") <> "" Then		
		ShowScreenButton = Int(ReadSettings.GetSetting("ShowScreenButton"))
	EndIf		
		
	If ReadSettings.GetSetting("AntiAlias") <> "" Then		
		AntiAliasSetting = Int(ReadSettings.GetSetting("AntiAlias"))
	EndIf	
	If ReadSettings.GetSetting("DebugLogEnabled") <> "" then		
		If Int(ReadSettings.GetSetting("DebugLogEnabled") ) = 1 then
			DebugLogEnabled = 1
		EndIf
	EndIf			
	ReadSettings.CloseFile()
End Function

Function WindowsCheck()
	?Win32
	WinDir = GetEnv("WINDIR")
	PrintF("Windows Folder: " + WinDir)
	?
End Function
