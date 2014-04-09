Type OnlineAdd Extends wxFrame 
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
			Local OA_PlatText:wxStaticText = New wxStaticText.Create(Panel1 , wxID_ANY , "Platform: " , - 1 , - 1 , - 1 , - 1)
			OA_PlatCombo = New wxComboBox.Create(Panel1, OA_PC , "PC" , JPLATFORMS , -1 , -1 , -1 , -1 , wxCB_DROPDOWN | wxCB_READONLY )			
			Local OA_SourceText:wxStaticText = New wxStaticText.Create(Panel1 , wxID_ANY , "Source: " , - 1 , - 1 , - 1 , - 1)
			OA_SourcePath = New wxTextCtrl.Create(Panel1 , OA_SP , "" , - 1 , - 1 , - 1 , - 1 , 0 )
			Local OA_SourceBrowse:wxButton = New wxButton.Create(Panel1 , OA_SB , "Browse")
		P1hbox.Add(OA_PlatText , 0 , wxEXPAND | wxALL , 8)
		P1hbox.Add(OA_PlatCombo , 0 , wxEXPAND | wxALL , 8)
		P1hbox.Add(OA_SourceText , 0 , wxEXPAND | wxALL , 8)
		P1hbox.Add(OA_SourcePath , 1 , wxEXPAND | wxALL , 8)
		P1hbox.Add(OA_SourceBrowse,  0 , wxEXPAND | wxALL, 8)
		Panel1.SetSizer(P1hbox)
		
		Local Panel2:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel2.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local P2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
			Local OA_SourceUpdate:wxButton = New wxButton.Create(Panel2 , OA_SU , "Update List")
		P2hbox.AddStretchSpacer(1)
		P2hbox.Add(OA_SourceUpdate , 1 , wxEXPAND | wxALL , 8)
		P2hbox.AddStretchSpacer(1)
		Panel2.SetSizer(P2hbox)
		
		Local sl1:wxStaticLine = New wxStaticLine.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		SourceItemsList = New wxListCtrl.Create(Self , OA_SIL , - 1 , - 1 , - 1 , - 1 , wxLC_REPORT | wxLC_SINGLE_SEL )
		
		
		Local Panel3:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel3.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local P3hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
			Local OA_AutoButton:wxButton = New wxButton.Create(Panel3 , OA_P3_AB , "Auto Scan")
			Local OA_SetButton:wxButton = New wxButton.Create(Panel3 , OA_P3_SB , "Set Game")
			Local OA_ClearButton:wxButton = New wxButton.Create(Panel3 , OA_P3_CB , "Clear Game")
			Local OA_SaveButton:wxButton = New wxButton.Create(Panel3 , OA_P3_SCB , "Save Changes")
		P3hbox.Add(OA_AutoButton , 1 , wxEXPAND | wxALL , 8)
		P3hbox.Add(OA_SetButton , 1 , wxEXPAND | wxALL , 8)
		P3hbox.Add(OA_ClearButton , 1 , wxEXPAND | wxALL , 8)
		P3hbox.Add(OA_SaveButton , 1 , wxEXPAND | wxALL , 8)
		Panel3.SetSizer(P3hbox)
		

		
		Local sl2:wxStaticLine = New wxStaticLine.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		Local BackButtonPanel:wxPanel = New wxPanel.Create(Self , - 1)
		BackButtonPanel.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local BackButtonVbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		Local BackButton:wxButton = New wxButton.Create(BackButtonPanel , OA_EXIT , "Back")
		BackButtonVbox.Add(BackButton , 4 , wxALIGN_LEFT | wxALL , 5)
		BackButtonPanel.SetSizer(BackButtonVbox)


		vbox.Add(Panel1,  0 , wxEXPAND , 0)
		vbox.Add(Panel2 , 0 , wxEXPAND , 0)
		vbox.Add(sl1 , 0 , wxEXPAND , 0)
		vbox.Add(SourceItemsList , 1 , wxEXPAND , 0)
		vbox.Add(Panel3 , 0 , wxEXPAND , 0)
		vbox.Add(sl2 , 0 , wxEXPAND , 0)
		vbox.Add(BackButtonPanel,  0 , wxEXPAND, 0)		
		SetSizer(vbox)
		Centre()		
		Hide()
		Connect(OA_EXIT , wxEVT_COMMAND_BUTTON_CLICKED , ShowMainMenu)
		Connect(OA_SB , wxEVT_COMMAND_BUTTON_CLICKED , SourceBrowseFun)
		Connect(OA_SU , wxEVT_COMMAND_BUTTON_CLICKED , SourceUpdateFun)
		Connect(OA_P3_CB ,wxEVT_COMMAND_BUTTON_CLICKED , ClearGameFun)
		
		Connect( OA_SIL, wxEVT_COMMAND_LIST_ITEM_ACTIVATED  , SetGameFun)
		Connect( OA_P3_SB , wxEVT_COMMAND_BUTTON_CLICKED , SetGameFun)
		
		Connect(OA_P3_AB , wxEVT_COMMAND_BUTTON_CLICKED , AutoSearch)
		
		Connect(OA_SIL , wxEVT_COMMAND_LIST_KEY_DOWN , SILKeyPress)
		Connect(OA_P3_SCB , wxEVT_COMMAND_BUTTON_CLICKED , SaveGamesFun)

		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method
	
	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = OnlineAdd(event.parent).ParentWin
		MainWin.Close(True)
	End Function	
	
	Function SaveGamesFun(event:wxEvent)
		PrintF("Saving Games - OnlineAdd")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		OnlineWin.Hide()
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Saving games" , , , 300 , 400) )
		Log1.Show(1)
		Local item = - 1
		Local GPlat:String = OnlineWin.OA_PlatCombo.GetValue()
		Local GName:String
		Local col2:wxListItem , col3:wxListItem, col4:wxListItem
		Repeat	
			item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 Then Exit
			
			If OnlineWin.SourceItemsList.GetItemText(item) = "True" Then
				col2 = New wxListItem.Create()
				col2.SetId(item)
				col2.SetColumn(1)
				col2.SetMask(wxLIST_MASK_TEXT)
				OnlineWin.SourceItemsList.GetItem(col2)
				col3 = New wxListItem.Create()
				col3.SetId(item)
				col3.SetColumn(2)
				col3.SetMask(wxLIST_MASK_TEXT)
				OnlineWin.SourceItemsList.GetItem(col3)
				
				If GPlat = "PC" Then
					col4 = New wxListItem.Create()
					col4.SetId(item)
					col4.SetColumn(3)
					col4.SetMask(wxLIST_MASK_TEXT)
					OnlineWin.SourceItemsList.GetItem(col4)				
				EndIf
				
				GName = col3.GetText()
				Local GameNode:GameType = New GameType
				
				If GPlat = "PC" Then
					GameNode.RunEXE = Chr(34)+col2.GetText() + FolderSlash + col4.GetText()+Chr(34)
				Else
					GameNode.ROM = col2.GetText()
					GameNode.ExtraCMD = ""
				EndIf
				GameNode.Plat = GPlat
				
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
				
				
				If EXEDatabaseOff = False Then
					Local DBFolder:String
					Local DBID:String
					Local DBEXE:String
					Local DBName:String
					If Int(Left(GName , Start)) < 0 Then
					
					Else
						If GPlat = "PC" Then
							DBFolder = SanitiseForInternet(StripDir(col2.GetText()) )
							DBEXE = SanitiseForInternet(FolderSlash + col4.GetText())
						Else
							DBFolder = SanitiseForInternet(StripExt(StripDir(col2.GetText() ) ))
							DBEXE = ""
						EndIf
						DBID = SanitiseForInternet(Int(Left(GName , Start)))
						DBName = SanitiseForInternet(Mid(GName , Start+3 , Middle-Start-3))
						s:TStream = ReadStream("http::photongamemanager.com/GamesEXEDatabase/GameSubmit.php?ID="+DBID+"&Folder="+DBFolder+"&EXE="+DBEXE+"&Name="+DBName)
			
					EndIf 
				EndIf 
				
				
				
				GameNode.DownloadGameInfo()
				GameNode.DownloadGameArtWork(GameUpdateMode , Log1)
				Log1.AddText("")
								
			EndIf
			If Log1.LogClosed = True Then Exit
		Forever
		OnlineWin.UnSavedChanges = False
		OnlineWin.SourceUpdateFun(event)
		'Log1.Destroy()
		Log1.Show(0)
		OnlineWin.Show()
	End Function
	
	Function SILKeyPress(event:wxEvent)
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		Local KeyEvent:wxListEvent = wxListEvent(event)
		Select KeyEvent.GetKeyCode()
			Case 127 , 8
				OnlineWin.ClearGameFun(event)
			Default
			
		End Select			
	End Function

	Method UpdateListWithGameData(Game:String , EXE:String = Null)
		PrintF("Updating Game - OnlineAdd")
		item = Self.SourceItemsList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		If OA_PlatCombo.GetValue() = "PC" Then
			SourceItemsList.SetStringItem(item , 0 , "True")
			SourceItemsList.SetStringItem(item , 2 , Game)
			SourceItemsList.SetStringItem(item , 3 , EXE)
			SourceItemsList.SetColumnWidth(3 , wxLIST_AUTOSIZE)
		Else
			SourceItemsList.SetStringItem(item , 0 , "True")
			SourceItemsList.SetStringItem(item , 2 , Game)
		EndIf
		Self.UnSavedChanges = True
		PrintF("Game Added: "+Game+" EXE: "+EXE)
		SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)
	End Method

	Function SourceUpdateFun(event:wxEvent)
		PrintF("Updating Source List - OnlineAdd")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		Local File:String , Folder:String
		Local MessageBox:wxMessageDialog
		Local index:Int
		Local a:Int = 0
		If OnlineWin.UnSavedChanges = True Then
			MessageBox = New wxMessageDialog.Create(Null, "You have unsaved changes, are you sure you wish to clear them?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				MessageBox.Free()
				PrintF("Unsaved Changes, exit")
				Return
				
			Else
				PrintF("Unsaved Changes, continue")
				MessageBox.Free()
			End If
		EndIf
		OnlineWin.UnSavedChanges = False
		
		Folder = OnlineWin.OA_SourcePath.GetValue()
		If Right(Folder , 1) = "/" Or Right(Folder , 1) = "\" Then
			Folder = Left(Folder , Len(Folder) - 1)
		EndIf
		If IsntNull(Folder) = False Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a folder" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			PrintF("No Folder, exit")
			Return 
		EndIf
		If FileType(Folder) = 2 Then
		Else
			MessageBox = New wxMessageDialog.Create(Null , "Source is not a folder" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			PrintF("Soucre not a Folder, exit")
			Return 		
		EndIf
		
		OnlineWin.SourceItemsList.ClearAll()
		
		OnlineWin.SourceItemsList.InsertColumn(0 , "Unsaved?")
		OnlineWin.SourceItemsList.SetColumnWidth(0, 80)
		OnlineWin.SourceItemsList.InsertColumn(1 , "Path")
		OnlineWin.SourceItemsList.InsertColumn(2 , "Game Name")
		OnlineWin.SourceItemsList.SetColumnWidth(2 , 200)
		If OnlineWin.OA_PlatCombo.GetValue() = "PC" Then
			OnlineWin.SourceItemsList.InsertColumn(3 , "Executable")
			OnlineWin.SourceItemsList.SetColumnWidth(3 , 200)	
		EndIf
		

		
		If Right(Folder , 1) = "\" Or Right(Folder , 1) = "/" Then
			Folder = Left(Folder, Len(Folder)-1)
		EndIf
		
		ReadFiles = ReadDir(Folder )
		Repeat
			File = NextFile(ReadFiles)
			If File="" Then Exit
			If File="." Or File=".." Then Continue
			If OnlineWin.OA_PlatCombo.GetValue() = "PC" Or OnlineWin.OA_PlatCombo.GetValue() = "Mac OS" Then
				If FileType(Folder + FolderSlash + File) = 2 Then
					index = OnlineWin.SourceItemsList.InsertStringItem( a , "")
					OnlineWin.SourceItemsList.SetStringItem(index , 1 , Folder + FolderSlash + File)
					PrintF("Add to List: "+Folder + FolderSlash + File)
				EndIf
			Else
				If FileType(Folder + FolderSlash + File) = 1 Then
					index = OnlineWin.SourceItemsList.InsertStringItem( a , "")
					OnlineWin.SourceItemsList.SetStringItem(index , 1 , Folder + FolderSlash + File)
					PrintF("Add to List: "+Folder + FolderSlash + File)
				EndIf			
			EndIf
			a = a + 1		
		Forever
		CloseDir(ReadFiles)
		
		OnlineWin.SourceItemsList.SetColumnWidth(1 , wxLIST_AUTOSIZE)
		
	End Function
	
	Function SetGameFun(event:wxEvent)
		PrintF("SetGameFun - OnlineAdd")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		Local MessageBox:wxMessageDialog
		item = OnlineWin.SourceItemsList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		
		If item = - 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select an item" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			PrintF("No item selected, exit")		
			Return
		EndIf
		
		
		Local ManualGEWindow:ManualGESearch = ManualGESearch(New ManualGESearch.Create(OnlineWin , wxID_ANY , "" , , , 800 , 600) )
		Local col2:wxListItem = New wxListItem.Create()
		col2.SetId(item)
		col2.SetColumn(1)
		col2.SetMask(wxLIST_MASK_TEXT)
		OnlineWin.SourceItemsList.GetItem(col2)
		ManualGEWindow.SetValues(OnlineWin , col2.GetText() , OnlineWin.OA_PlatCombo.GetValue() )
		ManualGEWindow.Search()
		OnlineWin.Hide()
	End Function
	
	Function AutoSearch(event:wxEvent)
		PrintF("AutoSearch - OnlineAdd")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		OnlineWin.Hide()
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Auto searching for games" , , , 300 , 400) )
		Log1.Show(1)
		Local item = - 1
		Local GName:String , GPath:String , GNameConv:String
		Local GPlat:String = OnlineWin.OA_PlatCombo.GetValue()
		Local GameName:String , ID:String , Platform:String, EXE:String
		Local EXEList:TList
		Local col2:wxListItem
		Local NoStream:Int
		Repeat	
			item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 Then Exit
			col2 = New wxListItem.Create()
			col2.SetId(item)
			col2.SetColumn(1)
			col2.SetMask(wxLIST_MASK_TEXT)
			OnlineWin.SourceItemsList.GetItem(col2)
			GPath = col2.GetText()
			GName = StripExt(StripDir(GPath))
			Log1.AddText("Searching: " + GName)
			PrintF("Searching: " + GName + " item: " + item)
			
			GNameConv = SanitiseForInternet(GName)
			
			If EXEDatabaseOff = False Then
				For b = 1 To 5
					Print "Searching Stream"
					NoStream = False
					Print "http::photongamemanager.com/GamesEXEDatabase/GetGame.php?Folder="+GNameConv+"&"
					s:TStream = ReadStream("http::photongamemanager.com/GamesEXEDatabase/GetGame.php?Folder="+GNameConv+"&")
					If s = Null Then
						NoStream=True
					Else
						Print "Found Stream"
						Exit
					EndIf
				Next	
			Else
				NoStream = True
			EndIf
			ID = ""
			If NoStream=False Then
				ID = s.ReadLine()
				Print ID
			EndIf
			If ID="" Or ID=" " Then
				WriteGameList(GName , GPlat)
				SortGameList(GName)			
				ReadGameSearch=ReadFile(TEMPFOLDER +"SearchGameList.txt")
					ID = ReadLine(ReadGameSearch)
					GameName = GameNameSanitizer(ReadLine(ReadGameSearch) )
					Platform = ReadLine(ReadGameSearch)
				CloseFile(ReadGameSearch)
				If IsntNull(ID) = False Or IsntNull(GameName) = False Or IsntNull(Platform) = False Then
					Log1.AddText("Nothing Found")
					Log1.AddText("")	
					PrintF("Null Data")
					Continue
				EndIf
				
				Log1.AddText("Found: " + GameName)
				
				If GPlat = "PC" Then
					EXEList = GetEXEList(GPath , GameName)
					If CountList(EXEList) < 1 Then
						Log1.AddText("Nothing Found")
						Log1.AddText("")	
						PrintF("No EXE")			
						Continue
					EndIf
					EXE = String(EXEList.first() )
					If IsntNull(EXE) = False Then
						Log1.AddText("Nothing Found")
						Log1.AddText("")
						PrintF("Null EXE")
						Continue
					EndIf
					OnlineWin.SourceItemsList.SetStringItem(item , 3 , EXE)
					Log1.AddText("EXE: " + EXE)
				EndIf
				
				
				PrintF("Found: " + GName+ "EXE: "+EXE)
				Log1.AddText("")
				OnlineWin.SourceItemsList.SetStringItem(item , 0 , "True")
				OnlineWin.SourceItemsList.SetStringItem(item , 2 , ID+"::"+GameName+"::"+Platform)
			
			Else
				EXE:String=s.ReadLine()
				GameName:String=s.ReadLine()	
				
				Log1.AddText("Database Found: " + GameName)
				
				If GPlat = "PC" Then
					Repeat 
					If Left(EXE,1)="\" Or Left(EXE,1)="/" Then 
						EXE = Right(EXE,Len(EXE)-1)
					Else
						Exit
					EndIf 
					Forever
					
					If FileType(GPath+FolderSlash+EXE) <> 1 Then 
						EXEList = GetEXEList(GPath , GameName)
						If CountList(EXEList) < 1 Then
							Log1.AddText("Nothing Found")
							Log1.AddText("")	
							PrintF("No EXE")			
							Continue
						EndIf
						EXE = String(EXEList.first() )
						If IsntNull(EXE) = False Then
							Log1.AddText("Nothing Found")
							Log1.AddText("")
							PrintF("Null EXE")
							Continue
						EndIf
						
					EndIf 
					OnlineWin.SourceItemsList.SetStringItem(item , 3 , EXE)
					Log1.AddText("EXE: " + EXE)
				EndIf
				
				PrintF("Found: " + GName + "EXE: " + EXE)	
				Log1.AddText("")							
				OnlineWin.SourceItemsList.SetStringItem(item , 0 , "True")
				OnlineWin.SourceItemsList.SetStringItem(item , 2 , ID+"::"+GameName+"::"+GPlat)			
			EndIf	
			If NoStream=False Then
				CloseStream(s)
			EndIf
			If Log1.LogClosed = True Then Exit

			
		Forever
		OnlineWin.SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)
		If GPlat="PC"
			OnlineWin.SourceItemsList.SetColumnWidth(3 , wxLIST_AUTOSIZE)
		EndIf
		'Log1.Destroy()
		Log1.Show(0)
		OnlineWin.Show()
		
	End Function
	
	
	Function ClearGameFun(event:wxEvent)
		PrintF("ClearGameFun - OnlineAdd")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
	
		item = OnlineWin.SourceItemsList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		PrintF("Delete item: "+item)
		OnlineWin.SourceItemsList.SetStringItem(item , 0 , "")
		OnlineWin.SourceItemsList.SetStringItem(item , 2 , "")
		If OnlineWin.OA_PlatCombo.GetValue() = "PC" 
			OnlineWin.SourceItemsList.SetStringItem(item , 3 , "")
		EndIf

	End Function

	Function SourceBrowseFun(event:wxEvent)
		PrintF("Browse for source")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		Local SelectedFile:String
		?Not Win32		
		Local openFileDialog:wxDirDialog = New wxDirDialog.Create(OnlineWin, "Select Source" ,OnlineWin.OA_SourcePath.GetValue() , wxDD_DIR_MUST_EXIST)	
		If openFileDialog.ShowModal() = wxID_OK Then
			SelectedFile = openFileDialog.GetPath()
		EndIf	
		?Win32
		SelectedFile = RequestDir("Select Source" , OnlineWin.OA_SourcePath.GetValue() )
		?
		If SelectedFile = "" Then
		
		Else
			OnlineWin.OA_SourcePath.ChangeValue(SelectedFile)
		EndIf
	End Function

	Function ShowMainMenu(event:wxEvent)
		PrintF("Showing main menu")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		Local MainWin:MainWindow = OnlineAdd(event.parent).ParentWin
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
		
		
		MainWin.Show()
		MainWin.OnlineAddField.Destroy()
		MainWin.OnlineAddField = Null 			
	End Function

	Function OnQuit(event:wxEvent)
		' true is to force the frame to close
		wxWindow(event.parent).Close(True)
	End Function
End Type




Type ManualGESearch Extends wxFrame 
	Field ParentWin:OnlineAdd
	Field SearchText:wxTextCtrl
	Field SearchButton:wxButton
	Field SearchList:wxListBox
	Field EXEList:wxListBox
	Field EXETList:TList
	Field GameFilePath:String
	Field UnHideWindow:OnlineAdd
	'Field PlatText:wxStaticText
	'Field PathText:wxStaticText
	Field Platform:String
	Field RP_SText:wxStaticText
	Field EXEShown:Int
	Field SelectedGame:Int
	
	Method OnInit()
		PrintF("Initialising ManualGESearch")
		Self.EXEShown = False
		Self.SelectedGame = -1
		ParentWin = OnlineAdd(GetParent() )
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)

		
		Local LeftPanel:wxPanel = New wxPanel.Create(Self , - 1)
		LeftPanel.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local LPvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local LP_SText:wxStaticText = New wxStaticText.Create(LeftPanel , wxID_ANY , OA_LP_Text , -1 , -1 , - 1 , - 1 , wxALIGN_CENTRE)
		'PathText = New wxStaticText.Create(LeftPanel , wxID_ANY , "Path: C:\Program Files (x86)\BlitzMax\mod\wx.mod\tutorials" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)
				
		LPPanel1:wxPanel = New wxPanel.Create(LeftPanel , - 1)
		LPPanel1.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local LPP1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SearchTxt:wxStaticText = New wxStaticText.Create(LPPanel1 , wxID_ANY , "Search: ")
		SearchText = New wxTextCtrl.Create(LPPanel1 , MS_ST ,"", - 1 , - 1 , - 1 , - 1 , wxTE_PROCESS_ENTER)
		'SearchText.ChangeValue("")
		SearchButton = New wxButton.Create(LPPanel1 , MS_SB , "Search")
		
		LPP1hbox.Add(SearchTxt , 1 , wxEXPAND | wxALL, 10)
		LPP1hbox.Add(SearchText , 3 , wxEXPAND | wxALL, 10)
		LPP1hbox.Add(SearchButton , 1 , wxEXPAND | wxALL , 10)
		LPPanel1.SetSizer(LPP1hbox)	
				
		SearchList = New wxListBox.Create(LeftPanel,MS_SL,Null,-1,-1,-1,-1,wxLB_SINGLE)
		
		LPPanel2:wxPanel = New wxPanel.Create(LeftPanel , - 1)
		LPPanel2.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local LPP2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Exitbutton = New wxButton.Create(LPPanel2 , MS_EB , "Cancel")
		LPP2hbox.Add(Exitbutton , 1 , wxEXPAND | wxALL , 10)
		LPP2hbox.AddStretchSpacer(2)
		LPPanel2.SetSizer(LPP2hbox)
		
		'LPvbox.Add(PathText , 0 , wxEXPAND , 0)
		LPvbox.Add(LP_SText , 0 , wxEXPAND , 0)	
		LPvbox.Add(LPPanel1 , 1 , wxEXPAND , 0)					
		LPvbox.Add(SearchList , 10 , wxEXPAND , 0)
		LPvbox.Add(LPPanel2,  0 , wxEXPAND , 0)								
		LeftPanel.SetSizer(LPvbox)
		
		
		Local RightPanel:wxPanel = New wxPanel.Create(Self , - 1)
		RightPanel.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local RPvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'PlatText = New wxStaticText.Create(RightPanel , wxID_ANY , "Path: PC" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)		
		RP_SText = New wxStaticText.Create(RightPanel , wxID_ANY , OA_RP_Text , -1 , -1 , - 1 , - 1 , wxALIGN_CENTRE)

		EXEList = New wxListBox.Create(RightPanel,MS_EL,Null,-1,-1,-1,-1,wxLB_SINGLE)
		
		RPPanel2:wxPanel = New wxPanel.Create(RightPanel , - 1)
		RPPanel2.SetBackgroundColour(New wxColour.Create(200,200,255))
		Local RPP2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Finishbutton = New wxButton.Create(RPPanel2 , MS_FB , "OK")
		RPP2hbox.AddStretchSpacer(2)
		RPP2hbox.Add(Finishbutton , 1 , wxEXPAND | wxALL, 10)
		RPPanel2.SetSizer(RPP2hbox)

		'RPvbox.Add(PlatText , 0 , wxEXPAND , 0)
		RPvbox.Add(RP_SText , 0 , wxEXPAND , 0)
		RPvbox.Add(EXEList , 1 , wxEXPAND , 0)
		RPvbox.Add(RPPanel2 , 0 , wxEXPAND , 0)
		RightPanel.SetSizer(RPvbox)
		
		hbox.Add(LeftPanel , 1 , wxEXPAND , 0)
		hbox.Add(RightPanel , 1 , wxEXPAND , 0)
		
		SetSizer(hbox)
		Centre()		
		Self.Hide()
		Show()
		
		Connect(MS_ST , wxTE_PROCESS_ENTER , ProcessSearch)
		Connect(MS_SB  , wxEVT_COMMAND_BUTTON_CLICKED , ProcessSearch)
		Connect(MS_EB , wxEVT_COMMAND_BUTTON_CLICKED , ExitFun)
		Connect(MS_SL, wxEVT_COMMAND_LISTBOX_DOUBLECLICKED ,GameSelectedFun)
		
		Connect(MS_EL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , OkClickedFun)
		Connect(MS_FB , wxEVT_COMMAND_BUTTON_CLICKED , OkClickedFun)
		
		'Connect(MS_FB , wxEVT_COMMAND_BUTTON_CLICKED , FinishFun)
		Connect(wxID_ANY , wxEVT_CLOSE , ExitFun)
		
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method
	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = OnlineAdd(ManualGESearch(event.parent).ParentWin).ParentWin
		MainWin.Close(True)
	End Function	


	Method Search()
		PrintF("Search - ManualGESearch")
		Self.EXEShown = False
		Self.SelectedGame = - 1
		Self.EXEList.Clear()		
		SText:String = SearchText.GetValue()
		SPlat:String = Self.Platform
		PrintF("Searching T:"+SText+" P:"+SPlat)
		Local a=1
		Local ID:String , GameName:String , Platform:String
		If SPlat = "All" Then SPlat = ""
		DeleteFile(TEMPFOLDER +"SearchGameList.txt")
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

	

	Method SetValues(val1:OnlineAdd , val2:String , val3:String)
		PrintF("Initialising Values")
		Self.UnHideWindow = val1
		Self.GameFilePath = val2
		Self.Platform = val3
		Self.SetTitle("Searching for: " + val2 + " (" + val3 + ")")
		Self.Update()
		PrintF("FilePath: "+val2+" Plat: "+val3)
		If Self.Platform = "PC" Then
		
		Else
			Self.RP_SText.SetLabel("")
			Self.EXEList.Hide()
		EndIf
		SearchText.ChangeValue(StripExt(StripDir(Self.GameFilePath)))
	End Method

	Function OkClickedFun(event:wxEvent)
		PrintF("OkClickedFun - ManualGESearch")
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		Local MessageBox:wxMessageDialog
		Local item:Int = ManualGESearchWin.SearchList.GetSelection()
		If item = - 1 Or ManualGESearchWin.SearchList.GetString(item)= "No Search Results Returned" Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a game" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			PrintF("No game selected")	
			Return
		EndIf
		
		If ManualGESearchWin.Platform = "PC" Then
			If item = ManualGESearchWin.SelectedGame Then
			Else
				ManualGESearchWin.EXEShown = False
				PrintF("Selected Game Changed")
			EndIf
			
			If ManualGESearchWin.EXEShown = False Then
				ManualGESearchWin.GameSelectedFun(event)
			ElseIf ManualGESearchWin.EXEShown = True
				Local EXEitem:Int = ManualGESearchWin.EXEList.GetSelection()
				If EXEitem = - 1 Or ManualGESearchWin.EXEList.GetString(EXEitem)= "No Executables Found" Then
					MessageBox = New wxMessageDialog.Create(Null , "Please select an executable" , "Error" , wxOK | wxICON_ERROR)
					MessageBox.ShowModal()
					PrintF("No executable selected")
					MessageBox.Free()		
					Return
				EndIf
				ManualGESearchWin.UnHideWindow.UpdateListWithGameData(ManualGESearchWin.SearchList.GetString(item), ManualGESearchWin.EXEList.GetString(EXEitem))
				ManualGESearchWin.Exitfun(event)				
			EndIf
		Else
			ManualGESearchWin.UnHideWindow.UpdateListWithGameData(ManualGESearchWin.SearchList.GetString(item) )
			ManualGESearchWin.Exitfun(event)
		EndIf


	End Function
	
	Function GameSelectedFun(event:wxEvent)
		PrintF("GameSelectedFun - ManualGESearch")
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		Local MessageBox:wxMessageDialog

		If ManualGESearchWin.Platform = "PC" Then
			Local item:Int = ManualGESearchWin.SearchList.GetSelection()
			If item = - 1 Or ManualGESearchWin.SearchList.GetString(item)= "No Search Results Returned" Then
				MessageBox = New wxMessageDialog.Create(Null , "Please select a game" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()	
				PrintF("No game selected")	
				Return
			EndIf			
			ManualGESearchWin.SelectedGame = item
			GName:String = ManualGESearchWin.SearchList.GetString(item)
			PrintF("Selected: "+item+" "+GName)
			Local Start:Int = -1
			Local Finish:Int = -1
			For a = 1 To Len(GName)
				If Mid(GName , a , 2) = "::" Then
					If Start = - 1 Then
						Start = a + 2
					Else
						Finish = a 
						Exit
					EndIf
				EndIf
			Next
			GName = Mid(GName , Start , Finish-Start)
		
			ManualGESearchWin.EXETList = GetEXEList(ManualGESearchWin.GameFilePath , GName)
			ManualGESearchWin.EXEList.Clear()
			PrintF("Populating EXEList")
			For EXE:String = EachIn ManualGESearchWin.EXETList
				ManualGESearchWin.EXEList.Append(EXE)
			Next
			If CountList(ManualGESearchWin.EXETList) < 1 Then
				ManualGESearchWin.EXEList.Append("No Executables Found")
			EndIf
			ManualGESearchWin.EXEShown = True
		Else
			OkClickedFun(event)
		EndIf
	End Function

	Function Exitfun(event:wxEvent)
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		ManualGESearchWin.UnHideWindow.Show()
		ManualGESearchWin.Destroy()
		ManualGESearchWin = Null 
		PrintF("Finish ManualGESearch")
	End Function


	Function ProcessSearch(event:wxEvent)
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		ManualGESearchWin.Search()
	End Function
End Type
