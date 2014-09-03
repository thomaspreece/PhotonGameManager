Type OnlineImport2 Extends wxFrame
	Field ParentWin:MainWindow
	'Field SourceItemsList:wxListCtrl
	Field ScrollBox:wxScrolledWindow
	Field UnSavedChanges:Int = 0	
	
	Field VPanelList:TList
	Field CheckBoxList:TList
	Field GDFNameList:TList
	Field GameNameList:TList
	Field EXEName:TList		
		
	Method OnInit()
		ParentWin = MainWindow(GetParent())

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
				
		Self.UnSavedChanges = False
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(200, 200, 255) )
		Local P1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local ExplainText:String = "This window will import installed games from Games Explorer."
		
		Local TextField = New wxStaticText.Create(Panel1 , wxID_ANY , ExplainText, - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTER)
		P1hbox.Add(TextField , 1 , wxEXPAND | wxALL , 8)
		
		Panel1.SetSizer(P1hbox)
		
		

		
		'SourceItemsList = New wxListCtrl.Create(Self , SOI2_SIL , - 1 , - 1 , - 1 , - 1 , wxLC_REPORT | wxLC_SINGLE_SEL )


		ScrollBox = New wxScrolledWindow.Create(Self)
		
		Self.UpdateList()

		
		Local sl2:wxStaticLine = New wxStaticLine.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		Local BackButtonPanel:wxPanel = New wxPanel.Create(Self , - 1)
		BackButtonPanel.SetBackgroundColour(New wxColour.Create(200, 200, 255) )
		Local BackButtonHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local BackButton:wxButton = New wxButton.Create(BackButtonPanel , OI2_EXIT , "Exit")
		Local SelectAllButton:wxButton = New wxButton.Create(BackButtonPanel , OI2_SEL , "Select All Games")
		Local DeselectAllButton:wxButton = New wxButton.Create(BackButtonPanel , OI2_DESEL , "Deselect All Games")
		Local SaveButton:wxButton = New wxButton.Create(BackButtonPanel , OI2_SAVE , "Save Games")
		BackButtonHbox.Add(BackButton , 1 , wxEXPAND | wxALL , 5)
		BackButtonHbox.AddStretchSpacer(1)
		BackButtonHbox.Add(SelectAllButton , 1 , wxEXPAND | wxALL , 5)
		BackButtonHbox.Add(DeselectAllButton , 1 , wxEXPAND | wxALL , 5)
		BackButtonHbox.AddStretchSpacer(1)
		BackButtonHbox.Add(SaveButton , 1 , wxEXPAND | wxALL , 5)
		BackButtonPanel.SetSizer(BackButtonHbox)

		vbox.Add(Panel1 , 0 , wxEXPAND , 0)
		'vbox.Add(Panel3 , 0 , wxEXPAND , 0)
		'vbox.Add(SourceItemsList , 1 , wxEXPAND , 0)
		
		
		vbox.Add(ScrollBox, 1, wxEXPAND , 0)
		vbox.Add(sl2 , 0 , wxEXPAND , 0)
		vbox.Add(BackButtonPanel, 0 , wxEXPAND, 0)		
		SetSizer(vbox)
		Centre()		
		Hide()
		
		
	
		Connect(OI2_EXIT , wxEVT_COMMAND_BUTTON_CLICKED , ShowMainMenu)

		Connect(OI2_SEL , wxEVT_COMMAND_BUTTON_CLICKED , SelectAllFun)		
		Connect(OI2_DESEL , wxEVT_COMMAND_BUTTON_CLICKED , DeSelectAllFun)	

		Connect(OI2_SAVE , wxEVT_COMMAND_BUTTON_CLICKED , SaveGamesFun)
		
		Rem	
		Connect(SOI2_P3_CB , wxEVT_COMMAND_BUTTON_CLICKED , ClearGameFun)
		
		Connect( SOI2_SIL, wxEVT_COMMAND_LIST_ITEM_ACTIVATED  , SetGameFun)
		Connect( SOI2_P3_SB , wxEVT_COMMAND_BUTTON_CLICKED , SetGameFun)
		
		Connect(SOI2_SIL , wxEVT_COMMAND_LIST_KEY_DOWN , SILKeyPress)
		Connect(SOI2_P3_AB , wxEVT_COMMAND_BUTTON_CLICKED , AutoSearch)
		
		
		EndRem

		ConnectAny(wxEVT_CLOSE , CloseApp)
		
		
	End Method

	Function SaveGamesFun(event:wxEvent)
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		OnlineWin.UpdateGames()
		OnlineWin.ShowMainMenu(event)
	End Function

	Method GameNameSelect()
		Local temp2:wxComboBox
		For temp2 = EachIn GameNameList
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
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		OnlineWin.GameNameSelect()
	End Function
	
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
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		OnlineWin.SelectAll()
	End Function 

	Function DeSelectAllFun(event:wxEvent)
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		OnlineWin.DeSelectAll()
	End Function 	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = OnlineImport2(event.parent).ParentWin
		MainWin.Close(True)
	End Function	

	Function ShowMainMenu(event:wxEvent)
		PrintF("Showing main menu")
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		Local MainWin:MainWindow = OnlineImport2(event.parent).ParentWin
		Local MessageBox:wxMessageDialog
		If OnlineWin.UnSavedChanges = True then
			MessageBox = New wxMessageDialog.Create(Null, "You have unsaved changes, are you sure you wish to clear them?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				MessageBox.Free()
				PrintF("Unsaved changes, exit")
				Return
				
			else
				PrintF("Unsaved changes, continue")
				MessageBox.Free()
			End If
		EndIf
		
		
		MainWin.ImportMenuField.Show()
		MainWin.OnlineImport2Field.Destroy()
		MainWin.OnlineImport2Field = Null 			
	End Function


	Method UpdateList()
		PrintF("Update OnlineImport List")
		OutputGDFs()
		
		Local BOLDFONT1:wxFont = New wxFont.Create()
		BOLDFONT1.SetWeight(wxFONTWEIGHT_BOLD)

		'Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local tempVbox:wxBoxSizer
		Local tempPanel:wxPanel	
							Local tempPanel1:wxPanel, tempPanel2:wxPanel	, tempPanel3:wxPanel	, tempPanel4:wxPanel	
		Local tempVbox1:wxBoxSizer, tempVbox2:wxBoxSizer, tempVbox3:wxBoxSizer, tempVbox4:wxBoxSizer
		
		Local gridbox:wxFlexGridSizer
		
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
		EndRem
		
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
		
		'tempPanel1 = New wxPanel.Create(ScrollBox , - 1)
		'tempPanel2 = New wxPanel.Create(ScrollBox , - 1)
		'tempPanel3 = New wxPanel.Create(ScrollBox , - 1)
		'tempPanel4 = New wxPanel.Create(ScrollBox , - 1)
		
		'tempVbox1 = New wxBoxSizer.Create(wxVERTICAL)
		'tempVbox2 = New wxBoxSizer.Create(wxVERTICAL)
		'tempVbox3 = New wxBoxSizer.Create(wxVERTICAL)
		'tempVbox4 = New wxBoxSizer.Create(wxVERTICAL)
		
		tempPanel = New wxPanel.Create(ScrollBox , - 1)
		gridbox = New wxFlexGridSizer.CreateRC(0, 4, 10, 10)		

		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Import?", - 1, - 1, - 1, - 1, wxALIGN_CENTER)
		'tempStaticText.SetFont(BOLDFONT1)
		gridbox.Add(tempStaticText , 1 , wxEXPAND | wxTOP, 20)
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Game Explorer Name", - 1, - 1, - 1, - 1, wxALIGN_CENTER)
		'tempStaticText.SetFont(BOLDFONT1)
		gridbox.Add(tempStaticText , 1 , wxEXPAND | wxTOP , 20)		
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Online Database Name", - 1, - 1, - 1, - 1, wxALIGN_CENTER)
		'tempStaticText.SetFont(BOLDFONT1)
		gridbox.Add(tempStaticText , 1 , wxEXPAND | wxTOP , 20)				
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "EXE Name", - 1, - 1, - 1, - 1, wxALIGN_CENTER)
		'tempStaticText.SetFont(BOLDFONT1)
		gridbox.Add(tempStaticText , 1 , wxEXPAND | wxTOP , 20)	
		
		Repeat
			File = NextFile(ReadGDFFolder)
			If File = "" then Exit
			If File = "." Or File = ".." then Continue
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
			
			
			
			
			
			'tempPanel = New wxPanel.Create(ScrollBox , - 1)
			'tempPanel.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
			'tempVbox = New wxBoxSizer.Create(wxHORIZONTAL)
			
			'tempCheckBox = New wxCheckBox.Create(tempPanel , wxID_ANY)
			tempCheckBox = New wxCheckBox.Create(tempPanel , wxID_ANY)
			ListAddLast CheckBoxList, tempCheckBox
			'tempVbox.Add(tempCheckBox , 0 , wxEXPAND | wxALL , 20)
			gridbox.Add(tempCheckBox, 0 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 20)
			
			'tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , File)
			tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , File)
			ListAddLast GDFNameList , tempStaticText
			'tempVbox.Add(tempStaticText , 0 , wxEXPAND | wxALL , 20)
			gridbox.Add(tempStaticText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 20)
			
			'tempGameName = New wxComboBox.Create(tempPanel , OI_GN, Null, Null, - 1, - 1, - 1, - 1, wxCB_READONLY)
			tempGameName = New wxComboBox.Create(tempPanel , OI_GN, Null, Null, - 1, - 1, - 1, - 1, wxCB_READONLY)
			ListAddLast GameNameList , tempGameName
			'tempVbox.Add(tempGameName , 1 , wxEXPAND | wxALL , 20)			
			gridbox.Add(tempGameName , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 20)			

			'tempEXEName = New wxComboBox.Create(tempPanel , wxID_ANY, Null, Null, - 1, - 1, - 1, - 1, wxCB_READONLY)
			tempEXEName = New wxComboBox.Create(tempPanel , wxID_ANY, Null, Null, - 1, - 1, - 1, - 1, wxCB_READONLY)
			ListAddLast EXEName , tempEXEName
			'tempVbox.Add(tempEXEName , 1 , wxEXPAND | wxALL , 20)
			gridbox.Add(tempEXEName , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 20)
			
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
			'tempPanel.SetSizer(tempVbox)
			'ListAddLast VPanelList, tempPanel
			CloseFile(ReadGDFFile)
			If Log1.LogClosed = True then Exit
		Forever		
		CloseDir(ReadGDFFolder)
		gridbox.SetFlexibleDirection(wxHORIZONTAL)
		tempPanel.SetSizer(gridbox)
		
		'tempPanel1.SetSizer(tempVbox1)
		'tempPanel2.SetSizer(tempVbox2)
		'tempPanel3.SetSizer(tempVbox3)
		'tempPanel4.SetSizer(tempVbox4)
		
		hbox2.Add(tempPanel, 1, wxEXPAND, 0)
		'hbox2.Add(tempPanel2, 0, wxALIGN_TOP, 0)
		'hbox2.Add(tempPanel3, 1, wxALIGN_TOP, 0)
		'hbox2.Add(tempPanel4, 1, wxALIGN_TOP, 0)
		
		Connect(OI_GN , wxEVT_COMMAND_COMBOBOX_SELECTED , GameNameSelectFun)
		
		Rem
		For temp2:wxPanel = EachIn VPanelList
			hbox2.Add(temp2 , 0 , wxEXPAND , 0)
			sl = New wxStaticLine.Create(ScrollBox , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
			hbox2.Add(sl , 0 , wxEXPAND , 0)			
		Next			
		hbox2.AddSpacer(60)
		EndRem
		hbox2.RecalcSizes()
		
		ScrollBox.SetSizer(hbox2)
		ScrollBox.SetScrollRate(10 , 10)
		Self.Update()
		ScrollBox.Update()
		'Self.SelectAll()
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
				If GameNode.DownloadGameInfo() = 1 then
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
			If GameName = "" Or GameName = " " then
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


