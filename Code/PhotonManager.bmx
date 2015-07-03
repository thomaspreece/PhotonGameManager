'TODO: Update Backup and Restore Functions
'NOTE: PhotonUpdater, PhotonTray dont load GeneralSettings and hence don't load DebugLog Setting


'TODO: Update Artwork BrowseOnline Function
'TODO: Hover over online game choice and show artwork thumb / More info button: downloads lua and displays the info
'TODO: Add in version information into configuration files to allow for easy updates
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
'OLDBUG: My Programs Crash when Using CreateProcess on Windows to load them from another program, No Idea Why... FIXED: with WinExec used for my programs ONLY
'TODO: Detect/ Load Country (in General/GlobalConsts) (for Global Country:String = "UK")
'Ex: Open Databasemanager, run steam wiz, close when searching, input steam manual, run steam wizard
'FIX: Icon png/jpg - Need FreeImage... Appears to fail badly(freeimage that is)

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
Import wx.wxgauge
Import wx.wxcolourpickerctrl
Import wx.wxradiobox

Import BaH.libcurlssl
Import Bah.libxml
Import Bah.Volumes
Import bah.regex
Import bah.libarchive

Import BAH.FreeImage
'Import BRL.JPGLoader
'Import BRL.PNGLoader

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
Import "..\Icons\PhotonManager.o"
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

AppTitle = "PhotonManager"

Include "Includes\General\StartupOverrideCheck.bmx"
Local TempFolderPath:String = OverrideCheck(FolderSlash)

Include "Includes\General\GlobalConsts.bmx"
Include "Includes\DatabaseManager\GlobalsConsts.bmx"

AppTitle = "Photon"
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

SubVersion = ExtractSubVersion(LoadText("incbin::Version/PM-Version.txt"), 1)
OSubVersion = ExtractSubVersion(LoadText("incbin::Version/OverallVersion.txt"), 1)

Print "Version = " + CurrentVersion
Print "SubVersion = " + SubVersion
Print "OSubVersion = " + OSubVersion


Local PastArgument:String
For Argument$ = EachIn AppArgs$
	Select PastArgument
		Case "-EditGame", "EditGame"
			EditGameName = Argument
			PastArgument = ""
		Case "-Debug","Debug"
			If int(Argument) = 1 then
				DebugLogEnabled = True
			EndIf 
			PastArgument = ""
		Default
			Select Argument
				Case "-Debug" , "-EditGame", "Debug" , "EditGame"
					PastArgument = Argument
			End Select
	End Select
Next

Global DatabaseApp:wxApp

PrintF("Starting DM")
DatabaseApp = New DatabaseManager
DatabaseApp.Run()

EndLuaVM()
End

Type DatabaseManager Extends wxApp
	Field Menu:MainWindow
	Field Wizard:FirstRunWizard
	Field Splash:SplashFrame
	
	Method OnInit:Int()
		wxImage.AddHandler( New wxICOHandler)		
		wxImage.AddHandler( New wxPNGHandler)		
		wxImage.AddHandler( New wxJPEGHandler)	
		
		New PMFactory
		
		Splash = SplashFrame(New SplashFrame.Create(Null, wxID_ANY, "Photon Loading...", - 1, - 1, 600, 225, 0) )	
		Local Timer:wxTimer = New wxTimer.Create(Self, wxID_ANY)
		Timer.Start(100, 1)
		ConnectAny(wxEVT_TIMER, Startup)
			
		Return True

	End Method
	
	Function Startup(event:wxEvent)
		Local DM:DatabaseManager = DatabaseManager(event.parent)
						
		?Threaded
		Local StartupThread:TThread = CreateThread(Thread_Startup, DM.Splash)
		While ThreadRunning(StartupThread)
			DM.Yield()
			Delay 100
		Wend
		?Not Threaded
		Thread_Download(DM.Splash)
		?

		If DebugLogEnabled = False then
			DeleteFile(LOGFOLDER + LogName)
		EndIf

		If EvaluationMode = True then
			Notify "You are running in evaluation mode, this limits you to the first 5 games added to the database in FrontEnd and PhotonExplorer"
		EndIf
		
		DM.StartupMain()
	End Function	
	
	Method StartupMain()
		If FileType(SETTINGSFOLDER + "GeneralSettings.xml") = 1 then
		
		Else
			Local Wizard:FirstRunWizard = FirstRunWizard(New FirstRunWizard.Create(Null, wxID_ANY, "First Run Wizard", Null, - 1, - 1, wxRESIZE_BORDER | wxDEFAULT_DIALOG_STYLE | wxMAXIMIZE_BOX ) )
			Wizard.Setup()
			Wizard.RunWizard(Wizard.Page1)
			Wizard.Destroy()
		EndIf
		
		Menu = MainWindow(New MainWindow.Create(Null , wxID_ANY, "DatabaseManager", - 1, - 1, 600, 400, wxDEFAULT_FRAME_STYLE ) )
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

	LogName = "Log-Manager " + CurrentDate() + " " + Replace(CurrentTime(), ":", "-") + ".txt"
	CreateFile(LOGFOLDER+LogName)

	Splash.SetStatusText("Loading settings")
	LoadGlobalSettings()
	LoadManagerSettings()
	LoadExplorerSettings()

	CheckKey()
	
	Splash.SetStatusText("Loading resources")
	SearchBeep = LoadSound("Resources" + FolderSlash + "BEEP.wav")

	
	WindowsCheck()
	
	Splash.SetStatusText("Loading platforms")
	SetupPlatforms()
	OldPlatformListChecks()

	Splash.SetStatusText("Checking internet connection")
	CheckInternet()
	'CheckPGMInternet()
	CheckVersion()
	CheckEXEDatabaseStatus()

	Splash.SetStatusText("Checking game database")
	'ValidateGames()
	GamesCheck()

	Splash.SetStatusText("Setting up LuaMachine")
	StartupLuaVM()		

	Splash.SetStatusText("Loading main window...")
End Function


Type FirstRunWizard Extends wxWizard	Field Page1:wxWizardPageSimple
	
	
	
	Field DateCombo:wxComboBox
	Field InputRadio:wxRadioBox
	Field ResolutionCombo:wxComboBox
	
	
	
	Method Setup()
		PrintF("Begin Startup Wizard")
		Page1:wxWizardPageSimple = wxWizardPageSimple(New wxWizardPageSimple.CreateSimple(Self, Null, Null) )
		Local Page2:wxWizardPageSimple = wxWizardPageSimple(New wxWizardPageSimple.CreateSimple(Self, Null, Null) )
		Local Page3:wxWizardPageSimple = wxWizardPageSimple(New wxWizardPageSimple.CreateSimple(Self, Null, Null) )
		Local Page4:wxWizardPageSimple = wxWizardPageSimple(New wxWizardPageSimple.CreateSimple(Self, Null, Null) )
		Local Page5:wxWizardPageSimple = wxWizardPageSimple(New wxWizardPageSimple.CreateSimple(Self, Null, Null) )
		
		Page1.SetNext(Page2)
		Page2.SetPrev(Page1)
		Page2.SetNext(Page3)
		Page3.SetPrev(Page2)
		Page3.SetNext(Page4)
		Page4.SetPrev(Page3)
		Page4.SetNext(Page5)
		Page5.SetPrev(Page4)
		
		'------------------------------------PAGE 1------------------------------------
		Local TextField = New wxStaticText.Create(Page1 , wxID_ANY , "Welcome to Photon V4~nAs this is the first time you have run Photon we need to ask you some questions to get you setup.~nClick Next to continue", - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTER)
		Local P1vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		P1vbox.AddStretchSpacer(1)
		P1vbox.Add(TextField , 1 , wxEXPAND | wxALL , 10)
		P1vbox.AddStretchSpacer(1)		
		Page1.SetSizer(P1vbox)
		'------------------------------------PAGE 2------------------------------------
		Local TextField2 = New wxStaticText.Create(Page2 , wxID_ANY , "Photon has been coded entirely by myself in my spare time and has become a passion as well as a hobby so I hope you enjoy the fruits of my labour. If you have any problems, find any bugs or have any feedback please don't hesitate to contact me on my website: photongamemanager.com, without the publics feedback the product wouldn't be what it is today so I do really appreciate folks taking the time to write to me. ~n~nAnyway enough of my talking, click Next to continue and enjoy :)", - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		Local P2vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		P2vbox.AddStretchSpacer(1)
		P2vbox.Add(TextField2 , 6 , wxEXPAND | wxALL , 10)
		P2vbox.AddStretchSpacer(1)		
					
		Page2.SetSizer(P2vbox)		
		
		
		'------------------------------------PAGE 3------------------------------------
		Local P3vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local TextField3:wxStaticText = New wxStaticText.Create(Page3 , wxID_ANY , "Photon Frontend can be controlled by many different inputs. Selecting the input below disables uneeded on screen controls for other inputs. (Can be changed later in settings menu)", - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTER)
		Local SL3:wxStaticLine = New wxStaticLine.Create(Page3, wxID_ANY, - 1, - 1, - 1, - 1, wxLI_HORIZONTAL)
		InputRadio = New wxRadioBox.Create(Page3, wxID_ANY, "Input", - 1, - 1, - 1, - 1, ["Keyboard Only", "Keyboard/Mouse", "Touchscreen", "Joystick/Controller", "All of the above"], 0, wxRA_VERTICAL)
		'Local InputText:wxTextCtrl = New wxTextCtrl.Create(Page3, wxID_ANY, "", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY)
		
		P3vbox.Add(TextField3 , 1 , wxEXPAND | wxALL , 10)
		P3vbox.Add(SL3 , 0 , wxEXPAND | wxALL , 10)
		P3vbox.Add(InputRadio , 1 , wxEXPAND | wxALL , 10)
		'P3vbox.Add(InputText , 1 , wxEXPAND | wxALL , 10)
		
		Page3.SetSizer(P3vbox)
		
		'------------------------------------PAGE 4------------------------------------
		Local P4vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local TextField4:wxStaticText = New wxStaticText.Create(Page4 , wxID_ANY , "Please select the resolution for the Frontend program. If you are not going to be using Frontend, select the resolution of your desktop as it is also used to optimize artwork. (Can be changed later in settings menu)", - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTER)
		Local SL4:wxStaticLine = New wxStaticLine.Create(Page4, wxID_ANY, - 1, - 1, - 1, - 1, wxLI_HORIZONTAL)
		Local TextField4_2:wxStaticText = New wxStaticText.Create(Page4 , wxID_ANY , "Frontend Resolution:", - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		ResolutionCombo = New wxComboBox.Create(Page4, wxID_ANY, "", Null, - 1, - 1, - 1, - 1, wxCB_DROPDOWN | wxCB_READONLY)
		
		Local wid:Int , hei:Int , dep:Int , hert:Int
		For a = 0 To CountGraphicsModes() - 1
		
			GetGraphicsMode(a , wid , hei , dep , hert)
			If dep => 32 And wid => 640 And hei >= 480 Then
				If ResolutionCombo.FindString(wid + "x" + hei) = - 1 then
					ResolutionCombo.Append(wid + "x" + hei)
				EndIf
			EndIf
		Next
		
		ResolutionCombo.SetSelection(ResolutionCombo.GetCount() - 1)
		
		P4vbox.Add(TextField4 , 3 , wxEXPAND | wxALL , 10)
		P4vbox.Add(SL4 , 0 , wxEXPAND | wxALL , 10)
		P4vbox.Add(TextField4_2 , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT | wxBOTTOM , 10)
		P4vbox.Add(ResolutionCombo , 0 , wxEXPAND | wxBOTTOM | wxLEFT | wxRIGHT , 10)
		P4vbox.AddStretchSpacer(2)
		
		Page4.SetSizer(P4vbox)
		'------------------------------------PAGE 5------------------------------------
		Local P5vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local TextField5:wxStaticText = New wxStaticText.Create(Page5 , wxID_ANY , "Generic Settings ~n(Can be changed later in settings menu)", - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTER)
		Local SL5:wxStaticLine = New wxStaticLine.Create(Page5, wxID_ANY, - 1, - 1, - 1, - 1, wxLI_HORIZONTAL)
	
		Local TextField5_2:wxStaticText = New wxStaticText.Create(Page5 , wxID_ANY , "Date Format:", - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DateCombo = New wxComboBox.Create(Page5, wxID_ANY, "UK", ["UK", "US", "EU"] , - 1, - 1, - 1, - 1, wxCB_DROPDOWN | wxCB_READONLY)

	
		P5vbox.Add(TextField5 , 1 , wxEXPAND | wxALL , 10)
		P5vbox.Add(SL5 , 0 , wxEXPAND | wxALL , 10)	
		P5vbox.Add(TextField5_2 , 0 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT | wxBOTTOM, 10)	
		P5vbox.Add(DateCombo , 0 , wxEXPAND | wxBOTTOM | wxLEFT | wxRIGHT , 10)	
		P5vbox.AddStretchSpacer(2)
		Page5.SetSizer(P5vbox)
		
		ConnectAny(wxEVT_WIZARD_CANCEL, WizardCancel)
		ConnectAny(wxEVT_WIZARD_FINISHED, WizardFinished)
	End Method

	Function WizardCancel(event:wxEvent)
		PrintF("Cancel")
		SaveGlobalSettings()
	End Function
	
	Function WizardFinished(event:wxEvent)
		Local Wizard:FirstRunWizard = FirstRunWizard(event.parent)
		PrintF("Finished")
		
		Country = Wizard.DateCombo.GetValue()
		
		For a = 1 To Len(Wizard.ResolutionCombo.GetValue() )
			If Mid(Wizard.ResolutionCombo.GetValue() , a , 1) = "x" then
				GraphicsW = Int(Left(Wizard.ResolutionCombo.GetValue() , a - 1) )
				GraphicsH = Int(Right(Wizard.ResolutionCombo.GetValue() , Len(Wizard.ResolutionCombo.GetValue() ) - a) )
				Exit
			EndIf
		Next
		
		Select Wizard.InputRadio.GetStringSelection()
			Case "Keyboard Only"
				TouchKeyboardEnabled = 0
				ShowInfoButton = 0
				ShowScreenButton = 0
			Case "Keyboard/Mouse"
				TouchKeyboardEnabled = 0
				ShowInfoButton = 1
				ShowScreenButton = 1		
			Case "Touchscreen"
				TouchKeyboardEnabled = 1
				ShowInfoButton = 1
				ShowScreenButton = 1		
			Case "Joystick/Controller"
				TouchKeyboardEnabled = 1
				ShowInfoButton = 0
				ShowScreenButton = 0			
			Case "All of the above"
				TouchKeyboardEnabled = 1
				ShowInfoButton = 1
				ShowScreenButton = 1			
			Default
				CustomRuntimeError("Wizard Error: Invalid Input String")
		End Select
		SaveGlobalSettings()
	End Function

End Type


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
	'Field EmulatorsListField:EmulatorsList
	Field PlatformsListField:PlatformsList
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
		
		
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Log1 = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Log" , , , 300 , 400) )
		
		Self.Centre()
		'timer = New wxTimer.Create(Self , wxID_ANY)
		'timer.Start(3000)
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		'Self.Refresh
		
		
		
		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		'vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxALL, 8)	
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		AGbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "AddButton.png" , wxBITMAP_TYPE_PNG)
		AGButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , MW_AGB , AGbitmap) )
		AGButton.SetFields("Add new games to Photon here.", HelpBox)
		AGButton.SetForegroundColour(New wxColour.Create(100 , 100 , 255) )
	
		EGbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"EditGames.png" , wxBITMAP_TYPE_PNG)
		EGButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , MW_EGB , EGbitmap) )
		EGButton.SetFields("Edit games that you have already added to Photon here.", HelpBox)
		EGButton.SetForegroundColour(New wxColour.Create(100 , 100 , 255) )
		
		Ebitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"Emulators.png" , wxBITMAP_TYPE_PNG)
		EButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , MW_EB , Ebitmap) )
		EButton.SetFields("From here you can change, add and remove Platforms as well as change their details such as name, default emulator and type.", HelpBox)
		EButton.SetForegroundColour(New wxColour.Create(100 , 100 , 255) )
		
		GSbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"Settings.png" , wxBITMAP_TYPE_PNG)
		GSButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , MW_GS , GSbitmap) )
		GSButton.SetFields("Change settings for all the applications within the Photon program suite. Also backup and restore your game database.", HelpBox)
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
		ImportMenuField = ImportMenu(New ImportMenu.Create(Self , wxID_ANY , "Game Explorer Import Select" , , , 600 , 400) )
		SteamMenuField = SteamMenu(New SteamMenu.Create(Self, wxID_ANY, "Steam Import Select", , , 600, 400) )
		AddGamesMenuField = AddGamesMenu(New AddGamesMenu.Create(Self, wxID_ANY, "Add Games Select", , , 600, 400) )
		SettingsMenuField = SettingsMenu(New SettingsMenu.Create(Self , wxID_ANY , "Settings Select" , , , 600 , 400) )	
		ActivateMenuField = ActivateMenu(New ActivateMenu.Create(Self , wxID_ANY , "Activate" , , , 300 , 230) )
					
											

		
		'OnlineAddField Now loaded ON demand
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
		
		'MainWin.EmulatorsListField = EmulatorsList(New EmulatorsList.Create(MainWin , wxID_ANY , "Emulator List" , , , 800 , 600) )	
		MainWin.PlatformsListField = PlatformsList(New PlatformsList.Create(MainWin , wxID_ANY , "Platform List" , , , 800 , 600) )	
		'MainWin.EmulatorsListField.Show(True)
		MainWin.PlatformsListField.Show(True)
		MainWin.Hide()
		'MainWin.EmulatorsListField.Raise()
		MainWin.PlatformsListField.Raise()
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
		MainWin.EditGameListField = EditGameList(New EditGameList.Create(MainWin, wxID_ANY, "Games", , , 900, 650, wxDEFAULT_FRAME_STYLE | wxTAB_TRAVERSAL) )	
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
		
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )

		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		'vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxALL, 8)	
		
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
		If Connected = False then
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
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
	
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )

		ParentWin = MainWindow(GetParent())
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		
		Local ExplainST:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , SCA_ET_Text , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		
		Local NameText:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , "Name:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		NameTextBox = New wxTextCtrl.Create(Self, SCA_NTB , "" , - 1 , - 1 , - 1 , - 1 , 0 )		
		Local IDText:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , "Steam ID:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		IDTextBox = New wxTextCtrl.Create(Self, SCA_ITB , "" , - 1 , - 1 , - 1 , - 1 , 0 )	
		
		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
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
		If IsntNull(MainWin.SteamCustomAddField.NameTextBox.GetValue() ) = False then
			MessageBox = New wxMessageDialog.Create(Null , "Please enter a name for the steam game" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return
		EndIf
		If Int(MainWin.SteamCustomAddField.IDTextBox.GetValue() ) < 1 then
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


		'newevent:wxEvent = event
		'newevent.parent = MainWin.GetEventHandler()
		
		'MainWin.ShowEditGameList(event)		
		MainWin.SteamCustomAddField.Hide()	
				
		MainWin.SteamMenuField.Show(1)		
				
		'MainWin.EditGameListField.PopulateGameList()
		
		'Local ID:Int = MainWin.EditGameListField.GameList.FindItem( - 1 , MainWin.SteamCustomAddField.NameTextBox.GetValue() )
		'MainWin.EditGameListField.GameList.SetitemState(ID,wxLIST_STATE_SELECTED,wxLIST_MASK_TEXT | wxLIST_MASK_IMAGE  )
		
		
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

		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )

		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		'vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxALL, 8)	
			
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

		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )

		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		'vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxALL, 8)	
			
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
'Include "Includes\DatabaseManager\EmulatorList.bmx"
'----------------------------------------------------------------------------------------------------------
'-----------------------------------PLATFORMS LIST---------------------------------------------------------
Include "Includes\DatabaseManager\PlatformList.bmx"

Type PluginsWindow Extends wxFrame
	Field ScrollBox:wxScrolledWindow
	Field PluginName:TList
	Field EnabledCombo:TList
	Field PluginType:TList	
	Field ParentWin:MainWindow
		
	Method OnInit()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
				
		ParentWin = MainWindow(GetParent())
		Local File:String , File2:String
		Local bID:Int = 0
		Local tempstatictext:wxStaticText
		Local tempstatictext2:wxStaticText
		Local tempcombobox:wxComboBox
		Local tempcombobox2:wxComboBox
		Local temphbox:wxBoxSizer, temphbox2:wxBoxSizer, temphbox3:wxBoxSizer
		
		PluginName = CreateList()
		EnabledCombo = CreateList()
		PluginType = CreateList()	
		
		Self.center()
		Self.Hide()
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local Panel2:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel2.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local P2Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local HelpText:wxTextCtrl = New wxTextCtrl.Create(Panel2, wxID_ANY, "Plugins", - 1, - 1, - 1, - 1, wxTE_READONLY | wxTE_MULTILINE | wxTE_CENTER)
		HelpText.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		P2Hbox.Add(HelpText , 1 , wxEXPAND | wxALL , 10)
		Panel2.SetSizer(P2Hbox)
		
		ScrollBox = New wxScrolledWindow.Create(Self)
		'Local SB_vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local gridbox:wxFlexGridSizer = New wxFlexGridSizer.Create(5)
		gridbox.SetFlexibleDirection(wxHORIZONTAL)
		gridbox.AddGrowableCol(1, 1)		
		
		ReadPlugins = ReadDir(StripSlash(APPFOLDER) )
		Repeat
			EnabledAble = False
			File = NextFile(ReadPlugins)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue 
			If FileType(APPFOLDER + File) = 2 And File <> "critical" then
				'temphbox = New wxBoxSizer.Create(wxHORIZONTAL)
				'temphbox2 = New wxBoxSizer.Create(wxHORIZONTAL)
				'temphbox3 = New wxBoxSizer.Create(wxHORIZONTAL)
				
				tempstatictext = New wxStaticText.Create(ScrollBox , wxID_ANY , File + " plugin:")
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
				If tempcombobox2.GetValue() = "" Or tempcombobox.GetValue() = "" then
					tempcombobox.SelectItem(0)
					tempcombobox2.SetValue("No")
				EndIf

				ReadSettings.CloseFile()
				'temphbox.Add(tempstatictext , 1 , wxEXPAND | wxALL , 7)
				'temphbox.Add(tempcombobox , 2 , wxEXPAND | wxALL , 5)
				
				'temphbox2.Add(tempButton , 1 ,wxEXPAND | wxALL , 3)
				'temphbox2.Add(tempstatictext2, 0 , wxEXPAND | wxALL , 7)
				'temphbox2.Add(tempcombobox2 , 1 , wxEXPAND | wxALL , 5)
				
				'temphbox3.AddSizer(temphbox , 1 , wxEXPAND , 0)
				'temphbox3.AddSizer(temphbox2 , 1 ,wxEXPAND , 0)
				
				
				gridbox.Add(tempstatictext , 1 , wxEXPAND | wxALL , 7)
				gridbox.Add(tempcombobox , 2 , wxEXPAND | wxALL , 5)
				
				gridbox.Add(tempButton , 1 , wxEXPAND | wxALL , 3)
				gridbox.Add(tempstatictext2, 0 , wxEXPAND | wxALL , 7)
				gridbox.Add(tempcombobox2 , 1 , wxEXPAND | wxALL , 5)
				
				
				ListAddLast(PluginType , File)
				ListAddLast(PluginName , tempcombobox)
				ListAddLast(EnabledCombo , tempcombobox2)
				'SB_vbox.AddSizer(gridbox , 0 , wxEXPAND , 0)
			EndIf 
		Forever
		CloseDir(ReadPlugins)
		
		
		'SB_vbox.RecalcSizes()
		ScrollBox.SetSizer(gridbox)
		ScrollBox.SetScrollRate(10 , 10)
		Self.Update()
		ScrollBox.Update()
		
		If PMMaximize = 1 then
			Self.Maximize(1)
		EndIf 		
		
		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Local P1Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BackButton:wxButton = New wxButton.Create(Panel1 , PW_BB , "Back")
		Local OKButton:wxButton = New wxButton.Create(Panel1, PW_OB , "OK")

		P1Hbox.Add(BackButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.AddStretchSpacer(3)
		P1Hbox.Add(OKButton , 1 , wxEXPAND | wxALL , 10)
		
		Panel1.SetSizer(P1Hbox)
		
		vbox.Add(Panel2 , 0 , wxEXPAND | wxALL , 10)
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
							Local PowerPlanPlugin:PowerPlanPluginWindow = PowerPlanPluginWindow(New PowerPlanPluginWindow.Create(PluginWin , wxID_ANY , "PowerPlan Settings" , , , 400 , 300) )
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
			WriteSettings.ParseFile(APPFOLDER + String(PluginTypeArray[a]) + FolderSlash + "PM-CONFIG.xml" , "PluginSelection")
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
		
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )

		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Local HelpST:wxStaticText = New wxStaticText.Create(Self, wxID_ANY, "Help", - 1, - 1, - 1, - 1, wxALIGN_CENTRE)
		HelpBox = New wxTextCtrl.Create(Self, wxID_ANY, "Help will appear here when you point your mouse over a button.", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY )
		
		'vbox2.Add(HelpST, 0 , wxEXPAND | wxALL, 8)				
		vbox2.Add(HelpBox, 1 , wxEXPAND | wxALL, 8)	
			
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		DBbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"DatabaseBackup.png" , wxBITMAP_TYPE_PNG)
		DRBbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources"+FolderSlash+"DatabaseRestore.png" , wxBITMAP_TYPE_PNG)
		Pbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "Plugins.png" , wxBITMAP_TYPE_PNG)
		Gbitmap:wxBitmap = New wxBitmap.CreateFromFile("Resources" + FolderSlash + "GeneralSettings.png" , wxBITMAP_TYPE_PNG)
		
		DBButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , SetM_DB , DBbitmap) )
		DBButton.SetFields("Clicking this will allow you to save your entire database of games into a single file which you can use to restore the database later in time.", HelpBox)
		DRBButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , SetM_DRB , DRBbitmap) )
		DRBButton.SetFields("Clicking this will allow you to restore your database of games to the state you saved it as using the above button.", HelpBox)
		PButton = wxBitmapButtonExtended(New wxBitmapButtonExtended.Create(Self , SetM_PB , Pbitmap) )
		PButton.SetFields("Here you can configure and enable plugins that allow you to do various things such as take screenshots and manage power plans.", HelpBox)
		GButton = wxBitmapButtonExtended( New wxBitmapButtonExtended.Create(Self , SetM_GB , Gbitmap) )
		GButton.SetFields("Here is where you can edit the settings of all of the applications in the Photon program suite. This includes PhotonManager, PhotonFrontend, PhotonExplorer and PhotonRunner", HelpBox)
		
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
		If MessageBox.ShowModal() = wxID_NO then
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
		If Check7zip() = True then
			If FileType(BakFilename) = 1 then DeleteFile(BakFilename)
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
	Field SubProgress:wxGauge
	Field Progress:wxGauge
	
	Method OnInit()
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
	
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )		
		LogClosed = False
		Local Timer:wxTimer = New wxTimer.Create(Self, LW_T)
		Timer.Start(1000)
		UpdateTimer = New wxTimer.Create(Self, LW_T2)
				
		
				
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		LogBox = New wxTextCtrl.Create(Self, LW_L, "", - 1 , - 1 , - 1 , - 1, wxTE_READONLY | wxTE_MULTILINE | wxTE_BESTWRAP)
		
		Progress = New wxGauge.Create(Self, wxID_ANY, 100, - 1, - 1, - 1, - 1, wxGA_HORIZONTAL)		
		SubProgress = New wxGauge.Create(Self, wxID_ANY, 100, - 1, - 1, - 1, - 1, wxGA_HORIZONTAL)		
		
		hbox.Add(LogBox, 1 , wxEXPAND, 0)		
		hbox.Add(SubProgress, 0 , wxEXPAND, 0)	
		hbox.Add(Progress, 0 , wxEXPAND, 0)	
		
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
		
		Self.Progress.SetValue(0)
		Self.SubProgress.SetValue(0)
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
		Local EditGameWin:EditGameList = EditGameList(SteamIconWin.GetParent() )
		EditGameWin.Enable()
		SteamIconWin.Destroy()
	End Function
	
	Function UpdateIcons(event:wxEvent)
		Local SteamIconWin:SteamIconWindow = SteamIconWindow(event.parent)
		Local MessageBox:wxMessageDialog
		Local DeepScan:Int
		MessageBox = New wxMessageDialog.Create(Null , "Would you like to do a deep scan? (takes a lot longer)" + Chr(10) + "Yes - Scan returns all icons, including those in the excluded folders list and dll files" + Chr(10) + "No - Do a normal scan for icons" , "Question" , wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			DeepScan = 1
			PrintF("Deep scan on")
		Else
			DeepScan = 0
			PrintF("Deep scan off")
		EndIf
		MessageBox.Free()	
		MessageBox = New wxMessageDialog.Create(Null , "About to update Icons, it may take some time, please be patient..." + Chr(10) + "Press Ok to start" , "Info" , wxOK)
		MessageBox.ShowModal()
		MessageBox.Free()			
		SteamIconWin.Hide()
		ExtractSteamIcons(SteamIconWin.SteamFolder, DeepScan)
		SteamIconWin.Show(1)
		SteamIconWin.Populate()
	End Function
	
	Function UpdateSelected(event:wxEvent)
		Local SteamIconWin:SteamIconWindow = SteamIconWindow(event.parent)
		SteamIconWin.Selection = wxListEvent(event).GetIndex()		
	End Function
	
	Function IconSelected(event:wxEvent)
		Local SteamIconWin:SteamIconWindow = SteamIconWindow(event.parent)
		Local EditGameWin:EditGameList = EditGameList(SteamIconWin.GetParent() )
		EditGameWin.Enable()
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

		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
			
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



Type wxComboHelpBox Extends wxComboBox
	Field DescriptionText:String
	Field OldDescriptionText:String
	Field TextBox:wxTextCtrl

	Method OnInit()
		ConnectAny(wxEVT_ENTER_WINDOW, Inside)
		ConnectAny(wxEVT_LEAVE_WINDOW, Outside)
		Super.OnInit()
	End Method
	
	Method SetFields(Desc:String, OldDesc:String, Box:wxTextCtrl)
		Self.DescriptionText = Desc
		Self.OldDescriptionText = OldDesc
		Self.TextBox = Box
	End Method	
	
	Function Inside(event:wxEvent)
		Local Button:wxComboHelpBox = wxComboHelpBox(event.parent)
		If Button.TextBox = Null Or Button.DescriptionText = Null Then
		
		Else
			Button.TextBox.SetValue(Button.DescriptionText)
		EndIf
	End Function
	
	Function Outside(event:wxEvent)
		Local Button:wxComboHelpBox = wxComboHelpBox(event.parent)
		If Button.TextBox = Null Then
		
		Else
			Button.TextBox.SetValue(Button.OldDescriptionText)
		EndIf
	End Function	
End Type

Type wxColourPickerHelpCtrl Extends wxColourPickerCtrl
	Field DescriptionText:String
	Field OldDescriptionText:String
	Field TextBox:wxTextCtrl

	Method OnInit()
		ConnectAny(wxEVT_ENTER_WINDOW, Inside)
		ConnectAny(wxEVT_LEAVE_WINDOW, Outside)
		Super.OnInit()
	End Method
	
	Method SetFields(Desc:String, OldDesc:String, Box:wxTextCtrl)
		Self.DescriptionText = Desc
		Self.OldDescriptionText = OldDesc
		Self.TextBox = Box
	End Method	
	
	Function Inside(event:wxEvent)
		Local Button:wxColourPickerHelpCtrl = wxColourPickerHelpCtrl(event.parent)
		If Button.TextBox = Null Or Button.DescriptionText = Null Then
		
		Else
			Button.TextBox.SetValue(Button.DescriptionText)
		EndIf
	End Function
	
	Function Outside(event:wxEvent)
		Local Button:wxColourPickerHelpCtrl = wxColourPickerHelpCtrl(event.parent)
		If Button.TextBox = Null then
		
		Else
			Button.TextBox.SetValue(Button.OldDescriptionText)
		EndIf
	End Function	
End Type

Type wxStaticHelpText Extends wxStaticText
	Field DescriptionText:String
	Field OldDescriptionText:String
	Field TextBox:wxTextCtrl

	Method OnInit()
		ConnectAny(wxEVT_ENTER_WINDOW, Inside)
		ConnectAny(wxEVT_LEAVE_WINDOW, Outside)
		Super.OnInit()
	End Method
	
	Method SetFields(Desc:String, OldDesc:String, Box:wxTextCtrl)
		Self.DescriptionText = Desc
		Self.OldDescriptionText = OldDesc
		Self.TextBox = Box
	End Method	
	
	Function Inside(event:wxEvent)
		Local Button:wxStaticHelpText = wxStaticHelpText(event.parent)
		If Button.TextBox = Null Or Button.DescriptionText = Null then
		
		Else
			Button.TextBox.SetValue(Button.DescriptionText)
		EndIf
	End Function
	
	Function Outside(event:wxEvent)
		Local Button:wxStaticHelpText = wxStaticHelpText(event.parent)
		If Button.TextBox = Null Then
		
		Else
			Button.TextBox.SetValue(Button.OldDescriptionText)
		EndIf
	End Function	
End Type


Type wxButtonHelp Extends wxButton
	Field DescriptionText:String
	Field OldDescriptionText:String
	Field TextBox:wxTextCtrl

	Method OnInit()
		ConnectAny(wxEVT_ENTER_WINDOW, Inside)
		ConnectAny(wxEVT_LEAVE_WINDOW, Outside)
		Super.OnInit()
	End Method
	
	Method SetFields(Desc:String, OldDesc:String, Box:wxTextCtrl)
		Self.DescriptionText = Desc
		Self.OldDescriptionText = OldDesc
		Self.TextBox = Box
	End Method	
	
	Function Inside(event:wxEvent)
		Local Button:wxButtonHelp = wxButtonHelp(event.parent)
		If Button.TextBox = Null Or Button.DescriptionText = Null then
		
		Else
			Button.TextBox.SetValue(Button.DescriptionText)
		EndIf
	End Function
	
	Function Outside(event:wxEvent)
		Local Button:wxButtonHelp = wxButtonHelp(event.parent)
		If Button.TextBox = Null then
		
		Else
			Button.TextBox.SetValue(Button.OldDescriptionText)
		EndIf
	End Function	
End Type

Type wxTextHelpCtrl Extends wxTextCtrl
	Field DescriptionText:String
	Field OldDescriptionText:String
	Field TextBox:wxTextCtrl

	Method OnInit()
		ConnectAny(wxEVT_ENTER_WINDOW, Inside)
		ConnectAny(wxEVT_LEAVE_WINDOW, Outside)
		Super.OnInit()
	End Method
	
	Method SetFields(Desc:String, OldDesc:String, Box:wxTextCtrl)
		Self.DescriptionText = Desc
		Self.OldDescriptionText = OldDesc
		Self.TextBox = Box
	End Method	
	
	Function Inside(event:wxEvent)
		Local Button:wxTextHelpCtrl = wxTextHelpCtrl(event.parent)
		If Button.TextBox = Null Or Button.DescriptionText = Null then
		
		Else
			Button.TextBox.SetValue(Button.DescriptionText)
		EndIf
	End Function
	
	Function Outside(event:wxEvent)
		Local Button:wxTextHelpCtrl = wxTextHelpCtrl(event.parent)
		If Button.TextBox = Null then
		
		Else
			Button.TextBox.SetValue(Button.OldDescriptionText)
		EndIf
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

Function GetGameIcon(EXEPath:String , GameName:String)
	Local temp:String , File:String
	DeleteCreateFolder(TEMPFOLDER + "Icons")
	ExtractIcon = CreateProcess(ExtractProgLoc + " /Source " + Chr(34) + StandardiseSlashes(EXEPath) + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons" + FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1")
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
	If temp = "" then

	Else
		CopyFile(TEMPFOLDER + "Icons" + FolderSlash + File , GAMEDATAFOLDER + GameName + FolderSlash + "Icon.ico")
	EndIf		
End Function

Function LoadManagerSettings()
	Local ReadSettings:SettingsType = New SettingsType
	ReadSettings.ParseFile(SETTINGSFOLDER + "Manager.xml" , "Manager")

	If ReadSettings.GetSetting("OnlineAddSource") <> "" then
		OnlineAddSource = ReadSettings.GetSetting("OnlineAddSource")
	EndIf
	If ReadSettings.GetSetting("OnlineAddPlatform") <> "" then
		OnlineAddPlatform = ReadSettings.GetSetting("OnlineAddPlatform")
	EndIf	
	If ReadSettings.GetSetting("Red1") <> "" then
		PMRed = Int(ReadSettings.GetSetting("Red1") )
	EndIf
	If ReadSettings.GetSetting("Green1") <> "" then
		PMGreen = Int(ReadSettings.GetSetting("Green1") )
	EndIf	
	If ReadSettings.GetSetting("Blue1") <> "" then
		PMBlue = Int(ReadSettings.GetSetting("Blue1") )
	EndIf		
	
	If ReadSettings.GetSetting("Red2") <> "" then
		PMRed2 = Int(ReadSettings.GetSetting("Red2") )
	EndIf
	If ReadSettings.GetSetting("Green2") <> "" then
		PMGreen2 = Int(ReadSettings.GetSetting("Green2") )
	EndIf	
	If ReadSettings.GetSetting("Blue2") <> "" then
		PMBlue2 = Int(ReadSettings.GetSetting("Blue2") )
	EndIf		

	If ReadSettings.GetSetting("Maximize") <> "" then
		PMMaximize = Int(ReadSettings.GetSetting("Maximize") )
	EndIf	
	
	If ReadSettings.GetSetting("DefaultGameLua") <> "" then
		PMDefaultGameLua = ReadSettings.GetSetting("DefaultGameLua")
	EndIf		
	
	If ReadSettings.GetSetting("FetchAllArt") <> "" then
		PMFetchAllArt = Int(ReadSettings.GetSetting("FetchAllArt") )
	EndIf			
	
	ReadSettings.CloseFile()
End Function

Function SaveManagerSettings()
	SaveSettings:SettingsType = New SettingsType
	SaveSettings.ParseFile(SETTINGSFOLDER + "Manager.xml" , "Manager")
	
	SaveSettings.SaveSetting("OnlineAddSource" , OnlineAddSource)
	SaveSettings.SaveSetting("OnlineAddPlatform" , OnlineAddPlatform)

	SaveSettings.SaveSetting("Red1" , PMRed)
	SaveSettings.SaveSetting("Green1" , PMGreen)
	SaveSettings.SaveSetting("Blue1" , PMBlue)

	SaveSettings.SaveSetting("Red2" , PMRed2)
	SaveSettings.SaveSetting("Green2" , PMGreen2)
	SaveSettings.SaveSetting("Blue2" , PMBlue2)

	SaveSettings.SaveSetting("Maximize" , PMMaximize)
	
	SaveSettings.SaveSetting("DefaultGameLua" , PMDefaultGameLua)
	SaveSettings.SaveSetting("FetchAllArt" , PMFetchAllArt)
	
	
	SaveSettings.SaveFile()
	SaveSettings.CloseFile()
End Function


Function SaveExplorerSettings()
	SaveSettings:SettingsType = New SettingsType
	SaveSettings.ParseFile(SETTINGSFOLDER + "PhotonExplorer.xml" , "Settings")
	SaveSettings.SaveSetting("Red1" , PERed)
	SaveSettings.SaveSetting("Green1" , PEGreen)
	SaveSettings.SaveSetting("Blue1" , PEBlue)	

	SaveSettings.SaveSetting("Red2" , PERed2)
	SaveSettings.SaveSetting("Green2" , PEGreen2)
	SaveSettings.SaveSetting("Blue2" , PEBlue2)	

	SaveSettings.SaveSetting("Red3" , PERed3)
	SaveSettings.SaveSetting("Green3" , PEGreen3)
	SaveSettings.SaveSetting("Blue3" , PEBlue3)	

	SaveSettings.SaveFile()
	SaveSettings.CloseFile()	
End Function

Function LoadExplorerSettings()
	ReadSettings:SettingsType = New SettingsType
	ReadSettings.ParseFile(SETTINGSFOLDER + "PhotonExplorer.xml" , "Settings")
	
	
	If ReadSettings.GetSetting("Red1") <> "" then
		PERed = Int(ReadSettings.GetSetting("Red1") )
	EndIf
	If ReadSettings.GetSetting("Green1") <> "" then
		PEGreen = Int(ReadSettings.GetSetting("Green1") )
	EndIf	
	If ReadSettings.GetSetting("Blue1") <> "" then
		PEBlue = Int(ReadSettings.GetSetting("Blue1") )
	EndIf		
	If ReadSettings.GetSetting("Red2") <> "" then
		PERed2 = Int(ReadSettings.GetSetting("Red2") )
	EndIf
	If ReadSettings.GetSetting("Green2") <> "" then
		PEGreen2 = Int(ReadSettings.GetSetting("Green2") )
	EndIf	
	If ReadSettings.GetSetting("Blue2") <> "" then
		PEBlue2 = Int(ReadSettings.GetSetting("Blue2") )
	EndIf	
	If ReadSettings.GetSetting("Red3") <> "" then
		PERed3 = Int(ReadSettings.GetSetting("Red3") )
	EndIf
	If ReadSettings.GetSetting("Green3") <> "" then
		PEGreen3 = Int(ReadSettings.GetSetting("Green3") )
	EndIf	
	If ReadSettings.GetSetting("Blue3") <> "" then
		PEBlue3 = Int(ReadSettings.GetSetting("Blue3") )
	EndIf		
	
	ReadSettings.CloseFile()	
End Function

Function LoadGlobalSettings()	
	ReadSettings:SettingsType = New SettingsType
	ReadSettings.ParseFile(SETTINGSFOLDER + "GeneralSettings.xml" , "GeneralSettings")
	If ReadSettings.GetSetting("SteamFolder") <> "" then
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
	If ReadSettings.GetSetting("GraphicsMode") <> "" then	
		GMode = Int(ReadSettings.GetSetting("GraphicsMode") )
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
	If ReadSettings.GetSetting("OriginWaitEnabled") <> "" then	
		OriginWaitEnabled = Int(ReadSettings.GetSetting("OriginWaitEnabled"))
	EndIf 	
	If ReadSettings.GetSetting("GameCache") <> "" then	
		GAMECACHELIMIT = Int(ReadSettings.GetSetting("GameCache"))
	EndIf 	
	If ReadSettings.GetSetting("LowMem") <> "" Then		
		LowMemory = Int(ReadSettings.GetSetting("LowMem"))
	EndIf
	If ReadSettings.GetSetting("LowProc") <> "" then		
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
	If ReadSettings.GetSetting("ShowScreenButton") <> "" then		
		ShowScreenButton = Int(ReadSettings.GetSetting("ShowScreenButton") )
	EndIf			
	If ReadSettings.GetSetting("DebugLogEnabled") <> "" then		
		If Int(ReadSettings.GetSetting("DebugLogEnabled") ) = 1 then
			DebugLogEnabled = 1
		EndIf
	EndIf				
	If ReadSettings.GetSetting("GEAddAllEXEs") <> "" then		
		PM_GE_AddAllEXEs = Int(ReadSettings.GetSetting("GEAddAllEXEs") )
	EndIf
	If ReadSettings.GetSetting("ProcessQueryDelay") <> "" then		
		PRProcessQueryDelay = Int(ReadSettings.GetSetting("ProcessQueryDelay") )
	EndIf	
	If ReadSettings.GetSetting("PluginQueryDelay") <> "" then		
		PRPluginQueryDelay = Int(ReadSettings.GetSetting("PluginQueryDelay") )
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
	SaveSettings.SaveSetting("DebugLogEnabled" , DebugLogEnabled)		
	SaveSettings.SaveSetting("GEAddAllEXEs" , PM_GE_AddAllEXEs)		
	SaveSettings.SaveSetting("ProcessQueryDelay" , PRProcessQueryDelay)		
	SaveSettings.SaveSetting("PluginQueryDelay" , PRPluginQueryDelay)	
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
		
'Replacement function for FreeImage
Function SavePixmapJPeg(Pixmap:TPixmap , SaveLocation:String , SaveQuality:Int = 85)		
	Local FreeImage:TFreeImage = TFreeImage.CreateFromPixmap(Pixmap)
	'FreeImage crashes without conversion to 24bits
	FreeImage = FreeImage.convertTo24Bits()
	FreeImage.save(SaveLocation, FIF_JPEG, SaveQuality)
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
	Local OSMinor:int
	wxGetOsVersion(OSMajor, OSMinor)

	PrintF("Detected Win Version: "+OSMajor+"."+OSMinor)

	If OSMajor => 6 Then
		WinExplorer = True
	Else
		WinExplorer = False
	EndIf
	?Not Win32
		WinExplorer = False
	?
End Function
	
Include "Includes\DatabaseManager\SettingsWindow.bmx"
Include "Includes\DatabaseManager\GameExplorerExtract.bmx"
Include "Includes\DatabaseManager\SteamExtract.bmx"
Include "Includes\DatabaseManager\DatabaseInternetFunctions.bmx"
Include "Includes\General\ValidationFunctions.bmx"
Include "Includes\General\General.bmx"
Include "Includes\DatabaseManager\Games.bmx"
Include "Includes\DatabaseManager\PluginConfigs.bmx"
Include "Includes\DatabaseManager\InputSettings.bmx"
Include "Includes\General\LuaFunctions.bmx"
Include "Includes\DatabaseManager\LuaFunctions.bmx"
Include "Includes\DatabaseManager\DatabaseSearchPanelType.bmx"
Include "Includes\General\Compress.bmx"
Include "Includes\DatabaseManager\StartupChecks.bmx"
Include "Includes\DatabaseManager\DBUpdates.bmx"
Include "Includes\General\SplashApp.bmx"
