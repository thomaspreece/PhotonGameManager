

Type SteamOfflineImport Extends wxWizard
	Field ParentWin:MainWindow
	Field StartPage:wxWizardPageSimple
	Field ImportPage:wxWizardPageSimple
	Field FinishPage:wxWizardPageSimple
	'Field CheckBoxList:wxCheckListBox
	'Field CheckBoxNumber:Int
	Field StartPageInt:Int
	Field ScrollBox:wxScrolledWindow
	Field VPanelList:TList
	Field CheckBoxList:TList
	Field GDFNameList:TList
	Field EXEName:TList	
	Field RealName:TList	
	
	Method Setup()
		PrintF("Creating Offline Wizard")
		StartPageInt = -1
		ParentWin = MainWindow(GetParent() )
		CheckBoxNumber = 0
		StartPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		ImportPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		FinishPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		
		StartPage.SetNext(ImportPage)
		ImportPage.SetNext(FinishPage)
		
		ImportPage.SetPrev(StartPage)
		
		Local ExplainText:String = "This wizard will import installed games from Steam, a popular digital distribution platform. ~n" + ..
		"If you do not know what Steam is, you don't need to use this wizard. ~n" + ..
		"This is the OFFLINE version of the wizard, this means that only locally stored information will be added (which is often missing or incorrect) unlike the online version which downloads all the information direct from your profile. ~n~n" + ..
		"Click Next to continue"
		
		Local ExplainText2:String = "Select from the list the games you wish to add to GameManager. ~n" + ..
		 "Games with (UnInstalled) after name are games that have been found but cannot be verified that they are installed ~n" + ..
		"Red: Game already in database   Blue: Game not in database "
		
		
		Local EndText:String = "Operation Completed Successfully."
		
		Local TextField = New wxStaticText.Create(StartPage , wxID_ANY , ExplainText, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
		Local P1vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		P1vbox.AddStretchSpacer(1)
		P1vbox.Add(TextField , 1 , wxEXPAND | wxALL , 10)
		P1vbox.AddStretchSpacer(1)		
		StartPage.SetSizer(P1vbox)
		

		tempPanel3:wxPanel = New wxPanel.Create(ImportPage , - 1)
		'ListAddLast VPanelList,tempPanel
		'tempPanel.SetBackgroundColour(New wxColour.Create(200,200,255))
		tempVbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		BOLDFONT1:wxFont = New wxFont.Create()
		BOLDFONT1.SetWeight(wxFONTWEIGHT_BOLD)
		
		Local tempStaticText:wxStaticText
		
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "Import?")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 0 , wxEXPAND | wxLEFT | wxRIGHT , 10)
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "Game Explorer Name")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10)	
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "EXE Name")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10)			
		tempPanel3.SetSizer(tempVbox)
		
		Local sl3:wxStaticLine = New wxStaticLine.Create(ImportPage , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)


		Local P2vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		ScrollBox = New wxScrolledWindow.Create(ImportPage)

		tempPanel:wxPanel = New wxPanel.Create(ImportPage , - 1)
		'tempPanel.SetBackgroundColour(New wxColour.Create(200,200,200))
		tempVbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SAButton:wxButton = New wxButton.Create(tempPanel , MI_SA , "Select All")
		DAButton:wxButton = New wxButton.Create(tempPanel, MI_DA , "DeSelect All")			
		tempVbox.Add(SAButton , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 10)
		tempVbox.Add(DAButton , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 10)	
		tempPanel.SetSizer(tempVbox)	
				
		Self.UpdateList()
		
		Local sl1:wxStaticLine = New wxStaticLine.Create(ImportPage , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		'Local sl2:wxStaticLine = New wxStaticLine.Create(ImportPage , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		tempPanel2:wxPanel = New wxPanel.Create(ImportPage , - 1)
		Local TextField3 = New wxStaticText.Create(tempPanel2 , wxID_ANY , ExplainText2, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
		Local P2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		P2hbox.AddStretchSpacer(1)
		P2hbox.Add(TextField3 , 6 , wxEXPAND , 0)
		P2hbox.AddStretchSpacer(1)		
		tempPanel2.SetSizer(P2hbox)
		
	
		
		P2vbox.Add(tempPanel2,  0 , wxEXPAND, 0)
		'P2vbox.Add(sl2 , 0 , wxEXPAND , 0)
		P2vbox.AddSpacer(10)
		P2vbox.Add(tempPanel3 , 1 , wxEXPAND, 0)
		P2vbox.Add(sl3 , 0 , wxEXPAND , 0)
		P2vbox.Add(ScrollBox , 15 , wxEXPAND , 0)
		P2vbox.Add(sl1 , 0 , wxEXPAND , 0)
		P2vbox.Add(tempPanel,  1 , wxEXPAND, 0)	
		ImportPage.SetSizer(P2vbox)


		Local TextField2 = New wxStaticText.Create(FinishPage , wxID_ANY , EndText, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
		Local P3vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		P3vbox.AddStretchSpacer(1)	
		P3vbox.Add(TextField2 , 1 , wxEXPAND | wxALL , 10)	
		P3vbox.AddStretchSpacer(1)		
		FinishPage.SetSizer(P3vbox)		

		Connect(MI_SA , wxEVT_COMMAND_BUTTON_CLICKED , SelectAllFun)		
		Connect(MI_DA , wxEVT_COMMAND_BUTTON_CLICKED , DeSelectAllFun)
		ConnectAny(wxEVT_WIZARD_PAGE_CHANGED , PageChange)
		PrintF("Finished Creating Wizard")
	End Method


	Method UpdateList()
		PrintF("Update OnlineImport List")
		OutputSteam(0)

		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local tempVbox:wxBoxSizer
		Local tempPanel:wxPanel		
		Local tempCheckBox:wxCheckBox		
		Local tempEXEName:wxStaticText	
		Local tempStaticText:wxStaticText
		Local sl:wxStaticLine
		
		VPanelList = CreateList()
		CheckBoxList = CreateList()
		GDFNameList = CreateList()
		EXEName = CreateList()
		RealName = CreateList()				
		
		
		'hbox2.Add(tempPanel , 0 , wxEXPAND , 0)
		'hbox2.Add(sl2 , 0 , wxEXPAND , 0)
		
		Delay 300
		
		ReadSteamFolder = ReadDir(TEMPFOLDER + "Steam")
		Local File:String
		Local SteamEXE:String
		Local Status:String
		Local GameName:String
		Repeat
			File = NextFile(ReadSteamFolder)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue
			PrintF(File)
			If FileType(TEMPFOLDER + "Steam\" + File + "\Info.txt") = 0 Then
				DeleteDir(TEMPFOLDER + "Steam\" + File , 0)
				PrintF("Folder Empty")
				Continue
			EndIf
			ReadSteamFile = ReadFile(TEMPFOLDER + "Steam\" + File + "\Info.txt")
			GameName = ReadLine(ReadSteamFile)
			SteamEXE = ReadLine(ReadSteamFile)
			Status = ReadLine(ReadSteamFile) 
			
			
			tempPanel = New wxPanel.Create(ScrollBox , - 1)
			If FileType(GAMEDATAFOLDER+File+"---PC")=2 Then 
				tempPanel.SetBackgroundColour(New wxColour.Create(255 , 200 , 200) )
			Else
				tempPanel.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
			EndIf
			tempVbox = New wxBoxSizer.Create(wxHORIZONTAL)
			
			tempCheckBox = New wxCheckBox.Create(tempPanel , wxID_ANY)
			If Status = "Installed" Then
				tempCheckBox.SetValue(1)
			Else
				tempCheckBox.SetValue(1)				
			EndIf
			ListAddLast CheckBoxList,tempCheckBox
			tempVbox.Add(tempCheckBox,  0 , wxEXPAND | wxALL, 20)
			
			tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , GameName + "(" + Status + ")")
			ListAddLast GDFNameList , tempStaticText
			tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxALL , 20)			

			tempEXEName = New wxStaticText.Create(tempPanel , wxID_ANY , SteamEXE)
			ListAddLast EXEName , tempEXEName
			tempVbox.Add(tempEXEName , 1 , wxEXPAND | wxALL , 20)
			
			ListAddLast(RealName , File)
			
			tempPanel.SetSizer(tempVbox)
			ListAddLast VPanelList,tempPanel
			CloseFile(ReadSteamFile)
			
		Forever		
		CloseDir(ReadSteamFolder)
		
		For temp2:wxPanel=EachIn VPanelList
			hbox2.Add(temp2 , 0 , wxEXPAND , 0)
			sl = New wxStaticLine.Create(ScrollBox , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
			hbox2.Add(sl , 0 , wxEXPAND , 0)
		Next			
		hbox2.AddSpacer(60)
			
		hbox2.RecalcSizes()
		ScrollBox.SetSizer(hbox2)
		ScrollBox.SetScrollRate(10 , 10)
		Self.Update()
		ScrollBox.Update()
		Self.SelectAll()
		PrintF("Finished Updating")
	End Method

	Method UpdateGames()
				
		PrintF("Starting to Update Games")
		Local MessageBox:wxMessageDialog
		
		Local CheckBoxListArray:wxCheckBox[]
		CheckBoxListArray = wxCheckBox[](ListToArray(CheckBoxList) )			
		
		Local RealNameArray:Object[]
		RealNameArray = ListToArray(RealName)
		
		
		Local SteamGameName:String
			
		For a = 0 To Len(RealNameArray) - 1
			If CheckBoxListArray[a].IsChecked() Then
				SteamGameName = String(RealNameArray[a])
				PrintF("Game Checked: "+SteamGameName)
				
				GameNode:GameType = New GameType
				GameNode.NewGame()
				
				ReadGameData = ReadFile(TEMPFOLDER + "Steam\" + SteamGameName + "\Info.txt")
				GameNode.Name = ReadLine(ReadGameData)
				GameNode.RunEXE = ReadLine(ReadGameData)
				GameNode.Plat = "PC"
				
				CloseFile(ReadGameData)
				
				GameNode.SaveGame()

			EndIf		
		Next
		
		PrintF("Finished Update Games")
	End Method



	Method SelectAll()
		For temp2:wxCheckBox = EachIn CheckBoxList
			temp2.SetValue(True)
		Next
	End Method
	
	Method DeSelectAll()
		For temp2:wxCheckBox = EachIn CheckBoxList
			temp2.SetValue(False)
		Next
	End Method	

	Function SelectAllFun(event:wxEvent)
		Local OfflineWiz:SteamOfflineImport = SteamOfflineImport(event.parent)
		OfflineWiz.SelectAll()
	End Function 

	Function DeSelectAllFun(event:wxEvent)
		Local OfflineWiz:SteamOfflineImport = SteamOfflineImport(event.parent)
		OfflineWiz.DeSelectAll()
	End Function 

	Function PageChange(event:wxEvent)
		WizEvent:wxWizardEvent = wxWizardEvent(event)
		Local MessageBox:wxMessageDialog
		Local overwrite = False
		Local OfflineWin:SteamOfflineImport = SteamOfflineImport(event.parent)		
		Local CopyGameName:String
		Local Page:Int = WizEvent.GetPage()	
		If OfflineWin.StartPageInt = - 1 Then
			OfflineWin.StartPage.SetInitialSize(800, 500)
			OfflineWin.StartPage.Refresh()		
			OfflineWin.StartPageInt = Page
		EndIf
		
		If Page = OfflineWin.StartPageInt + 2 Then
			OfflineWin.UpdateGames()
		EndIf
	End Function
	

End Type


