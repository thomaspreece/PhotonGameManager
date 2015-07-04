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
		
	Field SW_ShowMenu:wxComboBox
	Field SW_ShowNavigation:wxComboBox
	Field SW_ShowSearch:wxComboBox
	Field SW_ColourPicker1:wxColourPickerCtrl
	Field SW_ColourPicker2:wxColourPickerCtrl
	Field SW_Maximize:wxComboBox
	Field SW_HideHelp:wxComboBox
	Field SW_DefaultGameLua:wxComboBox
	Field SW_DownloadAllArtwork:wxComboBox
	Field SW_DebugLog:wxComboBox
	Field SW_GEAddAllEXEs:wxComboBox
	
	Field SW_ProcessQueryDelay:wxTextCtrl
	Field SW_PluginQueryDelay:wxTextCtrl
	
	Field SW_ColourPickerE1:wxColourPickerCtrl
	Field SW_ColourPickerE2:wxColourPickerCtrl
	Field SW_ColourPickerE3:wxColourPickerCtrl
	
	Field ST30:wxStaticHelpText, ST31:wxStaticHelpText, ST32:wxStaticHelpText, ST33:wxStaticHelpText
	
	Field KeyboardInputField:KeyboardInputWindow
	Field JoyStickInputField:JoyStickInputWindow
	
	Method OnInit()
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		ParentWin = MainWindow(GetParent() )
		
		Local DefaultHelp:String = "Hover over text labels for more information on each item."
		Local E1:String = "Date Format ~nDifferent countries prefer different date formats. UK: DD-MM-YYYY, US: MM-DD-YYYY, EU: YYYY-MM-DD"
		Local E2:String = "Override Default Save Path ~nBy Default Photon will store games, settings and other files in a 'GameManagerV4' folder in My Documents. Use this option to change that location to somewhere else on your computer. Leaving the box blank will remove any overide and tell Photon to use the folder in My Documents. ~n~nRecommended Setting: (Empty text box)"
		Local E3:String = "Enable Debug Log ~nThis turns on outputting of large amounts of debug information to log files. This slows down the application massively and should only be turned on when instructed to do so by Customer Support.~n~nRecommended Setting: No"
		
		Local E51:String = "Artwork Compression Level ~nTwo different settings affects the quality of the Artwork shown in Photon. You may wish to change the quality as  lower quality artwork will make Photon work faster at the expense of it looking worse. The first setting that affects artwork quality is 'Graphics Resolution' (found under the FrontEnd tab), the second is Artwork Compression Level (found under the Artwork tab). It is recommended that you set Graphics Resolution to the same resolution as your desktop and it is recommended to set Artwork Compression Level to the default 85. You will have to click Optimize Artwork for changes in these settings to take effect on already added games. ~nChanging the Graphics Resolution will cause the resolution of the artwork to be changed in a constant ratio to the specified Graphics Resolution. Changing Artwork Compression Level changes the overall quality of the artwork so a low number will be much more pixelated and artifacted than a higher number but a higher number will cause the artwork to take up more hard disk space and cause slower performance.~n~nRecommended Setting: 85"
		
		
		Local E52:String = "Optimize Artwork ~nArtwork is only optimized when first downloaded or after clicking on this button. If you have changed 'Graphics Resolution' (found under the FrontEnd tab) or Artwork Compression Level (found under the Artwork tab), it is highly recommended to click this button to reoptimize all your currently added game's artwork."
		Local E53:String = "Fetch all artwork from online sources~nSetting this option to true will cause Photon to fetch all available artwork from the online source instead of just the artwork Photon requires. The extra artwork may be used in future versions of Photon but has no use at present.~n~nRecommended Setting: No"
		
		Local E101:String = "Steam Path ~nThe Steam import wizard requires the path to your Steam application folder. If you don't use steam you can leave this blank, otherwise it should point to the folder containing steam.exe. On a typical system that would be C:\Program Files (x86)\Steam"
		Local E102:String = "Steam ID ~nEach Steam profile has a unique Steam ID associated with it. Photon requires that ID and also requires that your profile is public for it to be able to detect which games you have. Please note that this ID is NOT the same as your Steam username/gamertag, it is a unique 17 digit number. Click on the button to view more information on how to get your Steam ID."
		
		Local E151:String = "Keyboard Input ~nClick the button to change the default keyboard buttons used in FrontEnd"
		Local E152:String = "Joystick Input ~nClick the button to change the default joystick buttons used in FrontEnd"
		Local E153:String = "Graphics Resolution ~nThis is the resolution FrontEnd will load up at. If you run FrontEnd in full-screen (yes in option below) then you must select a valid resolution that your monitor supports, in other words you MUST select an option from this drop down box. If you run FrontEnd not in full-screen (no in option below) you can type in any resolution you want into this box. This option also affects artwork optimization (see Artwork Compression Level in Artwork tab for more information). ~n~nRecommended Setting: same resolution as your desktop"
		Local E154:String = "Full-Screen ~nRun FrontEnd in Full Screen(Yes Option): taskbar and other applications will not be visible or run FrontEnd in Windowed mode(No Option): taskbar will be visible and FrontEnd will be in a Window allowing you to move it about and put other applications on top or below it.  ~n~nRecommended Setting: Yes"
		Local E155:String = "Anti-Aliasing ~nSetting this higher should reduce jagged edges at the expense of performance.~n~nRecommended Setting: None"
		
		
		Local E156:String = "Low memory mode"
		Local E157:String = "Low processor mode"
		Local E158:String = "game cache (The number of games around the selected game to keep artwork in memory, larger will be smoother but use more memory)"
		
		
		Local E159:String = "Show Touchscreen/JoyStick Keyboard ~nWhen searching games in FrontEnd if this option is Yes an onscreen keyboard will appear that you can use with a touchscreen or a controller/joystick. If you have a keyboard connected you probably won't want this hogging screen space."
		Local E160:String = "Show Touchscreen Info Button ~nShows a round button with an 'i' in it that allows mouse/touchscreens to click it to bring up more information about a game"
		Local E161:String = "Show Touchscreen Screenshot Button ~n~nShows a round button with a camera in it that allows mouse/touchscreens to click it to bring up a screenshot viewing window"
		
		Local E162:String = "Show Menu Button ~n~nShows a button in top left corner which will bring up the menu when clicked on with a mouse or touchscreen."
		Local E163:String = "Show Navigation ~n~nShows the navigation boxes in the top left corner which show you what filters are currently applied. It can also be clicked on for quick navigation or to bring up the filter menu."
		Local E164:String = "Show Search Box ~n~nShows the search box in the top right corner of the screen. It can be clicked on with a mouse or touchscreen to filter results by a keyword. It also shows the current filter keyword."
		
		Local E201:String = "Enable PhotonRunner ~nDisabling PhotonRunner will will stop Photon from running in the background during games and hence disable post batch, unmount, plugins and cabinet mode. We have tried to make PhotonRunner as resource light as possible so you shouldn't see any performance loss by enabling PhotonRunner but this option is left here for those power users. ~n~nRecommended Setting: Yes"
		Local E202:String = "Enable Cabinet Mode ~nEnabling this option will cause PhotonFrontend or PhotonExplorer to load back up after you have finished with your game."
		Local E203:String = "Runner Stays Open ~nSetting this to Yes will cause PhotonRunner to not automatically close when it has finished doing its designated tasks. ~n~nRecommended Setting: No"
		Local E204:String = "Enable Origin 30 Second Wait ~nDetecting when an Origin game is finished can be difficult as Origin always stays open. Setting this option to Yes causes PhotonRunner to wait 30 seconds to allow origin and hence the game to load before PhotonRunner looks to see if game is still running ~n~nRecommended Setting: Yes"
		Local E205:String = "Process Query Delay ~nThis is the time (in milliseconds) between PhotonRunner checking whether your game has closed or not. Setting this lower makes PhotonRunner detect that your game has closed quicker but will increase CPU usage of PhotonRunner. In my testing setting this to the lowest value of 50 does not affect performance of system in any noticable way so changing this setting shouldn't affect your system performance in any way either but the option is left here in case it does."
		Local E206:String = "Plugin Query Delay ~nThis is the time (in milliseconds) between PhotonRunner checking for key presses that are assigned to the plugins such as screenshot and video capture plugins. Setting this lower makes PhotonRunner detect those key presses better. In my testing setting this to the lowest value of 50 does not affect performance of system in any noticable way so changing this setting shouldn't affect your system performance in any way either but the option is left here in case it does."		
		
		Local E251:String = "Colour Picker ~nHere you can change the two colours used on the interface of PhotonManager. Note you will need to restart PhotonManager to see these changes."
		Local E252:String = "Maximize ~nSetting this to Yes will cause most PhotonManager windows to maximize when they become visible. ~n~nRecommended Setting: Yes"
		Local E253:String = "Default Game Search ~nWhen searching online for game information you can use different online sources(websites) but the one selected here will automatically be selected and used first for online searching. ~n~nRecommended Setting: thegamesdb.net (Best site around and a brilliant resource)"
		Local E255:String = "Hide All Help ~nSetting this to Yes will remove most help boxes from PhotonManager's interface."
		
		Local E301:String = "Add Extra EXEs ~nWhen the wizard extracts Game Explorer games it usually extras multiple EXE's and other items such as manuals, website links and alternative programs bundled with each game. You have to select one of these as the main executable for the game but selecting 'Yes' here will mean any other items will be added as extra EXE's allowing you to view/open/run them from PhotonFrontEnd and PhotonExplorer. Selecting 'No' here will cause those extra links to be discarded. ~n~nRecommended Setting: No"
		
		Local E351:String = "Colour Picker ~nHere you can change the three colours used on the interface of PhotonExplorer. Note you will need to restart PhotonExplorer to see these changes."
		
		Local E401:String = "Temporary Files ~nYou can delete these files and it wont affect the running of any of the other Photon programs. Wiping this data will however wipe the already gathered data from the Steam and Explorer Import Wizards so you'll have to wait for Photon to regather this information if you try to use these Wizards again. It will also wipe the extracted Steam Icons, so again wiping this data will mean that you will have to wait for Photon to reextract the icons if you wish to use that feature."
		Local E402:String = "Log Files ~nHarmless data that can be deleted. Only needed to help Customer Support debug problems with an error you may of encountered and under normal circumstances you shouldn't have any data here to delete."
		Local E403:String = "Settings Files ~nDeleting this will delete all saved settings for ALL Photon programs. This includes settings set in this menu, customized platforms and emulators and many other settings that are saved behind the scenes. Deleting these settings will effectly put your Photon application back to when you first installed it, whilst leaving your game database intact."
		Local E404:String = "Games Files ~nDeleting this will remove ALL games from the database. This includes any artwork, patches, manuals, etc that may of been downloaded for that game within the Photon programs. Note: This will NOT affect any of your actual game installations, just the information Photon holds on each game."
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local SettingsNotebook:wxNotebook = New wxNotebook.Create(Self, wxID_ANY)
		SettingsNotebook.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
	
		'------------------------------------------------------------------------------------
		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local P1Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BackButton:wxButton = New wxButton.Create(Panel1 , SW_BB , "Back")
		Local OKButton:wxButton = New wxButton.Create(Panel1, SW_OB , "OK")

		P1Hbox.Add(BackButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.AddStretchSpacer(3)
		P1Hbox.Add(OKButton , 1 , wxEXPAND | wxALL , 10)
		
		Panel1.SetSizer(P1Hbox)

		'------------------------------------------------------------------------------------		
		Local Panel2:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel2.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local P2Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		
		
		Local HelpText:wxTextCtrl = New wxTextCtrl.Create(Panel2, wxID_ANY, DefaultHelp, - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY)
		P2Hbox.Add(HelpText , 1 , wxEXPAND | wxALL , 10)
		HelpText.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		If PMHideHelp = 1 then
			HelpText.Hide()
		EndIf
		Panel2.SetSizer(P2Hbox)

		'--------------------------------GENERAL SETTINGS------------------------------------	
		Local ScrollBox:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		ScrollBox.SetScrollRate(20, 20)
		
		Local ST3:wxStaticText = New wxStaticHelpText.Create(ScrollBox , wxID_ANY , "Date Format: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		wxStaticHelpText(ST3).SetFields( E1, DefaultHelp, HelpText)
		
		SW_DateFormat = New wxComboHelpBox.Create(ScrollBox , SW_DF , "" , ["UK" , "US" , "EU"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )
		wxComboHelpBox(SW_DateFormat).SetFields( E1, DefaultHelp, HelpText)
		
		Local ST13:wxStaticText = New wxStaticHelpText.Create(ScrollBox , wxID_ANY , "Override Default Save Path: (Leave blank to remove override)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)			
		wxStaticHelpText(ST13).SetFields( E2, DefaultHelp, HelpText)
		
		Local OverridePanel:wxPanel = New wxPanel.Create(ScrollBox , - 1)	
		Local OverrideHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)		
		SW_OverridePath = New wxTextHelpCtrl.Create(OverridePanel , SW_OP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		wxTextHelpCtrl(SW_OverridePath).SetFields( E2, DefaultHelp, HelpText)
		
		Local SW_OverrideBrowse:wxButton = New wxButtonHelp.Create(OverridePanel , SW_ODB , "Browse")
		wxButtonHelp(SW_OverrideBrowse).SetFields( E2, DefaultHelp, HelpText)
		OverrideHbox.Add(SW_OverridePath , 10 , wxEXPAND | wxALL , 4)
		OverrideHbox.Add(SW_OverrideBrowse , 2 , wxEXPAND | wxALL , 4)
		OverridePanel.SetSizer(OverrideHbox)	
		
		
		Local ST24:wxStaticText = New wxStaticHelpText.Create(ScrollBox , wxID_ANY , "Debug Log: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		wxStaticHelpText(ST24).SetFields( E3, DefaultHelp, HelpText)
		
		SW_DebugLog = New wxComboHelpBox.Create(ScrollBox , SW_DL , "" , ["Yes" , "No" ] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )
		wxComboHelpBox(SW_DebugLog).SetFields( E3, DefaultHelp, HelpText)
		
		'ScrollBoxvbox.Add(SL1,  0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox.Add(SLT1,  0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox.Add(SL2 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST3 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_DateFormat , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(ST13, 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(OverridePanel , 0 , wxEXPAND | wxALL , 4)					
		ScrollBoxvbox.Add(ST24, 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox.Add(SW_DebugLog , 0 , wxEXPAND | wxALL , 4)	
		
		ScrollBox.SetSizer(ScrollBoxvbox)
		
		'--------------------------------ARTWORK SETTINGS------------------------------------	

		Local ScrollBox2:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		ScrollBox2.SetScrollRate(20, 20)
				
		Local ST2:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox2 , wxID_ANY , "Artwork Compression Level: (100-Best, 1-Worst) " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST2).SetFields( E51, DefaultHelp, HelpText)
		
		Local Optimizehbox1:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SW_CompressLev = New wxTextHelpCtrl.Create(ScrollBox2 , SW_CL , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		wxTextHelpCtrl(SW_CompressLev).SetFields( E51, DefaultHelp, HelpText)
		Local SW_OptimizeArt1:wxButton = New wxButtonHelp.Create(ScrollBox2 , SW_OA1 , "Optimize Artwork")
		wxButtonHelp(SW_OptimizeArt1).SetFields( E52, DefaultHelp, HelpText)
		Optimizehbox1.Add(SW_CompressLev , 1 , wxEXPAND | wxALL , 4)
		Optimizehbox1.Add(SW_OptimizeArt1 , 0 , wxEXPAND | wxALL , 4)
		
		
		Local ST23:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox2 , wxID_ANY , "Download all Artwork: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST23).SetFields( E53, DefaultHelp, HelpText)
		
		SW_DownloadAllArtwork = New wxComboHelpBox.Create(ScrollBox2 , SW_DAA , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		wxComboHelpBox(SW_DownloadAllArtwork).SetFields( E53, DefaultHelp, HelpText)
		
		'ScrollBoxvbox2.Add(SL3, 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox2.Add(SLT2, 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox2.Add(SL4 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox2.Add(ST2 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox2.AddSizer(Optimizehbox1, 0 , wxEXPAND | wxALL , 4)				
		ScrollBoxvbox2.Add(ST23 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox2.Add(SW_DownloadAllArtwork , 0 , wxEXPAND | wxALL , 4)	
		
		ScrollBox2.SetSizer(ScrollBoxvbox2)
		
		
		
		
		
		'--------------------------------STEAM SETTINGS------------------------------------
		
		Local ScrollBox3:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox3:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		ScrollBox3.SetScrollRate(20, 20)		
				
		?win32		
		Local ST1:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox3 , wxID_ANY , "Steam Path: (Folder containing steam.exe)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST1).SetFields( E101, DefaultHelp, HelpText)
		?Not Win32
		Local ST1:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox3 , wxID_ANY , "Steam Path: (Folder containing steam executable, on Ubuntu thats /usr/bin/)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST1).SetFields( E101, DefaultHelp, HelpText)
		?	
		Local SteamPanel:wxPanel = New wxPanel.Create(ScrollBox3 , - 1)	
		Local SteamHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)		
		SW_SteamPath = New wxTextHelpCtrl.Create(SteamPanel , SW_SP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		wxTextHelpCtrl(SW_SteamPath).SetFields( E101, DefaultHelp, HelpText)
		Local SW_SteamBrowse:wxButton = New wxButtonHelp.Create(SteamPanel , SW_SB , "Browse")
		wxButtonHelp(SW_SteamBrowse).SetFields( E101, DefaultHelp, HelpText)
		
		SteamHbox.Add(SW_SteamPath , 10 , wxEXPAND | wxALL , 4)
		SteamHbox.Add(SW_SteamBrowse , 2 , wxEXPAND | wxALL , 4)
		SteamPanel.SetSizer(SteamHbox)		

		Local ST11:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox3 , wxID_ANY , "SteamID: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST11).SetFields( E102, DefaultHelp, HelpText)
		SW_SteamID = New wxTextHelpCtrl.Create(ScrollBox3 , SW_SID , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		wxTextHelpCtrl(SW_SteamID).SetFields( E102, DefaultHelp, HelpText)
		Local SW_SteamIDGuide:wxButton = New wxButtonHelp.Create(ScrollBox3 , SW_SIDG , "How to find SteamID Guide")
		wxButtonHelp(SW_SteamIDGuide).SetFields( E102, DefaultHelp, HelpText)


		'ScrollBoxvbox.Add(SL10, 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox.Add(SLT5, 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox.Add(SL11 , 0 , wxEXPAND | wxALL , 4)	
				
		ScrollBoxvbox3.Add(ST1, 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox3.Add(SteamPanel , 0 , wxEXPAND | wxALL , 4)
		
		ScrollBoxvbox3.Add(ST11, 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox3.Add(SW_SteamID , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox3.Add(SW_SteamIDGuide , 0 , wxEXPAND | wxALL , 4)
	

		ScrollBox3.SetSizer(ScrollBoxvbox3)

		'--------------------------------FRONTEND SETTINGS------------------------------------


		Local ScrollBox4:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox4:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		ScrollBox4.SetScrollRate(20, 20)


		Local FrontEndControlsHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local KeyboardInput:wxButton = New wxButtonHelp.Create(ScrollBox4 , SW_KI , "Keyboard Input")
		wxButtonHelp(KeyboardInput).SetFields( E151, DefaultHelp, HelpText)
		Local JoystickInput:wxButton = New wxButtonHelp.Create(ScrollBox4, SW_JI , "Joystick Input")
		wxButtonHelp(JoystickInput).SetFields( E152, DefaultHelp, HelpText)

		FrontEndControlsHbox.Add(KeyboardInput , 1 , wxEXPAND | wxALL , 10)
		FrontEndControlsHbox.Add(JoystickInput , 1 , wxEXPAND | wxALL , 10)

			
		Local ST4:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Graphics Resolution: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST4).SetFields( E153, DefaultHelp, HelpText)
		Local Optimizehbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SW_Resolution = New wxComboHelpBox.Create(ScrollBox4 , SW_R , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN )
		wxComboHelpBox(SW_Resolution).SetFields( E153, DefaultHelp, HelpText)	
		Local SW_OptimizeArt2:wxButton = New wxButtonHelp.Create(ScrollBox4 , SW_OA2 , "Optimize Artwork")
		wxButtonHelp(SW_OptimizeArt2).SetFields( E52, DefaultHelp, HelpText)
		Optimizehbox2.Add(SW_Resolution , 1 , wxEXPAND | wxALL , 4)
		Optimizehbox2.Add(SW_OptimizeArt2 , 0 , wxEXPAND | wxALL , 4)
		
		Local ST6:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "FullScreen: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST6).SetFields( E154, DefaultHelp, HelpText)
		SW_Mode = New wxComboHelpBox.Create(ScrollBox4 , SW_M , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
		wxComboHelpBox(SW_Mode).SetFields( E154, DefaultHelp, HelpText)
		
		Local ST16:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Anti-Aliasing: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST16).SetFields( E155, DefaultHelp, HelpText)
		SW_AntiAlias = New wxComboHelpBox.Create(ScrollBox4 , SW_AA , "" , ["None", "2X", "4X", "8X", "16X"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
		wxComboHelpBox(SW_AntiAlias).SetFields( E155, DefaultHelp, HelpText)
		
		Local ST7:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Low Memory Mode: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST7).SetFields( E156, DefaultHelp, HelpText)
		
		SW_LowMem = New wxComboHelpBox.Create(ScrollBox4 , SW_LM , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )
		wxComboHelpBox(SW_LowMem).SetFields( E156, DefaultHelp, HelpText)
		Local ST9:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Low Processor Mode: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST9).SetFields( E157, DefaultHelp, HelpText)
		
		SW_LowProc = New wxComboHelpBox.Create(ScrollBox4 , SW_LP , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
		wxComboHelpBox(SW_LowProc).SetFields( E157, DefaultHelp, HelpText)			
		Local ST8:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Game Cache Number: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST8).SetFields( E158, DefaultHelp, HelpText)
		
		SW_GameCache = New wxTextHelpCtrl.Create(ScrollBox4 , SW_GC , String(GAMECACHELIMIT) , - 1 , - 1 , - 1 , - 1 , 0 )
		wxTextHelpCtrl(SW_GameCache).SetFields( E158, DefaultHelp, HelpText)
		
		Local ST10:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Show TouchScreen/JoyStick Keyboard: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST10).SetFields( E159, DefaultHelp, HelpText)
		
		SW_TouchKey = New wxComboHelpBox.Create(ScrollBox4 , SW_TK , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		wxComboHelpBox(SW_TouchKey).SetFields( E159, DefaultHelp, HelpText)
		
		Local ST17:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Show Touchscreen Info Button: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST17).SetFields( E160, DefaultHelp, HelpText)
		
		SW_ShowTouchInfo = New wxComboHelpBox.Create(ScrollBox4 , SW_STI , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		wxComboHelpBox(SW_ShowTouchInfo).SetFields( E160, DefaultHelp, HelpText)
		
		Local ST18:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Show Touchscreen ScreenShot Button: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST18).SetFields( E161, DefaultHelp, HelpText)
		
		SW_ShowTouchScreen = New wxComboHelpBox.Create(ScrollBox4 , SW_STS , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		wxComboHelpBox(SW_ShowTouchScreen).SetFields( E161, DefaultHelp, HelpText)
		
		Local ST37:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Show Menu Button: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST37).SetFields( E162, DefaultHelp, HelpText)
		
		SW_ShowMenu = New wxComboHelpBox.Create(ScrollBox4 , wxID_ANY , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		wxComboHelpBox(SW_ShowMenu).SetFields( E162, DefaultHelp, HelpText)		
		
		Local ST38:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Show Navigation: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST38).SetFields( E163, DefaultHelp, HelpText)
		
		SW_ShowNavigation = New wxComboHelpBox.Create(ScrollBox4 , wxID_ANY , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		wxComboHelpBox(SW_ShowNavigation).SetFields( E163, DefaultHelp, HelpText)	

		Local ST39:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox4 , wxID_ANY , "Show Search Box: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST39).SetFields( E164, DefaultHelp, HelpText)
		
		SW_ShowSearch = New wxComboHelpBox.Create(ScrollBox4 , wxID_ANY , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )		
		wxComboHelpBox(SW_ShowNavigation).SetFields( E164, DefaultHelp, HelpText)			
		
	
		'ScrollBoxvbox.Add(SL5, 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox.Add(SLT3,  0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox.Add(SL6 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.AddSizer(FrontEndControlsHbox, 0 , wxEXPAND | wxALL , 4)
		
		ScrollBoxvbox4.Add(ST4 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.AddSizer(Optimizehbox2 , 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox.Add(SW_Resolution , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox4.Add(ST6 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_Mode , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(ST16 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_AntiAlias , 0 , wxEXPAND | wxALL , 4)		
		
		
		ScrollBoxvbox4.Add(ST7 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_LowMem , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(ST9 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_LowProc , 0 , wxEXPAND | wxALL , 4)					
		ScrollBoxvbox4.Add(ST8 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_GameCache , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(ST10 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_TouchKey , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox4.Add(ST17 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_ShowTouchInfo , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox4.Add(ST18 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_ShowTouchScreen , 0 , wxEXPAND | wxALL , 4)	

		ScrollBoxvbox4.Add(ST37 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_ShowMenu , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(ST38 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_ShowNavigation , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(ST39 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox4.Add(SW_ShowSearch , 0 , wxEXPAND | wxALL , 4)

		ScrollBox4.SetSizer(ScrollBoxvbox4)
		
		'--------------------------------RUNNER SETTINGS------------------------------------
		
		
		Local ScrollBox5:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox5:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		ScrollBox5.SetScrollRate(20, 20)

		Local ST5:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox5 , wxID_ANY , "Enable PhotonRunner: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST5).SetFields( E201, DefaultHelp, HelpText)
		
		SW_Runner = New wxComboHelpBox.Create(ScrollBox5 , SW_R , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
		wxComboHelpBox(SW_Runner).SetFields( E201, DefaultHelp, HelpText)
		
		Local ST12:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox5 , wxID_ANY , "Enable Cabinet Mode: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST12).SetFields( E202, DefaultHelp, HelpText)
		
		SW_Cabinate = New wxComboHelpBox.Create(ScrollBox5 , SW_C , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )						
		wxComboHelpBox(SW_Cabinate).SetFields( E202, DefaultHelp, HelpText)
		
		Local ST15:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox5 , wxID_ANY , "Photon Runner only closes when you click close button (All Games)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST15).SetFields( E203, DefaultHelp, HelpText)
		
		SW_ButtonCloseOnly = New wxComboHelpBox.Create(ScrollBox5 , SW_BCO , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )
		wxComboHelpBox(SW_ButtonCloseOnly).SetFields( E203, DefaultHelp, HelpText)
	
		Local ST14:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox5 , wxID_ANY , "Enable Origin 30 second wait: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST14).SetFields( E204, DefaultHelp, HelpText)
		
		SW_OriginWait = New wxComboHelpBox.Create(ScrollBox5 , SW_OW , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		wxComboHelpBox(SW_OriginWait).SetFields( E204, DefaultHelp, HelpText)
		
		ST14.Hide()
		SW_OriginWait.Hide()
		
		Local ST34:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox5 , wxID_ANY , "Runner Process Query Delay: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST34).SetFields( E205, DefaultHelp, HelpText)		
		
		SW_ProcessQueryDelay = New wxTextHelpCtrl.Create(ScrollBox5 , SW_PQD , PRProcessQueryDelay , - 1 , - 1 , - 1 , - 1 , 0 )
		wxTextHelpCtrl(SW_ProcessQueryDelay).SetFields( E205, DefaultHelp, HelpText)
		
		Local ST35:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox5 , wxID_ANY , "Runner Plugin Query Delay: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST35).SetFields( E206, DefaultHelp, HelpText)		
		
		SW_PluginQueryDelay = New wxTextHelpCtrl.Create(ScrollBox5 , wxID_ANY , PRPluginQueryDelay , - 1 , - 1 , - 1 , - 1 , 0 )
		wxTextHelpCtrl(SW_PluginQueryDelay).SetFields( E206, DefaultHelp, HelpText)		
		
		'ScrollBoxvbox5.Add(SL7, 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox5.Add(SLT4, 0 , wxEXPAND | wxALL , 4)
		'ScrollBoxvbox5.Add(SL8 , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox5.Add(ST5 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox5.Add(SW_Runner , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox5.Add(ST12 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox5.Add(SW_Cabinate , 0 , wxEXPAND | wxALL , 4)		
		
		ScrollBoxvbox5.Add(ST15 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox5.Add(SW_ButtonCloseOnly , 0 , wxEXPAND | wxALL , 4)	
		
		ScrollBoxvbox5.Add(ST14 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox5.Add(SW_OriginWait , 0 , wxEXPAND | wxALL , 4)			
		
		ScrollBoxvbox5.Add(ST34 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox5.Add(SW_ProcessQueryDelay , 0 , wxEXPAND | wxALL , 4)	
		ScrollBoxvbox5.Add(ST35 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox5.Add(SW_PluginQueryDelay , 0 , wxEXPAND | wxALL , 4)							
		
		ScrollBox5.SetSizer(ScrollBoxvbox5)
		
		
		
		'-----------------------------MANAGER---------------------------------------
		Local ScrollBox6:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox6:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		ScrollBox6.SetScrollRate(20, 20)
		
		
		Local ST19:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox6 , wxID_ANY , "Primary Colour: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST19).SetFields( E251, DefaultHelp, HelpText)
		
		Local ST20:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox6 , wxID_ANY , "Secondary Colour: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST20).SetFields( E251, DefaultHelp, HelpText)
		
		SW_ColourPicker1 = New wxColourPickerHelpCtrl.Create(ScrollBox6, wxID_ANY, New wxColour.Create(PMRed, PMGreen, PMBlue) )
		SW_ColourPicker2 = New wxColourPickerHelpCtrl.Create(ScrollBox6, wxID_ANY, New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		
		wxColourPickerHelpCtrl(SW_ColourPicker1).SetFields( E251, DefaultHelp, HelpText)
		wxColourPickerHelpCtrl(SW_ColourPicker2).SetFields( E251, DefaultHelp, HelpText)
		
		
		
		Local ST21:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox6 , wxID_ANY , "Maximize Windows: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST21).SetFields( E252, DefaultHelp, HelpText)
		
		SW_Maximize = New wxComboHelpBox.Create(ScrollBox6 , SW_MZ , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		wxComboHelpBox(SW_Maximize).SetFields( E252, DefaultHelp, HelpText)
		
		Local ST22:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox6 , wxID_ANY , "Default Game Database: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST22).SetFields( E253, DefaultHelp, HelpText)
		
		SW_DefaultGameLua = New wxComboHelpBox.Create(ScrollBox6 , SW_DGL , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		wxComboHelpBox(SW_DefaultGameLua).SetFields( E253, DefaultHelp, HelpText)

		Local ST36:wxStaticHelpText = wxStaticHelpText( New wxStaticHelpText.Create(ScrollBox6 , wxID_ANY , "Hide All Help Boxes: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT) )
		wxStaticHelpText(ST36).SetFields( E255, DefaultHelp, HelpText)

		SW_HideHelp = New wxComboHelpBox.Create(ScrollBox6 , wxID_ANY , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		wxComboHelpBox(SW_HideHelp).SetFields( E255, DefaultHelp, HelpText)
		
		
		
		Local DefaultGameLuaTList:TList = GetLuaList(1)
		Local DefaultGameLuaTListItem:String
		For DefaultGameLuaTListItem = EachIn DefaultGameLuaTList
			SW_DefaultGameLua.Append(DefaultGameLuaTListItem)
		Next
		SW_DefaultGameLua.SetValue(PMDefaultGameLua)
		
		ScrollBoxvbox6.Add(ST21 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox6.Add(SW_Maximize , 0 , wxEXPAND | wxALL , 4)		
		ScrollBoxvbox6.Add(ST22 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox6.Add(SW_DefaultGameLua , 0 , wxEXPAND | wxALL , 4)				
		ScrollBoxvbox6.Add(ST19 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox6.Add(SW_ColourPicker1 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox6.Add(ST20 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox6.Add(SW_ColourPicker2 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox6.Add(ST36 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox6.Add(SW_HideHelp , 0 , wxEXPAND | wxALL , 4)
		
		ScrollBox6.SetSizer(ScrollBoxvbox6)
		
		'-----------------------------Game Explorer---------------------------------------
		Local ScrollBox7:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox7:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		ScrollBox7.SetScrollRate(20, 20)		
		
		
		Local ST25:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox7 , wxID_ANY , "Add Extra EXE's: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST25).SetFields( E301, DefaultHelp, HelpText)
		
		SW_GEAddAllEXEs = New wxComboHelpBox.Create(ScrollBox7 , SW_R , "" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
		wxComboHelpBox(SW_GEAddAllEXEs).SetFields( E301, DefaultHelp, HelpText)
		
		
		ScrollBoxvbox7.Add(ST25 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox7.Add(SW_GEAddAllEXEs , 0 , wxEXPAND | wxALL , 4)		
		
		ScrollBox7.SetSizer(ScrollBoxvbox7)		
		
		'-----------------------------Explorer---------------------------------------
		Local ScrollBox8:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox8:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		ScrollBox8.SetScrollRate(20, 20)		
		
	
		Local ST26:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox8 , wxID_ANY , "Primary Colour: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST26).SetFields( E351, DefaultHelp, HelpText)
		
		Local ST27:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox8 , wxID_ANY , "Secondary Colour: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST27).SetFields( E351, DefaultHelp, HelpText)
		
		Local ST29:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox8 , wxID_ANY , "Tertiary Colour: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST29).SetFields( E351, DefaultHelp, HelpText)
		
		SW_ColourPickerE1 = New wxColourPickerHelpCtrl.Create(ScrollBox8, wxID_ANY, New wxColour.Create(PERed, PEGreen, PEBlue) )
		SW_ColourPickerE2 = New wxColourPickerHelpCtrl.Create(ScrollBox8, wxID_ANY, New wxColour.Create(PERed2, PEGreen2, PEBlue2) )
		SW_ColourPickerE3 = New wxColourPickerHelpCtrl.Create(ScrollBox8, wxID_ANY, New wxColour.Create(PERed3, PEGreen3, PEBlue3) )
		
		wxColourPickerHelpCtrl(SW_ColourPickerE1).SetFields( E351, DefaultHelp, HelpText)
		wxColourPickerHelpCtrl(SW_ColourPickerE2).SetFields( E351, DefaultHelp, HelpText)
		wxColourPickerHelpCtrl(SW_ColourPickerE3).SetFields( E351, DefaultHelp, HelpText)
		
		Local ST28:wxStaticText = New wxStaticText.Create(ScrollBox8 , wxID_ANY , "All other settings for PhotonExplorer can be found within the main menu of PhotonExplorer. " , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTER)	
		
		ScrollBoxvbox8.Add(ST26 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox8.Add(SW_ColourPickerE1 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox8.Add(ST27 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox8.Add(SW_ColourPickerE2 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox8.Add(ST29 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox8.Add(SW_ColourPickerE3 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox8.AddSpacer(30)
		ScrollBoxvbox8.Add(ST28 , 0 , wxEXPAND | wxALL , 4)
			
		ScrollBox8.SetSizer(ScrollBoxvbox8)		
		
		
		'-----------------------------Dangerous Tab---------------------------------------
		Local ScrollBox9:wxScrolledWindow = New wxScrolledWindow.Create(SettingsNotebook , wxID_ANY , - 1, - 1, - 1 , - 1 , wxHSCROLL)
		Local ScrollBoxvbox9:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)				
		ScrollBox9.SetScrollRate(20, 20)		
		
		ST30:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox9 , wxID_ANY , "Temporary Files (" + FolderSizeStringString(TEMPFOLDER) + "):" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST30).SetFields( E401, DefaultHelp, HelpText)
		Local TempFilesButton:wxButton = New wxButtonHelp.Create(ScrollBox9, SW_TFB , "Delete")
		wxButtonHelp(TempFilesButton).SetFields( E401, DefaultHelp, HelpText)

		ST31:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox9 , wxID_ANY , "Log Files (" + FolderSizeStringString(LOGFOLDER) + "):" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST31).SetFields( E402, DefaultHelp, HelpText)
		Local LogFilesButton:wxButton = New wxButtonHelp.Create(ScrollBox9, SW_LFB , "Delete")
		wxButtonHelp(LogFilesButton).SetFields( E402, DefaultHelp, HelpText)

		ST32:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox9 , wxID_ANY , "Settings Files (" + FolderSizeStringString(SETTINGSFOLDER) + "):" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST32).SetFields( E403, DefaultHelp, HelpText)
		Local SettingsFilesButton:wxButton = New wxButtonHelp.Create(ScrollBox9, SW_SFB , "Delete")
		wxButtonHelp(SettingsFilesButton).SetFields( E403, DefaultHelp, HelpText)
		
		ST33:wxStaticHelpText = wxStaticHelpText(New wxStaticHelpText.Create(ScrollBox9 , wxID_ANY , "Games Files (" + FolderSizeStringString(GAMEDATAFOLDER) + "):" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	)
		wxStaticHelpText(ST33).SetFields( E404, DefaultHelp, HelpText)
		Local GamesFilesButton:wxButton = New wxButtonHelp.Create(ScrollBox9, SW_GFB , "Delete")
		wxButtonHelp(GamesFilesButton).SetFields( E404, DefaultHelp, HelpText)
		
		ScrollBoxvbox9.Add(ST30 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox9.Add(TempFilesButton , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox9.Add(ST31 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox9.Add(LogFilesButton , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox9.Add(ST32 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox9.Add(SettingsFilesButton , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox9.Add(ST33 , 0 , wxEXPAND | wxALL , 4)
		ScrollBoxvbox9.Add(GamesFilesButton , 0 , wxEXPAND | wxALL , 4)
		
		
		ScrollBox9.SetSizer(ScrollBoxvbox9)	
		'--------------------------------------------------------------------
		
		
		ScrollBox.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ScrollBox2.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ScrollBox3.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ScrollBox4.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ScrollBox5.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ScrollBox6.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ScrollBox7.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ScrollBox8.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ScrollBox9.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		
		ScrollBox.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		ScrollBox2.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		ScrollBox3.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		ScrollBox4.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		ScrollBox5.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		ScrollBox6.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		ScrollBox7.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		ScrollBox8.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		ScrollBox9.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		
		SettingsNotebook.AddPage(ScrollBox, "General", 1)
		SettingsNotebook.AddPage(ScrollBox2, "Artwork", 0)
		SettingsNotebook.AddPage(ScrollBox3, "Steam Import", 0)
		SettingsNotebook.AddPage(ScrollBox7, "Game Explorer Import", 0)
		SettingsNotebook.AddPage(ScrollBox4, "FrontEnd", 0)
		SettingsNotebook.AddPage(ScrollBox6, "Manager", 0)
		SettingsNotebook.AddPage(ScrollBox8, "Explorer", 0)
		SettingsNotebook.AddPage(ScrollBox5, "Runner", 0)
		SettingsNotebook.AddPage(ScrollBox9, "Dangerous Settings", 0)
		
		
		'--------------------------------------------------------------------
		
		
				
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
		
		SW_Resolution.SetValue(GraphicsW + "x" + GraphicsH)
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
		
		If LowMemory = True then
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
		
		If ShowInfoButton = 1 then
			SW_ShowTouchInfo.SetValue("Yes")
		Else
			SW_ShowTouchInfo.SetValue("No")
		EndIf 			
		
		If ShowMenu = 1 then
			SW_ShowMenu.SetValue("Yes")
		Else
			SW_ShowMenu.SetValue("No")
		EndIf

		If ShowNavigation = 1 then
			SW_ShowNavigation.SetValue("Yes")
		Else
			SW_ShowNavigation.SetValue("No")
		EndIf

		If ShowSearchBox = 1 then
			SW_ShowSearch.SetValue("Yes")
		Else
			SW_ShowSearch.SetValue("No")
		EndIf		
				
		If RunnerButtonCloseOnly = 1 Then 
			SW_ButtonCloseOnly.SetValue("Yes")
		Else
			SW_ButtonCloseOnly.SetValue("No")
		EndIf 
		
		If OriginWaitEnabled = 1 then
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
			
								
		If PMMaximize = 1 then
			SW_Maximize.SetValue("Yes")
		Else
			SW_Maximize.SetValue("No")
		EndIf
		
		If PMHideHelp = 1 then
			SW_HideHelp.SetValue("Yes")
		Else
			SW_HideHelp.SetValue("No")
		EndIf
		
		If PMFetchAllArt = 1 then
			SW_DownloadAllArtwork.SetValue("Yes")
		Else
			SW_DownloadAllArtwork.SetValue("No")
		EndIf
		
		If DebugLogEnabled then
			SW_DebugLog.SetValue("Yes")
		Else
			SW_DebugLog.SetValue("No")
		EndIf
		
		
		If PM_GE_AddAllEXEs then
			SW_GEAddAllEXEs.SetValue("Yes")
		Else
			SW_GEAddAllEXEs.SetValue("No")
		EndIf
		'--------------------------------------------------------------------
		
		
		
		vbox.Add(Panel2, 0 , wxEXPAND , 0)		
		vbox.Add(SettingsNotebook, 8, wxEXPAND, 0)
		vbox.Add(Panel1, 0 , wxEXPAND , 0)		
		SetSizer(vbox)
		If PMMaximize = 1 then
			Self.Maximize(1)
		EndIf
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
		
		Connect(SW_TFB, wxEVT_COMMAND_BUTTON_CLICKED, DeleteTempFiles)
		Connect(SW_LFB, wxEVT_COMMAND_BUTTON_CLICKED, DeleteLogFiles)
		Connect(SW_SFB, wxEVT_COMMAND_BUTTON_CLICKED, DeleteSettingsFiles)
		Connect(SW_GFB, wxEVT_COMMAND_BUTTON_CLICKED, DeleteGamesFiles)		
	End Method

	Function DeleteTempFiles(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "Are you sure you wish to delete Temporary files?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			DeleteCreateFolder(TEMPFOLDER)
			MessageBox.Free()
			MessageBox = New wxMessageDialog.Create(Null , "Temporary files deleted" , "Success" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			SettingsWin.ST30.SetLabel("Temporary Files (" + FolderSizeStringString(TEMPFOLDER) + "):")
		Else
			MessageBox.Free()
		EndIf
	End Function
	
	Function DeleteLogFiles(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "Are you sure you wish to delete Log files?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			DeleteCreateFolder(LOGFOLDER)
			MessageBox.Free()
			MessageBox = New wxMessageDialog.Create(Null , "Log files deleted" , "Success" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			SettingsWin.ST31.SetLabel("Log Files (" + FolderSizeStringString(LOGFOLDER) + "):")
		Else
			MessageBox.Free()
		EndIf	
	End Function

	Function DeleteSettingsFiles(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "Are you sure you wish to delete all settings files?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			DeleteCreateFolder(SETTINGSFOLDER)
			MessageBox.Free()
			MessageBox = New wxMessageDialog.Create(Null , "Settings files deleted" , "Success" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			SettingsWin.ST32.SetLabel("Settings Files (" + FolderSizeStringString(SETTINGSFOLDER) + "):")
		Else
			MessageBox.Free()
		EndIf	
	End Function	

	Function DeleteGamesFiles(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "Are you sure you wish to delete games files?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			DeleteCreateFolder(GAMEDATAFOLDER)
			MessageBox.Free()
			MessageBox = New wxMessageDialog.Create(Null , "Games files deleted" , "Success" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			SettingsWin.ST33.SetLabel("Games Files (" + FolderSizeStringString(GAMEDATAFOLDER) + "):")
		Else
			MessageBox.Free()
		EndIf	
	End Function

	Function KeyboardWinFun(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		PrintF("----------------------------Show Keyboard----------------------------")
		SettingsWin.KeyboardInputField = KeyboardInputWindow(New KeyboardInputWindow.Create(SettingsWin, wxID_ANY, "FrontEnd Keyboard Input", , , 800, 600) )	
		SettingsWin.KeyboardInputField.Show(True)
		SettingsWin.Hide()
		SettingsWin.KeyboardInputField.Raise()
	End Function

	Function JoyStickWinFun(event:wxEvent)
		Local SettingsWin:SettingsWindow = SettingsWindow(event.parent)
		PrintF("----------------------------Show Keyboard----------------------------")
		SettingsWin.JoyStickInputField = JoyStickInputWindow(New JoyStickInputWindow.Create(SettingsWin, wxID_ANY, "FrontEnd JoyStick Input", , , 800, 600) )	
		SettingsWin.JoyStickInputField.Show(True)
		SettingsWin.Hide()
		SettingsWin.JoyStickInputField.Raise()
	End Function

	Function BrowseOverrideFun(event:wxEvent)
		Local MainWin:MainWindow = SettingsWindow(event.parent).ParentWin
		?Not Win32
		Local openFileDialog:wxDirDialog = New wxDirDialog.Create(MainWin.SettingsWindowField, "Select folder" ,MainWin.SettingsWindowField.SW_OverridePath.GetValue() , wxDD_DIR_MUST_EXIST)	
		If openFileDialog.ShowModal() = wxID_OK then
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
		If FileType(SW_SteamPath.GetValue() + FolderSlash + "Steam.exe") = 0 then
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
			If item = "" then Exit
			If item="." Or item=".." Then Continue
			GameNode:GameType = New GameType
			If GameNode.GetGame(item) = - 1 then
			
			Else
				Log1.AddText("Optimizing Artwork for: "+GameNode.Name)
				GameNode.OptimizeArtwork()			
			EndIf
			If Log1.LogClosed = True then Exit
		Forever
		CloseDir(GameDir)
		Self.Show(1)
		Log1.Show(0)		 	
	End Method 	

	Method SaveSettings()
		Local OptimizeArt = False
		Local MessageBox:wxMessageDialog
		If ValidateInput()=False Then Return False
		SteamFolder = SW_SteamPath.GetValue()
		SteamID = SW_SteamID.GetValue()
		ArtworkCompression = Int(SW_CompressLev.GetValue() )
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
				
		If SW_ShowMenu.GetValue() = "Yes" then
			ShowMenu = 1
		Else
			ShowMenu = 0
		EndIf
		
		If SW_ShowNavigation.GetValue() = "Yes" then
			ShowNavigation = 1
		Else
			ShowNavigation = 0
		EndIf

		If SW_ShowSearch.GetValue() = "Yes" then
			ShowSearchBox = 1
		Else
			ShowSearchBox = 0
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
		
		If SW_Maximize.GetValue() = "Yes"
			PMMaximize = 1
		Else
			PMMaximize = 0
		EndIf 	
			
		If SW_HideHelp.GetValue() = "Yes"
			If PMHideHelp <> 1 then
				MessageBox = New wxMessageDialog.Create(Null , "Not all help boxes will be hiden until PhotonManager is restarted" , "Info" , wxOK | wxICON_INFORMATION)
				MessageBox.ShowModal()
				MessageBox.Free()				
			EndIf
			PMHideHelp = 1
		Else
			If PMHideHelp <> 0 then
				MessageBox = New wxMessageDialog.Create(Null , "Not all help boxes will be shown until PhotonManager is restarted" , "Info" , wxOK | wxICON_INFORMATION)
				MessageBox.ShowModal()
				MessageBox.Free()				
			EndIf		
			PMHideHelp = 0
		EndIf
		
		If SW_DownloadAllArtwork.GetValue() = "Yes" then
			PMFetchAllArt = 1
		Else
			PMFetchAllArt = 0
		EndIf
		
		If SW_DebugLog.GetValue() = "Yes" then
			DebugLogEnabled = 1
		Else
			DebugLogEnabled = 0
		EndIf
		
		If SW_GEAddAllEXEs.GetValue() = "Yes" then
			PM_GE_AddAllEXEs = 1
		Else
			PM_GE_AddAllEXEs = 0
		EndIf
		
		PMDefaultGameLua = SW_DefaultGameLua.GetValue()
		
		
		
		PRPluginQueryDelay = Int(SW_PluginQueryDelay.GetValue() )
		If PRPluginQueryDelay < 10 then
			PRPluginQueryDelay = 10
		EndIf
		PRProcessQueryDelay = Int(SW_ProcessQueryDelay.GetValue() )
		If PRProcessQueryDelay < 10 then
			PRProcessQueryDelay = 10
		EndIf
		
		PMRed = SW_ColourPicker1.GetColour().Red()
		PMGreen = SW_ColourPicker1.GetColour().Green()
		PMBlue = SW_ColourPicker1.GetColour().Blue()		
		
		PMRed2 = SW_ColourPicker2.GetColour().Red()
		PMGreen2 = SW_ColourPicker2.GetColour().Green()
		PMBlue2 = SW_ColourPicker2.GetColour().Blue()
		
		PERed = SW_ColourPickerE1.GetColour().Red()
		PEGreen = SW_ColourPickerE1.GetColour().Green()
		PEBlue = SW_ColourPickerE1.GetColour().Blue()
		
		PERed2 = SW_ColourPickerE2.GetColour().Red()
		PEGreen2 = SW_ColourPickerE2.GetColour().Green()
		PEBlue2 = SW_ColourPickerE2.GetColour().Blue()
		
		PERed3 = SW_ColourPickerE3.GetColour().Red()
		PEGreen3 = SW_ColourPickerE3.GetColour().Green()
		PEBlue3 = SW_ColourPickerE3.GetColour().Blue()
		
		Local TempFolderPath:String
		If FileType("SaveLocationOverride.txt") = 1 then
			ReadLocationOverride = ReadFile("SaveLocationOverride.txt")
			TempFolderPath = ReadLine(ReadLocationOverride)
			CloseFile(ReadLocationOverride)	
		Else
			TempFolderPath = ""
		EndIf
		
		If SW_OverridePath.GetValue() = "" then
			DeleteFile("SaveLocationOverride.txt")
		Else
			DeleteFile("SaveLocationOverride.txt")
			tempwrite = WriteFile("SaveLocationOverride.txt")
			WriteLine(tempwrite, SW_OverridePath.GetValue() )
			CloseFile(tempwrite)
		EndIf
		
		SaveGlobalSettings()
		SaveManagerSettings()
		SaveExplorerSettings()

		If SW_OverridePath.GetValue() = TempFolderPath then
		
		Else
			PrintF("Old SaveFolder:" + TempFolderPath)
			PrintF("New SaveFolder:" + SW_OverridePath.GetValue() )
			
			MessageBox = New wxMessageDialog.Create(Null , "Change of default save path requires restart of Photon Manager to take effect" , "Info" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
		EndIf
		
		If OptimizeArt = True then
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