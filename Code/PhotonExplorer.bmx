'TODO: Fix LuaInternet to check for meta refreshes
'TODO: Fix Explorer/Frontends ability to handle files, webpages etc as Other Executables
'TODO: Speedup startup with 1000+ games


'FIX: Steam ScreenShots!

Framework wx.wxApp
Import wx.wxFrame
Import wx.wxMenu
'Import wx.wxAboutBox
Import wx.wxButton
Import wx.wxPanel
Import wx.wxStaticText
Import wx.wxPlatformInfo
Import wx.wxListCtrl
Import wx.wxMessageDialog
?MacOS
Import wx.wxChoicebook
?
Import wx.wxNotebook
Import wx.wxSplitterWindow
Import wx.wxComboBox
Import wx.wxTextCtrl
Import wx.wxBitmap
Import wx.wxStaticLine
Import wx.wxHyperlinkCtrl

Import wx.wxWebView

'Media Control Requires Ubunutu Restricted Access To Compile, libgstreamer-plugins-base0.10-dev, libgstreamer0.10-dev
?Win32
Import wx.wxMediaCtrl
?
Import wx.wxTimer
Import wx.wxListBox
'Import wx.wxGenericDirCtrl
Import wx.wxTaskBarIcon
Import wx.wxgauge

Import Bah.libxml
Import Bah.libcurlssl
Import Bah.Volumes
Import Bah.Regex

'Important for these to be in THIS ORDER
Import BRL.JPGLoader
Import bah.FreeImage

Import BRL.LinkedList
Import BRL.FileSystem
Import BRL.StandardIO
Import BRL.Retro
Import BRL.PolledInput
Import BRL.OpenALAudio
Import BRL.DirectSoundAudio
Import BRL.FreeAudioAudio
Import BRL.WAVLoader
Import BRL.Blitz

Import PUB.Win32
Import PUB.FreeProcess
Import BRL.Bank
Import BRL.System
Import brl.threads

?Win32
Import "..\Icons\PhotonExplorer.o"
?

Import LuGI.Core
Include "ExplorerGlue.bmx"

''Must Generate Glue Code in UnThreaded Mode
'Import LuGI.Generator
'GenerateGlueCode("ExplorerGlue.bmx")
'End

?Not Win32
Global FolderSlash:String = "/"

?Win32
Global FolderSlash:String ="\"
?

AppTitle = "PhotonExplorer"

Include "Includes\General\StartupOverrideCheck.bmx"
Local TempFolderPath:String = OverrideCheck(FolderSlash)

Include "Includes\General\GlobalConsts.bmx"
Include "Includes\GameExplorerShell\GlobalConsts.bmx"

AppTitle = "Photon"
' Revision Version Generation Code
' @bmk include Includes/General/Increment.bmk
' @bmk doOverallVersionFiles Version/OverallVersion.txt
?Win32
' @bmk doIncrement Version/PE-Version.txt 1
?Mac
' @bmk doIncrement Version/PE-Version.txt 2
?Linux
' @bmk doIncrement Version/PE-Version.txt 3
?
Incbin "Version/PE-Version.txt"
Incbin "Version/OverallVersion.txt"

SubVersion = ExtractSubVersion(LoadText("incbin::Version/PE-Version.txt"), 1)
OSubVersion = ExtractSubVersion(LoadText("incbin::Version/OverallVersion.txt"), 1)

Print "Version = " + CurrentVersion
Print "SubVersion = " + SubVersion
Print "OSubVersion = " + OSubVersion

Local ArguemntNo:int = 0
Local RunnerEXENumber:int
Local RunnerGameName:String
Local ProgramMode:Int = 1

'Mode = 1 NORMAL MODE
'Mode = 2 RUNNER MODE ONLY
'Mode = 3 TRAY APP


Local PastArgument:String
For Argument$ = EachIn AppArgs$
	Select PastArgument
		Case "-Cabinate","Cabinate"
			CmdLineCabinate = Int(Argument)
			PastArgument = ""
		Case "-GameTab","GameTab"
			CmdLineGameTab = Argument
			PastArgument = ""
		Case "-Game","Game"
			CmdLineGameName = Argument
			PastArgument = ""
		Case "-GameName", "GameName"
			RunnerGameName = Argument
			PastArgument = ""
		Case "-EXENum","EXENum"
			RunnerEXENumber = Int(Argument)
			PastArgument = ""
		Case "-Debug","Debug"
			If Int(Argument) = 1 Then
				DebugLogEnabled = True
			EndIf
			PastArgument = ""
		Default
			Select Argument
				Case "-Debug" , "-GameName" , "-EXENum" , "-Game" , "-GameTab", "-Cabinate", "Debug" , "GameName" , "EXENum" , "Game" , "GameTab", "Cabinate"
					PastArgument = Argument
			End Select
	End Select
Next



Global GameExplorerApp:GameExplorerShell

GameExplorerApp = New GameExplorerShell
GameExplorerApp.Run()


Print "Close"
End

Type GameExplorerShell Extends wxApp
	Field Menu:GameExplorerFrame
	Field Splash:SplashFrame

	Method OnInit:Int()
		wxImage.AddHandler( New wxICOHandler)
		'wxImage.AddHandler( New wxPNGHandler)
		'wxImage.AddHandler( New wxJPEGHandler)
		'wxImage.AddHandler( New wxJPEGHandler)

		Splash = SplashFrame(New SplashFrame.Create(Null, wxID_ANY, "Photon Loading...", - 1, - 1, 600, 225, 0) )
		Local Timer:wxTimer = New wxTimer.Create(Self, wxID_ANY)
		Timer.Start(100, 1)
		ConnectAny(wxEVT_TIMER, Startup)


		Return True

	End Method

	Function Startup(event:wxEvent)
		Local GES:GameExplorerShell = GameExplorerShell(event.parent)

		?Threaded
		Local StartupThread:TThread = CreateThread(Thread_Startup, GES.Splash)
		While ThreadRunning(StartupThread)
			GES.Yield()
			Delay 100
		Wend
		?Not Threaded
		Thread_Download(GES.Splash)
		?

		If DebugLogEnabled = False then
			DeleteFile(LOGFOLDER + LogName)
		EndIf


		GES.StartupMain()
	End Function


	Method StartupMain()

		Local w:Int = Int(SettingFile.GetSetting("WindowWidth") )
		Local h:Int = Int(SettingFile.GetSetting("WindowHeight") )
		Local Winx:Int
		Local Winy:Int
		If SettingFile.GetSetting("WindowX") = "" Or SettingFile.GetSetting("WindowY") = "" then
			Winx = - 1
			Winy = - 1
		Else
			Winx = Int(SettingFile.GetSetting("WindowX") )
			Winy = Int(SettingFile.GetSetting("WindowY") )
		EndIf
		If w = 0 Or h = 0 then
			Menu = GameExplorerFrame(New GameExplorerFrame.Create(Null , GES, "PhotonExplorer", Winx, Winy, 800, 600) )
		Else
			Menu = GameExplorerFrame(New GameExplorerFrame.Create(Null , GES, "PhotonExplorer", Winx, Winy, w, h) )
		EndIf
		Splash.Destroy()
	End Method
End Type

Function Thread_Startup:Object(obj:Object)
	Local Splash:SplashFrame = SplashFrame(obj)

	Splash.SetStatusText("Checking for debug")
	DebugCheck()

	Splash.SetStatusText("Checking folder integrity")
	FolderCheck()

	Splash.SetStatusText("Cleaning up temporary folder")
	TempFolderCleanup()

	LogName = "Log-Explorer" + CurrentDate() + " " + Replace(CurrentTime(), ":", "-") + ".txt"
	CreateFile(LOGFOLDER + LogName)



	Splash.SetStatusText("Loading settings")
	SettingFile.ParseFile(SETTINGSFOLDER + "PhotonExplorer.xml")
	LoadGlobalSettings()
	LoadSettings()

	CheckKey()



	WindowsCheck()

	Splash.SetStatusText("Loading platforms")
	SetupPlatforms()
	OldPlatformListChecks()

	Splash.SetStatusText("Checking internet connection")
	CheckInternet()
	CheckVersion()

	Splash.SetStatusText("Setting up LuaMachine")
	StartupLuaVM()

	Splash.SetStatusText("Loading main window...")


End Function


Function LoadSettings()

	If SettingFile.GetSetting("Red1") <> "" then
		PERed = Int(SettingFile.GetSetting("Red1") )
	EndIf
	If SettingFile.GetSetting("Green1") <> "" then
		PEGreen = Int(SettingFile.GetSetting("Green1") )
	EndIf
	If SettingFile.GetSetting("Blue1") <> "" then
		PEBlue = Int(SettingFile.GetSetting("Blue1") )
	EndIf
	If SettingFile.GetSetting("Red2") <> "" then
		PERed2 = Int(SettingFile.GetSetting("Red2") )
	EndIf
	If SettingFile.GetSetting("Green2") <> "" then
		PEGreen2 = Int(SettingFile.GetSetting("Green2") )
	EndIf
	If SettingFile.GetSetting("Blue2") <> "" then
		PEBlue2 = Int(SettingFile.GetSetting("Blue2") )
	EndIf
	If SettingFile.GetSetting("Red3") <> "" then
		PERed3 = Int(SettingFile.GetSetting("Red3") )
	EndIf
	If SettingFile.GetSetting("Green3") <> "" then
		PEGreen3 = Int(SettingFile.GetSetting("Green3") )
	EndIf
	If SettingFile.GetSetting("Blue3") <> "" then
		PEBlue3 = Int(SettingFile.GetSetting("Blue3") )
	EndIf

	Select SettingFile.GetSetting("ListType")
		Case "1"
			GameListStyle = wxLC_ICON | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE | wxBORDER_NONE
			ShowIcons = 1
		Case "2"
			GameListStyle = wxLC_LIST | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE | wxBORDER_NONE
			ShowIcons = 1
		Case "3"
			GameListStyle = wxLC_LIST | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE | wxBORDER_NONE
			ShowIcons = 0
	End Select


	Select SettingFile.GetSetting("ListArt")
		Case "1"
			GameListIconType = 1
		Case "3"
			GameListIconType = 3
		Case "4"
			GameListIconType = 4
		Case "5"
			GameListIconType = 5
	End Select


	Select SettingFile.GetSetting("IconSize")
		Case "16"
			IconSize = 16
		Case "32"
			IconSize = 32
		Case "64"
			IconSize = 64
		Case "128"
			IconSize = 128
		Case "256"
			IconSize = 256
		Case "512"
			IconSize = 512
	End Select

	Select SettingFile.GetSetting("ListText")
		Case "0"
			GameListText = 0
		Case "1"
			GameListText = 1
	End Select

	Select SettingFile.GetSetting("ListGeneric")
		Case "-1"
			GenericArt = - 1
		Case "0"
			GenericArt = 0
	End Select
End Function

Type GameExplorerFrame Extends wxFrame
	Field WinSplit:wxSplitterWindow
	Field SubWinSplit:wxSplitterWindow
	Field vbox:wxBoxSizer

	Field GameList:wxListCtrl
	?MacOS
	Field GameNotebook:wxChoicebook
	?Not MacOS
	Field GameNotebook:wxNotebook
	?
	Field SortCombo:wxComboBox
	Field FilterTextBox:wxTextCtrl
	Field PlatformCombo:wxComboBox

	Field GameRealPathList:TList
	Field GamesTList:TList


	Field FBAPanel:ImagePanel
	Field GameDetailsPanel:wxPanel
	Field GNameText:wxStaticText
	Field GDescText:wxTextCtrl
	Field GGenreText:wxStaticText
	Field GDevText:wxStaticText
	Field GPubText:wxStaticText
	Field GRDateText:wxStaticText
	Field GCertText:wxStaticText
	Field GCoopText:wxStaticText
	Field GPlayersText:wxStaticText
	Field GPlatText:wxStaticText

	Field TrailerWeb:wxWebView

	Field GCompletedCombo:wxComboBox
	Field GRatingCombo:wxComboBox

	Field PatchTList:TList
	Field ManualTList:TList
	Field WalkTList:TList
	Field CheatTList:TList

	Field GS_SC1_Panel:ScreenShotPanel
	Field GS_SC2_Panel:ScreenShotPanel

	Field GDPvbox:wxBoxSizer

	Field LocalPatchList:wxListBox
	Field LocalPatchFileList:wxListBox

	Field LocalManualList:wxListBox

	Field LocalWalkList:wxListBox
	Field LocalWalkFileList:wxListBox

	Field LocalCheatList:wxListBox

	Field SubMenu1:wxMenu
	Field SubMenu2:wxMenu
	Field SubMenu3:wxMenu
	Field SubMenu4:wxMenu
	Field SubMenu5:wxMenu

	Field StartupRefreshTimer:wxTimer
	Field StartupRefreshTimer2:wxTimer
	Field StartupRefreshTimer3:wxTimer

	Field ResizeTimer:wxTimer
	Field MoveTimer:wxTimer

	Field DownloadList:wxListBox
	Field DownloadSearchBox:wxTextCtrl
	Field DownloadSearchButton:wxButton
	Field DownloadSourceBox:wxComboBox
	Field DownloadTypeBox:wxComboBox
	Field DownloadSourceHyperText:wxHyperlinkCtrl
	Field DownloadPlatformBox:wxComboBox
	Field DownloadListDepth:int
	Field DownloadOldSearch:String
	Field DownloadListSelectButton:wxButton

	Field LuaTimer:wxTimer
	Field FilterTimer:wxTimer

	Method OnInit()

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )

		Self.Maximize(Int(SettingFile.GetSetting("WindowMaximized") ) )

		Self.SetBackgroundColour(New wxColour.Create(PERed, PEGreen, PEBlue) )

		LuaTimer = New wxTimer.Create(Self, LT1)
		ResizeTimer = New wxTimer.Create(Self, RT1)
		MoveTimer = New wxTimer.Create(Self, MT1)
		FilterTimer = New wxTimer.Create(Self, FT1)

		SubMenu1 = New wxMenu.Create()
		SubMenu1.AppendRadioItem(GL_SM1_IV , "Icon View")
		SubMenu1.AppendRadioItem(GL_SM1_LI , "List(Icons)")
		SubMenu1.AppendRadioItem(GL_SM1_LNI , "List(No Icons)")


		Connect(GL_SM1_IV , wxEVT_COMMAND_MENU_SELECTED , ChangeListTypeFun , "1")
		Connect(GL_SM1_LI , wxEVT_COMMAND_MENU_SELECTED , ChangeListTypeFun , "2")
		Connect(GL_SM1_LNI , wxEVT_COMMAND_MENU_SELECTED , ChangeListTypeFun , "3")

		SubMenu2 = New wxMenu.Create()
		SubMenu2.AppendRadioItem(GL_SM2_FA , "Front Art")
		SubMenu2.AppendRadioItem(GL_SM2_FAN , "Fan Art")
		SubMenu2.AppendRadioItem(GL_SM2_BA , "Banner Art")
		SubMenu2.AppendRadioItem(GL_SM2_IA , "Icon Art")


		Connect(GL_SM2_FA , wxEVT_COMMAND_MENU_SELECTED , ChangeListArtFun , "1")
		Connect(GL_SM2_FAN , wxEVT_COMMAND_MENU_SELECTED , ChangeListArtFun , "3")
		Connect(GL_SM2_BA , wxEVT_COMMAND_MENU_SELECTED , ChangeListArtFun , "4")
		Connect(GL_SM2_IA , wxEVT_COMMAND_MENU_SELECTED , ChangeListArtFun , "5")


		SubMenu3 = New wxMenu.Create()
		SubMenu3.AppendRadioItem(GL_SM3_16 , "16x16")
		SubMenu3.AppendRadioItem(GL_SM3_32 , "32x32")
		SubMenu3.AppendRadioItem(GL_SM3_64 , "64x64")
		SubMenu3.AppendRadioItem(GL_SM3_128 , "128x128")
		SubMenu3.AppendRadioItem(GL_SM3_256 , "256x256")
		SubMenu3.AppendRadioItem(GL_SM3_512 , "512x512")
		SubMenu3.Check(GL_SM3_32 , 1)

		Connect(GL_SM3_16 , wxEVT_COMMAND_MENU_SELECTED , ChangeIconSizeFun , "16")
		Connect(GL_SM3_32 , wxEVT_COMMAND_MENU_SELECTED , ChangeIconSizeFun , "32")
		Connect(GL_SM3_64 , wxEVT_COMMAND_MENU_SELECTED , ChangeIconSizeFun , "64")
		Connect(GL_SM3_128 , wxEVT_COMMAND_MENU_SELECTED , ChangeIconSizeFun , "128")
		Connect(GL_SM3_256 , wxEVT_COMMAND_MENU_SELECTED , ChangeIconSizeFun , "256")
		Connect(GL_SM3_512 , wxEVT_COMMAND_MENU_SELECTED , ChangeIconSizeFun , "512")

		SubMenu4 = New wxMenu.Create()
		SubMenu4.AppendRadioItem(GL_SM4_Y , "Yes")
		SubMenu4.AppendRadioItem(GL_SM4_N , "No")
		SubMenu4.Check(GL_SM4_Y , 1)

		Connect(GL_SM4_N , wxEVT_COMMAND_MENU_SELECTED , ChangeListTextFun , "0")
		Connect(GL_SM4_Y , wxEVT_COMMAND_MENU_SELECTED , ChangeListTextFun , "1")


		SubMenu5 = New wxMenu.Create()
		SubMenu5.AppendRadioItem(GL_SM5_Y , "Yes")
		SubMenu5.AppendRadioItem(GL_SM5_N , "No")
		SubMenu5.Check(GL_SM5_Y , 1)

		Connect(GL_SM5_N , wxEVT_COMMAND_MENU_SELECTED , ChangeListGenericFun , "-1")
		Connect(GL_SM5_Y , wxEVT_COMMAND_MENU_SELECTED , ChangeListGenericFun , "0")

		Select SettingFile.GetSetting("ListType")
			Case "1"
				SubMenu1.Check(GL_SM1_IV , 1)
			Case "2"
				SubMenu1.Check(GL_SM1_LI , 1)
			Case "3"
				SubMenu1.Check(GL_SM1_LNI , 1)
			Default
				SubMenu1.Check(GL_SM1_IV , 1)
		End Select

		Select SettingFile.GetSetting("ListArt")
			Case "1"
				SubMenu2.Check(GL_SM2_FA , 1)
			Case "3"
				SubMenu2.Check(GL_SM2_FAN , 1)
			Case "4"
				SubMenu2.Check(GL_SM2_BA , 1)
			Case "5"
				SubMenu2.Check(GL_SM2_IA , 1)
			Default
				SubMenu2.Check(GL_SM2_IA , 1)
		End Select


		Select SettingFile.GetSetting("IconSize")
			Case "16"
				SubMenu3.Check(GL_SM3_16 , 1)
			Case "32"
				SubMenu3.Check(GL_SM3_32 , 1)
			Case "64"
				SubMenu3.Check(GL_SM3_64 , 1)
			Case "128"
				SubMenu3.Check(GL_SM3_128 , 1)
			Case "256"
				SubMenu3.Check(GL_SM3_256 , 1)
			Case "512"
				SubMenu3.Check(GL_SM3_512 , 1)
			Default
				SubMenu3.Check(GL_SM3_32 , 1)
		End Select

		Select SettingFile.GetSetting("ListText")
			Case "0"
				SubMenu4.Check(GL_SM4_N , 1)
			Case "1"
				SubMenu4.Check(GL_SM4_Y , 1)
			Default
				SubMenu4.Check(GL_SM4_Y , 1)
		End Select

		Select SettingFile.GetSetting("ListGeneric")
			Case "-1"
				SubMenu5.Check(GL_SM5_N , 1)
			Case "0"
				SubMenu5.Check(GL_SM5_Y , 1)
			Default
				SubMenu5.Check(GL_SM5_Y , 1)
		End Select

		Local FileMenu:wxMenu = New wxMenu.Create()
		?Win32
		FileMenu.Append(GL_FM_Key , "Keyboard")
		Connect(GL_FM_Key , wxEVT_COMMAND_MENU_SELECTED , LoadKeyboardFun)
		?

		FileMenu.Append(GL_FM_Exit , "Exit")
		Connect(GL_FM_Exit , wxEVT_COMMAND_MENU_SELECTED , ExitFun)


		ConnectAny(wxEVT_CLOSE , ExitFun)

		Local MainMenu:wxMenu = New wxMenu.Create()
		MainMenu.AppendSubMenu(SubMenu1 , "List Type" )
		MainMenu.AppendSubMenu(SubMenu2 , "Icon Type" )
		MainMenu.AppendSubMenu(SubMenu3 , "Icon Size" )
		MainMenu.AppendSubMenu(SubMenu4 , "Show Text" )
		MainMenu.AppendSubMenu(SubMenu5 , "Show Generic Art" )

		Local MenuBar:wxMenuBar = New wxMenuBar.Create()
		MenuBar.Append(FileMenu , "File")
		MenuBar.Append(MainMenu , "List Options")


		Self.SetMenuBar(MenuBar)


		vbox = New wxBoxSizer.Create(wxVERTICAL)

		'---------------------------------TOP FILTERS PANEL---------------------------------
		Local FilPlatPanel:wxPanel = New wxPanel.Create(Self , - 1)

		Local FilPlatHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)


		Local SortText:wxStaticText = New wxStaticText.Create(FilPlatPanel , wxID_ANY , "Sort:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		SortCombo = New wxComboBox.Create(FilPlatPanel , GES_SL , "Alphabetical - Ascending" , SORTS , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )
		Local FilterText:wxStaticText = New wxStaticText.Create(FilPlatPanel , wxID_ANY , "Filter:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		FilterTextBox = New wxTextCtrl.Create(FilPlatPanel, GES_FTB , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local PlatformText:wxStaticText = New wxStaticText.Create(FilPlatPanel , wxID_ANY , "Platform:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		PlatformCombo = New wxComboBox.Create(FilPlatPanel , GES_PL , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY | wxCB_SORT)

		Local UsedPlatformList:TList = CreateList()
		Local GameNode:GameReadType
		ReadGamesDir = ReadDir(GAMEDATAFOLDER)
		Repeat
			Dir:String = NextFile(ReadGamesDir)
			If Dir = "" Then Exit
			If Dir = "." Or Dir = ".." then Continue

			GameNode = New GameReadType
			If GameNode.GetGame(Dir) = - 1 then

			Else
				If UsedPlatformList.Contains(String(GameNode.PlatformNum) ) then

				Else
					ListAddLast(UsedPlatformList , String(GameNode.PlatformNum) )
				EndIf
			EndIf

		Forever
		CloseDir(ReadGamesDir)

		PlatformCombo.Append("All", "All")
		PlatformCombo.SetSelection(0)

		Local PlatNum:String
		Local Platform:PlatformType
		For PlatNum = EachIn UsedPlatformList
			Platform = GlobalPlatforms.GetPlatformByID(Int(PlatNum) )
			If Platform.Name = "" then

			Else
				PlatformCombo.Append(Platform.Name, String(Platform.ID) )
			EndIf
		Next


		If CmdLineGameName = "" then
			If SettingFile.GetSetting("Sort") <> "" then
				SortCombo.SetValue(SettingFile.GetSetting("Sort"))
			EndIf
			If SettingFile.GetSetting("Filter") <> "" Then
				FilterTextBox.ChangeValue(SettingFile.GetSetting("Filter"))
			EndIf
			If SettingFile.GetSetting("Platform") <> "" Then
				PlatformCombo.SetValue(SettingFile.GetSetting("Platform") )
			EndIf
		EndIf


		FilPlatHbox.Add(SortText , 0 , wxEXPAND | wxLEFT | wxTOP | wxBOTTOM | wxALIGN_CENTER , 10 )
		FilPlatHbox.Add(SortCombo , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP | wxBOTTOM , 10)
		FilPlatHbox.Add(FilterText , 0 , wxEXPAND | wxLEFT | wxTOP | wxBOTTOM| wxALIGN_CENTER , 10 )
		FilPlatHbox.Add(FilterTextBox , 2 , wxEXPAND | wxALL , 10)
		FilPlatHbox.Add(PlatformText , 0 , wxEXPAND | wxLEFT | wxTOP | wxBOTTOM| wxALIGN_CENTER , 10)
		FilPlatHbox.Add(PlatformCombo , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP | wxBOTTOM, 10)



		FilPlatPanel.SetSizer(FilPlatHbox)


		'---------------------------------SPLIT PANEL---------------------------------
		WinSplit = New wxSplitterWindow.Create(Self , WS , - 1 , - 1 , - 1 , - 1 , wxSP_NOBORDER | wxSP_LIVE_UPDATE)

		WinSplit.SetBackgroundColour(New wxColour.Create(PERed, PEGreen, PEBlue) )
		WinSplit.SetForegroundColour(New wxColour.Create(PERed, PEGreen, PEBlue) )

		Local GameListPanel:wxPanel = New wxPanel.Create(WinSplit , - 1)
		GameListPanel.SetBackgroundColour(New wxColour.Create(PERed2, PEGreen2, PEBlue2) )

	 	Local GameListPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
	 	GameList = New wxListCtrl.Create(GameListPanel , GES_GL , - 1 , - 1 , - 1 , - 1 , GameListStyle)
		GameList.SetBackgroundColour(New wxColour.Create(PERed2, PEGreen2, PEBlue2) )


		GameListPanelhbox.Add(GameList , 1 , wxEXPAND | wxALL , 20)
		GameListPanel.SetSizer(GameListPanelhbox)


		Local GameNotebookPanel:wxPanel = New wxPanel.Create(WinSplit , - 1)

		Local GameNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		?MacOS
		GameNotebook = New wxChoicebook.Create(GameNotebookPanel , GES_GN , - 1 , - 1 , - 1 , - 1 , wxCHB_DEFAULT)
		?Not MacOS
		GameNotebook = New wxNotebook.Create(GameNotebookPanel , GES_GN , - 1 , - 1 , - 1 , - 1 , wxNB_TOP | wxNB_MULTILINE | wxNB_FLAT)
		?
		GameNotebook.SetBackgroundColour(New wxColour.Create(PERed, PEGreen, PEBlue) )
		GameNotebookPanelhbox.Add(GameNotebook , 1 , wxEXPAND | wxLEFT , 10)
		GameNotebookPanel.SetSizer(GameNotebookPanelhbox)


		'----------------------------Details+Front Art Panel------------------------------
		SubWinSplit = New wxSplitterWindow.Create(GameNotebook , GES_SWS , - 1 , - 1 , - 1 , - 1 , wxSP_NOBORDER | wxSP_LIVE_UPDATE)
		Local FBAMainPanel:wxPanel = New wxPanel.Create(SubWinSplit , - 1)
		FBAMainPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )
		FBAMainPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		FBAPanel = ImagePanel(New ImagePanel.Create(FBAMainPanel , - 1) )
		Select SettingFile.GetSetting("SideArtType")
			Case "1"
				FBAPanel.SetImageType(1)
			Case "3"
				FBAPanel.SetImageType(3)
			Case "4"
				FBAPanel.SetImageType(4)
			Case "5"
				FBAPanel.SetImageType(5)
			Default
				FBAPanel.SetImageType(1)
		End Select

		'Local sl2:wxStaticLine = New wxStaticLine.Create(FBAMainPanel , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		FBAMainPanelvbox.Add(FBAPanel , 1 , wxEXPAND | wxBOTTOM | wxTOP , 5)
		FBAMainPanel.SetSizer(FBAMainPanelvbox)

		GameDetailsPanel = New wxPanel.Create(SubWinSplit , - 1)
		GameDetailsPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )
		GDPvbox = New wxBoxSizer.Create(wxVERTICAL)

		Local GNameFont:wxFont = New wxFont.Create()
		GNameFont.SetPointSize(9)
		GNameFont.SetWeight(wxFONTWEIGHT_BOLD)
		'GNameFont.SetFamily(wxFONTFAMILY_SWISS)

		GNameText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE )
		GNameText.SetFont(GNameFont)

		'Local sl1:wxStaticLine = New wxStaticLine.Create(GameDetailsPanel , wxID_ANY , -1 , -1 , -1 , -1 , wxLI_HORIZONTAL)
		'GDescText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
		GDescText = New wxTextCtrl.Create( GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 , wxTE_READONLY | wxTE_WORDWRAP | wxTE_RICH | wxTE_MULTILINE)
		GGenreText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
		GDevText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
		GPubText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
		GRDateText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
		GCertText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
		GDP_sub_hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
			GCoopText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
			GPlayersText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
		GDP_sub_hbox.Add(GCoopText , 1 , wxEXPAND , 0)
		GDP_sub_hbox.Add(GPlayersText , 1 , wxEXPAND , 0)
		GPlatText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )

		GDP_sub_hbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		GDP_sub_hbox3:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		GDP_sub_hbox4:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
			Local GRatingText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "Rating: " , - 1 , - 1 , - 1 , - 1 )
			GRatingCombo = New wxComboBox.Create(GameDetailsPanel, GDP_GRC , "" , RATINGLIST ,-1 , -1 , -1 , -1 , wxCB_READONLY )
			Local GCompletedText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "Completed: " , - 1 , - 1 , - 1 , - 1 )
			GCompletedCombo = New wxComboBox.Create(GameDetailsPanel, GDP_GCC , "" , ["Yes","No"] ,-1 , -1 , -1 , -1 , wxCB_READONLY )
		GDP_sub_hbox2.Add(GRatingText , 0 , wxEXPAND | wxTOP , 2)
		GDP_sub_hbox2.Add(GRatingCombo , 1 , wxEXPAND | wxRIGHT , 10)
		GDP_sub_hbox3.Add(GCompletedText , 0 , wxEXPAND | wxTOP , 2)
		GDP_sub_hbox3.Add(GCompletedCombo , 1 , wxEXPAND , 0)

		GDP_sub_hbox4.AddSizer(GDP_sub_hbox2 , 1 , wxEXPAND , 0)
		GDP_sub_hbox4.AddSizer(GDP_sub_hbox3 , 1 , wxEXPAND , 0)

		'GDPvbox.Add(sl1 , 0 , wxEXPAND , 0)
		GDPvbox.Add(GNameText , 0 , wxEXPAND | wxALL , 5)
		GDPvbox.Add(GDescText , 1 , wxEXPAND | wxALL , 5)
		GDPvbox.Add(GGenreText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		GDPvbox.Add(GDevText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		GDPvbox.Add(GPubText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		GDPvbox.Add(GRDateText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		GDPvbox.Add(GCertText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		'GDPvbox.Add(GCoopText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		'GDPvbox.Add(GPlayersText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		GDPvbox.Add(GPlatText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		GDPvbox.AddSizer(GDP_sub_hbox , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		GDPvbox.AddSizer(GDP_sub_hbox4 , 0 , wxEXPAND | wxALL , 5)
		'GRVersionText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "Version: Beta #1" , - 1 , - 1 , - 1 , - 1 )
		'GDPvbox.Add(GRVersionText , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT , 5)
		'MARK: Take Out
		GameDetailsPanel.SetSizer(GDPvbox)

		'-----------------------------------------Trailer Panel--------------------------------------
		Local GameTrailerPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		Local GameTrailerPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		GameTrailerPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )

		TrailerWeb = New wxWebView.Create(GameTrailerPanel, GES_TW, "http://photongamemanager.com", - 1, - 1, - 1, - 1)

		TrailerButton = New wxButton.Create(GameTrailerPanel , GES_TB ,"Watch in browser")

		GameTrailerPanelvbox.Add(TrailerWeb , 1 , wxEXPAND | wxALL , 5)

		GameTrailerPanelvbox.Add(TrailerButton , 0 , wxEXPAND | wxALL , 5)
		GameTrailerPanel.SetSizer(GameTrailerPanelvbox)

		'--------------------------------------------Screenshot Panel-----------------------------------
		Local GameScreenPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		GameScreenPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )
		Local GS_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		GS_SC1_Panel = ScreenShotPanel(New ScreenShotPanel.Create(GameScreenPanel , - 1) )
		GS_SC1_Panel.SetImageType(3)
		'Local sl101:wxStaticLine = New wxStaticLine.Create(GameScreenPanel , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		GS_SC2_Panel = ScreenShotPanel(New ScreenShotPanel.Create(GameScreenPanel , - 1) )
		GS_SC2_Panel.SetImageType(3)
		'Local sl102:wxStaticLine = New wxStaticLine.Create(GameScreenPanel , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)

		Local OpenScreenShotButton:wxButton = New wxButton.Create(GameScreenPanel , GS_OSB , "View ScreenShots")



		GS_vbox.Add(GS_SC1_Panel , 1 , wxEXPAND | wxALL , 5)
		'GS_vbox.Add(sl101 , 0 , wxEXPAND , 0)
		GS_vbox.Add(GS_SC2_Panel , 1 , wxEXPAND | wxALL , 5)
		'GS_vbox.Add(sl102 , 0 , wxEXPAND , 0)
		GS_vbox.Add(OpenScreenShotButton , 0 , wxEXPAND | wxALL , 5)
		GameScreenPanel.SetSizer(GS_vbox)


		'--------------------------------------------Patch Panel------------------------------------

		Local GamePatchNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		Local GPL_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		GamePatchNotebookPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )


		LocalPatchText = New wxStaticText.Create(GamePatchNotebookPanel , wxID_ANY , "Patch:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT )
		LocalPatchList = New wxListBox.Create(GamePatchNotebookPanel , GLP_PL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)
		LocalPatchFilesText = New wxStaticText.Create(GamePatchNotebookPanel , wxID_ANY , "Patch Files:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT )
		LocalPatchFileList = New wxListBox.Create(GamePatchNotebookPanel , GLP_PFL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)

		GPL_vbox.Add(LocalPatchText , 0 , wxEXPAND | wxALL , 5)
		GPL_vbox.Add(LocalPatchList , 1 , wxEXPAND | wxALL , 5)
		GPL_vbox.Add(LocalPatchFilesText  , 0 , wxEXPAND | wxALL , 5)
		GPL_vbox.Add(LocalPatchFileList , 1 , wxEXPAND | wxALL  , 5)
		GamePatchNotebookPanel.SetSizer(GPL_vbox)


		'--------------------------------------------Cheat Panel-----------------------------------


		Local GameCheatNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		GameCheatNotebookPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )
		Local GameCheatNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)




		LocalCheatList = New wxListBox.Create(GameCheatNotebookPanel , GLC_CL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)

		GameCheatNotebookPanelhbox.Add(LocalCheatList , 1 , wxEXPAND | wxALL , 5)



		GameCheatNotebookPanel.SetSizer(GameCheatNotebookPanelhbox)




		'--------------------------------------------Walkthrough Panel------------------------------



		Local GameWalkNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		GameWalkNotebookPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )
		Local GameWalkNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)




		LocalWalkList = New wxListBox.Create(GameWalkNotebookPanel , GLW_WL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)




		GameWalkNotebookPanelhbox.Add(LocalWalkList , 1 , wxEXPAND | wxALL , 5)

		GameWalkNotebookPanel.SetSizer(GameWalkNotebookPanelhbox)


		'--------------------------------------------Manual Panel----------------------------------

		Local GameManualNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		GameManualNotebookPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )
		Local GameManualNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)


		LocalManualList = New wxListBox.Create(GameManualNotebookPanel , GLM_ML , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)




		GameManualNotebookPanelhbox.Add(LocalManualList , 1 , wxEXPAND | wxALL , 5)

		GameManualNotebookPanel.SetSizer(GameManualNotebookPanelhbox)


		'--------------------------------------------Download Panel----------------------------------

		Local DownloadNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		DownloadNotebookPanel.SetBackgroundColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3) )
		Local DownloadNotebookPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Local DownloadSelectPanel:wxPanel = New wxPanel.Create(DownloadNotebookPanel , - 1)
		Local DSP_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Local DSP_hbox1:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local DownloadTypeText:wxStaticText = New wxStaticText.Create(DownloadSelectPanel , wxID_ANY , "Type:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DownloadTypeBox = New wxComboBox.Create(DownloadSelectPanel, GW_DP_DT , "" , ["Cheats", "Walkthroughs", "Patches", "Manuals" ] , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY )

		DSP_hbox1.Add(DownloadTypeText , 0 , wxEXPAND | wxALL , 5)
		DSP_hbox1.Add(DownloadTypeBox , 1 , wxEXPAND | wxALL , 5)


		Local DSP_hbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local DownloadSourceText:wxStaticText = New wxStaticText.Create(DownloadSelectPanel , wxID_ANY , "Source:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DownloadSourceBox = New wxComboBox.Create(DownloadSelectPanel, GW_DP_DSo , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY )

		DSP_hbox2.Add(DownloadSourceText , 0 , wxEXPAND | wxALL , 5)
		DSP_hbox2.Add(DownloadSourceBox , 1 , wxEXPAND | wxALL , 5)

		Local DSP_hbox4:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local DownloadPlatformText:wxStaticText = New wxStaticText.Create(DownloadSelectPanel , wxID_ANY , "Platform:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DownloadPlatformBox = New wxComboBox.Create(DownloadSelectPanel, GW_DP_DP , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY )

		DSP_hbox4.Add(DownloadPlatformText , 0 , wxEXPAND | wxALL , 5)
		DSP_hbox4.Add(DownloadPlatformBox , 1 , wxEXPAND | wxALL , 5)


		Local DSP_hbox3:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local DownloadSearchText:wxStaticText = New wxStaticText.Create(DownloadSelectPanel , wxID_ANY , "Search:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DownloadSearchBox = New wxTextCtrl.Create(DownloadSelectPanel, GW_DP_DSe , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		DownloadSearchButton = New wxButton.Create(DownloadSelectPanel , GM_DP_SB , "Go")

		DSP_hbox3.Add(DownloadSearchText , 0 , wxEXPAND | wxALL , 5)
		DSP_hbox3.Add(DownloadSearchBox , 1 , wxEXPAND | wxALL , 5)
		DSP_hbox3.Add(DownloadSearchButton , 0 , wxEXPAND | wxALL , 5)


		DSP_vbox.AddSizer(DSP_hbox1, 0, wxEXPAND, 0)
		DSP_vbox.AddSizer(DSP_hbox2, 0, wxEXPAND, 0)
		DSP_vbox.AddSizer(DSP_hbox4, 0, wxEXPAND, 0)
		DSP_vbox.AddSizer(DSP_hbox3, 0, wxEXPAND, 0)

		DownloadSelectPanel.SetSizer(DSP_vbox)

		DownloadList = New wxListBox.Create(DownloadNotebookPanel , GM_DP_DL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)
		DownloadListSelectButton = New wxButton.Create(DownloadNotebookPanel , GM_DP_LS , "Download")
		DownloadSourceHyperText = New wxHyperlinkCtrl.Create(DownloadNotebookPanel, GM_DP_SHL, "-", "", - 1, - 1, - 1, - 1, wxHL_ALIGN_LEFT)


		Self.DownloadDisableEnable(0, 0, 0, 0)


		DownloadNotebookPanelvbox.Add(DownloadSelectPanel , 0 , wxEXPAND | wxALL , 5)
		DownloadNotebookPanelvbox.Add(DownloadList, 1, wxEXPAND, 0)
		DownloadNotebookPanelvbox.Add(DownloadListSelectButton, 0, wxEXPAND | wxALL, 5)
		DownloadNotebookPanelvbox.Add(DownloadSourceHyperText, 0, wxEXPAND | wxALL, 5)

		DownloadNotebookPanel.SetSizer(DownloadNotebookPanelvbox)

		'-----------------------------------------------------------------------------------




		GameNotebook.AddPage(SubWinSplit , "Details" )
		GameNotebook.AddPage(GameTrailerPanel , "Trailer" )
		GameNotebook.AddPage(GameScreenPanel , "Screen Shots" )
		GameNotebook.AddPage(GameManualNotebookPanel , "Manual" )
		GameNotebook.AddPage(GamePatchNotebookPanel , "Patches" )
		GameNotebook.AddPage(GameCheatNotebookPanel , "Cheats" )
		GameNotebook.AddPage(GameWalkNotebookPanel , "Walkthroughs" )
		GameNotebook.AddPage(DownloadNotebookPanel , "Download" )


		WinSplit.SplitVertically(GameListPanel , GameNotebookPanel , - 300)
	 	WinSplit.SetSashGravity(1)
	 	WinSplit.SetMinimumPaneSize(100)

		If SettingFile.GetSetting("SplitterSash2") = "" Or SettingFile.GetSetting("SplitterSash2") = Null Or SettingFile.GetSetting("SplitterSash2") = 0 then
			SubWinSplit.SplitHorizontally(FBAMainPanel , GameDetailsPanel , 200)
		Else
			SubWinSplit.SplitHorizontally(FBAMainPanel , GameDetailsPanel , Int(SettingFile.GetSetting("SplitterSash2") ) )
		EndIf

	 	SubWinSplit.SetSashGravity(0)
	 	SubWinSplit.SetMinimumPaneSize(10)

	 	GameNotebook.Disable()


		'hbox.Add(GameList , 3 , wxEXPAND | wxALL , 10 )
		'hbox.Add(GameNotebook , 1 , wxEXPAND | wxALL , 10 )

		vbox.Add(FilPlatPanel , 0 ,  wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 0)
		vbox.Add(WinSplit , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 10 )

		Self.SetSizer(vbox)


		If SettingFile.GetSetting("WindowX") = "" Or SettingFile.GetSetting("WindowY") = "" then
			Self.Center()
		EndIf

		Self.PopulateGameList()

		Connect(GW_DP_DSo, wxEVT_COMMAND_TEXT_UPDATED, DownloadSourceChangedFun)
		Connect(GW_DP_DT, wxEVT_COMMAND_COMBOBOX_SELECTED, DownloadTypeChange)
		Connect(GM_DP_SB, wxEVT_COMMAND_BUTTON_CLICKED, DownloadSearchFun)
		Connect(GM_DP_DL, wxEVT_COMMAND_LISTBOX_DOUBLECLICKED, DownloadListItemSelectedFun)
		Connect(GM_DP_LS, wxEVT_COMMAND_BUTTON_CLICKED, DownloadListItemSelectedFun)



		Connect(GES_SL , wxEVT_COMMAND_COMBOBOX_SELECTED , FilterUpdate2)
		Connect(GES_FTB , wxEVT_COMMAND_TEXT_UPDATED , FilterUpdate)
		Connect(GES_PL , wxEVT_COMMAND_COMBOBOX_SELECTED , FilterUpdate2)


		Connect(GES_GL , wxEVT_COMMAND_LIST_ITEM_SELECTED , UpdateSelectionFun)
		Connect(GES_GL , wxEVT_COMMAND_LIST_ITEM_RIGHT_CLICK , GLRightClickedFun)
		Connect(GES_GL , wxEVT_COMMAND_LIST_ITEM_ACTIVATED , GLMenuClickedFun , "RG")



		Connect(GES_SWS , wxEVT_COMMAND_SPLITTER_SASH_POS_CHANGED , UpdatePicSize)

		Connect(GES_TB , wxEVT_COMMAND_BUTTON_CLICKED , OpenTrailer)
		Connect(GS_OSB , wxEVT_COMMAND_BUTTON_CLICKED , OpenScreenShots)

		Connect(GLP_PL , wxEVT_COMMAND_LISTBOX_SELECTED , PatchClickedFun)

		Connect(GLP_PFL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , PatchItemSelectedFun)
		Connect(GLM_ML , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , ManualItemSelectedFun)
		Connect(GLC_CL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED ,CheatItemSelectedFun)
		Connect(GLW_WL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , WalkItemSelectedFun)

		Connect(GP_GPN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		Connect(GM_GPN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		Connect(GW_GWN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		Connect(GC_GCN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		Connect(GES_GN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)

		Connect(GDP_GRC , wxEVT_COMMAND_COMBOBOX_SELECTED , UserDataUpdate)
		Connect(GDP_GCC , wxEVT_COMMAND_COMBOBOX_SELECTED , UserDataUpdate)

		Connect(GM_DP_SHL, wxEVT_COMMAND_HYPERLINK, HyperLinkFun)
		Connect(WS , wxEVT_COMMAND_SPLITTER_SASH_POS_CHANGED, SplitterSashMovedFun)
		Connect(GES_SWS , wxEVT_COMMAND_SPLITTER_SASH_POS_CHANGED, SplitterSash2MovedFun)

		Connect(GES_TW, wxEVT_WEBVIEW_NAVIGATED, TrailerSiteChanged)

		?Win32
		Local StringItem:String
		Local ID:Int = 0
		Local IDSet = False
		Local item:wxListItem
		If CmdLineGameName = "" then
			If SettingFile.GetSetting("LastGameNumber") <> "" then
				ID = Int(SettingFile.GetSetting("LastGameNumber") )
				If ID < GameList.GetItemCount() then
					item = New wxListItem.Create()
					item.SetId(ID )
					GameList.GetItem(item)
					item.SetState(wxLIST_STATE_SELECTED)
					GameList.SetItem(item)
				EndIf
			EndIf
		Else
			For StringItem = EachIn GameRealPathList
				If StringItem = CmdLineGameName then
					IDSet = True
					Exit
				Else
					ID = ID + 1
				EndIf
			Next
			If IDSet = True then
				If ID < GameList.GetItemCount() then
					item = New wxListItem.Create()
					item.SetId(ID)
					GameList.GetItem(item)
					item.SetState(wxLIST_STATE_SELECTED)
					GameList.SetItem(item)
				EndIf
			EndIf

		EndIf
		?


		StartupRefreshTimer = New wxTimer.Create(Self,SRT1)
		StartupRefreshTimer.Start(1000 , True)
		Connect(SRT1 , wxEVT_TIMER , StartupRefreshTimerFun)

		?Linux
		StartupRefreshTimer2 = New wxTimer.Create(Self, SRT2)
		StartupRefreshTimer2.Start(2000 , True)
		Connect(SRT2 ,wxEVT_TIMER , StartupRefreshTimerFun2)
		?

		StartupRefreshTimer3 = New wxTimer.Create(Self,SRT3)
		StartupRefreshTimer3.Start(3000 , True)
		Connect(SRT3 , wxEVT_TIMER , StartupRefreshTimerFun3)

		Connect(GES , wxEVT_SIZE , ResizeEventFun)
		Connect(GES , wxEVT_MOVE , MoveEventFun)
		Connect(RT1, wxEVT_TIMER, ResizedFun)
		Connect(MT1, wxEVT_TIMER, MovedFun)

		Connect(FT1, wxEVT_TIMER, GameListUpdate)

		LuaTimer.Start(100)
		Connect(LT1, wxEVT_TIMER , DownloadLuaEvent)

	End Method

	Function TrailerSiteChanged(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		'GameExploreWin.TrailerWeb.GetCurrentURL()
		PrintF("Website Changed: " + GameExploreWin.TrailerWeb.GetCurrentURL() )
		If GameExploreWin.TrailerWeb.GetCurrentURL() = "https://get.adobe.com/flashplayer/" Or GameExploreWin.TrailerWeb.GetCurrentURL() = "https://www.youtube.com/html5" then
			Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "This Gadget requires Adobe Flash for IE to work. To install Adobe Flash open up Internet Explorer and navigate to https://get.adobe.com/flashplayer/ ~n (You will still have to do this even if you have installed Adobe Flash via another browser such as Firefox or Chrome)", "Info", wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			GameExploreWin.TrailerWeb.LoadURL("https://www.youtube.com/embed/" + GameNode.Trailer)
		EndIf
	End Function

	Function HyperLinkFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		If GameExploreWin.DownloadSourceHyperText.GetURL() = "-" then
			Return
		EndIf
		Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "Goto website: " + GameExploreWin.DownloadSourceHyperText.GetURL() + "?~n(Note that Photon does not take any responsibility for the content or quality of the link and the site it points to)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES then
			wxLaunchDefaultBrowser(GameExploreWin.DownloadSourceHyperText.GetURL() )
		EndIf
	End Function

	Function DownloadLuaEvent(event:wxEvent)
		?Threaded
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		If GameExploreWin = Null then Return

		Local LuaEvent2:String

		LockMutex(LuaEventMutex)
		LuaEvent2 = LuaEvent
		LuaEvent = ""
		UnlockMutex(LuaEventMutex)

		Select LuaEvent2
			Case "SourceChanged"
				GameExploreWin.DownloadSourceChangedReturn()
			Case "Search"
				GameExploreWin.DownloadSearchReturn()
			Case "FurtherSearch"
				GameExploreWin.DownloadFurtherSearchReturn()
			Case ""
				'Do nothing
			Default
				'Error
		End Select

		?
	End Function


	Function DownloadSourceChangedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		GameExploreWin.DownloadSourceChanged()
	End Function

	Method DownloadSourceChanged()
		Self.DownloadDisableEnable(0, 0, 0, 0)

		If LuaMutexLock(1, 1) = 0 then
			Return
		EndIf

		Self.DownloadSourceHyperText.SetLabel("-")
		Self.DownloadSourceHyperText.SetURL("")
		Self.DownloadSourceHyperText.Refresh(1)

		Self.DownloadList.Clear()
		Self.DownloadPlatformBox.Clear()

		'Create Platform List
		Local LuaList:LuaListType = New LuaListType.Create()
		'Get Lua File
		Local LuaFile:String
		If Self.DownloadTypeBox.GetSelection() = wxNOT_FOUND then
			Return
		Else
			Select Self.DownloadTypeBox.GetSelection()+2
				Case 2
					LuaFile = LUAFOLDER + "Cheat" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 3
					LuaFile = LUAFOLDER + "Walkthrough" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 4
					LuaFile = LUAFOLDER + "Patch" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 5
					LuaFile = LUAFOLDER + "Manual" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Default
					CustomRuntimeError("SourceChanged - Select Error")
			End Select
		EndIf

		If LuaHelper_LoadString(LuaVM, "" , LuaFile) <> 0 then
			LuaMutexUnlock()
			Return
		EndIf
		PrintF("Running: " + LuaFile)

		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "GetPlatforms")
		lua_pushinteger( LuaVM , GameNode.PlatformNum)
		lua_pushbmaxobject( LuaVM, LuaList )
		lua_pushbmaxobject( LuaVM, LUAFOLDER )
		LuaMutexUnlock()


		?Threaded
		Local LuaThreadType:LuaThread_pcall_Type = New LuaThread_pcall_Type.Create(LuaVM, 3, 4, "SourceChanged")
		Local LuaThread:TThread = CreateThread(LuaThread_pcall_Funct, LuaThreadType)

		?Not Threaded
		LuaMutexLock()
		If LuaHelper_pcall(LuaVM, 3, 4) <> 0 then
			Return
			LuaMutexUnlock()
		Else
			LuaMutexUnlock()
		EndIf
		DownloadSourceChangedReturn()
		?
	End Method

	Method DownloadSourceChangedReturn()

		LuaMutexLock()
		Local ErrorString:String
		Local Error:Int

		'Get Return status
		If lua_isnumber(LuaVM, 1) = False then
			Error = 198
		Else
			Error = luaL_checkint( LuaVM, 1 )
		EndIf

		If Error <> 0 then
			If lua_isstring(LuaVM, 2) = False Or lua_isnumber(LuaVM, 1) = False then
				ErrorString = "Lua code did not return int @1 or/and string @2"
			Else
				ErrorString = luaL_checkstring(LuaVM , 2)
			EndIf
			LuaHelper_FunctionError(LuaVM, Error, ErrorString)
			LuaMutexUnlock()
			Return
		EndIf


		'Get selected platform
		If lua_isstring(LuaVM, 3) = False then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return string object @3")
			LuaMutexUnlock()
			Return
		EndIf
		Local SelectedPlatform:String = luaL_checkstring(LuaVM , 3)
		If lua_isbmaxobject(LuaVM, 4) = False then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return correct object @4")
			LuaMutexUnlock()
			Return
		EndIf
		Local LuaList:LuaListType = LuaListType(lua_tobmaxobject( LuaVM, 4 ) )
		Local SinglePlatform:LuaListItemType

		'Remove 2 return values from stack
		LuaHelper_CleanStack(LuaVM)

		For SinglePlatform = EachIn LuaList.List
			Self.DownloadPlatformBox.Append(SinglePlatform.ItemName, SinglePlatform.ClientData)
		Next

		Local SelectedPlatformItem:Int = Self.DownloadPlatformBox.FindString(SelectedPlatform)
		If SelectedPlatformItem <> - 1 then
			Self.DownloadPlatformBox.SetSelection(SelectedPlatformItem)
		EndIf

		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "GetText")
		LuaHelper_pcall(LuaVM, 0, 3)

		Error = luaL_checkint( LuaVM, 1 )
		If Error <> 0 then
			LuaHelper_FunctionError(LuaVM, Error, "Error Getting Website Source Link")
			LuaMutexUnlock()
			Return
		EndIf

		Local ReturnedSourceText:String = luaL_checkstring(LuaVM , 2)
		Local ReturnedSourceURL:String = luaL_checkstring(LuaVM , 3)
		LuaHelper_CleanStack(LuaVM)

		Self.DownloadSourceHyperText.SetLabel(ReturnedSourceText)
		Self.DownloadSourceHyperText.SetURL(ReturnedSourceURL)
		Self.DownloadSourceHyperText.Show()
		Self.DownloadSourceHyperText.Refresh(1)

		Self.DownloadDisableEnable(0, 1, 1, 1)
		'Blank out lua Code
		If LuaHelper_LoadString(LuaVM, LuaBlank) <> 0 then CustomRuntimeError("Blank Lua Code Error")

		LuaMutexUnlock()

	End Method



	Method DownloadDisableEnable( List:Int, Search:Int, Platform:Int, Source:Int)
		If List = 1 then
			Self.DownloadList.Enable()
			Self.DownloadListSelectButton.Enable()
		Else
			Self.DownloadList.Disable()
			Self.DownloadListSelectButton.Disable()
		EndIf
		If Search = 1 then
			Self.DownloadSearchBox.Enable()
			Self.DownloadSearchButton.Enable()
		Else
			Self.DownloadSearchBox.Disable()
			Self.DownloadSearchButton.Disable()
		EndIf
		If Platform = 1 then
			Self.DownloadPlatformBox.Enable()
		Else
			Self.DownloadPlatformBox.Disable()
		EndIf
		If Source = 1 then
			Self.DownloadSourceBox.Enable()
		Else
			Self.DownloadSourceBox.Disable()
		EndIf
	End Method

	Function DownloadListItemSelectedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		GameExploreWin.DownloadListItemSelected()
	End Function

	Method DownloadListItemSelected()
		Local MessageBox:wxMessageDialog
		If Self.DownloadListDepth = 0 then
			'Send Event
			'Self.SearchList.Clear()
			If Self.DownloadList.GetStringSelection() = "No Search Results Returned" Or Self.DownloadList.GetStringSelection() = "Searching..." then
				PrintF("Invalid search selection")
				MessageBox = New wxMessageDialog.Create(Null , "Not a valid selection!" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()
			Else
				Self.DownloadDisableEnable(0, 1, 1, 1)
				Self.DownloadListDepth = 1
				Local DownloadBox:DownloadWindow = DownloadWindow(New DownloadWindow.Create(Null, wxID_ANY, "Downloading", - 1, - 1, 300, 400, wxDEFAULT_FRAME_STYLE) )
				DownloadBox.ClientData = String(Self.DownloadList.GetItemClientData(Self.DownloadList.GetSelection() ) )
				DownloadBox.FName = String(Self.DownloadList.GetStringSelection() )
				DownloadBox.GName = GameNode.Name
				DownloadBox.GameFolderDownloadName = GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash

				If Self.DownloadTypeBox.GetSelection() = wxNOT_FOUND then
					Return
				Else
					Select Self.DownloadTypeBox.GetSelection() + 2
						Case 2
							DownloadBox.GameFolderDownloadName = DownloadBox.GameFolderDownloadName + "Cheats" + FolderSlash
							DownloadBox.LuaFile = LUAFOLDER + "Cheat" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
						Case 3
							DownloadBox.GameFolderDownloadName = DownloadBox.GameFolderDownloadName + "Guides" + FolderSlash
							DownloadBox.LuaFile = LUAFOLDER + "Walkthrough" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
						Case 4
							DownloadBox.GameFolderDownloadName = DownloadBox.GameFolderDownloadName + "Patches" + FolderSlash
							DownloadBox.LuaFile = LUAFOLDER + "Patch" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
						Case 5
							DownloadBox.GameFolderDownloadName = DownloadBox.GameFolderDownloadName + "Manuals" + FolderSlash
							DownloadBox.LuaFile = LUAFOLDER + "Manual" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
						Default
							CustomRuntimeError("DownloadListItemSelected - Select Error")
					End Select
				EndIf
				If FileType(DownloadBox.GameFolderDownloadName) = 0 then
					CreateDir(DownloadBox.GameFolderDownloadName, 1)
				EndIf

				Self.DownloadList.Clear()
				DownloadBox.Show(1)

				?Threaded
				DownloadBox.Thread = CreateThread(Thread_Download, DownloadBox)
				?Not Threaded
				Thread_Download(DownloadBox)
				?
			EndIf
		else
			Self.DownloadFurtherSearch(String(Self.DownloadList.GetItemClientData(Self.DownloadList.GetSelection() ) ) )
		EndIf
	End Method

	Method DownloadFurtherSearch(ClientData:String)
		LuaMutexLock()

		Self.DownloadList.Clear()
		Self.DownloadList.Append("Searching...")

		Local PlatformData:String = String(Self.DownloadPlatformBox.GetItemClientData(Self.DownloadPlatformBox.GetSelection() ) )
		Local LuaList:LuaListType = New LuaListType.Create()
		Local LuaInternet:LuaInternetType = LuaInternetType(New LuaInternetType.Create() )

		Local LuaFile:String
		If Self.DownloadTypeBox.GetSelection() = wxNOT_FOUND then
			Return
		Else
			Select Self.DownloadTypeBox.GetSelection()+2
				Case 2
					LuaFile = LUAFOLDER + "Cheat" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 3
					LuaFile = LUAFOLDER + "Walkthrough" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 4
					LuaFile = LUAFOLDER + "Patch" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 5
					LuaFile = LUAFOLDER + "Manual" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Default
					CustomRuntimeError("SourceChanged - Select Error")
			End Select
		EndIf
		If LuaHelper_LoadString(LuaVM, "", LuaFile) <> 0 then
			LuaMutexUnlock()
			Return
		EndIf

		'Get Lua Function
		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "Search")
		'Push PlatformNum and empty list
		lua_pushbmaxobject( LuaVM , Self.DownloadOldSearch)
		lua_pushbmaxobject( LuaVM , ClientData)
		lua_pushbmaxobject( LuaVM , PlatformData)
		lua_pushinteger( LuaVM , Self.DownloadListDepth)
		lua_pushbmaxobject( LuaVM, LuaInternet )
		lua_pushbmaxobject( LuaVM, LuaList )
		lua_pushbmaxobject( LuaVM, LUAFOLDER )
		'Call Lua Function

		LuaMutexUnlock()

		?Threaded
		Local LuaThreadType:LuaThread_pcall_Type = New LuaThread_pcall_Type.Create(LuaVM, 7, 4, "FurtherSearch" )
		Local LuaThread:TThread = CreateThread(LuaThread_pcall_Funct, LuaThreadType)
		?Not Threaded
		LuaMutexLock()
		If LuaHelper_pcall(LuaVM, 7, 4) <> 0 then
			Return
			LuaMutexUnlock()
		Else
			LuaMutexUnlock()
		EndIf
		DownloadFurtherSearchReturn()
		?

	End Method

	Method DownloadFurtherSearchReturn()

		LuaMutexLock()
		PlaySound Beep
		Local Error:Int, ErrorString:String

		'Get Return status
		If lua_isnumber(LuaVM, 1) = False then
			Error = 198
		Else
			Error = luaL_checkint( LuaVM, 1 )
		EndIf

		If Error <> 0 then
			If lua_isstring(LuaVM, 2) = False Or lua_isnumber(LuaVM, 1) = False then
				ErrorString = "Lua code did not return int @1 or/and string @2"
			Else
				ErrorString = luaL_checkstring(LuaVM , 2)
			EndIf
			LuaHelper_FunctionError(LuaVM, Error, ErrorString)
			LuaMutexUnlock()
			Return
		EndIf


		If lua_isnumber(LuaVM, 3) = False then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return int @3")
			LuaMutexUnlock()
			Return
		EndIf
		Self.DownloadListDepth = luaL_checkint( LuaVM , 3)
		If lua_isbmaxobject(LuaVM, 4) = False then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return correct object @4")
			LuaMutexUnlock()
			Return
		EndIf
		Local LuaList:LuaListType = LuaListType(lua_tobmaxobject( LuaVM, 4 ) )

		LuaHelper_CleanStack(LuaVM)

		Self.DownloadList.Clear()

		If CountList(LuaList.List) > 0 then
			Local LuaListItem:LuaListItemType
			For LuaListItem = EachIn LuaList.List
				Self.DownloadList.Append(LuaListItem.ItemName, LuaListItem.ClientData)
			Next
			Self.DownloadDisableEnable(1, 1, 1, 1)
		Else
			Self.DownloadList.Append("No Search Results Returned", "")
		EndIf

		LuaHelper_LoadString(LuaVM, LuaBlank)

		LuaMutexUnlock()

	End Method

	Function DownloadSearchFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		GameExploreWin.DownloadSearch()
	End Function

	Method DownloadSearch()
		LuaMutexLock()

		Self.DownloadListDepth = 1
		Self.DownloadDisableEnable(0, 1, 1, 1)
		Self.DownloadList.Clear()
		Self.DownloadList.Append("Searching...")

		LuaInternet.Reset()

		Local SearchTerm:String = Self.DownloadSearchBox.GetValue()

		Local PlatformData:String
		If Self.DownloadPlatformBox.GetSelection() = wxNOT_FOUND then
			LuaMutexUnlock()
			Return
		Else
			PlatformData = String(Self.DownloadPlatformBox.GetItemClientData(Self.DownloadPlatformBox.GetSelection() ) )
		EndIf

		Local LuaList:LuaListType = New LuaListType.Create()

		Local LuaFile:String
		If Self.DownloadTypeBox.GetSelection() = wxNOT_FOUND then
			Return
		Else
			Select Self.DownloadTypeBox.GetSelection()+2
				Case 2
					LuaFile = LUAFOLDER + "Cheat" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 3
					LuaFile = LUAFOLDER + "Walkthrough" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 4
					LuaFile = LUAFOLDER + "Patch" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Case 5
					LuaFile = LUAFOLDER + "Manual" + FolderSlash + Self.DownloadSourceBox.GetValue() + ".lua"
				Default
					CustomRuntimeError("SourceChanged - Select Error")
			End Select
		EndIf

		If LuaHelper_LoadString(LuaVM, "", LuaFile) <> 0 then
			LuaMutexUnlock()
			Return
		EndIf

		Self.DownloadOldSearch = SearchTerm

		'Get Lua Function
		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "Search")
		'Push PlatformNum and empty list
		lua_pushbmaxobject( LuaVM , SearchTerm)
		lua_pushbmaxobject( LuaVM , "")
		lua_pushbmaxobject( LuaVM , PlatformData)
		lua_pushinteger( LuaVM , Self.DownloadListDepth)
		lua_pushbmaxobject( LuaVM, LuaInternet )
		lua_pushbmaxobject( LuaVM, LuaList )
		lua_pushbmaxobject( LuaVM, LUAFOLDER )
		'Call Lua Function

		LuaMutexUnlock()

		?Threaded
		Local LuaThreadType:LuaThread_pcall_Type = New LuaThread_pcall_Type.Create(LuaVM, 7, 4, "Search" )
		Local LuaThread:TThread = CreateThread(LuaThread_pcall_Funct, LuaThreadType)

		?Not Threaded
		LuaMutexLock()
		If LuaHelper_pcall(LuaVM, 7, 4) <> 0 then
			Return
			LuaMutexUnlock()
		Else
			LuaMutexUnlock()
		EndIf
		DownloadSearchReturn()
		?
	End Method


	Method DownloadSearchReturn()
		PlaySound Beep
		Local ErrorString:String

		LuaMutexLock()
		Local Error:Int

		'Get Return status
		If lua_isnumber(LuaVM, 1) = False then
			Error = 198
		Else
			Error = luaL_checkint( LuaVM, 1 )
		EndIf

		If Error <> 0 then
			If lua_isstring(LuaVM, 2) = False Or lua_isnumber(LuaVM, 1) = False then
				ErrorString = "Lua code did not return int @1 or/and string @2"
			Else
				ErrorString = luaL_checkstring(LuaVM , 2)
			EndIf
			LuaHelper_FunctionError(LuaVM, Error, ErrorString)
			LuaMutexUnlock()
			Return
		EndIf


		If lua_isnumber(LuaVM, 3) = False then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return int @3")
			LuaMutexUnlock()
			Return
		EndIf
		Self.DownloadListDepth = luaL_checkint( LuaVM , 3)
		If lua_isbmaxobject(LuaVM, 4) = False then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return correct object @4")
			LuaMutexUnlock()
			Return
		EndIf
		Local LuaList:LuaListType = LuaListType(lua_tobmaxobject( LuaVM, 4 ) )

		LuaHelper_CleanStack(LuaVM)

		Self.DownloadList.Clear()
		If CountList(LuaList.List) > 0 then
			Local LuaListItem:LuaListItemType
			For LuaListItem = EachIn LuaList.List
				Self.DownloadList.Append(LuaListItem.ItemName, LuaListItem.ClientData)
			Next
			Self.DownloadDisableEnable(1, 1, 1, 1)
		Else
			Self.DownloadList.Append("No Search Results Returned", "")
		EndIf

		LuaHelper_LoadString(LuaVM, LuaBlank)
		LuaMutexUnlock()
	End Method


	Function DownloadTypeChange(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local item:Int = GameExploreWin.DownloadTypeBox.GetSelection()
		Local Sources:TList, Source:String

		GameExploreWin.DownloadDisableEnable(0, 0, 0, 0)

		If item = wxNOT_FOUND then
			CustomRuntimeError("DownloadTypeChange: item not found")
		Else
			GameExploreWin.DownloadSourceBox.Clear()
			GameExploreWin.DownloadPlatformBox.Clear()
			GameExploreWin.DownloadList.Clear()
			GameExploreWin.DownloadSourceHyperText.SetLabel("-")
			GameExploreWin.DownloadSourceHyperText.SetURL("")
			GameExploreWin.DownloadSourceHyperText.Refresh(1)
			Sources = GetLuaList(item + 2)
			For Source = EachIn Sources
				GameExploreWin.DownloadSourceBox.Append(Source)
			Next
			GameExploreWin.DownloadSourceBox.SetStringSelection(LuaHelper_GetDefault(item + 2) )
			If Sources.Count() > 0 then
				GameExploreWin.DownloadDisableEnable(0, 0, 0, 1)
				GameExploreWin.DownloadSourceChanged()
			Else
				GameExploreWin.DownloadSourceBox.Append("No available sources")
				GameExploreWin.DownloadSourceBox.SetSelection(0)
			EndIf
		EndIf
	End Function

	Function MoveEventFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		event.Skip(True)
		GameExploreWin.MoveTimer.Stop()
		GameExploreWin.MoveTimer.Start(2000, 1)
	End Function

	Function MovedFun(event:wxEvent)
		PrintF("Moved Win")
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local x:Int, y:Int
		GameExploreWin.GetPosition(x, y)
		SettingFile.SaveSetting("WindowX" , String(x) )
		SettingFile.SaveSetting("WindowY" , String(y) )
		SettingFile.SaveFile()
	End Function

	Function ResizedFun(event:wxEvent)
		PrintF("Resized Win")
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local w:Int, h:Int
		GameExploreWin.GetSize(w, h)

		If GameExploreWin.IsMaximized() = 0 then
			SettingFile.SaveSetting("WindowWidth" , String(w) )
			SettingFile.SaveSetting("WindowHeight" , String(h) )
		EndIf
		SettingFile.SaveSetting("WindowMaximized" , String(GameExploreWin.IsMaximized() ) )
		SettingFile.SaveFile()
	End Function

	Function ResizeEventFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		event.Skip(True)
		GameExploreWin.ResizeTimer.Stop()
		GameExploreWin.ResizeTimer.Start(2000, 1)
	'	GameExploreWin.Refresh()
	'	GameExploreWin.Update()
	End Function

	Function SplitterSashMovedFun(event:wxEvent)
		PrintF("Sash1")
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local w:Int, h:Int
		GameExploreWin.WinSplit.GetSize(w, h)
		SettingFile.SaveSetting("SplitterSash1" , String(w - GameExploreWin.WinSplit.GetSashPosition() ) )
		SettingFile.SaveFile()
		GameExploreWin.Refresh()
	End Function

	Function SplitterSash2MovedFun(event:wxEvent)
		PrintF("Sash2")
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		SettingFile.SaveSetting("SplitterSash2" , String(GameExploreWin.SubWinSplit.GetSashPosition() ) )
		SettingFile.SaveFile()
		GameExploreWin.Refresh()
	End Function

	Method RefreshWindow()
		PrintF("Refresh")

		'Linux Part required otherwise GameList doesn't update and is just blank
		?Linux
		Local w:Int
		Local h:Int
		Self.GetSize(w,h)
		Self.SetSize(w+1,h)
		?

		Self.Refresh()
		Self.Update()
	End Method

	Function StartupRefreshTimerFun3(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		If CmdLineGameName <> "" then
			Select CmdLineGameTab
				Case "ScreenShots"
					GameExploreWin.GameNotebook.ChangeSelection(2)
				Case "Manuals"
					GameExploreWin.GameNotebook.ChangeSelection(3)
				Case "Patches"
					GameExploreWin.GameNotebook.ChangeSelection(4)
				Case "Cheats"
					GameExploreWin.GameNotebook.ChangeSelection(5)
				Case "Walkthroughs"
					GameExploreWin.GameNotebook.ChangeSelection(6)
			End Select
		EndIf
	End Function

	Function StartupRefreshTimerFun2(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)

		Local StringItem:String
		Local ID:Int = 0
		Local IDSet = False
		Local item:wxListItem
		If CmdLineGameName = "" Then
			If SettingFile.GetSetting("LastGameNumber") <> "" Then
				item = New wxListItem.Create()
				item.SetID(Int(SettingFile.GetSetting("LastGameNumber")))
				GameExploreWin.GameList.GetItem(item)
				item.SetState(wxLIST_STATE_SELECTED)
				GameExploreWin.GameList.SetItem(item)
			EndIf
		Else
			For StringItem = EachIn GameExploreWin.GameRealPathList
				If StringItem = CmdLineGameName Then
					IDSet = True
					Exit
				Else
					ID = ID + 1
				EndIf
			Next
			If IDSet = True then
				item = New wxListItem.Create()
				item.SetID(ID)
				GameExploreWin.GameList.GetItem(item)
				item.SetState(wxLIST_STATE_SELECTED)
				GameExploreWin.GameList.SetItem(item)
			EndIf

		EndIf
	End Function

	Function StartupRefreshTimerFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		GameExploreWin.Show()
		Local Sash1:Int = Int(SettingFile.GetSetting("SplitterSash1") )
		If Sash1 = 0 then
		Else
			GameExploreWin.WinSplit.SetSashPosition( - Sash1)
		EndIf
		GameExploreWin.RefreshWindow()
	End Function

	Function UserDataUpdate(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		If GameExploreWin.GCompletedCombo.GetValue() = "Yes" Then
			Completed = 1
		Else
			Completed = 0
		EndIf
		If GameExploreWin.GRatingCombo.GetValue() = "Select..." Then
			Rating = 0
		Else
			Rating = Int(GameExploreWin.GRatingCombo.GetValue())
		EndIf
		WriteUserData = WriteFile(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "userdata.txt")
		WriteLine(WriteUserData , Rating)
		WriteLine(WriteUserData, Completed)
		CloseFile(WriteUserData)
	End Function

	Function PatchItemSelectedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalPatchList.GetStringSelection()
		Local Selection2:String = GameExploreWin.LocalPatchFileList.GetStringSelection()
		Local CDir:String = CurrentDir()
		ChangeDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Patches" + FolderSlash + Selection)
		OpenURL(Selection2)
		ChangeDir(CDir)
	End Function

	Function WalkItemSelectedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalWalkList.GetStringSelection()
		Local CDir:String = CurrentDir()
		If Selection = "No Walkthroughs Found Locally" Or Selection = "Use 'Download' tab to download some" then
			Return
		EndIf
		ChangeDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides")
		OpenURL(Selection)
		ChangeDir(CDir)
	End Function

	Function ManualItemSelectedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalManualList.GetStringSelection()
		If Selection = "No Manuals Found Locally" Or Selection = "Use 'Download' tab to download some" then
			Return
		EndIf
		Local CDir:String = CurrentDir()
		ChangeDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Manuals")
		OpenURL(Selection)
		ChangeDir(CDir)
	End Function

	Function CheatItemSelectedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalCheatList.GetStringSelection()
		Local CDir:String = CurrentDir()
		If Selection = "No Cheats Found Locally" Or Selection = "Use 'Download' tab to download some" then
			Return
		EndIf
		ChangeDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Cheats")
		OpenURL(Selection)
		ChangeDir(CDir)
	End Function

	Function PatchClickedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalPatchList.GetStringSelection()
		Local File:String

		If Selection = "No Patches Found Locally" Or Selection = "Use 'Download' tab to download some" then
			Return
		EndIf

		GameExploreWin.LocalPatchFileList.Clear()

		ReadPatches = ReadDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Patches" + FolderSlash + Selection)
		Repeat
			File = NextFile(ReadPatches)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue
			If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Patches" + FolderSlash + Selection + FolderSlash + File) = 1 Then
				GameExploreWin.LocalPatchFileList.Append(File)
			EndIf
		Forever
		CloseDir(ReadPatches)

	End Function

	Rem
	Function WalkClickedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalWalkList.GetStringSelection()
		Local File:String

		GameExploreWin.LocalWalkFileList.Clear()

		ReadWalks = ReadDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides" + FolderSlash + Selection)
		Repeat
			File = NextFile(ReadWalks)
			If File="." Or File=".." Then Continue
			If File = "" then Exit
			If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides" + FolderSlash + Selection + FolderSlash + File) = 1 Then
				GameExploreWin.LocalWalkFileList.Append(File)
			EndIf
		Forever
		CloseDir(ReadWalks)

	End Function
	EndRem

	Function ExitFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		PrintF("Exit Function")
		SettingFile.CloseFile()
		EndLuaVM()
		?Win32
		If CmdLineGameName <> "" then
			RunProcess("FrontEnd.exe", 1)
		EndIf
		?Linux

		?
		GameExploreWin.Destroy()
		End
	End Function

	Function LoadKeyboardFun(event:wxEvent)
		?Win32
		Select WinBit
			Case 64
				OpenURL(WinDir + "\sysnative\osk.exe")
				PrintF( WinDir + "\sysnative\osk.exe")
			Case 32
				OpenURL(WinDir + "\system32\osk.exe")
				PrintF( WinDir + "\system32\osk.exe")
			Default
				CustomRuntimeError("Error 108: Invalid Windows Bit") 'MARK: Error 108
		End Select
		?
	End Function

	Function ChangeListTypeFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local data:Object = event.userData
		Select String(data)
			Case "1"
				GameListStyle = wxLC_ICON | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE | wxBORDER_NONE
				ShowIcons = 1
				SettingFile.SaveSetting("ListType" , "1")
				SettingFile.SaveFile()
			Case "2"
				GameListStyle = wxLC_LIST | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE | wxBORDER_NONE
				ShowIcons = 1
				SettingFile.SaveSetting("ListType" , "2")
				SettingFile.SaveFile()
			Case "3"
				GameListStyle = wxLC_LIST | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE | wxBORDER_NONE
				ShowIcons = 0
				SettingFile.SaveSetting("ListType" , "3")
				SettingFile.SaveFile()
		End Select
		GameExploreWin.GameList.SetWindowStyleFlag(GameListStyle)
		GameExploreWin.PopulateGameList
	End Function

	Function ChangeListArtFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local data:Object = event.userData
		Select String(data)
			Case "1"
				GameListIconType = 1
				SettingFile.SaveSetting("ListArt" , "1")
				SettingFile.SaveFile()
			Case "3"
				GameListIconType = 3
				SettingFile.SaveSetting("ListArt" , "3")
				SettingFile.SaveFile()
			Case "4"
				GameListIconType = 4
				SettingFile.SaveSetting("ListArt" , "4")
				SettingFile.SaveFile()
			Case "5"
				GameListIconType = 5
				SettingFile.SaveSetting("ListArt" , "5")
				SettingFile.SaveFile()
		End Select
		GameExploreWin.PopulateGameList
	End Function

	Function ChangeIconSizeFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local data:Object = event.userData
		Select String(data)
			Case "16"
				IconSize = 16
				SettingFile.SaveSetting("IconSize" , "16")
				SettingFile.SaveFile()
			Case "32"
				IconSize = 32
				SettingFile.SaveSetting("IconSize" , "32")
				SettingFile.SaveFile()
			Case "64"
				IconSize = 64
				SettingFile.SaveSetting("IconSize" , "64")
				SettingFile.SaveFile()
			Case "128"
				IconSize = 128
				SettingFile.SaveSetting("IconSize" , "128")
				SettingFile.SaveFile()
			Case "256"
				IconSize = 256
				SettingFile.SaveSetting("IconSize" , "256")
				SettingFile.SaveFile()
			Case "512"
				IconSize = 512
				SettingFile.SaveSetting("IconSize" , "512")
				SettingFile.SaveFile()
		End Select
		GameExploreWin.PopulateGameList
	End Function

	Function ChangeListTextFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local data:Object = event.userData
		Select String(data)
			Case "0"
				GameListText = 0
				SettingFile.SaveSetting("ListText" , "0")
				SettingFile.SaveFile()
			Case "1"
				GameListText = 1
				SettingFile.SaveSetting("ListText" , "1")
				SettingFile.SaveFile()
		End Select
		GameExploreWin.PopulateGameList
	End Function

	Function ChangeListGenericFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local data:Object = event.userData
		Select String(data)
			Case "-1"
				GenericArt = - 1
				SettingFile.SaveSetting("ListGeneric" , "-1")
				SettingFile.SaveFile()
			Case "0"
				GenericArt = 0
				SettingFile.SaveSetting("ListGeneric" , "0")
				SettingFile.SaveFile()
		End Select
		GameExploreWin.PopulateGameList
	End Function

	Function GLMenuClickedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)

		Local item:Int = GameExploreWin.GameList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		If item = - 1 Then
			Return
		EndIf
		Local GameNamesArray:Object[]
		GameNamesArray = ListToArray(GameExploreWin.GameRealPathList)
		Local GameN:String = String(GameNamesArray[item])

		Local data:Object = event.userData
		If String(data) = "RG" then
			RunProcess(RUNNERPROGRAM + " -Runner 1 -GameName " + Chr(34) + GameN + Chr(34) + " -EXENum 1 -Cabinate 2", 1)
			GameExploreWin.Close(True)
		Else
			Local RunNumber:Int = Int(String(data) )
			PrintF(RunNumber)
			RunProcess(RUNNERPROGRAM + " -Runner 1 -GameName " + Chr(34) + GameN + Chr(34) + " -EXENum " + RunNumber + " -Cabinate 2", 1)
			GameExploreWin.Close(True)
		EndIf
	End Function

	Function GLRightClickedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local item:Int = GameExploreWin.GameList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		If item = - 1 Then
			Return
		EndIf
		Local GameNamesArray:Object[]
		GameNamesArray = ListToArray(GameExploreWin.GameRealPathList)
		Local GameName:String = String(GameNamesArray[item])
		GameNode:GameReadType = New GameReadType
		If GameNode.GetGame(GameName) = - 1 Then
			Return
		Else


			Local Menu1:wxMenu = New wxMenu.Create()
			Menu1.Append(GL_M1_RG , "Run Game")
			GameExploreWin.Connect(GL_M1_RG , wxEVT_COMMAND_MENU_SELECTED , GLMenuClickedFun , "RG")
			Local a = 2
			For Exe:String = EachIn GameNode.OEXEsName
				Menu1.Append(1200 + a , Exe)
				GameExploreWin.Connect(1200 + a , wxEVT_COMMAND_MENU_SELECTED , GLMenuClickedFun , String(a))
				a = a + 1
			Next
			GameExploreWin.PopupMenu(Menu1)
		EndIf
	End Function

	Function OpenScreenShots(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local item:Int = GameExploreWin.GameList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		If item = - 1 Then
			Return
		EndIf
		Local GameNamesArray:Object[]
		GameNamesArray = ListToArray(GameExploreWin.GameRealPathList)
		Local GameName:String = String(GameNamesArray[item])
		If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "ScreenShots") <> 2 Then
			CreateDir(GAMEDATAFOLDER + GameName + FolderSlash + "ScreenShots")
		EndIf
		OpenURL(GAMEDATAFOLDER + GameName + FolderSlash + "ScreenShots")
	End Function

	Function OpenTrailer(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local item:Int = GameExploreWin.GameList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		If item = - 1 Then
			Return
		EndIf
		Local GameNamesArray:Object[]
		GameNamesArray = ListToArray(GameExploreWin.GameRealPathList)
		Local GameName:String = String(GameNamesArray[item])
		GameNode:GameReadType = New GameReadType
		If GameNode.GetGame(GameName) = - 1 Then
			Return
		Else
			If GameNode.Trailer = "" then
				MessageBox = New wxMessageDialog.Create(Null , "This game doesn't have a trailer associated with it" , "Info" , wxOK | wxICON_INFORMATION)
				MessageBox.ShowModal()
				MessageBox.Free()
				Return
			Else
				OpenURL("http://www.youtube.com/watch?v=" + GameNode.Trailer)
			EndIf
		EndIf
	End Function

	Function UpdatePicSize(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		GameExploreWin.FBAPanel.Refresh()
	End Function

	Function UpdateSelectionFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		GameExploreWin.UpdateSelection()
	End Function

	Method UpdateSelection()
		Local item:Int = Self.GameList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		If item = - 1 Then
			Return
		EndIf
		SettingFile.SaveSetting("LastGameNumber" , String(item) )
		SettingFile.SaveFile()

		Local File:String
		Local GameNamesArray:Object[]
		GameNamesArray = ListToArray(Self.GameRealPathList)
		Local GameName:String = String(GameNamesArray[item])

		GameNode = New GameReadType
		If GameNode.GetGame(GameName) = - 1 then

		Else
			Self.GameNotebook.Enable()
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Front_OPT_2X.jpg") = 1 then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Front_OPT_2X.jpg" , 1)
			Else
				FBAPanel.SetImage("" , 1)

			EndIf
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Back_OPT_2X.jpg") = 1 then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Back_OPT_2X.jpg" , 2)
			Else
				FBAPanel.SetImage("" , 2)

			EndIf
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Screen_OPT_2X.jpg") = 1 then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Screen_OPT_2X.jpg" , 3)
			Else
				FBAPanel.SetImage("" , 3)

			EndIf
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Banner_OPT_2X.jpg") = 1 then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Banner_OPT_2X.jpg" , 4)
			Else
				FBAPanel.SetImage("" , 4)

			EndIf
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Icon.ico") = 1 Then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Icon.ico" , 5)
			Else
				FBAPanel.SetImage("" , 5)

			EndIf

			Local TheScreenShotList:TList = CreateList()
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Shot1_OPT.jpg") = 1 Then
				ListAddLast(TheScreenShotList , GAMEDATAFOLDER + GameName + FolderSlash + "Shot1_OPT.jpg")
			EndIf
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Shot2_OPT.jpg") = 1 Then
				ListAddLast(TheScreenShotList , GAMEDATAFOLDER + GameName + FolderSlash + "Shot2_OPT.jpg")
			EndIf
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "ScreenShots") = 2 Then
				ReadScreenShotDir = ReadDir(GAMEDATAFOLDER + GameName + FolderSlash + "ScreenShots")
				Repeat
					File = NextFile(ReadScreenShotDir)
					If File = "" Then Exit
					If File="." Or File=".." Then Continue
					If ExtractExt(File) = "jpg" Then
						ListAddLast(TheScreenShotList , GAMEDATAFOLDER + GameName + FolderSlash + "ScreenShots"+FolderSlash+File)
					EndIf
				Forever
				CloseDir(ReadScreenShotDir)
			EndIf
			Local FirstSS:String = String(TheScreenShotList.RemoveLast() )
			Print "FSS: "+FirstSS
			Local SecondSS:String = String(TheScreenShotList.RemoveLast() )
			Print "SSS: "+SecondSS

			If FirstSS = Null Then
				GS_SC1_Panel.SetImage("" , 3)
			Else
				GS_SC1_Panel.SetImage(FirstSS , 3)
			EndIf

			If SecondSS = Null Then
				GS_SC2_Panel.SetImage("" , 3)
			Else
				GS_SC2_Panel.SetImage(SecondSS , 3)
			EndIf


			Self.GNameText.SetLabel(CorrectText(GameNode.Name) )
			Self.GDescText.ChangeValue(CorrectText(GameNode.Desc) )
			Local GenreList:String
			For Gen:String = EachIn GameNode.Genres
				GenreList = GenreList + Gen + ", "
			Next
			GenreList = Left(GenreList , Len(GenreList) - 2)


			Self.LocalPatchList.Clear()
			Self.LocalPatchFileList.Clear()
			Self.LocalWalkList.Clear()
			Self.LocalManualList.Clear()
			Self.LocalCheatList.Clear()

			If FileType(GAMEDATAFOLDER+GameNode.OrginalName+FolderSlash+"Patches") = 2 Then
				ReadPatches = ReadDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Patches")
				Repeat
					File = NextFile(ReadPatches)
					If File = "" Then Exit
					If File="." Or File=".." Then Continue
					If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Patches" + FolderSlash + File) = 2 Then
						Self.LocalPatchList.Append(File)
					EndIf
				Forever
				CloseDir(ReadPatches)
			EndIf

			If Self.LocalPatchList.GetCount() = 0 then
				Self.LocalPatchList.Append("No Patches Found Locally")
				Self.LocalPatchList.Append("Use 'Download' tab to download some")
			EndIf

			If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Cheats") = 2 then

				ReadCheats = ReadDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Cheats")
				Repeat
					File = NextFile(ReadCheats)
					If File="." Or File=".." Then Continue
					If File = "" Then Exit
					If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Cheats" + FolderSlash + File) = 1 Then
						Self.LocalCheatList.Append(File)
					EndIf
				Forever
				CloseDir(ReadCheats)
			EndIf

			If Self.LocalCheatList.GetCount() = 0 then
				Self.LocalCheatList.Append("No Cheats Found Locally")
				Self.LocalCheatList.Append("Use 'Download' tab to download some")
			EndIf

			If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides") = 2 then
				ReadWalks = ReadDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash +"Guides")
				Repeat
					File = NextFile(ReadWalks)
					If File = "" Then Exit
					If File="." Or File=".." Then Continue
					If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides" + FolderSlash + File) = 1 then
						Self.LocalWalkList.Append(File)
					EndIf
				Forever
				CloseDir(ReadWalks)
			EndIf

			If Self.LocalWalkList.GetCount() = 0 then
				Self.LocalWalkList.Append("No Walkthroughs Found Locally")
				Self.LocalWalkList.Append("Use 'Download' tab to download some")
			EndIf

			If FileType(GAMEDATAFOLDER+GameNode.OrginalName+FolderSlash+"Manuals") = 2 Then
				ReadManuals = ReadDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash +"Manuals")
				Repeat
					File = NextFile(ReadManuals)
					If File = "" Then Exit
					If File="." Or File=".." Then Continue
					If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Manuals"+ FolderSlash + File) = 1 Then
						Self.LocalManualList.Append(File)
					EndIf
				Forever
				CloseDir(ReadManuals)
			EndIf

			If Self.LocalManualList.GetCount() = 0 then
				Self.LocalManualList.Append("No Manuals Found Locally")
				Self.LocalManualList.Append("Use 'Download' tab to download some")
			EndIf

			Self.DownloadSearchBox.ChangeValue(GameNode.Name)
			Self.GGenreText.SetLabel("Genre: " + CorrectText(GenreList) )
			Self.GDevText.SetLabel("Developer: " + CorrectText(GameNode.Dev) )
			Self.GPubText.SetLabel("Publisher: " + CorrectText(GameNode.Pub) )
			Self.GRDateText.SetLabel("Release Date: " + GetDateFromCorrectFormat(GameNode.ReleaseDate) )
			Self.GCertText.SetLabel("Certificate: " + CorrectText(GameNode.Cert) )
			Self.GCoopText.SetLabel("Co-Op: " + CorrectText(GameNode.Coop) )
			Self.GPlayersText.SetLabel("Players: " + CorrectText(GameNode.Players) )
			Self.GPlatText.SetLabel("Platform: " + CorrectText(GlobalPlatforms.GetPlatformByID(GameNode.PlatformNum).Name) )
			If String(GameNode.Rating) = "0" Then
				Self.GRatingCombo.SetValue("Select...")
			Else
				Self.GRatingCombo.SetValue(String(GameNode.Rating) )
			EndIf
			If GameNode.Completed = 1 Then
				Self.GCompletedCombo.SetValue("Yes")
			Else
				Self.GCompletedCombo.SetValue("No")
			EndIf


			If GameNode.Trailer = "" then
				'If Self.TrailerWeb.GetCurrentURL() = "file:///" + RESFOLDER + "NoTrailer.html" then

				'Else
					Self.TrailerWeb.LoadURL(RealPath(RESFOLDER + "NoTrailer.html") )
				'EndIf
			Else
				If Self.TrailerWeb.GetCurrentURL() = "https://www.youtube.com/embed/" + GameNode.Trailer then

				Else
					Self.TrailerWeb.LoadURL("https://www.youtube.com/embed/" + GameNode.Trailer)
				EndIf
			EndIf

			Self.GDPvbox.RecalcSizes()
			FBAPanel.Refresh()
			GS_SC1_Panel.Refresh()
			GS_SC2_Panel.Refresh()
			GameDetailsPanel.Refresh()
		EndIf

	End Method

	Function CorrectText:String(Text:String)
		Text = Replace(Text , "&" , "&&")
		Return Text
	End Function

	Function GameListUpdate(event:wxEvent)
		PrintF("----------------------------Updating Game List----------------------------")
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		SettingFile.SaveSetting("Sort" , GameExploreWin.SortCombo.GetValue())
		SettingFile.SaveSetting("Filter" , GameExploreWin.FilterTextBox.GetValue() )
		SettingFile.SaveSetting("Platform" , GameExploreWin.PlatformCombo.GetValue() )
		SettingFile.SaveFile()

		GameExploreWin.PopulateGameList()
	End Function


	Function FilterUpdate(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		GameExploreWin.FilterTimer.Stop()
		GameExploreWin.FilterTimer.Start(500, True)
	End Function

	Function FilterUpdate2(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		GameExploreWin.FilterTimer.Stop()
		GameExploreWin.FilterTimer.Start(100, True)
	End Function

	Method PopulateGameList()
		Local FIPixmap:TFreeImage
		Local Pixmap:TPixmap , Pixmap2:TPixmap
		Local Hor:Int , Ver:Int
		Local GameIconList:wxImageList
		GameRealPathList = CreateList()
		If GameListIconType = 4 Then
			If ShowIcons = 1 Then
				GameIconList = New wxImageList.Create(IconSize , Int(Float(IconSize)/BannerFloat) , True)
			Else
				GameIconList = New wxImageList.Create(1 , 1 , True)
			EndIf
		Else
			If ShowIcons = 1 Then
				GameIconList = New wxImageList.Create(IconSize , IconSize , True)
			Else
				GameIconList = New wxImageList.Create(1 , 1 , True)
			EndIf
		EndIf
		GameList.SetImageList(GameIconList , wxIMAGE_LIST_NORMAL)
		GameList.SetImageList(GameIconList , wxIMAGE_LIST_SMALL)
		If ShowIcons = 1 Then
			Select GameListIconType
				Case 1
					'FIPixmap = LoadFreeImage(RESFOLDER+"NoCover.jpg")
					'FIPixmap = FIPixmap.makeThumbnail(IconSize)

					'Ver = (IconSize - FIPixmap.Height) / 2
					'Hor = (IconSize - FIPixmap.Width) / 2

					'FIPixmap = FIPixmap.enlargeCanvas(Hor , Ver , Hor , Ver , New TRGBQuad.Create(255,81,237) , FICC_RGB)
					Pixmap = LoadPixmap(RESFOLDER+"NoCover.jpg") 'FIPixmap.GetPixmap()
					Pixmap = FitPixmapIntoBox(Pixmap,IconSize)

					Pixmap = MaskPixmap(Pixmap , 255,81,237)
					'Pixmap = ResizePixmap(Pixmap,IconSize,IconSize)
					GameIconList.Add( wxBitmap.CreateBitmapFromPixmap(Pixmap) )

				Case 3

					'FIPixmap = LoadFreeImage(RESFOLDER+"NoBack.jpg")

					'FIPixmap = FIPixmap.makeThumbnail(IconSize)

					'Hor = (IconSize - FIPixmap.Width) / 2
					'Ver = (IconSize - FIPixmap.Height) / 2

					'FIPixmap = FIPixmap.enlargeCanvas(Hor , Ver , Hor , Ver , New TRGBQuad.Create(255,81,237) , FICC_RGB)
					Pixmap = LoadPixmap(RESFOLDER+"NoBack.jpg")'FIPixmap.GetPixmap()
					Pixmap = FitPixmapIntoBox(Pixmap,IconSize)
					Pixmap = MaskPixmap(Pixmap , 255,81,237)
					'Pixmap = ResizePixmap(Pixmap,IconSize,IconSize)
					GameIconList.Add( wxBitmap.CreateBitmapFromPixmap(Pixmap) )
				Case 4
					'FIPixmap = LoadFreeImage(RESFOLDER+"NoBanner.png")
					'FIPixmap = FIPixmap.makeThumbnail(IconSize)

					'Hor = (IconSize - FIPixmap.Width) / 2
					'Ver = Int((Float(IconSize)/BannerFloat) - FIPixmap.Height) / 2

					'FIPixmap = FIPixmap.enlargeCanvas(Hor , Ver , Hor , Ver , New TRGBQuad.Create(255,81,237) , FICC_RGB)
					Pixmap = LoadPixmap(RESFOLDER+"NoBanner.png")'FIPixmap.GetPixmap()
					Pixmap = FitPixmapIntoBox(Pixmap,IconSize,Int(Float(IconSize)/BannerFloat))
					Pixmap = MaskPixmap(Pixmap , 255,81,237)
					'Pixmap = ResizePixmap(Pixmap,IconSize,Int(Float(IconSize)/BannerFloat))
					GameIconList.Add( wxBitmap.CreateBitmapFromPixmap(Pixmap) )
				Case 5
					GameIconList.AddIcon( wxIcon.CreateFromFile( RESFOLDER+"NoIcon.ico" , wxBITMAP_TYPE_ICO ) )
				Default
					CustomRuntimeError("Error 106: Invalid GameListIconType, default icon select") 'MARK: Error 106
			End Select
		EndIf

		PopulateTList()
		PrintF("Creating ListCtrl Columns")
		GameList.DeleteAllItems()
		GameList.DeleteColumn(0)
		Local itemCol:wxListItem = New wxListItem.Create()
		itemCol.SetText("Games")
		GameList.InsertColumnItem(0 , itemCol)
		Local GameLine:String
		Local LSI:Int = 0
		Local LSI_Icon:Int = 1
		Local GameNode:GameReadType
		GameNode = New GameReadType
		PrintF("Looping Through adding each game to list")
		For GameLine = EachIn GamesTList
			If GameNode.GetGame(GameLine) = - 1 Then

			Else
				PrintF("Game Not Null")
				If ShowIcons = 1 Then
					PrintF("Loading in Artork")
					Select GameListIconType
						Case 1

							If FileType(GAMEDATAFOLDER + GameLine + FolderSlash +"Front_OPT.jpg") = 1 Then
								'FIPixmap = LoadFreeImage(GAMEDATAFOLDER + GameLine + "\Front_THUMB.jpg")
								'FIPixmap = FIPixmap.makeThumbnail(IconSize)

								'Ver = (IconSize - FIPixmap.Height) / 2
								'Hor = (IconSize - FIPixmap.Width) / 2

								'FIPixmap = FIPixmap.enlargeCanvas(Hor , Ver , Hor , Ver , New TRGBQuad.Create(255,81,237) , FICC_RGB)
								Pixmap = LoadPixmap(GAMEDATAFOLDER + GameLine + FolderSlash + "Front_OPT.jpg")'FIPixmap.GetPixmap()

								Pixmap = FitPixmapIntoBox(Pixmap,IconSize)

								Pixmap = MaskPixmap(Pixmap , 255,81,237)
								'Pixmap = ResizePixmap(Pixmap,IconSize,IconSize)
								GameIconList.Add( wxBitmap.CreateBitmapFromPixmap(Pixmap) )
								If GameListText = 1 Then
									LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , LSI_Icon)
								Else
									LSI = GameList.InsertImageStringItem(LSI , Null , LSI_Icon)
								EndIf
								LSI_Icon = LSI_Icon + 1
								ListAddLast(GameRealPathList,GameLine)
							Else
								If GameListText = 1 Then
									LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , GenericArt)
								Else
									LSI = GameList.InsertImageStringItem(LSI , Null , GenericArt)
								EndIf
								ListAddLast(GameRealPathList,GameLine)
							EndIf
							'LSI = GameList.InsertImageItem(LSI , 0)
							If LSI = -1 Then CustomRuntimeError("Error 102: Unable to add "+GameLine+" To GameList") 'MARK: Error 102
							LSI = LSI + 1
						Case 3
							If FileType(GAMEDATAFOLDER + GameLine + FolderSlash +"Screen_OPT.jpg") = 1 Then
								'FIPixmap = LoadFreeImage(GAMEDATAFOLDER + GameLine + "\Screen_THUMB.jpg")
								'FIPixmap = FIPixmap.makeThumbnail(IconSize)

								'Ver = (IconSize - FIPixmap.Height) / 2
								'Hor = (IconSize - FIPixmap.Width) / 2

								'FIPixmap = FIPixmap.enlargeCanvas(Hor , Ver , Hor , Ver , New TRGBQuad.Create(255,81,237) , FICC_RGB)
								Pixmap = LoadPixmap(GAMEDATAFOLDER + GameLine + FolderSlash + "Screen_OPT.jpg")'FIPixmap.GetPixmap()

								Pixmap = FitPixmapIntoBox(Pixmap,IconSize)
								Pixmap = MaskPixmap(Pixmap , 255,81,237)
								'Pixmap = ResizePixmap(Pixmap,IconSize,IconSize)
								GameIconList.Add( wxBitmap.CreateBitmapFromPixmap(Pixmap))
								If GameListText = 1 Then
									LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , LSI_Icon)
								Else
									LSI = GameList.InsertImageStringItem(LSI , Null , LSI_Icon)
								EndIf
								LSI_Icon = LSI_Icon + 1
								ListAddLast(GameRealPathList,GameLine)
							Else
								If GameListText = 1 Then
									LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , GenericArt)
								Else
									LSI = GameList.InsertImageStringItem(LSI , Null , GenericArt)
								EndIf
								ListAddLast(GameRealPathList,GameLine)
							EndIf
							'LSI = GameList.InsertImageItem(LSI , 0)
							If LSI = -1 Then CustomRuntimeError("Error 102: Unable to add "+GameLine+" To GameList") 'MARK: Error 102
							LSI = LSI + 1
						Case 4
							If FileType(GAMEDATAFOLDER + GameLine + FolderSlash + "Banner_OPT.jpg") = 1 Then
								'FIPixmap = LoadFreeImage(GAMEDATAFOLDER + GameLine + "\Banner_THUMB.jpg")
								'FIPixmap = FIPixmap.makeThumbnail(IconSize)

								'Hor = (IconSize - FIPixmap.Width) / 2
								'Ver = (Int(Float(IconSize)/BannerFloat) - FIPixmap.Height) / 2

								'FIPixmap = FIPixmap.enlargeCanvas(Hor , Ver , Hor , Ver , New TRGBQuad.Create(255,81,237) , FICC_RGB)
								Pixmap = LoadPixmap(GAMEDATAFOLDER + GameLine + FolderSlash + "Banner_OPT.jpg")'FIPixmap.GetPixmap()

								Pixmap = FitPixmapIntoBox(Pixmap,IconSize,Int(Float(IconSize)/BannerFloat))
								Pixmap = MaskPixmap(Pixmap , 255,81,237)
								Pixmap = ResizePixmap(Pixmap,IconSize,Int(Float(IconSize)/BannerFloat))
								GameIconList.Add( wxBitmap.CreateBitmapFromPixmap(Pixmap))
								If GameListText = 1 Then
									LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , LSI_Icon)
								Else
									LSI = GameList.InsertImageStringItem(LSI , Null , LSI_Icon)
								EndIf
								LSI_Icon = LSI_Icon + 1
								ListAddLast(GameRealPathList,GameLine)
							Else
								If GameListText = 1 Then
									LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , GenericArt)
								Else
									LSI = GameList.InsertImageStringItem(LSI , Null , GenericArt)
								EndIf
								ListAddLast(GameRealPathList,GameLine)
							EndIf
							'LSI = GameList.InsertImageItem(LSI , 0)
							If LSI = -1 Then CustomRuntimeError("Error 102: Unable to add "+GameLine+" To GameList") 'MARK: Error 102
							LSI = LSI + 1
						Case 5
							If FileType(GAMEDATAFOLDER + GameLine + FolderSlash + "Icon.ico") = 1 Then
								GameIconList.AddIcon( wxIcon.CreateFromFile( GAMEDATAFOLDER + GameLine + FolderSlash + "Icon.ico" , wxBITMAP_TYPE_ICO ) )
								If GameListText = 1 Then
									LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , LSI_Icon)
								Else
									LSI = GameList.InsertImageStringItem(LSI , Null , LSI_Icon)
								EndIf
								LSI_Icon = LSI_Icon + 1
								ListAddLast(GameRealPathList,GameLine)
							Else
								If GameListText = 1 Then
									LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , GenericArt)
								Else
									LSI = GameList.InsertImageStringItem(LSI , Null , GenericArt)
								EndIf
								ListAddLast(GameRealPathList,GameLine)
							EndIf
							'LSI = GameList.InsertImageItem(LSI , 0)
							If LSI = -1 Then CustomRuntimeError("Error 102: Unable to add "+GameLine+" To GameList") 'MARK: Error 102
							LSI = LSI + 1
						Default
							CustomRuntimeError("Error 107: Invalid GameListIconType, icon load") 'MARK: Error 107
					End Select
					PrintF("Finished Loading in Artork")
				Else
					LSI = GameList.InsertStringItem(LSI , GameNode.Name)
					LSI_Icon = LSI_Icon + 1
					ListAddLast(GameRealPathList , GameLine)
					If LSI = - 1 Then CustomRuntimeError("Error 102: Unable to add " + GameLine + " To GameList") 'MARK: Error 102
					'GameList.SetItemImage(LSI , -1)
					LSI = LSI + 1
					Print GameNode.Name
				EndIf
			EndIf
		Next
		GameList.SetColumnWidth( 0 , wxLIST_AUTOSIZE )

		Self.RefreshWindow()
		wxSafeYield(Self)
		PrintF("PopulateGameList Complete")
	End Method

	Method PopulateTList()
		PrintF("PopulateTList Running")
		GamesTList = CreateList()
		Local GamesTSList:TList
		Local GameDir:Int
		Local item:String
		Local itemPlat:String
		Local itemDate:String
		Local itemDev:String
		Local itemPub:String
		Local itemGen:String
		Local itemScore:String
		Local SearchTerm:String
		Local InfoFile:TStream
		Local itemCompleted:String
		Local GameNode:GameReadType
		Local PlatformFilterType:String
		If PlatformCombo.GetSelection() = wxNOT_FOUND then
			PlatformFilterType = "All"
		Else
			PlatformFilterType = String(PlatformCombo.GetItemClientData(PlatformCombo.GetSelection() ) )
		EndIf
		PrintF("Platform: " + String(PlatformCombo.GetValue() ) )
		GameDir = ReadDir(GAMEDATAFOLDER)
		Local EvaluationGameNum = 0
		Repeat
			item$=NextFile(GameDir)
			If item = "." Or item = ".." Then Continue
			If item = "" Then Exit
			GameNode:GameReadType = New GameReadType
			If GameNode.GetGame(item) = - 1 Then

			Else
				If PlatformFilterType = "All" Or GameNode.PlatformNum = Int(PlatformFilterType) then
					ListAddLast(GamesTList, item)
					EvaluationGameNum = EvaluationGameNum + 1
					If EvaluationGameNum > 4 And EvaluationMode = True Then
						Exit
					EndIf
				EndIf
			EndIf

		Forever
		CloseDir(GameDir)
		PrintF("Sorting by: "+SortCombo.GetValue())
		Select SortCombo.GetValue()
			Case "Alphabetical - Ascending"
				PrintF("Alphabetical-A Sort")
				SortList(GamesTList,1)
			Case "Alphabetical - Descending"
				PrintF("Alphabetical-D Sort")
				SortList(GamesTList , 0)
			Default

				GamesTSList=CreateList()
				For item$ = EachIn GamesTList
					GameNode:GameReadType = New GameReadType
					If GameNode.GetGame(item) = - 1 Then

					Else
						Select SortCombo.GetValue()
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
								CustomRuntimeError("Error 103: SortCombo Get String Fail") 'MARK: Error 103
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
		End Select
		PrintF("Sort Applied")
		PrintF("Starting Filter")
		GamesTSList = CreateList()
		SearchTerm = FilterTextBox.GetLineText(1)
		SearchTerm = SearchTerm.ToLower()

		If Len(SearchTerm) = 1 Then
			For item$=EachIn GamesTList
				If Left(item.ToLower() , 1) = SearchTerm Then
					ListAddLast(GamesTSList,item)
				EndIf
			Next
		ElseIf Len(SearchTerm) = 0 Then
			For item$=EachIn GamesTList
				ListAddLast(GamesTSList,item)
			Next
		Else
			For item$=EachIn GamesTList
				For a=1 To Len(item)-Len(SearchTerm)
					If Mid(item.ToLower() , a , Len(SearchTerm) ) = SearchTerm Then
						ListAddLast(GamesTSList,item)
						Exit
					EndIf
				Next
			Next
		EndIf
		PrintF("Moving Filtered Games Back To Main List")
		GamesTList = CreateList()
		For item$ = EachIn GamesTSList
			ListAddLast(GamesTList,item)
		Next
		PrintF("PopulateTList Finished")
	End Method


End Type


Type ImagePanel Extends wxPanel
	Field Image:String[]
	Field Changed:Int
	Field ImageType:Int
	'1: Front
	'2: Back
	'3: Fanart
	'4: Banner
	'5: Icon

	Method OnInit()
		Image = New String[5]
		Changed = False
		ConnectAny(wxEVT_PAINT , OnPaint)
		ConnectAny( wxEVT_LEFT_DCLICK , ImageLeftClickedFun)
		ConnectANY( wxEVT_RIGHT_DOWN , ImageRightClickedFun)

		Connect(IP_M1_I1 , wxEVT_COMMAND_MENU_SELECTED , MenuClickFun , "1")
		Connect(IP_M1_I2 , wxEVT_COMMAND_MENU_SELECTED , MenuClickFun , "2")
		Connect(IP_M1_I3 , wxEVT_COMMAND_MENU_SELECTED , MenuClickFun , "3")
		Connect(IP_M1_I4 , wxEVT_COMMAND_MENU_SELECTED , MenuClickFun , "4")
		Connect(IP_M1_I5 , wxEVT_COMMAND_MENU_SELECTED , MenuClickFun , "5")
	End Method

	Method SetImageType(ImageT:Int)
		If ImageT > 5 Or ImageT < 1 Then
			CustomRuntimeError("Error 104: Wrong ImageType") 'MARK: Error 104
		EndIf
		ImageType = ImageT
		SettingFile.SaveSetting("SideArtType" , String(ImageType))
		SettingFile.SaveFile()
	End Method


	Method SetImage(Bitmap:String , IType:Int)
		Self.Image[IType - 1] = Bitmap

	End Method

	Function ImageLeftClickedFun(event:wxEvent)
		Local IPanel:ImagePanel = ImagePanel(event.parent)
		Local temp:String = IPanel.Image[IPanel.ImageType-1]
		If temp = "" Then

		Else
			If FileType(Left(temp, Len(temp) - 11) + ".jpg") = 1 then
				OpenURL(Left(temp , Len(temp) - 11) + ".jpg")
			ElseIf FileType(temp) = 1 then
				OpenURL(temp)
			Else

			EndIf
		EndIf
	End Function

	Function MenuClickFun(event:wxEvent)
		Local IPanel:ImagePanel = ImagePanel(event.parent)
		Local data:Object = event.userData
		Select String(data)
			Case "1"
				IPanel.SetImageType(1)
			Case "2"
				IPanel.SetImageType(2)
			Case "3"
				IPanel.SetImageType(3)
			Case "4"
				IPanel.SetImageType(4)
			Case "5"
				IPanel.SetImageType(5)
			Default
				CustomRuntimeError("Error 101: Invalid MenuClick Type") 'MARK: Error 101
		End Select
		IPanel.Refresh()
	End Function

	Function ImageRightClickedFun(event:wxEvent)
		Local IPanel:ImagePanel = ImagePanel(event.parent)
		Menu1:wxMenu = New wxMenu.Create("Artwork Menu")
		Menu1.Append(IP_M1_I1 , "Front Art")
		If IPanel.Image[0] = "" Then Menu1.Enable(IP_M1_I1 , False)
		Menu1.Append(IP_M1_I2 , "Back Art")
		If IPanel.Image[1] = "" Then Menu1.Enable(IP_M1_I2 , False)
		Menu1.Append(IP_M1_I3 , "Fan Art")
		If IPanel.Image[2] = "" Then Menu1.Enable(IP_M1_I3 , False)
		Menu1.Append(IP_M1_I4 , "Banner Art")
		If IPanel.Image[3] = "" Then Menu1.Enable(IP_M1_I4 , False)
		Menu1.Append(IP_M1_I5 , "Icon Art")
		If IPanel.Image[4] = "" Then Menu1.Enable(IP_M1_I5 , False)
		IPanel.PopupMenu(Menu1)
	End Function


	Function OnPaint(event:wxEvent)
		Local canvas:ImagePanel = ImagePanel(event.parent)

		canvas.Refresh()

		Local dc:wxPaintDC = New wxPaintDC.Create(canvas)
		canvas.PrepareDC(dc)
		Local x,x2,x3:Int
		Local y , y2 , y3:Int
		Local HWratio:Float
		Local WHratio:Float
		dc.Clear()
		canvas.GetClientSize(x,y)
		dc.SetBackground(New wxBrush.CreateFromColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3), wxTRANSPARENT) )
		dc.Clear()
		dc.SetTextForeground(New wxColour.Create(0,0,0))
		Local NoLen:Int, ArtworkLen:Int, FoundLen:Int
		If canvas.Image[canvas.ImageType - 1] = ""
			'dc.GetTextExtent("No Artwork Found" , x2 , y2)
			dc.GetTextExtent("No" , NoLen , y2)
			dc.GetTextExtent("Artwork" , ArtworkLen , y2)
			dc.GetTextExtent("Found" , FoundLen , y2)
			dc.DrawText("No" , x / 2 - NoLen / 2 , y / 2 - y2)
			dc.DrawText("Artwork" , x / 2 - ArtworkLen / 2 , y / 2)
			dc.DrawText("Found" , x / 2 - FoundLen / 2 , y / 2 +y2)
			'dc.DrawText("No Artwork Found",x/2-x2/2,y/2)
		ElseIf FileType(canvas.Image[canvas.ImageType - 1]) = 1

			Local ImageImg:wxImage
			Local ImageBit:wxBitmap
			Local ImagePix:TPixmap
			Local BlackBit:wxBitmap
			Local Drawx:Int
			Local Drawy:Int

			If Right(canvas.Image[canvas.ImageType - 1] , 3) = "ico" Then
				ImageImg = New wxImage.Create(canvas.Image[canvas.ImageType - 1] , wxBITMAP_TYPE_ICO)
				''ImageImg.SetMask(True)
				''ImageImg.SetMaskFromImage(ImageImg , 0 , 0 , 0)
				''ImageImg.SetMaskColour(240 , 240 , 240)
				ImageImg.Rescale(Min(x , y) , Min(x , y) )
				ImageBit = New wxBitmap.CreateFromImage(ImageImg)
				Drawx = (x - (Min(x , y) ) ) / 2
				Drawy = (y - (Min(x , y)) ) / 2
				''ImageBit.SetMask(New wxMask.Create(ImageBit,New wxColour.CreateNamedColour("Black")))

			Else
				ImagePix = LoadPixmap(canvas.Image[canvas.ImageType - 1])
				ImagePix = MaskPixmap(ImagePix , - 1 , - 1 , - 1)
				x3 = PixmapWidth(ImagePix)
				y3 = PixmapHeight(ImagePix)

				HWratio = Float(y3) / x3
				WHratio = Float(x3) / y3

				If HWratio*x < y Then
					ImagePix = ResizePixmap(ImagePix , x , HWratio * x)
					BlackBit = New wxBitmap.CreateEmpty(x , HWratio * x)
					BlackBit.Colourize(New wxColour.Create(0 , 0 , 0) )
					Drawx = 0
					Drawy = (y - (HWratio * x) ) / 2
				Else
					ImagePix = ResizePixmap(ImagePix , WHratio * y , y)
					BlackBit = New wxBitmap.CreateEmpty(WHratio * y , y)
					BlackBit.Colourize(New wxColour.Create(0 , 0 , 0) )
					Drawx = (x - (WHratio * y) ) / 2
					Drawy = 0
				EndIf

				ImageBit = New wxBitmap.CreateBitmapFromPixmap(ImagePix)
				'ImageBit.SetMask(New wxMask.Create(BlackBit,New wxColour.Create(255,255,255,255)))
				dc.DrawBitmap(BlackBit , Drawx , Drawy , False)

			EndIf

			dc.DrawBitmap(ImageBit, Drawx, Drawy, False)
		Else
			CustomRuntimeError("Error 105: Invalid Image File") 'MARK: Error 105
		EndIf
		dc.Free()
	End Function

End Type


Type ScreenShotPanel Extends wxPanel
	Field Image:String[]
	Field Changed:Int
	Field ImageType:Int
	'1: Front
	'2: Back
	'3: Fanart
	'4: Banner
	'5: Icon

	Method OnInit()
		Image = New String[5]
		Changed = False
		ConnectAny(wxEVT_PAINT , OnPaint)
		ConnectANY( wxEVT_LEFT_DCLICK , ImageLeftClickedFun)
	End Method

	Method SetImageType(ImageT:Int)
		If ImageT > 5 Or ImageT < 1 then
			CustomRuntimeError("Error 104: Wrong ImageType") 'MARK: Error 104
		EndIf
		ImageType = ImageT

	End Method

	Function ImageLeftClickedFun(event:wxEvent)
		Local IPanel:ScreenShotPanel = ScreenShotPanel(event.parent)
		Local temp:String = IPanel.Image[IPanel.ImageType - 1]
		If temp = "" then

		Else
			If FileType(Left(temp,Len(temp)-8)+".jpg") = 1 Then
				OpenURL(Left(temp , Len(temp) - 8) + ".jpg")
			ElseIf FileType(temp) = 1 Then
				OpenURL(temp)
			Else

			EndIf
		EndIf
	End Function

	Method SetImage(Bitmap:String , IType:Int)
		Self.Image[IType - 1] = Bitmap

	End Method

	Function OnPaint(event:wxEvent)

		Local canvas:ScreenShotPanel = ScreenShotPanel(event.parent)

		canvas.Refresh()

		Local dc:wxPaintDC = New wxPaintDC.Create(canvas)
		canvas.PrepareDC(dc)
		Local x,x2,x3:Int
		Local y , y2 , y3:Int
		Local HWratio:Float
		Local WHratio:Float
		dc.Clear()

		canvas.GetClientSize(x,y)
		dc.SetBackground(New wxBrush.CreateFromColour(New wxColour.Create(PERed3, PEGreen3, PEBlue3), wxSOLID) )
		dc.Clear()
		dc.SetTextForeground(New wxColour.Create(0, 0, 0) )
		Local NoLen:Int, ArtworkLen:Int, FoundLen:Int
		If canvas.Image[canvas.ImageType - 1] = ""
			'dc.GetTextExtent("No Artwork Found" , x2 , y2)
			dc.GetTextExtent("No" , NoLen , y2)
			dc.GetTextExtent("Artwork" , ArtworkLen , y2)
			dc.GetTextExtent("Found" , FoundLen , y2)
			dc.DrawText("No" , x / 2 - NoLen / 2 , y / 2 - y2)
			dc.DrawText("Artwork" , x / 2 - ArtworkLen / 2 , y / 2)
			dc.DrawText("Found" , x / 2 - FoundLen / 2 , y / 2 +y2)
			'dc.DrawText("No Artwork Found",x/2-x2/2,y/2)
		ElseIf FileType(canvas.Image[canvas.ImageType - 1]) = 1

			Local ImageImg:wxImage
			Local ImageBit:wxBitmap
			Local ImagePix:TPixmap
			Local BlackBit:wxBitmap
			Local Drawx:Int
			Local Drawy:Int

			If Right(canvas.Image[canvas.ImageType - 1] , 3) = "ico" Then
				ImageImg = New wxImage.Create(canvas.Image[canvas.ImageType - 1] , wxBITMAP_TYPE_ICO)
				''ImageImg.SetMask(True)
				''ImageImg.SetMaskFromImage(ImageImg , 0 , 0 , 0)
				''ImageImg.SetMaskColour(240 , 240 , 240)
				ImageImg.Rescale(Min(x , y) , Min(x , y) )
				ImageBit = New wxBitmap.CreateFromImage(ImageImg)
				Drawx = (x - (Min(x , y) ) ) / 2
				Drawy = (y - (Min(x , y)) ) / 2
				''ImageBit.SetMask(New wxMask.Create(ImageBit,New wxColour.CreateNamedColour("Black")))

			Else
				ImagePix = LoadPixmap(canvas.Image[canvas.ImageType - 1])
				ImagePix = MaskPixmap(ImagePix , - 1 , - 1 , - 1)
				x3 = PixmapWidth(ImagePix)
				y3 = PixmapHeight(ImagePix)

				HWratio = Float(y3) / x3
				WHratio = Float(x3) / y3

				If HWratio * x < y then
					ImagePix = ResizePixmap(ImagePix , x , HWratio * x)
					BlackBit = New wxBitmap.CreateEmpty(x , HWratio * x)
					BlackBit.Colourize(New wxColour.Create(0 , 0 , 0) )
					Drawx = 0
					Drawy = (y - (HWratio * x) ) / 2
				Else
					ImagePix = ResizePixmap(ImagePix , WHratio * y , y)
					BlackBit = New wxBitmap.CreateEmpty(WHratio * y , y)
					BlackBit.Colourize(New wxColour.Create(0 , 0 , 0) )
					Drawx = (x - (WHratio * y) ) / 2
					Drawy = 0
				EndIf

				ImageBit = New wxBitmap.CreateBitmapFromPixmap(ImagePix)
				'ImageBit.SetMask(New wxMask.Create(BlackBit,New wxColour.Create(255,255,255,255)))
				dc.DrawBitmap(BlackBit , Drawx , Drawy , False)

			EndIf

			dc.DrawBitmap(ImageBit, Drawx, Drawy, False)
		Else
			CustomRuntimeError("Error 105: Invalid Image File") 'MARK: Error 105
		EndIf
		dc.free()
	End Function

End Type

Type DownloadWindow Extends wxFrame {expose disablenew}
	Field LogBox:wxTextCtrl
	Field LogClosed:int
	Field DownloadFinished:int
	Field SubProgress:wxGauge
	Field Progress:wxGauge

	Field ClientData:String
	Field LuaFile:String
	Field FName:String
	Field GName:String
	Field GameFolderDownloadName:String

	?Threaded
	Field Thread:TThread
	?

	Method Finish()
		Self.DownloadFinished = True
		If LogClosed = True then
			Self.AddText("Operation aborted by user")
			Delay(3000)
			Self.Destroy()
			Return
		EndIf
		Self.AddText("Finished")
		Self.AddText("~nYou may now close this window and you will find your download in the relevant tab")
		Self.Raise()
		Self.SetFocus()
	End Method

	Method OnInit()

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		LogClosed = False


		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		LogBox = New wxTextCtrl.Create(Self, wxID_ANY, "", - 1 , - 1 , - 1 , - 1, wxTE_READONLY | wxTE_MULTILINE | wxTE_BESTWRAP)

		Progress = New wxGauge.Create(Self, wxID_ANY, 100, - 1, - 1, - 1, - 1, wxGA_HORIZONTAL | wxGA_SMOOTH)
		SubProgress = New wxGauge.Create(Self, wxID_ANY, 100, - 1, - 1, - 1, - 1, wxGA_HORIZONTAL | wxGA_SMOOTH)

		hbox.Add(LogBox, 1 , wxEXPAND, 0)
		hbox.Add(SubProgress, 0 , wxEXPAND, 0)
		hbox.Add(Progress, 0 , wxEXPAND, 0)

		SetSizer(hbox)
		Centre()


		Self.Progress.SetValue(0)
		Self.SubProgress.SetValue(0)

		Show(0)
		LogClosed = False

		ConnectAny(wxEVT_CLOSE , CloseLog)
	End Method

	Method SetSubGauge(Percentage:Int)
		Self.SubProgress.SetValue(Percentage)
	End Method

	Method PulseSubGauge()
		Self.SubProgress.Pulse()
	End Method

	Method SetGauge(Percentage:Int)
		Self.Progress.SetValue(Percentage)
	End Method

	Method PulseGauge()
		Self.Progress.Pulse()
	End Method

	Function CloseLog(event:wxEvent)
		LogWin:DownloadWindow = DownloadWindow(event.parent)
		If LogWin.DownloadFinished = True then
			LogWin.Destroy()
		Else
			LogWin.LogClosed = True
			LogWin.AddText("Cancelling..")
		EndIf
	End Function

	Method AddText(Tex:String)
		Self.LogBox.AppendText(Tex + Chr(10) )
	End Method
End Type

Function ReturnTagInfo$(SearchLine$,Tag$,EndTag$,Debug=False)
	Rem
	Function:	Finds first instance of Tag and EndTag in SearchLine and returns the characters inbetween
			Sets CurrentSearchLine to the rest of SearchLine(Bit not containing Tag/EndTag)
	Input:	SearchLine - The String to search within
			Tag - The start term
			EndTag - The end term
	Return:	The string containing the characters between tags
	SubCalls:	None
	EndRem
	If Debug Then
		Print SearchLine
		Print Tag
		Print EndTag
	EndIf
	StartPos=0
	EndPos=0
	Found=False
	For a=1 To Len(SearchLine)
		If Mid(SearchLine,a,Len(Tag))=Tag$ Then
			StartPos=a+Len(Tag)
			If Debug Then Print StartPos
			Found=True
			Exit
		EndIf
	Next
	If Found=True Then
		For a=1 To Len(SearchLine)-StartPos
			If Mid(SearchLine,a+StartPos,Len(EndTag))=EndTag$ Then
				EndPos=a+StartPos
				If Debug Then Print EndPos
				CurrentSearchLine=Right(SearchLine,Len(SearchLine)-EndPos)
				Exit
			EndIf
		Next
	EndIf
	Return Mid(SearchLine,StartPos,EndPos-StartPos)
End Function


Function TimeoutCallback:Int(data:Object , dltotal:Double , dlnow:Double , ultotal:Double , ulnow:Double)
	If MilliSecs() - InternetTimeout > 10000 Then
		Return 1
	EndIf
	Return 0
End Function

Function GetGFAQsCode:Int(Code:Int)
	Select Code
		Case 0
		Return 0
		Case 1
		Return 1068
		Case 2
		Return 1026
		Case 3
		Return 1049
		Case 4
		Return 1025
		Case 5
		Return 5
		Case 6
		Return 7
		Case 7
		Return 1028
		Case 8
		Return 1069
		Case 9
		Return 1031
		Case 10
		Return 1070
		Case 11
		Return 1029
		Case 12
		Return 15
		Case 13
		Return 1058
		Case 14
		Return 1042
		Case 15
		Return 24
		Case 16
		Return 1059
		Case 17
		Return 1035
		Case 18
		Return 1061
		Case 19
		Return 1020
		Case 20
		Return 25
		Case 21
		Return 26
		Case 22
		Return 27
		Case 23
		Return 1021
		Case 24
		Return 28
		Case 25
		Return 29
		Case 26
		Return 30
		Case 27
		Return 31
		Case 28
		Return 1034
		Case 29
		Return 1052
		Case 30
		Return 1053
		Case 31
		Return 32
		Case 32
		Return 1063
		Case 33
		Return 1060
		Case 34
		Return 1056
		Case 35
		Return 33
		Case 36
		Return 34
		Case 37
		Return 35
		Case 38
		Return 36
		Case 39
		Return 1038
		Case 40
		Return 1044
		Case 41
		Return 1048
		Case 42
		Return 1
		Case 43
		Return 1023
		Case 44
		Return 1013
		Case 45
		Return 1040
		Case 46
		Return 1008
		Case 47
		Return 1064
		Case 48
		Return 1041
		Case 49
		Return 1055
		Case 50
		Return 2
		Case 51
		Return 12
		Case 52
		Return 9
		Case 53
		Return 38
		Case 54
		Return 11
		Case 55
		Return 16
		Case 56
		Return 10
		Case 57
		Return 1030
		Case 58
		Return 37
		Case 59
		Return 39
		Case 60
		Return 1047
		Case 61
		Return 17
		Case 62
		Return 1004
		Case 63
		Return 1046
		Case 64
		Return 40
		Case 65
		Return 42
		Case 66
		Return 1039
		Case 67
		Return 43
		Case 68
		Return 41
		Case 69
		Return 1006
		Case 70
		Return 1065
		Case 71
		Return 1033
		Case 72
		Return 1007
		Case 73
		Return 18
		Case 74
		Return 3
		Case 75
		Return 19
		Case 76
		Return 4
		Case 77
		Return 1012
		Case 78
		Return 14
		Case 79
		Return 1011
		Case 80
		Return 44
		Case 81
		Return 1010
		Case 82
		Return 1037
		Case 83
		Return 1018
		Case 84
		Return 1015
		Case 85
		Return 1062
		Case 86
		Return 45
		Case 87
		Return 1009
		Case 88
		Return 46
		Case 89
		Return 6
		Case 90
		Return 1024
		Case 91
		Return 1045
		Case 92
		Return 1019
		Case 93
		Return 8
		Case 94
		Return 1003
		Case 95
		Return 1002
		Case 96
		Return 20
		Case 97
		Return 1017
		Case 98
		Return 1066
		Case 99
		Return 1032
		Case 100
		Return 1050
		Case 101
		Return 21
		Case 102
		Return 1054
		Case 103
		Return 1057
		Case 104
		Return 1043
		Case 105
		Return 1036
		Case 106
		Return 1051
		Case 107
		Return 1005
		Case 108
		Return 22
		Case 109
		Return 47
		Case 110
		Return 49
		Case 111
		Return 48
		Case 112
		Return 50
		Case 113
		Return 1014
		Case 114
		Return 1022
		Case 115
		Return 23
		Case 116
		Return 13
		Case 117
		Return 1067
		Case 118
		Return 1027
		Default
		CustomRuntimeError("Error 109: Invalid GFAQS Code") 'MARK: Error 109
	End Select
End Function

Function LoadGlobalSettings()
	ReadSettings:SettingsType = New SettingsType
	ReadSettings.ParseFile(SETTINGSFOLDER + "GeneralSettings.xml" , "GeneralSettings")
	If ReadSettings.GetSetting("Country")<>"" Then
		Country = ReadSettings.GetSetting("Country")
	EndIf
	If ReadSettings.GetSetting("PGMOff")<>"" Then
		PerminantPGMOff = Int(ReadSettings.GetSetting("PGMOff") )
	EndIf
	If ReadSettings.GetSetting("SilentRunOff") <> "" Then
		SilentRunnerEnabled = Int(ReadSettings.GetSetting("SilentRunOff"))
	EndIf
	If ReadSettings.GetSetting("Cabinate") <> "" Then
		CabinateEnable = Int(ReadSettings.GetSetting("Cabinate") )
	EndIf
	If ReadSettings.GetSetting("RunnerButtonCloseOnly") <> "" Then
		RunnerButtonCloseOnly = Int(ReadSettings.GetSetting("RunnerButtonCloseOnly"))
	EndIf
	If ReadSettings.GetSetting("OriginWaitEnabled") <> "" then
		OriginWaitEnabled = Int(ReadSettings.GetSetting("OriginWaitEnabled") )
	EndIf
	If ReadSettings.GetSetting("DebugLogEnabled") <> "" then
		If Int(ReadSettings.GetSetting("DebugLogEnabled") ) = 1 then
			DebugLogEnabled = 1
		EndIf
	EndIf
	ReadSettings.CloseFile()
End Function

Function FitPixmapIntoBox:TPixmap(Pixmap:TPixmap, IconSize:Int, Banner:Int = - 1)
	Local Pixmap2:TPixmap
	If Banner = -1 Then

		If Float(Pixmap.Height)/Pixmap.Width > 1 Then
			Pixmap = ResizePixmap(Pixmap,IconSize*Float(Pixmap.Width)/Pixmap.Height,IconSize)
		ElseIf Float(Pixmap.Width)/Pixmap.Height > 1
			Pixmap = ResizePixmap(Pixmap,IconSize,IconSize*Float(Pixmap.Height)/Pixmap.Width)
		Else
			Pixmap = ResizePixmap(Pixmap,IconSize,IconSize)
		EndIf

		Pixmap2 = CreatePixmap(IconSize,IconSize,5)
		ClearPixels(Pixmap2, - 44563)
		Pixmap2.Paste(Pixmap,(IconSize-Pixmap.Width)/2,(IconSize-Pixmap.Height)/2)
		Return Pixmap2

	Else
		If IconSize*Float(Pixmap.Height)/Pixmap.Width > Banner Then
			Pixmap = ResizePixmap(Pixmap,IconSize*Float(Pixmap.Width)/Pixmap.Height,Banner)
		ElseIf IconSize*Float(Pixmap.Width)/Pixmap.Height > IconSize
			Pixmap = ResizePixmap(Pixmap,IconSize,IconSize*Float(Pixmap.Height)/Pixmap.Width)
		Else
			Pixmap = ResizePixmap(Pixmap,IconSize,Banner)
		EndIf

		Pixmap2 = CreatePixmap(IconSize,Banner,5)
		ClearPixels(Pixmap2,-44563)
		Pixmap2.Paste(Pixmap,0,0)
		Return Pixmap2
	EndIf
End Function

Function WindowsCheck()
	?Win32
	WinDir = GetEnv("WINDIR")
	PrintF("Windows Folder: " + WinDir)

	If wxIsPlatform64Bit() = 1 then
		PrintF("Detected 64bit")
		WinBit = 64
	Else
		PrintF("Detected 32bit")
		WinBit = 32
	EndIf

	Local OSMajor:Int
	Local OSMinor:Int
	wxGetOsVersion(OSMajor, OSMinor)

	PrintF("Detected Win Version: " + OSMajor + "." + OSMinor)

	If OSMajor => 6 Then
		WinExplorer = True
	Else
		WinExplorer = False
	EndIf
	?Not Win32
		WinExplorer = False
	?

End Function

Function Thread_Download:Object(Obj:Object)
	Local DownloadBox:DownloadWindow = DownloadWindow(Obj)

	DownloadBox.AddText("Downloading " + DownloadBox.FName + " for game " + DownloadBox.GName)
	DownloadBox.AddText("")

	Local LocalLuaVM:Byte Ptr
	LocalLuaVM = luaL_newstate()
	Local LocalLuaInternet = LuaInternetType(New LuaInternetType.Create(DownloadBox) )
	Local LocalLuaFileList:LuaListType = New LuaListType.Create()

	InitLuGI(LocalLuaVM)
	luaL_openlibs(LocalLuaVM)

	Local Result:Int
	Local MessageBox:wxMessageDialog
	Local line:String
	Local Source:String = ""

	If DownloadBox.LuaFile <> Null then
		Local LuaSourceFile:TStream = ReadFile(DownloadBox.LuaFile)
		If LuaSourceFile = Null then
			PrintF("Lua File Error: ~n" + "Could not open Lua file for reading (" + DownloadBox.LuaFile + ")")
			DownloadBox.AddText("Lua File Error: ~n" + "Could not open Lua file for reading (" + DownloadBox.LuaFile + ")")
			'MessageBox = New wxMessageDialog.Create(Null , "Lua File Error: ~n" + "Could not open Lua file for reading (" + DownloadBox.LuaFile + ")" , "Error" , wxOK | wxICON_EXCLAMATION)
			'MessageBox.ShowModal()
			'MessageBox.Free()
			DownloadBox.Finish()
			Return
		EndIf
		Repeat
			line = ReadLine(LuaSourceFile)
			Source = Source + line + "~n~r"
			If Eof(LuaSourceFile) then Exit
		Forever
		CloseFile(LuaSourceFile)
	EndIf

	Result = luaL_loadstring(LocalLuaVM, Source)
	If (Result <> 0) then
		PrintF("Lua Compile Error: ~n" + luaL_checkstring(LocalLuaVM, - 1) )
		DownloadBox.AddText("Lua Compile Error: ~n" + luaL_checkstring(LocalLuaVM, - 1) )
		'MessageBox = New wxMessageDialog.Create(Null , "Lua Compile Error: ~n" + luaL_checkstring(LocalLuaVM, - 1) , "Error" , wxOK | wxICON_EXCLAMATION)
		'MessageBox.ShowModal()
		'MessageBox.Free()
		LuaHelper_CleanStack( LocalLuaVM )
		DownloadBox.Finish()
		Return
	End If

	lua_pcall(LocalLuaVM, 1, - 1, - 1)

	Local ErrorMessage:String

	lua_getfield(LocalLuaVM, LUA_GLOBALSINDEX, "Get")
	lua_pushbmaxobject( LocalLuaVM, LocalLuaFileList )
	lua_pushbmaxobject( LocalLuaVM, LocalLuaInternet )
	lua_pushbmaxobject( LocalLuaVM, DownloadBox.ClientData )
	lua_pushbmaxobject( LocalLuaVM, DownloadBox )

	Result = lua_pcall(LocalLuaVM, 4, 3, 0)

	If (Result <> 0) then
		ErrorMessage = luaL_checkstring(LocalLuaVM, - 1)
		DownloadBox.AddText("Lua Run Error: ~n" + ErrorMessage)
		PrintF("Lua Run Error: ~n" + ErrorMessage)
		'MessageBox = New wxMessageDialog.Create(Null , "Lua Run Error: ~n" + ErrorMessage , "Error" , wxOK | wxICON_EXCLAMATION)
		'MessageBox.ShowModal()
		'MessageBox.Free()
		LuaHelper_CleanStack(LocalLuaVM)
		DownloadBox.Finish()
		Return
	EndIf

	If lua_isnumber(LocalLuaVM, 1) = False then
		Error = 198
	Else
		Error = luaL_checkint( LocalLuaVM, 1 )
	EndIf

	If Error <> 0 then
		If lua_isstring(LocalLuaVM, 2) = False Or lua_isnumber(LocalLuaVM, 1) = False then
			ErrorMessage = "Lua code did not return int @1 or/and string @2"
		Else
			ErrorMessage = luaL_checkstring(LocalLuaVM , 2)
		EndIf
		If ErrorMessage = "Operation was aborted by an application callback" then ErrorMessage = "Internet operation timeout"
		PrintF("Lua function returned error code: " + Error + " with message: " + ErrorMessage)
		DownloadBox.AddText("Lua function returned error code: " + Error + " with message: " + ErrorMessage)
		LuaHelper_CleanStack(LocalLuaVM)
		DownloadBox.Finish()
		Return
	EndIf

	If lua_isbmaxobject(LocalLuaVM, 3) = False then
		PrintF("Lua function returned error code: 199 with message: Lua code did not return correct object @3")
		DownloadBox.AddText("Lua function returned error code: 199 with message: Lua code did not return correct object @3")
		LuaHelper_CleanStack(LocalLuaVM)
		DownloadBox.Finish()
		Return
	EndIf

	LuaHelper_CleanStack(LocalLuaVM)
	lua_close(LocalLuaVM)

	'Run through Lua File list and move them to correct place
	Local FileName:String
	For LuaFile:LuaListItemType = EachIn LocalLuaFileList.List
		If LuaFile.ClientData = "" Or LuaFile.ClientData = Null then
			If LuaFile.ItemName = "" Or LuaFile.ItemName = Null then

			Else
				FileName = StripDir(LuaFile.ItemName)
			EndIf
		Else
			FileName = StripDir(FileNameFilter(LuaFile.ClientData, False) )
		EndIf
		If LuaFile.ItemName = "" Or LuaFile.ItemName = Null Or FileType(LuaFile.ItemName) = 0 then
			PrintF("Lua returned invalid download item ~nItem: "+LuaFile.ItemName+" ~nData:"+LuaFile.ClientData)
			DownloadBox.AddText("Lua returned invalid download item ~nItem: " + LuaFile.ItemName + " ~nData:" + LuaFile.ClientData)
			DownloadBox.Finish()
			Return
		EndIf

		Local FileName2:String = ""
		Local a:Int = 2

		If Right(DownloadBox.GameFolderDownloadName, Len("Patches" + FolderSlash) ) = "Patches" + FolderSlash then
			'Check game doesnt already have folder with same name
			FileName = StripExt(FileName)
			If FileType(DownloadBox.GameFolderDownloadName + FileName) = 2 then
				FileName2 = FileName
				FileName = FileName2 + "(" + String(a) + ")"
			EndIf
			Repeat
				If FileType(DownloadBox.GameFolderDownloadName + FileName) = 2 then
					a = a + 1
					FileName = FileName2 + "(" + String(a) + ")"
				Else
					DownloadBox.AddText("Extracting: " + FileName)
					Extract(LuaFile.ItemName, DownloadBox.GameFolderDownloadName + FileName + FolderSlash)
					Exit
				EndIf
			Forever
		Else
			'Check game doesnt already have file with same name
			If FileType(DownloadBox.GameFolderDownloadName + FileName) = 1 then
				FileName2 = FileName
				FileName = StripExt(FileName2) + "(" + String(a) + ")." + ExtractExt(FileName2)
			EndIf
			Repeat
				If FileType(DownloadBox.GameFolderDownloadName + FileName) = 1 then
					a = a + 1
					FileName = StripExt(FileName2) + "(" + String(a) + ")." + ExtractExt(FileName2)
				Else
					DownloadBox.AddText("Moving: " + FileName)
					CopyFile(LuaFile.ItemName, DownloadBox.GameFolderDownloadName + FileName)
					Exit
				EndIf
			Forever
		EndIf
	Next

	DownloadBox.Finish()

End Function

Include "Includes\General\ValidationFunctions.bmx"
Include "Includes\General\General.bmx"
Include "Includes\General\LuaFunctions.bmx"
Include "Includes\GameExplorerShell\LuaFunctions.bmx"
Include "Includes\General\Compress.bmx"
Include "Includes\General\SplashApp.bmx"
