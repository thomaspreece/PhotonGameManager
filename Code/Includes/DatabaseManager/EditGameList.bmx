
Type EditGameList Extends wxFrame
	Field Mounter:MounterReadType = New MounterReadType
	Field BackButton:wxButton
	Field FilterTextBox:wxTextCtrl
	Field SortCombo:wxComboBox
	Field PlatformCombo:wxComboBox
	Field GameList:wxListCtrl
	Rem
	?MacOS
	Field GameNotebook:wxChoicebook
	Field ExecutableNotebook:wxChoicebook 
	?Not MacOS
	EndRem
	Field ExecutableNotebook:wxNotebook
	Field GameNotebook:wxNotebook
	'?
	
	
	Field AddButton:wxButton
	Field DelButton:wxButton
	Field CancelButton:wxButton
	Field SaveButton:wxButton
	Field OtherButton:wxButton
	Field OptimizeButton:wxButton
	Field ParentWin:MainWindow
	Field GamesTList:TList
	Field Selection:Int
	
	Field DataChanged:Int
	Field DataTimeout:Int
	
	Field SubGamePanel2:wxPanel
	
	Field DP_GameName:wxTextCtrl
	Field DP_GameDesc:wxTextCtrl
	Field DP_GameRel:wxTextCtrl
	Field DP_GameCert:wxComboBox
	Field DP_GameDev:wxTextCtrl
	Field DP_GamePub:wxTextCtrl
	Field DP_GameGen:wxTextCtrl
	Field DP_GameRate:wxComboBox
	Field DP_GameCoop:wxComboBox
	Field DP_GamePlayers:wxComboBox
	Field DP_GameVid:wxTextCtrl
	Field DP_GamePlat:wxComboBox
	
	Field FrontBoxArt:ImagePanel
	Field BackBoxArt:ImagePanel
	Field BackGroundArt:ImagePanel
	Field BannerArt:ImagePanel
	Field IconArt:ImagePanel
	Field FrontBoxArtBB:wxButton
	Field BackBoxArtBB:wxButton
	Field BackGroundArtBB:wxButton
	Field BannerArtBB:wxButton
	Field IconArtBB:wxButton
	
	Field NewFBArt:String
	Field NewBBArt:String
	Field NewBGArt:String
	Field NewBArt:String
	Field NewIArt:String
	
	Field EP_EXEPath:wxTextCtrl
	Field EP_EXEBrowse:wxButton
	Field EP_CLO:wxTextCtrl
	Field EP_EO:wxTextCtrl
	Field EP_EO_Text:wxStaticText
	
	'Field DescribeTextST:wxStaticText
	Field EP_EXE_Text:wxStaticText
	Field EP_CLO_Text:wxStaticText
	'Field DescribeTexthbox:wxBoxSizer
	
	'Field EP_TP2_ST:wxStaticText
	Field EP_EO_DT:wxStaticText
	
	Field EEP_LC:wxListCtrl
	Field EEP_EXEPath:wxTextCtrl
	Field EEP_EXEName:wxTextCtrl 
	
	Field GameRealPathList:TList
	
	Field AM_ISOPath:wxTextCtrl
	Field AM_UnMountCombo:wxComboBox
	Field AM_VDCombo:wxComboBox
	Field AM_MPath:wxTextCtrl
	Field AM_MountCombo:wxComboBox	
	Field AM_ISOBrowse:wxButton	
	Field AM_MBrowse:wxButton
	
	Field PostBFEXEPath:wxTextCtrl
	Field PreBFEXEPath:wxTextCtrl
	
	Field A_RunnerON:wxComboBox
	'Field A_StartWaitEnabled:wxComboBox
	Field A_EXEList:wxListCtrl
	
	Field BF_Pre_WTF:wxComboBox 
	Field BF_Post_WTF:wxComboBox
	
	Field UpdateListTimer:wxTimer
	
	Field HelpText:wxTextCtrl
	
	Method OnInit()
	
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
	
		UpdateListTimer = New wxTimer.Create(Self,EGL_ULT)
		Connect(EGL_ULT,wxEVT_TIMER, GameListUpdateTimer)
		
		
		Mounter.Init()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )

		BOLDFONT1:wxFont = New wxFont.Create()
		BOLDFONT1.SetPointSize(9)
		'BOLDFONT1.
		BOLDFONT1.SetWeight(wxFONTWEIGHT_BOLD)		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		
		ParentWin = MainWindow(GetParent() )
		Selection=-1
		Local MainVbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		DataChanged = 0
	
		'------------------------------TOP FILTER/PLAT PANEL--------------------------------------
		Local FilPlatPanel:wxPanel = New wxPanel.Create(Self , - 1)
		Local FilPlatHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local SortText:wxStaticText = New wxStaticText.Create(FilPlatPanel , wxID_ANY , "Sort:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		SortCombo = New wxComboBox.Create(FilPlatPanel, EGL_SL , "Alphabetical - Ascending" , SORTS , -1 , -1 , -1 , -1 , wxCB_DROPDOWN | wxCB_READONLY )
		Local FilterText:wxStaticText = New wxStaticText.Create(FilPlatPanel , wxID_ANY , "Filter:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		FilterTextBox = New wxTextCtrl.Create(FilPlatPanel, EGL_FTB , "" , -1 , -1 , -1 , -1 , 0 )
		Local PlatformText:wxStaticText = New wxStaticText.Create(FilPlatPanel , wxID_ANY , "Platform:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		PlatformCombo = New wxComboBox.Create(FilPlatPanel , EGL_PL , "All" , ["All"] + GlobalPlatforms.GetPlatformNameList() , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY | wxCB_SORT)		
		
		FilPlatHbox.Add(SortText , 0 , wxEXPAND | wxLEFT | wxTOP | wxBOTTOM | wxALIGN_CENTER , 10 )
		FilPlatHbox.Add(SortCombo , 2 , wxEXPAND | wxALL  , 10)
		FilPlatHbox.Add(FilterText , 0 , wxEXPAND | wxLEFT  | wxTOP | wxBOTTOM | wxALIGN_CENTER , 10 )
		FilPlatHbox.Add(FilterTextBox , 2 , wxEXPAND | wxALL , 10)
		FilPlatHbox.Add(PlatformText , 0 , wxEXPAND | wxLEFT | wxBOTTOM | wxTOP |  wxALIGN_CENTER , 10)
		FilPlatHbox.Add(PlatformCombo , 2 , wxEXPAND | wxALL  , 10)
		
		FilPlatPanel.SetSizer(FilPlatHbox)
		'--------------------------------GAME PANEL-----------------------------------------------
		
		Local GamePanel:wxPanel = New wxPanel.Create(Self , - 1)
		Local GameHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		Local SubGamePanel1:wxPanel = New wxPanel.Create(GamePanel , - 1)
		SubGamePanel1.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local SubGamePanel1Vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		GameList = New wxListCtrl.Create(SubGamePanel1 , EGL_GL , - 1 , - 1 , - 1 , - 1 ,  wxLC_REPORT | wxSUNKEN_BORDER )
		SubGamePanel1Vbox.Add(GameList , 14 , wxEXPAND | wxALL , 2 )
			
		
		Local SubGameButtonPanel1:wxPanel = New wxPanel.Create(SubGamePanel1 , - 1)
		Local SubGameButton1Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		AddButton = New wxButton.Create(SubGameButtonPanel1 , EGL_ADD , "Add")
		DelButton = New wxButton.Create(SubGameButtonPanel1 , EGL_DEL , "Delete")	
		OtherButton = New wxButton.Create(SubGameButtonPanel1 , EGL_OO , "Other Options")
	
		
		SubGameButton1Hbox.Add(AddButton , 10 , wxEXPAND | wxALL , 4 )
		SubGameButton1Hbox.Add(DelButton , 10 , wxEXPAND | wxALL , 4 )
		SubGameButton1Hbox.Add(OtherButton , 12 , wxEXPAND | wxALL , 4 )			

		SubGameButtonPanel1.SetSizer(SubGameButton1Hbox)		
		SubGamePanel1Vbox.Add(SubGameButtonPanel1 , 0 , wxEXPAND , 0 )

		
		Rem
		Local SubGameButtonPanel12:wxPanel = New wxPanel.Create(SubGamePanel1 , - 1)
		Local SubGameButton12Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		OptimizeButton = New wxButton.Create(SubGameButtonPanel12 , EGL_OPT , "Optimize Artwork")
		SubGameButton12Hbox.Add(OptimizeButton , 12 , wxEXPAND | wxALL , 4 )		
		SubGamePanel1Vbox.Add(SubGameButtonPanel12 , 1 , wxEXPAND , 0 )
		EndRem

		SubGamePanel1.SetSizer(SubGamePanel1Vbox)		
	
		
		
		SubGamePanel2 = New wxPanel.Create(GamePanel , - 1)
		SubGamePanel2.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )		
		Local SubGamePanel2Vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		HelpText = New wxTextCtrl.Create(SubGamePanel2, wxID_ANY, "Help information will appear here", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_BESTWRAP | wxTE_READONLY)
		If PMHideHelp = 1 then
			HelpText.Hide()
		EndIf
		Rem
		?MacOS
		GameNotebook = New wxChoicebook.Create(SubGamePanel2 , - 1 , - 1 , - 1 , - 1 , - 1 , wxCHB_DEFAULT)
		?Not MacOS
		EndRem
		GameNotebook = New wxNotebook.Create(SubGamePanel2 , EGL_GN , - 1 , - 1 , - 1 , - 1 , wxNB_TOP)
		'?
		
		'GameNotebook.SetBackgroundColour(New wxColour.Create(150 , 150 , 255) )
		'----------------------------------------------GAMEDETAILSPANEL----------------------------------------
		Local GameDetailsPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		Local GameDetailsSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local DP_GN_Text:wxStaticText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "Game Name" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GameName = New wxTextCtrl.Create(GameDetailsPanel , EGL_DP_GN , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local DP_GD_Text:wxStaticText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "Description" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GameDesc = New wxTextCtrl.Create(GameDetailsPanel , EGL_DP_GD , "" , - 1 , - 1 , - 1 , - 1 , wxTE_BESTWRAP | wxTE_MULTILINE )
		Local DP_GG_Text:wxStaticText = New wxStaticText.Create(GameDetailsPanel , wxID_ANY , "Genre (Separate genres by '/' eg. Action/Puzzle)" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GameGen = New wxTextCtrl.Create(GameDetailsPanel , EGL_DP_GG , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		
		SubGDPanel:wxPanel = New wxPanel.Create(GameDetailsPanel , - 1)
		SubGDPanelHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		SubGDPanel1:wxPanel = New wxPanel.Create(SubGDPanel , - 1)
		SubGDPanel1Vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Local DP_GC_Text:wxStaticText = New wxStaticText.Create(SubGDPanel1 , wxID_ANY , "Certificate" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		'DP_GameCert = New wxTextCtrl.Create(SubGDPanel1 , EGL_DP_GC , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		DP_GameCert = New wxComboBox.Create(SubGDPanel1, EGL_DP_GC , "Select..." , CERTIFICATES , -1 , -1 , -1 , -1 , wxCB_DROPDOWN | wxCB_READONLY )	
		Local DP_GDev_Text:wxStaticText = New wxStaticText.Create(SubGDPanel1 , wxID_ANY , "Developer" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GameDev = New wxTextCtrl.Create(SubGDPanel1 , EGL_DP_GDev , "" , - 1 , - 1 , - 1 , - 1 , 0 )					
		Local DP_GPub_Text:wxStaticText = New wxStaticText.Create(SubGDPanel1 , wxID_ANY , "Publisher" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GamePub = New wxTextCtrl.Create(SubGDPanel1 , EGL_DP_GPub , "" , - 1 , - 1 , - 1 , - 1 , 0 )							
		Local DP_GPlay_Text:wxStaticText = New wxStaticText.Create(SubGDPanel1 , wxID_ANY , "Players" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GamePlayers = New wxComboBox.Create(SubGDPanel1, EGL_DP_GPlay , "Select..." , ["Select..." , "1", "2" , "3" , "4+"] , -1 , -1 , -1 , -1 , wxCB_DROPDOWN | wxCB_READONLY )					
		Local DP_GVid_Text:wxStaticText = New wxStaticText.Create(SubGDPanel1 , wxID_ANY , "Youtube Video Code" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GameVid = New wxTextCtrl.Create(SubGDPanel1 , EGL_DP_GVid , "" , - 1 , - 1 , - 1 , - 1 , 0 )	

		
		SubGDPanel1Vbox.Add(DP_GC_Text , GNTextH ,  wxALL , 4 )
		SubGDPanel1Vbox.Add(DP_GameCert , 0 , wxEXPAND | wxALL , 4 )		
		SubGDPanel1Vbox.Add(DP_GDev_Text , GNTextH ,  wxALL , 4 )
		SubGDPanel1Vbox.Add(DP_GameDev , 0 , wxEXPAND | wxALL , 4 )		
		SubGDPanel1Vbox.Add(DP_GPub_Text , GNTextH ,  wxALL , 4 )
		SubGDPanel1Vbox.Add(DP_GamePub , 0 , wxEXPAND | wxALL , 4 )				
		SubGDPanel1Vbox.Add(DP_GPlay_Text , GNTextH ,  wxALL , 4 )
		SubGDPanel1Vbox.Add(DP_GamePlayers , 0 , wxEXPAND | wxALL , 4 )	
		SubGDPanel1Vbox.Add(DP_GVid_Text , GNTextH ,  wxALL , 4 )
		SubGDPanel1Vbox.Add(DP_GameVid , 0 , wxEXPAND | wxALL , 4 )				
		
		SubGDPanel1.SetSizer(SubGDPanel1Vbox)
		

		SubGDPanel2:wxPanel = New wxPanel.Create(SubGDPanel , - 1)
		SubGDPanel2Vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local LocalFormat:String
		Select Country
			Case "UK"
				LocalFormat = "DD/MM/YYYY"
			Case "US"
				LocalFormat = "MM/DD/YYYY"
			Case "EU"
				LocalFormat = "YYYY/MM/DD"
			Default
				CustomRuntimeError("Error 45: Invalid Country") 'MARK: Error 45
		End Select		
		
		Local DP_GRD_Text:wxStaticText = New wxStaticText.Create(SubGDPanel2 , wxID_ANY , "Release Date ( "+LocalFormat+" )" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GameRel = New wxTextCtrl.Create(SubGDPanel2 , EGL_DP_GRD , "" , - 1 , - 1 , - 1 , - 1 , 0 )		
		Local DP_GR_Text:wxStaticText = New wxStaticText.Create(SubGDPanel2 , wxID_ANY , "Rating" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GameRate = New wxComboBox.Create(SubGDPanel2 , EGL_DP_GR , "Select..." , RATINGLIST , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
		Local DP_GP_Text:wxStaticText = New wxStaticText.Create(SubGDPanel2 , wxID_ANY , "Platform" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GamePlat = New wxComboBox.Create(SubGDPanel2, EGL_DP_GP , "" , GlobalPlatforms.GetPlatformNameList() , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		Local DP_GCO_Text:wxStaticText = New wxStaticText.Create(SubGDPanel2 , wxID_ANY , "Co-Op" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		DP_GameCoop = New wxComboBox.Create(SubGDPanel2 , EGL_DP_GCO , "Select..." , ["Select..." , "Yes" , "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		Local SubGDPanel2VboxHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local DP_NO_Text:wxStaticText = New wxStaticText.Create(SubGDPanel2 , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		Local DP_TrailerButton:wxButton = New wxButton.Create(SubGDPanel2 , EGL_DP_TB , "View Trailer" )
		Local DP_AutoTrailerButton:wxButton = New wxButton.Create(SubGDPanel2 , EGL_DP_ATB , "Auto Find Trailer" )

		SubGDPanel2VboxHbox.Add(DP_TrailerButton , 1 , wxEXPAND | wxALL , 4 )
		SubGDPanel2VboxHbox.Add(DP_AutoTrailerButton , 1 , wxEXPAND | wxALL , 4 )
				
		SubGDPanel2Vbox.Add(DP_GRD_Text , GNTextH ,  wxALL , 4 )
		SubGDPanel2Vbox.Add(DP_GameRel , 0 , wxEXPAND | wxALL , 4 )	
		SubGDPanel2Vbox.Add(DP_GR_Text , GNTextH , wxALL , 4 )
		SubGDPanel2Vbox.Add(DP_GameRate , 0 , wxEXPAND | wxALL , 4 )
		SubGDPanel2Vbox.Add(DP_GP_Text , GNTextH ,  wxALL , 4 )
		SubGDPanel2Vbox.Add(DP_GamePlat , 0 , wxEXPAND | wxALL , 4 )	
		SubGDPanel2Vbox.Add(DP_GCO_Text , GNTextH ,  wxALL , 4 )
		SubGDPanel2Vbox.Add(DP_GameCoop , 0 , wxEXPAND | wxALL , 4 )		
		SubGDPanel2Vbox.Add(DP_NO_Text , GNTextH , wxALL , 4 )
		
		SubGDPanel2Vbox.AddSizer(SubGDPanel2VboxHbox, 0, wxEXPAND, 0)
		
			
		SubGDPanel2.SetSizer(SubGDPanel2Vbox)	
				
		SubGDPanelHbox.Add(SubGDPanel1 , 1 , wxEXPAND , 0)
		SubGDPanelHbox.Add(SubGDPanel2 , 1 , wxEXPAND , 0)
		SubGDPanel.SetSizer(SubGDPanelHbox)
		
		GameDetailsSizer.Add(DP_GN_Text , GNTextH ,  wxALL , 4 )
		GameDetailsSizer.Add(DP_GameName , 0 , wxEXPAND | wxALL , 4 )
		GameDetailsSizer.Add(DP_GD_Text , GNTextH ,  wxALL , 4 )
		GameDetailsSizer.Add(DP_GameDesc , 1 , wxEXPAND | wxALL , 4 )
		GameDetailsSizer.Add(DP_GG_Text , GNTextH ,  wxALL , 4 )
		GameDetailsSizer.Add(DP_GameGen , 0 , wxEXPAND | wxALL , 4 )	
		GameDetailsSizer.Add(SubGDPanel , 0 , wxEXPAND | wxALL , 4 )	

		GameDetailsPanel.SetSizer(GameDetailsSizer)
		'----------------------------------------------GAMEARTPANEL----------------------------------------
		Local GameArtPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		Local GameArtSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local SubGAPanel:wxPanel = New wxPanel.Create(GameArtPanel , - 1)
		Local SubGAPanelHbox1:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		FrontBoxArt = ImagePanel(New ImagePanel.Create(SubGAPanel , 1001 , - 1 , - 1 , - 1 , - 1 ) )
		FrontBoxArt.SetImageType(1)
		FrontBoxArt.SetEditGameWin(Self)
		BackBoxArt = ImagePanel(New ImagePanel.Create(SubGAPanel , - 1 , - 1 , - 1 , - 1 , - 1 ) )
		BackBoxArt.SetImageType(2)
		BackBoxArt.SetEditGameWin(Self)

			
		Local SubSubGAPanel:wxPanel = New wxPanel.Create(SubGAPanel , - 1)
		Local SubSubGAPanelVbox1:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		BackGroundArt = ImagePanel(New ImagePanel.Create(SubSubGAPanel , - 1 , - 1 , - 1 , - 1 , - 1 ) )
		BackGroundArt.SetImageType(3)
		BackGroundArt.SetEditGameWin(Self)
		
		SubSubGAPanelVbox1.Add(BackGroundArt , 12 , wxEXPAND  )
		SubSubGAPanelVbox1.AddStretchSpacer(5)
		
		SubSubGAPanel.SetSizer(SubSubGAPanelVbox1)
		
		
		SubGAPanelHbox1.Add(FrontBoxArt , 20 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		SubGAPanelHbox1.Add(BackBoxArt , 20 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		SubGAPanelHbox1.Add(SubSubGAPanel , 31 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )	
		
		SubGAPanel.SetSizer(SubGAPanelHbox1)
		
		Local SubGAPanel2:wxPanel = New wxPanel.Create(GameArtPanel , - 1)		
		Local SubGAPanelVbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		FrontBoxArtBB = New wxButton.Create(SubGAPanel2 , EGL_AP_FBABB , "Change")
		BackBoxArtBB = New wxButton.Create(SubGAPanel2 , EGL_AP_BBABB , "Change")
		BackGroundArtBB = New wxButton.Create(SubGAPanel2 , EGL_AP_BGABB , "Change")

		SubGAPanelVbox2.Add(FrontBoxArtBB , 2 , wxALIGN_CENTRE | wxLEFT | wxRIGHT  , 8 )
		SubGAPanelVbox2.Add(BackBoxArtBB , 2 , wxALIGN_CENTRE | wxLEFT | wxRIGHT  , 8 )
		SubGAPanelVbox2.Add(BackGroundArtBB , 3 , wxALIGN_CENTRE | wxLEFT | wxRIGHT , 8 )			
		
		SubGAPanel2.SetSizer(SubGAPanelVbox2)
		
		Local SubGAPanel3:wxPanel = New wxPanel.Create(GameArtPanel , - 1)		
		Local SubGAPanelHbox3:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		BannerArt = ImagePanel(New ImagePanel.Create(SubGAPanel3 , - 1 , - 1 , - 1 , - 1 , - 1 ) )
		BannerArt.SetImageType(4)
		BannerArt.SetEditGameWin(Self)
		
		IconArt = ImagePanel(New ImagePanel.Create(SubGAPanel3 , - 1 , - 1 , - 1 , - 1 , - 1 ) )
		IconArt.SetImageType(5)
		IconArt.SetEditGameWin(Self)
		
		SubGAPanelHbox3.Add(BannerArt , 5, wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		SubGAPanelHbox3.Add(IconArt , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )			
		
		SubGAPanel3.SetSizer(SubGAPanelHbox3)
		
		
		Local SubGAPanel4:wxPanel = New wxPanel.Create(GameArtPanel , - 1)		
		Local SubGAPanelHbox4:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		BannerArtBB = New wxButton.Create(SubGAPanel4 , EGL_AP_BABB , "Change")
		IconArtBB = New wxButton.Create(SubGAPanel4 , EGL_AP_IABB , "Change")


		SubGAPanelHbox4.Add(BannerArtBB , 5 , wxALIGN_CENTRE | wxLEFT | wxRIGHT  , 8 )
		SubGAPanelHbox4.Add(IconArtBB , 1 , wxALIGN_CENTRE | wxLEFT | wxRIGHT  , 8 )		
		
		SubGAPanel4.SetSizer(SubGAPanelHbox4)	
		
		Local SubGAPanel5:wxPanel = New wxPanel.Create(GameArtPanel , - 1)		
		Local SubGAPanelHbox5:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		Local AP_FBA_Text:wxStaticText = New wxStaticText.Create(SubGAPanel5 , wxID_ANY , "Front Box" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		Local AP_BBA_Text:wxStaticText = New wxStaticText.Create(SubGAPanel5 , wxID_ANY , "Back Box" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		Local AP_SA_Text:wxStaticText = New wxStaticText.Create(SubGAPanel5 , wxID_ANY , "Background" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)				

		SubGAPanelHbox5.Add(AP_FBA_Text , 2 , wxALIGN_CENTRE | wxLEFT | wxRIGHT  , 12 )
		SubGAPanelHbox5.Add(AP_BBA_Text , 2 , wxALIGN_CENTRE | wxLEFT | wxRIGHT , 12 )		
		SubGAPanelHbox5.Add(AP_SA_Text , 3 , wxALIGN_CENTRE | wxLEFT | wxRIGHT  , 12 )	
		
		SubGAPanel5.SetSizer(SubGAPanelHbox5)
		
		
		Local SubGAPanel6:wxPanel = New wxPanel.Create(GameArtPanel , - 1)		
		Local SubGAPanelHbox6:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		Local AP_BA_Text:wxStaticText = New wxStaticText.Create(SubGAPanel6 , wxID_ANY , "Banner" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		Local AP_IA_Text:wxStaticText = New wxStaticText.Create(SubGAPanel6 , wxID_ANY , "Icon" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)

		SubGAPanelHbox6.Add(AP_BA_Text , 5 , wxALIGN_CENTRE | wxLEFT | wxRIGHT  , 12 )
		SubGAPanelHbox6.Add(AP_IA_Text , 1 , wxALIGN_CENTRE | wxLEFT | wxRIGHT , 12 )		

		SubGAPanel6.SetSizer(SubGAPanelHbox6)		
		
		
		GameArtSizer.Add(SubGAPanel5 , 2 , wxEXPAND , 0 )
		GameArtSizer.Add(SubGAPanel, 18 , wxEXPAND  , 0 )
		GameArtSizer.Add(SubGAPanel2 , 4 , wxEXPAND , 0 )
		GameArtSizer.AddStretchSpacer(1)
		GameArtSizer.Add(SubGAPanel6 , 2 , wxEXPAND , 0 )
		GameArtSizer.Add(SubGAPanel3 , 8 , wxEXPAND , 0 )
		GameArtSizer.Add(SubGAPanel4 , 4 , wxEXPAND , 0 )
		GameArtSizer.AddStretchSpacer(3)	
		GameArtPanel.SetSizer(GameArtSizer)

		'----------------------------------------------EXECUTABLESPANEL----------------------------------------
		Local ExecutablePanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)
		Local ExecutablePanelSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
				
		Rem
		?MacOS
		ExecutableNotebook = New wxChoicebook.Create(ExecutablePanel , - 1 , - 1 , - 1 , - 1 , - 1 , wxCHB_DEFAULT)
		?Not MacOS
		EndRem
		ExecutableNotebook = New wxNotebook.Create(ExecutablePanel , EGL_EN , - 1 , - 1 , - 1 , - 1 , wxNB_TOP)
		'?	
		
		ExecutablePanelSizer.Add(ExecutableNotebook, 1 , wxEXPAND | wxTOP , 4)



		ExecutablePanel.SetSizer(ExecutablePanelSizer)
		

		'----------------------------------------------GAMEEXEPANEL----------------------------------------
		Local GameEXEPanel:wxPanel = New wxPanel.Create(ExecutableNotebook , - 1)	
		Local GameEXESizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		'Local DescribeTextPanel:wxPanel = New wxPanel.Create(GameEXEPanel , - 1)
		'DescribeTexthbox = New wxBoxSizer.Create(wxHORIZONTAL)
	
		'DescribeTextST = New wxStaticText.CreateStaticText(DescribeTextPanel , wxID_ANY , EP_EXE_DescribeText1 , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)
		
		'DescribeTexthbox.AddStretchSpacer(1)
		'DescribeTexthbox.Add(DescribeTextST , 0 , wxEXPAND , 0)
		'DescribeTexthbox.AddStretchSpacer(1)
		
		'DescribeTextPanel.SetSizer(DescribeTexthbox)
		
		EP_EXE_Text = New wxStaticText.Create(GameEXEPanel , wxID_ANY , "EXE Path:(Please enclose in speach mark) " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		EP_EXE_Text.SetFont(BOLDFONT1)	
		
		Local SubEXEPanel:wxPanel = New wxPanel.Create(GameEXEPanel , - 1)	
		Local SubEXEHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		EP_EXEPath = New wxTextCtrl.Create(SubEXEPanel , EGL_EP_EXEP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		EP_EXEBrowse = New wxButton.Create(SubEXEPanel , EGL_EP_EXEB , "Browse")
		SubEXEHbox.Add(EP_EXEPath , 10 , wxEXPAND | wxALL , 4)
		SubEXEHbox.Add(EP_EXEBrowse , 2 , wxEXPAND | wxALL , 4)
		
		SubEXEPanel.SetSizer(SubEXEHbox)
		
		
		EP_CLO_Text = New wxStaticText.Create(GameEXEPanel , wxID_ANY , "Command Line Options: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		EP_CLO_Text.SetFont(BOLDFONT1)
		EP_CLO = New wxTextCtrl.Create(GameEXEPanel , EGL_EP_CLO , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		
		
		'Local EP_TP2:wxPanel = New wxPanel.Create(GameEXEPanel , - 1)
		'Local EP_TP2_hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
	
		'EP_TP2_ST = New wxStaticText.CreateStaticText(EP_TP2 , wxID_ANY , EP_TP2_Text , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)
		
		'EP_TP2_hbox.AddStretchSpacer(1)
		'EP_TP2_hbox.Add(EP_TP2_ST , 0 , wxEXPAND , 0)
		'EP_TP2_hbox.AddStretchSpacer(1)
		
		'EP_TP2.SetSizer(EP_TP2_hbox)

		
		
		EP_EO_Text = New wxStaticText.Create(GameEXEPanel , wxID_ANY , "Emulator Override: " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		EP_EO_Text.SetFont(BOLDFONT1)
		
		Local EP_EO_hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		EP_EO = New wxTextCtrl.Create(GameEXEPanel , EGL_EP_EO , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local EP_EO_Browse:wxButton = New wxButton.Create(GameEXEPanel, EGL_EP_EO_B, "Browse")
		
		EP_EO_hbox.Add(EP_EO, 10, wxEXPAND | wxALL, 4)
		EP_EO_hbox.Add(EP_EO_Browse, 2, wxEXPAND | wxALL, 4)
		
		EP_EO_DT = New wxStaticText.Create(GameEXEPanel , wxID_ANY , "(Default Emulator)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		
			
		'GameEXESizer.Add(DescribeTextPanel, 0 , wxEXPAND | wxALL , 4)
		GameEXESizer.Add(EP_EXE_Text , 0 , wxEXPAND | wxALL , 4 )
		GameEXESizer.Add(SubEXEPanel , 0 , wxEXPAND | wxALL , 4 )
		GameEXESizer.Add(EP_CLO_Text , 0 , wxEXPAND | wxALL , 4 )
		GameEXESizer.Add(EP_CLO , 2 , wxEXPAND | wxALL , 4 )
		'GameEXESizer.Add(EP_TP2, 0, wxEXPAND | wxALL , 4 )
		GameEXESizer.Add(EP_EO_Text, 0 , wxEXPAND | wxALL , 4)
		GameEXESizer.AddSizer(EP_EO_hbox , 0 , wxEXPAND | wxALL , 4 )
		GameEXESizer.Add(EP_EO_DT , 0 , wxEXPAND | wxALL , 4 )		
		GameEXESizer.AddStretchSpacer(1)
		
		GameEXEPanel.SetSizer(GameEXESizer)
		
		'-------------------------------------EXTRA EXE FILES------------------------------------
		
		Local GameExtraEXEPanel:wxPanel = New wxPanel.Create(ExecutableNotebook , - 1)	
		Local GameExtraEXESizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		'Local DescribeTextPanel5:wxPanel = New wxPanel.Create(GameExtraEXEPanel , - 1)
		'DescribeTexthbox5:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
	
		'DescribeTextST5 = New wxStaticText.CreateStaticText(DescribeTextPanel5 , wxID_ANY , EP_EEXE_DescribeText1 , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)
		
		'DescribeTexthbox5.AddStretchSpacer(1)
		'DescribeTexthbox5.Add(DescribeTextST5 , 0 , wxEXPAND , 0)
		'DescribeTexthbox5.AddStretchSpacer(1)
		
		'DescribeTextPanel5.SetSizer(DescribeTexthbox5)

		'EEP_LB = New wxListBox.Create(GameExtraEXEPanel , EGL_EEP_LB , Null , -1 , -1 , -1 , -1 , wxLB_SINGLE)
		EEP_LC = New wxListCtrl.Create(GameExtraEXEPanel , EGL_EEP_LC , - 1 , - 1 , - 1 , - 1 , wxLC_REPORT|wxLC_EDIT_LABELS|wxLC_SORT_ASCENDING)
		
		Local SubEEXEPanel2:wxPanel = New wxPanel.Create(GameExtraEXEPanel , - 1)	
		Local SubEEXEHbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		Local EEP_NT:wxStaticText = New wxStaticText.CreateStaticText(SubEEXEPanel2 , wxID_ANY , "Name" , - 1 , - 1 , - 1 , - 1 )
		Local EEP_PT:wxStaticText = New wxStaticText.CreateStaticText(SubEEXEPanel2 , wxID_ANY , "Executable Path" , - 1 , - 1 , - 1 , - 1 )
		
		SubEEXEHbox2.Add(EEP_NT , 3 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT, 4)
		SubEEXEHbox2.Add(EEP_PT , 7 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT, 4)
		SubEEXEHbox2.AddStretchSpacer(2)
		SubEEXEPanel2.SetSizer(SubEEXEHbox2)
		
		
		

		Local SubEEXEPanel:wxPanel = New wxPanel.Create(GameExtraEXEPanel , - 1)	
		Local SubEEXEHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		EEP_EXEName = New wxTextCtrl.Create(SubEEXEPanel , EGL_EEP_EXEN , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		EEP_EXEPath = New wxTextCtrl.Create(SubEEXEPanel , EGL_EEP_EXEP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local EEP_EXEBrowse:wxButton = New wxButton.Create(SubEEXEPanel , EGL_EEP_EXEB , "Browse")
		SubEEXEHbox.Add(EEP_EXEName , 3 , wxEXPAND | wxBOTTOM | wxLEFT | wxRIGHT , 4)
		SubEEXEHbox.Add(EEP_EXEPath , 7 , wxEXPAND | wxBOTTOM | wxLEFT | wxRIGHT , 4)
		SubEEXEHbox.Add(EEP_EXEBrowse , 2 , wxEXPAND | wxBOTTOM | wxLEFT | wxRIGHT , 4)
		
		SubEEXEPanel.SetSizer(SubEEXEHbox)
		
		Local EEP_BP:wxPanel = New wxPanel.Create(GameExtraEXEPanel , - 1)
		Local EEP_BPHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local EEP_AddButton:wxButton = New wxButton.Create(EEP_BP , EGL_EEP_ADD , "Add")
		Local EEP_DelButton:wxButton = New wxButton.Create(EEP_BP , EGL_EEP_DEL , "Delete")	
		EEP_BPHbox.Add(EEP_AddButton , 10 , wxEXPAND | wxALL , 4 )
		EEP_BPHbox.Add(EEP_DelButton , 10 , wxEXPAND | wxALL , 4 )			
		EEP_BP.SetSizer(EEP_BPHbox)		
		
		
		
		
		'GameExtraEXESizer.Add(DescribeTextPanel5 , 0 , wxEXPAND | wxALL , 4)
		GameExtraEXESizer.Add(EEP_LC , 1 , wxEXPAND | wxALL , 4 )
		GameExtraEXESizer.Add(SubEEXEPanel2 , 0, wxEXPAND | wxBOTTOM , 2 )
		GameExtraEXESizer.Add(SubEEXEPanel , 0, wxEXPAND , 4 )
		GameExtraEXESizer.Add(EEP_BP , 0 , wxEXPAND | wxALL , 4 )
		GameExtraEXEPanel.SetSizer(GameExtraEXESizer)
		
		
		'-------------------------------------Batch FILES------------------------------------	
		Local BatchFilesPanel:wxPanel = New wxPanel.Create(ExecutableNotebook , - 1)	
		Local BatchFilesSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		
		'Local BF_ST:wxStaticText = New wxStaticText.CreateStaticText(BatchFilesPanel , wxID_ANY , BF_ET_Text , - 1 , - 1 , - 1 , - 1, wxALIGN_CENTRE )		

		
		
		
		Local PreBatchPanel:wxPanel = New wxPanel.Create(BatchFilesPanel , - 1)	
		Local PreBatchHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BF_Pre_PT:wxStaticText = New wxStaticText.CreateStaticText(PreBatchPanel , wxID_ANY , "Pre Game Launch Batch File" , - 1 , - 1 , - 1 , - 1 )		
		PreBFEXEPath = New wxTextCtrl.Create(PreBatchPanel , EGL_PreBF_EXEP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local PreBF_EXEBrowse = New wxButton.Create(PreBatchPanel , EGL_PreBF_EXEB , "Browse")
		PreBatchHbox.Add(BF_Pre_PT , 0 , wxEXPAND | wxALL , 4)
		PreBatchHbox.Add(PreBFEXEPath , 10 , wxEXPAND | wxALL , 4)
		PreBatchHbox.Add(PreBF_EXEBrowse , 0 , wxEXPAND | wxALL , 4)
		PreBatchPanel.SetSizer(PreBatchHbox)		

		
		Local PreBatchHbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BF_Pre_WTFT:wxStaticText = New wxStaticText.CreateStaticText(BatchFilesPanel , wxID_ANY , "Wait For Pre Batch File to Finish" , - 1 , - 1 , - 1 , - 1 )		
		BF_Pre_WTF = New wxComboBox.Create(BatchFilesPanel, EGL_PreBF_WTF , "No" , ["Yes","No"] , -1 , -1 , -1 , -1 , wxCB_DROPDOWN | wxCB_READONLY )	
		PreBatchHbox2.Add(BF_Pre_WTFT , 0 , wxEXPAND | wxALL , 4)
		PreBatchHbox2.Add(BF_Pre_WTF , 10 , wxEXPAND | wxALL , 4)

		Local PostBatchPanel:wxPanel = New wxPanel.Create(BatchFilesPanel , - 1)	
		Local PostBatchHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BF_Post_PT:wxStaticText = New wxStaticText.CreateStaticText(PostBatchPanel , wxID_ANY , "Post Game Launch Batch File" , - 1 , - 1 , - 1 , - 1 )		
		PostBFEXEPath = New wxTextCtrl.Create(PostBatchPanel , EGL_PostBF_EXEP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local PostBF_EXEBrowse = New wxButton.Create(PostBatchPanel , EGL_PostBF_EXEB , "Browse")
		PostBatchHbox.Add(BF_Post_PT , 0 , wxEXPAND | wxALL , 4)
		PostBatchHbox.Add(PostBFEXEPath , 10 , wxEXPAND | wxALL , 4)
		PostBatchHbox.Add(PostBF_EXEBrowse , 0 , wxEXPAND | wxALL , 4)
		PostBatchPanel.SetSizer(PostBatchHbox)	
		
		Local PreBatchHbox3:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BF_Post_WTFT:wxStaticText = New wxStaticText.CreateStaticText(BatchFilesPanel , wxID_ANY , "Wait For Batch File to Finish" , - 1 , - 1 , - 1 , - 1 )		
		BF_Post_WTF = New wxComboBox.Create(BatchFilesPanel, EGL_PostBF_WTF , "No" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
		PreBatchHbox3.Add(BF_Post_WTFT , 0 , wxEXPAND | wxALL , 4)
		PreBatchHbox3.Add(BF_Post_WTF , 10 , wxEXPAND | wxALL , 4)			
		
		'BatchFilesSizer.Add(BF_ST , 0 , wxEXPAND | wxALL , 4)
		'BatchFilesSizer.Add(BF_Pre_PT , 0 , wxEXPAND | wxALL , 4)
		BatchFilesSizer.Add(PreBatchPanel , 0 , wxEXPAND | wxTOP , 10)
		BatchFilesSizer.AddSizer(PreBatchHbox2 , 0 , wxEXPAND | wxALL , 0)

		'BatchFilesSizer.Add(BF_Post_PT , 0 , wxEXPAND | wxALL , 4)
		BatchFilesSizer.Add(PostBatchPanel , 0 , wxEXPAND  , 0)
		BatchFilesSizer.AddSizer(PreBatchHbox3 , 0 , wxEXPAND | wxALL , 0)
	
		BatchFilesPanel.SetSizer(BatchFilesSizer)	
		
		'-------------------------------------AutoMount------------------------------------	

		
		Local AutoMountPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)	
		Local AutoMountSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		'Local AM_ET_ST:wxStaticText = New wxStaticText.CreateStaticText(AutoMountPanel , wxID_ANY , AM_ET_Text , - 1 , - 1 , - 1 , - 1 ,wxALIGN_CENTER)				

		
		
		Local Subhbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local AM_MC_ST:wxStaticText = New wxStaticText.CreateStaticText(AutoMountPanel , wxID_ANY , "Mounter: " , - 1 , - 1 , - 1 , - 1 )				
		AM_MountCombo:wxComboBox = New wxComboBox.Create(AutoMountPanel , EGL_AM_MC , "None" , ["None"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY)
		
		For mount:String = EachIn Self.Mounter.MountersList
			AM_MountCombo.Append(mount)
		Next 
		Subhbox2.Add(AM_MC_ST , 0 , wxEXPAND | wxALL , 4)
		Subhbox2.Add(AM_MountCombo , 1 , wxEXPAND | wxALL , 4)

		Local Subhbox3:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local AM_MP_ST:wxStaticText = New wxStaticText.CreateStaticText(AutoMountPanel , wxID_ANY , "Mounter Path" , - 1 , - 1 , - 1 , - 1 )				
		AM_MPath = New wxTextCtrl.Create(AutoMountPanel , EGL_AM_MP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		AM_MBrowse = New wxButton.Create(AutoMountPanel , EGL_AM_MB , "Browse")
		Subhbox3.Add(AM_MP_ST , 0 , wxEXPAND | wxALL , 4)
		Subhbox3.Add(AM_MPath , 1 , wxEXPAND | wxALL , 4)
		Subhbox3.Add(AM_MBrowse , 0 , wxEXPAND | wxALL , 4)
		

		
		Local Subhbox4:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local AM_VD_ST:wxStaticText = New wxStaticText.CreateStaticText(AutoMountPanel , wxID_ANY , "Virtual Drive Number: " , - 1 , - 1 , - 1 , - 1 )				
		AM_VDCombo = New wxComboBox.Create(AutoMountPanel , EGL_AM_VDC , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN)
		Local AM_UC_ST:wxStaticText = New wxStaticText.CreateStaticText(AutoMountPanel , wxID_ANY , "UnMount?: " , - 1 , - 1 , - 1 , - 1 )				
		AM_UnMountCombo = New wxComboBox.Create(AutoMountPanel,EGL_AM_UC,"Yes",["Yes","No"],-1,-1,-1,-1,wxCB_DROPDOWN|wxCB_READONLY)		
		Subhbox4.Add(AM_VD_ST , 0 , wxEXPAND | wxALL , 4)
		Subhbox4.Add(AM_VDCombo , 1 , wxEXPAND | wxALL , 4)		
		Subhbox4.Add(AM_UC_ST , 0 , wxEXPAND | wxALL , 4)
		Subhbox4.Add(AM_UnMountCombo , 1 , wxEXPAND | wxALL , 4)
		


		Local Subhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local AM_ISO_ST:wxStaticText = New wxStaticText.CreateStaticText(AutoMountPanel , wxID_ANY , "Disc Image File" , - 1 , - 1 , - 1 , - 1 )				
		AM_ISOPath = New wxTextCtrl.Create(AutoMountPanel , EGL_AM_ISOP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		AM_ISOBrowse = New wxButton.Create(AutoMountPanel , EGL_AM_ISOB , "Browse")
		Subhbox.Add(AM_ISO_ST , 0 , wxEXPAND | wxALL , 4)
		Subhbox.Add(AM_ISOPath , 1 , wxEXPAND | wxALL , 4)
		Subhbox.Add(AM_ISOBrowse , 0 , wxEXPAND | wxALL , 4)

		AM_MPath.Disable()
		AM_MBrowse.Disable()
		AM_VDCombo.Disable()
		AM_UnMountCombo.Disable()
		AM_ISOPath.Disable()
		AM_ISOBrowse.Disable()
				
	
		'AutoMountSizer.Add(AM_ET_ST , 0 , wxEXPAND | wxALL , 4)
		AutoMountSizer.AddSizer(Subhbox2 , 0 , wxEXPAND | wxALL , 4)
		AutoMountSizer.AddSizer(Subhbox3 , 0 , wxEXPAND | wxALL , 4)
		AutoMountSizer.AddSizer(Subhbox4 , 0 , wxEXPAND | wxALL , 4)
		AutoMountSizer.AddSizer(Subhbox , 0 , wxEXPAND | wxALL , 4)
		
		AutoMountPanel.SetSizer(AutoMountSizer)	
		

		
		
		
		
		'-------------------------------------Advanced------------------------------------	
		
		Local AdvancedPanel:wxPanel = New wxPanel.Create(GameNotebook , - 1)	
		Local AdvancedSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Local SL3:wxStaticLine = New wxStaticLine.Create(AdvancedPanel , wxID_ANY)
		'Local A_ET_ST:wxStaticText = New wxStaticText.CreateStaticText(AdvancedPanel , wxID_ANY , A_ET_Text , - 1 , - 1 , - 1 , - 1 ,wxALIGN_CENTER)				
		
	'	Local font:wxFont = A_ET_ST.GetFont();
      ' 	font.SetWeight(wxFONTWEIGHT_BOLD);
	'	A_ET_ST.SetFont(font)
		
		Local Asubhbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local A_RAO_Text:wxStaticText = New wxStaticText.Create(AdvancedPanel , wxID_ANY , "PhotonRunner only closes when you click the close button (this game only): " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		A_RunnerON = New wxComboBox.Create(AdvancedPanel, EGL_A_RAO , "No" , ["Yes","No"] , -1 , -1 , -1 , -1 , wxCB_DROPDOWN | wxCB_READONLY )	
		
		Local Asubhbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		'Local A_SWE_Text:wxStaticText = New wxStaticText.Create(AdvancedPanel , wxID_ANY , "Wait 30 seconds after starting game before checking if it has closed? (this game only): " , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		'A_StartWaitEnabled = New wxComboBox.Create(AdvancedPanel, EGL_A_SWE , "No" , ["Yes", "No"] , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )			
		
		
		Local Asubhbox3:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local SL1:wxStaticLine = New wxStaticLine.Create(AdvancedPanel , wxID_ANY)
		Local A_ET_ST2:wxStaticText = New wxStaticText.CreateStaticText(AdvancedPanel , wxID_ANY , "Watch Executable List" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTER)	
		
		A_EXEList = New wxListCtrl.Create(AdvancedPanel , EGL_A_EXEL , - 1 , - 1 , - 1 , - 1 , wxLC_REPORT | wxLC_EDIT_LABELS | wxLC_SORT_ASCENDING)
		Local A_AddFolderButton:wxButton = New wxButton.Create(AdvancedPanel , EGL_A_AddF , "Add Folder")
		Local A_AddExecutableButton:wxButton = New wxButton.Create(AdvancedPanel , EGL_A_AddE , "Add Executable")
		Local A_DeleteButton:wxButton = New wxButton.Create(AdvancedPanel , EGL_A_Del , "Delete")


		Connect(EGL_A_AddF , wxEVT_COMMAND_BUTTON_CLICKED , WEXEAddF)
		Connect(EGL_A_AddE , wxEVT_COMMAND_BUTTON_CLICKED , WEXEAddE)
		Connect(EGL_A_Del , wxEVT_COMMAND_BUTTON_CLICKED , WEXEDelete)
		
		
		Asubhbox.Add(A_RAO_Text , 0 , wxEXPAND | wxALL , 4)
		Asubhbox.Add(A_RunnerON , 1 , wxEXPAND | wxALL , 4)
		
		'Asubhbox2.Add(A_SWE_Text , 0 , wxEXPAND | wxALL , 4)
		'Asubhbox2.Add(A_StartWaitEnabled , 1 , wxEXPAND | wxALL , 4)
		
		Asubhbox3.Add(A_AddFolderButton , 0 , wxEXPAND | wxALL , 4)
		Asubhbox3.Add(A_AddExecutableButton , 1 , wxEXPAND | wxALL , 4)
		Asubhbox3.Add(A_DeleteButton , 0 , wxEXPAND | wxALL , 4)				
		

		'AdvancedSizer.Add(A_ET_ST , 0 , wxEXPAND | wxALL , 4)
		AdvancedSizer.AddSizer(Asubhbox , 0 , wxEXPAND | wxALL , 4)
		AdvancedSizer.AddSizer(Asubhbox2 , 0 , wxEXPAND | wxALL , 4)

		AdvancedSizer.Add(SL1 , 0 , wxEXPAND | wxALL , 0)
		AdvancedSizer.Add(A_ET_ST2 , 0 , wxEXPAND | wxALL , 4)
		AdvancedSizer.Add(A_EXEList , 2 , wxEXPAND | wxALL , 4)
		AdvancedSizer.AddSizer(Asubhbox3 , 0 , wxEXPAND | wxALL , 4)
		AdvancedPanel.SetSizer(AdvancedSizer)	
		
		
		
		'----------------------------------------------------------------------------------			
		GameNotebook.AddPage(GameDetailsPanel , "Details" )
		GameDetailsPanel.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		GameNotebook.AddPage(GameArtPanel , "Artwork" )
		GameArtPanel.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		
		'Function hello()
		
		GameNotebook.AddPage(ExecutablePanel, "Executables")
		
		ExecutableNotebook.AddPage(GameEXEPanel , "Run Executable Path" )
		GameEXEPanel.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )		
		ExecutableNotebook.AddPage(GameExtraEXEPanel , "Other Executables" )
		GameExtraEXEPanel.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		ExecutableNotebook.AddPage(BatchFilesPanel , "Batch Files" )
		BatchFilesPanel.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )		
		GameNotebook.AddPage(AutoMountPanel , "AutoMount" )
		AutoMountPanel.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )		
		GameNotebook.AddPage(AdvancedPanel , "Runner Options" )
		AdvancedPanel.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )	
						
		
		SubGamePanel2Vbox.Add(HelpText , 1 , wxEXPAND | wxALL , 2 )
		SubGamePanel2Vbox.Add(GameNotebook , 5 , wxEXPAND | wxALL , 2 )
		
		

		
		Local SubGameButtonPanel2:wxPanel = New wxPanel.Create(SubGamePanel2 , - 1)
		Local SubGameButton2Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		'CancelButton= New wxButton.Create(SubGameButtonPanel2 , EGL_CAN , "Cancel Changes")
		SaveButton = New wxButton.Create(SubGameButtonPanel2 , EGL_SAVE , "Save")
		
		SubGameButton2Hbox.Add(SaveButton , 1 , wxEXPAND | wxALL , 4 )
		'SubGameButton2Hbox.Add(CancelButton , 1 , wxEXPAND | wxALL , 4 )
		SubGameButtonPanel2.SetSizer(SubGameButton2Hbox)		
		SubGamePanel2Vbox.Add(SubGameButtonPanel2 , 0 , wxEXPAND , 0 )
		SubGamePanel2.SetSizer(SubGamePanel2Vbox)
		

		GameHbox.Add(SubGamePanel1 , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10 )
		GameHbox.Add(SubGamePanel2 , 2 , wxEXPAND | wxRIGHT  , 10 )
				
		GamePanel.SetSizer(GameHbox)
		
		SaveButton.Disable()
		SubGamePanel2.Disable()
		
		'-----------------------------------------------------------------------------------------

		Local BackButtonPanel:wxPanel = New wxPanel.Create(Self , - 1)
		Local BackButtonVbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		BackButton = New wxButton.Create(BackButtonPanel , EGL_EXIT , "Back")
		BackButtonVbox.Add(BackButton , 4 , wxALIGN_LEFT | wxALL , 5)
		
		BackButtonPanel.SetSizer(BackButtonVbox)
		
		MainVbox.Add(FilPlatPanel , 0 , wxEXPAND , 0)
		MainVbox.Add(GamePanel , 30 , wxEXPAND , 0)
		'MainVbox.Add(GameButtonPanel, 0.5 , wxEXPAND , 0)
		MainVbox.Add(BackButtonPanel, 0 , wxEXPAND , 0)		
		Self.SetSizer(MainVbox)
		Self.Centre()	
		If PMMaximize = 1 then
			Self.Maximize(1)
		EndIf
		Self.Hide()
		'wxframe
		
		Connect(EGL_DP_ATB, wxEVT_COMMAND_BUTTON_CLICKED , FindTrailer)
		Connect(EGL_DP_TB , wxEVT_COMMAND_BUTTON_CLICKED , ShowTrailer)
		Connect(EGL_EXIT , wxEVT_COMMAND_BUTTON_CLICKED , ShowMainMenu)
		Connect(EGL_PL , wxEVT_COMMAND_COMBOBOX_SELECTED , GameListUpdate )
		Connect(EGL_SL , wxEVT_COMMAND_COMBOBOX_SELECTED , GameListUpdate )
		Connect(EGL_AM_MC , wxEVT_COMMAND_COMBOBOX_SELECTED , UpdateMounterOptions)
		Connect(EGL_FTB , wxEVT_COMMAND_TEXT_UPDATED , GameListUpdate )
		Connect(EGL_ADD , wxEVT_COMMAND_BUTTON_CLICKED , ShowAGM)
		Connect(EGL_GL , wxEVT_COMMAND_LIST_ITEM_SELECTED , UpdateSelection)
		Connect(EGL_DEL , wxEVT_COMMAND_BUTTON_CLICKED , DeleteSelection)
		Connect(EGL_OO , wxEVT_COMMAND_BUTTON_CLICKED , OtherOptionsMenu)
		Connect(EGL_M1_I1 , wxEVT_COMMAND_MENU_SELECTED , UpdateGame)
		Connect(EGL_M1_I2 , wxEVT_COMMAND_MENU_SELECTED , UpdateAllGames)
		
		'Connect(EGL_OPT , wxEVT_COMMAND_BUTTON_CLICKED , OptimizeAllArt)		
		
		'Connect(EGL_GL , wxEVT_COMMAND_LIST_ITEM_ACTIVATED, UpdateGame)
		'Connect(EGL_GL , wxEVT_COMMAND_LIST_ITEM_SELECTED, UpdateDetails)
		Connect(EGL_GL , wxEVT_COMMAND_LIST_KEY_DOWN , GLKeyPress)
		
		Connect(EGL_EEP_ADD , wxEVT_COMMAND_BUTTON_CLICKED , EEXEAdd)
		Connect(EGL_EEP_DEL , wxEVT_COMMAND_BUTTON_CLICKED , EEXEDelete)
		Connect(EGL_EEP_LC , wxEVT_COMMAND_LIST_END_LABEL_EDIT , DataChangeUpdate)
		Connect(EGL_EEP_LC , wxEVT_COMMAND_LIST_ITEM_SELECTED  , EEXESelect)
		Connect(EGL_EEP_EXEB , wxEVT_COMMAND_BUTTON_CLICKED , EEXEBrowse)

		'ConnectAny(wxEVT_KEY_DOWN, GLKeyPress)
		
		Connect(EGL_EP_EXEB , wxEVT_COMMAND_BUTTON_CLICKED , EXEBrowse)
		Connect(EGL_AP_FBABB , wxEVT_COMMAND_BUTTON_CLICKED , FrontBoxArt.FrontImageBrowseFun)
		Connect(EGL_AP_BBABB , wxEVT_COMMAND_BUTTON_CLICKED , BackBoxArt.BackImageBrowseFun )
		Connect(EGL_AP_BGABB , wxEVT_COMMAND_BUTTON_CLICKED , BackGroundArt.BackgroundImageBrowseFun )
		Connect(EGL_AP_BABB , wxEVT_COMMAND_BUTTON_CLICKED , BannerArt.BannerImageBrowseFun )
		Connect(EGL_AP_IABB , wxEVT_COMMAND_BUTTON_CLICKED , IconArt.IconImageBrowseFun)
		
		
		Connect(IP_M1_I3 , wxEVT_COMMAND_MENU_SELECTED , FrontBoxArt.FrontImageClickFun)
		Connect(IP_M2_I3 , wxEVT_COMMAND_MENU_SELECTED , BackBoxArt.BackImageClickFun )
		Connect(IP_M3_I3 , wxEVT_COMMAND_MENU_SELECTED , BackGroundArt.BackgroundImageClickFun )
		Connect(IP_M4_I3 , wxEVT_COMMAND_MENU_SELECTED , BannerArt.BannerImageClickFun )
		Connect(IP_M5_I5 , wxEVT_COMMAND_MENU_SELECTED , IconArt.IconImageClickFun)		
		
		
		Connect(IP_M1_I1 , wxEVT_COMMAND_MENU_SELECTED , FrontBoxBrowse)	
		Connect(IP_M1_I2 , wxEVT_COMMAND_MENU_SELECTED , FrontDelete)	
			
		Connect(IP_M2_I1 , wxEVT_COMMAND_MENU_SELECTED , BackBoxBrowse)
		Connect(IP_M2_I2 , wxEVT_COMMAND_MENU_SELECTED , BackDelete)

		
		Connect(IP_M3_I1 , wxEVT_COMMAND_MENU_SELECTED , BackGroundBrowse)
		Connect(IP_M3_I2 , wxEVT_COMMAND_MENU_SELECTED , BackGroundDelete)
		Connect(IP_M3_I4 , wxEVT_COMMAND_MENU_SELECTED , OnlineArtworkBrowse , "3")
		
		Connect(IP_M4_I1 , wxEVT_COMMAND_MENU_SELECTED , BannerBrowse)
		Connect(IP_M4_I2 , wxEVT_COMMAND_MENU_SELECTED , BannerDelete)
		Connect(IP_M4_I4 , wxEVT_COMMAND_MENU_SELECTED , OnlineArtworkBrowse , "4")		
				
		Connect(IP_M5_I1 , wxEVT_COMMAND_MENU_SELECTED , IconBrowse)		
		
								
		Connect(IP_M5_I2 , wxEVT_COMMAND_MENU_SELECTED , IconExtract)
		Connect(IP_M5_I3	 , wxEVT_COMMAND_MENU_SELECTED , SteamIconBrowse)	
		Connect(IP_M5_I4 , wxEVT_COMMAND_MENU_SELECTED , IconDelete)			
		
		Connect(EGL_SAVE , wxEVT_COMMAND_BUTTON_CLICKED , SaveGame)
		
		Connect(EGL_PreBF_EXEB , wxEVT_COMMAND_BUTTON_CLICKED , PreBatchBrowse)
		Connect(EGL_PostBF_EXEB , wxEVT_COMMAND_BUTTON_CLICKED , PostBatchBrowse)
		
		Connect(EGL_AM_ISOB ,wxEVT_COMMAND_BUTTON_CLICKED, DiscImageBrowse)
		Connect(EGL_AM_MB ,wxEVT_COMMAND_BUTTON_CLICKED, MounterBrowse)
		'--------------------------DETAILS UPDATED--------------------------------------
		Connect( EGL_DP_GN , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GD , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GRD , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GDev , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GPub , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GG , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_EP_EXEP , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_EP_CLO , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_EP_EO , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		
		Connect( EGL_DP_GR , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GC , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)	
		Connect( EGL_DP_GP , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GCO , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GPlay , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_DP_GVid , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_PreBF_EXEP , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_PostBF_EXEP , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		
		Connect( EGL_AM_ISOP , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_AM_MP , wxEVT_COMMAND_TEXT_UPDATED , DataChangeUpdate)
		Connect( EGL_AM_VDC , wxEVT_COMMAND_COMBOBOX_SELECTED , DataChangeUpdate)
		Connect( EGL_A_RAO , wxEVT_COMMAND_COMBOBOX_SELECTED , DataChangeUpdate)	
		Connect( EGL_A_SWE , wxEVT_COMMAND_COMBOBOX_SELECTED , DataChangeUpdate)			
		Connect( EGL_AM_UC , wxEVT_COMMAND_COMBOBOX_SELECTED , DataChangeUpdate)
		
		Connect( EGL_PreBF_WTF , wxEVT_COMMAND_COMBOBOX_SELECTED , DataChangeUpdate)
		Connect( EGL_PostBF_WTF , wxEVT_COMMAND_COMBOBOX_SELECTED , DataChangeUpdate)		
		
		Connect(EGL_GN, wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED, GameNotebookPageChanged)
		Connect(EGL_EN, wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED, GameNotebookPageChanged)
		
		Connect(EGL_EP_EO_B, wxEVT_COMMAND_BUTTON_CLICKED, BrowseEmuOverrideFun)
		
		'------------------------------------------------------------------------------
		'ConnectAny(wxEVT_COMMAND_RIGHT_CLICK  , TestFun)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function BrowseEmuOverrideFun(event:wxEvent)
		Local Window:EditGameList = EditGameList(event.parent)
		?Not Win32	
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EmuWin, "Select emulator path" )	
		If openFileDialog.ShowModal() = wxID_OK then
			Window.EP_EO.ChangeValue(Chr(34) + openFileDialog.GetPath() + Chr(34) + " [ROMPATH] [EXTRA-CMD]")
		EndIf
		?Win32
		tempFile:String = RequestFile("Select emulator path" )
		If tempFile <> "" then
			Window.EP_EO.ChangeValue(Chr(34) + tempFile + Chr(34) + " [ROMPATH] [EXTRA-CMD]")
		EndIf
		? 	
		Window.DataChangeUpdate(event)
	End Function

	Function GameNotebookPageChanged(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local Page:String, Page2:String
		If EditGameWin.GameNotebook.GetSelection() <> - 1 then
			Page = EditGameWin.GameNotebook.GetPageText(EditGameWin.GameNotebook.GetSelection() )
			Select Page
				Case "Details"
					EditGameWin.HelpText.SetValue(EGL_Help_Details)
				Case "Artwork"
					EditGameWin.HelpText.SetValue(EGL_Help_Artwork)
				Case "AutoMount"
					EditGameWin.HelpText.SetValue(EGL_Help_AutoMount)
				Case "Runner Options"
					EditGameWin.HelpText.SetValue(EGL_Help_Runner_Options)
				Case "Executables"
					If EditGameWin.ExecutableNotebook.GetSelection() <> - 1 then
						Page2 = EditGameWin.ExecutableNotebook.GetPageText(EditGameWin.ExecutableNotebook.GetSelection() )
						Select Page2
							Case "ROM Path"
								EditGameWin.HelpText.SetValue(EGL_Help_ROM)
							Case "Run Executable Path"
								EditGameWin.HelpText.SetValue(EGL_Help_Run)
							Case "Other Executables"
								EditGameWin.HelpText.SetValue(EGL_Help_Other_Executables)
							Case "Batch Files"
								EditGameWin.HelpText.SetValue(EGL_Help_Batch)
							Default
								CustomRuntimeError("GameNotebookPageChanged Page Select Error 2")
						End Select
					EndIf
				Default
					CustomRuntimeError("GameNotebookPageChanged Page Select Error")
			End Select
		EndIf
	End Function

	Function OtherOptionsMenu(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local Menu1:wxMenu = New wxMenu.Create("Other Options Menu")
		Menu1.Append(EGL_M1_I1 , "Update Selection")
		Menu1.Append(EGL_M1_I2 , "Update All")
		EditGameWin.PopupMenu(Menu1)
	End Function

Rem
	Function OptimizeAllArt(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "This updates the artwork to work with the current Frontend resolution. Continue?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then		
			EditGameWin.Show(0)
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
			Forever
			CloseDir(GameDir)
			EditGameWin.Show(1)
			Log1.Show(0)	
		EndIf 	
	End Function
EndRem

	Function UpdateMounterOptions(event:wxEvent)
		Local EGW:EditGameList = EditGameList(event.parent)
		
		EGW.Mounter.MounterPath = EGW.AM_MPath.GetValue()
		EGW.Mounter.SaveMounter()
		
		If EGW.AM_MountCombo.GetValue() = "None" Then
			EGW.AM_MPath.Disable()
			EGW.AM_MBrowse.Disable()
			EGW.AM_VDCombo.Disable()
			EGW.AM_UnMountCombo.Disable()
			EGW.AM_ISOPath.Disable()
			EGW.AM_ISOBrowse.Disable()
		Else
			EGW.AM_MPath.Enable()
			EGW.AM_MBrowse.Enable()
			EGW.AM_VDCombo.Enable()
			EGW.AM_UnMountCombo.Enable()
			EGW.AM_ISOPath.Enable()
			EGW.AM_ISOBrowse.Enable()
			EGW.Mounter.GetMounter(EGW.AM_MountCombo.GetValue() )
			EGW.AM_VDCombo.Clear()
			For Drive:String = EachIn EGW.Mounter.Drives
				EGW.AM_VDCombo.Append(Drive)
			Next
			EGW.AM_MPath.ChangeValue(EGW.Mounter.MounterPath)
		EndIf 
		DataChangeUpdate(event)
	End Function

	Function CloseApp(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local MainWin:MainWindow = EditGameList(event.parent).ParentWin
		
		If EditGameList(event.parent).DataChanged = 1 Then
			PrintF("Clear Changes?")
			MessageBox = New wxMessageDialog.Create(Null, "You have unsaved changes, are you sure you wish to exit?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				PrintF("Changes Not Cleared")
				'EGW.PopulateGameList
				'EGW.GameList.SetitemState(EGW.Selection , wxLIST_STATE_SELECTED , wxLIST_MASK_TEXT | wxLIST_MASK_IMAGE )
				MessageBox.Free()
				Return
			Else
				PrintF("Changes Cleared")
				MessageBox.Free()
			EndIf
		EndIf
		MainWin.Close(True)
		Return		
		
	End Function
		
	Function TestFun(event:wxEvent)
		Print "CLICK"
		DebugStop 
	End Function
	
	Function GLKeyPress(event:wxEvent)
		Local KeyEvent:wxListEvent = wxListEvent(event)
		Select KeyEvent.GetKeyCode()
			Case 127 , 8
				DeleteSelection(event)
			Default
			
		End Select			
	End Function

	Method PopulateGameList()
		
		GameRealPathList = CreateList()
		Local GameIconList:wxImageList = New wxImageList.Create(32 , 32 , True)
		GameList.SetImageList(GameIconList, wxIMAGE_LIST_SMALL)
		?MacOS
		Local myIcon:wxIcon = wxIcon.CreateFromFile( RESFOLDER+"NoIcon-MAC.ico" , wxBITMAP_TYPE_ICO , 32 , 32  )
		?Not MacOS
		Local myIcon:wxIcon = wxIcon.CreateFromFile( RESFOLDER+"NoIcon.ico" , wxBITMAP_TYPE_ICO )
		
		?
		GameIconList.AddIcon( myIcon )
		
		
		

		GameList.DeleteAllItems()
		?Win32
		GameList.DeleteColumn(0)
		?
		DatabaseApp.Yield()
		
		PopulateTList()
		PrintF("Creating ListCtrl Columns")		
		Local itemCol:wxListItem = New wxListItem.Create()
		itemCol.SetText("Games")
		GameList.InsertColumnItem(0 , itemCol)
		Local GameLine:String
		Local LSI:Int = 0
		Local LSI_Icon:Int = 1
		Local GameNode:GameType
		GameNode = New GameType
		PrintF("Looping Through adding each game to list")
		For GameLine = EachIn GamesTList
			If GameNode.GetGame(GameLine) = - 1 Then
				
			Else
				?Win32
				If FileType(GAMEDATAFOLDER + GameLine + FolderSlash+"Icon.ico") = 1 Then
					GameIconList.AddIcon( wxIcon.CreateFromFile( GAMEDATAFOLDER + GameLine +FolderSlash+"Icon.ico" , wxBITMAP_TYPE_ICO ) )			
					'Local Pixmap:TPixmap = LoadPixmap(GAMEDATAFOLDER + GameLine + "\Front_OPT.jpg")
					'Pixmap = MaskPixmap(Pixmap , - 1 , - 1 , - 1)
					'Pixmap = ResizePixmap(Pixmap,128,128)
					'GameIconList.Add( wxBitmap.CreateBitmapFromPixmap(Pixmap))
					LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , LSI_Icon)
					LSI_Icon = LSI_Icon + 1
					ListAddLast(GameRealPathList,GameLine)
				Else
					LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , 0)
					ListAddLast(GameRealPathList,GameLine)
				EndIf
				?Not Win32
					LSI = GameList.InsertImageStringItem(LSI , GameNode.Name , 0)
					ListAddLast(GameRealPathList,GameLine)
				?
				'LSI = GameList.InsertImageItem(LSI , 0)
				If LSI = -1 Then CustomRuntimeError("Error 1: Unable to add "+GameLine+" To GameList")		'MARK: Error 1	
				LSI = LSI + 1
			EndIf
		Next
		GameList.SetColumnWidth( 0 , wxLIST_AUTOSIZE )
		
		Local StringItem:String 
		Local ID:Int = 0
		Local IDSet:Int = False 
		
		If EditGameName <> "" Then 
			For StringItem = EachIn GameRealPathList
				If StringItem = EditGameName Then 
					IDSet = True 
					Exit
				Else
					ID = ID + 1
				EndIf
			Next 
			If IDSet = True Then 
				Local item:wxListItem = New wxListItem.Create()	
				item.SetID(ID)
				GameList.GetItem(item)
				item.SetState(wxLIST_STATE_SELECTED)
				GameList.SetItem(item)
			EndIf 
		EndIf 
		?Not Win32	
		Local w:Int
		Local h:Int 
		Self.GetSize(w,h)
		Self.SetSize(w + 1, h)
		?
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
		
		Local PlatformFilterType:String = PlatformCombo.GetValue()
		PrintF("Platform: "+PlatformFilterType)
		GameDir = ReadDir(GAMEDATAFOLDER)
		Repeat
			item$ = NextFile(GameDir)
			If item = "" then Exit
			If item = "." Or item = ".." then Continue
			GameNode:GameType = New GameType
			If GameNode.GetGame(item) = - 1 Then
			
			Else
				If GlobalPlatforms.GetPlatformByID(GameNode.PlatformNum).Name = PlatformFilterType Or PlatformFilterType = "All" then
					ListAddLast(GamesTList,item)
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
					GameNode:GameType = New GameType
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
								CustomRuntimeError("Error 2: SortCombo Get String Fail") 'MARK: Error 2
						End Select
					EndIf
					Rem
					If FileType(GAMEDATAFOLDER+item+"\Info.txt")=1 Then
						InfoFile=ReadFile(GAMEDATAFOLDER+item+"\Info.txt")
						For a=1 To 4
							ReadLine(InfoFile)
						Next
						itemDate=ReadLine(InfoFile)
						ReadLine(InfoFile)
						itemDev=ReadLine(InfoFile)
						itemPub=ReadLine(InfoFile)
						itemGen = ReadLine(InfoFile)
						ReadLine(InfoFile)
						itemScore=ReadLine(InfoFile)
						itemPlat=ReadLine(InfoFile)
						CloseFile(InfoFile)
						If FileType(GAMEDATAFOLDER+item+"\userdata.txt")=1 Then
							InfoFile=ReadFile(GAMEDATAFOLDER+item+"\userdata.txt")
							itemScore=ReadLine(InfoFile)
							itemCompleted=ReadLine(InfoFile)
							CloseFile(InfoFile)
						Else
							itemCompleted=0
						EndIf		
										
						Select SortCombo.GetStringSelection()
							Case "Genre"
								If itemGen="" Then
									ListAddLast(GamesTSList,"zzzz>"+item)
								Else
									ListAddLast(GamesTSList,itemGen+">"+item)
								EndIf							
							Case "Developer"
								If itemDev="" Then
									ListAddLast(GamesTSList,"zzzz>"+item)
								Else
									ListAddLast(GamesTSList,itemDev+">"+item)
								EndIf	
							Case "Publisher"						
								If itemPub="" Then
									ListAddLast(GamesTSList,"zzzz>"+item)
								Else
									ListAddLast(GamesTSList,itemPub+">"+item)
								EndIf	
							Case "Rating"							
								If itemScore="" Then
									ListAddLast(GamesTSList,"0>"+item)
								Else
									If itemScore=10 Then
										ListAddLast(GamesTSList,"10>"+item)
									Else
										ListAddLast(GamesTSList,"0"+(10-Int(itemScore))+">"+item)
									EndIf
								EndIf		
							Case "Completed"
								If itemCompleted="" Then
									ListAddLast(GamesTSList,"0>"+item)
								Else
									ListAddLast(GamesTSList,itemCompleted+">"+item)
								EndIf																					
							Case "Release Date"
								If itemDate="" Then
									ListAddLast(GamesTSList,"9999/99/99>"+item)
								Else
									itemDate=Right(itemDate,4)+"/"+Left(itemDate,2)+"/"+Mid(itemDate,4,2)
									ListAddLast(GamesTSList,itemDate+">"+item)
								EndIf
							Default
								CustomRuntimeError("Error 2: SortCombo Get String Fail") 'MARK: Error 2
						End Select	
					Else
						PrintF("Couldn't Find: "+GAMEDATAFOLDER+item+"\Info.txt"	)
					EndIf
					endrem
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

	Function OnlineArtworkBrowse(event:wxEvent)
		PrintF("--------------Begin OnlineArtworkBrowse--------------")
		Local EGW:EditGameList = EditGameList(event.parent)
		Local data:Object = event.userData
		Local GameNamesArray:Object[]
		Local ArtworkPickerField:ArtworkPicker
		GameNamesArray = ListToArray(EGW.GameRealPathList)		
		GameName:String = String(GameNamesArray[EGW.Selection])
		Print String(data)
		Select String(data)
			Case "3"
				ArtworkPickerField = ArtworkPicker(New ArtworkPicker.Create(EGW, wxID_ANY, "Artwork Picker", , , 800, 600) )	
				EGW.Hide()
				ArtworkPickerField.SetType(GameName , 3)
				
			Case "4"
				ArtworkPickerField = ArtworkPicker(New ArtworkPicker.Create(EGW, wxID_ANY, "Artwork Picker", , , 800, 600))	
				EGW.Hide()
				ArtworkPickerField.SetType(GameName , 4)
		End Select
		PrintF("--------------Finish OnlineArtworkBrowse--------------")
	End Function

	Function UpdateSelection(event:wxEvent)
		PrintF("--------------Begin UpdateSelection--------------")
		Local EGW:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog
		Local GRate:String, GCert:String, GPlatform:String, GEmuOverride:String , GCoop:String , GPlayers:String, GPlatformNum:Int
		EGW.SubGamePanel2.Enable()
		EGW.GameNotebookPageChanged(event)
		
		If EGW.DataChanged = 1 then
			PrintF("Clear Changes?")
			MessageBox = New wxMessageDialog.Create(Null, "You have unsaved changes, are you sure you wish to clear them?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				PrintF("Changes Not Cleared")
				'EGW.PopulateGameList
				'EGW.GameList.SetitemState(EGW.Selection , wxLIST_STATE_SELECTED , wxLIST_MASK_TEXT | wxLIST_MASK_IMAGE )
				MessageBox.Free()
				EGW.DataChanged = 1
				Return
			Else
				PrintF("Changes Cleared")
				MessageBox.Free()
				EGW.DataChanged = 0
				EGW.SaveButton.Disable()
			EndIf
		EndIf
		
		PrintF("Reseting artwork paths")
		EGW.NewFBArt = ""
		EGW.NewBBArt = ""
		EGW.NewBGArt = ""
		EGW.NewBArt = ""
		EGW.NewIArt = ""
		
		'Local info:wxListItem = New wxListItem.Create()
		Local ReadInfo:TStream
		'EGW.Selection = wxListEvent(event).GetIndex()
		EGW.Selection = EGW.GameList.GetNextItem(-1, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED) 
		'info.SetId(wxListEvent(event).GetIndex() )
		'info.SetColumn(0)
		'info.SetMask(wxLIST_MASK_TEXT)
		'EGW.GameList.GetItem(info)
		'Local GameName:String = info.GetText()		
		
		Local GameNamesArray:Object[]
		GameNamesArray = ListToArray(EGW.GameRealPathList)
		Local GameName:String = String(GameNamesArray[EGW.Selection])
		PrintF("Retrieved game name as"+GameName)
		
		If FileType(GAMEDATAFOLDER+GameName+FolderSlash+"Front_OPT.jpg")=1 Then
			EGW.FrontBoxArt.SetImage(GAMEDATAFOLDER + GameName +FolderSlash+"Front_OPT.jpg")
			PrintF("Loading Front Artwork")
		Else
			EGW.FrontBoxArt.SetImage("")
		EndIf
		
		If FileType(GAMEDATAFOLDER+GameName +FolderSlash+"Back_OPT.jpg")=1 Then
			EGW.BackBoxArt.SetImage(GAMEDATAFOLDER + GameName +FolderSlash+"Back_OPT.jpg")
			PrintF("Loading Back Artwork")
		Else
			EGW.BackBoxArt.SetImage("")
		EndIf
				
		If FileType(GAMEDATAFOLDER+GameName +FolderSlash+"Screen_OPT.jpg")=1 Then
			EGW.BackGroundArt.SetImage(GAMEDATAFOLDER + GameName +FolderSlash+"Screen_OPT.jpg")
			PrintF("Loading Screen Artwork")
		Else
			EGW.BackGroundArt.SetImage("")
		EndIf
		
		If FileType(GAMEDATAFOLDER+GameName +FolderSlash+"Banner_OPT.jpg")=1 Then
			EGW.BannerArt.SetImage(GAMEDATAFOLDER + GameName +FolderSlash+"Banner_OPT.jpg")
			PrintF("Loading Banner Artwork")
		Else
			EGW.BannerArt.SetImage( "")
		EndIf		
		
		If FileType(GAMEDATAFOLDER+GameName +FolderSlash+"Icon.ico")=1 Then
			EGW.IconArt.SetImage(GAMEDATAFOLDER + GameName +FolderSlash+"Icon.ico")
			PrintF("Loading Icon Artwork")
		Else
			EGW.IconArt.SetImage("")
		EndIf	
		GameNode:GameType = New GameType
		If GameNode.GetGame(GameName) = - 1 Then
		
		Else
			EGW.DP_GameName.ChangeValue(GameNode.Name) 'Name
			EGW.DP_GameDesc.ChangeValue(GameNode.Desc)  'Description
			'Local temp1:String = ReadLine(ReadInfo)
			'Local temp2:String = ReadLine(ReadInfo)
			
			EGW.DP_GameRel.ChangeValue( GetDateFromCorrectFormat(GameNode.ReleaseDate) )  'Release Date
			GCert = GameNode.Cert
			If GCert = "" Then GCert = "Select..."
			EGW.DP_GameCert.SetSelection(EGW.DP_GameCert.FindString(GCert) ) 'Certificate
			
			EGW.DP_GameDev.ChangeValue(GameNode.Dev ) 'Developer
			EGW.DP_GamePub.ChangeValue(GameNode.Pub ) 'Publisher
			Local GenreLine:String = "" , Genre:String = ""
			For genre = EachIn GameNode.Genres
				GenreLine = GenreLine + genre + "/"
			Next
			GenreLine = Left(GenreLine , Len(GenreLine) - 1 )
			EGW.DP_GameGen.ChangeValue(GenreLine ) 'Genre
			GRate = GameNode.Rating
			If GRate = "" Then GRate = "Select..."
			EGW.DP_GameRate.SetSelection(EGW.DP_GameRate.FindString(GRate ) )'Rating
			'GPlatform = GameNode.Plat
			
			
			GPlatformNum = GameNode.PlatformNum
			EGW.DP_GamePlat.SetSelection(EGW.DP_GamePlat.FindString(GlobalPlatforms.GetPlatformByID(GPlatformNum).Name ) )'Platform
			GEmuOverride = GameNode.EmuOverride
			
			GCoop = GameNode.Coop
			If GCoop = "" Then GCoop = "Select..."
			EGW.DP_GameCoop.SetSelection(EGW.DP_GameCoop.FindString( GCoop ) )'Coop
			GPlayers = GameNode.Players
			If GPlayers = "" Then GPlayers = "Select..."
			EGW.DP_GamePlayers.SetSelection(EGW.DP_GamePlayers.FindString( GPlayers ) )'Players
			EGW.DP_GameVid.ChangeValue(GameNode.Trailer )
			
			EGW.PreBFEXEPath.ChangeValue(GameNode.PreBF)
			EGW.PostBFEXEPath.ChangeValue(GameNode.PostBF)
			
			
			
			If IsntNull(GameNode.Mounter) = False Then
				EGW.AM_MountCombo.SetValue("None")
			Else
				EGW.AM_MountCombo.SetValue(GameNode.Mounter)
			EndIf
			
			
			
			If EGW.AM_MountCombo.GetValue() = "None" Then
				EGW.AM_MPath.Disable()
				EGW.AM_MBrowse.Disable()
				EGW.AM_VDCombo.Disable()
				EGW.AM_UnMountCombo.Disable()
				EGW.AM_ISOPath.Disable()
				EGW.AM_ISOBrowse.Disable()
			Else
				EGW.AM_MPath.Enable()
				EGW.AM_MBrowse.Enable()
				EGW.AM_VDCombo.Enable()
				EGW.AM_UnMountCombo.Enable()
				EGW.AM_ISOPath.Enable()
				EGW.AM_ISOBrowse.Enable()
				EGW.Mounter.GetMounter(EGW.AM_MountCombo.GetValue() )
				EGW.AM_VDCombo.Clear()
				For Drive:String = EachIn EGW.Mounter.Drives
					EGW.AM_VDCombo.Append(Drive)
				Next
				EGW.AM_MPath.ChangeValue(EGW.Mounter.MounterPath)
			EndIf 
			
			EGW.AM_VDCombo.SetValue(GameNode.VDriveNum)
			EGW.AM_UnMountCombo.SetValue(GameNode.UnMount)
			EGW.AM_ISOPath.ChangeValue(GameNode.DiscImage)
			
			If GameNode.GameRunnerAlwaysOn = 1 then
				EGW.A_RunnerON.SetSelection(EGW.A_RunnerON.FindString("Yes") )
			Else
				EGW.A_RunnerON.SetSelection(EGW.A_RunnerON.FindString("No") )
			EndIf 
			
			'If GameNode.StartWaitEnabled = 1 Then
			'	EGW.A_StartWaitEnabled.SetSelection(EGW.A_StartWaitEnabled.FindString("Yes") )
			'Else
			'	EGW.A_StartWaitEnabled.SetSelection(EGW.A_StartWaitEnabled.FindString("No") )
			'EndIf

			
			If GameNode.PreBFWait = 1 Then 
				EGW.BF_Pre_WTF.SetSelection(EGW.BF_Pre_WTF.FindString("Yes") )
			Else
				EGW.BF_Pre_WTF.SetSelection(EGW.BF_Pre_WTF.FindString("No") )
			EndIf 
			
			If GameNode.PostBFWait = 1 Then 
				EGW.BF_Post_WTF.SetSelection(EGW.BF_Post_WTF.FindString("Yes") )
			Else
				EGW.BF_Post_WTF.SetSelection(EGW.BF_Post_WTF.FindString("No") )
			EndIf 			
			
			Local EXE:String
			Local CmdVar:String 	

								
			
			If GlobalPlatforms.GetPlatformByID(GPlatformNum).PlatType = "Folder" then
				EGW.ExecutableNotebook.SetPageText(0,"Run Executable Path")
				EGW.EP_EO_DT.SetLabel("")
				'EGW.EP_TP2_ST.SetLabel("")
				EGW.EP_EO.Disable()
				EGW.EP_EO.Hide()
				EGW.EP_EO_Text.SetLabel("")
				EGW.EP_EO.ChangeValue("")
				'EGW.DescribeTextST.SetLabel(EP_EXE_DescribeText1)
				EGW.EP_EXE_Text.SetLabel("EXE: ")
				EGW.EP_CLO_Text.SetLabel("Command Line Options: ")		
				'EGW.DescribeTexthbox.Layout()
				
				'For a = 1 To Len(GameNode.EXE)
				'	If Mid(GameNode.EXE , a , 1) = "." Then
				'		EXE = GameNode.Dir + Left(GameNode.EXE , a + 3)
				'		CmdVar = Right(GameNode.EXE , Len(GameNode.EXE) - a - 4)
				'		Exit
				'	EndIf
				'Next		
				
				If Left(GameNode.RunEXE, 1) = Chr(34) then
					For a = 2 To Len(GameNode.RunEXE)
						If Mid(GameNode.RunEXE , a , 1) = Chr(34) Then
							EXE = Left(GameNode.RunEXE , a)
							CmdVar = Right(GameNode.RunEXE , Len(GameNode.RunEXE) - (a+1) )
							Exit
						EndIf
					Next				
				Else
					For a = 1 To Len(GameNode.RunEXE)
						If Mid(GameNode.RunEXE , a , 1) = " " Then
							EXE = Left(GameNode.RunEXE , a -1)
							CmdVar = Right(GameNode.RunEXE , Len(GameNode.RunEXE) - a )
							Exit
						EndIf
					Next							
				EndIf 
			Else
				EGW.ExecutableNotebook.SetPageText(0,"ROM Path")
				'EGW.EP_TP2_ST.SetLabel(EP_TP2_Text)
				EGW.EP_EO.Enable()
				EGW.EP_EO.Show()
				EGW.EP_EO_Text.SetLabel("Emulator Override")			
				'EGW.DescribeTextST.SetLabel(EP_EXE_DescribeText2)
				EGW.EP_EXE_Text.SetLabel("Rom Path: ")
				EGW.EP_CLO_Text.SetLabel("Extra Command Line Options: ")				
				'EGW.DescribeTexthbox.Layout()
				If GEmuOverride = "" Or GEmuOverride = " " Then
					EGW.EP_EO.ChangeValue(GlobalPlatforms.GetPlatformByID(GPlatformNum).Emulator )
					If GlobalPlatforms.GetPlatformByID(GPlatformNum).Emulator = "" then
						EGW.EP_EO_DT.SetLabel("(Default emulator for this platform not set! Goto 'Platform' tab of main menu to set one.)")
					Else
						EGW.EP_EO_DT.SetLabel("(Default Emulator)")
					EndIf
				Else
					EGW.EP_EO.ChangeValue(GEmuOverride)
					EGW.EP_EO_DT.SetLabel("")
				EndIf
				EXE = GameNode.ROM
				CmdVar = GameNode.ExtraCMD
			EndIf
			

			EGW.EP_EXEPath.ChangeValue(EXE) 'EXE
			EGW.EP_CLO.ChangeValue(CmdVar) 'CmdLine		
				
			Local OEXEsArray:Object[] = ListToArray(GameNode.OEXEs)
			Local OEXEsNameArray:Object[] = ListToArray(GameNode.OEXEsName)
			'EGW.EEP_LB.Clear()
			EGW.EEP_LC.ClearAll()
			EGW.EEP_LC.InsertColumn(0 , "Name")
			EGW.EEP_LC.InsertColumn(1 , "Executable")
			
			If Len(OEXEsArray) = Len(OEXEsNameArray) Then
				For a = 0 To Len(OEXEsArray) - 1
					index = EGW.EEP_LC.InsertStringItem( a , String(OEXEsNameArray[a]) )
					EGW.EEP_LC.SetStringItem(index , 1 , String(OEXEsArray[a]) )
					'EGW.EEP_LB.Append(String(OEXEsNameArray[a])+"::"+String(OEXEsArray[a]))
				Next
			Else
				CustomRuntimeError("Error 43: OEXE arrays dont match in size") 'MARK: Error 43
			EndIf			
		

			EGW.EEP_LC.SetColumnWidth(0 , 150)
			EGW.EEP_LC.SetColumnWidth(1 , wxLIST_AUTOSIZE_USEHEADER)
			
			EGW.A_EXEList.ClearAll()
			EGW.A_EXEList.InsertColumn(0 , "Executable")
			EGW.A_EXEList.SetColumnWidth(0 , wxLIST_AUTOSIZE_USEHEADER)
			
			Local WatchEXEsArray:Object[] = ListToArray(GameNode.WatchEXEs)
			
			For a = 0 To Len(WatchEXEsArray) - 1
				EGW.A_EXEList.InsertStringItem(a  , String(WatchEXEsArray[a]) )
			Next
			
			EGW.GameNotebookPageChanged(event)
			
			PrintF("Set Details into Details Pane")

		EndIf
		

		PrintF("Refresh Panel")
		EGW.Refresh()
		PrintF("--------------Finish UpdateSelection--------------")
	End Function
	
	Function FindTrailer(event:wxEvent)
		Local EGW:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog
		Local Trailer:String = EGW.GetYoutube(EGW.DP_GameName.GetValue() )
		If Trailer = "" then
			MessageBox = New wxMessageDialog.Create(Null , "Could not find a video" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
		Else
			EGW.DP_GameVid.SetValue( Trailer)
		EndIf
	End Function
	
	Function GetYoutube:String(Text:String)
		Local TFile:TStream
		Local Trailercurl:TCurlEasy
		Local Line:String
		Local Error:Int
		
		Trailercurl = TCurlEasy.Create()
		TFile = WriteFile(TEMPFOLDER + "YoutubeHTML.json")
		Trailercurl.setOptInt(CURLOPT_FOLLOWLOCATION , 1)
		Trailercurl.setOptInt(CURLOPT_HEADER, 0)
		Trailercurl.setOptString(CURLOPT_CAINFO, "ca-bundle.crt")
		Trailercurl.setWriteStream(TFile)
		Trailercurl.setOptInt(CURLOPT_SSL_VERIFYPEER, 0)
		PrintF("https://photongamemanager.com/GameManagerPages/Youtube.php?q=" + Replace(Replace(Text, " ", "+"), "&", "") + "+Trailer")
		Trailercurl.setOptString(CURLOPT_URL, "https://photongamemanager.com/GameManagerPages/Youtube.php?q=" + Replace(Replace(Text, " ", "+"), "&", "") + "+Trailer" )
		Error = Trailercurl.perform()
		CloseFile(TFile)	
		If Error then
			PrintF("CurlError: " + CurlError(Error) )
			Return ""
		EndIf
	
		Local ReadYoutube:TStream = ReadFile(TEMPFOLDER + "YoutubeHTML.json")
		Local RegEx:TRegEx = TRegEx.Create(Chr(34) + "videoId" + Chr(34) + ": " + Chr(34) + "(.+)" + Chr(34) )
		Local match:TRegExMatch
		
		Repeat
			Line = ReadLine(ReadYoutube)
			

			match = RegEx.Find(Line)

			If match And match.SubCount() > 0 then
				PrintF("Youtube:" + match.SubExp(1) )
				Return match.SubExp(1)
			EndIf
			
			If Eof(ReadYoutube) then Exit
		Forever
		CloseFile(ReadYoutube)
		Return ""
	End Function 
		
	
	Function ShowTrailer(event:wxEvent)
		Local EGW:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog
	
		If Left(EGW.DP_GameVid.GetValue(), Len("https://www.youtube.com/watch?v=") ) = "https://www.youtube.com/watch?v=" then
			EGW.DP_GameVid.SetValue(Mid(EGW.DP_GameVid.GetValue(), Len("https://www.youtube.com/watch?v=")+1 , 11) )
		EndIf
		If Left(EGW.DP_GameVid.GetValue(), Len("http://www.youtube.com/watch?v=") ) = "http://www.youtube.com/watch?v=" then
			EGW.DP_GameVid.SetValue(Mid(EGW.DP_GameVid.GetValue(), Len("http://www.youtube.com/watch?v=") + 1 , 11) )
		EndIf	
							If EGW.DP_GameVid.GetValue().length > 0 And EGW.DP_GameVid.GetValue().length <> 11 then
			MessageBox = New wxMessageDialog.Create(Null , "Invalid Trailer code: it should be 11 characters and can be found by taking the youtube video link and copying the 11 characters after the 'v=' part of the link. So for 'youtube.com/watch?v=nfWlot6h_JM' you would enter 'nfWlot6h_JM'. Leave blank to not have a trailer." , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			Return				
		EndIf
		Local Trailer:String = EGW.DP_GameVid.GetValue()
		OpenURL("http://www.youtube.com/watch?v=" + Trailer)
	End Function
	
	Function SaveGame(event:wxEvent)
		Local EGW:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog
		If EGW.AM_MountCombo.GetValue() <> "None" Then 
			EGW.Mounter.MounterPath = EGW.AM_MPath.GetValue()
			
			If FileType(EGW.Mounter.MounterPath ) <> 1 then
				MessageBox = New wxMessageDialog.Create(Null , "Invalid Mounter Path" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()
				Return					
			EndIf					
			
			EGW.Mounter.SaveMounter()
			

			If IsntNull(EGW.AM_VDCombo.GetValue())=False Then
				MessageBox = New wxMessageDialog.Create(Null , "Invalid Virtual Drive Number" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()
				Return		
			EndIf
			
			If IsntNull(EGW.AM_UnMountCombo.GetValue() ) = False Then
				MessageBox = New wxMessageDialog.Create(Null , "Invalid UnMount Option" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()
				Return					
			EndIf
			
			If FileType(EGW.AM_ISOPath.GetValue() ) <> 1 Then
				MessageBox = New wxMessageDialog.Create(Null , "Invalid Game Image Path" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()
				Return					
			EndIf
				
		EndIf 
		
		If Left(EGW.DP_GameVid.GetValue(), Len("https://www.youtube.com/watch?v=") ) = "https://www.youtube.com/watch?v=" then
			EGW.DP_GameVid.SetValue(Mid(EGW.DP_GameVid.GetValue(), Len("https://www.youtube.com/watch?v=")+1 , 11) )
		EndIf
		If Left(EGW.DP_GameVid.GetValue(), Len("http://www.youtube.com/watch?v=") ) = "http://www.youtube.com/watch?v=" then
			EGW.DP_GameVid.SetValue(Mid(EGW.DP_GameVid.GetValue(), Len("http://www.youtube.com/watch?v=") + 1 , 11) )
		EndIf		
		
		If EGW.DP_GameVid.GetValue().length > 0 And EGW.DP_GameVid.GetValue().length <> 11 then
			MessageBox = New wxMessageDialog.Create(Null , "Invalid Trailer code: it should be 11 characters and can be found by taking the youtube video link and copying the 11 characters after the 'v=' part of the link. So for 'youtube.com/watch?v=nfWlot6h_JM' you would enter 'nfWlot6h_JM'. Leave blank to not have a trailer." , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			Return				
		EndIf
		
		'Local info:wxListItem = New wxListItem.Create()
		Local ReadInfo:TStream , WriteInfo:TStream
		Local ID:Int , GameName:String , GameNameS:String , BaseDir:String , EXE:String
		
				
		Local GDate:String = EGW.DP_GameRel.GetValue()
		Local GCert:String = EGW.DP_GameCert.GetValue()
		Local GRate:String = EGW.DP_GameRate.GetValue()
		Local GCoop:String = EGW.DP_GameCoop.GetValue()
		Local GPlayers:String = EGW.DP_GamePlayers.GetValue()

		Local GRunnerAlwaysOn:Int
		Local GStartWaitEnabled:Int
		Local PreWait:Int
		Local PostWait:Int 
		
		If EGW.A_RunnerON.GetValue()="Yes" Then 
			GRunnerAlwaysOn = 1
		Else
			GRunnerAlwaysOn = 0
		EndIf 
		
		'If EGW.A_StartWaitEnabled.GetValue()="Yes" Then
		'	GStartWaitEnabled = 1
		'Else
		'	GStartWaitEnabled = 0
		'EndIf

		If EGW.BF_Pre_WTF.GetValue()="Yes" Then 
			PreWait = 1
		Else
			PreWait = 0
		EndIf 		

		If EGW.BF_Post_WTF.GetValue()="Yes" Then 
			PostWait = 1
		Else
			PostWait = 0
		EndIf 
		
		
		If GCert = "Select..." Then GCert = ""
		If GRate = "Select..." Then GRate = ""	
		If GCoop = "Select..." Then GCoop = ""
		If GPlayers = "Select..." Then GPlayers = ""

		If GDate = "" Or GDate = " " Then
			
		Else
			GDate = GetDateFromLocalFormat(GDate)
		EndIf
		If GDate = "-1" Then
			Local DateFormatMessage:String
			Select Country
				Case "UK"
					DateFormatMessage = "DD/MM/YYYY"
				Case "US"
					DateFormatMessage = "MM/DD/YYYY"
				Case "EU"
					DateFormatMessage = "YYYY/MM/DD"
				Default
					CustomRuntimeError("Error 29: Invalid Country") 'MARK: Error 29
			End Select			
			MessageBox = New wxMessageDialog.Create(Null , "Invalid Date: Please enter release date as "+DateFormatMessage , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			Return
		EndIf
		If FileType(Replace(EGW.EP_EXEPath.GetValue(),Chr(34),"") ) = 0 Then
			MessageBox = New wxMessageDialog.Create(Null, "Invalid Executable: File doesn't exist. Continue?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_YES Then
				MessageBox.Free()
			Else
				MessageBox.Free()
				Return
			EndIf
			
		EndIf
		

		'info.SetId(EGW.Selection)
		'info.SetColumn(0)
		'info.SetMask(wxLIST_MASK_TEXT)
		'EGW.GameList.GetItem(info)
		
		
		Local GameNamesArray:Object[]
		GameNamesArray = ListToArray(EGW.GameRealPathList)
		GameName:String = String(GameNamesArray[EGW.Selection])
				
		'PrintF("Game info retrieved")
		'GameName = info.GetText()
		PrintF("Game name: " + GameName)
		
		GameNode:GameType = New GameType
		If GameNode.GetGame(GameName) = - 1 Then
			CustomRuntimeError("Error 34: Tryed to save game but old game data missing") 'MARK: Error 34
		EndIf
				
		Local EmuOverride:String
	
		If GlobalPlatforms.GetPlatformByName(EGW.DP_GamePlat.GetValue()).PlatType = "Folder" Then
			PrintF("Extracting EXE data")	
			GameNode.RunEXE = EGW.EP_EXEPath.GetValue()+" "+EGW.EP_CLO.GetValue()
			EmuOverride = ""
		Else
			
			If EGW.EP_EO.GetValue() = GlobalPlatforms.GetPlatformByName(EGW.DP_GamePlat.GetValue()).Emulator Then
				EmuOverride = ""
			Else
				EmuOverride = EGW.EP_EO.GetValue()
			EndIf
			
			'BaseDir = EGW.EP_EXEPath.GetValue()
			'EXE = EGW.EP_CLO.GetValue()
			
			GameNode.ROM = EGW.EP_EXEPath.GetValue()
			GameNode.ExtraCMD = EGW.EP_CLO.GetValue()
		EndIf
		
		Local col1:wxListItem , col2:wxListItem
		GameNode.OEXEsName = CreateList()
		GameNode.OEXEs = CreateList()
		Local item = -1
		Repeat
			item = EGW.EEP_LC.GetNextItem(item, wxLIST_NEXT_ALL, wxLIST_STATE_DONTCARE)
		
			If item = -1 Then Exit
			
			'Print "Item " + item + " is selected."
			'Print EditGameWin.EEP_LC.GetItemText(item)
			
			col1 = New wxListItem.Create()
			col2 = New wxListItem.Create()
			col1.SetId(item)
			col1.SetColumn(0)
			col1.SetMask(wxLIST_MASK_TEXT)
			col2.SetId(item)
			col2.SetColumn(1)
			col2.SetMask(wxLIST_MASK_TEXT)
			
			EGW.EEP_LC.GetItem(col1)
			EGW.EEP_LC.GetItem(col2)
			ListAddLast(GameNode.OEXEsName , col1.GetText() )
			ListAddLast(GameNode.OEXEs ,col2.GetText())			
		Forever
		
		
		GameNode.WatchEXEs = CreateList()
		item = -1
		Repeat
			item = EGW.A_EXEList.GetNextItem(item, wxLIST_NEXT_ALL, wxLIST_STATE_DONTCARE)
		
			If item = -1 Then Exit
			
			'Print "Item " + item + " is selected."
			'Print EditGameWin.EEP_LC.GetItemText(item)
			
			col1 = New wxListItem.Create()
			col1.SetId(item)
			col1.SetColumn(0)
			col1.SetMask(wxLIST_MASK_TEXT)
					
			EGW.A_EXEList.GetItem(col1)
			ListAddLast(GameNode.WatchEXEs , col1.GetText() )	
		Forever		
		
		BaseDir = StandardiseSlashes(BaseDir)
		
		GameNode.Name = EGW.DP_GameName.GetValue()
		GameNode.Desc = EGW.DP_GameDesc.GetValue()
		GameNode.ReleaseDate = GDate
		GameNode.Cert = GCert
		GameNode.Dev = EGW.DP_GameDev.GetValue()
		GameNode.Pub = EGW.DP_GamePub.GetValue()
		
		GameNode.Coop = GCoop
		GameNode.Players = GPlayers
		
		
		GameNode.Trailer = EGW.DP_GameVid.GetValue()	
		GameNode.PreBF =	EGW.PreBFEXEPath.GetValue()
		GameNode.PreBFWait = PreWait
		GameNode.PostBF = EGW.PostBFEXEPath.GetValue()
		GameNode.PostBFWait = PostWait
		
		GameNode.GameRunnerAlwaysOn = GRunnerAlwaysOn
		GameNode.StartWaitEnabled = GStartWaitEnabled

		GameNode.VDriveNum = EGW.AM_VDCombo.GetValue()
		GameNode.UnMount = EGW.AM_UnMountCombo.GetValue()
		GameNode.DiscImage = EGW.AM_ISOPath.GetValue()
		GameNode.Mounter = EGW.AM_MountCombo.GetValue()
		
		Local SingleGenre:String , GenreList:String , ContinueLoop:Int	
		GameNode.Genres = CreateList()
		GenreList = EGW.DP_GameGen.GetValue()+"/"
		
		Repeat
			ContinueLoop = False
			For a = 1 To Len(GenreList)
				If Mid(GenreList , a , 1) = "/" Then
					SingleGenre = Left(GenreList , a - 1)
					If SingleGenre = "" Or SingleGenre = " " Then
					
					Else
						ListAddLast(GameNode.Genres , SingleGenre )
					EndIf
					GenreList = Right(GenreList , Len(GenreList) - a)
					ContinueLoop = True
					Exit
				EndIf
			Next
			If ContinueLoop = False Then Exit
		Forever

		'ID already input
		GameNode.Rating = GRate
		'GameNode.Plat = EGW.DP_GamePlat.GetValue()
		GameNode.PlatformNum = GlobalPlatforms.GetPlatformByName(EGW.DP_GamePlat.GetValue()).ID
		GameNode.EmuOverride = EmuOverride
		
		GameNode.SaveGame()
		
	


		Local Pixmap:TPixmap',SPixmap:TPixmap
		
		If EGW.FrontBoxArt.Changed = False Or EGW.FrontBoxArt.Image = GAMEDATAFOLDER + GameName +FolderSlash+"Front_OPT.jpg" Then
		
		Else
			PrintF("Copying: Front Box Art")
			If EGW.FrontBoxArt.Image = "" Then
				DeleteFile(GAMEDATAFOLDER + GameName +FolderSlash+"Front.jpg")
			Else
				Pixmap = LoadPixmap(EGW.FrontBoxArt.Image)
				If Pixmap = Null Then CustomRuntimeError("Error 10: Front Pixmap load failed")'MARK: Error 10
				SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GameName +FolderSlash+"Front.jpg" , 100)
			EndIf
			EGW.FrontBoxArt.Changed = False
		EndIf
								
		If EGW.BackBoxArt.Changed = False Or EGW.BackBoxArt.Image = GAMEDATAFOLDER + GameName +FolderSlash+"Back_OPT.jpg" Then
		
		Else
			PrintF("Copying: Back Box Art")


			If EGW.BackBoxArt.Image = "" Then
				DeleteFile(GAMEDATAFOLDER + GameName +FolderSlash+"Back.jpg")
			Else
				Pixmap = LoadPixmap(EGW.BackBoxArt.Image)
				If Pixmap = Null Then CustomRuntimeError("Error 10: Back Pixmap load failed")'MARK: Error 10
				SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GameName +FolderSlash+"Back.jpg" , 100)
			EndIf
			EGW.BackBoxArt.Changed = False
			
		EndIf
		
		If EGW.BackGroundArt.Changed = False Or EGW.BackGroundArt.Image = GAMEDATAFOLDER + GameName +FolderSlash+"Screen_OPT.jpg" Then
		
		Else
			PrintF("Copying: Screen Art")
			
			If EGW.BackGroundArt.Image = "" Then
				DeleteFile(GAMEDATAFOLDER + GameName +FolderSlash+"Screen.jpg")
			Else
				Pixmap = LoadPixmap(EGW.BackGroundArt.Image)
				If Pixmap = Null Then CustomRuntimeError("Error 10: Screen Pixmap load failed")'MARK: Error 10
				SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GameName +FolderSlash+"Screen.jpg" , 100)
			EndIf
			EGW.BackGroundArt.Changed = False
		EndIf		

		If EGW.BannerArt.Changed = False Or EGW.BannerArt.Image = GAMEDATAFOLDER + GameName +FolderSlash+"Banner_OPT.jpg" Then
		
		Else
			PrintF("Copying: Banner Art")
			If EGW.BannerArt.Image = "" Then
				DeleteFile(GAMEDATAFOLDER + GameName +FolderSlash+"Banner.jpg")
			Else			
				Pixmap = LoadPixmap(EGW.BannerArt.Image)
				If Pixmap = Null Then CustomRuntimeError("Error 10: Banner Pixmap load failed")'MARK: Error 10
				SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GameName +FolderSlash+"Banner.jpg")
			EndIf
			EGW.BannerArt.Changed = False
		EndIf	
		
		If EGW.IconArt.Changed = False Or EGW.IconArt.Image = GAMEDATAFOLDER + GameName +FolderSlash+"Icon.ico" Then
		
		Else
			PrintF("Copying: Icon Art")
			If EGW.IconArt.Image = "" then
				DeleteFile(GAMEDATAFOLDER + GameName +FolderSlash+"Icon.ico")
			Else			
				CopyFile(EGW.IconArt.Image , GAMEDATAFOLDER + GameName +FolderSlash+"Icon.ico")
			EndIf
			EGW.IconArt.Changed = False
		EndIf	
		
		GameNode.OptimizeArtwork()		
		
		PrintF("Update Game List")
		EGW.DataChanged = False
		EGW.SaveButton.Disable()
		EGW.PopulateGameList()
		If ShowUselessNotifys=True Then
			MessageBox = New wxMessageDialog.Create(Null , "Game Saved" , "Info" , wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()			
		EndIf
		EGW.GameList.SetitemState(EGW.Selection , wxLIST_STATE_SELECTED , wxLIST_MASK_TEXT | wxLIST_MASK_IMAGE )	
		EGW.Refresh()
	End Function
	
	Function DataChangeUpdate(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local Path:String
		If EditGameWin.DataChanged = True Then
		
		Else
			PrintF("Data Changed True")
		EndIf
		EditGameWin.DataChanged = True
		EditGameWin.SaveButton.Enable()
		If GlobalPlatforms.GetPlatformByName(EditGameWin.DP_GamePlat.GetValue()).PlatType = "Folder" Then
		
		Else
			If EditGameWin.EP_EO.GetValue() = GlobalPlatforms.GetPlatformByName(EditGameWin.DP_GamePlat.GetValue() ).Emulator Or EditGameWin.EP_EO.GetValue() = "" then
				If GlobalPlatforms.GetPlatformByName(EditGameWin.DP_GamePlat.GetValue() ).Emulator = "" then
					EditGameWin.EP_EO_DT.SetLabel("(Default emulator for this platform not set! Goto 'Platform' tab of main menu to set one.)")
				Else
					EditGameWin.EP_EO_DT.SetLabel("(Default Emulator)")
				EndIf
			Else
				EditGameWin.EP_EO_DT.SetLabel("")
			EndIf
		EndIf
		
	End Function
	
	Function DataChangeUpdateExt(EditGameWin:EditGameList)
		If EditGameWin.DataChanged = True Then
		
		Else
			PrintF("Data Changed True")
		EndIf
		EditGameWin.DataChanged = True
		EditGameWin.SaveButton.Enable()
		If GlobalPlatforms.GetPlatformByName(EditGameWin.DP_GamePlat.GetValue()).PlatType = "Folder" Then
		
		Else
			If EditGameWin.EP_EO.GetValue() = GlobalPlatforms.GetPlatformByName(EditGameWin.DP_GamePlat.GetValue() ).Emulator Or EditGameWin.EP_EO.GetValue() = "" then
				EditGameWin.EP_EO_DT.SetLabel("(Default Emulator)")
			Else
				EditGameWin.EP_EO_DT.SetLabel("")
			EndIf
		EndIf
		
	End Function	
	
	Function DeleteSelection(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local MessageBox2:wxMessageDialog
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local item:Int = - 1
		Local GameNamesArray:Object[] = ListToArray(EditGameWin.GameRealPathList)
		Local DeleteMessage:String = "Are you sure you wish to delete: "
		Local GameNode:GameType
		Local GameName:String
		Local DeleteList:TList = CreateList()
		
		Repeat
			item = EditGameWin.GameList.GetNextItem(item, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED)
			If item = - 1 then Exit
			DeleteMessage = DeleteMessage + "~n" + String(GameNamesArray[item])
			ListAddLast(DeleteList, String(item) )
		Forever
		
		item = - 1
		PrintF(DeleteMessage)
		MessageBox = New wxMessageDialog.Create(Null, DeleteMessage , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES then
			Local DeleteCount = 0
			For itemString:String = EachIn DeleteList
				item = Int(itemString)
				GameName = String(GameNamesArray[item])
				PrintF(GameName)
				GameNode = New GameType
				GameNode.GetGame(GameName)	
				GameNode.DeleteGame()
				GameNode = Null
					
				EditGameWin.GameList.DeleteItem(item - DeleteCount)
				EditGameWin.SubGamePanel2.Disable()
				EditGameWin.GameRealPathList.Remove(GameName )
				
				DeleteCount = DeleteCount + 1	
			Next 	
			'EditGameWin.PopulateGameList()
			MessageBox2 = New wxMessageDialog.Create(Null, "Game deleted successfully", "Info", wxOK)
			MessageBox2.ShowModal()
			MessageBox2.Free()
		Else
			PrintF("Delete Canceled")	
		EndIf
		MessageBox.Free()
	End Function

	Function ShowAGM(event:wxEvent)
		Local MainWin:MainWindow = EditGameList(event.parent).ParentWin
		MainWin.AddGamesMenuField.Show()		
		MainWin.EditGameListField.Hide()
	End Function

	Function GameListUpdate(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		EditGameWin.UpdateListTimer.Start(1000,True)
	End Function
	
	Function GameListUpdateTimer(event:wxEvent)
		PrintF("----------------------------Updating Game List----------------------------")	
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		EditGameWin.PopulateGameList()
	End Function

	Function ShowMainMenu(event:wxEvent)
		Local MainWin:MainWindow = EditGameList(event.parent).ParentWin
		Local EGW:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog
		If EGW.DataChanged = 1 then
			PrintF("Clear Changes? (EXIT)")
			MessageBox = New wxMessageDialog.Create(Null, "You have unsaved changes, are you sure you wish to clear them?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				PrintF("Changes Not Cleared")
				MessageBox.Free()
				EGW.DataChanged = 1
				Return
			Else
				PrintF("Changes Cleared")
				MessageBox.Free()
				EGW.DataChanged = 0
				EGW.SaveButton.Disable()
			EndIf
		EndIf
		
		MainWin.Show()
		
		MainWin.EditGameListField.FrontBoxArt.Destroy()
		MainWin.EditGameListField.FrontBoxArt = Null 
		MainWin.EditGameListField.BackBoxArt.Destroy()
		MainWin.EditGameListField.BackBoxArt = Null 
		MainWin.EditGameListField.BackGroundArt.Destroy()
		MainWin.EditGameListField.BackGroundArt = Null 
		MainWin.EditGameListField.BannerArt.Destroy()
		MainWin.EditGameListField.BannerArt = Null 
		MainWin.EditGameListField.IconArt.Destroy()
		MainWin.EditGameListField.IconArt = Null 
				
		MainWin.EditGameListField.Destroy()
		MainWin.EditGameListField = Null
		
		
	End Function
	
	Function EXEBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		?Win32
		Local temp:String 	
		?Not Win32
		Local openFileDialog:wxFileDialog
		?
		
		If EditGameWin.EP_EXE_Text.GetLabel() = "Rom Path: " Then 
			?Not Win32	
			openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose the game rom" , ExtractDir(EditGameWin.EP_EXEPath.GetValue()) , "" , "All files (*)|*" , wxFD_OPEN , -1 , -1 , -1 , -1)
			If openFileDialog.ShowModal() = wxID_OK Then
				EditGameWin.EP_EXEPath.ChangeValue(Chr(34)+openFileDialog.GetPath()+Chr(34))
				DataChangeUpdate(event)
			End If	
			
			?Win32
			temp:String = RequestFile( "Choose the game rom" , "All files (*.*): *"  , False , ExtractDir(EditGameWin.EP_EXEPath.GetValue()))
			If temp="" Then
			
			Else
				EditGameWin.EP_EXEPath.ChangeValue(Chr(34)+temp+Chr(34))
				DataChangeUpdate(event)
			EndIf
			?		
		Else
			?Not Win32	
			openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose the game executable" , ExtractDir(EditGameWin.EP_EXEPath.GetValue()) , "" , "All files (*)|*" , wxFD_OPEN , -1 , -1 , -1 , -1)
			If openFileDialog.ShowModal() = wxID_OK Then
				EditGameWin.EP_EXEPath.ChangeValue(Chr(34)+openFileDialog.GetPath()+Chr(34))
				DataChangeUpdate(event)
			End If	
			
			?Win32
			temp:String = RequestFile( "Choose the game executable" , "EXE files (*.exe):exe;All files (*.*): *"  , False , ExtractDir(EditGameWin.EP_EXEPath.GetValue()))
			If temp="" Then
			
			Else
				EditGameWin.EP_EXEPath.ChangeValue(Chr(34)+temp+Chr(34))
				DataChangeUpdate(event)
			EndIf
			?
		EndIf 
	End Function

	Function PreBatchBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)		
		?Not Win32	
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose Pre Game Batch File" , ExtractDir(EditGameWin.PreBFEXEPath.GetValue()) , "" , "All files (*)|*" , wxFD_OPEN , -1 , -1 , -1 , -1)
		If openFileDialog.ShowModal() = wxID_OK Then
			EditGameWin.PreBFEXEPath.ChangeValue(Chr(34)+openFileDialog.GetPath()+Chr(34))
			DataChangeUpdate(event)
		End If	
		
		?Win32	
		Local temp:String = RequestFile( "Choose Pre Game Batch File" , "BAT files (*.bat):bat;All files (*.*): *"  , False , ExtractDir(EditGameWin.PreBFEXEPath.GetValue()))
		If temp="" Then
		
		Else
			EditGameWin.PreBFEXEPath.ChangeValue(Chr(34)+temp+Chr(34))
			DataChangeUpdate(event)
		EndIf
		?
	End Function	
	
	Function PostBatchBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)		
		?Not Win32	
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose Post Game Batch File" , ExtractDir(EditGameWin.PostBFEXEPath.GetValue()) , "" , "All files (*)|*" , wxFD_OPEN , -1 , -1 , -1 , -1)
		If openFileDialog.ShowModal() = wxID_OK Then
			EditGameWin.PostBFEXEPath.ChangeValue(Chr(34)+openFileDialog.GetPath()+Chr(34))
			DataChangeUpdate(event)
		End If	
		?Win32	
		Local temp:String = RequestFile( "Choose Post Game Batch File" , "BAT files (*.bat):bat;All files (*.*): *"  , False , ExtractDir(EditGameWin.PostBFEXEPath.GetValue()))
		If temp="" Then
		
		Else
			EditGameWin.PostBFEXEPath.ChangeValue(Chr(34)+temp+Chr(34))
			DataChangeUpdate(event)
		EndIf
		?
	End Function
	
	Function DiscImageBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)		
		
		?Not Win32	
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose Disc Image" , ExtractDir(EditGameWin.AM_ISOPath.GetValue()) , "" , "All files (*)|*" , wxFD_OPEN , -1 , -1 , -1 , -1)
		If openFileDialog.ShowModal() = wxID_OK Then
			EditGameWin.AM_ISOPath.ChangeValue(openFileDialog.GetPath())
			DataChangeUpdate(event)
		End If	
		?Win32	
			
		Local temp:String = RequestFile( "Choose Disc Image" , "All files (*.*): *"  , False , ExtractDir(EditGameWin.AM_ISOPath.GetValue()))
		If temp="" Then
		
		Else
			EditGameWin.AM_ISOPath.ChangeValue(temp)
			DataChangeUpdate(event)
		EndIf
		?
	End Function	
	
	Function MounterBrowse(event:wxEvent)
		Local MessageBox:wxMessageDialog 
		Local EditGameWin:EditGameList = EditGameList(event.parent)		
		Local EXE:String = EditGameWin.Mounter.MounterEXE
		Local temp:String 
		?Not Win32	
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose Disc Image" , ExtractDir(EditGameWin.AM_MPath.GetValue()) , "" , "Mounter ("+EXE+")|*" , wxFD_OPEN , -1 , -1 , -1 , -1)
		If openFileDialog.ShowModal() = wxID_OK Then
			temp = openFileDialog.GetPath()
		End If	
		?Win32	
		temp = RequestFile( "Choose Disc Image" , "Mounter ("+EXE+"): *"  , False , ExtractDir(EditGameWin.AM_MPath.GetValue()))
		?
		If temp="" Then
		
		Else
			If StripDir(temp)=EXE Then 
				EditGameWin.AM_MPath.ChangeValue(temp)
				DataChangeUpdate(event)
			Else
				MessageBox = New wxMessageDialog.Create(Null, "Please select a valid mounter file: "+EXE, "Error", wxOK)
				MessageBox.ShowModal()
				MessageBox.Free()				
				MounterBrowse(event)
			EndIf
		EndIf
	End Function		
	
	Function EEXEBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)		
		Local temp:String
		?Not Win32	
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose the game executable" , ExtractDir(EditGameWin.EP_EXEPath.GetValue() ) , "" , "All files (*)|*" , wxFD_OPEN , - 1 , - 1 , - 1 , - 1)
		If openFileDialog.ShowModal() = wxID_OK Then
			temp = openFileDialog.GetPath()
		End If	
		?Win32
		temp = RequestFile( "Choose the game executable" , "EXE files (*.exe):exe;All files (*.*): *" , False , ExtractDir(EditGameWin.EP_EXEPath.GetValue() ) )
		?
		If temp="" Then
		
		Else
			EditGameWin.EEP_EXEPath.ChangeValue(Chr(34)+temp+Chr(34))
			If EditGameWin.EEP_EXEName.GetValue() = "" Or EditGameWin.EEP_EXEName.GetValue() = " " Then
				EditGameWin.EEP_EXEName.ChangeValue(StripDir(StripExt(temp)))
			EndIf
		EndIf
	End Function	
	
	Function FrontDelete(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		EditGameWin.NewFBArt = ""
		EditGameWin.FrontBoxArt.SetImage("" )
		EditGameWin.FrontBoxArt.Changed = True
		EditGameWin.Refresh()
		DataChangeUpdate(event)
		
	End Function
	
	Function FrontBoxBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local temp:String 
		?Not Win32	
		Local openFileDialog2:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose front box art" , EditGameWin.NewFBArt , "" , "Image files (*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png)|*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png" )
		If openFileDialog2.ShowModal() = wxID_OK Then
			temp = openFileDialog2.GetPath()
		End If	
		?Win32
		temp = RequestFile( "Choose front box art" , "Image files (*.jpg *.jpeg *.bmp *.gif *.tiff *.png):jpg,jpeg,bmp,gif,tiff,png;All files (*.*): *"  , False , EditGameWin.NewFBArt)
		?
		If temp="" Then
		
		Else
			EditGameWin.NewFBArt = temp
			EditGameWin.FrontBoxArt.SetImage(temp )
			EditGameWin.FrontBoxArt.Changed = True
			EditGameWin.Refresh()
			DataChangeUpdate(event)
		EndIf
		?		
	End Function
	
	Function FrontBoxBrowseMain(event:wxEvent)
		Local IPanel:ImagePanel = ImagePanel(event.parent)
		Local EditGameWin:EditGameList = IPanel.EditGameWin
		Local temp:String 
		?Not Win32
		Local openFileDialog2:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose front box art" , EditGameWin.NewFBArt , "" , "Image files (*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png)|*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png" )
		If openFileDialog2.ShowModal() = wxID_OK Then
			temp = openFileDialog2.GetPath()
		End If	
		?Win32
		
		temp = RequestFile( "Choose front box art" , "Image files (*.jpg *.jpeg *.bmp *.gif *.tiff *.png):jpg,jpeg,bmp,gif,tiff,png;All files (*.*): *"  , False , EditGameWin.NewFBArt)
		?
		If temp="" Then
		
		Else
			EditGameWin.NewFBArt = temp
			EditGameWin.FrontBoxArt.SetImage(temp )
			EditGameWin.FrontBoxArt.Changed = True
			EditGameWin.Refresh()
			DataChangeUpdate(event)
		EndIf		
	End Function	
	
	Function BackDelete(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		EditGameWin.NewBBArt = ""
		EditGameWin.BackBoxArt.SetImage("" )
		EditGameWin.BackBoxArt.Changed = True
		EditGameWin.Refresh()
		DataChangeUpdate(event)				
	End Function
	
	Function WEXEAddF(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local SelectedFile:String
		'Local MessageBox:wxMessageDialog	
		
		
		?Not Win32		
		Local openFileDialog:wxDirDialog = New wxDirDialog.Create(EditGameWin, "Select Folder" , Null , wxDD_DIR_MUST_EXIST)	
		If openFileDialog.ShowModal() = wxID_OK Then
			SelectedFile = openFileDialog.GetPath()
		EndIf	
		?Win32
		SelectedFile = RequestDir("Select Folder" , Null )
		?

		If SelectedFile="" Or SelectedFile=" " Then 
		
		Else		
			?Win32
			EditGameWin.A_EXEList.InsertStringItem( 0 , SelectedFile  )
			?Not Win32
			EditGameWin.A_EXEList.InsertStringItem( 0 , SelectedFile  )
			?
			DataChangeUpdate(event)
		EndIf 
	
	End Function
	
	Function WEXEAddE(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local SelectedFile:String	

		?Not Win32		
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose executable" , Null , "" , "*.*")
	
		If openFileDialog.ShowModal() = wxID_OK Then
			SelectedFile = openFileDialog.GetPath()
		End If	
		?Win32
		SelectedFile = RequestFile( "Choose executable" , "EXE files (*.exe):exe;All files (*.*): *"  , False , Null)
		?
		
		If SelectedFile="" Or SelectedFile=" " Then 
		
		Else		
			?Win32
			EditGameWin.A_EXEList.InsertStringItem( 0 , SelectedFile )
			?Not Win32
			EditGameWin.A_EXEList.InsertStringItem( 0 , SelectedFile  )
			?
			DataChangeUpdate(event)
		EndIf 

	
	
	End Function 
	
	Function WEXEDelete(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog
		
		If EditGameWin.A_EXEList.GetSelectedItemCount() = 0 Then
			PrintF("GameList Returned: -1")
			MessageBox = New wxMessageDialog.Create(Null, "Please select an executable/folder to delete", "Info", wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()		
			Return 
		EndIf
		
		Local item = -1
		Repeat
			item = EditGameWin.A_EXEList.GetNextItem(item, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED)
		
			If item = -1 Then Exit
			
			EditGameWin.A_EXEList.DeleteItem(item)
			DataChangeUpdate(event)			
		Forever
	End Function
	
	Function EEXEAdd(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog

		Local Value:String = EditGameWin.EEP_EXEPath.GetValue()
		Local Value2:String = EditGameWin.EEP_EXEName.GetValue()
		Local Index:Int
		
		If Value = "" Or Value = " " then
			PrintF("EXE Path empty")
			MessageBox = New wxMessageDialog.Create(Null, "Please browse or enter an executable to add to list", "Info", wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()		
			Return 		
		ElseIf Value2 = "" Or Value2 = " " Then
			PrintF("EXE Name empty")
			MessageBox = New wxMessageDialog.Create(Null, "Please select a name for the executable", "Info", wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()		
			Return 		
		else
			Index = EditGameWin.EEP_LC.InsertStringItem( 0 , Value2 )

			EditGameWin.EEP_LC.SetStringItem(Index , 1 , Value )
	
		
			EditGameWin.EEP_EXEName.ChangeValue("")
			EditGameWin.EEP_EXEPath.ChangeValue("")
			DataChangeUpdate(event)				
		EndIf
		

	End Function
	
	Function EEXESelect(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		If EditGameWin.EEP_LC.GetSelectedItemCount() = 1 Then
			item = EditGameWin.EEP_LC.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
			Local info:wxListItem = New wxListItem.Create()
			Local info2:wxListItem = New wxListItem.Create()			
			info.SetId(item)
			info.SetColumn(0)
			info.SetMask(wxLIST_MASK_TEXT)
			info2.SetId(item)
			info2.SetColumn(1)
			info2.SetMask(wxLIST_MASK_TEXT)			
			EditGameWin.EEP_LC.GetItem(info)
			EditGameWin.EEP_LC.GetItem(info2)	
			EditGameWin.EEP_EXEName.ChangeValue(info.GetText())
			EditGameWin.EEP_EXEPath.ChangeValue(info2.GetText())			
		EndIf			
	End Function
	
	Function EEXEDelete(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local MessageBox:wxMessageDialog
		
		If EditGameWin.EEP_LC.GetSelectedItemCount() = 0 Then
			PrintF("GameList Returned: -1")
			MessageBox = New wxMessageDialog.Create(Null, "Please select an executable to delete", "Info", wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()		
			Return 
		EndIf
		
		Local item = -1
		Repeat
			item = EditGameWin.EEP_LC.GetNextItem(item, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED)
		
			If item = -1 Then Exit
			
			EditGameWin.EEP_LC.DeleteItem(item)
			DataChangeUpdate(event)
			'Print "Item " + item + " is selected."
			'Print EditGameWin.EEP_LC.GetItemText(item)
			
			'Local info:wxListItem = New wxListItem.Create()
			'info.SetId(item)
			'info.SetColumn(1)
			'info.SetMask(wxLIST_MASK_TEXT)
			'EditGameWin.EEP_LC.GetItem(info)
			'print info.GetText()				
		Forever
		
	End Function
	
	Function BackBoxBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local temp:String 
		?Not Win32		
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose back box art" , EditGameWin.NewBBArt , "" , "Image files (*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png)|*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png")

		If openFileDialog.ShowModal() = wxID_OK Then
			temp = openFileDialog.GetPath()
		End If	
		?Win32
		temp = RequestFile( "Choose back box art" , "Image files (*.jpg *.jpeg *.bmp *.gif *.tiff *.png):jpg,jpeg,bmp,gif,tiff,png;All files (*.*): *"  , False , EditGameWin.NewBBArt)
		?
		If temp="" Then
		
		Else
			EditGameWin.NewBBArt = temp
			EditGameWin.BackBoxArt.SetImage(temp )
			EditGameWin.BackBoxArt.Changed = True
			EditGameWin.Refresh()
			DataChangeUpdate(event)
		EndIf
		
	End Function	
	
	Function BannerDelete(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		EditGameWin.NewBArt = ""
		EditGameWin.BannerArt.SetImage("")
		EditGameWin.BannerArt.Changed = True
		EditGameWin.Refresh()
		DataChangeUpdate(event)
	End Function
	
	Function BannerBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local temp:String 
		?Not Win32
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose banner art" , EditGameWin.NewBArt , "" , "Image files (*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png)|*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png")

		If openFileDialog.ShowModal() = wxID_OK Then
			temp = openFileDialog.GetPath()
		End If	
		?Win32

		temp = RequestFile( "Choose banner art" , "Image files (*.jpg *.jpeg *.bmp *.gif *.tiff *.png):jpg,jpeg,bmp,gif,tiff,png;All files (*.*): *"  , False , EditGameWin.NewBArt)
		?
		If temp="" Then
		
		Else
			EditGameWin.NewBArt = temp
			EditGameWin.BannerArt.SetImage(temp )
			EditGameWin.BannerArt.Changed = True
			EditGameWin.Refresh()
			DataChangeUpdate(event)
		EndIf		
		
	End Function	
	
	Function BackgroundDelete(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		EditGameWin.NewBGArt = ""
		EditGameWin.BackGroundArt.SetImage("" )
		EditGameWin.BackGroundArt.Changed = True
		EditGameWin.Refresh()
		DataChangeUpdate(event)
	End Function
	
	Function BackgroundBrowse(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local temp:String
		?Not Win32
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose background art" , EditGameWin.NewBGArt , "" , "Image files (*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png)|*.jpg;*.jpeg;*.bmp;*.gif;*.tiff;*.png")

		If openFileDialog.ShowModal() = wxID_OK Then
			temp = openFileDialog.GetPath()
		End If	
		?Win32
		temp = RequestFile( "Choose background art" , "Image files (*.jpg *.jpeg *.bmp *.gif *.tiff *.png):jpg,jpeg,bmp,gif,tiff,png;All files (*.*): *"  , False , EditGameWin.NewBGArt)
		?
		If temp="" Then
		
		Else
			EditGameWin.NewBGArt = temp
			EditGameWin.BackGroundArt.SetImage(temp )
			EditGameWin.BackGroundArt.Changed = True
			EditGameWin.Refresh()
			DataChangeUpdate(event)
		EndIf		
		
	End Function
	
	Function IconExtract(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local File:String , temp:String
		Local MessageBox:wxMessageDialog
		'Local image:TFreeImage
		Local EXEPath:String = EditGameWin.EP_EXEPath.GetValue()
		EXEPath = Replace(EXEPath,Chr(34),"")
		DeleteCreateFolder(TEMPFOLDER + "Icons")
		DeleteCreateFolder(TEMPFOLDER + "Icons2")
		Local ExtractIcon:TProcess = CreateProcess(ResourceExtractPath + " /Source " + Chr(34) + StandardiseSlashes(EXEPath) + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons" + FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1")
		Repeat
			Delay 10
			If ProcessStatus(ExtractIcon) = 0 then Exit
		Forever	
		
		ReadIcons = ReadDir(TEMPFOLDER + "Icons"+FolderSlash)
		temp = ""
		Repeat
			File = NextFile(ReadIcons)
			If File = "" Then Exit
			If File = "." Or File = ".." then Continue
			If ExtractExt(File) = "ico" Then
				temp = TEMPFOLDER + "Icons"+FolderSlash + File
				Exit			
			EndIf
		Forever
		CloseDir(ReadIcons)		
		
		If temp = "" Then
			MessageBox = New wxMessageDialog.Create(Null , "Could not extract an icon from the executable" , "Error" , wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()
		Else

			EditGameWin.NewIArt = temp
			EditGameWin.IconArt.SetImage(temp )
			EditGameWin.IconArt.Changed = True
			EditGameWin.Refresh()
			DataChangeUpdate(event)			
		EndIf
'		EndRem
	End Function
	
	Function SteamIconBrowse(event:wxEvent)
		
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local SteamIconOrCustom:Int = False 	
		Local ExtractIconEXE:String = EditGameWin.EP_EXEPath.GetValue()
		Local MessageBox:wxMessageDialog
		
		ExtractIconEXE = Replace(ExtractIconEXE, Chr(34), "")
		
		Local info:wxListItem = New wxListItem.Create()
		info.SetId(EditGameWin.Selection )
		info.SetColumn(0)
		info.SetMask(wxLIST_MASK_TEXT)
		EditGameWin.GameList.GetItem(info)
		Local GameTitle:String = info.GetText()		

		PrintF( GameTitle)
		If FileType(ExtractIconEXE) = 1 Then 
		
		Else
			MessageBox = New wxMessageDialog.Create(Null , "Invalid Steam Folder" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return		
		EndIf 
		
		If Lower(StripDir(ExtractIconEXE) ) = "steam.exe" Then
		
		Else
			MessageBox = New wxMessageDialog.Create(Null , "This is not a steam game" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return 
		EndIf
		
	
		If FileType(TEMPFOLDER+"SteamIcons") = 0 Then
			MessageBox = New wxMessageDialog.Create(Null , "About to update Icons, it may take some time please be patient..."+Chr(10)+"Press Ok to continue" , "Info" , wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()	
			ExtractSteamIcons(ExtractDir(ExtractIconEXE), 0)
		EndIf
		
		Local SteamIconWindowField:SteamIconWindow = SteamIconWindow(New SteamIconWindow.Create(EditGameWin , wxID_ANY , "Choose Icon for: "+GameTitle , , , 700 , 500) )					
		SteamIconWindowField.SteamFolder = ExtractDir(ExtractIconEXE)
		SteamIconWindowField.GameFolder = GAMEDATAFOLDER + GameTitle	
		SteamIconWindowField.GameType = 2
	
		EditGameWin.Disable()
	End Function
	
	Function IconDelete(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		EditGameWin.NewIArt = ""
		EditGameWin.IconArt.SetImage("" )
		EditGameWin.IconArt.Changed = True
		EditGameWin.Refresh()
		DataChangeUpdate(event)
	End Function
	
	Function IconBrowse(event:wxEvent)
'		Rem
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local File:String
'		Local image:TFreeImage
		Local MessageBox:wxMessageDialog
		Local temp:String

		?Not Win32
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EditGameWin, "Choose icon art" , EditGameWin.NewIArt , "" , "Icon files (*.ico)|*.ico")

		If openFileDialog.ShowModal() = wxID_OK Then
			temp = openFileDialog.GetPath()
		End If
		?Win32	
		temp = RequestFile( "Choose icon art" , "Icon files/Icon Resources (*.ico *.exe *.dll):ico,exe,dll"  , False , EditGameWin.NewIArt)
		?
		If temp="" Then
		
		Else
			If Lower(Right(temp , 3) ) = "exe" Or Lower(Right(temp , 3) ) = "dll" Then
				?Win32	
				DeleteCreateFolder(TEMPFOLDER + "Icons")
				DeleteCreateFolder(TEMPFOLDER + "Icons2")
				Local ExtractIcon:TProcess = CreateProcess(ResourceExtractPath + " /Source " + Chr(34) + StandardiseSlashes(temp) + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons"+FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1")
				Repeat
					Delay 10
					If ProcessStatus(ExtractIcon)=0 Then Exit
				Forever	
				
				ReadIcons = ReadDir(TEMPFOLDER + "Icons"+FolderSlash)
				temp = ""
				Repeat
					File = NextFile(ReadIcons)
					If File="." Or File=".." Then Continue
					If File = "" Then Exit
					If Lower(ExtractExt(File)) = "ico" Then
						temp = TEMPFOLDER + "Icons"+FolderSlash + File
						Exit
					EndIf
				Forever
				CloseDir(ReadIcons)	
				If temp = "" Then
					MessageBox = New wxMessageDialog.Create(Null , "Could not find any icons in the resource" , "Error" , wxOK | wxICON_EXCLAMATION)
					MessageBox.ShowModal()
					MessageBox.Free()	
				Else
					EditGameWin.NewIArt = temp
					EditGameWin.IconArt.SetImage(temp )
					EditGameWin.IconArt.Changed = True
					EditGameWin.Refresh()
					DataChangeUpdate(event)				
				EndIf
				?				
			Else
				EditGameWin.NewIArt = temp
				EditGameWin.IconArt.SetImage(temp )
				EditGameWin.IconArt.Changed = True
				EditGameWin.Refresh()
				DataChangeUpdate(event)
			EndIf
		EndIf			
	End Function		
	
	Function UpdateGame(event:wxEvent)

		Local MessageBox:wxMessageDialog
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		
		Local GameFileRead:TStream
		Local GameID:Int
		Local GameBaseDir:String
		Local GameEXE:String
		Local GamePlat:String
		Local GameUpdateMode:Int = - 1
		If CheckInternet() = 0 then
			PrintF("Not Connected to Internet")
			MessageBox = New wxMessageDialog.Create(Null, "You are not connected to the internet.", "Error", wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return 					
		EndIf
		
		If EditGameWin.Selection = - 1 then
			PrintF("GameList Returned: -1, Update Pressed")
			MessageBox = New wxMessageDialog.Create(Null, "Please select a game to Update", "Info", wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()			
		Else	
			PrintF("GameList Returned: " + EditGameWin.Selection)
			'EditGameWin.Disable()
			Local GameNamesArray:Object[]
			GameNamesArray = ListToArray(EditGameWin.GameRealPathList)
			Local GameName:String = String(GameNamesArray[EditGameWin.Selection])
			
			Local GameNode:GameType = New GameType
			PrintF("GameList Selection: " + GameName)

			If GameNode.GetGame(GameName) = - 1 then
				CustomRuntimeError("Error 4: Unable to find info.txt in UpdateGame") 'MARK: Error 4			
			Else
				PrintF("Reading Info File")

				
				If GameNode.LuaFile = Null Or GameNode.LuaFile = "" Or GameNode.LuaIDData = Null Or GameNode.LuaIDData = "" then
					PrintF("ID=0: Message Shown End Loop")
					MessageBox = New wxMessageDialog.Create(Null , "This game was added manually, please select a game added via the online database to use the update feature" , "Info" , wxOK)
					MessageBox.ShowModal()
					MessageBox.Free()						
				Else
					PrintF("Overwrite Dialog")
					MessageBox = New wxMessageDialog.Create(Null, "Would you like to overwrite old files?"+Chr(10)+" Yes - redownloads all game artwork"+Chr(10)+" No - download new artwork only" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
					If MessageBox.ShowModal() = wxID_YES Then
						PrintF("Overwrite True")
						GameNode.OverideArtwork = 1
					Else
						PrintF("Overwrite False")
						GameNode.OverideArtwork = 0
					EndIf
					MessageBox.Free()	
					PrintF("Running Main Update Function")				
					
					
					?Threaded
					Local UpdateGameThread:TThread = CreateThread(Thread_UpdateGame, GameNode)
					While UpdateGameThread.Running()
						DatabaseApp.Yield()
						Delay 100
					Wend
					?Not Threaded
					Thread_UpdateGame(GameNode)
					?					
								

					
					MessageBox = New wxMessageDialog.Create(Null , "Game Successfully Updated" , "Info" , wxOK)
					MessageBox.ShowModal()
					MessageBox.Free()	
				EndIf	
				
				GameNode = Null
				
				'EditGameWin.Enable()
				'EditGameWin.ParentWin.ResetEditGameWindow()
				EditGameWin.UpdateSelection(event)

			EndIf					
		EndIf
	End Function

	Function UpdateAllGames(event:wxEvent)
		Local EditGameWin:EditGameList = EditGameList(event.parent)
		Local item:Int = - 1
		Local GameNamesArray:Object[] = ListToArray(EditGameWin.GameRealPathList)
		Local UpdateList:TList = CreateList()
		Local MessageBox:wxMessageDialog
		
		Repeat
			item = EditGameWin.GameList.GetNextItem(item, wxLIST_NEXT_ALL, wxLIST_STATE_DONTCARE)
			If item = - 1 then Exit
			ListAddLast(UpdateList, String(GameNamesArray[item]) )
		Forever		
		
		If CheckInternet() = 0 then
			PrintF("Not Connected to Internet")
			MessageBox = New wxMessageDialog.Create(Null, "You are not connected to the internet.", "Error", wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return 					
		EndIf
		
		
		EditGameWin.Hide()
		?Threaded
		Local UpdateAllGamesThread:TThread = CreateThread(Thread_UpdateAllGames, UpdateList)
		While UpdateAllGamesThread.Running()
			DatabaseApp.Yield()
			Delay 100
		Wend
		?Not Threaded
		Thread_UpdateAllGames(UpdateList)
		?
		EditGameWin.Show()
	End Function

	Function OnQuit(event:wxEvent)
		' true is to force the frame to close
		wxWindow(event.parent).Close(True)
	End Function
End Type

Type ImageBase Extends wxPanel
	Field EditGameWin:EditGameList
	Field Image:String
	Field Changed:Int
	Field ImageType:Int
	Field ClickCount:Int
	Field DoubleClickTimer:Int
	'1: Front
	'2: Back
	'3: Fanart
	'4: Banner
	'5: Icon

	Method OnInit()
		ClickCount = 0
		DoubleClickTimer = 0
		Image = ""
		Changed = False
		ConnectAny(wxEVT_PAINT , OnPaint)
		'ConnectANY( wxEVT_RIGHT_DOWN , ImageRightClickedFun)		
		'ConnectANY( wxEVT_LEFT_DCLICK , ImageLeftClickedFun)
	End Method
	
	Method SetImageType(ImageT:Int)
		If ImageT > 5 Or ImageT < 1 Then
			CustomRuntimeError("Error 25: Wrong ImageType") 'MARK: Error 25
		EndIf
		ImageType = ImageT
	End Method
		
	Method SetImage(Bitmap:String)
		Self.Image = Bitmap
	End Method
		
	Function OnPaint(event:wxEvent)
		
		Local canvas:ImageBase = ImageBase(event.parent)
		
		canvas.Refresh()
		
		Local dc:wxPaintDC = New wxPaintDC.Create(canvas)
		canvas.PrepareDC(dc)
		Local x,x2,x3:Int
		Local y , y2 , y3:Int
		Local HWratio:Float
		Local WHratio:Float

			
		dc.Clear()
		canvas.GetClientSize(x,y)
		dc.SetBackground(New wxBrush.CreateFromColour(New wxColour.Create(240,240,240), wxSOLID))
		dc.Clear()
		dc.SetTextForeground(New wxColour.Create(0,0,0))
		Local NoLen:Int, ArtworkLen:Int, FoundLen:Int
		If canvas.Image = ""
			'dc.GetTextExtent("No Artwork Found" , x2 , y2)			
			dc.GetTextExtent("No" , NoLen , y2)
			dc.GetTextExtent("Artwork" , ArtworkLen , y2)
			dc.GetTextExtent("Found" , FoundLen , y2)						
			dc.DrawText("No" , x / 2 - NoLen / 2 , y / 2 - y2)
			dc.DrawText("Artwork" , x / 2 - ArtworkLen / 2 , y / 2)
			dc.DrawText("Found" , x / 2 - FoundLen / 2 , y / 2 +y2)
			'dc.DrawText("No Artwork Found",x/2-x2/2,y/2)									
		ElseIf FileType(canvas.Image) = 1
			
			Local ImageImg:wxImage
			Local ImageBit:wxBitmap
			Local ImagePix:TPixmap
			Local BlackBit:wxBitmap
			Local Drawx:Int
			Local Drawy:Int 				
			
			If Right(canvas.Image , 3) = "ico" Then				
				ImageImg = New wxImage.Create(canvas.Image , wxBITMAP_TYPE_ICO)
				''ImageImg.SetMask(True)
				''ImageImg.SetMaskFromImage(ImageImg , 0 , 0 , 0)
				''ImageImg.SetMaskColour(240 , 240 , 240)				
				ImageImg.Rescale(x , y)
				ImageBit = New wxBitmap.CreateFromImage(ImageImg)
				''ImageBit.SetMask(New wxMask.Create(ImageBit,New wxColour.CreateNamedColour("Black")))
				Drawx = (x - (Min(x , y) ) ) / 2
				Drawy = (y - (Min(x , y)) ) / 2				
				
			Else
				ImagePix = LoadPixmap(canvas.Image)
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
			dc.GetTextExtent("No Artwork Found" , x2 , y2)
			dc.DrawText("No Artwork Found",x/2-x2/2,y/2)
		EndIf
		dc.free()
	End Function
	
End Type

Type ImagePanel Extends wxPanel
	Field EditGameWin:EditGameList
	Field Image:String
	Field Changed:Int
	Field ImageType:Int
	Field ClickCount:Int
	Field DoubleClickTimer:Int
	'1: Front
	'2: Back
	'3: Fanart
	'4: Banner
	'5: Icon

	Method OnInit()
		ClickCount = 0
		DoubleClickTimer = 0
		Image = ""
		Changed = False
		ConnectAny(wxEVT_PAINT , OnPaint)
		ConnectANY( wxEVT_RIGHT_DOWN , ImageRightClickedFun)		
		ConnectANY( wxEVT_LEFT_DCLICK , ImageLeftClickedFun)
	End Method
	
	Method SetImageType(ImageT:Int)
		If ImageT > 5 Or ImageT < 1 Then
			CustomRuntimeError("Error 25: Wrong ImageType") 'MARK: Error 25
		EndIf
		ImageType = ImageT
	End Method
	
	Method SetEditGameWin(Win:EditGameList)
		EditGameWin = Win
	End Method
	
	Method SetImage(Bitmap:String)
		Self.Image = Bitmap
	End Method
	
	Method ShowImage()
		If Self.Image = "" Then
		
		Else
			OpenURL(Self.Image)
		EndIf
	End Method
	
	Method ImageClicked()
		Select Self.ImageType
			Case 1
				Menu1:wxMenu = New wxMenu.Create("Front Art Menu")
				Menu1.Append(IP_M1_I3 , "View")
				Menu1.Append(IP_M1_I1 , "Browse computer")
				MENU1.Append(IP_M1_I2 , "Delete")
				EditGameWin.PopupMenu(MENU1)
			Case 2
				Menu2:wxMenu = New wxMenu.Create("Back Art Menu")
				Menu2.Append(IP_M2_I3 , "View")				
				Menu2.Append(IP_M2_I1 , "Browse computer")
				Menu2.Append(IP_M2_I2 , "Delete")				
				EditGameWin.PopupMenu(Menu2)			
			Case 3
				Menu3:wxMenu = New wxMenu.Create("Background Art Menu")
				Menu3.Append(IP_M3_I3 , "View")
				Menu3.Append(IP_M3_I4 , "Browse online")				
				Menu3.Append(IP_M3_I1 , "Browse computer")
				Menu3.Append(IP_M3_I2 , "Delete")				
				EditGameWin.PopupMenu(Menu3)			
			Case 4
				Menu4:wxMenu = New wxMenu.Create("Banner Art Menu")
				Menu4.Append(IP_M4_I3 , "View")			
				Menu4.Append(IP_M4_I4 , "Browse online")	
				Menu4.Append(IP_M4_I1 , "Browse computer")
				Menu4.Append(IP_M4_I2 , "Delete")				
				EditGameWin.PopupMenu(Menu4)			
			Case 5
				Menu5:wxMenu = New wxMenu.Create("Icon Art Menu")
				Menu5.Append(IP_M5_I5 , "View")				
				Menu5.Append(IP_M5_I1 , "Browse computer")
				?Win32
				MENU5.Append(IP_M5_I3, "Extract icon from steam folder")
				MENU5.Append(IP_M5_I2 , "Extract icon from EXE")
				?
				Menu5.Append(IP_M5_I4 , "Delete")
				EditGameWin.PopupMenu(Menu5)			
			Default
				CustomRuntimeError("Error 26: Wrong ImageType in Select") 'MARK: Error 26
		End Select
	End Method	
	
	Function ImageRightClickedFun(event:wxEvent)
		Local IPanel:ImagePanel = ImagePanel(event.parent)
		IPanel.ImageClicked()
	End Function

	Function ImageLeftClickedFun(event:wxEvent)
		Local IPanel:ImagePanel = ImagePanel(event.parent)
		IPanel.ShowImage()	
	End Function
	
	
	
	Function FrontImageClickFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.FrontBoxArt.ShowImage()
	End Function
	
	Function BackImageClickFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.BackBoxArt.ShowImage()
	End Function
	
	Function BackgroundImageClickFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.BackGroundArt.ShowImage()
	End Function	
	
	Function BannerImageClickFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.BannerArt.ShowImage()
	End Function
	
	Function IconImageClickFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.IconArt.ShowImage()
	End Function
	
	
	
	Function FrontImageBrowseFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.FrontBoxArt.ImageClicked()
	End Function
	
	Function BackImageBrowseFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.BackBoxArt.ImageClicked()
	End Function
	
	Function BackgroundImageBrowseFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.BackGroundArt.ImageClicked()
	End Function	
	
	Function BannerImageBrowseFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.BannerArt.ImageClicked()
	End Function
	
	Function IconImageBrowseFun(event:wxEvent)
		Local EditWin:EditGameList = EditGameList(event.parent)
		EditWin.IconArt.ImageClicked()
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
		dc.SetBackground(New wxBrush.CreateFromColour(New wxColour.Create(240,240,240), wxSOLID))
		dc.Clear()
		dc.SetTextForeground(New wxColour.Create(0,0,0))
		Local NoLen:Int, ArtworkLen:Int, FoundLen:Int
		If canvas.Image = ""
			'dc.GetTextExtent("No Artwork Found" , x2 , y2)			
			dc.GetTextExtent("No" , NoLen , y2)
			dc.GetTextExtent("Artwork" , ArtworkLen , y2)
			dc.GetTextExtent("Found" , FoundLen , y2)						
			dc.DrawText("No" , x / 2 - NoLen / 2 , y / 2 - y2)
			dc.DrawText("Artwork" , x / 2 - ArtworkLen / 2 , y / 2)
			dc.DrawText("Found" , x / 2 - FoundLen / 2 , y / 2 +y2)
			'dc.DrawText("No Artwork Found",x/2-x2/2,y/2)									
		ElseIf FileType(canvas.Image) = 1
			
			Local ImageImg:wxImage
			Local ImageBit:wxBitmap
			Local ImagePix:TPixmap
			Local BlackBit:wxBitmap
			
			If Right(canvas.Image , 3) = "ico" Then				
				ImageImg = New wxImage.Create(canvas.Image , wxBITMAP_TYPE_ICO)
				''ImageImg.SetMask(True)
				''ImageImg.SetMaskFromImage(ImageImg , 0 , 0 , 0)
				''ImageImg.SetMaskColour(240 , 240 , 240)				
				ImageImg.Rescale(x , y)
				ImageBit = New wxBitmap.CreateFromImage(ImageImg)
				''ImageBit.SetMask(New wxMask.Create(ImageBit,New wxColour.CreateNamedColour("Black")))
				
			Else
				ImagePix = LoadPixmap(canvas.Image)
				ImagePix = MaskPixmap(ImagePix , - 1 , - 1 , - 1)
				x3 = PixmapWidth(ImagePix)
				y3 = PixmapHeight(ImagePix)		
				
				HWratio = Float(y3) / x3
				WHratio = Float(x3) / y3
				
				If HWratio*x < y Then
					ImagePix = ResizePixmap(ImagePix , x , HWratio * x)	
					BlackBit = New wxBitmap.CreateEmpty(x , HWratio * x)
					BlackBit.Colourize(New wxColour.Create(0,0,0))
				Else
					ImagePix = ResizePixmap(ImagePix , WHratio * y , y)	
					BlackBit = New wxBitmap.CreateEmpty(WHratio * y , y)
					BlackBit.Colourize(New wxColour.Create(0,0,0))					
				EndIf		
				
				ImageBit = New wxBitmap.CreateBitmapFromPixmap(ImagePix)
				'ImageBit.SetMask(New wxMask.Create(BlackBit,New wxColour.Create(255,255,255,255)))
				dc.DrawBitmap(BlackBit, 0, 0, False)
			EndIf
			
			dc.DrawBitmap(ImageBit, 0, 0, False)		
		Else
			dc.GetTextExtent("No Artwork Found" , x2 , y2)
			dc.DrawText("No Artwork Found",x/2-x2/2,y/2)
		EndIf
		dc.free()
	End Function
	
End Type




Type ArtworkPicker Extends wxFrame
	Field ParentWin:EditGameList
	Field ArtworkList:wxListBox
	Field ArtworkPreview:ImageBase
	Field GameNode:GameType
	Field ArtType:Int
	
	Method OnInit()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		ParentWin = EditGameList(GetParent())
		
		Local SplitWin:wxSplitterWindow = New wxSplitterWindow.Create(Self , AP_SP)
		
		ArtworkList = New wxListBox.Create(SplitWin , AP_AL , Null)
		ArtworkPreview = ImageBase(New ImageBase.Create(SplitWin , AP_AP))

		SplitWin.SplitVertically(ArtworkList , ArtworkPreview , -300)
	
		SplitWin.SetMinimumPaneSize(100)
		SplitWin.SetSashGravity(0.5)
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
				
		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Local P1Hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		BackButton:wxButton = New wxButton.Create(Panel1 , AP_BB , "Back")
		OKButton:wxButton = New wxButton.Create(Panel1, AP_OB , "OK")

		P1Hbox.Add(BackButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.AddStretchSpacer(1)
		P1Hbox.Add(OKButton , 1 , wxEXPAND | wxALL , 10)
		
		Panel1.SetSizer(P1Hbox)
		
		vbox.Add(SplitWin,  1 , wxEXPAND , 0)
		vbox.Add(Panel1,  0 , wxEXPAND , 0)		
		SetSizer(vbox)
		Centre()		
		Hide()
				
		Connect(AP_BB , wxEVT_COMMAND_BUTTON_CLICKED , ShowEditList)
		Connect(AP_OB , wxEVT_COMMAND_BUTTON_CLICKED , SaveArt)
		'Connect(SCA_HB, wxEVT_COMMAND_BUTTON_CLICKED, ShowHelp)
		
		Connect(AP_AL , wxEVT_COMMAND_LISTBOX_SELECTED , UpdateImage)
		Connect(AP_SP , wxEVT_COMMAND_SPLITTER_SASH_POS_CHANGED  , RefreshImage)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method
	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = ArtworkPicker(event.parent).ParentWin.ParentWin
		MainWin.Close(True)
	End Function		
	
	Method SetType(IGameName:String , IArtType:Int)
		ArtType = IArtType
		ArtworkPreview.SetImageType(ArtType)
		GameNode = New GameType
		GameNode.GetGame(IGameName)
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Downloading Thumbs" , , , 300 , 400) )
		Log1.Show(1)
		GameNode.DownloadArtWorkThumbs(Log1 , ArtType)
		'Log1.Destroy()
		Log1.Show(0)
		ArtworkList.Clear()
		Select IArtType
			Case 3
				For item:String = EachIn GameNode.Fanart
					ArtworkList.Append(item)
				Next
			Case 4
				For item:String = EachIn GameNode.BannerArt
					ArtworkList.Append(item)
				Next				
		End Select
		Show()
	End Method
	
	Function SaveArt(event:wxEvent)
		
		Local ArtWin:ArtworkPicker = ArtworkPicker(event.parent)
		Local MessageBox:wxMessageDialog
		Local Selection:Int = ArtWin.ArtworkList.GetSelection()
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Downloading Art" , , , 300 , 400) )
		Log1.Show(1)
		Local temp:String
		ArtWin.Hide()
		If Selection = - 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select an artwork" , "Info" , wxOK)
			MessageBox.ShowModal()
			MessageBox.Free()		
			Return
		EndIf
		Local Downloadexe:TProcess = RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile " + Chr(34) + ArtWin.ArtworkList.GetString(Selection) + Chr(34) + " -DownloadPath " + Chr(34) + TEMPFOLDER + "ArtWork" + Chr(34) + " -DownloadName " + Chr(34) + "Art" + String(ArtWin.ArtType) + "." + Lower(ExtractExt(ArtWin.ArtworkList.GetString(Selection) ) ) + Chr(34) + "")
		
		'"PhotonDownloader.exe -Mode 2 -DownloadFile " + Chr(34) + Thumb + Chr(34) + " -DownloadPath " + Chr(34) + GAMEDATAFOLDER + GName + "\Thumbs"+String(ArtType) + Chr(34) + " -DownloadName " + Chr(34) + "Thumb" + String(a) + "." + Lower(ExtractExt(Thumb) ) + Chr(34))

		Log1.AddText("Downloading Art "+Selection)
		PrintF("Downloading "+ArtWin.ArtworkList.GetString(Selection))				
		Repeat
			If ProcessStatus(Downloadexe) = 0 Then	
				Log1.AddText("Download Completed")
				PrintF("Download Completed")					
				Exit
			EndIf	
			If Downloadexe.pipe.ReadAvail()  Then
				Log1.AddText(Downloadexe.pipe.ReadLine())
			EndIf 
			Delay 100
			If Log1.LogClosed = True Then
				ArtWin.ParentWin.Show()
				ArtWin.Hide()
				ArtWin.Destroy()	
				'Log1.Destroy()	
				Log1.Show(0)
				TerminateProcess(Downloadexe)
				DeleteFile(TEMPFOLDER + "ArtWork"+FolderSlash + "Art" + String(ArtWin.ArtType) + "." + Lower(ExtractExt(ArtWin.ArtworkList.GetString(Selection) ) ) )
				Return
			EndIf
		Forever	
		Select ArtWin.ArtType
			Case 3
				temp = TEMPFOLDER + "ArtWork"+FolderSlash +"Art" + String(ArtWin.ArtType) + "." + Lower(ExtractExt(ArtWin.ArtworkList.GetString(Selection)) )
				ArtWin.ParentWin.NewBGArt = temp
				ArtWin.ParentWin.BackGroundArt.SetImage(temp )
				ArtWin.ParentWin.BackGroundArt.Changed = True			
			Case 4
				temp =  TEMPFOLDER + "ArtWork"+FolderSlash +"Art" + String(ArtWin.ArtType) + "." + Lower(ExtractExt(ArtWin.ArtworkList.GetString(Selection)) )
				ArtWin.ParentWin.NewBArt = temp
				ArtWin.ParentWin.BannerArt.SetImage(temp )
				ArtWin.ParentWin.BannerArt.Changed = True				
				
		End Select
		ArtWin.ParentWin.DataChangeUpdateExt(ArtWin.ParentWin)
		ArtWin.ParentWin.Show()
		ArtWin.Hide()
		ArtWin.ArtworkPreview.Destroy()
		ArtWin.Destroy()
		ArtWin = Null
		'Log1.Destroy()			
		Log1.Show(0)
	End Function
	
	Function ShowEditList(event:wxEvent)
		Local ArtWin:ArtworkPicker = ArtworkPicker(event.parent)
		ArtWin.ParentWin.Show()
		ArtWin.Hide()
		ArtWin.Destroy()
	End Function
	
	Function UpdateImage(event:wxEvent)
		Local ArtWin:ArtworkPicker = ArtworkPicker(event.parent)
		Local Selection:Int = ArtWin.ArtworkList.GetSelection()
		Local GName:String = GameReadType.GameNameDirFilter(ArtWin.GameNode.Name) + "---" + ArtWin.GameNode.PlatformNum
		ArtWin.ArtworkPreview.SetImage(GAMEDATAFOLDER + GName + FolderSlash + "Thumbs" + String(ArtWin.ArtType) + FolderSlash + "Thumb" + Selection + ".jpg")
		ArtWin.ArtworkPreview.Refresh()
	End Function
	
	Function RefreshImage(event:wxEvent)
		Local ArtWin:ArtworkPicker = ArtworkPicker(event.parent)		
		ArtWin.ArtworkPreview.Refresh()		
	End Function		
End Type

Function Thread_UpdateGame:Object(Game:Object)
	Local GameNode:GameType = GameType(Game)
	
	
	Log1.Show(1)
	Log1.AddText("Downloading Game Info ID:" + GameNode.LuaIDData )
	GameNode.DownloadGameInfo()
	GameNode.DownloadGameArtWork()
	Log1.AddText("Finished")
	Log1.Show(0)

End Function

Function Thread_UpdateAllGames:Object(GameL:Object)
	Local GameList:TList = TList(GameL)
	Local GameNode:GameType = New GameType
	Local GameName:String
	Local OverideArtwork:Int = 0
	Local MessageBox:wxMessageDialog
	
	
	Log1.Show(1)
	
	MessageBox = New wxMessageDialog.Create(Null, "Would you like to overwrite old files?" + Chr(10) + " Yes - redownloads all game artwork" + Chr(10) + " No - download new artwork only" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
	If MessageBox.ShowModal() = wxID_YES then
		PrintF("Overwrite True")
		OverideArtwork = 1
	Else
		PrintF("Overwrite False")
		OverideArtwork = 0
	EndIf
	MessageBox.Free()
	
	
	
	Local GameTotal:Int = GameList.Count()
	Local GameNumber:Int = 0
	
	For GameN:Object = EachIn GameList
		GameName:String = String(GameN)
		PrintF("Update Game: " + GameName)
		Log1.AddText("Updating:" + GameName )
		If GameNode.GetGame(GameName) = - 1 then
			PrintF("Invalid GetGame")	
		Else
			If GameNode.LuaFile = Null Or GameNode.LuaFile = "" Or GameNode.LuaIDData = Null Or GameNode.LuaIDData = "" then
				PrintF("Invalid Lua Data")							
			Else
				If OverideArtwork = 1 then
					GameNode.OverideArtwork = 1
				Else
					GameNode.OverideArtwork = 0
				EndIf
				Log1.AddText("Downloading Game Info ID:" + GameNode.LuaIDData )
				GameNode.DownloadGameInfo()
				GameNode.DownloadGameArtWork()
				Log1.AddText("Finished")
			EndIf
		EndIf
		GameNumber = GameNumber + 1
		Log1.Progress.SetValue( (100 * GameNumber) / GameTotal )
		If Log1.LogClosed = True then Exit
	Next
	
	MessageBox = New wxMessageDialog.Create(Null , "Games Successfully Updated" , "Info" , wxOK)
	MessageBox.ShowModal()
	MessageBox.Free()	

	Log1.Show(0)

End Function
