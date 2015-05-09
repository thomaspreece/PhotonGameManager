Type OnlineImport2 Extends wxFrame
	Field ParentWin:MainWindow
	Field SourceItemsList:wxListCtrl
	Field OA_SourcePath:wxTextCtrl
	Field OA_PlatCombo:wxComboBox
	Field UnSavedChanges:Int
	
	Field EXEList:TList
	
	Method OnInit()
		ParentWin = MainWindow(GetParent() )

		EXEList = CreateList()

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
				
		Self.UnSavedChanges = False
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local P1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local ExplainText:String = "Some Explain Thingy"
		
		Local TextField = New wxStaticText.Create(Panel1 , wxID_ANY , ExplainText, - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTER)
		P1hbox.Add(TextField , 1 , wxEXPAND | wxALL , 8)
		
		SourceItemsList = New wxListCtrl.Create(Self , SOI2_SIL , - 1 , - 1 , - 1 , - 1 , wxLC_REPORT | wxLC_SINGLE_SEL )
		Local Panel3:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel3.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local P3hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local SOI2_AutoButton:wxButton = New wxButton.Create(Panel3 , SOI2_P3_AB , "Auto Scan")
		Local SOI2_SetButton:wxButton = New wxButton.Create(Panel3 , SOI2_P3_SB , "Set Game")
		Local SOI2_ClearButton:wxButton = New wxButton.Create(Panel3 , SOI2_P3_CB , "Clear Game")
		Local SOI2_SaveButton:wxButton = New wxButton.Create(Panel3 , SOI2_P3_SCB , "Save Changes")
		P3hbox.Add(SOI2_AutoButton , 1 , wxEXPAND | wxALL , 8)
		P3hbox.Add(SOI2_SetButton , 1 , wxEXPAND | wxALL , 8)
		P3hbox.Add(SOI2_ClearButton , 1 , wxEXPAND | wxALL , 8)
		P3hbox.Add(SOI2_SaveButton , 1 , wxEXPAND | wxALL , 8)
		Panel3.SetSizer(P3hbox)
		

		
		Local sl2:wxStaticLine = New wxStaticLine.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		Local BackButtonPanel:wxPanel = New wxPanel.Create(Self , - 1)
		BackButtonPanel.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local BackButtonVbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		Local BackButton:wxButton = New wxButton.Create(BackButtonPanel , SOI2_EXIT , "Exit")
		BackButtonVbox.Add(BackButton , 4 , wxALIGN_LEFT | wxALL , 5)
		BackButtonPanel.SetSizer(BackButtonVbox)

		vbox.Add(Panel1 , 0 , wxEXPAND , 0)
		vbox.Add(SourceItemsList , 1 , wxEXPAND , 0)
		vbox.Add(Panel3 , 0 , wxEXPAND , 0)
		vbox.Add(sl2 , 0 , wxEXPAND , 0)
		vbox.Add(BackButtonPanel,  0 , wxEXPAND, 0)		
		SetSizer(vbox)
		Centre()		
		Hide()
		
		
		Connect(SOI2_EXIT , wxEVT_COMMAND_BUTTON_CLICKED , ShowMainMenu)
		
		'Connect(SOI2_SB , wxEVT_COMMAND_BUTTON_CLICKED , SourceBrowseFun)
		'Connect(SOI2_SU , wxEVT_COMMAND_BUTTON_CLICKED , SourceUpdateFun)
		
		Connect(SOI2_P3_CB ,wxEVT_COMMAND_BUTTON_CLICKED , ClearGameFun)
		
		Connect( SOI2_SIL, wxEVT_COMMAND_LIST_ITEM_ACTIVATED  , SetGameFun)
		Connect( SOI2_P3_SB , wxEVT_COMMAND_BUTTON_CLICKED , SetGameFun)
		
		Connect(SOI2_SIL , wxEVT_COMMAND_LIST_KEY_DOWN , SILKeyPress)
		Connect(SOI2_P3_AB , wxEVT_COMMAND_BUTTON_CLICKED , AutoSearch)
		
		Connect(SOI2_P3_SCB , wxEVT_COMMAND_BUTTON_CLICKED , SaveGamesFun)
		

		ConnectAny(wxEVT_CLOSE , CloseApp)
		
		OutputGDFs()

		SourceItemsList.ClearAll()
		
		SourceItemsList.InsertColumn(0 , "Unsaved?")
		SourceItemsList.SetColumnWidth(0, 80)
		SourceItemsList.InsertColumn(1 , "Online Data")
		SourceItemsList.SetColumnWidth(1, 200)		
		SourceItemsList.InsertColumn(2 , "Extracted Name")
		SourceItemsList.SetColumnWidth(2 , 200)
		SourceItemsList.InsertColumn(3 , "Executable")
		SourceItemsList.SetColumnWidth(3 , 200)	

		If FileType(TEMPFOLDER + "GDF") = 2 then
	
			Local SubEXEList:TList
			Local ReadGDFFolder:Int = ReadDir(TEMPFOLDER + "GDF")
			Local File:String , Title:String
			Local GDFEXEs:String
			Local b:Int, a:Int
			Local tempString:String  
			Local itemNum:Int = 0
			
			
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
				
				SubEXEList = CreateList()		
				
				b = 1
				For a = 1 To Len(GDFEXEs)
					If Mid(GDFEXEs , a , 2) = "||" then
						tempString = Mid(GDFEXEs , b , a - b)
						For c = 1 To Len(tempString)
							If Mid(tempString, c , 1) = "|" then
								tempString = Left(tempString, c - 1)
								Exit
							EndIf
						Next
						ListAddLast(SubEXEList, tempString)
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
				ListAddLast(SubEXEList, tempString)
				
				CloseFile(ReadGDFFile)
				
				Index = SourceItemsList.InsertStringItem( a , "")
				SourceItemsList.SetStringItem(Index , 2 , Title)
				SourceItemsList.SetStringItem(Index , 3 , "")				
				itemNum = itemNum + 1				
				
				ListAddLast(EXEList,SubEXEList)
			Forever		
			CloseDir(ReadGDFFolder)
		EndIf


	End Method

	Function SaveGamesFun(event:wxEvent)
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		?Threaded
		'Local SaveGamesThread:TThread = CreateThread(Thread_SaveGames_SOI, OnlineWin)
		?Not Threaded
		'Thread_SaveGames_SOI(OnlineWin)
		?	
	End Function


	Function AutoSearch(event:wxEvent)
		PrintF("AutoSearch - SteamOnlineImport2")
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		OnlineWin.Hide()
		Log1.Show(1)
		Local item = - 1
		Local GName:String , GNameConv:String
		Local ReadGameSearch:TStream
		Local GameName:String , ID:String
		Local col2:wxListItem
		Repeat	
			item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 then Exit
			col2 = New wxListItem.Create()
			col2.SetId(item)
			col2.SetColumn(2)
			col2.SetMask(wxLIST_MASK_TEXT)
			OnlineWin.SourceItemsList.GetItem(col2)
			GName = col2.GetText()
			Log1.AddText("Searching: " + GName)
			PrintF("Searching: " + GName + " item: " + item)
			
			GNameConv = SanitiseForInternet(GName)
			
			WriteGameList(GNameConv , "PC")
			DatabaseApp.Yield()
			SortGameList(GName)
			ReadGameSearch = ReadFile(TEMPFOLDER + "SearchGameList.txt")
			
			ID = ReadLine(ReadGameSearch)
			GameName = GameReadType.GameNameFilter(ReadLine(ReadGameSearch) )
			If GameName = "" Or GameName = " " then
				CloseFile(ReadGameSearch)
				Continue
			EndIf
			
			Log1.AddText("Found: " + GameName)
			PrintF("Found: " + GameName + " item: " + ID)
			OnlineWin.SourceItemsList.SetStringItem(item , 1 , ID + "::" + GameName + "::" + "PC")
			OnlineWin.SourceItemsList.SetStringItem(item , 0 , "True")
			CloseFile(ReadGameSearch)
			If Log1.LogClosed = True Then Exit
			DatabaseApp.Yield()
		Forever
		OnlineWin.SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)
		OnlineWin.SourceItemsList.SetColumnWidth(3 , wxLIST_AUTOSIZE)
		OnlineWin.UnSavedChanges = True 
		
		Log1.Show(0)
		OnlineWin.Show()
		
	End Function

	Function SILKeyPress(event:wxEvent)
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		Local KeyEvent:wxListEvent = wxListEvent(event)
		Select KeyEvent.GetKeyCode()
			Case 127 , 8
				OnlineWin.ClearGameFun(event)
			Default
			
		End Select			
	End Function

	Function ClearGameFun(event:wxEvent)
		PrintF("ClearGameFun - SteamOnlineImport2")
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		Local MessageBox:wxMessageDialog
		Local item:Int
		item = OnlineWin.SourceItemsList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		If item = - 1 then
			MessageBox = New wxMessageDialog.Create(Null , "Please select an item" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			PrintF("No item selected, exit")		
			Return
		EndIf

		PrintF("Delete item: " + item)
		OnlineWin.SourceItemsList.SetStringItem(item , 0 , "")
		OnlineWin.SourceItemsList.SetStringItem(item , 1 , "")
	End Function

	Function SetGameFun(event:wxEvent)
		PrintF("SetGameFun - OnlineImport2")
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		Local MessageBox:wxMessageDialog
		Local item:Int
		item = OnlineWin.SourceItemsList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		
		If item = - 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select an item" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			PrintF("No item selected, exit")		
			Return
		EndIf
		
		
		Local ManualWindow:ManualSearch = ManualSearch(New ManualSearch.Create(OnlineWin , wxID_ANY , "" , , , 800 , 600) )
		Local col2:wxListItem = New wxListItem.Create()
		col2.SetId(item)
		col2.SetColumn(2)
		col2.SetMask(wxLIST_MASK_TEXT)
		OnlineWin.SourceItemsList.GetItem(col2)
		Local EXEList:Object[] = OnlineWin.EXEList.ToArray()
		ManualWindow.SetValues(OnlineWin.SourceItemsList, col2.GetText(), item, TList(EXEList[item]) )
		OnlineWin.Hide()
	End Function
	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = OnlineImport2(event.parent).ParentWin
		MainWin.Close(True)
	End Function	

	Function ShowMainMenu(event:wxEvent)
		PrintF("Showing main menu")
		Local OnlineWin:OnlineImport2 = OnlineImport2(event.parent)
		Local MainWin:MainWindow = OnlineWin.ParentWin
		Local MessageBox:wxMessageDialog
		If OnlineWin.UnSavedChanges = True Then
			MessageBox = New wxMessageDialog.Create(Null, "You have unsaved changes, are you sure you wish to clear them?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				MessageBox.Free()
				PrintF("Unsaved changes, exit")
				Return
				
			Else
				PrintF("Unsaved changes, continue")
				MessageBox.Free()
			End If
		EndIf
		
		
		MainWin.ImportMenuField.Show()
		MainWin.OnlineImport2Field.Destroy()
		MainWin.OnlineImport2Field = Null 			
	End Function
End Type



Type ManualSearch Extends wxFrame
	Field ParentWin:OnlineImport2
	'Field SearchText:wxTextCtrl
	'Field SearchButton:wxButton
	Field EXEListCombo:wxComboBox
	Field SourceItemsList:wxListCtrl
	Field ListItemNum:Int
	
	
	Field DatabaseSearchPanel:DatabaseSearchPanelType	
	
	Method OnInit()
		ParentWin = OnlineImport2(GetParent() )
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		
		Self.DatabaseSearchPanel = DatabaseSearchPanelType(New DatabaseSearchPanelType.Create(Self, MS_DSP) )
		
		
		Local panel1:wxPanel = New wxPanel.Create(Self , - 1)
		Local hbox1:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local EXEListComboText:wxStaticText = New wxStaticText.Create(panel1 , wxID_ANY , "Executable:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		EXEListCombo = New wxComboBox.Create(panel1, MS_CB, "", Null, - 1, - 1, - 1, - 1, wxCB_DROPDOWN | wxCB_READONLY)
		hbox1.Add(EXEListComboText , 0 , wxEXPAND | wxALL , 10)
		hbox1.Add(EXEListCombo , 1 , wxEXPAND | wxALL , 10)
		
		
		panel1.SetSizer(hbox1)
		
		
		Local panel2:wxPanel = New wxPanel.Create(Self , - 1)
		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local Exitbutton:wxButton = New wxButton.Create(panel2 , MS_EB , "Cancel")
		Local Finishbutton:wxButton = New wxButton.Create(panel2 , MS_FB , "OK")
		hbox2.Add(Exitbutton , 1 , wxEXPAND | wxALL , 10)
		hbox2.AddStretchSpacer(1)
		hbox2.Add(Finishbutton , 1 , wxEXPAND | wxALL, 10)
		panel2.SetSizer(hbox2)
		
		
		vbox.Add(DatabaseSearchPanel , 1 , wxEXPAND , 0)
		vbox.Add(panel1, 0, wxEXPAND, 0)
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

	Method SetValues(SourceList:wxListCtrl, SText:String, Num:Int, EXEList:TList)
		SourceItemsList = SourceList
		Self.DatabaseSearchPanel.InitialSearch = SText
		ListItemNum = Num
		Local EXE:String
		For EXE = EachIn EXEList
			EXEListCombo.Append(EXE)		
		Next
		EXEListCombo.SetSelection(0)
	End Method

	Function Exitfun(event:wxEvent)
		Local ManualSearchWin:ManualSearch = ManualSearch(event.parent)
		ManualSearchWin.ParentWin.Show()
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
		
		ManualSearchWin.SourceItemsList.SetStringItem(ManualSearchWin.ListItemNum , 1 , ManualSearchWin.DatabaseSearchPanel.SearchList.GetString(item) )
		ManualSearchWin.SourceItemsList.SetStringItem(ManualSearchWin.ListItemNum , 0 , "True")
		ManualSearchWin.SourceItemsList.SetStringItem(ManualSearchWin.ListItemNum , 3 , ManualSearchWin.EXEListCombo.GetValue() )
		ManualSearchWin.SourceItemsList.SetItemData(ManualSearchWin.ListItemNum , ManualSearchWin.DatabaseSearchPanel.SearchSource.GetValue() + "||" + String(ManualSearchWin.DatabaseSearchPanel.SearchList.GetItemClientData(item) ) )
		ManualSearchWin.ParentWin.UnSavedChanges = True
		ManualSearchWin.ParentWin.Show()
		ManualSearchWin.Destroy()			
		
	End Function
	
	
End Type
