Type SteamOnlineImportApp Extends wxApp 
	Method OnInit:Int()
		wxImage.AddHandler( New wxICOHandler)		
		wxImage.AddHandler( New wxPNGHandler)		
		wxImage.AddHandler( New wxJPEGHandler)
					
		Local MessageBox:wxMessageDialog
				
		If FindSteamFolderMain() = - 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Could not find Steam Folder, please manually select it from the settings menu" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()			
		Else
			Local SteamOnlineImportField:SteamOnlineImport = SteamOnlineImport(New SteamOnlineImport.Create(Null , wxID_ANY , "Online Import" , Null , - 1 , - 1 , wxRESIZE_BORDER | wxDEFAULT_DIALOG_STYLE | wxMAXIMIZE_BOX ) )
			CheckInternet()
			If Connected = 1 Then
				SteamOnlineImportField.Setup()	
				SteamOnlineImportField.RunWizard(SteamOnlineImportField.StartPage)
				SteamOnlineImportField.Destroy()
			Else
				MessageBox = New wxMessageDialog.Create(Null , "You are not connected to the internet!" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()
			EndIf		
		EndIf		
		
		Return True

	End Method
	
End Type

Type SteamOnlineImport Extends wxWizard
	Field BackButton:wxButton
	Field ParentWin:MainWindow
	Field StartPage:wxWizardPageSimple
	Field ImportPage:wxWizardPageSimple
	Field FinishPage:wxWizardPageSimple	
	Field StartPageInt:Int 
	Field ScrollBox:wxScrolledWindow
	Field VPanelList:TList
	Field CheckBoxList:TList
	Field GDFNameList:TList
	Field GameNameList:TList
	Field EXEName:TList	
	Field RealName:TList

	Method Setup()
		PrintF("Setup Online Import")
		StartPageInt = -1
		ParentWin = MainWindow(GetParent() )
		
		StartPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		ImportPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		FinishPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		
		StartPage.SetNext(ImportPage)
		ImportPage.SetNext(FinishPage)
		
		ImportPage.SetPrev(StartPage)
	
		Local ExplainText:String = "This wizard will import installed games from Steam, a popular digital distribution platform. ~n" + ..
		"If you do not know what Steam is, you don't need to use this wizard. ~n" + ..
		"This is the ONLINE version of the wizard, you must be connected to the internet AND your steam profile must be public! (Otherwise the import will fail) ~n" + ..
		"Powered By Steam (http://steampowered.com) ~n~n" + ..
		"Click Next to continue"

		
		Local ExplainText2:String = "Select from the list the games you wish to add to GameManager. ~n"	
		
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
		


		tempPanel2:wxPanel = New wxPanel.Create(ImportPage , - 1)
		Local TextField3 = New wxStaticText.Create(tempPanel2 , wxID_ANY , ExplainText2, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
		Local P2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		P2hbox.AddStretchSpacer(1)
		P2hbox.Add(TextField3 , 6 , wxEXPAND , 0)
		P2hbox.AddStretchSpacer(1)		
		tempPanel2.SetSizer(P2hbox)


		Local tempStaticText:wxStaticText
		
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "Import?")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 0 , wxEXPAND | wxLEFT | wxRIGHT , 10)
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "Game Explorer Name")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10)		
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "Online Database Name")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10)				
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "EXE Name")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10)	
		
		
		tempPanel3.SetSizer(tempVbox)
		
		Local sl3:wxStaticLine = New wxStaticLine.Create(ImportPage , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		Local sl1:wxStaticLine = New wxStaticLine.Create(ImportPage , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
	
		
		Local P2vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		ScrollBox = New wxScrolledWindow.Create(ImportPage)

		tempPanel:wxPanel = New wxPanel.Create(ImportPage , - 1)
		tempVbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SAButton:wxButton = New wxButton.Create(tempPanel , MI_SA , "Select All")
		DAButton:wxButton = New wxButton.Create(tempPanel, MI_DA , "DeSelect All")			
		tempVbox.Add(SAButton , 0 , wxEXPAND | wxTOP | wxRIGHT | wxLEFT , 10)
		tempVbox.Add(DAButton , 0 , wxEXPAND | wxTOP | wxRIGHT | wxLEFT , 10)	
		tempPanel.SetSizer(tempVbox)	
				
		Self.UpdateList()

		P2vbox.Add(tempPanel2,  0 , wxEXPAND, 0)
		P2vbox.AddSpacer(10)
		P2vbox.Add(tempPanel3 , 1 , wxEXPAND, 0)
		P2vbox.Add(sl3 , 0 , wxEXPAND , 0)
		P2vbox.Add(ScrollBox , 15 , wxEXPAND , 0)
		P2vbox.Add(sl1 , 0 , wxEXPAND , 0)
		P2vbox.Add(tempPanel,  1 , wxEXPAND, 0)	
		ImportPage.SetSizer(P2vbox)

		Local TextField2 = New wxStaticText.Create(FinishPage , wxID_ANY , EndText, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
		Local P3vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		P3vbox.Add(TextField2,  1 , wxEXPAND | wxALL, 10)		
		FinishPage.SetSizer(P3vbox)		
		
		'StartPage.SetSize(600 , 600)
		'StartPage.SetInitialSize(600 , 600)
		'StartPage.SetMinSize(600 , 600)
		'StartPage.SetClientSize(600,600)		
		'StartPage.SetVirtualSize(600 , 600)
		'StartPage.SetDimensions(0,0,600,600)
		'StartPage.Refresh()

		Connect(MI_SA , wxEVT_COMMAND_BUTTON_CLICKED , SelectAllFun)		
		Connect(MI_DA , wxEVT_COMMAND_BUTTON_CLICKED , DeSelectAllFun)		
		ConnectAny(wxEVT_WIZARD_PAGE_CHANGED , PageChange)
		'Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'BackButton = New wxButton.Create(StartPage, 101 , "Back")
		'hbox.Add(BackButton,  1 , wxEXPAND | wxALL, 20)		
		'SetSizer(hbox)
		'Centre()		
		'Hide()
		'Connect(101, wxEVT_COMMAND_BUTTON_CLICKED, ShowMainMenu)
		PrintF("Finished Setup of OnlineImport")
	End Method 

	Method UpdateList()
		PrintF("Update OnlineImport List")
		OutputSteam(True)

		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local tempVbox:wxBoxSizer
		Local tempPanel:wxPanel		
		Local tempCheckBox:wxCheckBox		
		Local tempGameName:wxComboBox
		Local tempEXEName:wxStaticText	
		Local tempStaticText:wxStaticText
		Local sl:wxStaticLine

		VPanelList = CreateList()
		CheckBoxList = CreateList()
		GDFNameList = CreateList()
		GameNameList = CreateList()
		EXEName = CreateList()
		RealName = CreateList()
			
		Rem			
		tempPanel = New wxPanel.Create(ScrollBox , - 1)
		ListAddLast VPanelList,tempPanel
		tempPanel.SetBackgroundColour(New wxColour.Create(200,200,200))
		tempVbox = New wxBoxSizer.Create(wxHORIZONTAL)

		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Import?")
		tempVbox.Add(tempStaticText , 0 , wxEXPAND | wxALL , 20)
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Game Explorer Name")
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxALL , 20)	
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Online Database Name")
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxALL , 20)		
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "EXE Name")
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxALL , 20)			
		tempPanel.SetSizer(tempVbox)
		endrem
		
		Delay 300
		
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Searching Online For Games" , , , 300 , 400) )
		Log1.Show(1)
		Log1.AddText("Searching Online For Games")
		ReadSteamFolder = ReadDir(TEMPFOLDER + "Steam")
		
		Local File:String
		Local SteamEXE:String
		Local ID:String
		Local GameName:String
		Local Platform:String
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
			ReadGDFFile = ReadFile(TEMPFOLDER + "Steam\" + File + "\Info.txt")
			GameName = ReadLine(ReadGDFFile)
			SteamEXE = ReadLine(ReadGDFFile)
			
			tempPanel = New wxPanel.Create(ScrollBox , - 1)
			tempPanel.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
			tempVbox = New wxBoxSizer.Create(wxHORIZONTAL)
			
			tempCheckBox = New wxCheckBox.Create(tempPanel , wxID_ANY)
			ListAddLast CheckBoxList,tempCheckBox
			tempVbox.Add(tempCheckBox,  0 , wxEXPAND | wxALL, 20)
			
			tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , GameName)
			ListAddLast GDFNameList , tempStaticText
			tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxALL , 20)
			
			tempGameName = New wxComboBox.Create(tempPanel , OI_GN, Null, Null)
			ListAddLast GameNameList , tempGameName
			tempVbox.Add(tempGameName , 1 , wxEXPAND | wxALL , 20)			

			tempEXEName = New wxStaticText.Create(tempPanel , wxID_ANY , SteamEXE )
			ListAddLast EXEName , tempEXEName
			tempVbox.Add(tempEXEName , 1 , wxEXPAND | wxALL , 20)
			
			ListAddLast(RealName , File)
			
			Log1.AddText("Searching for: "+File)
			WriteGameList(File , "PC")
			SortGameList(File)
			ReadGameSearch=ReadFile(TEMPFOLDER +"SearchGameList.txt")
			For a = 1 To 5
				ID = ReadLine(ReadGameSearch)
				GameName = GameNameSanitizer(ReadLine(ReadGameSearch) )
				Platform = ReadLine(ReadGameSearch) 
				If GameName = "" Or GameName = " " Then
					If a=1 Then
						tempGameName.Append("")
						Exit
					Else
						Exit
					EndIf
				EndIf
				tempGameName.Append(ID + "::" + GameName + "::" + Platform)
				
			Next
			tempGameName.Append("Manual Search")
			tempGameName.SelectItem(0)
			CloseFile(ReadGameSearch)
			tempPanel.SetSizer(tempVbox)
			ListAddLast VPanelList,tempPanel
			CloseFile(ReadGDFFile)
			If Log1.LogClosed = True Then Exit
		Forever		
		CloseDir(ReadSteamFolder)
		
		Connect(OI_GN , wxEVT_COMMAND_COMBOBOX_SELECTED , GameNameSelectFun)
		
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
		'Log1.Destroy()		
		Log1.Show(0)
	End Method

	Method UpdateGames()
		
		PrintF("Starting to Update Games")
		Local MessageBox:wxMessageDialog

		Local VPanelListArray:wxPanel[]
		VPanelListArray = wxPanel[](ListToArray(VPanelList) )
		
		Local CheckBoxListArray:wxCheckBox[]
		CheckBoxListArray = wxCheckBox[](ListToArray(CheckBoxList) )		

		Local GDFNameListArray:wxStaticText[]
		GDFNameListArray = wxStaticText[](ListToArray(GDFNameList) )
		
		Local GameNameListArray:wxComboBox[]
		GameNameListArray = wxComboBox[](ListToArray(GameNameList) )
		
		Local EXENameArray:wxComboBox[]
		EXENameArray = wxComboBox[](ListToArray(EXEName) )
		
		Local RealNameArray:Object[]
		RealNameArray = ListToArray(RealName)
		
		
		Local SteamGameName:String
		Local ID:String
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Processing New Games" , , , 300 , 400) )
		Log1.Show(1)
		Self.Disable()
		Self.Hide()
		For a = 0 To Len(RealNameArray) - 1
			If CheckBoxListArray[a].IsChecked() Then
				
				SteamGameName = String(RealNameArray[a])
				PrintF("Game Checked: " + SteamGameName)
				Log1.AddText("Processing: " + SteamGameName)

				
				GameNode:GameType = New GameType
				GameNode.NewGame()
				
				ReadGameData = ReadFile(TEMPFOLDER + "Steam\" + SteamGameName + "\Info.txt")
				GameNode.Name = ReadLine(ReadGameData)
				GameNode.RunEXE = ReadLine(ReadGameData)
				GameNode.Plat = "PC"
				
				CloseFile(ReadGameData)

				ID = GameNameListArray[a].GetValue()
				If ID = " " Or ID = "" Then
					PrintF("Empty ID Text")
					Continue
				EndIf
				LenID = Len(ID)
				For b = 1 To LenID
					If Mid(ID , b , 2) = "::" Then
						ID = Left(ID , b - 1)
						Exit
					EndIf
				Next
				If b = LenID Then
					PrintF("No ID")
					Continue
				EndIf
				GameNode.ID = Int(ID)
				PrintF("Game ID: "+ID)
				Log1.AddText("Downloading game infoformation")
				If GameNode.DownloadGameInfo()=1 Then
					GameNode.DownloadGameArtWork(0 , Log1)
				EndIf
				
			EndIf	
			If Log1.LogClosed = True Then Exit	
		Next
		PrintF("Finished Update Games")
		Log1.AddText("Finished")
		Delay 1500
		'Log1.Destroy()
		Log1.Show(0)
		Self.Enable()
		Self.Show(True)
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
	
	Method GameNameSelect()
		For temp2:wxComboBox = EachIn GameNameList
			If temp2.GetValue() = "Manual Search" Then
				PrintF("Manual Search")
				ManualSearchWindow:ManualSearch = ManualSearch(New ManualSearch.Create(Self, wxID_ANY, "Manual Search", , , 600, 500))
				ManualSearchWindow.SetValues(temp2,Self)
				temp2.SelectItem(0)
				Self.Disable()
				ManualSearchWindow.Show()
			EndIf
		Next		
	End Method

	Function GameNameSelectFun(event:wxEvent)
		Local OnlineWiz:SteamOnlineImport = SteamOnlineImport(event.parent)
		OnlineWiz.GameNameSelect()
	End Function

	Function SelectAllFun(event:wxEvent)
		Local OnlineWiz:SteamOnlineImport = SteamOnlineImport(event.parent)
		OnlineWiz.SelectAll()
	End Function 

	Function DeSelectAllFun(event:wxEvent)
		Local OnlineWiz:SteamOnlineImport = SteamOnlineImport(event.parent)
		OnlineWiz.DeSelectAll()
	End Function 

	Function PageChange(event:wxEvent)
		WizEvent:wxWizardEvent = wxWizardEvent(event)
		Local OnlineWin:SteamOnlineImport = SteamOnlineImport(event.parent)	
		Local CopyGameName:String
		Local Page:Int = WizEvent.GetPage()	
		If OnlineWin.StartPageInt = - 1 Then
			OnlineWin.Maximize(True)
			'OnlineWin.StartPage.SetInitialSize(800 , 600)
			OnlineWin.StartPage.Refresh()
			OnlineWin.StartPageInt = Page
		EndIf
		
		If Page = OnlineWin.StartPageInt + 1 Then
			

		EndIf
		
		If Page = OnlineWin.StartPageInt + 2 Then
			OnlineWin.UpdateGames()
		EndIf
	End Function
	
End Type




