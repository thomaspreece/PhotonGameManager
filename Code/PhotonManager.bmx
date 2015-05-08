'TODO: Finish Lua Implementation of
'	-AutoSearch OnlineAdd
'	-AutoSearch SearchOnlineImport
'	-AutoSearch GameExplorerImport
'	-ManualSearch GameExplorerImport

'TODO: Add Sorting to thegamesdb.net lua script
'TODO: Reorder settings window
'TODO: Add progress bars to Log Window
'TODO: Re-enable automatic Icon extract
'TODO: Convert OnlineImport2 to similar format as SteamOnlineImport2

'SUPER IMPORTANT

'TODO: Fix the way platforms are done...

'END OF SUPER IMPORTANT

'TODO: OnlineAdd and SteamOnlineImport2 - scan for already added games and add to spreadsheet
'TODO: Find a way to check if icon is compatable with wxwidgets
'TODO: Check online database in imports to properly match games up.
'TODO: Add game selections to online database
'TODO: Check that RunProcess doesn't screw up Executables other than mine
'TODO: Fix controls so you can tab between them
'TODO: Update GDF import to use libxml and to look at all bin files

'NOTHING IMPORTANT HERE

'LINUX: Change file paths to get working on linux
'       -Done PhotonManager and all its includes
'       -Done PhotonExplorer and all its includes
'       -Done PhotonFrontend and all its includes
'wxAPP contains yield controls!

'All subfiles checked, no pending fixes found
'BUG: My Programs Crash when Using CreateProcess on Windows to load them from another program, No Idea Why... FIXED: with WinExec used for my programs ONLY
'TODO: Detect/ Load Country (in General/GlobalConsts) (for Global Country:String = "UK")
'FIX: When Log window is closed by user it causes all sorts of errors. Mainly arwork not downloaded, steam not correctly found.
'Ex: Open Databasemanager, run steam wiz, close when searching, input steam manual, run steam wizard
'SETTING: RGB for interface
'FIX: Load in platforms from online database
'FIX: Platform overide if ManualPlatforms.txt detected
'FIX: Icon png/jpg - Need FreeImage... Appears to fail badly(freeimage that is)
'FIX: All Wizards in separate processes
'FIX: UpdateGame needs to load as separate process

'END OF NOTHING IMPORTANT HERE





Framework wx.wxApp
Import wx.wxFrame
'Import wx.wxtimer
Import wx.wxMenu
'Import wx.wxAboutBox
Import wx.wxButton
Import wx.wxBitmapButton
Import wx.wxPanel
Import wx.wxStaticText
Import wx.wxComboBox
Import wx.wxWizard
Import wx.wxListCtrl
'?MacOS
'Import wx.wxChoicebook
'?Not MacOS
Import wx.wxNotebook
'?
Import wx.wxTextCtrl
Import wx.wxMessageDialog
Import wx.wxFileDialog
Import wx.wxDirDialog 
'Import wx.wxStaticBitmap
Import wx.wxBitmap
Import wx.wxTimer
Import wx.wxStaticText
Import wx.wxCheckListBox
Import wx.wxCheckBox
Import wx.wxScrolledWindow
Import wx.wxStaticLine
Import wx.wxPlatformInfo
Import wx.wxSplitterWindow
Import wx.wxMouseEvent
Import wx.wxHyperlinkCtrl

Import BaH.libcurlssl
Import Bah.libxml
Import Bah.Volumes
Import bah.regex

Import BRL.JPGLoader
Import BRL.PNGLoader
'Import BAH.FreeImage
Import BRL.Threads

Import BRL.StandardIO
Import BRL.LinkedList
Import BRL.FileSystem
Import BRL.Retro
Import BRL.PolledInput
Import BRL.OpenALAudio 
Import BRL.DirectSoundAudio
Import BRL.FreeAudioAudio 
Import BRL.WAVLoader
Import BRL.OGGLoader
Import Pub.FreeProcess
Import Pub.FreeJoy

Import sidesign.minib3d

?Win32
Import "Icons\PhotonManager.o"
?


Import LuGI.Core
Include "ManagerGlue.bmx"

''Must Generate Glue Code in UnThreaded Mode
'Import LuGI.Generator
'GenerateGlueCode("ManagerGlue.bmx")
'End


?Not Win32
Global FolderSlash:String = "/"
?Win32
Global FolderSlash:String = "\"
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
Include "Includes\DatabaseManager\GlobalsConsts.bmx"

' Revision Version Generation Code
' @bmk include Includes/General/Increment.bmk
' @bmk doOverallVersionFiles Version/OverallVersion.txt
?Win32
' @bmk doIncrement Version/PM-Version.txt 1
?Mac
' @bmk doIncrement Version/PM-Version.txt 2
?Linux
' @bmk doIncrement Version/PM-Version.txt 3
?
Incbin "Version/PM-Version.txt"
Incbin "Version/OverallVersion.txt"

Global SubVersion:String = ExtractSubVersion(LoadText("incbin::Version/PM-Version.txt"), 1)
Global OSubVersion:String = ExtractSubVersion(LoadText("incbin::Version/OverallVersion.txt"), 1)

Print "Version = " + CurrentVersion
Print "SubVersion = " + SubVersion
Print "OSubVersion = " + OSubVersion


If FileType("DebugLog.txt")=1 Then 
	DebugLogEnabled = True
EndIf

FolderCheck()
LogName = "Log-Manager "+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
CreateFile(LOGFOLDER+LogName)

AppTitle = "PhotonManager"


LoadGlobalSettings()
CheckKey()
If EvaluationMode = True Then
	Notify "You are running in evaluation mode, this limits you to the first 5 games added to the database in FrontEnd and PhotonExplorer"
EndIf 
SearchBeep = LoadSound("Resources"+FolderSlash+"BEEP.wav")


?Win32
WinDir = GetEnv("WINDIR")
PrintF("Windows Folder: "+WinDir)
?


GlobalPlatforms = New PlatformReader
If FileType(SETTINGSFOLDER + "Platforms.xml") = 1 Then
	GlobalPlatforms.ReadInPlatforms()	
Else
	GlobalPlatforms.PopulateDefaultPlatforms()
	GlobalPlatforms.ReadInPlatforms()
EndIf

'TODO: REMOVE THIS FUNCTION FROM ALL FILES
PlatformListChecks()

CheckInternet()
'CheckPGMInternet()

CheckVersion()
CheckEXEDatabaseStatus()

'ValidateGames()

If wxIsPlatform64Bit() = 1 Then
	PrintF("Detected 64bit")
	WinBit = 64
Else
	PrintF("Detected 32bit")
	WinBit = 32
EndIf



?Win32
Local OSMajor:Int 
Local OSMinor:Int
wxGetOsVersion(OSMajor,OSMinor)

PrintF("Detected Win Version: "+OSMajor+"."+OSMinor)

If OSMajor => 6 Then
	WinExplorer = True
Else
	WinExplorer = False
EndIf
?Not Win32
	WinExplorer = False
?

LuaVM = luaL_newstate()
InitLuGI(LuaVM)
luaL_openlibs(LuaVM)


Local RunWizard:Int = -1

Local PastArgument:String 
For Argument$ = EachIn AppArgs$
	Select PastArgument
		Case "-EditGame","EditGame"
			EditGameName = Argument
			PastArgument = ""
		Case "-Wiz","Wiz"
			RunWizard = Int(Argument)
			PastArgument = ""
		Case "-Debug","Debug"
			If Int(Argument) = 1 Then 
				DebugLogEnabled = True
			EndIf 
			PastArgument = ""
		Default
			Select Argument
				Case "-Wiz" , "-Debug" , "-EditGame","Wiz" , "Debug" , "EditGame"
					PastArgument = Argument
			End Select
	End Select
Next

Global DatabaseApp:wxApp

If DebugLogEnabled=False Then 
	DeleteFile(LOGFOLDER+LogName)
EndIf 

Rem
If RunWizard = 1 Then
	
	DatabaseApp = New SteamOnlineImportApp
	DatabaseApp.Run()
	End
EndIf 
EndRem

DatabaseApp = New DatabaseManager
DatabaseApp.Run()

'If ReloadApp = True Then
'	RestartProgram()
'EndIf
End

Type DatabaseManager Extends wxApp
	Field Menu:MainWindow
	'Field Menu2:DatabaseSearchPanelType
	
	Method OnInit:Int()
		wxImage.AddHandler( New wxICOHandler)		
		wxImage.AddHandler( New wxPNGHandler)		
		wxImage.AddHandler( New wxJPEGHandler)
		'wxImage.AddHandler( New wxJPEGHandler)			
		
		New PMFactory
		
		'Local Menu2 = DatabaseSearchPanelType(New DatabaseSearchPanelType.Create(Null , wxID_ANY, "DatabaseManager", - 1, - 1, 600, 400) )
   
		Menu = MainWindow(New MainWindow.Create(Null , wxID_ANY, "DatabaseManager", - 1, - 1, 600, 400) )
		Return True

	End Method
	
End Type

lua_close(LuaVM)

'----------------------------------------------------------------------------------------------------------
'-------------------------------------MAIN WINDOW----------------------------------------------------------
Type MainWindow Extends wxFrame
	
	'Sub Windows
	Field EditGameListField:EditGameList	
	'Field OfflineImportField:OfflineImport
	Field OfflineImport2Field:OfflineImport2
	'Field SteamOfflineImportField:SteamOfflineImport
	'Field SteamOnlineImportField:SteamOnlineImport
	Field SteamOnlineImport2Field:SteamOnlineImport2
	'Field OnlineImportField:OnlineImport
	Field OnlineImport2Field:OnlineImport2
	Field ImportMenuField:ImportMenu	
	Field AddGamesMenuField:AddGamesMenu
	Field SteamMenuField:SteamMenu
	'Field ManualAddField:ManualAdd
	Field OnlineAddField:OnlineAdd
	Field SteamCustomAddField:SteamCustomAdd	
	Field EmulatorsListField:EmulatorsList
	Field SettingsWindowField:SettingsWindow
	Field SettingsMenuField:SettingsMenu
	Field PluginsWindowField:PluginsWindow
	Field ActivateMenuField:ActivateMenu
	'Field SteamIconWindowField:SteamIconWindow
	
	'Buttons
	Field AGButton:wxBitmapButtonExtended
	'Field IGButton:wxBitmapButtonExtended
	Field EGButton:wxBitmapButtonExtended
	Field EButton:wxBitmapButtonExtended
	Field GSButton:wxBitmapButtonExtended
	Field UGMButton:wxButton
	Field Back:wxButton
	Field Activate:wxButton
'	Field Timer:wxtimer

	Field HelpBox:wxTextCtrl

	Method OnInit()
		Log1 = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Log" , , , 300 , 400) )
		
		Self.Centre()
		'timer = New wxTimer.Create(Self , wxID_ANY)
		'timer.Start(3000)
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(200,200,255))
		'Self.Refresh
		
		
		
		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 8)	
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		AGbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "AddButton.png" , wxBITMAP_TYPE_PNG)
		AGButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , MW_AGB , AGbitmap) )
		AGButton.SetFields("Add new games to GameManager here.", HelpBox)
		AGButton.SetForegroundColour(New wxColour.Create(100 , 100 , 255) )
	
		EGbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"EditGames.png" , wxBITMAP_TYPE_PNG)
		EGButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , MW_EGB , EGbitmap) )
		EGButton.SetFields("Edit games that you have already added to GameManager.", HelpBox)
		EGButton.SetForegroundColour(New wxColour.Create(100 , 100 , 255) )
		
		Ebitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"Emulators.png" , wxBITMAP_TYPE_PNG)
		EButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , MW_EB , Ebitmap) )
		EButton.SetFields("Change the default emulator for all games of a certain platform that have already been added to GameManager.", HelpBox)
		EButton.SetForegroundColour(New wxColour.Create(100 , 100 , 255) )
		
		GSbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"Settings.png" , wxBITMAP_TYPE_PNG)
		GSButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , MW_GS , GSbitmap) )
		GSButton.SetFields("Change settings for the whole of the GameManager suite. Also backup and restore your game database. Furthermore change plugin settings.", HelpBox)
		GSButton.SetForegroundColour(New wxColour.Create(100 , 100 , 255) )
		
		'UGMButton = New wxButton.Create(Self , MW_UGM , "Update GameManager")
		
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Activate = New wxButton.Create(Self , MW_A , "Activate")
		Back = New wxButton.Create(Self , wxID_EXIT , "Quit")
		
		hbox.Add(Activate, 1 , wxALL, 6)
		hbox.Add(Back, 1 , wxALL, 6)
		
		If EvaluationMode = False Then
			Activate.show(0)
		EndIf
		
		'AGButton = New wxButton.Create(Self, MW_AGB , "Add Game/s")			
		'EGButton = New wxButton.Create(Self , MW_EGB , "Edit Game/s")		
		'EButton = New wxButton.Create(Self , MW_EB , "Emulators")		
		'GSButton = New wxButton.Create(Self , MW_GS , "General Settings")		
		
		vbox.Add(AGButton, 2 , wxEXPAND | wxTOP | wxRIGHT | wxLEFT, 8)				
		vbox.Add(EGButton, 2 , wxEXPAND | wxTOP | wxRIGHT | wxLEFT, 8)		
		vbox.Add(EButton, 2 , wxEXPAND | wxTOP | wxRIGHT | wxLEFT, 8)	
		vbox.Add(GSButton , 2 , wxEXPAND | wxTOP | wxRIGHT | wxLEFT, 8)	
		vbox.AddSizer(hbox, 1 , wxEXPAND | wxTOP | wxRIGHT | wxLEFT, 8 )
		'vbox.Add(UGMButton,  2 , wxEXPAND | wxTOP | wxRIGHT | wxLEFT, 8)	
		

		
 		
		Local Mainhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Mainhbox.AddSizer(vbox, 1 , wxEXPAND, 0)
		Mainhbox.AddSizer(vbox2, 1 , wxEXPAND , 0)

		SetSizer(Mainhbox)
	
		Connect(MW_AGB, wxEVT_COMMAND_BUTTON_CLICKED, ShowGamesList)
		Connect(MW_EGB, wxEVT_COMMAND_BUTTON_CLICKED, ShowEditGameList)
		Connect(MW_EB, wxEVT_COMMAND_BUTTON_CLICKED, ShowEmulatorsList)
		Connect(MW_GS , wxEVT_COMMAND_BUTTON_CLICKED , ShowSettingsWindow)
		Connect(MW_A , wxEVT_COMMAND_BUTTON_CLICKED , ShowActivateWindow)
		
		Connect(wxID_EXIT, wxEVT_COMMAND_BUTTON_CLICKED, OnQuit)
		ConnectAny(wxEVT_CLOSE , OnQuit)
		
		
		
		'EditGameListField = EditGameList(New EditGameList.Create(Self, wxID_ANY, "Games", , , 800, 600))	
		'EditGameListField Now loaded on demand
		
		'Menus not needed to be loaded on demand
		ImportMenuField = ImportMenu(New ImportMenu.Create(Self , wxID_ANY , "Import Select" , , , 600 , 400) )
		SteamMenuField = SteamMenu(New SteamMenu.Create(Self, wxID_ANY, "Steam Import Select", , , 600, 400) )
		AddGamesMenuField = AddGamesMenu(New AddGamesMenu.Create(Self, wxID_ANY, "Add Games Select", , , 600, 400) )
		SettingsMenuField = SettingsMenu(New SettingsMenu.Create(Self , wxID_ANY , "Settings Select" , , , 600 , 400) )	
		ActivateMenuField = ActivateMenu(New ActivateMenu.Create(Self , wxID_ANY , "Activate" , , , 300 , 200) )
						
		'OnlineAddField Now loaded on demand
		'OnlineAddField = OnlineAdd(New OnlineAdd.Create(Self, wxID_ANY, "Add Games via Online Database", , , 800, 600))	
		
					
		SteamCustomAddField = SteamCustomAdd(New SteamCustomAdd.Create(Self , wxID_ANY , "Add Custom Steam ID" , , , 600 , 400) )						
		
		'SettingsWindowField now loaded on demand
		'SettingsWindowField = SettingsWindow(New SettingsWindow.Create(Self , wxID_ANY , "General Settings" , , , 800 , 600) )	
		
		'PluginsWindow				
		'PluginsWindowField = PluginsWindow(New PluginsWindow.Create(Self , wxID_ANY , "Plugin Settings" , , , 800 , 600) )
		
								
		'EmulatorsListField = EmulatorsList(New EmulatorsList.Create(Self, wxID_ANY, "Emulator List", , , 800, 600))						

	
		Show()			
		Self.Enable()
		Self.SetFocus()		

		If EditGameName <> "" Then 
			Show(0)
			CommandEvent:wxEvent = New wxEvent
			CommandEvent.Parent = Self.GetEventHandler()
			ShowEditGameList(CommandEvent)
		EndIf
		
	End Method
	
	Method ResetEditGameWindow()
		EditGameListField.Destroy()
		EditGameListField = Null 
		EditGameListField = EditGameList(New EditGameList.Create(Self, wxID_ANY, "Games", , , 900, 650))	
		EditGameListField.PopulateGameList()		
		EditGameListField.Show(True)
		EditGameListField.Raise()
	End Method
	
	Function ShowSettingsWindow(event:wxEvent)
		Local MainWin:MainWindow = MainWindow(event.parent)
		PrintF("----------------------------Show Settings Window----------------------------")
		MainWin.Hide()
		MainWin.SettingsMenuField.Show(True)
		MainWin.SettingsMenuField.Raise()
	End Function	
	
	Function ShowActivateWindow(event:wxEvent)
		Local MainWin:MainWindow = MainWindow(event.parent)
		PrintF("----------------------------Show Activate Window----------------------------")
		MainWin.Hide()
		MainWin.ActivateMenuField.Show(True)
		MainWin.ActivateMenuField.Raise()
	End Function	
	
	Function ShowEmulatorsList(event:wxEvent)
		Local MainWin:MainWindow = MainWindow(event.parent)
		PrintF("----------------------------Show Emulator List----------------------------")
		
		MainWin.EmulatorsListField = EmulatorsList(New EmulatorsList.Create(MainWin , wxID_ANY , "Emulator List" , , , 800 , 600) )	
		MainWin.EmulatorsListField.Show(True)
		MainWin.Hide()
		MainWin.EmulatorsListField.Raise()
	End Function		
	
	Function ShowGamesList(event:wxEvent)
		Local MainWin:MainWindow = MainWindow(event.parent)
		PrintF("----------------------------Show Add Games Menu----------------------------")
		MainWin.AddGamesMenuField.Show(True)
		MainWin.Hide()		
		MainWin.AddGamesMenuField.Raise()
	End Function

	Function ShowEditGameList(event:wxEvent)
		Local MainWin:MainWindow = MainWindow(event.parent)
		PrintF("----------------------------Show Edit Game List----------------------------")
		MainWin.EditGameListField = EditGameList(New EditGameList.Create(MainWin, wxID_ANY, "Games", , , 900, 650))	
		MainWin.EditGameListField.PopulateGameList()		
		MainWin.EditGameListField.Show(True)
		MainWin.Hide()
		MainWin.EditGameListField.Raise()
	End Function

	Function OnQuit(event:wxEvent)
		' true is to force the frame to close
		End 
	End Function
End Type
'----------------------------------------------------------------------------------------------------------
'------------------------------EDIT GAME LIST--------------------------------------------------------------
Include "Includes\DatabaseManager\EditGameList.bmx"
'----------------------------------------------------------------------------------------------------------
'------------------------------ADD GAMES MENU--------------------------------------------------------------
Type AddGamesMenu Extends wxFrame
	Field ParentWin:MainWindow	
	Field MButton:wxBitmapButtonExtended
	Field OButton:wxBitmapButtonExtended
	Field SButton:wxBitmapButtonExtended
	Field IGButton:wxBitmapButtonExtended
	Field Back:wxButton
	
	
	Field HelpBox:wxTextCtrl
			
							
	Method OnInit()
		ParentWin = MainWindow(GetParent() )
		
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )		
		Self.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )	

		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 8)	
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Mbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "Manual.png" , wxBITMAP_TYPE_PNG)		
		MButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , AGM_MB , Mbitmap) )
		MButton.SetFields("Here you can add a blank game to the database. This is useful if your game is not on any of the online databases available with the 'Online Add' button above or if you do not have a internet connection.", HelpBox)
		'MButton = New wxButton.Create(Self , AGM_MB , "Add a Game Manually")
		Obitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"Online.png" , wxBITMAP_TYPE_PNG)		
		OButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , AGM_OB , Obitmap)	)
		OButton.SetFields("Here you can search your computer for games and download the relevant game data to your database from online sources.", HelpBox)
		'OButton = New wxButton.Create(Self, AGM_OB , "Add Games via Online Database")
		Sbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "SteamImport.png" , wxBITMAP_TYPE_PNG)		
		SButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , AGM_SB , Sbitmap) )
		SButton.SetFields("Here you can add steam games. You are given the option to manually add them or to automatically scan and add games to your database using online sources. ~n~nIf you have any steam games then we highly recommend you use this option before using the 'Online Add' or 'Manual Add' options.", HelpBox)
		'SButton = New wxButton.Create(Self , AGM_SB , "Add Steam Games")
		IGbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "GEImport.png" , wxBITMAP_TYPE_PNG)		
		IGButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , AGM_IGB , IGbitmap) )
		IGButton.SetFields("If you have games shown under Window's Games Explorer you can use this option to quickly extract the information from your system with the option to fill in missing data from online sources. ~n~nIf you have games in Games Explorer then we highly recommend you use this option before  using the 'Online Add' or 'Manual Add' options.", HelpBox)
		'IGButton = New wxButton.Create(Self, AGM_IGB , "Import Game/s from Game Explorer")
		
		Back = New wxButton.Create(Self,AGM_BB, "Back")

		vbox.Add(IGButton , 2 , wxEXPAND |  wxTOP | wxRIGHT | wxLEFT, 8)				
		vbox.Add(SButton , 2 , wxEXPAND |  wxTOP | wxRIGHT | wxLEFT, 8)
		vbox.Add(OButton,  2 , wxEXPAND |  wxTOP | wxRIGHT | wxLEFT, 8)		
		vbox.Add(MButton , 2 , wxEXPAND |  wxTOP | wxRIGHT | wxLEFT, 8)			
		vbox.Add(Back,  1 , wxALIGN_LEFT | wxALL, 6)		


		Local Mainhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Mainhbox.AddSizer(vbox, 1 , wxEXPAND, 0)
		Mainhbox.AddSizer(vbox2, 1 , wxEXPAND , 0)

		SetSizer(Mainhbox)		

		
		If WinExplorer = False Then IGButton.Disable()
		
		Centre()
		Hide()		
		Connect(AGM_BB, wxEVT_COMMAND_BUTTON_CLICKED, ShowMainMenu)
		Connect(AGM_MB, wxEVT_COMMAND_BUTTON_CLICKED, ShowMA)
		Connect(AGM_OB, wxEVT_COMMAND_BUTTON_CLICKED, ShowOA)
		Connect(AGM_SB , wxEVT_COMMAND_BUTTON_CLICKED , ShowSA)	
		Connect(AGM_IGB , wxEVT_COMMAND_BUTTON_CLICKED , ShowIG)	
		'ConnectAny(wxEVT_CLOSE, ShowMainMenu)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method
	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = AddGamesMenu(event.parent).ParentWin
		MainWin.Close(True)
	End Function	
	
	Function ShowMA(event:wxEvent)
		PrintF("----------------------------Manual Game Add Selected----------------------------")
		Local MainWin:MainWindow = AddGamesMenu(event.parent).ParentWin
		newevent:wxEvent = event
		newevent.parent = MainWin.GetEventHandler()
		MainWin.ShowEditGameList(event)		
		MainWin.AddGamesMenuField.Hide()
		Local a:Int = 0
		Repeat
			If FileType(GAMEDATAFOLDER + "A_NewGame_" + String(a) + "---0" ) = 2 Then
				a=a+1
			Else
				PrintF(GAMEDATAFOLDER + "A_NewGame_" + String(a) + "---0"+ " Selected")
				Local GameNode:GameType = New GameType
				GameNode.NewGame()
				GameNode.Name = "A_NewGame_" + String(a)
				GameNode.PlatformNum = 0
				GameNode.SaveGame()
				Exit
			EndIf
		Forever
		
		MainWin.EditGameListField.PopulateGameList()
		
		PrintF("Selecting new game in list")
		Local ID:Int = MainWin.EditGameListField.GameList.FindItem( - 1 , "A_NewGame_" + String(a) )
		MainWin.EditGameListField.GameList.SetitemState(ID,wxLIST_STATE_SELECTED,wxLIST_MASK_TEXT | wxLIST_MASK_IMAGE  )
	End Function
	
	Function ShowIG(event:wxEvent)
		PrintF("----------------------------Import Menu Selected----------------------------")
		Local MainWin:MainWindow = AddGamesMenu(event.parent).ParentWin
		MainWin.ImportMenuField.Show()
		MainWin.AddGamesMenuField.Hide()
	End Function
		
	Function ShowOA(event:wxEvent)
		Local MessageBox:wxMessageDialog	
		PrintF("----------------------------Online Game Add Selected----------------------------")
		Local MainWin:MainWindow = AddGamesMenu(event.parent).ParentWin
		If Connected = False Then 
			CheckInternet()		
		EndIf 	
		If Connected = True Then 
			MainWin.OnlineAddField = OnlineAdd(New OnlineAdd.Create(MainWin, wxID_ANY, "Add Games via Online Database", , , 800, 600))
			MainWin.OnlineAddField.Show()
			MainWin.AddGamesMenuField.Hide()
		Else
			MessageBox = New wxMessageDialog.Create(Null , "You Are Not Connected to the Internet" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
		EndIf 
	End Function

	Function ShowSA(event:wxEvent)
		PrintF("----------------------------Steam Import Menu Selected----------------------------")
		Local MainWin:MainWindow = AddGamesMenu(event.parent).ParentWin
		MainWin.SteamMenuField.Show()
		MainWin.AddGamesMenuField.Hide()
	End Function

	Function ShowMainMenu(event:wxEvent)
		Local MainWin:MainWindow = AddGamesMenu(event.parent).ParentWin
		MainWin.Show()
		MainWin.AddGamesMenuField.Hide()			
	End Function
	
End Type
'----------------------------------------------------------------------------------------------------------
'-----------------------------------MANUAL ADD---------------------------------------------------------
Rem
Type ManualAdd Extends wxFrame 
	Field BackButton:wxButton
	Field ParentWin:MainWindow
	
	Method OnInit()
		ParentWin = MainWindow(GetParent())
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		BackButton = New wxButton.Create(Self, 101 , "Back")
		hbox.Add(BackButton,  1 , wxEXPAND | wxALL, 20)		
		SetSizer(hbox)
		Centre()		
		Hide()
		Connect(101, wxEVT_COMMAND_BUTTON_CLICKED, ShowMainMenu)
	End Method

	Function ShowMainMenu(event:wxEvent)
		Local MainWin:MainWindow = ManualAdd(event.parent).ParentWin
		MainWin.Show()
		MainWin.ManualAddField.Hide()			
	End Function

	Function OnQuit(event:wxEvent)
		' true is to force the frame to close
		wxWindow(event.parent).Close(True)
	End Function
End Type
EndRem
'----------------------------------------------------------------------------------------------------------
'-----------------------------------ONLINE ADD---------------------------------------------------------
Include "Includes/DatabaseManager/OnlineAdd.bmx"
Include "Includes/DatabaseManager/EXESort.bmx"
'----------------------------------------------------------------------------------------------------------
'-----------------------------------STEAM ADD---------------------------------------------------------
Type SteamCustomAdd Extends wxFrame 
	Field BackButton:wxButton
	Field ParentWin:MainWindow
	Field NameTextBox:wxTextCtrl
	Field IDTextBox:wxTextCtrl
	
	Method OnInit()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )

		ParentWin = MainWindow(GetParent())
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Self.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
		
		Local ExplainST:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , SCA_ET_Text , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		
		Local NameText:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , "Name:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		NameTextBox = New wxTextCtrl.Create(Self, SCA_NTB , "" , - 1 , - 1 , - 1 , - 1 , 0 )		
		Local IDText:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , "Steam ID:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		IDTextBox = New wxTextCtrl.Create(Self, SCA_ITB , "" , - 1 , - 1 , - 1 , - 1 , 0 )	
		
		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
		Local P1Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		BackButton:wxButton = New wxButton.Create(Panel1 , SCA_BB , "Back")
		HelpButton:wxButton = New wxButton.Create(Panel1, SCA_HB , "Help")
		OKButton:wxButton = New wxButton.Create(Panel1, SCA_OB , "OK")

		P1Hbox.Add(BackButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.Add(HelpButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.Add(OKButton , 1 , wxEXPAND | wxALL , 10)
		
		Panel1.SetSizer(P1Hbox)
		
		vbox.Add(ExplainST , 1 , wxEXPAND | wxALL , 5)
		vbox.Add(NameText , 0 , wxEXPAND | wxALL , 4)
		vbox.Add(NameTextBox , 0 , wxEXPAND | wxALL , 4)
		vbox.Add(IDText , 0 , wxEXPAND | wxALL , 4)
		vbox.Add(IDTextBox , 0 , wxEXPAND | wxALL , 4)
		'vbox.AddStretchSpacer(1)
		vbox.Add(Panel1,  0 , wxEXPAND , 0)		
		SetSizer(vbox)
		Centre()		
		Hide()
		Connect(SCA_BB , wxEVT_COMMAND_BUTTON_CLICKED , ShowSteamMenu)
		Connect(SCA_OB , wxEVT_COMMAND_BUTTON_CLICKED , SaveCustomSteamGame)
		Connect(SCA_HB , wxEVT_COMMAND_BUTTON_CLICKED , ShowHelp)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = SteamCustomAdd(event.parent).ParentWin
		MainWin.Close(True)
	End Function

	Function ShowHelp(event:wxEvent)
		OpenURL("https://support.steampowered.com/kb_article.php?ref=3729-WFJZ-4175")
	End Function

	Function ShowSteamMenu(event:wxEvent)
		Local MainWin:MainWindow = SteamCustomAdd(event.parent).ParentWin
		MainWin.SteamMenuField.Show()
		MainWin.SteamCustomAddField.Hide()			
	End Function
	
	Function SaveCustomSteamGame(event:wxEvent)
		Local MainWin:MainWindow = SteamCustomAdd(event.parent).ParentWin
		Local MessageBox:wxMessageDialog
		If IsntNull(MainWin.SteamCustomAddField.NameTextBox.GetValue()) = False Then
			MessageBox = New wxMessageDialog.Create(Null , "Please enter a name for the steam game" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return
		EndIf
		If Int(MainWin.SteamCustomAddField.IDTextBox.GetValue() ) < 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Please enter a number for the steam game" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return		
		EndIf

		Local GameNode:GameType = New GameType
		GameNode.NewGame()
		GameNode.Name = MainWin.SteamCustomAddField.NameTextBox.GetValue()
		GameNode.RunEXE = SteamFolder+FolderSlash+"Steam.exe "+Chr(34)+"-applaunch "+Int(MainWin.SteamCustomAddField.IDTextBox.GetValue())+Chr(34)

		
		?Win32
		GameNode.Plat = "PC"
		GameNode.PlatformNum = 24
		?MacOS
		GameNode.Plat = "Mac OS"
		GameNode.PlatformNum = 12	
		?Linux
		GameNode.Plat = "Linux"
		GameNode.PlatformNum = 40
		?
		
		GameNode.SaveGame()


		newevent:wxEvent = event
		newevent.parent = MainWin.GetEventHandler()
		
		MainWin.ShowEditGameList(event)		
		MainWin.SteamCustomAddField.Hide()	
				
		MainWin.EditGameListField.PopulateGameList()
		
		Local ID:Int = MainWin.EditGameListField.GameList.FindItem( - 1 , MainWin.SteamCustomAddField.NameTextBox.GetValue() )
		MainWin.EditGameListField.GameList.SetitemState(ID,wxLIST_STATE_SELECTED,wxLIST_MASK_TEXT | wxLIST_MASK_IMAGE  )
		
		
		'MainWin.show(1)
	End Function

	Function OnQuit(event:wxEvent)
		' true is to force the frame to close
		wxWindow(event.parent).Close(True)
	End Function
End Type
'----------------------------------------------------------------------------------------------------------
'-----------------------------------IMPORT MENU---------------------------------------------------------
Type ImportMenu Extends wxFrame 
	Field ParentWin:MainWindow	
	Field MButton:wxBitmapButtonExtended
	Field OButton:wxBitmapButtonExtended
	Field Back:wxButton
	
	Field HelpBox:wxTextCtrl	
		
	Method OnInit()
		ParentWin = MainWindow(GetParent() )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(200,200,255))

		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 8)	
			
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Mbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "ManualImport.png" , wxBITMAP_TYPE_PNG)
		Obitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "OnlineImport.png" , wxBITMAP_TYPE_PNG)
		
		MButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , IM_MB , Mbitmap) )
		MButton.SetFields("This option finds the already existing game information on your system and allows you to add it to the database. This option is mainly designed for those without an internet connection or games that are not in the online databases. ~n~nIt is higly recommended to use 'Online Import' option instead of this option if possible.", HelpBox)
		OButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , IM_OB , Obitmap) )
		OButton.SetFields("This option finds the already existing game information on your system and updates missing information from online sources. It then allows you to add that game information to your game database. This option requires an internet connection!", HelpBox)
		


				
		Back = New wxButton.Create(Self,IM_BB, "Back")
		
		'vbox.AddStretchSpacer(2)
		vbox.Add(OButton , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)		
		vbox.Add(MButton, 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 8)		
		vbox.AddStretchSpacer(4)		
		vbox.Add(Back,  1 , wxALIGN_LEFT | wxALL, 6)		

		Local Mainhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Mainhbox.AddSizer(vbox, 1 , wxEXPAND, 0)
		Mainhbox.AddSizer(vbox2, 1 , wxEXPAND , 0)

		SetSizer(Mainhbox)		
		Centre()
		Hide()		
		Connect(IM_BB, wxEVT_COMMAND_BUTTON_CLICKED, ShowAddGamesMenu)
		Connect(IM_MB, wxEVT_COMMAND_BUTTON_CLICKED, ShowMI)
		Connect(IM_OB, wxEVT_COMMAND_BUTTON_CLICKED, ShowOI)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = ImportMenu(event.parent).ParentWin
		MainWin.Close(True)
	End Function	
	
	Function ShowMI(event:wxEvent)
		Local MainWin:MainWindow = ImportMenu(event.parent).ParentWin
		MainWin.ImportMenuField.Hide()
		MainWin.OfflineImport2Field = OfflineImport2(New OfflineImport2.Create(MainWin, wxID_ANY, "Add Games via Games Explorer", , , 800, 600) )
		MainWin.OfflineImport2Field.Show()		
		Rem
		MainWin.OfflineImportField = OfflineImport(New OfflineImport.Create(MainWin , wxID_ANY , "Offline Import" , Null , -1 , -1 , wxRESIZE_BORDER | wxDEFAULT_DIALOG_STYLE | wxMAXIMIZE_BOX ) )
		MainWin.OfflineImportField.Setup()	
		MainWin.OfflineImportField.RunWizard(MainWin.OfflineImportField.StartPage)
		MainWin.OfflineImportField.Destroy()
		MainWin.ImportMenuField.Show()
		EndRem
		'MainWin.ImportMenuField.Hide()
		'MainWin.Show()
	End Function
	
	Function ShowOI(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local MainWin:MainWindow = ImportMenu(event.parent).ParentWin

		If Connected = False Then 
			CheckInternet()
		EndIf
		If Connected = 1 Then
			
			MainWin.ImportMenuField.Hide()
			MainWin.OnlineImport2Field = OnlineImport2(New OnlineImport2.Create(MainWin, wxID_ANY, "Add Games via Games Explorer", , , 800, 600) )
			MainWin.OnlineImport2Field.Show()
			
			
			Rem
			MainWin.OnlineImportField = OnlineImport(New OnlineImport.Create(MainWin , wxID_ANY , "Online Import" , Null , - 1 , - 1 , wxRESIZE_BORDER | wxDEFAULT_DIALOG_STYLE | wxMAXIMIZE_BOX ) )
			MainWin.OnlineImportField.Setup()	
			MainWin.OnlineImportField.RunWizard(MainWin.OnlineImportField.StartPage)
			MainWin.OnlineImportField.Destroy()
			'MainWin.ImportMenuField.Hide()
			'MainWin.Show()
			MainWin.ImportMenuField.Show()
			EndRem
		Else
			MessageBox = New wxMessageDialog.Create(Null , "You are not connected to the internet!" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
		EndIf	

	End Function

	Function ShowAddGamesMenu(event:wxEvent)
		Local MainWin:MainWindow = ImportMenu(event.parent).ParentWin
		MainWin.AddGamesMenuField.Show()
		MainWin.ImportMenuField.Hide()			
	End Function
	
End Type
'----------------------------------------------------------------------------------------------------------
'-----------------------------------STEAM MENU---------------------------------------------------------

Type SteamMenu Extends wxFrame
	Field ParentWin:MainWindow	
	Field CButton:wxBitmapButtonExtended
	Field OButton:wxBitmapButtonExtended
	Field Back:wxButton
	
	Field HelpBox:wxTextCtrl	
		
	Method OnInit()
		ParentWin = MainWindow(GetParent() )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(200,200,255))

		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 8)	
			
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Mbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"ManualImport.png" , wxBITMAP_TYPE_PNG)
		Obitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"OnlineImport.png" , wxBITMAP_TYPE_PNG)
		Cbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "ManualImport.png" , wxBITMAP_TYPE_PNG)
		
		'MButton = New wxBitmapButton.Create(Self , SM_MB , Mbitmap)
		OButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , SM_OB , Obitmap) )
		OButton.SetFields("Here you can automatically find all your steam games and search online sources to fill in the missing game information. It requires an internet connection and your steam ID. ~n~nWe highly recommend that you use this option if possible.", HelpBox)
		CButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , SM_CB , Cbitmap) )
		CButton.SetFields("Here you can manually enter Steam games one by one by specifying their ID. This is only recommended if you do not have an internet connection.", HelpBox)
		Back = New wxButton.Create(Self, SM_BB, "Back")
		
		
		'vbox.AddStretchSpacer(2)
		'vbox.Add(MButton,  2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 8)		
		vbox.Add(OButton , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)		
		vbox.Add(CButton , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)
		vbox.AddStretchSpacer(4)		
		vbox.Add(Back,  1 , wxALIGN_LEFT | wxALL, 6)		

		Local Mainhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Mainhbox.AddSizer(vbox, 1 , wxEXPAND, 0)
		Mainhbox.AddSizer(vbox2, 1 , wxEXPAND , 0)

		SetSizer(Mainhbox)		
		Centre()
		Hide()		
		Connect(SM_BB, wxEVT_COMMAND_BUTTON_CLICKED, ShowAddGamesMenu)
		'Connect(SM_MB, wxEVT_COMMAND_BUTTON_CLICKED, ShowMI)
		Connect(SM_OB , wxEVT_COMMAND_BUTTON_CLICKED , ShowOI)
		Connect(SM_CB, wxEVT_COMMAND_BUTTON_CLICKED, ShowC)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = SteamMenu(event.parent).ParentWin
		MainWin.Close(True)
	End Function
	
	Rem
	Function ShowMI(event:wxEvent)
		Local MainWin:MainWindow = SteamMenu(event.parent).ParentWin
		Local MessageBox:wxMessageDialog
		MainWin.SteamMenuField.Hide()
		If FindSteamFolderMain() = - 1 then
			MessageBox = New wxMessageDialog.Create(Null , "Could not find Steam Folder, please manually select it from the settings menu" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
		Else
			MainWin.SteamOfflineImportField = SteamOfflineImport(New SteamOfflineImport.Create(MainWin , wxID_ANY , "Steam Offline Import" , Null , -1 , -1 , wxRESIZE_BORDER | wxDEFAULT_DIALOG_STYLE | wxMAXIMIZE_BOX ) )
			MainWin.SteamOfflineImportField.Setup()	
			MainWin.SteamOfflineImportField.RunWizard(MainWin.SteamOfflineImportField.StartPage)
			MainWin.SteamOfflineImportField.Destroy()
		EndIf
		MainWin.SteamMenuField.Show()
	End Function
	EndRem
	
	Function ShowC(event:wxEvent)
		
		Local MessageBox:wxMessageDialog
		Local MainWin:MainWindow = SteamMenu(event.parent).ParentWin
		
		'MainWin.SteamMenuField.Hide()
		If FindSteamFolderMain() = - 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Could not find Steam Folder, please manually select it from the settings menu" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()			
		Else
			MainWin.SteamCustomAddField.Show()
			MainWin.SteamMenuField.Hide()
		EndIf
		'MainWin.SteamMenuField.Show()
		'MainWin.OnlineImportField.Show()
		'MainWin.ImportMenuField.Hide()
		
	End Function
	
	Function ShowOI(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local MainWin:MainWindow = SteamMenu(event.parent).ParentWin
		
		
		If FindSteamFolderMain() = - 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Steam Folder invalid, please manually select it in the settings menu" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()			
		Else
			If SteamID="" Or SteamID=" " Or Len(SteamID)<>17 Then 
				MessageBox = New wxMessageDialog.Create(Null , "SteamID invalid, please manually enter it in the settings menu" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()	
			Else
				If Connected = False Then 	
					CheckInternet()
				EndIf 
				If Connected = 1 Then
					
					MainWin.SteamMenuField.Hide()
					MainWin.SteamOnlineImport2Field = SteamOnlineImport2(New SteamOnlineImport2.Create(MainWin, wxID_ANY, "Add Games via Steam", , , 800, 600))
					MainWin.SteamOnlineImport2Field.Show()
					
					Rem
					MainWin.SteamOnlineImportField = SteamOnlineImport(New SteamOnlineImport.Create(MainWin , wxID_ANY , "Online Import" , Null , - 1 , - 1 , wxRESIZE_BORDER | wxDEFAULT_DIALOG_STYLE | wxMAXIMIZE_BOX ) )
					MainWin.SteamMenuField.Hide()
					MainWin.SteamOnlineImportField.Setup()	
					MainWin.SteamOnlineImportField.RunWizard(MainWin.SteamOnlineImportField.StartPage)
					MainWin.SteamOnlineImportField.Destroy()
					MainWin.SteamMenuField.Show()
					EndRem 
				Else
					MessageBox = New wxMessageDialog.Create(Null , "You are not connected to the internet!" , "Error" , wxOK | wxICON_EXCLAMATION)
					MessageBox.ShowModal()
					MessageBox.Free()
				EndIf	
				EndIf 	
		EndIf
		
		'MainWin.OnlineImportField.Show()
		'MainWin.ImportMenuField.Hide()
	End Function

	Function ShowAddGamesMenu(event:wxEvent)
		Local MainWin:MainWindow = SteamMenu(event.parent).ParentWin
		MainWin.AddGamesMenuField.Show()
		MainWin.SteamMenuField.Hide()			
	End Function
	
End Type
'----------------------------------------------------------------------------------------------------------
'-----------------------------------OFFLINE IMPORT---------------------------------------------------------
'Include "Includes\DatabaseManager\OfflineImport.bmx"
Include "Includes\DatabaseManager\OfflineImport2.bmx"
'----------------------------------------------------------------------------------------------------------
'---------------------------------------ONLINE IMPORT------------------------------------------------------
'Include "Includes\DatabaseManager\OnlineImport.bmx"
Include "Includes\DatabaseManager\OnlineImport2.bmx"
'----------------------------------------------------------------------------------------------------------
'---------------------------------------OFFLINE STEAM IMPORT-----------------------------------------------
'Include "Includes\DatabaseManager\SteamOfflineImport.bmx"
'----------------------------------------------------------------------------------------------------------
'---------------------------------------ONLINE STEAM IMPORT-----------------------------------------------
'Include "Includes\DatabaseManager\SteamOnlineImport.bmx"
Include "Includes\DatabaseManager\SteamOnlineImport2.bmx"
'----------------------------------------------------------------------------------------------------------
'-----------------------------------EMULATORS LIST---------------------------------------------------------
Include "Includes\DatabaseManager\EmulatorList.bmx"


Type PluginsWindow Extends wxFrame
	Field ScrollBox:wxScrolledWindow
	Field PluginName:TList
	Field EnabledCombo:TList
	Field PluginType:TList	
	Field ParentWin:MainWindow
		
	Method OnInit()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
				
		ParentWin = MainWindow(GetParent())
		Local File:String , File2:String
		Local bID:Int = 0
		Local tempstatictext:wxStaticText
		Local tempstatictext2:wxStaticText
		Local tempcombobox:wxComboBox
		Local tempcombobox2:wxComboBox
		Local temphbox:wxBoxSizer,temphbox2:wxBoxSizer,temphbox3:wxBoxSizer
		
		PluginName = CreateList()
		EnabledCombo = CreateList()
		PluginType = CreateList()	
		
		Self.center()
		Self.Hide()
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		ScrollBox = New wxScrolledWindow.Create(Self)
		Local SB_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		ReadPlugins = ReadDir(StripSlash(APPFOLDER))
		Repeat
			EnabledAble = False 
			File = NextFile(ReadPlugins)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue 
			If FileType(APPFOLDER + File) = 2 And File <> "critical" Then
				temphbox = New wxBoxSizer.Create(wxHORIZONTAL)
				temphbox2 = New wxBoxSizer.Create(wxHORIZONTAL)
				temphbox3 = New wxBoxSizer.Create(wxHORIZONTAL)
				tempstatictext = New wxStaticText.Create(ScrollBox , wxID_ANY , "Plugin: "+File)
				tempcombobox = New wxComboBox.Create(ScrollBox , wxID_ANY , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY)
				Local tempButton:wxButton = New wxButton.Create(ScrollBox , 700 + bID , "Configure")
				Connect(700 + bID , wxEVT_COMMAND_BUTTON_CLICKED , ConfigureClickedFun , File)
				bID = bID + 1
				ReadPluginNames = ReadDir(APPFOLDER + File)
				Repeat
					File2 = NextFile(ReadPluginNames)
					If File2 = "" Then Exit
					If File2=".." Or File2="." Then Continue 
					If FileType(APPFOLDER + File + FolderSlash + File2) = 2 Then
						If ValidatePlugin(APPFOLDER + File + FolderSlash + File2 , File) = True Then
							tempcombobox.Append(File2)
							EnabledAble = True 
						EndIf 
					EndIf 
				Forever
				CloseDir(ReadPluginNames)

				tempstatictext2 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Enabled: ")
				If EnabledAble = True Then
					tempcombobox2 = New wxComboBox.Create(ScrollBox , wxID_ANY , "" , ["Yes" , "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY)
				Else
					tempButton.Disable()
					tempcombobox2 = New wxComboBox.Create(ScrollBox , wxID_ANY , "No" , ["No"] , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY)
				EndIf
				
				Local ReadSettings:SettingsType = New SettingsType
				ReadSettings.ParseFile(APPFOLDER + File + FolderSlash+"PM-CONFIG.xml" , "PluginSelection")
				tempcombobox.SetValue(ReadSettings.GetSetting("plugin") )
				tempcombobox2.SetValue(ReadSettings.GetSetting("enabled") )
				If tempcombobox2.GetValue()= "" Or tempcombobox.GetValue()= "" Then
					tempcombobox.SelectItem(0)
					tempcombobox2.SetValue("No")
				EndIf 

				ReadSettings.CloseFile()
				temphbox.Add(tempstatictext , 1 , wxEXPAND | wxALL , 7)
				temphbox.Add(tempcombobox , 2 , wxEXPAND | wxALL , 5)
				
				temphbox2.Add(tempButton , 1 ,wxEXPAND | wxALL , 3)
				temphbox2.Add(tempstatictext2, 0 , wxEXPAND | wxALL , 7)
				temphbox2.Add(tempcombobox2 , 1 , wxEXPAND | wxALL , 5)
				
				temphbox3.AddSizer(temphbox , 1 , wxEXPAND , 0)
				temphbox3.AddSizer(temphbox2 , 1 ,wxEXPAND , 0)
				ListAddLast(PluginType , File)
				ListAddLast(PluginName , tempcombobox)
				ListAddLast(EnabledCombo , tempcombobox2)
				SB_vbox.AddSizer(temphbox3 , 0 , wxEXPAND , 0)
			EndIf 
		Forever
		CloseDir(ReadPlugins)
		
		
		SB_vbox.RecalcSizes()
		ScrollBox.SetSizer(SB_vbox)
		ScrollBox.SetScrollRate(10 , 10)
		Self.Update()
		ScrollBox.Update()
		

		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Local P1Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BackButton:wxButton = New wxButton.Create(Panel1 , PW_BB , "Back")
		Local OKButton:wxButton = New wxButton.Create(Panel1, PW_OB , "OK")

		P1Hbox.Add(BackButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.AddStretchSpacer(1)
		P1Hbox.Add(OKButton , 1 , wxEXPAND | wxALL , 10)
		
		Panel1.SetSizer(P1Hbox)
		
		
		vbox.Add(ScrollBox , 1 , wxEXPAND , 0)
		vbox.Add(Panel1 , 0 , wxEXPAND , 0)
		
		Self.SetSizer(vbox)
		
		Connect(PW_BB , wxEVT_COMMAND_BUTTON_CLICKED , ShowSettingsMenu)
		Connect(PW_OB , wxEVT_COMMAND_BUTTON_CLICKED , SavePluginSettingsFun)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function ConfigureClickedFun(event:wxEvent)
		Local PluginWin:PluginsWindow = PluginsWindow(event.parent)
		Local data:Object = event.userData
		'Select String(data)
		Local MessageBox:wxMessageDialog
		Local PluginNameArray:Object[] = ListToArray(PluginWin.PluginName)
		Local EnabledComboArray:Object[] = ListToArray(PluginWin.EnabledCombo)
		Local PluginTypeArray:Object[] = ListToArray(PluginWin.PluginType)		
		Local ReadSettings:SettingsType
		Local Configure:String
		For a = 0 To Len(PluginNameArray) - 1
			If String(PluginTypeArray[a]) = String(data) Then
				If wxComboBox(PluginNameArray[a]).GetValue() = "" Then
					MessageBox = New wxMessageDialog.Create(Null , "Please select a plugin" , "Info" , wxOK | wxICON_INFORMATION)
					MessageBox.ShowModal()
					MessageBox.Free()				
					Return 		
				EndIf 
				ReadSettings = New SettingsType
				ReadSettings.ParseFile(APPFOLDER + String(PluginTypeArray[a]) + FolderSlash + wxComboBox(PluginNameArray[a]).GetValue() +FolderSlash+"PM-CONFIG.xml" , "PluginConfig")
				Configure = ReadSettings.GetSetting("configurepath")
				ReadSettings.CloseFile()
				If Configure = "" Then
					'Print CurrentDir()+APPFOLDER + String(PluginTypeArray[a]) + "\" + wxComboBox(PluginNameArray[a]).GetValue() +"\PM-CONFIG.xml"
					RunProcess("Notepad.exe "+CurrentDir()+FolderSlash+APPFOLDER + String(PluginTypeArray[a]) + FolderSlash + wxComboBox(PluginNameArray[a]).GetValue() +FolderSlash+"PM-CONFIG.xml" , 1)
				ElseIf Configure = "Internal"
					'Load internal configure
					Select String(PluginTypeArray[a])
						Case "powerplan"
							Local PowerPlanPlugin:PowerPlanPluginWindow = PowerPlanPluginWindow(New PowerPlanPluginWindow.Create(PluginWin , wxID_ANY , "PowerPlan Settings" , , , 400 , 300))
							PowerPlanPlugin.UpdateData(APPFOLDER + String(PluginTypeArray[a]) + FolderSlash + wxComboBox(PluginNameArray[a]).GetValue()+FolderSlash+"PM-CONFIG.xml")
						Case "screenshots" , "video"
							Local HotkeyPlugin:HotkeyPluginWindow = HotkeyPluginWindow(New HotkeyPluginWindow.Create(PluginWin , wxID_ANY , "PowerPlan Settings" , , , 400 , 300))
							HotkeyPlugin.UpdateData(APPFOLDER + String(PluginTypeArray[a]) + FolderSlash + wxComboBox(PluginNameArray[a]).GetValue()+FolderSlash+"PM-CONFIG.xml")						
					End Select 
				Else
					Configure = Replace(Configure,"[CURRENTDIR]",APPFOLDER + String(PluginTypeArray[a]) + FolderSlash + wxComboBox(PluginNameArray[a]).GetValue())
					RunProcess(Configure,1)
				EndIf 
				
				Exit 
			EndIf 
		Next 
	End Function 

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = PluginsWindow(event.parent).ParentWin
		MainWin.Close(True)
	End Function

	Function SavePluginSettingsFun(event:wxEvent)
		Local PluginWin:PluginsWindow = PluginsWindow(event.parent)
		Local MessageBox:wxMessageDialog
		Local PluginNameArray:Object[] = ListToArray(PluginWin.PluginName)
		Local EnabledComboArray:Object[] = ListToArray(PluginWin.EnabledCombo)
		Local PluginTypeArray:Object[] = ListToArray(PluginWin.PluginType)
		Local WriteSettings:SettingsType
		
		For a = 0 To Len(PluginNameArray) - 1
			WriteSettings = New SettingsType
			WriteSettings.ParseFile(APPFOLDER + String(PluginTypeArray[a]) + FolderSlash+"PM-CONFIG.xml" , "PluginSelection")
			WriteSettings.SaveSetting("enabled" , wxComboBox(EnabledComboArray[a]).GetValue() )
			WriteSettings.SaveSetting("plugin" , wxComboBox(PluginNameArray[a]).GetValue() )
			WriteSettings.SaveFile()
			WriteSettings.CloseFile()
		Next
		
		MessageBox = New wxMessageDialog.Create(Null , "Plugin Settings saved." , "Info" , wxOK | wxICON_INFORMATION)
		MessageBox.ShowModal()
		MessageBox.Free()	
		ShowSettingsMenu(event)
	End Function 

	Function ShowSettingsMenu(event:wxEvent)
		Local MainWin:MainWindow = PluginsWindow(event.parent).ParentWin
		
		MainWin.SettingsMenuField.Show()
		MainWin.PluginsWindowField.Destroy()
		MainWin.PluginsWindowField = Null 		
	End Function
	
End Type 
'----------------------------------------------------------------------------------------------------------
'-----------------------------------FG UPDATE WINDOW-------------------------------------------------------
Type SettingsWindow Extends wxFrame 
	Field ParentWin:MainWindow
	Field SW_SteamPath:wxTextCtrl
	Field SW_SteamID:wxTextCtrl
	Field SW_CompressLev:wxTextCtrl
	Field SW_DateFormat:wxComboBox
	Field SW_Resolution:wxComboBox
	Field SW_Runner:wxComboBox
	Field SW_Cabinate:wxComboBox
	Field SW_Mode:wxComboBox
	Field SW_LowMem:wxComboBox
	Field SW_LowProc:wxComboBox
	Field SW_GameCache:wxTextCtrl
	Field SW_TouchKey:wxComboBox
	Field SW_OverridePath:wxTextCtrl 
	Field SW_ButtonCloseOnly:wxComboBox
	Field SW_OriginWait:wxComboBox
	Field SW_AntiAlias:wxComboBox 
	Field SW_ShowTouchScreen:wxComboBox
	Field SW_ShowTouchInfo:wxComboBox 
	
	Field KeyboardInputField:KeyboardInputWindow
	Field JoyStickInputField:JoyStickInputWindow
	
	Method OnInit()
		ParentWin = MainWindow(GetParent())
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		
		Local ScrollBox:wxScrolledWindow = New wxScrolledWindow.Create(Self , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		
		ScrollBox.SetScrollRate(20,20)
		Local ScrollBoxvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'------------------------------------------------------------------------------------
		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Local P1Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BackButton:wxButton = New wxButton.Create(Panel1 , SW_BB , "Back")
		Local OKButton:wxButton = New wxButton.Create(Panel1, SW_OB , "OK")

		P1Hbox.Add(BackButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.AddStretchSpacer(1)
		P1Hbox.Add(OKButton , 1 , wxEXPAND | wxALL , 10)
		
		Panel1.SetSizer(P1Hbox)
		'------------------------------------------------------------------------------------		
		


		'------------------------------------------------------------------------------------	
		Local SL1:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)
		Local SLT1 = New wxStaticText.Create(ScrollBox , wxID_ANY , "General Settings" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)	
		Local SL2:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)
		Local ST3 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Date Format: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_DateFormat = New wxComboBox.Create(ScrollBox , SW_DF , "" , ["UK" , "US" , "EU"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )
		
		Local ST13 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Override Default Save Path: (Leave blank to remove override)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)			
		Local OverridePanel:wxPanel = New wxPanel.Create(ScrollBox , - 1)	
		Local OverrideHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)		
		SW_OverridePath = New wxTextCtrl.Create(OverridePanel , SW_OP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local SW_OverrideBrowse = New wxButton.Create(OverridePanel , SW_ODB , "Browse")
		OverrideHbox.Add(SW_OverridePath , 10 , wxEXPAND | wxALL , 4)
		OverrideHbox.Add(SW_OverrideBrowse , 2 , wxEXPAND | wxALL , 4)
		OverridePanel.SetSizer(OverrideHbox)	
		
			
		
		Local SL3:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)
		Local SLT2 = New wxStaticText.Create(ScrollBox , wxID_ANY , "PhotonManager Settings" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)	
		Local SL4:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)		
		Local ST2 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Artwork Compression Level: (100-Best, 1-Worst) " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		
		Local Optimizehbox1:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SW_CompressLev = New wxTextCtrl.Create(ScrollBox , SW_CL , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local SW_OptimizeArt1 = New wxButton.Create(ScrollBox , SW_OA1 , "Optimize Artwork")
		Optimizehbox1.Add(SW_CompressLev , 1 , wxEXPAND | wxALL , 4)
		Optimizehbox1.Add(SW_OptimizeArt1 , 0 , wxEXPAND | wxALL , 4)
		
		
		Local SL10:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)
		Local SLT5 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Steam Settings" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)	
		Local SL11:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)		
		
		?win32		
		Local ST1 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Steam Path: (Folder containing steam.exe)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)		
		?Not Win32
		Local ST1 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Steam Path: (Folder containing steam executable, on Ubuntu thats /usr/bin/)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)		
		?	
		Local SteamPanel:wxPanel = New wxPanel.Create(ScrollBox , - 1)	
		Local SteamHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)		
		SW_SteamPath = New wxTextCtrl.Create(SteamPanel , SW_SP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local SW_SteamBrowse = New wxButton.Create(SteamPanel , SW_SB , "Browse")
		SteamHbox.Add(SW_SteamPath , 10 , wxEXPAND | wxALL , 4)
		SteamHbox.Add(SW_SteamBrowse , 2 , wxEXPAND | wxALL , 4)
		SteamPanel.SetSizer(SteamHbox)		

		Local ST11 = New wxStaticText.Create(ScrollBox , wxID_ANY , "SteamID: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_SteamID = New wxTextCtrl.Create(ScrollBox , SW_SID , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local SW_SteamIDGuide = New wxButton.Create(ScrollBox , SW_SIDG , "How to find SteamID Guide")

		Local SL5:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)
		Local SLT3 = New wxStaticText.Create(ScrollBox , wxID_ANY , "PhotonFrontEnd Settings" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)	
		Local SL6:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)
		
		
		
		Local FrontEndControlsHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local KeyboardInput:wxButton = New wxButton.Create(ScrollBox , SW_KI , "Keyboard Input")
		Local JoystickInput:wxButton = New wxButton.Create(ScrollBox, SW_JI , "Joystick Input")

		FrontEndControlsHbox.Add(KeyboardInput , 1 , wxEXPAND | wxALL , 10)
		FrontEndControlsHbox.Add(JoystickInput , 1 , wxEXPAND | wxALL , 10)

			
		Local ST4 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Graphics Resolution: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		
		Local Optimizehbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SW_Resolution = New wxComboBox.Create(ScrollBox , SW_R , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN )			
		Local SW_OptimizeArt2 = New wxButton.Create(ScrollBox , SW_OA2 , "Optimize Artwork")
		Optimizehbox2.Add(SW_Resolution , 1 , wxEXPAND | wxALL , 4)
		Optimizehbox2.Add(SW_OptimizeArt2 , 0 , wxEXPAND | wxALL , 4)
		
		Local ST6 = New wxStaticText.Create(ScrollBox , wxID_ANY , "FullScreen: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_Mode = New wxComboBox.Create(ScrollBox , SW_M , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
		
		Local ST16 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Anti-Aliasing: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_AntiAlias = New wxComboBox.Create(ScrollBox , SW_AA , "" , ["None","2X","4X","8X","16X"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
			
		Local ST7 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Low Memory Mode: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_LowMem = New wxComboBox.Create(ScrollBox , SW_LM , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )
		Local ST9 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Low Processor Mode: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_LowProc = New wxComboBox.Create(ScrollBox , SW_LP , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		Local ST8 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Game Cache Number: (The number of games around the selected game to keep artwork in memory, larger will be smoother but use more memory) " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_GameCache = New wxTextCtrl.Create(ScrollBox , SW_GC , String(GAMECACHELIMIT) , - 1 , - 1 , - 1 , - 1 , 0 )
		
		Local ST10 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Show TouchScreen/JoyStick Keyboard: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_TouchKey = New wxComboBox.Create(ScrollBox , SW_TK , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		
		Local ST17 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Show Touchscreen Info Button: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_ShowTouchInfo = New wxComboBox.Create(ScrollBox , SW_STI , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		
		Local ST18 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Show Touchscreen ScreenShot Button: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_ShowTouchScreen = New wxComboBox.Create(ScrollBox , SW_STS , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		

		Local SL7:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)
		Local SLT4 = New wxStaticText.Create(ScrollBox , wxID_ANY , "PhotonRunner Settings" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)	
		Local SL8:wxStaticLine = New wxStaticLine.Create(ScrollBox , wxID_ANY)
		Local ST5 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Enable PhotonRunner: (Disabling will stop the program from running in the background during games and also disable post batch and unmount functions)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_Runner = New wxComboBox.Create(ScrollBox , SW_R , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		Local ST12 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Enable Cabinet Mode: (After Runner closed Explorer or Frontend will load back up)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_Cabinate = New wxComboBox.Create(ScrollBox , SW_C , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )						

		Local ST15 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Photon Runner only closes when you click close button (All Games)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_ButtonCloseOnly = New wxComboBox.Create(ScrollBox , SW_BCO , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )
	
		Local ST14 = New wxStaticText.Create(ScrollBox , wxID_ANY , "Enable Origin 30 second wait: (Waits 30 seconds when it detects Origin to allow game to load before PhotonRunner looks to see if game process is still running)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
		SW_OriginWait = New wxComboBox.Create(ScrollBox , SW_OW , "" , ["Yes","No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		
				
		Local wid:Int , hei:Int , dep:Int , hert:Int
		For a = 0 To CountGraphicsModes() - 1
		
			GetGraphicsMode(a , wid , hei , dep , hert)
			If dep => 32 And wid => 640 And hei >= 480 Then
				If SW_Resolution.FindString(wid+"x"+hei) = -1 Then 
					SW_Resolution.Append(wid + "x" + hei)
				EndIf 
				'Print wid + "x" + hei + " " + dep + " bit @" + hert + "hz"
			EndIf
		Next
		
		SW_Resolution.SetValue(GraphicsW+"x"+GraphicsH)
		If SilentRunnerEnabled Then 
			SW_Runner.SetValue("Yes")
		Else
			SW_Runner.SetValue("No")
		EndIf
		If CabinateEnable Then 
			SW_Cabinate.SetValue("Yes")
		Else
			SW_Cabinate.SetValue("No")
		EndIf	
		
		If LowMemory = True Then 
			SW_LowMem.SetValue("Yes")
		Else
			SW_LowMem.SetValue("No")
		EndIf 		
		If LowProcessor = True Then 
			SW_LowProc.SetValue("Yes")
		Else
			SW_LowProc.SetValue("No")
		EndIf 			
		If GMode = 1 Then 
			SW_Mode.SetValue("Yes")
		Else
			SW_Mode.SetValue("No")
		EndIf 
		If TouchKeyboardEnabled = 1 Then 
			SW_TouchKey.SetValue("Yes")
		Else
			SW_TouchKey.SetValue("No")
		EndIf 	

		If ShowScreenButton = 1 Then 
			SW_ShowTouchScreen.SetValue("Yes")
		Else
			SW_ShowTouchScreen.SetValue("No")
		EndIf 	
		
		If ShowInfoButton = 1 Then 
			SW_ShowTouchInfo.SetValue("Yes")
		Else
			SW_ShowTouchInfo.SetValue("No")
		EndIf 			
		
			
		
		If RunnerButtonCloseOnly = 1 Then 
			SW_ButtonCloseOnly.SetValue("Yes")
		Else
			SW_ButtonCloseOnly.SetValue("No")
		EndIf 
		
		If OriginWaitEnabled = 1 Then 
			SW_OriginWait.SetValue("Yes")
		Else
			SW_OriginWait.SetValue("No")
		EndIf 
		
		Select AntiAliasSetting
			Case 0
				SW_AntiAlias.SetValue("None")
			Case 2
				SW_AntiAlias.SetValue("2X")
			Case 4
				SW_AntiAlias.SetValue("4X")
			Case 8
				SW_AntiAlias.SetValue("8X")
			Case 16
				SW_AntiAlias.SetValue("16X")
		End Select
			
				
		ScrollBoxvbox.Add(SL1,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SLT1,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SL2 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST3 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_DateFormat , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST13,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(OverridePanel , 0 , wxEXPAND | wxALL , 4)		
		
		ScrollBoxvbox.AddSpacer(50)
		
		ScrollBoxvbox.Add(SL3,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SLT2,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SL4 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST2 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.AddSizer(Optimizehbox1, 0 , wxEXPAND | wxALL , 4)	
		'ScrollBoxvbox.Add(SW_CompressLev , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox.AddSpacer(50)	
	
		ScrollBoxvbox.Add(SL10,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SLT5,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SL11 , 0 , wxEXPAND | wxALL , 4)	
				
		ScrollBoxvbox.Add(ST1,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SteamPanel , 0 , wxEXPAND | wxALL , 4)
		
		ScrollBoxvbox.Add(ST11,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_SteamID , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_SteamIDGuide , 0 , wxEXPAND | wxALL , 4)
			
		ScrollBoxvbox.AddSpacer(50)

		ScrollBoxvbox.Add(SL5,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SLT3,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SL6 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.AddSizer(FrontEndControlsHbox, 0 , wxEXPAND | wxALL , 4)
		
		ScrollBoxvbox.Add(ST4 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.AddSizer(Optimizehbox2 , 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox.Add(SW_Resolution , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox.Add(ST6 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_Mode , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST16 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_AntiAlias , 0 , wxEXPAND | wxALL , 4)		
		
		
		ScrollBoxvbox.Add(ST7 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_LowMem , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST9 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_LowProc , 0 , wxEXPAND | wxALL , 4)					
		ScrollBoxvbox.Add(ST8 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_GameCache , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST10 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_TouchKey , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox.Add(ST17 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_ShowTouchInfo , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox.Add(ST18 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_ShowTouchScreen , 0 , wxEXPAND | wxALL , 4)							
						
		ScrollBoxvbox.AddSpacer(50)
				
		ScrollBoxvbox.Add(SL7,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SLT4,  0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SL8 , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox.Add(ST5 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_Runner , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST12 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_Cabinate , 0 , wxEXPAND | wxALL , 4)		
		
		ScrollBoxvbox.Add(ST15 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_ButtonCloseOnly , 0 , wxEXPAND | wxALL , 4)	
		
		ScrollBoxvbox.Add(ST14 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_OriginWait , 0 , wxEXPAND | wxALL , 4)	
		
					
		ScrollBoxvbox.AddSpacer(50)
		
		ScrollBox.SetSizer(ScrollBoxvbox)
		
		vbox.Add(ScrollBox, 1, wxEXPAND, 0)
		vbox.Add(Panel1,  0 , wxEXPAND ,0)		
		SetSizer(vbox)
		Centre()		
		Hide()
		Connect(SW_BB , wxEVT_COMMAND_BUTTON_CLICKED , ShowSettingsMenu)
		Connect(SW_OB , wxEVT_COMMAND_BUTTON_CLICKED , SaveSettingsFun)
		Connect(SW_SB , wxEVT_COMMAND_BUTTON_CLICKED , BrowseButtonFun)
		Connect(SW_ODB , wxEVT_COMMAND_BUTTON_CLICKED , BrowseOverrideFun)
		Connect(SW_SIDG , wxEVT_COMMAND_BUTTON_CLICKED , SteamIDFun)		
		Connect(SW_KI , wxEVT_COMMAND_BUTTON_CLICKED , KeyboardWinFun)
		Connect(SW_JI , wxEVT_COMMAND_BUTTON_CLICKED , JoyStickWinFun)
		
		Connect(SW_OA1 , wxEVT_COMMAND_BUTTON_CLICKED , OptimizeAllArtFun)
		Connect(SW_OA2 , wxEVT_COMMAND_BUTTON_CLICKED , OptimizeAllArtFun)
		
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function KeyboardWinFun(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		PrintF("----------------------------Show Keyboard----------------------------")
		SettingsWin.KeyboardInputField = KeyboardInputWindow(New KeyboardInputWindow.Create(SettingsWin, wxID_ANY, "FrontEnd Keyboard Input", , , 340, 630))	
		SettingsWin.KeyboardInputField.Show(True)
		SettingsWin.Hide()
		SettingsWin.KeyboardInputField.Raise()
	End Function

	Function JoyStickWinFun(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		PrintF("----------------------------Show Keyboard----------------------------")
		SettingsWin.JoyStickInputField = JoyStickInputWindow(New JoyStickInputWindow.Create(SettingsWin, wxID_ANY, "FrontEnd JoyStick Input", , , 340, 480))	
		SettingsWin.JoyStickInputField.Show(True)
		SettingsWin.Hide()
		SettingsWin.JoyStickInputField.Raise()
	End Function

	Function BrowseOverrideFun(event:wxEvent)
		Local MainWin:MainWindow = SettingsWindow(event.parent).ParentWin
		?Not Win32
		Local openFileDialog:wxDirDialog = New wxDirDialog.Create(MainWin.SettingsWindowField, "Select folder" ,MainWin.SettingsWindowField.SW_OverridePath.GetValue() , wxDD_DIR_MUST_EXIST)	
		If openFileDialog.ShowModal() = wxID_OK Then
			MainWin.SettingsWindowField.SW_OverridePath.ChangeValue(openFileDialog.GetPath())
		EndIf
		?Win32
		tempFile:String = RequestDir("Select folder" , MainWin.SettingsWindowField.SW_OverridePath.GetValue())
		If tempFile <> "" Then 
			MainWin.SettingsWindowField.SW_OverridePath.ChangeValue(tempFile)
		EndIf
		? 		
	End Function

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = SettingsWindow(event.parent).ParentWin
		MainWin.Close(True)
	End Function
	
	Method ValidateInput()
		Local MessageBox:wxMessageDialog
		?Win32
		If FileType(SW_SteamPath.GetValue() + FolderSlash +"Steam.exe") = 0 Then
			If SW_SteamPath.GetValue() = "" Then
			
			Else
				MessageBox = New wxMessageDialog.Create(Null , "Invalid Steam Path. No Steam.exe within folder" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()	
				SW_SteamPath.ChangeValue("")	
				Return False
			EndIf
		EndIf
		?Not Win32
		If FileType(SW_SteamPath.GetValue() + FolderSlash +"steam") = 0 Then
			If SW_SteamPath.GetValue() = "" Then
			
			Else
				MessageBox = New wxMessageDialog.Create(Null , "Invalid Steam Path. No steam executable within folder" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()	
				SW_SteamPath.ChangeValue("")	
				Return False
			EndIf
		EndIf
		?
		If Int(SW_CompressLev.GetValue() ) < 1 Or Int(SW_CompressLev.GetValue() ) > 100 Then
			MessageBox = New wxMessageDialog.Create(Null , "Invalid Compression Level. Enter a number between 1 and 100" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()		
			Return False
		EndIf
		Return True
	End Method

	Function SteamIDFun(event:wxEvent)
		OpenURL("http://photongamemanager.com/GameManagerPages/SteamGuide.php")
	End Function

	Function BrowseButtonFun(event:wxEvent)
		Local MainWin:MainWindow = SettingsWindow(event.parent).ParentWin
		?Not Win32
		Local openFileDialog:wxDirDialog = New wxDirDialog.Create(MainWin.SettingsWindowField, "Select folder containing steam binary" ,MainWin.SettingsWindowField.SW_SteamPath.GetValue() , wxDD_DIR_MUST_EXIST)	
		If openFileDialog.ShowModal() = wxID_OK Then
			MainWin.SettingsWindowField.SW_SteamPath.ChangeValue(openFileDialog.GetPath())
		EndIf
		?Win32
		tempFile:String = RequestDir("Select steam folder" , MainWin.SettingsWindowField.SW_SteamPath.GetValue())
		If tempFile <> "" Then 
			MainWin.SettingsWindowField.SW_SteamPath.ChangeValue(tempFile)
		EndIf
		? 		
	End Function

	Method PopulateSettings()	
		If FileType("SaveLocationOverride.txt") = 1 Then 
			ReadLocationOverride = ReadFile("SaveLocationOverride.txt")
			Local TempFolderPath:String = ReadLine(ReadLocationOverride)
			CloseFile(ReadLocationOverride)	
			SW_OverridePath.ChangeValue(TempFolderPath)
		EndIf 	
		SW_SteamPath.ChangeValue(SteamFolder)
		SW_CompressLev.ChangeValue(ArtworkCompression)
		SW_DateFormat.SetValue(Country)
		SW_SteamID.ChangeValue(SteamID)
	End Method
	
	Function OptimizeAllArtFun(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "This optimizes the artwork so that FrontEnd runs better for the set resolution and compression level. Continue? (recommended only if resolution or compression level changed)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			SettingsWin.OptimizeAllArt()
		EndIf
		MessageBox.Free()	
	End Function

	Method OptimizeAllArt()
		Self.Show(0)
		Log1.Show(1)
		Log1.AddText("Optimizing Artwork")
	
		GameDir = ReadDir(GAMEDATAFOLDER)
		Repeat
			item$=NextFile(GameDir)
			If item = "" Then Exit
			If item="." Or item=".." Then Continue
			GameNode:GameType = New GameType
			If GameNode.GetGame(item) = - 1 Then
			
			Else
				Log1.AddText("Optimizing Artwork for: "+GameNode.Name)
				GameNode.OptimizeArtwork()			
			EndIf
			If Log1.LogClosed = True Then Exit 
		Forever
		CloseDir(GameDir)
		Self.Show(1)
		Log1.Show(0)		 	
	End Method 	

	Method SaveSettings()
		Local OptimizeArt = False 
		If ValidateInput()=False Then Return False
		SteamFolder = SW_SteamPath.GetValue()
		SteamID = SW_SteamID.GetValue()
		ArtworkCompression = Int(SW_CompressLev.GetValue())
		Country = SW_DateFormat.GetValue()
		For a = 1 To Len(SW_Resolution.GetValue())
			If Mid(SW_Resolution.GetValue() , a , 1) = "x" Then
				NewGraphicsW = Int(Left(SW_Resolution.GetValue() , a - 1))
				NewGraphicsH = Int(Right(SW_Resolution.GetValue() , Len(SW_Resolution.GetValue())-a))
				Exit
			EndIf
		Next
		
		If GraphicsW = NewGraphicsW And GraphicsH = NewGraphicsH Then 
		
		Else
			Local MessageBox:wxMessageDialog
	
			MessageBox = New wxMessageDialog.Create(Null, "Frontend Resolution has changed, would you like to reoptimize artwork? (recommended)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_YES Then
				OptimizeArt = True 
			EndIf
			MessageBox.Free()	
		EndIf 
		
		GraphicsW = NewGraphicsW
		GraphicsH = NewGraphicsH
		
		If SW_Runner.GetValue() = "Yes" Then
			SilentRunnerEnabled = True
		Else
			SilentRunnerEnabled = False 
		EndIf
		If SW_Cabinate.GetValue() = "Yes" Then
			CabinateEnable = True
		Else
			CabinateEnable = False 
		EndIf
		If SW_LowMem.GetValue() = "Yes" Then
			LowMemory = True
		Else
			LowMemory = False
		EndIf
		If SW_LowProc.GetValue() = "Yes" Then 
			LowProcessor = True
		Else
			LowProcessor = False
		EndIf 	
		
		GAMECACHELIMIT = Int(SW_GameCache.GetValue())
		If SW_Mode.GetValue() = "Yes" Then
			GMode = 1
		Else
			GMode = 2
		EndIf 	
		
		If SW_TouchKey.GetValue() = "Yes" Then 
			TouchKeyboardEnabled = 1
		Else
			TouchKeyboardEnabled = 0
		EndIf 	
		
		If SW_ShowTouchScreen.GetValue() = "Yes" Then 
			ShowScreenButton = 1
		Else
			ShowScreenButton = 0
		EndIf 	

		If SW_ShowTouchInfo.GetValue() = "Yes" Then 
			ShowInfoButton = 1
		Else
			ShowInfoButton = 0
		EndIf 		
	
		If SW_OverridePath.GetValue()="" Then
			DeleteFile("SaveLocationOverride.txt")
		Else
			DeleteFile("SaveLocationOverride.txt")
			tempwrite = WriteFile("SaveLocationOverride.txt")
			WriteLine(tempwrite,SW_OverridePath.GetValue())
			CloseFile(tempwrite)
		EndIf 
		
		If SW_ButtonCloseOnly.GetValue() = "Yes"
			RunnerButtonCloseOnly = 1
		Else
			RunnerButtonCloseOnly = 0
		EndIf 
			
		If SW_OriginWait.GetValue() = "Yes"
			OriginWaitEnabled = 1
		Else
			OriginWaitEnabled = 0
		EndIf 	
		
		Select SW_AntiAlias.GetValue()
			Case "None"
				AntiAliasSetting = 0
			Case "2X"
				AntiAliasSetting = 2
			Case "4X"
				AntiAliasSetting = 4
			Case "8X"
				AntiAliasSetting = 8
			Case "16X"
				AntiAliasSetting = 16
		End Select	
		
		SaveGlobalSettings()
		
		If OptimizeArt = True Then 
			Self.OptimizeAllArt()
		EndIf 
		
		Return True
	End Method

	Function SaveSettingsFun(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local MainWin:MainWindow = SettingsWindow(event.parent).ParentWin
		If MainWin.SettingsWindowField.SaveSettings() = True Then
			MessageBox = New wxMessageDialog.Create(Null , "Settings saved." , "Info" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()			
			MainWin.SettingsWindowField.ShowSettingsMenu(event)
		EndIf
	End Function
	
	Function ShowSettingsMenu(event:wxEvent)
		Local MainWin:MainWindow = SettingsWindow(event.parent).ParentWin
		MainWin.SettingsMenuField.Show()
		MainWin.SettingsWindowField.Destroy()
		MainWin.SettingsWindowField = Null 
	End Function

	Function OnQuit(event:wxEvent)
		' true is to force the frame to close
		wxWindow(event.parent).Close(True)
	End Function
End Type

Type SettingsMenu Extends wxFrame
	Field ParentWin:MainWindow	
	Field DBButton:wxBitmapButtonExtended
	Field DRBButton:wxBitmapButtonExtended
	Field PButton:wxBitmapButtonExtended
	Field GButton:wxBitmapButtonExtended	
	Field Back:wxButton

	Field HelpBox:wxTextCtrl
		
	Method OnInit()
		ParentWin = MainWindow(GetParent())

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(200,200,255))

		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 8)	
			
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		DBbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"DatabaseBackup.png" , wxBITMAP_TYPE_PNG)
		DRBbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"DatabaseRestore.png" , wxBITMAP_TYPE_PNG)
		Pbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"Plugins.png" , wxBITMAP_TYPE_PNG)
		Gbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"GeneralSettings.png" , wxBITMAP_TYPE_PNG)
		
		DBButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , SetM_DB , DBbitmap) )
		DBButton.SetFields("Clicking this will allow you to save your entire database of games into a single file which you can use to restore the database later in time.", HelpBox)
		DRBButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , SetM_DRB , DRBbitmap) )
		DRBButton.SetFields("Clicking this will allow you to restore your database of games to the state you saved it as using the above button.", HelpBox)
		PButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , SetM_PB , Pbitmap) )
		PButton.SetFields("Here you can configure and enable plugins that allow you to do various things such as take screenshots and manage power plans.", HelpBox)
		GButton = wxBitmapButtonExtended( New wxBitmapButtonExtended.Create(Self , SetM_GB , Gbitmap) )
		GButton.SetFields("Here is where you can edit the settings of all of the applications in the GameManager suite. This includes PhotonManager, PhotonFrontend, PhotonExplorer and PhotonRunner", HelpBox)
		
		?Not Win32
		PButton.Enable(0)
		DBButton.Enable(0)
		DRBButton.Enable(0)
		?
				
		Back = New wxButton.Create(Self,SetM_BB, "Back")
		
		'vbox.AddStretchSpacer(2)
		vbox.Add(DBButton , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)
		vbox.Add(DRBButton,  2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 8)		
		vbox.Add(PButton , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)
		vbox.Add(GButton , 2 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)			
				
		vbox.Add(Back,  1 , wxALIGN_LEFT | wxALL, 6)		

		Local Mainhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Mainhbox.AddSizer(vbox, 1 , wxEXPAND, 0)
		Mainhbox.AddSizer(vbox2, 1 , wxEXPAND , 0)

		SetSizer(Mainhbox)	
		Centre()
		Hide()		
		Connect(SetM_BB, wxEVT_COMMAND_BUTTON_CLICKED, ShowMainMenu)
		Connect(SetM_GB , wxEVT_COMMAND_BUTTON_CLICKED , ShowSettings)
		Connect(SetM_DB , wxEVT_COMMAND_BUTTON_CLICKED , BackupDatabase)
		Connect(SetM_DRB , wxEVT_COMMAND_BUTTON_CLICKED , RestoreDatabase)
		Connect(SetM_PB , wxEVT_COMMAND_BUTTON_CLICKED , ShowPlugins)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = SettingsMenu(event.parent).ParentWin
		MainWin.Close(True)
	End Function

	Function RestoreDatabase(event:wxEvent)
		Local MainWin:MainWindow = SettingsMenu(event.parent).ParentWin
		Local MessageBox:wxMessageDialog
		Local temp:String
		MessageBox = New wxMessageDialog.Create(Null, "Restoring a backup will delete all current games saved in your database, are you sure you wish to continue?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_NO Then
			Return
		EndIf
		
		Local BakFilename:String = RequestFile( "Select which backup to restore" , "Backup File (*.PBak):PBak" , False)
		If IsntNull(BakFilename) = False Then
			Return
		EndIf
		If FileType(BakFilename) = 0 Or FileType(BakFilename) = 2 Then
			Return
		EndIf
		If Check7zip()=True Then
			'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Database Backup" , , , 300 , 400) )
			Log1.Show(1)
			DeleteCreateFolder(GAMEDATAFOLDER)
			Local zipProcess:TProcess = RunProcess(SevenZipPath+" x "+Chr(34)+BakFilename+Chr(34) + " -o"+GAMEDATAFOLDER , 0)
			Repeat
				
				If zipProcess.status() Or zipProcess.pipe.ReadAvail() Then 
					temp = zipProcess.pipe.ReadLine()
					If IsntNull(temp) Then
						Log1.AddText(temp)
					EndIf
				Else
					Exit
				EndIf		
			Forever
			Log1.Show(0)
			MessageBox = New wxMessageDialog.Create(Null , "Restore Successful" , "Info" , wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()				
		Else
			MessageBox = New wxMessageDialog.Create(Null , "7zip Plugin not found, please install it." , "Error" , wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()	
		EndIf

	End Function

	Function BackupDatabase(event:wxEvent)
		Local MainWin:MainWindow = SettingsMenu(event.parent).ParentWin
		Local MessageBox:wxMessageDialog
		Local BakFilename:String = RequestFile( "Select where to save backup" , "Backup File (*.PBak):PBak" , True )
		Local BackFailed = False
		Local temp:String
		If IsntNull(BakFilename) = False Then
			Return
		EndIf
		If Check7zip() = True Then
			If FileType(BakFilename)=1 Then DeleteFile(BakFilename)
			'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Database Backup" , , , 300 , 400) )
			Log1.Show(1)
			Local tempdir:String = CurrentDir()
			ChangeDir(GAMEDATAFOLDER)
			Local zipProcess:TProcess = RunProcess( SevenZipPath + " a -t7z " + Chr(34) + BakFilename + Chr(34) + " " + "" + "* -mx9" , 0)
			ChangeDir(tempdir)
			Repeat
				
				If zipProcess.status() Or zipProcess.pipe.ReadAvail() Then 
					temp = zipProcess.pipe.ReadLine()
					If IsntNull(temp) Then
						Log1.AddText(temp)
					EndIf
				Else
					Exit
				EndIf	
				If Log1.LogClosed = True Then
					BakFailed = True
					DeleteFile(BakFilename)
					Exit
				EndIf
			Forever
			'Log1.Destroy()
			Log1.Show(0)
			If BakFailed = True Then
				MessageBox = New wxMessageDialog.Create(Null , "Backup canceled by user" , "Info" , wxOK)
				MessageBox.ShowModal()
				MessageBox.Free()				
			Else
				MessageBox = New wxMessageDialog.Create(Null , "Backup Successful" , "Info" , wxOK)
				MessageBox.ShowModal()
				MessageBox.Free()	
			EndIf			
		Else
			MessageBox = New wxMessageDialog.Create(Null , "7zip Plugin not found, please install it." , "Error" , wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()	
		EndIf
	End Function

	Function ShowPlugins(event:wxEvent)
		Local MainWin:MainWindow = SettingsMenu(event.parent).ParentWin
		MainWin.PluginsWindowField = PluginsWindow(New PluginsWindow.Create(MainWin , wxID_ANY , "Plugin Settings" , , , 800 , 600) )	
		MainWin.PluginsWindowField.Show()
		MainWin.SettingsMenuField.Hide()		
	End Function

	Function ShowSettings(event:wxEvent)
		Local MainWin:MainWindow = SettingsMenu(event.parent).ParentWin
		MainWin.SettingsWindowField = SettingsWindow(New SettingsWindow.Create(MainWin , wxID_ANY , "General Settings" , , , 800 , 600) )
		MainWin.SettingsWindowField.PopulateSettings()
		MainWin.SettingsWindowField.Show()
		MainWin.SettingsMenuField.Hide()			
	End Function

	Function ShowMainMenu(event:wxEvent)
		Local MainWin:MainWindow = SettingsMenu(event.parent).ParentWin
		MainWin.Show()
		MainWin.SettingsMenuField.Hide()			
	End Function
	
End Type

'Possible Fix: Create LogClosed Function, then get value of function not Log1.LogClosed in other files.
'				Within the function return value of LogClosed and when a true is returned set LogClosed back to zero
'				Make sure in other files that a single function will exit from a single LogClosed Value
Type LogWindow Extends wxFrame
	Field LogBox:wxTextCtrl
	Field LogClosed:Int
	Field UpdateTimer:wxTimer
	
	Method OnInit()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )		
		LogClosed = False
		Local Timer:wxTimer = New wxTimer.Create(Self, LW_T)
		Timer.Start(1000)
		UpdateTimer = New wxTimer.Create(Self, LW_T2)
				
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		LogBox = New wxTextCtrl.Create(Self, LW_L, "", - 1 , - 1 , - 1 , - 1, wxTE_READONLY | wxTE_MULTILINE | wxTE_BESTWRAP)
		hbox.Add(LogBox, 1 , wxEXPAND, 0)		
		SetSizer(hbox)
		Centre()	
		Show(0)	
		
		ConnectAny(wxEVT_CLOSE , CloseLog)
		Connect(LW_T, wxEVT_TIMER , UpdateTimersFun)
		Connect(LW_T2, wxEVT_TIMER , UpdateTexts)
	End Method

	Function UpdateTimersFun(event:wxEvent)
		'Cant start timers from a thread so use a slower timer to constantly check if thread wants to trigger faster timer
		LogWin:LogWindow = LogWindow(event.parent)
		?Threaded
		LockMutex(LogOpenMutex)
		?
		
		If LogOpen = 1 then
			LogWin.UpdateTimer.Start(100)
		Else
			LogWin.UpdateTimer.Stop()
		EndIf
		
		?Threaded
		UnlockMutex(LogOpenMutex)
		?	
	End Function
	
	Function UpdateTexts(event:wxEvent)
		LogWin:LogWindow = LogWindow(event.parent)
		?Threaded
		If TryLockMutex(LogWinListMutex) = 0 then Return
		?
		While CountList(LogWinList) > 0
			LogWin.LogBox.AppendText(String(LogWinList.RemoveFirst() ) + Chr(10) )
		Wend
			
		?Threaded
		UnlockMutex(LogWinListMutex)
		?
	End Function
	
	Method Show(Val:Int)
	
		?Threaded
		LockMutex(LogOpenMutex)
		?
		
		LogOpen = Val
		
		?Threaded
		UnlockMutex(LogOpenMutex)
		?		
		
		LogClosed = False
		Super.Show(Val)
		LogBox.Clear()
		'If Val = 0 then
		'	LogBox.Clear()
		'EndIf
	End Method
	
	Function CloseLog(event:wxEvent)
		LogWin:LogWindow = LogWindow(event.parent)
		LogWin.LogClosed = True
		LogWin.AddText("Closing...")
	End Function

	Method AddText(Tex:String)
		?Not Threaded
		DatabaseApp.Yield()
		?
		?Threaded
		LockMutex(LogWinListMutex)
		?
		ListAddLast(LogWinList, Tex)
		?Threaded
		UnlockMutex(LogWinListMutex)
		?
	End Method
	
End Type


Type SteamIconWindow Extends wxFrame
	Field IconList:wxListCtrl
	Field ChooseButton:wxButton
	Field UpIconButton:wxButton
	Field BackButton:wxButton
	Field SteamFolder:String
	Field GameFolder:String
	Field Selection:Int
	Field GameType:Int 
	
	Method OnInit()
		PrintF("SteamIconWindow Creation")
		Selection=-1
		'ParentWin = MainWindow(GetParent())
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		IconList = New wxListCtrl.Create(Self , SI_W , - 1 , - 1 , - 1 , - 1 , wxLC_ICON | wxLC_AUTOARRANGE)
		Local SubPanel:wxPanel = New wxPanel.Create(Self , - 1)
		Local SubPanelHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		ChooseButton = New wxButton.Create(SubPanel , SI_CB , "Choose Icon")
		UpIconButton = New wxButton.Create(SubPanel , SI_UIB , "Update Icons")
		BackButton = New wxButton.Create(SubPanel , SI_BB , "Back")
		SubPanelHbox.Add(ChooseButton , 1 , wxEXPAND | wxALL , 5)	
		SubPanelHbox.Add(UpIconButton , 2 , wxEXPAND | wxALL , 5)		
		SubPanelHbox.Add(BackButton , 1 , wxEXPAND | wxALL , 5)		
		
		SubPanel.SetSizer(SubPanelHbox)
		
		vbox.Add(IconList , 6 , wxEXPAND | wxALL , 4)		
		vbox.Add(SubPanel,  1 , wxEXPAND | wxALL, 4)		
		SetSizer(vbox)
		Populate()
		Centre()	
		Show()	
		Connect(SI_UIB, wxEVT_COMMAND_BUTTON_CLICKED, UpdateIcons)
		Connect(SI_W , wxEVT_COMMAND_LIST_ITEM_ACTIVATED , IconSelected)
		Connect(SI_W , wxEVT_COMMAND_LIST_ITEM_SELECTED , UpdateSelected)
		Connect(SI_CB , wxEVT_COMMAND_BUTTON_CLICKED, IconSelected)
		Connect(SI_BB , wxEVT_COMMAND_BUTTON_CLICKED , Back)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function CloseApp(event:wxEvent)
		event.Skip
	End Function
	
	Method Populate()
		PrintF("Populating IconWindow")
		IconList.DeleteAllItems()
		Local SteamIconList:wxImageList = New wxImageList.Create(32 , 32 , True)
		IconList.SetImageList(SteamIconList, wxIMAGE_LIST_NORMAL)
		Local ReadSteamIconDir:Int = ReadDir(TEMPFOLDER+"SteamIcons")
		Local File:String
		Local LSI:Int=0
		Repeat
			File = NextFile(ReadSteamIconDir)
			If File = "" Then Exit 
			If File="." Or File=".." Then Continue
			temp1:String = Right(File,3)
			If temp1 = "ico" Then			
				If SteamIconList.AddIcon( wxIcon.CreateFromFile( TEMPFOLDER + "SteamIcons"+ FolderSlash + File , wxBITMAP_TYPE_ICO ) ) = - 1 Then
				
				Else			
					LSI = IconList.InsertImageStringItem(LSI ,File, LSI)
					If LSI = -1 Then CustomRuntimeError("Error 8: Unable to add steam icons")		'MARK: Error 8
					LSI = LSI + 1
				EndIf
			EndIf

		Forever		
	End Method
	
	Function Back(event:wxEvent)
		Local SteamIconWin:SteamIconWindow = SteamIconWindow(event.parent)
		SteamIconWin.Destroy()
	End Function
	
	Function UpdateIcons(event:wxEvent)
		Local SteamIconWin:SteamIconWindow = SteamIconWindow(event.parent)
		Local MessageBox:wxMessageDialog
		Local DeepScan:Int
		MessageBox = New wxMessageDialog.Create(Null , "Would you like to do a deep scan? (takes a lot longer)"+Chr(10)+"Yes - Scan returns all icons, including those in the excluded folders list and dll files"+Chr(10)+"No - Do a normal scan for icons" , "Question" , wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			DeepScan = 1
			PrintF("Deep scan on")
		Else
			DeepScan = 0
			PrintF("Deep scan off")
		EndIf
		MessageBox.Free()	
		MessageBox = New wxMessageDialog.Create(Null , "About to update Icons, it may take some time and the window may stop responding, please be patient..."+Chr(10)+"Press Ok to start" , "Info" , wxOK)
		MessageBox.ShowModal()
		MessageBox.Free()			
		CopyIconsMain(SteamIconWin.SteamFolder,DeepScan)
		SteamIconWin.Populate()
	End Function
	
	Function UpdateSelected(event:wxEvent)
		Local SteamIconWin:SteamIconWindow = SteamIconWindow(event.parent)
		SteamIconWin.Selection = wxListEvent(event).GetIndex()		
	End Function
	
	Function IconSelected(event:wxEvent)
		Local SteamIconWin:SteamIconWindow = SteamIconWindow(event.parent)
		Local EditGameWin:EditGameList = EditGameList(SteamIconWin.GetParent())
		Local MessageBox:wxMessageDialog

		If SteamIconWin.Selection = - 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select an icon" , "Info" , wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()			
		Else
			IconFileString:String = SteamIconWin.IconList.GetItemText(SteamIconWin.Selection)		
			PrintF("Icon Selected "+IconFileString)
			'Print SteamIconWin.SteamFolder
			'Print SteamIconWin.GameFolder
			Select SteamIconWin.GameType
				Case 1		
					PrintF("Type: 1")		
					CopyFile(TEMPFOLDER+"SteamIcons"+FolderSlash+IconFileString,SteamIconWin.GameFolder+FolderSlash+"Icon.ico")
					
					SteamIconWin.Destroy()
					MessageBox = New wxMessageDialog.Create(Null , "Game Successfully Updated" , "Info" , wxOK)
					MessageBox.ShowModal()
					MessageBox.Free()	
					EditGameWin.PopulateGameList()
					'SteamIconWin.Selection = wxListEvent(event).GetIndex()
					'Print wxListEvent(event).GetIndex()
				Case 2
					PrintF("Type: 2")				
					EditGameWin.NewIArt = TEMPFOLDER+"SteamIcons"+FolderSlash+IconFileString
					EditGameWin.IconArt.SetImage(EditGameWin.NewIArt )
					EditGameWin.IconArt.Changed = True
					EditGameWin.Refresh()
					EditGameWin.DataChanged = True
					EditGameWin.SaveButton.Enable()
					SteamIconWin.Destroy()
			End Select
		EndIf		
	End Function	

End Type


Type ActivateMenu Extends wxFrame
	Field ParentWin:MainWindow	

	Field Activate:wxButton
	Field Back:wxButton
	
	Field UserName:wxTextCtrl
	Field UserKey:wxTextCtrl
		
	Method OnInit()
		ParentWin = MainWindow(GetParent() )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(200,200,255))
			
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		
		Local ST1 = New wxStaticText.Create(Self , wxID_ANY , "Username:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)			
		UserName = New wxTextCtrl.Create(Self , AM_UN , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local ST2 = New wxStaticText.Create(Self , wxID_ANY , "Key:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		UserKey = New wxTextCtrl.Create(Self , AM_UK , "" , - 1 , - 1 , - 1 , - 1 , 0 )

		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Activate = New wxButton.Create(Self, AM_AB, "Activate")		
		Back = New wxButton.Create(Self, AM_BB, "Back")
		
			
		vbox.Add(ST1 , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)		
		vbox.Add(UserName , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)		
		vbox.Add(ST2 , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)		
		vbox.Add(UserKey , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 8)		
		vbox.AddStretchSpacer(4)	
		vbox.AddSizer(hbox, 1, wxEXPAND | wxALL, 8)
		
		hbox.Add(Activate, 1 , wxALIGN_LEFT | wxALL, 6)		
		hbox.Add(Back, 1 , wxALIGN_LEFT | wxALL, 6)		

		SetSizer(vbox)
		Centre()
		Hide()		
		Connect(AM_BB, wxEVT_COMMAND_BUTTON_CLICKED, ShowMainMenu)
		Connect(AM_AB, wxEVT_COMMAND_BUTTON_CLICKED, ActivateFunction)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = ActivateMenu(event.parent).ParentWin
		MainWin.Close(True)
	End Function	
	
	Function ActivateFunction(event:wxEvent)
		Local MainWin:MainWindow = ActivateMenu(event.parent).ParentWin
		Local ActivateWin:ActivateMenu = ActivateMenu(event.parent)
		Local MessageBox:wxMessageDialog
		
		Local UserName:String = ActivateWin.UserName.GetValue()
		Local UserKey:String = ActivateWin.UserKey.GetValue()
		
		If keygen(UserName) = UserKey Then
			KeyFile = WriteFile(SETTINGSFOLDER + "ProgramKey.txt")
			WriteLine(KeyFile, UserName)
			WriteLine(KeyFile, UserKey)	
			CloseFile(KeyFile)
			MessageBox = New wxMessageDialog.Create(Null , "Program Activated. ~nPlease restart program." , "Info" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			MainWin.Close(True)
		Else
			MessageBox = New wxMessageDialog.Create(Null , "Invalid Username/key" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			Delay(2000)
		EndIf
		
	
	End Function
	
	Function ShowMainMenu(event:wxEvent)
		Local MainWin:MainWindow = ActivateMenu(event.parent).ParentWin
		MainWin.Show()
		MainWin.ActivateMenuField.Hide()			
	End Function
	
End Type

Type wxBitmapButtonExtended Extends wxBitmapButton
	Field DescriptionText:String
	Field TextBox:wxTextCtrl
	
	Method OnInit()
		ConnectAny(wxEVT_ENTER_WINDOW, Inside)
		ConnectAny(wxEVT_LEAVE_WINDOW, Outside)
		Super.OnInit()
	End Method
	
	Method SetFields(DT:String, TB:wxTextCtrl)
		Self.DescriptionText = DT
		Self.TextBox = TB	
	End Method
	
	Function Inside(event:wxEvent)
		Local Button:wxBitmapButtonExtended = wxBitmapButtonExtended(event.parent)
		If Button.TextBox = Null Or Button.DescriptionText = Null Then
		
		Else
			Button.TextBox.SetValue(Button.DescriptionText)
		EndIf
	End Function
	
	Function Outside(event:wxEvent)
		Local Button:wxBitmapButtonExtended = wxBitmapButtonExtended(event.parent)
		If Button.TextBox = Null Then
		
		Else
			Button.TextBox.SetValue("Help will appear here when you point your mouse over a button.")
		EndIf
	End Function	
End Type

Function CopyIconsMain(SteamFolder:String , FullSearch:Int = False)
	PrintF("Searching for Icons")
	'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Searching for Icons" , , , 300 , 400) )		
	Log1.Show(1)
	INum = 0
	DeleteCreateFolder(TEMPFOLDER + "SteamIcons")
	SteamFolder = StandardiseSlashes(SteamFolder)	
	CopyIcons(SteamFolder , FullSearch , Log1)
	CopyIcons(TEMPFOLDER + "Icons" , FullSearch , Log1)	
	DeleteCreateFolder(TEMPFOLDER + "Icons")
	'Log1.Destroy()
	Log1.Show(0)
End Function

Function CopyIcons(SteamFolder:String,FullSearch:Int , Log1:LogWindow)
	If FileType(SteamFolder) = 2 Then
		Local Dir:Int = ReadDir(SteamFolder)
		Local File:String
		Repeat
			File = NextFile(Dir)
			If File="" Then Exit
			If File="." Or File=".." Then Continue
			If FileType(SteamFolder + FolderSlash + File) = 2 Then
				If FullSearch = True Or IconFolderExclude(File) = False Then
					CopyIcons(SteamFolder + FolderSlash + File,FullSearch , Log1)
				EndIf
			Else
				If Lower(Right(File , 3) ) = "ico" Then
					Log1.AddText("Found: " + SteamFolder + FolderSlash + File)
					PrintF("Found: " + SteamFolder + FolderSlash + File)
					CopyFile(SteamFolder + FolderSlash + File , TEMPFOLDER + "SteamIcons"+FolderSlash+"SIcon" + String(INum) + ".ico")
					INum=INum+1
				EndIf
					
				If Lower(Right(File , 3) ) = "exe" Or (Lower(Right(File , 3) ) = "dll" And FullSearch = True) Then
					'DeleteCreateFolder(TEMPFOLDER + "Icons")
					'Print ExtractProgLoc + " /Source " + Chr(34) + SteamFolder + "\" + File + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons\" + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1"
					'RunProcessInProcessSpace(ExtractProgLoc + " /Source " + Chr(34) + SteamFolder + "\" + File + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons\" + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1" , Log1 , 1)
					
					Local ProcessSpace:TProcess 
	
					ProcessSpace = CreateProcess(ResourceExtractPath + " /Source " + Chr(34) + SteamFolder + FolderSlash + File + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons"+FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1")
					
					Repeat
						If ProcessSpace = Null Then Exit 
						If ProcessStatus(ProcessSpace) = 0 Then 
							Exit 
						EndIf 
						Delay 10
						
					Forever

					DatabaseApp.Yield()
					'Local ExtractIcon:TProcess = CreateProcess(ExtractProgLoc + " /Source " + Chr(34) + SteamFolder + "\" + File + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons\" + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1")
					'Repeat
					'	Delay 10
					'	If ProcessStatus(ExtractIcon)=0 Then Exit
					'Forever		
					'CopyIcons(TEMPFOLDER + "Icons",FullSearch , Log1)			
				EndIf
			
			EndIf
			If Log1.LogClosed = True Then Exit
		Forever
	Else
		CustomRuntimeError("Error 32: Cannot find folder - "+SteamFolder) 'MARK: Error 32
	EndIf
End Function

Function IconFolderExclude:Int(Folder:String)
	Select Folder
		Case "Public"
		Case "FaceFX"
		Case "EA Help"
		Default
			Return False
	End Select
	Return True
End Function

Rem
Function RunProcessInProcessSpace(Process:String , Log1:LogWindow , Fun:Int)
	Local ProcessSpace:TProcess 
	
	ProcessSpace = CreateProcess(Process)
	If ProcessSpace = Null Then Return 
	Repeat
		If ProcessStatus(ProcessSpace1) = 0 Then 
			Return
		EndIf 
	Forever
	
	'Rem
	Repeat
		If Process1Running = 0 Then
			ProcessSpace1 = CreateProcess(Process)
			Process1Running = 1
			Return
		ElseIf Process2Running = 0 Then
			ProcessSpace2 = CreateProcess(Process)
			Process2Running = 1
			Return
		ElseIf Process3Running = 0 Then
			ProcessSpace3 = CreateProcess(Process)
			Process3Running = 1
			Return
		ElseIf Process4Running = 0 Then
			ProcessSpace4 = CreateProcess(Process)
			Process4Running = 1
			Return
		ElseIf Process5Running = 0 Then
			ProcessSpace5 = CreateProcess(Process)
			Process5Running = 1
			Return
		Else
			If ProcessStatus(ProcessSpace1) = 0 And ProcessStatus(ProcessSpace2) = 0 And ProcessStatus(ProcessSpace3) = 0 And ProcessStatus(ProcessSpace4) = 0 And ProcessStatus(ProcessSpace5) = 0 Then
				Process1Running = 0
				Process2Running = 0
				Process3Running = 0
				Process4Running = 0
				Process5Running = 0
				Select Fun
					Case 1
						CopyIcons(TEMPFOLDER + "Icons" , 0 , Log1)
						DeleteCreateFolder(TEMPFOLDER + "Icons")	
					Default
						CustomRuntimeError("Error 31: Invalid ProcessSpace Function Type") 'MARK: Error 31
				End Select
				Return
			EndIf
		EndIf	
		Delay 100	
	Forever	
	'EndRem			
End Function
EndRem
Function GetGameIcon(EXEPath:String , GameName:String)
	Local temp:String , File:String
	DeleteCreateFolder(TEMPFOLDER + "Icons")
	ExtractIcon = CreateProcess(ExtractProgLoc + " /Source " + Chr(34) + StandardiseSlashes(EXEPath) + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons"+FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1")
	Repeat
		Delay 10
		If ProcessStatus(ExtractIcon)=0 Then Exit
	Forever	
	
	ReadIcons = ReadDir(TEMPFOLDER + "Icons"+FolderSlash)
	temp = ""
	Repeat
		File = NextFile(ReadIcons)
		If File = "" Then Exit
		If File="." Or File=".." Then Continue
		If ExtractExt(File) = "ico" Then
			temp = TEMPFOLDER + "Icons"+FolderSlash + File
			Exit			
		EndIf
	Forever
	CloseDir(ReadIcons)		
	If temp = "" Then

	Else
		CopyFile(TEMPFOLDER + "Icons"+FolderSlash + File , GAMEDATAFOLDER + GameName + FolderSlash+"Icon.ico")
	EndIf		
End Function

Function LoadGlobalSettings()
	'ReadSettings = ReadFile(SETTINGSFOLDER + "\GeneralSettings.txt")
	'SteamFolder = ReadLine(ReadSettings)
	'ArtworkCompression = Int(ReadLine(ReadSettings) )
	'Country = ReadLine(ReadSettings)
	'PerminantPGMOff = Int(ReadLine(ReadSettings))
	'CloseFile(ReadSettings)
	
	
	ReadSettings:SettingsType = New SettingsType
	ReadSettings.ParseFile(SETTINGSFOLDER + "GeneralSettings.xml" , "GeneralSettings")
	If ReadSettings.GetSetting("SteamFolder")<>"" Then
		SteamFolder = ReadSettings.GetSetting("SteamFolder")
	EndIf
	If ReadSettings.GetSetting("SteamID")<>"" Then
		SteamID = ReadSettings.GetSetting("SteamID")
	EndIf
	If ReadSettings.GetSetting("ArtworkCompression")<>""
		ArtworkCompression = Int(ReadSettings.GetSetting("ArtworkCompression") )
	EndIf
	If ReadSettings.GetSetting("Country")<>"" Then 
		Country = ReadSettings.GetSetting("Country")
	EndIf
	If ReadSettings.GetSetting("PGMOff")<>"" Then 
		PerminantPGMOff = Int(ReadSettings.GetSetting("PGMOff") )
	EndIf
	If ReadSettings.GetSetting("GraphicsWidth") <> "" Then	
		GraphicsW = Int(ReadSettings.GetSetting("GraphicsWidth"))
	EndIf
	If ReadSettings.GetSetting("GraphicsHeight") <> "" Then	
		GraphicsH = Int(ReadSettings.GetSetting("GraphicsHeight"))
	EndIf 		
	If ReadSettings.GetSetting("GraphicsMode") <> "" Then	
		GMode = Int(ReadSettings.GetSetting("GraphicsMode"))
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
	If ReadSettings.GetSetting("AntiAlias") <> "" Then		
		AntiAliasSetting = Int(ReadSettings.GetSetting("AntiAlias"))
	EndIf			
	If ReadSettings.GetSetting("ShowInfoButton") <> "" Then		
		ShowInfoButton = Int(ReadSettings.GetSetting("ShowInfoButton") )
	EndIf		
	If ReadSettings.GetSetting("ShowScreenButton") <> "" Then		
		ShowScreenButton = Int(ReadSettings.GetSetting("ShowScreenButton"))
	EndIf			
	
	ReadSettings.CloseFile()
End Function

Function SaveGlobalSettings()
	SaveSettings:SettingsType = New SettingsType
	SaveSettings.ParseFile(SETTINGSFOLDER + "GeneralSettings.xml" , "GeneralSettings")
	SaveSettings.SaveSetting("SteamFolder" , SteamFolder)
	SaveSettings.SaveSetting("SteamID" , SteamID)	
	SaveSettings.SaveSetting("ArtworkCompression" , ArtworkCompression)
	SaveSettings.SaveSetting("Country" , Country)
	SaveSettings.SaveSetting("PGMOff" , PerminantPGMOff)
	SaveSettings.SaveSetting("SilentRunOff" , SilentRunnerEnabled)
	SaveSettings.SaveSetting("Cabinate" , CabinateEnable)	
	SaveSettings.SaveSetting("RunnerButtonCloseOnly" , RunnerButtonCloseOnly)	
	SaveSettings.SaveSetting("OriginWaitEnabled" , OriginWaitEnabled)	
	SaveSettings.SaveSetting("GraphicsWidth" , GraphicsW)
	SaveSettings.SaveSetting("GraphicsHeight" , GraphicsH)
	SaveSettings.SaveSetting("GraphicsMode" , GMode)
	SaveSettings.SaveSetting("GameCache" , GAMECACHELIMIT)
	SaveSettings.SaveSetting("LowMem" , LowMemory)
	SaveSettings.SaveSetting("LowProc" , LowProcessor)
	SaveSettings.SaveSetting("TouchKey" , TouchKeyboardEnabled)	
	SaveSettings.SaveSetting("AntiAlias" , AntiAliasSetting)		
	SaveSettings.SaveSetting("ShowInfoButton" , ShowInfoButton)	
	SaveSettings.SaveSetting("ShowScreenButton" , ShowScreenButton)	
	
	SaveSettings.SaveFile()
	SaveSettings.CloseFile()
	
End Function

Type PMFactory Extends TCustomEventFactory
        Method CreateEvent:wxEvent(wxEventPtr:Byte Ptr, evt:TEventHandler)
                Select evt.eventType
                        Case wxEVT_COMMAND_SEARCHPANEL_SELECTED, wxEVT_COMMAND_SEARCHPANEL_SOURCECHANGED, wxEVT_COMMAND_SEARCHPANEL_NEWSEARCH
                                Return wxCommandEvent.Create(wxEventPtr, evt)
                End Select
                Return Null
        End Method
End Type

Rem
Function RestartProgram()
	If Debug = True Then
		RunProcess("RestartManager-Debug.bat" , 1)
	Else
		RunProcess("RestartManager.bat" , 1)
	EndIf

End Function
EndRem
		
Include "Includes\DatabaseManager\GameExplorerExtract.bmx"
Include "Includes\DatabaseManager\SteamExtract.bmx"
Include "Includes\DatabaseManager\DatabaseInternetFunctions.bmx"
Include "Includes\General\ValidationFunctions.bmx"
Include "Includes\General\General.bmx"
Include "Includes\DatabaseManager\Games.bmx"
Include "Includes\DatabaseManager\PluginConfigs.bmx"
Include "Includes\DatabaseManager\InputSettings.bmx"
Include "Includes\DatabaseManager\LuaFunctions.bmx"
Include "Includes\DatabaseManager\DatabaseSearchPanelType.bmx"


