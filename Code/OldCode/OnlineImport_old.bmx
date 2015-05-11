Type OnlineImport2 Extends wxFrame
	Field ParentWin:MainWindow
	'Field SourceItemsList:wxListCtrl
	Field ScrollBox:wxScrolledWindow
	Field UnSavedChanges:Int = 0	
	
	
	Field OnlineImportList:TList
	
	
	'Field VPanelList:TList
	'Field CheckBoxList:TList
	'Field GDFNameList:TList
	'Field GameNameList:TList
	'Field EXEName:TList		
		
	Method OnInit()
		
	
		ParentWin = MainWindow(GetParent() )

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
		Local ListLine:OnlineImportListLineType
		For ListLine = EachIn Self.OnlineImportList
			If ListLine.Name.GetValue() = "Search Online For Game Data" then
				PrintF("Manual Search")
				Local ManualSearchWindow:ManualSearch = ManualSearch(New ManualSearch.Create(Self, wxID_ANY, "Manual Search", , , 600, 500) )
				ManualSearchWindow.SetValues(ListLine.Name, ListLine.Text.GetLabel() )
				ListLine.Name.SelectItem(0)
				Self.Disable()
				ManualSearchWindow.Show()
			ElseIf ListLine.Name.GetValue() = "----------" then
				ListLine.Name.SelectItem(0)
			EndIf
		Next		
	End Method

	Function GameNameSelectFun(event:wxEvent)
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		OnlineWin.GameNameSelect()
	End Function
	
	Method SelectAll()
	'	For temp2:wxCheckBox = EachIn CheckBoxList
	'		temp2.SetValue(True)
	'	Next
	End Method
	
	Method DeSelectAll()
	'	For temp2:wxCheckBox = EachIn CheckBoxList
	'		temp2.SetValue(False)
	'	Next
	End Method	

	Function SelectAllFun(event:wxEvent)
	'	Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
	'	OnlineWin.SelectAll()
	End Function

	Function DeSelectAllFun(event:wxEvent)
	'	Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
	'	OnlineWin.DeSelectAll()
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
		
		
		MainWin.Show()
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
	
		OnlineImportList = CreateList()
				
		Delay 300
			
		ReadGDFFolder = ReadDir(TEMPFOLDER + "GDF")
		Local File:String , Title:String
		Local GDFEXEs:String
		Local ID:String
		Local GameName:String
		Local Platform:String
		
		tempPanel = New wxPanel.Create(ScrollBox , - 1)
		gridbox = New wxFlexGridSizer.CreateRC(0, 3, 10, 10)		

		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Game Explorer Name", - 1, - 1, - 1, - 1, wxALIGN_CENTER)	
		gridbox.Add(tempStaticText , 1 , wxEXPAND | wxTOP , 20)		
		
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Online Database Name", - 1, - 1, - 1, - 1, wxALIGN_CENTER)
		gridbox.Add(tempStaticText , 1 , wxEXPAND | wxTOP , 20)				
		
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "EXE Name", - 1, - 1, - 1, - 1, wxALIGN_CENTER)
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
			Title = ReadLine(ReadGDFFile)
			ReadLine(ReadGDFFile)
			GDFEXEs = ReadLine(ReadGDFFile)
			
					
			tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , Title)
			gridbox.Add(tempStaticText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 20)
			
			tempGameName = New wxComboBox.Create(tempPanel , OI_GN, Null, Null, - 1, - 1, - 1, - 1, wxCB_READONLY)
			gridbox.Add(tempGameName , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 20)			

			tempEXEName = New wxComboBox.Create(tempPanel , wxID_ANY, Null, Null, - 1, - 1, - 1, - 1, wxCB_READONLY)
			gridbox.Add(tempEXEName , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 20)
			
			ListAddLast(OnlineImportList, New OnlineImportListLineType.Create(tempStaticText, tempGameName, tempEXEName) )
			
			Local tempString:String
			
			b=1
			For a = 1 To Len(GDFEXEs)
				If Mid(GDFEXEs , a , 2) = "||" then
					tempString = Mid(GDFEXEs , b , a - b)
					For c = 1 To Len(tempString)
						If Mid(tempString, c , 1) = "|" then
							tempString = Left(tempString, c - 1)
							Exit
						EndIf
					Next
					
					tempEXEName.Append(tempString )
					b = a + 2
				EndIf
			Next	
			
			tempString = Mid(GDFEXEs , b)
			For c = 1 To Len(tempString)
				If Mid(tempString, c , 1) = "|" then
					tempString = Left(tempString, c - 1)
					Exit
				EndIf
			Next			
			tempEXEName.Append(tempString )
			tempEXEName.SelectItem(0)
			
					
			tempGameName.Append("Don't Import","DONT-IMPORT")		
			tempGameName.Append("Search Online For Game Data")
			tempGameName.Append("----------", "DONT-IMPORT")			
			
			tempGameName.SelectItem(0)
			
			CloseFile(ReadGDFFile)
		Forever		
		CloseDir(ReadGDFFolder)
		gridbox.SetFlexibleDirection(wxHORIZONTAL)
		tempPanel.SetSizer(gridbox)

		
		hbox2.Add(tempPanel, 1, wxEXPAND, 0)
		
		Connect(OI_GN , wxEVT_COMMAND_COMBOBOX_SELECTED , GameNameSelectFun)
		
		hbox2.RecalcSizes()
		
		ScrollBox.SetSizer(hbox2)
		ScrollBox.SetScrollRate(10 , 10)
		Self.Update()
		ScrollBox.Update()
		'Self.SelectAll()
		PrintF("Finished Updating")
		'Log1.Destroy()		
		'Log1.Show(0)
	End Method

	Method UpdateGames()
Rem		
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
		Local EXE:String , EXEs:String
		Local ID:String
		Local RealName:String
		Local overwrite:String
		DeleteCreateFolder(TEMPFOLDER + "Games\")
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Processing New Games" , , , 300 , 400) )
		Log1.Show(1)
		Self.Disable()
		Self.Hide()
		For a = 0 To ArrayLength - 1
			If CheckBoxListArray[a].IsChecked() then			
				
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
				EXEs = ReadLine(ReadGameData)
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
				
				GameNode.Plat = "PC"
				GameNode.PlatformNum = 24
				
				CloseFile(ReadGameData)
				
				GameNode.RunEXE = Chr(34)+EXE+Chr(34)
				
				Local b = 1
				Local tempString:String, tempEXE:String, tempName:String
	
				For f = 1 To Len(EXEs)
					If Mid(EXEs , f , 2) = "||" then
						tempString = Mid(EXEs , b , f - b)
						Print tempString
						tempEXE = ""
						tempName = ""
						For e = 1 To Len(tempString)
							If Mid(tempString, e , 1) = "|" then
								tempEXE = Chr(34) + Left(tempString, e - 1) + Chr(34)
								tempName = Right(tempString , Len(tempString) - e )
								Exit
							EndIf
						Next
						If tempEXE = "" then tempEXE = Chr(34) + tempString + Chr(34)
						
						If tempEXE = GameNode.RunEXE then
						
						else
							ListAddLast(GameNode.OEXEs , tempEXE )
							ListAddLast(GameNode.OEXEsName , tempName )
						EndIf 
						
						b = f + 2
					EndIf
				Next	
					
				tempString = Mid(EXEs , b)
				Print tempString
				If tempString = "" Or tempString = " " then
				
				else
					
					tempEXE = ""
					tempName = ""
					For e = 1 To Len(tempString)
						If Mid(tempString, e , 1) = "|" then
							tempEXE = Chr(34) + Left(tempString, e - 1) + Chr(34)
							tempName = Right(tempString , Len(tempString) - e )
							Exit
						EndIf
					Next
					If tempEXE = "" then tempEXE = Chr(34) + tempString + Chr(34)
					
					If tempEXE = GameNode.RunEXE then
						
					else
						ListAddLast(GameNode.OEXEs , tempEXE )
						ListAddLast(GameNode.OEXEsName , tempName )		
					EndIf
				EndIf
				
				
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
					GameNode.DownloadGameArtWork()
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
		
		MessageBox = New wxMessageDialog.Create(Null , "Games successfully added to database" , "Info" , wxOK | wxICON_INFORMATION)
		MessageBox.ShowModal()
		MessageBox.Free()
	EndRem	
	End Method

End Type



Type OnlineImportListLineType
	Field Text:wxStaticText
	Field Name:wxComboBox
	Field EXE:wxComboBox

	Method Create:OnlineImportListLineType(Text:wxStaticText, Name:wxComboBox, EXE:wxComboBox)
		Self.Text = Text
		Self.Name = Name
		Self.EXE = EXE
		Return Self
	End Method

End Type


Type ManualSearch Extends wxFrame
	Field ParentWin:OnlineImport2
	'Field SearchText:wxTextCtrl
	'Field SearchButton:wxButton
	'Field SearchList:wxListBox
	Field UpdateCombo:wxComboBox
	
	
	Field DatabaseSearchPanel:DatabaseSearchPanelType	
	
	Method OnInit()
		ParentWin = OnlineImport2(GetParent() )
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		
		Self.DatabaseSearchPanel = DatabaseSearchPanelType(New DatabaseSearchPanelType.Create(Self, MS_DSP) )
		
		Local panel2:wxPanel = New wxPanel.Create(Self , - 1)
		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local Exitbutton:wxButton = New wxButton.Create(panel2 , MS_EB , "Cancel")
		Local Finishbutton:wxButton = New wxButton.Create(panel2 , MS_FB , "OK")
		hbox2.Add(Exitbutton , 1 , wxEXPAND | wxALL , 10)
		hbox2.AddStretchSpacer(1)
		hbox2.Add(Finishbutton , 1 , wxEXPAND | wxALL, 10)
		panel2.SetSizer(hbox2)
		
		
		vbox.Add(DatabaseSearchPanel , 1 , wxEXPAND , 0)
		vbox.Add(panel2, 0, wxEXPAND, 0)
		SetSizer(vbox)
		Centre()		
		Self.Show(0)
		Self.Show(1)
		
		Connect(wxID_ANY , wxEVT_CLOSE , Exitfun)
		Connect(MS_EB , wxEVT_COMMAND_BUTTON_CLICKED , Exitfun)
		
		Connect(MS_FB , wxEVT_COMMAND_BUTTON_CLICKED , FinishButtonFun)
		Connect(MS_DSP, wxEVT_COMMAND_SEARCHPANEL_SELECTED, FinishFun)
			
	End Method

	Method SetValues(OnlineChoiceCombo:wxComboBox, SearchString:String)
		Self.UpdateCombo = OnlineChoiceCombo
		Self.DatabaseSearchPanel.InitialSearch = SearchString
	End Method

	Function Exitfun(event:wxEvent)
		Local ManualSearchWin:ManualSearch = ManualSearch(event.parent)
		ManualSearchWin.ParentWin.Enable()
		ManualSearchWin.Destroy()
		PrintF("Finish Manual Search")
	End Function
	
	Method Destroy()
		Self.DatabaseSearchPanel.Destroy()
		Self.DatabaseSearchPanel = Null
		Super.Destroy()
	End Method	

	Function FinishButtonFun(event:wxEvent)
		Local MessageBox:wxMessageDialog
		Local ManualSearchWin:ManualSearch = ManualSearch(event.parent)
		If ManualSearchWin.DatabaseSearchPanel.SearchList.GetSelection() = wxNOT_FOUND then
			MessageBox = New wxMessageDialog.Create(Null , "Please select an item" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return
		Else
			If ManualSearchWin.DatabaseSearchPanel.SearchList.GetStringSelection() = "No Search Results Returned" then
				MessageBox = New wxMessageDialog.Create(Null , "Please select an item" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()		
				Return
			Else
				ManualSearchWin.DatabaseSearchPanel.ListItemSelected()
				Return
			EndIf
		EndIf
	End Function
	
	Function FinishFun(event:wxEvent)
		Local ManualSearchWin:ManualSearch = ManualSearch(event.parent)
		Local item:Int = ManualSearchWin.DatabaseSearchPanel.SearchList.GetSelection()
		
		ManualSearchWin.UpdateCombo.Append(ManualSearchWin.DatabaseSearchPanel.SearchList.GetString(item), ManualSearchWin.DatabaseSearchPanel.SearchSource.GetValue() + "||" + String(ManualSearchWin.DatabaseSearchPanel.SearchList.GetItemClientData(item) ) )
		ManualSearchWin.UpdateCombo.SetSelection(ManualSearchWin.UpdateCombo.GetCount() - 1)
		ManualSearchWin.ParentWin.UnSavedChanges = True
		ManualSearchWin.ParentWin.Enable()
		ManualSearchWin.Destroy()			
	End Function
	
	
End Type

Rem
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
			GameName = GameReadType.GameNameFilter(ReadLine(ReadGameSearch) )
			Platform = ReadLine(ReadGameSearch)
			If GameName = "" Or GameName = " " then
				If a = 1 then
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

EndRem
