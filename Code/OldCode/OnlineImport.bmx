Type OnlineImport Extends wxWizard
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
	
		Local ExplainText:String = "This wizard will import installed games from windows Game Explorer, the game management tool built into Windows Vista and 7. If you do not know what Game Explorer is, don't worry your games will have automatically been added to it. ~n" + ..
		"This is the ONLINE version of the wizard, this means that you need to be connected to the internet to retrieve game data. ~n~n" + ..
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
		OutputGDFs()

		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local tempVbox:wxBoxSizer
		Local tempPanel:wxPanel		
		Local tempCheckBox:wxCheckBox		
		Local tempGameName:wxComboBox
		Local tempEXEName:wxComboBox		
		Local tempStaticText:wxStaticText
		Local sl:wxStaticLine

		VPanelList = CreateList()
		CheckBoxList = CreateList()
		GDFNameList = CreateList()
		GameNameList = CreateList()
		EXEName = CreateList()
			
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
		ReadGDFFolder = ReadDir(TEMPFOLDER + "GDF")
		Local File:String
		Local GDFEXEs:String
		Local ID:String
		Local GameName:String
		Local Platform:String
		Repeat
			File = NextFile(ReadGDFFolder)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue
			PrintF(File)
			If FileType(TEMPFOLDER + "GDF\" + File + "\Data.txt") = 0 Then
				DeleteDir(TEMPFOLDER + "GDF\" + File , 0)
				PrintF("Folder Empty")
				Continue
			EndIf
			ReadGDFFile = ReadFile(TEMPFOLDER + "GDF\" + File + "\Data.txt")
			ReadLine(ReadGDFFile)
			ReadLine(ReadGDFFile)
			ReadLine(ReadGDFFile)
			GDFEXEs = ReadLine(ReadGDFFile)
			
			tempPanel = New wxPanel.Create(ScrollBox , - 1)
			tempPanel.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
			tempVbox = New wxBoxSizer.Create(wxHORIZONTAL)
			
			tempCheckBox = New wxCheckBox.Create(tempPanel , wxID_ANY)
			ListAddLast CheckBoxList,tempCheckBox
			tempVbox.Add(tempCheckBox,  0 , wxEXPAND | wxALL, 20)
			
			tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , File)
			ListAddLast GDFNameList , tempStaticText
			tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxALL , 20)
			
			tempGameName = New wxComboBox.Create(tempPanel , OI_GN, Null, Null)
			ListAddLast GameNameList , tempGameName
			tempVbox.Add(tempGameName , 1 , wxEXPAND | wxALL , 20)			

			tempEXEName = New wxComboBox.Create(tempPanel , wxID_ANY, Null, Null, -1, -1, -1, -1, wxCB_READONLY)
			ListAddLast EXEName , tempEXEName
			tempVbox.Add(tempEXEName , 1 , wxEXPAND | wxALL , 20)
			
			b=1
			For a = 1 To Len(GDFEXEs)
				If Mid(GDFEXEs , a , 1) = "|" Then
					tempEXEName.Append(Mid(GDFEXEs , b , a - b) )
					b = a + 1
				EndIf
			Next	
			tempEXEName.Append(Mid(GDFEXEs , b , a - b) )
			tempEXEName.SelectItem(0)
			
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
			If log1.LogClosed = True Then Exit
		Forever		
		CloseDir(ReadGDFFolder)
		
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
		
		Local ArrayLength:Int
		For Local i=EachIn GDFNameListArray.Dimensions()
			ArrayLength = i
			PrintF("Number of Games: "+ArrayLength)
		Next
		
		Local GDFGameName:String
		Local Dir:String
		Local GameName:String
		Local EXE:String
		Local ID:String
		Local RealName:String
		Local overwrite:String
		DeleteCreateFolder(TEMPFOLDER + "Games\")
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Processing New Games" , , , 300 , 400) )
		Log1.Show(1)
		Self.Disable()
		Self.Hide()
		For a = 0 To ArrayLength - 1
			If CheckBoxListArray[a].IsChecked() Then
				Rem
				GDFGameName = GDFNameListArray[a].GetLabel()
				PrintF("Game Checked: "+GDFGameName)
				ReadGDFFile = ReadFile(TEMPFOLDER + "GDF\" + GDFGameName + "\Data.txt")
				ReadLine(ReadGDFFile)
				ReadLine(ReadGDFFile)
				GameDir = ReadLine(ReadGDFFile)
				PrintF("Game Dir: "+GameDir)	
				CloseFile(ReadGDFFile)
				EXE = EXENameArray[a].GetValue()
				PrintF("EXE: " + EXE)
				endrem
				
				
				GDFGameName = GDFNameListArray[a].GetLabel()
				PrintF("Game Checked: " + GDFGameName)
				Log1.AddText("Processing: " + GDFGameName)
				EXE = EXENameArray[a].GetValue()
				PrintF("EXE: "+EXE)
				
				GameNode:GameType = New GameType
				GameNode.NewGame()
				
				ReadGameData = ReadFile(TEMPFOLDER + "GDF\" + GDFGameName + "\Data.txt")
				GameNode.Name = ReadLine(ReadGameData)
				GameNode.Desc = ReadLine(ReadGameData)
				Dir = ReadLine(ReadGameData)
				ReadLine(ReadGameData)
				GameNode.ReleaseDate = ReadLine(ReadGameData)
				GameNode.Cert = ReadLine(ReadGameData)
				GameNode.Dev = ReadLine(ReadGameData)
				GameNode.Pub = ReadLine(ReadGameData)
				
				Local GenreList:String , SingleGenre:String
				GenreList = ReadLine(ReadGameData)+"/"
				
				Repeat
					ContinueLoop = False
					For c = 1 To Len(GenreList)
						If Mid(GenreList , c , 1) = "/" Then
							SingleGenre = Left(GenreList , c - 1)
							If SingleGenre = "" Or SingleGenre = " " Then
							
							Else
								ListAddLast(GameNode.Genres , SingleGenre )
							EndIf
							GenreList = Right(GenreList , Len(GenreList) - c)
							ContinueLoop = True
							Exit
						EndIf
					Next
					If ContinueLoop = False Then Exit
				Forever				
				ReadLine(ReadGameData)
				GameNode.Rating = ReadLine(ReadGameData)
				
				GameNode.Plat = "PC"
				GameNode.PlatformNum = 24
				
				CloseFile(ReadGameData)
				
				GameNode.RunEXE = Chr(34)+Dir + EXE+Chr(34)
				
				For b = 0 To EXENameArray[a].GetCount() - 1
					If EXE = EXENameArray[a].GetString(b) Then
					
					Else
						ListAddLast(GameNode.OEXEs , Dir + EXENameArray[a].GetString(b))
						ListAddLast(GameNode.OEXEsName , StripExt(StripDir(EXENameArray[a].GetString(b))) )
					EndIf
					
				Next
				
				
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
		Local OnlineWiz:OnlineImport = OnlineImport(event.parent)
		OnlineWiz.GameNameSelect()
	End Function

	Function SelectAllFun(event:wxEvent)
		Local OnlineWiz:OnlineImport = OnlineImport(event.parent)
		OnlineWiz.SelectAll()
	End Function 

	Function DeSelectAllFun(event:wxEvent)
		Local OnlineWiz:OnlineImport = OnlineImport(event.parent)
		OnlineWiz.DeSelectAll()
	End Function 

	Function PageChange(event:wxEvent)
		WizEvent:wxWizardEvent = wxWizardEvent(event)
		Local OnlineWin:OnlineImport = OnlineImport(event.parent)	
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

Type ManualSearch Extends wxFrame 
	Field ParentWin:MainWindow
	Field SearchText:wxTextCtrl
	Field SearchButton:wxButton
	Field SearchList:wxListBox
	'Field PlatList:wxComboBox
	Field UpdateCombo:wxComboBox
	Field UnHideWindow:wxWindow
	
	Method OnInit()
		ParentWin = MainWindow(GetParent())
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		panel1:wxPanel = New wxPanel.Create(Self , - 1)
		Local hbox1:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SearchTxt:wxStaticText = New wxStaticText.Create(panel1 , wxID_ANY , "Search: ")
		SearchText = New wxTextCtrl.Create(panel1 , MS_ST , "" , - 1 , - 1 , - 1 , - 1 , wxTE_PROCESS_ENTER)
		'SearchText.ChangeValue("")
		SearchButton = New wxButton.Create(panel1 , MS_SB , "Search")
		
		hbox1.Add(SearchTxt , 1 , wxEXPAND | wxALL, 10)
		hbox1.Add(SearchText , 3 , wxEXPAND | wxALL, 10)
		hbox1.Add(SearchButton , 1 , wxEXPAND | wxALL , 10)
		panel1.SetSizer(hbox1)	
		
		Rem
		panel3:wxPanel = New wxPanel.Create(Self , - 1)
		Local hbox3:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		PlatText:wxStaticText = New wxStaticText.Create(panel3 , wxID_ANY , "Platform: ")
		PlatList = New wxComboBox.Create(panel3, MS_PL, "PC", PLATFORMS, -1, -1, -1, -1, wxCB_DROPDOWN)
		

		hbox3.Add(PlatText , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10)
		hbox3.Add(PlatList , 3 , wxEXPAND | wxLEFT | wxRIGHT , 10)
		hbox3.AddStretchSpacer(1)
		
		panel3.SetSizer(hbox3)
		endrem			
		
		SearchList = New wxListBox.Create(Self,MS_SL,Null,-1,-1,-1,-1,wxLB_SINGLE)
		
		panel2:wxPanel = New wxPanel.Create(Self , - 1)
		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Exitbutton = New wxButton.Create(panel2 , MS_EB , "Cancel")
		Finishbutton = New wxButton.Create(panel2 , MS_FB , "OK")
		hbox2.Add(Exitbutton , 1 , wxEXPAND | wxALL , 10)
		hbox2.AddStretchSpacer(1)
		hbox2.Add(Finishbutton , 1 , wxEXPAND | wxALL, 10)
		panel2.SetSizer(hbox2)
		
		vbox.Add(panel1 , 1 , wxEXPAND , 0)		
		'vbox.Add(panel3 , 1 , wxEXPAND  , 0)			
		vbox.Add(SearchList , 8 , wxEXPAND , 0)
		vbox.Add(panel2,  1.5 , wxEXPAND , 0)								
		SetSizer(vbox)
		Centre()		
		Self.Hide()
		Show()
		
		Connect(MS_ST , wxTE_PROCESS_ENTER , ProcessSearch)
		Connect(MS_SB  , wxEVT_COMMAND_BUTTON_CLICKED , ProcessSearch)
		Connect(MS_EB  , wxEVT_COMMAND_BUTTON_CLICKED , ExitFun)
		Connect(MS_FB , wxEVT_COMMAND_BUTTON_CLICKED , FinishFun)
		Connect(wxID_ANY , wxEVT_CLOSE , ExitFun)
		
		
	End Method

	Method Search()
		
		SText:String = SearchText.GetValue()
		SPlat:String = "PC"
		PrintF("Searching T:"+SText+" P:"+SPlat)
		Local a=1
		Local ID:String , GameName:String , Platform:String
		WriteGameList(SText , SPlat)
		SortGameList(SText)
		SearchList.Clear()
		PlaySound SearchBeep
		ReadGameSearch=ReadFile(TEMPFOLDER +"SearchGameList.txt")
		Repeat
			ID = ReadLine(ReadGameSearch)
			GameName = GameNameSanitizer(ReadLine(ReadGameSearch) )
			Platform = ReadLine(ReadGameSearch) 
			If GameName = "" Or GameName = " " Then
				If a = 1 Then
					PrintF("Appending: "+"No Search Results Returned")
					SearchList.Append("No Search Results Returned")
					Exit
				Else
					Exit
				EndIf
			EndIf
			PrintF("Appending: "+ID + "::" + GameName + "::" + Platform)
			SearchList.Append(ID + "::" + GameName + "::" + Platform)
			a=a+1
		Forever
	End Method
	
	Method SetValues(val1:wxComboBox,val2:wxWindow)
		UnHideWindow = val2
		UpdateCombo = val1
	End Method

	Function Exitfun(event:wxEvent)
		Local ManualSearchWin:ManualSearch = ManualSearch(event.parent)
		ManualSearchWin.UnHideWindow.Enable()
		ManualSearchWin.Destroy()
		PrintF("Finish Manual Search")
	End Function
	
	Function FinishFun(event:wxEvent)
		PrintF("Updating Pulldown")
		Local ManualSearchWin:ManualSearch = ManualSearch(event.parent)
		Local MessageBox:wxMessageDialog
		ItemNums:Int = ManualSearchWin.SearchList.GetCount()
		If ManualSearchWin.SearchList.GetString(0) = "No Search Results Returned" Then
			MessageBox = New wxMessageDialog.Create(Null , "No Search Results have been Returned" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()			
			Return		
		EndIf
		
		If ManualSearchWin.SearchList.GetSelection()=-1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a game from the above list" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return
		EndIf
		
	
		ManualSearchWin.UpdateCombo.Clear()
		For a = 0 To ItemNums-1
			ManualSearchWin.UpdateCombo.Append(ManualSearchWin.SearchList.GetString(a))
		Next
		ManualSearchWin.UpdateCombo.Append("Manual Search")
		
		ManualSearchWin.UpdateCombo.SetSelection(ManualSearchWin.SearchList.GetSelection())
		
		ManualSearchWin.UnHideWindow.Enable()
		ManualSearchWin.Destroy()	

	End Function

	Function ProcessSearch(event:wxEvent)
		Local ManualSearchWin:ManualSearch = ManualSearch(event.parent)
		ManualSearchWin.Search()
	End Function

End Type



