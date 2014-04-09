Type SteamOnlineImport2 Extends wxFrame 
	Field ParentWin:MainWindow
	Field SourceItemsList:wxListCtrl 
	Field OA_SourcePath:wxTextCtrl
	Field OA_PlatCombo:wxComboBox
	Field UnSavedChanges:Int 
	
	Method OnInit()
		ParentWin = MainWindow(GetParent())

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
				
		Self.UnSavedChanges = False
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local P1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local ExplainText:String = "This window will import installed games from Steam, a popular digital distribution platform. ~n" + ..
		"If you do not know what Steam is, you don't need to use this wizard. ~n" + ..
		"This is the ONLINE version of the wizard, you must be connected to the internet AND your steam profile must be public! (Otherwise the import will fail) ~n" + ..
		"Powered By Steam (http://steampowered.com)"
		
		Local TextField = New wxStaticText.Create(Panel1 , wxID_ANY , ExplainText, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
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
		
		OutputSteam(True)
		
		SourceItemsList.ClearAll()
		
		SourceItemsList.InsertColumn(0 , "Unsaved?")
		SourceItemsList.SetColumnWidth(0, 80)
		SourceItemsList.InsertColumn(1 , "Online Data")
		SourceItemsList.SetColumnWidth(1, 200)		
		SourceItemsList.InsertColumn(2 , "Extracted Name")
		SourceItemsList.SetColumnWidth(2 , 200)
		SourceItemsList.InsertColumn(3 , "Executable")
		SourceItemsList.SetColumnWidth(3 , 200)	




		If FileType(TEMPFOLDER + "Steam")=2 Then
			Local a:Int = 0
			Local ReadSteamFolder:Int
			Local ReadSteamData:TStream
			Local File:String
			Local GameName:String
			Local SteamEXE:String
			
			ReadSteamFolder = ReadDir(TEMPFOLDER + "Steam")
			
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
				ReadSteamData = ReadFile(TEMPFOLDER + "Steam\" + File + "\Info.txt")
				GameName = ReadLine(ReadSteamData)
				SteamEXE = ReadLine(ReadSteamData)
				CloseFile(ReadSteamData)
				
				index = SourceItemsList.InsertStringItem( a , "")
				SourceItemsList.SetStringItem(index , 2 , GameName)
				SourceItemsList.SetStringItem(index , 3 , SteamEXE)				
				a = a + 1
			Forever		
			CloseDir(ReadSteamFolder)			
		EndIf
		
	End Method

	Function SaveGamesFun(event:wxEvent)
		PrintF("Saving Games - SteamOnlineImport2")
		Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(event.parent)
		OnlineWin.Hide()
		Log1.Show(1)
		Local item = - 1
		Local GName:String
		Local col1:wxListItem , col3:wxListItem
		Local MessageBox:wxMessageDialog

		Repeat	
			item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 Then Exit
			
			If OnlineWin.SourceItemsList.GetItemText(item) = "True" Then
				col1 = New wxListItem.Create()
				col1.SetId(item)
				col1.SetColumn(1)
				col1.SetMask(wxLIST_MASK_TEXT)
				OnlineWin.SourceItemsList.GetItem(col1)
				
				col3 = New wxListItem.Create()
				col3.SetId(item)
				col3.SetColumn(3)
				col3.SetMask(wxLIST_MASK_TEXT)
				OnlineWin.SourceItemsList.GetItem(col3)
				
				GName = col1.GetText()
				Local GameNode:GameType = New GameType
				
				GameNode.RunEXE = col3.GetText()
				GameNode.Plat = "PC"
				
				Local Start:Int = - 1
				Local Middle:Int = -1
				For a = 1 To Len(GName)
					If Mid(GName , a , 2) = "::" Then
						Start = a -1
						Exit
					EndIf
				Next
				For b = Start + 3 To Len(GName)
					If Mid(GName , b , 2) = "::" Then
						Middle = b
						Exit
					EndIf
				Next				
	
				GameNode.ID = Int(Left(GName , Start) )
				
				GameNode.OEXEs = CreateList()
				GameNode.OEXEsName = CreateList()
				
				Log1.AddText("Geting info for: " + GName)
				PrintF("Geting info for: " + GName)
	
				
				
				GameNode.DownloadGameInfo()
				GameNode.DownloadGameArtWork(GameUpdateMode , Log1)
				Log1.AddText("")
				
				OnlineWin.SourceItemsList.SetStringItem(item , 0 , "")					
			EndIf
			If Log1.LogClosed = True Then Exit
		Forever
		OnlineWin.UnSavedChanges = False
		MessageBox = New wxMessageDialog.Create(Null , "Completed" , "Info" , wxOK | wxICON_INFORMATION)
		MessageBox.ShowModal()
		MessageBox.Free()
	
		'Log1.Destroy()
		Log1.Show(0)
		OnlineWin.Show()
	End Function


	Function AutoSearch(event:wxEvent)
		PrintF("AutoSearch - SteamOnlineImport2")
		Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(event.parent)
		OnlineWin.Hide()
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Auto searching for games" , , , 300 , 400) )
		Log1.Show(1)
		Local item = - 1
		Local GName:String , GNameConv:String
		Local ReadGameSearch:TStream
		Local GameName:String , ID:String 
		Local col2:wxListItem
		Repeat	
			item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 Then Exit
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
			SortGameList(GName)
			ReadGameSearch=ReadFile(TEMPFOLDER +"SearchGameList.txt")
			
			ID = ReadLine(ReadGameSearch)
			GameName = GameNameSanitizer(ReadLine(ReadGameSearch) )
			If GameName = "" Or GameName = " " Then
				CloseFile(ReadGameSearch)
				Continue 
			EndIf
			
			Log1.AddText("Found: " + GameName)
			PrintF("Found: " + GameName + " item: " + ID)
			OnlineWin.SourceItemsList.SetStringItem(item , 1 , ID + "::" + GameName + "::" + "PC")
			OnlineWin.SourceItemsList.SetStringItem(item , 0 , "True")
			CloseFile(ReadGameSearch)
			If Log1.LogClosed = True Then Exit
		Forever
		OnlineWin.SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)
		OnlineWin.SourceItemsList.SetColumnWidth(3 , wxLIST_AUTOSIZE)
		OnlineWin.UnSavedChanges = True 
		
		Log1.Show(0)
		OnlineWin.Show()
		
	End Function

	Function SILKeyPress(event:wxEvent)
		Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(event.parent)
		Local KeyEvent:wxListEvent = wxListEvent(event)
		Select KeyEvent.GetKeyCode()
			Case 127 , 8
				OnlineWin.ClearGameFun(event)
			Default
			
		End Select			
	End Function

	Function ClearGameFun(event:wxEvent)
		PrintF("ClearGameFun - SteamOnlineImport2")
		Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(event.parent)
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

		PrintF("Delete item: "+item)
		OnlineWin.SourceItemsList.SetStringItem(item , 0 , "")
		OnlineWin.SourceItemsList.SetStringItem(item , 1 , "")
	End Function

	Function SetGameFun(event:wxEvent)
		PrintF("SetGameFun - SteamOnlineImport2")
		Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(event.parent)
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
		
		
		Local ManualSGWindow:ManualSGSearch = ManualSGSearch(New ManualSGSearch.Create(OnlineWin , wxID_ANY , "" , , , 800 , 600) )
		Local col2:wxListItem = New wxListItem.Create()
		col2.SetId(item)
		col2.SetColumn(2)
		col2.SetMask(wxLIST_MASK_TEXT)
		OnlineWin.SourceItemsList.GetItem(col2)
		ManualSGWindow.SetValues(OnlineWin.SourceItemsList,col2.GetText(),item)
		ManualSGWindow.Search()
		OnlineWin.Hide()
	End Function
	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = SteamOnlineImport2(event.parent).ParentWin
		MainWin.Close(True)
	End Function	

	Function ShowMainMenu(event:wxEvent)
		PrintF("Showing main menu")
		Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(event.parent)
		Local MainWin:MainWindow = SteamOnlineImport2(event.parent).ParentWin
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
		
		
		MainWin.SteamMenuField.Show()
		MainWin.SteamOnlineImport2Field.Destroy()
		MainWin.SteamOnlineImport2Field = Null 			
	End Function

End Type




Type ManualSGSearch Extends wxFrame 
	Field ParentWin:SteamOnlineImport2
	Field SearchText:wxTextCtrl
	Field SearchButton:wxButton
	Field SearchList:wxListBox
	Field SourceItemsList:wxListCtrl 
	Field ListItemNum:Int
	
	Method OnInit()
		ParentWin = SteamOnlineImport2(GetParent())
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

	Method SetValues(SourceList:wxListCtrl,SText:String,Num:Int)
		SourceItemsList = SourceList
		SearchText.ChangeValue(SText)
		ListItemNum = Num
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
	

	Function Exitfun(event:wxEvent)
		Local ManualSearchWin:ManualSGSearch = ManualSGSearch(event.parent)
		ManualSearchWin.ParentWin.Show()
		ManualSearchWin.Destroy()
		PrintF("Finish Manual Search")
	End Function
	
	Function FinishFun(event:wxEvent)
		PrintF("Updating Pulldown")
		Local ManualSearchWin:ManualSGSearch = ManualSGSearch(event.parent)
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
		
		
		
		ManualSearchWin.SourceItemsList.SetStringItem(ManualSearchWin.ListItemNum , 1 , ManualSearchWin.SearchList.GetString(ManualSearchWin.SearchList.GetSelection()))
		ManualSearchWin.SourceItemsList.SetStringItem(ManualSearchWin.ListItemNum , 0 , "True")
		ManualSearchWin.ParentWin.UnSavedChanges = True 
		ManualSearchWin.ParentWin.Show()
		ManualSearchWin.Destroy()	

	End Function

	Function ProcessSearch(event:wxEvent)
		Local ManualSearchWin:ManualSGSearch = ManualSGSearch(event.parent)
		ManualSearchWin.Search()
	End Function

End Type
