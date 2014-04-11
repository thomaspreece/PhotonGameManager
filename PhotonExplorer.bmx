
'TODO PhotonRunner to Use Steam API to tell if steam game over

'NOTHING IMPORTANT HERE
'All subfiles checked, no pending fixes found

'FIX: Steam ScreenShots!
'FIX: Sort list by relavence (SearchPatch_PScrolls)
'FIX: Sort list by relavence(SearchManual_RDocs)
'FIX: Search in relievent category(SearchManual_RDocs)

'END OF NOTHING IMPORTANT HERE

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

'Media Control Requires Ubunutu Restricted Access To Compile, libgstreamer-plugins-base0.10-dev, libgstreamer0.10-dev
?Win32
Import wx.wxMediaCtrl
?
Import wx.wxTimer
Import wx.wxListBox
'Import wx.wxGenericDirCtrl
Import wx.wxTaskBarIcon

Import Bah.libxml
Import BaH.libcurlssl
Import Bah.Volumes

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
'Import BRL.LinkedList
Import BRL.System
'Import BRL.StandardIO

?Not Win32
Global FolderSlash:String ="/"

?Win32
Import "Icons\PhotonExplorer.o"
Global FolderSlash:String ="\"
?

Local TempFolderPath:String
If FileType("SaveLocationOverride.txt") = 1 Then 
	ReadLocationOverride = ReadFile("SaveLocationOverride.txt")
	TempFolderPath = ReadLine(ReadLocationOverride)
	CloseFile(ReadLocationOverride)
	If Right(TempFolderPath,1)=FolderSlash Then 
	
	Else
		TempFolderPath = TempFolderPath + FolderSlash
	EndIf 
Else
	If FileType(GetUserDocumentsDir()+FolderSlash+"GameManagerV4") <> 2 Then 
		CreateFolder(GetUserDocumentsDir()+FolderSlash+"GameManagerV4")
	EndIf 
	TempFolderPath = GetUserDocumentsDir()+FolderSlash+"GameManagerV4"+FolderSlash
EndIf 

Include "Includes\General\GlobalConsts.bmx"
Include "Includes\GameExplorerShell\GlobalConsts.bmx"

If FileType("DebugLog.txt")=1 Then 
	DebugLogEnabled = True
EndIf 


FolderCheck()
LogName = "ExplorerPreFile"+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
CreateFile(LOGFOLDER+LogName)

AppTitle = "Photon GameManager"

Local ArguemntNo:Int = 0
Local RunnerEXENumber:Int
Local RunnerGameName:String
Local ProgramMode:Int = 1

'Mode = 1 NORMAL MODE
'Mode = 2 RUNNER MODE ONLY
'Mode = 3 TRAY APP



CheckKey()
If EvaluationMode = True Then 
	Notify "You are running in evaluation mode, this limits you to 5 games."
EndIf 




LoadGlobalSettings()
SettingFile.ParseFile(SETTINGSFOLDER+"PhotonExplorer.xml")

'Local GameName:String
'Local EXENum:Int
ProgramMode = 1
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
		Case "-Tray","Tray"
			'Rem
			If Int(Argument) = 1 Then 
				ProgramMode = 3
			EndIf 
			PastArgument = ""
			'EndRem
		Case "-Runner","Runner"
			If Int(Argument) = 1 Then 
				ProgramMode = 2
			EndIf 
			PastArgument = ""	
		Case "-GameName","GameName"
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
				Case "-Tray" , "-Debug" , "-Runner" , "-GameName" , "-EXENum" , "-Game" , "-GameTab", "-Cabinate", "Tray" , "Debug" , "Runner" , "GameName" , "EXENum" , "Game" , "GameTab", "Cabinate"
					PastArgument = Argument
			End Select
	End Select
Next

If DebugLogEnabled=False Then 
	DeleteFile(LOGFOLDER+LogName)
EndIf 

Select ProgramMode
	Case 1
		LogName = "Log-Explorer-MainApp"+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
	Case 2
		LogName = "Log-Explorer-PhotonRunner"+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
	Case 3
		LogName = "Log-Explorer-Tray"+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
	Default 
		LogName = "Log-Explorer-Default"+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
End Select
CreateFile(LOGFOLDER+LogName)

?Win32
WinDir = GetEnv("WINDIR")
PrintF("Windows Folder: " + WinDir)
?

PlatformListChecks()

If wxIsPlatform64Bit() = 1 Then
	PrintF("Detected 64bit")
	WinBit = 64
Else
	PrintF("Detected 32bit")
	WinBit = 32
EndIf

Global GameExplorerApp:GameExplorerShell
Global PhotonRunnerApp:PhotonRunner
Global PhotonTrayApp:PhotonTray

LoadSettings()


If ProgramMode = 1 Then 
	CheckInternet()
	CheckVersion()
	GameExplorerApp = New GameExplorerShell
	GameExplorerApp.Run()
EndIf

If ProgramMode = 2 Then
	'If ArgumentNo < 4 Then
	'	Notify "Not enough arguments"
	'	End
	'EndIf
	If FileType(GAMEDATAFOLDER + RunnerGameName) <> 2 Then
		Notify "Invalid Game"
		End
	EndIf 
	PhotonRunnerApp = New PhotonRunner
	PhotonRunnerApp.SetGame(RunnerGameName , RunnerEXENumber)
	PhotonRunnerApp.Run()
EndIf

If ProgramMode = 3 Then 
	PhotonTrayApp = New PhotonTray
	PhotonTrayApp.Run()
EndIf


SettingFile.CloseFile()
Print "Close"
If CmdLineGameName <> "" Then 
	RunProcess("FrontEnd.exe",1)
EndIf 
End


Function LoadSettings()
	Select SettingFile.GetSetting("ListType")
		Case "1"
			GameListStyle = wxLC_ICON | wxSUNKEN_BORDER | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE
			ShowIcons = 1
		Case "2"
			GameListStyle = wxLC_LIST | wxSUNKEN_BORDER | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE
			ShowIcons = 1						
		Case "3"
			GameListStyle = wxLC_LIST | wxSUNKEN_BORDER | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE					
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









Type GameExplorerShell Extends wxApp 
	Field Menu:GameExplorerFrame
	Method OnInit:Int()
		wxImage.AddHandler( New wxICOHandler)		
		'wxImage.AddHandler( New wxPNGHandler)		
		'wxImage.AddHandler( New wxJPEGHandler)
		'wxImage.AddHandler( New wxJPEGHandler)			
		Menu = GameExplorerFrame(New GameExplorerFrame.Create(Null , GES, "PhotonExplorer", -1, -1, 800, 600))
		Return True

	End Method
	
End Type

Type GameExplorerFrame Extends wxFrame
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
	?Win32
	Field TrailerCtrl:wxMediaCtrl
	?
	Field GCompletedCombo:wxComboBox
	Field GRatingCombo:wxComboBox	
	
	Field PatchTList:TList
	Field ManualTList:TList
	Field WalkTList:TList
	Field CheatTList:TList
	
	Field GS_SC1_Panel:ScreenShotPanel
	Field GS_SC2_Panel:ScreenShotPanel

	Field GDPvbox:wxBoxSizer
	
	Field PatchSearchBox:wxTextCtrl
	Field PatchList:wxListBox
	Field LocalPatchList:wxListBox
	Field LocalPatchFileList:wxListBox
	
	Field LocalManualList:wxListBox
	Field ManualSearchBox:wxTextCtrl
	Field ManualList:wxListBox	
	
	Field LocalWalkList:wxListBox
	Field LocalWalkFileList:wxListBox
	Field WalkSearchBox:wxTextCtrl
	Field WalkList:wxListBox	
	Field WalkSearchCatBox:wxComboBox
	
	Field LocalCheatList:wxListBox
	Field CheatSearchCatBox:wxComboBox
	Field CheatSearchBox:wxTextCtrl
	Field CheatList:wxListBox	
		
	Field SubMenu1:wxMenu
	Field SubMenu2:wxMenu
	Field SubMenu3:wxMenu
	Field SubMenu4:wxMenu
	Field SubMenu5:wxMenu	
	
	Field StartupRefreshTimer:wxTimer 
	Field StartupRefreshTimer2:wxTimer	
	Field StartupRefreshTimer3:wxTimer
	
	Method OnInit()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		Self.maximize(1)
		
		Self.SetBackgroundColour(New wxColour.Create(MainColor_R,MainColor_G,MainColor_B))		

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
		
		?Linux
		ConnectAny(wxEVT_CLOSE , ExitFun)
		?
		Local MainMenu:wxMenu = New wxMenu.Create()
		MainMenu.AppendMenu(wxID_ANY , "List Type" , SubMenu1)
		MainMenu.AppendMenu(wxID_ANY , "Icon Type" , SubMenu2)
		MainMenu.AppendMenu(wxID_ANY , "Icon Size" , SubMenu3)
		MainMenu.AppendMenu(wxID_ANY , "Show Text" , SubMenu4)
		MainMenu.AppendMenu(wxID_ANY , "Show Generic Art" , SubMenu5)
		
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
		Local FilterText:wxStaticText = New wxStaticText.Create(FilPlatPanel , wxID_ANY , "Filter:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		FilterTextBox = New wxTextCtrl.Create(FilPlatPanel, GES_FTB , "" , -1 , -1 , -1 , -1 , 0 )
		Local PlatformText:wxStaticText = New wxStaticText.Create(FilPlatPanel , wxID_ANY , "Platform:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		PlatformCombo = New wxComboBox.Create(FilPlatPanel , GES_PL , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY)		
		
		Local UsedPlatformList:TList
		'Local UsedPlatformList2:TList
		UsedPlatformList = CreateList()
		'UsedPlatformList2 = CreateList()
		Local GameNode:GameReadType
		ReadGamesDir = ReadDir(GAMEDATAFOLDER)
		Repeat
			Dir:String = NextFile(ReadGamesDir)
			If Dir = "" Then Exit
			If Dir="." Or Dir=".." Then Continue 
			
			GameNode = New GameReadType
			If GameNode.GetGame(Dir) = - 1 Then
			
			Else
				ListAddLast(UsedPlatformList , GameNode.Plat)
			EndIf

		Forever
		CloseDir(ReadGamesDir)
		
		PlatformCombo.Append("All")
		PlatformCombo.SetSelection(0)
		
		Local Plat:String
		For Plat = EachIn JPLATFORMS
			If UsedPlatformList.Contains(Plat) Then
				PlatformCombo.Append(Plat)
				'ListAddLast(UsedPlatformList2 , Plat)
			EndIf
		Next
		
		
		If CmdLineGameName = "" Then 
			If SettingFile.GetSetting("Sort") <> "" Then	
				SortCombo.SetValue(SettingFile.GetSetting("Sort"))
			EndIf
			If SettingFile.GetSetting("Filter") <> "" Then
				FilterTextBox.ChangeValue(SettingFile.GetSetting("Filter"))
			EndIf 
			If SettingFile.GetSetting("Platform") <> "" Then
				PlatformCombo.SetValue(SettingFile.GetSetting("Platform"))
			EndIf 
		EndIf 
			
		
		FilPlatHbox.Add(SortText , 0 , wxEXPAND | wxLEFT | wxTOP | wxBOTTOM| wxALIGN_CENTER , 10 )
		FilPlatHbox.Add(SortCombo , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP | wxBOTTOM , 10)
		FilPlatHbox.Add(FilterText , 0 , wxEXPAND | wxLEFT | wxTOP | wxBOTTOM| wxALIGN_CENTER , 10 )
		FilPlatHbox.Add(FilterTextBox , 2 , wxEXPAND | wxALL , 10)
		FilPlatHbox.Add(PlatformText , 0 , wxEXPAND | wxLEFT | wxTOP | wxBOTTOM| wxALIGN_CENTER , 10)
		FilPlatHbox.Add(PlatformCombo , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP | wxBOTTOM, 10)
		

		
		FilPlatPanel.SetSizer(FilPlatHbox)
		
		
		'---------------------------------SPLIT PANEL---------------------------------
		Local WinSplit:wxSplitterWindow = New wxSplitterWindow.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxSP_NOBORDER | wxSP_LIVE_UPDATE)
	
		Local GameListPanel:wxPanel = New wxPanel.Create(WinSplit , - 1)
	 	Local GameListPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
	 	GameList = New wxListCtrl.Create(GameListPanel , GES_GL , - 1 , - 1 , - 1 , - 1 , GameListStyle )
		GameListPanelhbox.Add(GameList , 1 ,  wxEXPAND | wxLEFT | wxBOTTOM , 5)
		GameListPanel.SetSizer(GameListPanelhbox)

		
		Local GameNotebookPanel:wxPanel = New wxPanel.Create(WinSplit , - 1)
		
		Local GameNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		?MacOS
		GameNotebook = New wxChoicebook.Create(GameNotebookPanel , GES_GN , - 1 , - 1 , - 1 , - 1 , wxCHB_DEFAULT)
		?Not MacOS
		GameNotebook = New wxNotebook.Create(GameNotebookPanel , GES_GN , - 1 , - 1 , - 1 , - 1 , wxNB_TOP | wxNB_MULTILINE)
		?
		GameNotebook.SetBackgroundColour(New wxColour.Create(MainColor_R,MainColor_G,MainColor_B))
		GameNotebookPanelhbox.Add(GameNotebook , 1 ,  wxEXPAND | wxLEFT |wxRIGHT | wxBOTTOM , 5)
		GameNotebookPanel.SetSizer(GameNotebookPanelhbox)
		
		
		'----------------------------Details+Front Art Panel------------------------------
		Local SubWinSplit:wxSplitterWindow = New wxSplitterWindow.Create(GameNotebook , GES_SWS , - 1 , - 1 , - 1 , - 1 , wxSP_NOBORDER | wxSP_LIVE_UPDATE)
		'SubWinSplit.SetBackgroundColour(New wxColour.Create(255,255,255))
		Local FBAMainPanel:wxPanel = New wxPanel.Create(SubWinSplit , - 1)
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
		
		Local sl2:wxStaticLine = New wxStaticLine.Create(FBAMainPanel , wxID_ANY , -1 , -1 , -1 , -1 , wxLI_HORIZONTAL)
		FBAMainPanelvbox.Add(FBAPanel , 1 , wxEXPAND , 5)
		FBAMainPanelvbox.Add(sl2 , 0 , wxEXPAND , 0)
		FBAMainPanel.SetSizer(FBAMainPanelvbox)
		
		GameDetailsPanel = New wxPanel.Create(SubWinSplit , - 1)
		GDPvbox = New wxBoxSizer.Create(wxVERTICAL)
		
		Local GNameFont:wxFont = New wxFont.Create()
		GNameFont.SetPointSize(9)
		GNameFont.SetWeight(wxFONTWEIGHT_BOLD)
		'GNameFont.SetFamily(wxFONTFAMILY_SWISS)
				
		GNameText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE )
		GNameText.SetFont(GNameFont)
		
		Local sl1:wxStaticLine = New wxStaticLine.Create(GameDetailsPanel , wxID_ANY , -1 , -1 , -1 , -1 , wxLI_HORIZONTAL)
		'GDescText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 )
		GDescText = New wxTextCtrl.Create( GameDetailsPanel , wxID_ANY , "" , -1 , -1 , -1 , -1 , wxTE_READONLY | wxTE_WORDWRAP | wxTE_MULTILINE)
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
		GDP_sub_hbox4.AddSizer(GDP_sub_hbox3 , 1 , wxEXPAND   , 0)
			
		GDPvbox.Add(sl1 , 0 , wxEXPAND , 0)
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
		
		?Win32
		TrailerCtrl = New wxMediaCtrl.Create(GameTrailerPanel , wxID_ANY , "" , -1 , -1 , -1 , -1 , 0 , BackEnd )
		
		If ShowPlayerCtrls = True Then 
			TrailerCtrl.ShowPlayerControls()
		EndIf 	
		?	
			
		TrailerButton = New wxButton.Create(GameTrailerPanel , GES_TB ,"Watch in browser")
		
		?Win32
		GameTrailerPanelvbox.Add(TrailerCtrl , 1 , wxEXPAND | wxALL , 5)
		?
		
		GameTrailerPanelvbox.Add(TrailerButton , 0 , wxEXPAND | wxALL , 5)
		GameTrailerPanel.SetSizer(GameTrailerPanelvbox)
		
		'--------------------------------------------Screenshot Panel-----------------------------------
		Local GameScreenPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		
		Local GS_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		GS_SC1_Panel = ScreenShotPanel(New ScreenShotPanel.Create(GameScreenPanel , - 1) )
		GS_SC1_Panel.SetImageType(3)
		Local sl101:wxStaticLine = New wxStaticLine.Create(GameScreenPanel , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		GS_SC2_Panel = ScreenShotPanel(New ScreenShotPanel.Create(GameScreenPanel , - 1) )
		GS_SC2_Panel.SetImageType(3)		
		Local sl102:wxStaticLine = New wxStaticLine.Create(GameScreenPanel , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		Local OpenScreenShotButton:wxButton = New wxButton.Create(GameScreenPanel , GS_OSB ,"View ScreenShots")
		
		
		
		GS_vbox.Add(GS_SC1_Panel , 1 , wxEXPAND | wxALL , 5)
		GS_vbox.Add(sl101 , 0 , wxEXPAND , 0)
		GS_vbox.Add(GS_SC2_Panel , 1 , wxEXPAND | wxALL , 5)
		GS_vbox.Add(sl102 , 0 , wxEXPAND , 0)
		GS_vbox.Add(OpenScreenShotButton , 0 , wxEXPAND | wxALL , 5)
		GameScreenPanel.SetSizer(GS_vbox)
		
		
		'--------------------------------------------Patch Panel------------------------------------
		
		Local GamePatchNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)	
		Local GamePatchNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local GamePatchNotebook:wxNotebook = New wxNotebook.Create(GamePatchNotebookPanel , GP_GPN , - 1 , - 1 , - 1 , - 1 , wxNB_TOP | wxNB_FLAT )
		GamePatchNotebook.SetBackgroundColour(New wxColour.Create(MainColor_R,MainColor_G,MainColor_B))
		GamePatchNotebookPanelhbox.Add(GamePatchNotebook , 1 ,  wxEXPAND | wxALL , 5)
		GamePatchNotebookPanel.SetSizer(GamePatchNotebookPanelhbox)

		Local GamePatchLocalPanel:wxPanel = New wxPanel.Create(GamePatchNotebook , - 1)
		GPL_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		LocalPatchText = New wxStaticText.Create(GamePatchLocalPanel , wxID_ANY , "Patch:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT )
		LocalPatchList = New wxListBox.Create(GamePatchLocalPanel , GLP_PL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)
		LocalPatchFilesText = New wxStaticText.Create(GamePatchLocalPanel , wxID_ANY , "Patch Files:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT )		
		LocalPatchFileList = New wxListBox.Create(GamePatchLocalPanel , GLP_PFL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)
		
		GPL_vbox.Add(LocalPatchText , 0 , wxEXPAND | wxALL , 5)
		GPL_vbox.Add(LocalPatchList , 1 , wxEXPAND | wxALL , 5)
		GPL_vbox.Add(LocalPatchFilesText  , 0 , wxEXPAND | wxALL , 5)
		GPL_vbox.Add(LocalPatchFileList , 1 , wxEXPAND | wxALL  , 5)
		GamePatchLocalPanel.SetSizer(GPL_vbox)


		Local GamePatchPanel:wxPanel = New wxPanel.Create(GamePatchNotebook , - 1)
		Local GP_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		GP_SP_hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local PatchText:wxStaticText = New wxStaticText.Create(GamePatchPanel , wxID_ANY , "Search:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		PatchSearchBox = New wxTextCtrl.Create(GamePatchPanel, GP_SP_ST , "" , -1 , -1 , -1 , -1 , 0 )
		Local PatchSearchButton:wxButton = New wxButton.Create(GamePatchPanel , GP_SP_SB ,"Go")
		GP_SP_hbox.Add(PatchText , 0 , wxEXPAND | wxTOP | wxBOTTOM , 4)
		GP_SP_hbox.Add(PatchSearchBox , 1 , wxEXPAND | wxLEFT | wxRIGHT , 5)
		GP_SP_hbox.Add(PatchSearchButton , 0 , wxEXPAND  , 5)
		
		PatchList = New wxListBox.Create(GamePatchPanel , GP_PL , Null , -1 , -1 , -1 , -1 , wxLB_SINGLE) 
		Local PatchDownloadButton:wxButton = New wxButton.Create(GamePatchPanel , GP_DP , "Download")
		
		GP_vbox.AddSizer(GP_SP_hbox , 0 , wxEXPAND | wxALL , 5)
		GP_vbox.Add(PatchList , 1 , wxEXPAND | wxALL , 5)
		GP_vbox.Add(PatchDownloadButton , 0 , wxEXPAND | wxALL , 5)
		GamePatchPanel.SetSizer(GP_vbox)
		
		
		GamePatchNotebook.AddPage(GamePatchLocalPanel , "Local" )
		GamePatchNotebook.AddPage(GamePatchPanel , "Download" )		
		
		'--------------------------------------------Cheat Panel-----------------------------------
	

		Local GameCheatNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		Local GameCheatNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local GameCheatNotebook:wxNotebook = New wxNotebook.Create(GameCheatNotebookPanel , GC_GCN , - 1 , - 1 , - 1 , - 1 , wxNB_TOP | wxNB_FLAT )
		GameCheatNotebook.SetBackgroundColour(New wxColour.Create(MainColor_R,MainColor_G,MainColor_B))
		GameCheatNotebookPanelhbox.Add(GameCheatNotebook , 1 ,  wxEXPAND | wxALL , 5)
		GameCheatNotebookPanel.SetSizer(GameCheatNotebookPanelhbox)
		


		Local GameCheatLocalPanel:wxPanel = New wxPanel.Create(GameCheatNotebook , - 1)
		Local GCL_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local LocalCheatText = New wxStaticText.Create(GameCheatLocalPanel , wxID_ANY , "Cheats:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT )
		LocalCheatList = New wxListBox.Create(GameCheatLocalPanel , GLC_CL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)
		

		
		GCL_vbox.Add(LocalCheatText , 0 , wxEXPAND | wxALL , 5)
		GCL_vbox.Add(LocalCheatList , 1 , wxEXPAND | wxALL , 5)
		GameCheatLocalPanel.SetSizer(GCL_vbox)


		Local GameCheatPanel:wxPanel = New wxPanel.Create(GameCheatNotebook , - 1)
		Local GC_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		CheatSearchCatBox = New wxComboBox.Create(GameCheatPanel, GC_SC_SC , "All Platforms" , GAMEFAQPLATFORMS , -1 , -1 , -1 , -1 , wxCB_READONLY )
		
		Local GC_SC_hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)		
		Local CheatText:wxStaticText = New wxStaticText.Create(GameCheatPanel , wxID_ANY , "Search:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		CheatSearchBox = New wxTextCtrl.Create(GameCheatPanel, GC_SC_ST , "" , -1 , -1 , -1 , -1 , 0 )
		Local CheatSearchButton:wxButton = New wxButton.Create(GameCheatPanel , GC_SC_SB ,"Go")
		GC_SC_hbox.Add(CheatText , 0 , wxEXPAND | wxTOP | wxBOTTOM , 4)
		GC_SC_hbox.Add(CheatSearchBox , 1 , wxEXPAND | wxLEFT | wxRIGHT , 5)
		GC_SC_hbox.Add(CheatSearchButton , 0 , wxEXPAND  , 5)
		
		CheatList = New wxListBox.Create(GameCheatPanel , GC_CL , Null , -1 , -1 , -1 , -1 , wxLB_SINGLE) 
		Local CheatDownloadButton:wxButton = New wxButton.Create(GameCheatPanel , GC_DC , "Download")
		
		GC_vbox.Add(CheatSearchCatBox, 0 , wxEXPAND | wxALL , 5)
		GC_vbox.AddSizer(GC_SC_hbox , 0 , wxEXPAND | wxALL , 5)
		GC_vbox.Add(CheatList , 1 , wxEXPAND | wxALL , 5)
		GC_vbox.Add(CheatDownloadButton , 0 , wxEXPAND | wxALL , 5)
		GameCheatPanel.SetSizer(GC_vbox)
		
		
		GameCheatNotebook.AddPage(GameCheatLocalPanel , "Local" )
		GameCheatNotebook.AddPage(GameCheatPanel , "Download" )	

		
		
		'--------------------------------------------Walkthrough Panel------------------------------

		
		
		Local GameWalkNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		Local GameWalkNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local GameWalkNotebook:wxNotebook = New wxNotebook.Create(GameWalkNotebookPanel , GW_GWN , - 1 , - 1 , - 1 , - 1 , wxNB_TOP | wxNB_FLAT )
		GameWalkNotebook.SetBackgroundColour(New wxColour.Create(MainColor_R,MainColor_G,MainColor_B))
		GameWalkNotebookPanelhbox.Add(GameWalkNotebook , 1 ,  wxEXPAND | wxALL , 5)
		GameWalkNotebookPanel.SetSizer(GameWalkNotebookPanelhbox)
		

		Local GameWalkLocalPanel:wxPanel = New wxPanel.Create(GameWalkNotebook , - 1)
		Local GWL_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local LocalWalkText = New wxStaticText.Create(GameWalkLocalPanel , wxID_ANY , "Walkthrough Set:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT )
		LocalWalkList = New wxListBox.Create(GameWalkLocalPanel , GLW_WL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)
		Local LocalWalkFilesText = New wxStaticText.Create(GameWalkLocalPanel , wxID_ANY , "Walkthrough Files:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT )		
		LocalWalkFileList = New wxListBox.Create(GameWalkLocalPanel , GLW_WFL , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)
		

		
		GWL_vbox.Add(LocalWalkText , 0 , wxEXPAND | wxALL , 5)
		GWL_vbox.Add(LocalWalkList , 1 , wxEXPAND | wxALL , 5)
		GWL_vbox.Add(LocalWalkFilesText  , 0 , wxEXPAND | wxALL , 5)
		GWL_vbox.Add(LocalWalkFileList , 1 , wxEXPAND | wxALL  , 5)
		GameWalkLocalPanel.SetSizer(GWL_vbox)


		Local GameWalkPanel:wxPanel = New wxPanel.Create(GameWalkNotebook , - 1)
		Local GW_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		WalkSearchCatBox = New wxComboBox.Create(GameWalkPanel, GW_SP_SC , "All Platforms" , GAMEFAQPLATFORMS , -1 , -1 , -1 , -1 , wxCB_READONLY )
		
		GP_SP_hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)		
		Local WalkText:wxStaticText = New wxStaticText.Create(GameWalkPanel , wxID_ANY , "Search:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		WalkSearchBox = New wxTextCtrl.Create(GameWalkPanel, GW_SP_ST , "" , -1 , -1 , -1 , -1 , 0 )
		Local WalkSearchButton:wxButton = New wxButton.Create(GameWalkPanel , GW_SP_SB ,"Go")
		GP_SP_hbox.Add(WalkText , 0 , wxEXPAND | wxTOP | wxBOTTOM , 4)
		GP_SP_hbox.Add(WalkSearchBox , 1 , wxEXPAND | wxLEFT | wxRIGHT , 5)
		GP_SP_hbox.Add(WalkSearchButton , 0 , wxEXPAND  , 5)
		
		WalkList = New wxListBox.Create(GameWalkPanel , GW_WL , Null , -1 , -1 , -1 , -1 , wxLB_SINGLE) 
		Local WalkDownloadButton:wxButton = New wxButton.Create(GameWalkPanel , GW_DW , "Download")
		
		GW_vbox.Add(WalkSearchCatBox, 0 , wxEXPAND | wxALL , 5)
		GW_vbox.AddSizer(GP_SP_hbox , 0 , wxEXPAND | wxALL , 5)
		GW_vbox.Add(WalkList , 1 , wxEXPAND | wxALL , 5)
		GW_vbox.Add(WalkDownloadButton , 0 , wxEXPAND | wxALL , 5)
		GameWalkPanel.SetSizer(GW_vbox)
		
		
		GameWalkNotebook.AddPage(GameWalkLocalPanel , "Local" )
		GameWalkNotebook.AddPage(GameWalkPanel , "Download" )		
				
		
		'--------------------------------------------Manual Panel----------------------------------
	
		Local GameManualNotebookPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		Local GameManualNotebookPanelhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local GameManualNotebook:wxNotebook = New wxNotebook.Create(GameManualNotebookPanel , GM_GPN , - 1 , - 1 , - 1 , - 1 , wxNB_TOP | wxNB_FLAT )
		GameManualNotebook.SetBackgroundColour(New wxColour.Create(MainColor_R,MainColor_G,MainColor_B))
		GameManualNotebookPanelhbox.Add(GameManualNotebook , 1 ,  wxEXPAND | wxALL , 5)
		GameManualNotebookPanel.SetSizer(GameManualNotebookPanelhbox)

		Local GameManualLocalPanel:wxPanel = New wxPanel.Create(GameManualNotebook , - 1)
		GML_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local LocalManualText = New wxStaticText.Create(GameManualLocalPanel , wxID_ANY , "Manual:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT )
		LocalManualList = New wxListBox.Create(GameManualLocalPanel , GLM_ML , Null , - 1 , - 1 , - 1 , - 1 , wxLB_SINGLE)



		GML_vbox.Add(LocalManualText , 0 , wxEXPAND | wxALL , 5)
		GML_vbox.Add(LocalManualList , 1 , wxEXPAND | wxALL , 5)
		GameManualLocalPanel.SetSizer(GML_vbox)


		Local GameManualPanel:wxPanel = New wxPanel.Create(GameManualNotebook , - 1)
		Local GM_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		GM_SP_hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local ManualText:wxStaticText = New wxStaticText.Create(GameManualPanel , wxID_ANY , "Search:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		ManualSearchBox = New wxTextCtrl.Create(GameManualPanel, GM_SP_ST , "" , -1 , -1 , -1 , -1 , 0 )
		Local ManualSearchButton:wxButton = New wxButton.Create(GameManualPanel , GM_SP_SB ,"Go")
		GM_SP_hbox.Add(ManualText , 0 , wxEXPAND | wxTOP | wxBOTTOM , 4)
		GM_SP_hbox.Add(ManualSearchBox , 1 , wxEXPAND | wxLEFT | wxRIGHT , 5)
		GM_SP_hbox.Add(ManualSearchButton , 0 , wxEXPAND  , 5)
		
		ManualList = New wxListBox.Create(GameManualPanel , GM_ML , Null , -1 , -1 , -1 , -1 , wxLB_SINGLE) 
		Local ManualDownloadButton:wxButton = New wxButton.Create(GameManualPanel , GM_DM , "Download")
		
		GM_vbox.AddSizer(GM_SP_hbox , 0 , wxEXPAND | wxALL , 5)
		GM_vbox.Add(ManualList , 1 , wxEXPAND | wxALL , 5)
		GM_vbox.Add(ManualDownloadButton , 0 , wxEXPAND | wxALL , 5)
		GameManualPanel.SetSizer(GM_vbox)
		
		
		GameManualNotebook.AddPage(GameManualLocalPanel , "Local" )
		GameManualNotebook.AddPage(GameManualPanel , "Download" )		

		'-----------------------------------------------------------------------------------		

		

		
		GameNotebook.AddPage(SubWinSplit , "Details" )
		GameNotebook.AddPage(GameTrailerPanel , "Trailer" )
		GameNotebook.AddPage(GameScreenPanel , "Screen Shots" )
		GameNotebook.AddPage(GameManualNotebookPanel , "Manual" )
		GameNotebook.AddPage(GamePatchNotebookPanel , "Patches" )
		GameNotebook.AddPage(GameCheatNotebookPanel , "Cheats" )
		GameNotebook.AddPage(GameWalkNotebookPanel , "Walkthroughs" )
		

		

		WinSplit.SplitVertically(GameListPanel , GameNotebookPanel , - 300)
	 	WinSplit.SetSashGravity(1)
	 	WinSplit.SetMinimumPaneSize(100)
		
	 	SubWinSplit.SplitHorizontally(FBAMainPanel , GameDetailsPanel , 200)
	 	SubWinSplit.SetSashGravity(0)
	 	SubWinSplit.SetMinimumPaneSize(10)	
		
	 	GameNotebook.Disable()	
		
		
		'hbox.Add(GameList , 3 , wxEXPAND | wxALL , 10 )
		'hbox.Add(GameNotebook , 1 , wxEXPAND | wxALL , 10 )
		
		vbox.Add(FilPlatPanel , 0 ,  wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 0)
		vbox.Add(WinSplit , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 0 )

		Self.SetSizer(vbox)
		Self.Centre()
		
		
		Self.PopulateGameList()
		
		
		Connect(GES_SL , wxEVT_COMMAND_COMBOBOX_SELECTED , GameListUpdate)
		Connect(GES_FTB , wxEVT_COMMAND_TEXT_UPDATED , GameListUpdate)
		Connect(GES_PL , wxEVT_COMMAND_COMBOBOX_SELECTED , GameListUpdate)
			
			
		Connect(GES_GL , wxEVT_COMMAND_LIST_ITEM_SELECTED , UpdateSelectionFun)
		Connect(GES_GL , wxEVT_COMMAND_LIST_ITEM_RIGHT_CLICK , GLRightClickedFun)
		Connect(GES_GL , wxEVT_COMMAND_LIST_ITEM_ACTIVATED  , GLMenuClickedFun , "RG")
		

		
		Connect(GES_SWS , wxEVT_COMMAND_SPLITTER_SASH_POS_CHANGED , UpdatePicSize)
		
		Connect(GES_TB , wxEVT_COMMAND_BUTTON_CLICKED , OpenTrailer)
		Connect(GS_OSB , wxEVT_COMMAND_BUTTON_CLICKED , OpenScreenShots)
		
		Connect(GP_SP_SB , wxEVT_COMMAND_BUTTON_CLICKED , PatchSearchFun)
		Connect(GM_SP_SB , wxEVT_COMMAND_BUTTON_CLICKED , ManualSearchFun)
		Connect(GW_SP_SB , wxEVT_COMMAND_BUTTON_CLICKED , WalkSearchFun)
		Connect(GC_SC_SB , wxEVT_COMMAND_BUTTON_CLICKED , CheatSearchFun)
		
		Connect(GP_DP , wxEVT_COMMAND_BUTTON_CLICKED , PatchDownloadFun)
		Connect(GM_DM , wxEVT_COMMAND_BUTTON_CLICKED , ManualDownloadFun)
		Connect(GW_DW , wxEVT_COMMAND_BUTTON_CLICKED , WalkDownloadFun)
		Connect(GC_DC , wxEVT_COMMAND_BUTTON_CLICKED , CheatDownloadFun)
		
		Connect(GP_PL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , PatchDownloadFun)
		Connect(GM_ML , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , ManualDownloadFun)		
		Connect(GW_WL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , WalkDownloadFun)
		Connect(GC_CL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , CheatDownloadFun)

		
		Connect(GLP_PL , wxEVT_COMMAND_LISTBOX_SELECTED , PatchClickedFun)
		Connect(GLW_WL , wxEVT_COMMAND_LISTBOX_SELECTED , WalkClickedFun)
		
		Connect(GLP_PFL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , PatchItemSelectedFun)
		Connect(GLM_ML , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , ManualItemSelectedFun)
		Connect(GLC_CL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED ,CheatItemSelectedFun)
		Connect(GLW_WFL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , WalkItemSelectedFun)
		
		Connect(GP_GPN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		Connect(GM_GPN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		Connect(GW_GWN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		Connect(GC_GCN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		Connect(GES_GN , wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED , UpdateSelectionFun)
		
		Connect(GDP_GRC , wxEVT_COMMAND_COMBOBOX_SELECTED , UserDataUpdate)
		Connect(GDP_GCC , wxEVT_COMMAND_COMBOBOX_SELECTED , UserDataUpdate)
		

		?Win32		
		Local StringItem:String 
		Local ID:Int = 0
		Local IDSet = False 
		Local item:wxListItem
		If CmdLineGameName = "" Then 
			If SettingFile.GetSetting("LastGameNumber") <> "" Then		
				item = New wxListItem.Create()	
				item.SetID(Int(SettingFile.GetSetting("LastGameNumber")))
				GameList.GetItem(item)
				item.SetState(wxLIST_STATE_SELECTED)
				GameList.SetItem(item)
			EndIf
		Else
			For StringItem = EachIn GameRealPathList
				If StringItem = CmdLineGameName Then 
					IDSet = True 
					Exit
				Else
					ID = ID + 1
				EndIf 
			Next 
			If IDSet = True Then 
				item = New wxListItem.Create()	
				item.SetID(ID)
				GameList.GetItem(item)
				item.SetState(wxLIST_STATE_SELECTED)
				GameList.SetItem(item)
			EndIf 
		
		EndIf 
		?

			
		StartupRefreshTimer = New wxTimer.Create(Self,SRT1)
		StartupRefreshTimer.Start(1000 , True)
		Connect(SRT1 ,wxEVT_TIMER , StartupRefreshTimerFun)

		?Linux
		StartupRefreshTimer2 = New wxTimer.Create(Self,SRT2)
		StartupRefreshTimer2.Start(2000 , True)
		Connect(SRT2 ,wxEVT_TIMER , StartupRefreshTimerFun2)
		?

		StartupRefreshTimer3 = New wxTimer.Create(Self,SRT3)
		StartupRefreshTimer3.Start(3000 , True)
		Connect(SRT3 ,wxEVT_TIMER , StartupRefreshTimerFun3)
		
		Connect(GES ,wxEVT_SIZE , ResizeEventFun)
		
		
		
	End Method
	
	Function ResizeEventFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		PrintF("Resized Win")
		event.skip(True)
	'	GameExploreWin.Refresh()
	'	GameExploreWin.Update()
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
		If CmdLineGameName <> "" Then 
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
			If IDSet = True Then 
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
		Local Selection2:String = GameExploreWin.LocalWalkFileList.GetStringSelection()
		Local CDir:String = CurrentDir()
		ChangeDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides" + FolderSlash + Selection)
		OpenURL(Selection2)
		ChangeDir(CDir)
	End Function	

	Function ManualItemSelectedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalManualList.GetStringSelection()
		Local CDir:String = CurrentDir()
		ChangeDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Manuals")
		OpenURL(Selection)
		ChangeDir(CDir)
	End Function
	
	Function CheatItemSelectedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalCheatList.GetStringSelection()
		Local CDir:String = CurrentDir()
		ChangeDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Cheats")
		OpenURL(Selection)
		ChangeDir(CDir)
	End Function	

	Function PatchClickedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalPatchList.GetStringSelection()
		Local File:String
		
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
	
	Function WalkClickedFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Selection:String = GameExploreWin.LocalWalkList.GetStringSelection()
		Local File:String
		
		GameExploreWin.LocalWalkFileList.Clear()
		
		ReadWalks = ReadDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides" + FolderSlash + Selection)
		Repeat
			File = NextFile(ReadWalks)
			If File="." Or File=".." Then Continue
			If File = "" Then Exit
			If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides" + FolderSlash + Selection + FolderSlash + File) = 1 Then
				GameExploreWin.LocalWalkFileList.Append(File)
			EndIf
		Forever
		CloseDir(ReadWalks)

	End Function	

	Function ExitFun(event:wxEvent)
		?Win32
        wxWindow(event.parent).Close(True)
		?Linux
		End 
		?
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
	
	Function PatchDownloadFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local MessageBox:wxMessageDialog
		Local Patch:DownloadListObject		
		Local Selection:String = GameExploreWin.PatchList.GetStringSelection()
		'Local DownloadFile:String = ""
		'Local GameName:String = ""
		If Selection = "" Or Selection = "No Results Returned" Or Selection = "Tip: Try removing numbers, II could be indexed as 2 or vice versa. Also try removing terms to widen your search." Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a patch" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return		
		Else
			For Patch = EachIn GameExploreWin.PatchTList
				If Selection = Patch.Name Then
					'DownloadFile = Patch.URL
					Exit 
				EndIf 
			Next			
		EndIf
		'GameName = 
		PrintF("PhotonDownloader.exe -Mode 1 -DownloadGame "+Chr(34)+GameNode.OrginalName+Chr(34)+" -DownloadFile "+Chr(34)+Patch.URL+Chr(34)+" -DownloadType PScrolls -DownloadName "+Chr(34)+Patch.Name+Chr(34))
		RunProcess("PhotonDownloader.exe -Mode 1 -DownloadGame "+Chr(34)+GameNode.OrginalName+Chr(34)+" -DownloadFile "+Chr(34)+Patch.URL+Chr(34)+" -DownloadType PScrolls -DownloadName "+Chr(34)+Patch.Name+Chr(34) , 1)
		
	End Function

	Function CheatDownloadFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local MessageBox:wxMessageDialog
		Local Cheat:DownloadListObject		
		Local Selection:String = GameExploreWin.CheatList.GetStringSelection()
		If Selection = "" Or Selection = "No Results Returned" Or Selection = "Tip: Try removing numbers, II could be indexed as 2 or vice versa. Also try removing terms to widen your search." Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a manual" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return		
		Else
			For Cheat = EachIn GameExploreWin.CheatTList
				If Selection = Cheat.Name Then
					Exit 
				EndIf 
			Next			
		EndIf
		Print "PhotonDownloader.exe -Mode 1 -DownloadGame "+Chr(34)+GameNode.OrginalName+Chr(34)+" -DownloadFile "+Chr(34)+Cheat.URL+Chr(34)+" -DownloadType GFAQs-Cheat -DownloadName "+Chr(34)+Cheat.Name+Chr(34)
		RunProcess("PhotonDownloader.exe -Mode 1 -DownloadGame "+Chr(34)+GameNode.OrginalName+Chr(34)+" -DownloadFile "+Chr(34)+Cheat.URL+Chr(34)+" -DownloadType GFAQs-Cheat -DownloadName "+Chr(34)+Cheat.Name+Chr(34) , 1)
		
	End Function

	Function WalkDownloadFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local MessageBox:wxMessageDialog
		Local Walk:DownloadListObject		
		Local Selection:String = GameExploreWin.WalkList.GetStringSelection()
		If Selection = "" Or Selection = "No Results Returned" Or Selection = "Tip: Try removing numbers, II could be indexed as 2 or vice versa. Also try removing terms to widen your search." Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a manual" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return		
		Else
			For Walk = EachIn GameExploreWin.WalkTList
				If Selection = Walk.Name Then
					Exit 
				EndIf 
			Next			
		EndIf
		Print "PhotonDownloader.exe -Mode 1 -DownloadGame "+Chr(34)+GameNode.OrginalName+Chr(34)+" -DownloadFile "+Chr(34)+Walk.URL+Chr(34)+" -DownloadType GFAQs -DownloadName "+Chr(34)+Walk.Name+Chr(34)
		RunProcess("PhotonDownloader.exe -Mode 1 -DownloadGame "+Chr(34)+GameNode.OrginalName+Chr(34)+" -DownloadFile "+Chr(34)+Walk.URL+Chr(34)+" -DownloadType GFAQs -DownloadName "+Chr(34)+Walk.Name+Chr(34) , 1)
		
	End Function

	Function ManualDownloadFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local MessageBox:wxMessageDialog
		Local Manual:DownloadListObject		
		Local Selection:String = GameExploreWin.ManualList.GetStringSelection()
		'Local DownloadFile:String = ""
		'Local GameName:String = ""
		If Selection = "" Or Selection = "No Results Returned" Or Selection = "Tip: Try removing numbers, II could be indexed as 2 or vice versa. Also try removing terms to widen your search." Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a manual" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return		
		Else
			For Manual = EachIn GameExploreWin.ManualTList
				If Selection = Manual.Name Then
					'DownloadFile = Patch.URL
					Exit 
				EndIf 
			Next			
		EndIf
		'GameName = 
		Print "PhotonDownloader.exe -Mode 1 -DownloadGame "+Chr(34)+GameNode.OrginalName+Chr(34)+" -DownloadFile "+Chr(34)+Manual.URL+Chr(34)+" -DownloadType PDocs -DownloadName "+Chr(34)+Manual.Name+Chr(34)
		RunProcess("PhotonDownloader.exe -Mode 1 -DownloadGame "+Chr(34)+GameNode.OrginalName+Chr(34)+" -DownloadFile "+Chr(34)+Manual.URL+Chr(34)+" -DownloadType RDocs -DownloadName "+Chr(34)+Manual.Name+Chr(34) , 1)
		
	End Function

	Function WalkSearchFun(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Walk:DownloadListObject
		
		If CheckInternet() = 1 Then
			If SettingFile.GetSetting("DownloadsAccepted") = "" Then
				OpenURL("http://photongamemanager.com/GameManagerPages/DownloadsToS.html")
				MessageBox = New wxMessageDialog.Create(Null , "Before you can download anything you must accept the ToS opened in your browser (http://photongamemanager.com/GameManagerPages/DownloadsToS.html). Do you accept them?" , "Question" , wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_YES Then
					SettingFile.SaveSetting("DownloadsAccepted" , "1")
					SettingFile.SaveFile()
				Else
					Return
				EndIf 
			EndIf 
			
			Rem
			If SettingFile.GetSetting("WalkthroughAccepted") = "" Then
				OpenURL("")
				MessageBox = New wxMessageDialog.Create(Null , "Before you can download walkthroughs you must accept the ToS opened in your browser (). Do you accept them?" , "Question" , wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_YES Then
					SettingFile.SaveSetting("WalkthroughAccepted" , "1")
					SettingFile.SaveFile()
				Else
					Return
				EndIf 
			EndIf 		
			EndRem 
			
			GameExploreWin.WalkTList = SearchGuide_GFAQs(GameExploreWin.WalkSearchBox.GetValue(),GetGFAQsCode(GameExploreWin.WalkSearchCatBox.GetCurrentSelection()))
			GameExploreWin.WalkList.Clear() 
			
			For Walk = EachIn GameExploreWin.WalkTList
				GameExploreWin.WalkList.Append(Walk.Name)
			Next
			If GameExploreWin.WalkTList.Count() < 1 Then
				GameExploreWin.WalkList.Append("No Results Returned")
				GameExploreWin.WalkList.Append("Tip: Try removing numbers, II could be indexed as 2 or vice versa. Also try removing terms to widen your search.")
			EndIf
		Else
			MessageBox = New wxMessageDialog.Create(Null , "You are not connected to the internet" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return			
		EndIf 
	End Function

	Function CheatSearchFun(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Cheat:DownloadListObject
		
		If CheckInternet() = 1 Then
			If SettingFile.GetSetting("DownloadsAccepted") = "" Then
				OpenURL("http://photongamemanager.com/GameManagerPages/DownloadsToS.html")
				MessageBox = New wxMessageDialog.Create(Null , "Before you can download anything you must accept the ToS opened in your browser (http://photongamemanager.com/GameManagerPages/DownloadsToS.html). Do you accept them?" , "Question" , wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_YES Then
					SettingFile.SaveSetting("DownloadsAccepted" , "1")
					SettingFile.SaveFile()
				Else
					Return
				EndIf 
			EndIf 
			Rem
			If SettingFile.GetSetting("WalkthroughAccepted") = "" Then
				OpenURL("")
				MessageBox = New wxMessageDialog.Create(Null , "Before you can download cheats you must accept the ToS opened in your browser (). Do you accept them?" , "Question" , wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_YES Then
					SettingFile.SaveSetting("WalkthroughAccepted" , "1")
					SettingFile.SaveFile()
				Else
					Return
				EndIf 
			EndIf 		
			EndRem 
			
			GameExploreWin.CheatTList = SearchCheat_GFAQs(GameExploreWin.CheatSearchBox.GetValue(),GetGFAQsCode(GameExploreWin.WalkSearchCatBox.GetCurrentSelection()))
			GameExploreWin.CheatList.Clear() 
			
			For Cheat = EachIn GameExploreWin.CheatTList
				GameExploreWin.CheatList.Append(Cheat.Name)
			Next
			If GameExploreWin.CheatTList.Count() < 1 Then
				GameExploreWin.CheatList.Append("No Results Returned")
				GameExploreWin.CheatList.Append("Tip: Try removing numbers, II could be indexed as 2 or vice versa. Also try removing terms to widen your search.")
			EndIf
		Else
			MessageBox = New wxMessageDialog.Create(Null , "You are not connected to the internet" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return			
		EndIf 
	End Function

	Function ManualSearchFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Manual:DownloadListObject
		Local MessageBox:wxMessageDialog		
		If CheckInternet() = 1 Then
			If SettingFile.GetSetting("DownloadsAccepted") = "" Then
				OpenURL("http://photongamemanager.com/GameManagerPages/DownloadsToS.html")
				MessageBox = New wxMessageDialog.Create(Null , "Before you can download anything you must accept the ToS opened in your browser (http://photongamemanager.com/GameManagerPages/DownloadsToS.html). Do you accept them?" , "Question" , wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_YES Then
					SettingFile.SaveSetting("DownloadsAccepted" , "1")
					SettingFile.SaveFile()
				Else
					Return
				EndIf 
			EndIf 		
			GameExploreWin.ManualTList = SearchManual_RDocs(GameExploreWin.ManualSearchBox.GetValue() )
			GameExploreWin.ManualList.Clear() 
			
			For Manual = EachIn GameExploreWin.ManualTList
				GameExploreWin.ManualList.Append(Manual.Name)
			Next
			If GameExploreWin.ManualTList.Count() < 1 Then
				GameExploreWin.ManualList.Append("No Results Returned")
				GameExploreWin.ManualList.Append("Tip: Try removing numbers, II could be indexed as 2 or vice versa. Also try removing terms to widen your search.")
			EndIf
		Else
			MessageBox = New wxMessageDialog.Create(Null , "You are not connected to the internet" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return			
		EndIf 
	End Function

	Function PatchSearchFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local Patch:DownloadListObject
		Local MessageBox:wxMessageDialog	
		If CheckInternet() = 1 Then
			If SettingFile.GetSetting("DownloadsAccepted") = "" Then
				OpenURL("http://photongamemanager.com/GameManagerPages/DownloadsToS.html")
				MessageBox = New wxMessageDialog.Create(Null , "Before you can download anything you must accept the ToS opened in your browser (http://photongamemanager.com/GameManagerPages/DownloadsToS.html). Do you accept them?" , "Question" , wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_YES Then
					SettingFile.SaveSetting("DownloadsAccepted" , "1")
					SettingFile.SaveFile()
				Else
					Return
				EndIf 
			EndIf 			
			GameExploreWin.PatchTList = SearchPatch_PScrolls("lang=eng&sys=pc&ref=ps&search=" + GameExploreWin.PatchSearchBox.GetValue() )
			GameExploreWin.PatchList.Clear() 
			
			For Patch = EachIn GameExploreWin.PatchTList
				GameExploreWin.PatchList.Append(Patch.Name)
			Next
			If GameExploreWin.PatchTList.Count() < 1 Then
				GameExploreWin.PatchList.Append("No Results Returned")
				GameExploreWin.PatchList.Append("Tip: Try removing numbers, II could be indexed as 2 or vice versa. Also try removing terms to widen your search.")
			EndIf
		Else
			MessageBox = New wxMessageDialog.Create(Null , "You are not connected to the internet" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return			
		EndIf 
	End Function



	Function SearchPatch_PScrolls:TList(Term:String)
		Local File:TStream
		Local RawPatch:String
		Local URL:String
		Local Name:String
		Local curl:TCurlEasy
		Local Patch:DownloadListObject
		Local PatchList:TList = CreateList()
			
		InternetTimeout = MilliSecs()
		File=WriteFile(TEMPFOLDER+"PatchHTML.txt")
		curl = TCurlEasy.Create()
		curl.setOptString(CURLOPT_POSTFIELDS, Term)
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
		curl.setOptInt(CURLOPT_HEADER, 0)
		curl.setWriteStream(File)
		curl.setProgressCallback(TimeoutCallback) 
		curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
		curl.setOptString(CURLOPT_URL, "http://dlh.net/cgi-bin/dp.cgi")
		Error = curl.perform()
		CloseFile(File)
		If Error > 0 Then
			Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null , "Website Timed Out" , "Info" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()					
			Return PatchList	
		EndIf 			
	
		ReadHTML=ReadFile(TEMPFOLDER+"PatchHTML.txt")
		CurrentSearchLine=""
		Repeat
			CurrentSearchLine=CurrentSearchLine+ReadLine(ReadHTML)
			If Eof(ReadHTML) Then Exit
		Forever
		CloseFile(ReadHTML)
		
		
		Repeat
			RawPatch=ReturnTagInfo(CurrentSearchLine,"<a href="+Chr(34)+"dlp.cgi?","</A>")
			If RawPatch="" Then Exit
			For a=1 To Len(RawPatch)
				If Mid(RawPatch,a,1)=">" Then
					URL$=Left(RawPatch,a-2)
					Name$=Right(RawPatch,Len(RawPatch)-a)
					Exit
				EndIf
			Next
			Patch = New DownloadListObject
			Patch.URL = URL
			Patch.Name = Name
		
			ListAddLast(PatchList,Patch)
		Forever
		
		Return PatchList
	End Function
	

	Function SearchManual_RDocs:TList(Term:String)
		
		Local curl:TCurlEasy
		Local ResultNum:Int = 1
		Local ManualList:TList = CreateList()
		Local Manual:DownloadListObject
		
		Term = Replace(Replace(Term , " " , "+") , "&" , "")
		
		'For ResultNum = 1 To 51 Step 10
		
			InternetTimeout = MilliSecs()
			File=WriteFile(TEMPFOLDER+"PatchHTML.txt")
			curl = TCurlEasy.Create()
			'curl.setOptString(CURLOPT_POSTFIELDS, "")
			curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
			curl.setOptInt(CURLOPT_HEADER, 0)
			curl.setWriteStream(File)
			curl.setProgressCallback(TimeoutCallback) 
			curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
			curl.setOptString(CURLOPT_URL, "http://replacementdocs.com/search.php?q="+Term+"&r="+ResultNum+"&s=Search&in=&ex=&ep=&be=&t=downloads&adv=0&cat=all&on=New&time=any&author=&match=0")
			Error = curl.perform()
			CloseFile(File)
			If Error > 0 Then
				Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null , "Website Timed Out" , "Info" , wxOK | wxICON_INFORMATION)
				MessageBox.ShowModal()
				MessageBox.Free()					
				Return ManualList	
			EndIf 			
			
			
			ReadHTML=ReadFile(TEMPFOLDER+"PatchHTML.txt")
			CurrentSearchLine=""
			Repeat
				CurrentSearchLine=CurrentSearchLine+ReadLine(ReadHTML)
				If Eof(ReadHTML) Then Exit
			Forever
			CloseFile(ReadHTML)
			
			Local RawManualHTML:String
			Local RawManualHTML2:String
			Local RawManualName:String
			Local RawManualURL:String
			Local RawManualType:String
			Local RawManualPlat:String
			Local TempCurrentSearchLine:String
			
			Repeat
				RawManualHTML = ReturnTagInfo(CurrentSearchLine , "<b>" , "</b>")
				If RawManualHTML = "" Then Exit
				
				If Instr(RawManualHTML , "class='visit'") > 0 Then
				
					RawManualHTML2 = ReturnTagInfo(CurrentSearchLine , "<div class='smalltext'>" , "<span class='smalltext'>")
					TempCurrentSearchLine = CurrentSearchLine
					
					RawManualURL = ReturnTagInfo(RawManualHTML , "<a" , ">")
					RawManualURL = ReturnTagInfo(RawManualURL , "href='", "'")
					
					RawManualName = ReturnTagInfo(RawManualHTML , ">" , "</a>")
					For a = 1 To Len(RawManualName)
						If Mid(RawManualName , a , 2) = " |" Then
							RawManualPlat = Left(RawManualName,a-1)
							Exit
						EndIf
					Next
					
					RawManualName = ReturnTagInfo(RawManualName , "| " , "dfjadkgfdfjigfaogjfovmckvfjnfc")
					RawManualName = Replace(RawManualName,"<span class='searchhighlight'>","")
					RawManualName = Replace(RawManualName , "</span>" , "")
					
					RawManualType = ReturnTagInfo(RawManualHTML2 , "</div>" , "<br />")

					
					Manual = New DownloadListObject
					Manual.URL = RawManualURL
					Manual.Name = RawManualName + " - " + RawManualType + " - " + RawManualPlat
				
					ListAddLast(ManualList,Manual)
					
					CurrentSearchLine = TempCurrentSearchLine
				EndIf 
				
			Forever
		'Next
		
		Return ManualList
	End Function

	Function SearchGuide_GFAQs:TList(Term:String,Plat:String)
		
		Local curl:TCurlEasy
		Local ResultNum:Int = 0
		Local GuideList:TList = CreateList()
		Local Guide:DownloadListObject
		
		Term = Replace(Replace(Term , " " , "+") , "&" , "and")
	
		For ResultNum = 0 To 1
			InternetTimeout = MilliSecs()
			File=WriteFile(TEMPFOLDER+"PatchHTML.txt")
			curl = TCurlEasy.Create()
			'curl.setOptString(CURLOPT_POSTFIELDS, "")
			curl.setOptInt(CURLOPT_FOLLOWLOCATION , 1)
			curl.setProgressCallback(TimeoutCallback) 
			curl.setOptInt(CURLOPT_HEADER, 0)
			curl.setWriteStream(File)
			curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
			curl.setOptString(CURLOPT_URL, "http://www.gamefaqs.com/search/index.html?game="+Term+"&page="+ResultNum+"&platform="+Plat)
			Error = curl.perform()
			CloseFile(File) 
			If Error > 0 Then
				Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null , "Website Timed Out" , "Info" , wxOK | wxICON_INFORMATION)
				MessageBox.ShowModal()
				MessageBox.Free()					
				Return GuideList	
			EndIf 
	
			
			ReadHTML=ReadFile(TEMPFOLDER+"PatchHTML.txt")
			CurrentSearchLine=""
			Repeat
				CurrentSearchLine=CurrentSearchLine+ReadLine(ReadHTML)
				If Eof(ReadHTML) Then Exit
			Forever
			CloseFile(ReadHTML)
			
			Local RawWalkHTML:String
			Local TempCurrentSearchLine:String
			Local Line1:String , Line2:String , Line3:String
			Local PrevPlat:String
			
			Local GameName:String , GameURL:String , GamePlat:String
			
			Local TableResults:String = ""
			TableResults = TableResults + ReturnTagInfo(CurrentSearchLine , "<table class="+Chr(34)+"results"+Chr(34)+">" , "</table>")
			TableResults = TableResults + ReturnTagInfo(CurrentSearchLine , "<table class="+Chr(34)+"results"+Chr(34)+">" , "</table>")
			TableResults = TableResults + ReturnTagInfo(CurrentSearchLine , "<table class="+Chr(34)+"results"+Chr(34)+">" , "</table>")
			
			CurrentSearchLine = TableResults

			Repeat
				RawWalkHTML = ReturnTagInfo(CurrentSearchLine , "<tr>" , "</tr>")
				If RawWalkHTML = "" Then Exit
				TempCurrentSearchLine = CurrentSearchLine
				CurrentSearchLine = RawWalkHTML
				Line1 = ReturnTagInfo(CurrentSearchLine , "<td class="+Chr(34)+"rmain"+Chr(34)+">" , "</td>")
				Line1 = Replace(Line1 , "	" , "")
				Line1 = Replace(Line1 , " " , "")
				If Instr(Line1 , "&nbsp;") > 0 Then
					Line1 = PrevPlat
				Else
					PrevPlat = Line1
				EndIf
				
				Line2 = ReturnTagInfo(CurrentSearchLine , "<td class="+Chr(34)+"rtitle"+Chr(34)+">" , "</td>")
				Line3 = ReturnTagInfo(CurrentSearchLine , "<td class="+Chr(34)+"rmain"+Chr(34)+">" , "</td>")
		
				
				If Instr(Line3 , "---") < 1 Then
					GameName = ReturnTagInfo(Line2 , ">" , "</a>")
					GameName = Replace(GameName,"&amp;","&")
					GameURL = ReturnTagInfo(Line3 , "<a href=" + Chr(34) , Chr(34) + ">")
					GamePlat = Line1
					Print GameName+" - "+GamePlat
					Print GameURL
					Print ""
					Guide = New DownloadListObject
					Guide.URL = GameURL
					Guide.Name = GameName+" - "+GamePlat
						
					ListAddLast(GuideList,Guide)
		
					
				EndIf 
				'Print RawWalkHTML
				CurrentSearchLine = TempCurrentSearchLine
			Forever
		
		Next
		Return GuideList
	End Function	
	
	Function SearchCheat_GFAQs:TList(Term:String,Plat:String)
		
		Local curl:TCurlEasy
		Local ResultNum:Int = 0
		Local GuideList:TList = CreateList()
		Local Guide:DownloadListObject
		
		Term = Replace(Replace(Term , " " , "+") , "&" , "and")
	
		For ResultNum = 0 To 1
			InternetTimeout = MilliSecs()
			File=WriteFile(TEMPFOLDER+"PatchHTML.txt")
			curl = TCurlEasy.Create()
			'curl.setOptString(CURLOPT_POSTFIELDS, "")
			curl.setOptInt(CURLOPT_FOLLOWLOCATION , 1)
			curl.setProgressCallback(TimeoutCallback) 
			curl.setOptInt(CURLOPT_HEADER, 0)
			curl.setWriteStream(File)
			curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
			curl.setOptString(CURLOPT_URL, "http://www.gamefaqs.com/search/index.html?game="+Term+"&page="+ResultNum+"&platform="+Plat)
			Error = curl.perform()
			CloseFile(File) 
			If Error > 0 Then
				Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null , "Website Timed Out" , "Info" , wxOK | wxICON_INFORMATION)
				MessageBox.ShowModal()
				MessageBox.Free()					
				Return GuideList	
			EndIf 
	
			
			ReadHTML=ReadFile(TEMPFOLDER+"PatchHTML.txt")
			CurrentSearchLine=""
			Repeat
				CurrentSearchLine=CurrentSearchLine+ReadLine(ReadHTML)
				If Eof(ReadHTML) Then Exit
			Forever
			CloseFile(ReadHTML)
			
			Local RawWalkHTML:String
			Local TempCurrentSearchLine:String
			Local Line1:String , Line2:String , Line3:String
			Local PrevPlat:String
			
			Local GameName:String , GameURL:String , GamePlat:String
			
			Local TableResults:String = ""
			TableResults = TableResults + ReturnTagInfo(CurrentSearchLine , "<table class="+Chr(34)+"results"+Chr(34)+">" , "</table>")
			TableResults = TableResults + ReturnTagInfo(CurrentSearchLine , "<table class="+Chr(34)+"results"+Chr(34)+">" , "</table>")
			TableResults = TableResults + ReturnTagInfo(CurrentSearchLine , "<table class="+Chr(34)+"results"+Chr(34)+">" , "</table>")
			
			CurrentSearchLine = TableResults
			
			Repeat
				RawWalkHTML = ReturnTagInfo(CurrentSearchLine , "<tr>" , "</tr>")
				If RawWalkHTML = "" Then Exit
				TempCurrentSearchLine = CurrentSearchLine
				CurrentSearchLine = RawWalkHTML
				Line1 = ReturnTagInfo(CurrentSearchLine , "<td class="+Chr(34)+"rmain"+Chr(34)+">" , "</td>")
				Line1 = Replace(Line1 , "	" , "")
				Line1 = Replace(Line1 , " " , "")
				If Instr(Line1 , "&nbsp;") > 0 Then
					Line1 = PrevPlat
				Else
					PrevPlat = Line1
				EndIf
				
				Line2 = ReturnTagInfo(CurrentSearchLine , "<td class="+Chr(34)+"rtitle"+Chr(34)+">" , "</td>")
				Line3 = ReturnTagInfo(CurrentSearchLine , "<td class="+Chr(34)+"rmain"+Chr(34)+">" , "</td>")
				Line3 = ReturnTagInfo(CurrentSearchLine , "<td class="+Chr(34)+"rmain"+Chr(34)+">" , "</td>")
				
				If Instr(Line3 , "---") < 1 Then
					GameName = ReturnTagInfo(Line2 , ">" , "</a>")
					GameName = Replace(GameName,"&amp;","&")
					GameURL = ReturnTagInfo(Line3 , "<a href=" + Chr(34) , Chr(34) + ">")
					GamePlat = Line1
					Print GameName+" - "+GamePlat
					Print GameURL
					Print ""
					Guide = New DownloadListObject
					Guide.URL = GameURL
					Guide.Name = GameName+" - "+GamePlat
						
					ListAddLast(GuideList,Guide)
		
					
				EndIf 
				'Print RawWalkHTML
				CurrentSearchLine = TempCurrentSearchLine
			Forever
		
		Next
		Return GuideList
	End Function	
	

	Function ChangeListTypeFun(event:wxEvent)
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		Local data:Object = event.userData
		Select String(data)
			Case "1"
				GameListStyle = wxLC_ICON | wxSUNKEN_BORDER | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE
				ShowIcons = 1
				SettingFile.SaveSetting("ListType" , "1")
				SettingFile.SaveFile()
			Case "2"
				GameListStyle = wxLC_LIST | wxSUNKEN_BORDER | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE
				ShowIcons = 1	
				SettingFile.SaveSetting("ListType" , "2")
				SettingFile.SaveFile()						
			Case "3"
				GameListStyle = wxLC_LIST | wxSUNKEN_BORDER | wxLC_SINGLE_SEL | wxLC_AUTOARRANGE					
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
		If String(data) = "RG" Then		
			RunProcess(EXPLORERPROGRAM+" -Runner 1 -GameName "+Chr(34)+GameN+Chr(34)+" -EXENum 1 -Cabinate 2",1)
			GameExploreWin.Close(True)
		Else
			Local RunNumber:Int = Int(String(data) )
			Print RunNumber
			RunProcess(EXPLORERPROGRAM+" -Runner 1 -GameName "+Chr(34)+GameN+Chr(34)+" -EXENum "+RunNumber+" -Cabinate 2",1)
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
			If GameNode.Trailer = "" Then
				MessageBox = New wxMessageDialog.Create(Null , "This game doesn't have a trailer associated with it" , "Info" , wxOK | wxICON_INFORMATION)
				MessageBox.ShowModal()
				MessageBox.Free()					
				Return
			Else
				OpenURL("http://www.youtube.com/watch?v="+GameNode.Trailer)
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
		If GameNode.GetGame(GameName) = - 1 Then
		
		Else
			Self.GameNotebook.Enable()
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Front_OPT.jpg") = 1 Then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Front_OPT.jpg" , 1)
			Else
				FBAPanel.SetImage("" , 1)
								
			EndIf
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Back_OPT.jpg") = 1 Then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Back_OPT.jpg" , 2)
			Else
				FBAPanel.SetImage("" , 2)
								
			EndIf			
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Screen_OPT.jpg") = 1 Then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Screen_OPT.jpg" , 3)
			Else
				FBAPanel.SetImage("" , 3)
								
			EndIf			
			If FileType(GAMEDATAFOLDER + GameName + FolderSlash + "Banner_OPT.jpg") = 1 Then
				FBAPanel.SetImage(GAMEDATAFOLDER + GameName + FolderSlash + "Banner_OPT.jpg" , 4)
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
			
			Self.PatchList.Clear()
			Self.LocalPatchList.Clear()		
			Self.LocalPatchFileList.Clear()
			Self.WalkList.Clear()
			Self.LocalWalkList.Clear()		
			Self.LocalWalkFileList.Clear()			
			Self.ManualList.Clear()
			Self.LocalManualList.Clear()	
			Self.WalkSearchCatBox.SetSelection(0)		
			Self.CheatList.Clear()
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

			If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Cheats") = 2 Then

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
			
			If FileType(GAMEDATAFOLDER+GameNode.OrginalName+FolderSlash+"Guides") = 2 Then
				ReadWalks = ReadDir(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash +"Guides")
				Repeat
					File = NextFile(ReadWalks)
					If File = "" Then Exit
					If File="." Or File=".." Then Continue
					If FileType(GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash + "Guides" + FolderSlash + File) = 2 Then
						Self.LocalWalkList.Append(File)
					EndIf
				Forever
				CloseDir(ReadWalks)
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
			
			Self.PatchSearchBox.ChangeValue(GameNode.Name)
			Self.WalkSearchBox.ChangeValue(GameNode.Name)
			Self.ManualSearchBox.ChangeValue(GameNode.Name)
			Self.CheatSearchBox.ChangeValue(GameNode.Name)
			Self.GGenreText.SetLabel("Genre: " + CorrectText(GenreList) )
			Self.GDevText.SetLabel("Developer: " + CorrectText(GameNode.Dev) )
			Self.GPubText.SetLabel("Publisher: " + CorrectText(GameNode.Pub) )
			Self.GRDateText.SetLabel("Release Date: " + GetDateFromCorrectFormat(GameNode.ReleaseDate) )
			Self.GCertText.SetLabel("Certificate: " + CorrectText(GameNode.Cert) )
			Self.GCoopText.SetLabel("Co-Op: " + CorrectText(GameNode.Coop) )
			Self.GPlayersText.SetLabel("Players: " + CorrectText(GameNode.Players) )
			Self.GPlatText.SetLabel("Platform: " + CorrectText(GameNode.Plat) )
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
			If GameNode.Trailer = "" Then
				If Self.GameNotebook.GetPageText(Self.GameNotebook.GetSelection())="Trailer" Then
					If Connected = 1 Then
						Local Vid:String = GetYoutube()
						Print Vid
						If Vid = "" Then
						
						Else
							?Win32	
							Self.TrailerCtrl.Load("http://www.youtube.com/v/" + Vid)
							?
						EndIf
					EndIf
				EndIf 
			Else
				?Win32
				Self.TrailerCtrl.Load("http://www.youtube.com/v/" + GameNode.Trailer)
				?
			EndIf 
			Self.GDPvbox.RecalcSizes()
			FBAPanel.Refresh()
			GS_SC1_Panel.Refresh()
			GS_SC2_Panel.Refresh()
			GameDetailsPanel.Refresh()
		EndIf

	End Method
	
	Function GetYoutube:String()
		Local TFile:TStream
		Trailercurl = TCurlEasy.Create()
		TFile=WriteFile(TEMPFOLDER+"YoutubeHTML.xml")
		Trailercurl.setOptInt(CURLOPT_FOLLOWLOCATION , 1)
		Trailercurl.setOptInt(CURLOPT_HEADER, 0)
		Trailercurl.setOptString(CURLOPT_CAINFO, "ca-bundle.crt")
		Trailercurl.setWriteStream(TFile)
		Trailercurl.setOptString(CURLOPT_URL, "https://gdata.youtube.com/feeds/api/videos?q="+Replace(Replace(GameNode.Name," ","+"),"&","")+"+Trailer&max-results=1&v=2")
		Error=Trailercurl.perform()
		CloseFile(TFile)	
	
		Local Gamedoc:TxmlDoc
		Local RootNode:TxmlNode , node:TxmlNode 
		
		Gamedoc = TxmlDoc.parseFile(TEMPFOLDER+"YoutubeHTML.xml")
	
		If Gamedoc = Null Then
			PrintF("XML Document not parsed successfully")
			Return ""				
		End If
		
		RootNode = Gamedoc.getRootElement()
		
		If RootNode = Null Then
			Gamedoc.free()
			PrintF("Empty document")
			Return ""	
			'CustomRuntimeError( "Error 40: Empty document, GetGameXML. "+ GName) 'MARK: Error 40
		End If		

		If RootNode.getName() <> "feed" Then
			Gamedoc.free()
			PrintF("Document of the wrong type, root node <> feed")
			Return ""
		End If
		
		Local ChildrenList:TList = RootNode.getChildren()
		If ChildrenList = Null Or ChildrenList.IsEmpty() Then
			Gamedoc.free()
			PrintF("Document error, no data contained within")
			Return ""
		EndIf
		For node = EachIn ChildrenList
			If node.getName() = "entry"
				ChildrenList = node.getChildren()
				For node = EachIn ChildrenList
					If node.getName() = "group" Then
						ChildrenList:TList = node.getChildren()
						For node = EachIn ChildrenList
							If node.getName() = "videoid" Then
								Return node.getText()
							EndIf 
						Next
						Exit
					EndIf 
				Next
				Exit
			EndIf 
		Next
		Return ""
	End Function 
	
	Function CorrectText:String(Text:String)
		Text = Replace(Text , "&" , "&&")
		Return Text
	End Function

	Function GameListUpdate(event:wxEvent)
		PrintF("----------------------------Updating Game List----------------------------")
		Local GameExploreWin:GameExplorerFrame = GameExplorerFrame(event.parent)
		SettingFile.SaveSetting("Sort" , GameExploreWin.SortCombo.GetValue())
		SettingFile.SaveSetting("Filter" , GameExploreWin.FilterTextBox.GetValue())
		SettingFile.SaveSetting("Platform" , GameExploreWin.PlatformCombo.GetValue())
		SettingFile.SaveFile()			
		GameExploreWin.PopulateGameList()
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
		
		Local PlatformFilterType:String = PlatformCombo.GetValue()
		PrintF("Platform: "+PlatformFilterType)
		GameDir = ReadDir(GAMEDATAFOLDER)
		Local EvaluationGameNum = 0
		Repeat
			item$=NextFile(GameDir)
			If item = "." Or item = ".." Then Continue
			If item = "" Then Exit
			GameNode:GameReadType = New GameReadType
			If GameNode.GetGame(item) = - 1 Then
			
			Else
				If GameNode.Plat=PlatformFilterType Or PlatformFilterType="All" Then
					ListAddLast(GamesTList,item)
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
		ConnectANY( wxEVT_LEFT_DCLICK , ImageLeftClickedFun)
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
			If FileType(Left(temp,Len(temp)-8)+".jpg") = 1 Then
				OpenURL(Left(temp , Len(temp) - 8) + ".jpg")
			ElseIf FileType(temp) = 1 Then
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
		dc.SetBackground(New wxBrush.CreateFromColour(New wxColour.Create(MainColor_R,MainColor_G,MainColor_B), wxTRANSPARENT))
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
		dc.free()
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
		If ImageT > 5 Or ImageT < 1 Then
			CustomRuntimeError("Error 104: Wrong ImageType") 'MARK: Error 104
		EndIf
		ImageType = ImageT
			
	End Method
	
	Function ImageLeftClickedFun(event:wxEvent)
		Local IPanel:ScreenShotPanel = ScreenShotPanel(event.parent)
		Local temp:String = IPanel.Image[IPanel.ImageType-1]
		If temp = "" Then
		
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
		dc.SetBackground(New wxBrush.CreateFromColour(New wxColour.Create(MainColor_R,MainColor_G,MainColor_B), wxSOLID))
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
		dc.free()
	End Function
	
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
		CabinateEnable = Int(ReadSettings.GetSetting("Cabinate"))
	EndIf 
	If ReadSettings.GetSetting("RunnerButtonCloseOnly") <> "" Then	
		RunnerButtonCloseOnly = Int(ReadSettings.GetSetting("RunnerButtonCloseOnly"))
	EndIf 
	If ReadSettings.GetSetting("OriginWaitEnabled") <> "" Then	
		OriginWaitEnabled = Int(ReadSettings.GetSetting("OriginWaitEnabled"))
	EndIf 			
	ReadSettings.CloseFile()
End Function

Function FitPixmapIntoBox:TPixmap(Pixmap:TPixmap,IconSize:Int,Banner:Int = -1)
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
		ClearPixels(Pixmap2,-44563)
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

Include "Includes\GameExplorerShell\PhotonTray.bmx"
Include "Includes\GameExplorerShell\PhotonRunner.bmx"
Include "Includes\GameExplorerShell\ProcessManager.bmx"
Include "Includes\General\ValidationFunctions.bmx"
Include "Includes\General\General.bmx"
