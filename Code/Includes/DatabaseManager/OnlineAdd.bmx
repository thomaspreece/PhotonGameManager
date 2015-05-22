Function Thread_AutoSearch:Object(obj:Object)		Local OnlineWin:OnlineAdd = OnlineAdd(obj)
		OnlineWin.Hide()
		Log1.Show(1)
		Local item = - 1
		Local GName:String , GPath:String , GNameConv:String
		Local ErrorMessage:String
		Local EXE:String
		Local EXEList:TList
		Local col2:wxListItem
		Local AutoSearchLuaFile:String = LuaHelper_GetDefaultGame()
		Local GPlat:String = OnlineWin.OA_PlatCombo.GetValue()

		Local TotalGames:Int = 0
		Local SavedGames:Int = 0
		
		Repeat
			item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 then Exit
			
			TotalGames = TotalGames + 1
		Forever
		
		item = - 1	

		LuaMutexLock()
		
		Local LuaList:LuaListType = New LuaListType.Create()
	
		Local LuaFile:String = LUAFOLDER + "Game" + FolderSlash + AutoSearchLuaFile + ".lua"
		If LuaHelper_LoadString(LuaVM, "", LuaFile) <> 0 then
			LuaMutexUnlock()
			Log1.Show(0)
			OnlineWin.Show()
			Return
		EndIf

		'Create Platform List
		Local LuaPlatformList:LuaListType = New LuaListType.Create()
		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "GetPlatforms")
		lua_pushinteger( LuaVM , GlobalPlatforms.GetPlatformByName(GPlat ).ID)
		lua_pushbmaxobject( LuaVM, LuaPlatformList )
		
		Result = lua_pcall(LuaVM, 2, 4, 0)
				
		If (Result <> 0) then
			ErrorMessage = luaL_checkstring(LuaVM, - 1)
		
			LuaHelper_FunctionError(LuaVM, Result , ErrorMessage)
			
			LuaMutexUnlock()
			Log1.Show(0)
			OnlineWin.Show()
			Return
		EndIf
		
		Error = luaL_checkint( LuaVM, 1 )
		
		If Error <> 0 then
			ErrorMessage = luaL_checkstring(LuaVM , 2)
			LuaHelper_FunctionError(LuaVM, Error , ErrorMessage)
			LuaMutexUnlock()
			Log1.Show(0)
			OnlineWin.Show()
			Return
		EndIf
		
		Local PlatformName:String = luaL_checkstring(LuaVM , 3)
		Local PlatformData:String = ""
		Local Platform:LuaListItemType
		
		For Platform = EachIn LuaPlatformList.List
			If Platform.ItemName = PlatformName then
				PlatformData = Platform.ClientData
				Exit
			EndIf
		Next
		
		If PlatformData = "" then
			LuaHelper_FunctionError(LuaVM, - 1 , "Could not get a platform match")
			LuaMutexUnlock()
			Log1.Show(0)
			OnlineWin.Show()
			Return
		EndIf
		
		LuaHelper_CleanStack(LuaVM)
		
		Local LuaSearchList:LuaListType
		Local NextDepth:Int
		Local NextLuaData:String
		Local NextLuaName:String
		Local SkipRepeat:Int
		
		'Repeat through list
		Repeat	
			item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 then Exit
			col2 = New wxListItem.Create()
			col2.SetId(item)
			col2.SetColumn(1)
			col2.SetMask(wxLIST_MASK_TEXT)
			OnlineWin.SourceItemsList.GetItem(col2)
			GPath = col2.GetText()
			GName = StripExt(StripDir(GPath) )
			Log1.AddText("Searching: " + GName)
			PrintF("Searching: " + GName + " item: " + item)
				
			NextDepth = 1
			NextLuaData = ""
			NextLuaName = ""
			SkipRepeat = 0
			
			'Repeat through all search depths required choosing first returned item
			
			Repeat
				LuaSearchList = New LuaListType.Create()
					
				'Get Lua Function
				lua_getfield(LuaVM, LUA_GLOBALSINDEX, "SearchGame")
				'Push PlatformNum and empty list
				lua_pushbmaxobject( LuaVM , GName)
				lua_pushbmaxobject( LuaVM , NextLuaData)
				lua_pushbmaxobject( LuaVM , PlatformData)
				lua_pushinteger( LuaVM , NextDepth)
				lua_pushbmaxobject( LuaVM, LuaInternet )
				lua_pushbmaxobject( LuaVM, LuaSearchList )
				
				Result = lua_pcall(LuaVM, 6, 4, 0)
					
				If (Result <> 0) then
					ErrorMessage = luaL_checkstring(LuaVM, - 1)
					LuaHelper_FunctionError(LuaVM, Result , ErrorMessage)
					Log1.AddText("Nothing Found")
					Log1.AddText("")	
					PrintF("Lua Search pcall Error")
					SkipRepeat = 1
					Exit
				EndIf
				
				Error = luaL_checkint( LuaVM, 1 )
				
				If Error <> 0 then
					ErrorMessage = luaL_checkstring(LuaVM , 2)
					LuaHelper_FunctionError(LuaVM, Error , ErrorMessage)
					Log1.AddText("Nothing Found")
					Log1.AddText("")	
					PrintF("Lua Search Error")
					SkipRepeat = 1
					Exit 
				EndIf
				
				
				
				NextDepth = luaL_checkint( LuaVM, 3 )
				LuaHelper_CleanStack(LuaVM)
				
				If LuaSearchList.List.Count() > 0 then
					NextLuaData = LuaListItemType(LuaSearchList.List.First() ).ClientData
					NextLuaName = LuaListItemType(LuaSearchList.List.First() ).ItemName
				Else
					Log1.AddText("Nothing Found")
					Log1.AddText("")	
					PrintF("Nothing Returned")
					SkipRepeat = 1
					Exit
				EndIf
				
				If NextDepth = 0 then
					Exit 			
				EndIf
				
			Forever
			If SkipRepeat = 1 then Continue
					
			If GlobalPlatforms.GetPlatformByName(GPlat ).PlatType = "Folder" then
				EXEList = GetEXEList(GPath , NextLuaName)
				If CountList(EXEList) < 1 then
					Log1.AddText("Nothing Found")
					Log1.AddText("")	
					PrintF("No EXE")			
					Continue
				EndIf
				EXE = String(EXEList.First() )
				If IsntNull(EXE) = False then
					Log1.AddText("Nothing Found")
					Log1.AddText("")
					PrintF("Null EXE")
					Continue
				EndIf
				OnlineWin.SourceItemsList.SetStringItem(item , 3 , EXE)
				Log1.AddText("EXE: " + EXE)
			EndIf
			
			OnlineWin.SourceItemsList.SetStringItem(item , 0 , "True")
			OnlineWin.SourceItemsList.SetStringItem(item , 2 , NextLuaName)			
			OnlineWin.SourceItemsList.SetItemData(item, AutoSearchLuaFile + "||" + NextLuaData)
			OnlineWin.UnSavedChanges = True		
			
			PrintF(AutoSearchLuaFile + "||" + NextLuaData)			
			
			Log1.AddText("Found: " + NextLuaName)
			Log1.AddText(" ")
			SavedGames = SavedGames + 1
			Log1.Progress.SetValue( (100 * SavedGames) / TotalGames)
			
			If Log1.LogClosed = True then Exit
		Forever
		LuaMutexUnlock()
		
		OnlineWin.SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)
		If GlobalPlatforms.GetPlatformByName(GPlat).PlatType = "Folder" then
			OnlineWin.SourceItemsList.SetColumnWidth(3 , wxLIST_AUTOSIZE)
		EndIf		
		
		'Log1.Destroy()
		Delay 2000
		Log1.Show(0)
		OnlineWin.Show()
End Function



Function Thread_SaveGames:Object(obj:Object)
	PrintF("Saving Games - OnlineAdd")
	Local OnlineWin:OnlineAdd = OnlineAdd(obj)
	Local MessageBox:wxMessageDialog
	LuaInternet.Reset()
	OnlineWin.Hide()
	Log1.Show(1)
	Local item = - 1
	Local GPlat:String = OnlineWin.OA_PlatCombo.GetValue()
	Local GName:String
	Local ClientData:String
	Local GPlatType:PlatformType = GlobalPlatforms.GetPlatformByName(GPlat)
	Local col2:wxListItem , col3:wxListItem, col4:wxListItem
	
	Local TotalGames:Int = 0
	Local SavedGames:Int = 0
	
	Repeat
		item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
		If item = - 1 then Exit
		
		If OnlineWin.SourceItemsList.GetItemText(item) = "True" then
			TotalGames = TotalGames + 1
		EndIf
	Forever
	
	item = - 1	
	
	Repeat	
		item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
		If item = - 1 then Exit
		
		If OnlineWin.SourceItemsList.GetItemText(item) = "True" then
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
			
			If GPlatType.PlatType = "Folder" then
				col4 = New wxListItem.Create()
				col4.SetId(item)
				col4.SetColumn(3)
				col4.SetMask(wxLIST_MASK_TEXT)
				OnlineWin.SourceItemsList.GetItem(col4)				
			EndIf
			
			GName = col3.GetText()
			Local GameNode:GameType = New GameType
			
			If GPlatType.PlatType = "Folder" then
				GameNode.RunEXE = Chr(34)+col2.GetText() + FolderSlash + col4.GetText()+Chr(34)
			Else
				GameNode.ROM = col2.GetText()
				GameNode.ExtraCMD = ""
			EndIf
			GameNode.Plat = GPlat
			GameNode.PlatformNum = GPlatType.ID
			
			ClientData = String(OnlineWin.SourceItemsList.GetItemData(item) )
			
			For a = 1 To Len(ClientData)
				If Mid(ClientData, a, 2) = "||" then
					GameNode.LuaFile = Left(ClientData, a - 1) + ".lua"
					GameNode.LuaIDData = Right(ClientData, Len(ClientData) - a - 1)
					Exit
				EndIf
			Next
			
			GameNode.OEXEs = CreateList()
			GameNode.OEXEsName = CreateList()
			
			Log1.AddText( "Geting info for: " + GName)
			PrintF("Geting info for: " + GName)
			
			
			GameNode.DownloadGameInfo()
			
			GameNode.OverideArtwork = 1
			GameNode.DownloadGameArtWork()
			GameNode.ExtractIcon()

			OnlineWin.SourceItemsList.SetStringItem(item , 0 , "")	
			SavedGames = SavedGames + 1
			
			Log1.Progress.SetValue( (100 * SavedGames) / TotalGames)		
		EndIf
		If Log1.LogClosed = True then Exit
	Forever
	
	If SavedGames = TotalGames then
		OnlineWin.UnSavedChanges = False
	EndIf
	'OnlineWin.SourceUpdate()
	
	MessageBox = New wxMessageDialog.Create(Null , "Saved " + String(SavedGames) + "/" + String(TotalGames) + " Successfully" , "Info" , wxOK | wxICON_INFORMATION)
	MessageBox.ShowModal()
	MessageBox.Free()
	
	Log1.Show(0)
	OnlineWin.Show()
End Function


Type OnlineAdd Extends wxFrame
	Field ParentWin:MainWindow
	Field SourceItemsList:wxListCtrl
	Field OA_SourcePath:wxTextCtrl
	Field OA_PlatCombo:wxComboBox
	Field UnSavedChanges:Int 
	
	Method OnInit()
		ParentWin = MainWindow(GetParent() )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
				
		Self.UnSavedChanges = False
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local P1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local OA_PlatText:wxStaticText = New wxStaticText.Create(Panel1 , wxID_ANY , "Platform: " , - 1 , - 1 , - 1 , - 1)
		OA_PlatCombo = New wxComboBox.Create(Panel1, OA_PC , GlobalPlatforms.GetPlatformByID(24).Name , GlobalPlatforms.GetPlatformNameList() , - 1 , - 1 , - 1 , - 1 , wxCB_DROPDOWN | wxCB_READONLY )	
							
		If OnlineAddPlatform = "" then 					
			OA_PlatCombo.SetValue(GlobalPlatforms.GetPlatformByID(24).Name)
		Else
			OA_PlatCombo.SetValue(OnlineAddPlatform)
		EndIf
		
		Local OA_SourceText:wxStaticText = New wxStaticText.Create(Panel1 , wxID_ANY , "Source: " , - 1 , - 1 , - 1 , - 1)
		OA_SourcePath = New wxTextCtrl.Create(Panel1 , OA_SP , OnlineAddSource , - 1 , - 1 , - 1 , - 1 , 0 )
		Local OA_SourceBrowse:wxButton = New wxButton.Create(Panel1 , OA_SB , "Browse")
		P1hbox.Add(OA_PlatText , 0 , wxEXPAND | wxALL , 8)
		P1hbox.Add(OA_PlatCombo , 0 , wxEXPAND | wxALL , 8)
		P1hbox.Add(OA_SourceText , 0 , wxEXPAND | wxALL , 8)
		P1hbox.Add(OA_SourcePath , 1 , wxEXPAND | wxALL , 8)
		P1hbox.Add(OA_SourceBrowse,  0 , wxEXPAND | wxALL, 8)
		Panel1.SetSizer(P1hbox)
		
		Local Panel2:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel2.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue))
		Local P2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
			Local OA_SourceUpdate:wxButton = New wxButton.Create(Panel2 , OA_SU , "Update List")
		P2hbox.AddStretchSpacer(1)
		P2hbox.Add(OA_SourceUpdate , 1 , wxEXPAND | wxALL , 8)
		P2hbox.AddStretchSpacer(1)
		Panel2.SetSizer(P2hbox)
		
		Local sl1:wxStaticLine = New wxStaticLine.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		SourceItemsList = New wxListCtrl.Create(Self , OA_SIL , - 1 , - 1 , - 1 , - 1 , wxLC_REPORT | wxLC_SINGLE_SEL )
		
		Local Panel3:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel3.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue))
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
		BackButtonPanel.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local BackButtonVbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local BackButton:wxButton = New wxButton.Create(BackButtonPanel , OA_EXIT , "Back")
		BackButtonVbox.Add(BackButton , 1 , wxALIGN_LEFT | wxALL , 5)
		BackButtonVbox.AddStretchSpacer(4)
		BackButtonPanel.SetSizer(BackButtonVbox)
		
		
		Local HelpPanel:wxPanel = New wxPanel.Create(Self)
		HelpPanel.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local HelpPanelSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local HelpText:wxTextCtrl = New wxTextCtrl.Create(HelpPanel, wxID_ANY, "Online Add", - 1, - 1, - 1, - 1, wxTE_READONLY | wxTE_MULTILINE | wxTE_CENTER)
		HelpText.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		HelpPanelSizer.Add(HelpText, 1, wxEXPAND | wxALL, 10)
		HelpPanel.SetSizer(HelpPanelSizer)
		
		vbox.Add(HelpPanel, 0 , wxEXPAND, 0)
		
		vbox.Add(Panel1, 0 , wxEXPAND , 0)
		vbox.Add(Panel2 , 0 , wxEXPAND , 0)
		vbox.Add(sl1 , 0 , wxEXPAND , 0)
		vbox.Add(SourceItemsList , 1 , wxEXPAND , 0)
		vbox.Add(Panel3 , 0 , wxEXPAND , 0)
		vbox.Add(sl2 , 0 , wxEXPAND , 0)
		vbox.Add(BackButtonPanel, 0 , wxEXPAND, 0)		
		SetSizer(vbox)
		Centre()		
		Hide()
		If PMMaximize = 1 then
			Self.Maximize(1)
		EndIf 		
		
		Connect(OA_PC, wxEVT_COMMAND_COMBOBOX_SELECTED, SaveComboPlatform)
		Connect(OA_EXIT , wxEVT_COMMAND_BUTTON_CLICKED , ShowMainMenu)
		Connect(OA_SB , wxEVT_COMMAND_BUTTON_CLICKED , SourceBrowseFun)
		Connect(OA_SU , wxEVT_COMMAND_BUTTON_CLICKED , SourceUpdateFun)
		Connect(OA_P3_CB , wxEVT_COMMAND_BUTTON_CLICKED , ClearGameFun)
		
		Connect( OA_SIL, wxEVT_COMMAND_LIST_ITEM_ACTIVATED  , SetGameFun)
		Connect( OA_P3_SB , wxEVT_COMMAND_BUTTON_CLICKED , SetGameFun)
		
		Connect(OA_P3_AB , wxEVT_COMMAND_BUTTON_CLICKED , AutoSearch)
		
		Connect(OA_SIL , wxEVT_COMMAND_LIST_KEY_DOWN , SILKeyPress)
		Connect(OA_P3_SCB , wxEVT_COMMAND_BUTTON_CLICKED , SaveGamesFun)

		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method

	Function SaveComboPlatform(event:wxEvent)
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		OnlineAddPlatform = OnlineWin.OA_PlatCombo.GetValue()
		SaveManagerSettings()
	End Function
	
	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = OnlineAdd(event.parent).ParentWin
		MainWin.Close(True)
	End Function	
	
	Function SaveGamesFun(event:wxEvent)
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		?Threaded
		Local SaveGamesThread:TThread = CreateThread(Thread_SaveGames, OnlineWin)
		?Not Threaded
		Thread_SaveGames(OnlineWin)
		?
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

	Method UpdateListWithGameData(Game:String , Obj:Object, EXE:String = Null)
		PrintF("Updating Game - OnlineAdd")
		item = Self.SourceItemsList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		If GlobalPlatforms.GetPlatformByName(OA_PlatCombo.GetValue() ).PlatType = "Folder" then
			SourceItemsList.SetStringItem(item , 0 , "True")
			SourceItemsList.SetStringItem(item , 2 , Game )
			SourceItemsList.SetStringItem(item , 3 , EXE)
			SourceItemsList.SetItemData(item, Obj)
			SourceItemsList.SetColumnWidth(3 , wxLIST_AUTOSIZE)
			SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)
		Else
			SourceItemsList.SetStringItem(item , 0 , "True")
			SourceItemsList.SetStringItem(item , 2 , Game)
			SourceItemsList.SetItemData(item, Obj)
			SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)
		EndIf
		Self.UnSavedChanges = True
				
		PrintF("Game Added: " + Game)
		PrintF("EXE: " + EXE)
		PrintF("ClientData: " + String(Obj) )
		SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)
	End Method

	Method SourceUpdate()
		PrintF("Updating Source List - OnlineAdd")
		Local File:String , Folder:String
		Local MessageBox:wxMessageDialog
		Local index:Int
		Local a:Int = 0
		If Self.UnSavedChanges = True then
			MessageBox = New wxMessageDialog.Create(Null, "You have unsaved changes, are you sure you wish to clear them?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO then
				MessageBox.Free()
				PrintF("Unsaved Changes, exit")
				Return
				
			else
				PrintF("Unsaved Changes, continue")
				MessageBox.Free()
			End If
		EndIf
		Self.UnSavedChanges = False
		
		Folder = Self.OA_SourcePath.GetValue()
		If Right(Folder , 1) = "/" Or Right(Folder , 1) = "\" then
			Folder = Left(Folder , Len(Folder) - 1)
		EndIf
		If IsntNull(Folder) = False then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a folder" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			PrintF("No Folder, exit")
			Return
		EndIf
		If FileType(Folder) = 2 then
		else
			MessageBox = New wxMessageDialog.Create(Null , "Source is not a folder" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			PrintF("Soucre not a Folder, exit")
			Return 		
		EndIf
		
		Self.SourceItemsList.ClearAll()
		
		Self.SourceItemsList.InsertColumn(0 , "Unsaved?")
		Self.SourceItemsList.SetColumnWidth(0, 80)
		Self.SourceItemsList.InsertColumn(1 , "Path")
		Self.SourceItemsList.InsertColumn(2 , "Game Name")
		Self.SourceItemsList.SetColumnWidth(2 , 200)
		If GlobalPlatforms.GetPlatformByName(Self.OA_PlatCombo.GetValue() ).PlatType = "Folder" then
			Self.SourceItemsList.InsertColumn(3 , "Executable")
			Self.SourceItemsList.SetColumnWidth(3 , 200)	
		EndIf
		

		
		If Right(Folder , 1) = "\" Or Right(Folder , 1) = "/" then
			Folder = Left(Folder, Len(Folder) - 1)
		EndIf
		
		ReadFiles = ReadDir(Folder )
		Repeat
			File = NextFile(ReadFiles)
			If File = "" then Exit
			If File = "." Or File = ".." then Continue
			If GlobalPlatforms.GetPlatformByName(Self.OA_PlatCombo.GetValue() ).PlatType = "Folder" then
				If FileType(Folder + FolderSlash + File) = 2 then
					index = Self.SourceItemsList.InsertStringItem( a , "")
					Self.SourceItemsList.SetStringItem(index , 1 , Folder + FolderSlash + File)
					PrintF("Add to List: " + Folder + FolderSlash + File)
				EndIf
			else
				If FileType(Folder + FolderSlash + File) = 1 then
					index = Self.SourceItemsList.InsertStringItem( a , "")
					Self.SourceItemsList.SetStringItem(index , 1 , Folder + FolderSlash + File)
					PrintF("Add to List: " + Folder + FolderSlash + File)
				EndIf			
			EndIf
			a = a + 1		
		Forever
		CloseDir(ReadFiles)
		
		Self.SourceItemsList.SetColumnWidth(1 , wxLIST_AUTOSIZE)
	End Method

	Function SourceUpdateFun(event:wxEvent)
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		OnlineWin.SourceUpdate()	
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
		'ManualGEWindow.Search()
		OnlineWin.Hide()
	End Function
	
	Function AutoSearch(event:wxEvent)
		PrintF("AutoSearch - OnlineAdd")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
		?Threaded
		Local AutoSearchThread:TThread = CreateThread(Thread_AutoSearch, OnlineWin)
		?Not Threaded
		Thread_AutoSearch(OnlineWin)
		?		
	End Function
	
	
	Function ClearGameFun(event:wxEvent)
		PrintF("ClearGameFun - OnlineAdd")
		Local OnlineWin:OnlineAdd = OnlineAdd(event.parent)
	
		item = OnlineWin.SourceItemsList.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		PrintF("Delete item: "+item)
		OnlineWin.SourceItemsList.SetStringItem(item , 0 , "")
		OnlineWin.SourceItemsList.SetStringItem(item , 2 , "")
		If GlobalPlatforms.GetPlatformByName(OnlineWin.OA_PlatCombo.GetValue() ).PlatType = "Folder" then
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
			OnlineAddSource = SelectedFile
			SaveManagerSettings()
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
				
			else
				PrintF("Unsaved changes, continue")
				MessageBox.Free()
			End If
		EndIf
		
		
		MainWin.AddGamesMenuField.Show()
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
	Field EXEList:wxListBox
	Field EXETList:TList
	Field GameFilePath:String
	Field UnHideWindow:OnlineAdd
	
	Field PlatformNum:Int
	Field RP_SText:wxStaticText
	Field GameSelected:Int
	Field SearchSource:wxComboBox
	Field DatabaseSearchPanel:DatabaseSearchPanelType
	
	Method OnInit()
		PrintF("Initialising ManualGESearch")
		Self.GameSelected = False
		ParentWin = OnlineAdd(GetParent() )
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		
		Local LeftPanel:wxPanel = New wxPanel.Create(Self , - 1)
		LeftPanel.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local LPvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		
		Self.DatabaseSearchPanel = DatabaseSearchPanelType(New DatabaseSearchPanelType.Create(LeftPanel, MS_DSP) )	
		
		Local LP_SText:wxStaticText = New wxStaticText.Create(LeftPanel , wxID_ANY , OA_LP_Text , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)
		
		LPPanel2:wxPanel = New wxPanel.Create(LeftPanel , - 1)
		LPPanel2.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local LPP2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Exitbutton = New wxButton.Create(LPPanel2 , MS_EB , "Cancel")
		LPP2hbox.Add(Exitbutton , 1 , wxEXPAND | wxALL , 10)
		LPP2hbox.AddStretchSpacer(2)
		LPPanel2.SetSizer(LPP2hbox)
		
		LPvbox.Add(LP_SText , 0 , wxEXPAND , 0)	
		LPvbox.Add(DatabaseSearchPanel, 1, wxEXPAND, 0)
		LPvbox.Add(LPPanel2, 0 , wxEXPAND , 0)								
		LeftPanel.SetSizer(LPvbox)
		
		
		Local RightPanel:wxPanel = New wxPanel.Create(Self , - 1)
		RightPanel.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue))
		Local RPvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'PlatText = New wxStaticText.Create(RightPanel , wxID_ANY , "Path: PC" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)		
		RP_SText = New wxStaticText.Create(RightPanel , wxID_ANY , OA_RP_Text , -1 , -1 , - 1 , - 1 , wxALIGN_CENTRE)

		EXEList = New wxListBox.Create(RightPanel,MS_EL,Null,-1,-1,-1,-1,wxLB_SINGLE)
		
		RPPanel2:wxPanel = New wxPanel.Create(RightPanel , - 1)
		RPPanel2.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
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
		
		'Connect(MS_ST , wxTE_PROCESS_ENTER , ProcessSearch)
		'Connect(MS_SB , wxEVT_COMMAND_BUTTON_CLICKED , ProcessSearch)
		
		'Connect(MS_SL, wxEVT_COMMAND_LISTBOX_DOUBLECLICKED ,GameSelectedFun)
		
		'Connect(MS_FB , wxEVT_COMMAND_BUTTON_CLICKED , FinishFun)
		
		Connect(MS_EL , wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , OkClickedFun)
		Connect(MS_FB , wxEVT_COMMAND_BUTTON_CLICKED , OkClickedFun)
		
		
		Connect(MS_EB , wxEVT_COMMAND_BUTTON_CLICKED , Exitfun)
		Connect(wxID_ANY , wxEVT_CLOSE , Exitfun)
		
		Connect(MS_DSP, wxEVT_COMMAND_SEARCHPANEL_SELECTED, GameSelectedFun)
		Connect(MS_DSP, wxEVT_COMMAND_SEARCHPANEL_SOURCECHANGED, ResetSearchFun)
		Connect(MS_DSP , wxEVT_COMMAND_SEARCHPANEL_NEWSEARCH, ResetSearchFun)
		
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method
	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = OnlineAdd(ManualGESearch(event.parent).ParentWin).ParentWin
		MainWin.Close(True)
	End Function	
	

	Method SetValues(val1:OnlineAdd , val2:String , val3:String)
		PrintF("Initialising Values")
		Self.UnHideWindow = val1
		Self.GameFilePath = val2
		
		Self.PlatformNum = GlobalPlatforms.GetPlatformByName(val3).ID
		Self.DatabaseSearchPanel.SetPlatformNum(Self.PlatformNum)
				
		Self.SetTitle("Searching for: " + val2 + " (" + val3 + ")")
		Self.Update()
		PrintF("FilePath: " + val2 + " Plat: " + val3)
		If GlobalPlatforms.GetPlatformByID(Self.PlatformNum).PlatType = "Folder" then
		
		Else
			Self.RP_SText.SetLabel("")
			Self.EXEList.Hide()
		EndIf
		
		DatabaseSearchPanel.InitialSearch = StripExt(StripDir(Self.GameFilePath) )
		DatabaseSearchPanel.SourceChanged()
	End Method

	Function OkClickedFun(event:wxEvent)
		PrintF("OkClickedFun - ManualGESearch")
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		Local MessageBox:wxMessageDialog
		Local item:Int = - 1
		Local EXEitem:Int
		
		If GlobalPlatforms.GetPlatformByID(ManualGESearchWin.PlatformNum ).PlatType = "Folder" then	
			If ManualGESearchWin.GameSelected = False then
				If ManualGESearchWin.DatabaseSearchPanel.SearchList.GetSelection() = wxNOT_FOUND then
					MessageBox = New wxMessageDialog.Create(Null , "Please select a item in the left box" , "Error" , wxOK | wxICON_ERROR)
					MessageBox.ShowModal()
					MessageBox.Free()	
					Return
				Else
					If ManualGESearchWin.DatabaseSearchPanel.SearchList.GetStringSelection() = "No Search Results Returned" then
						MessageBox = New wxMessageDialog.Create(Null , "Please select a item in the left box" , "Error" , wxOK | wxICON_ERROR)
						MessageBox.ShowModal()
						MessageBox.Free()		
						Return
					Else
						ManualGESearchWin.DatabaseSearchPanel.ListItemSelected()
						Return
					EndIf
				EndIf
			Else
			
				If ManualGESearchWin.EXEList.GetSelection() = wxNOT_FOUND then
					MessageBox = New wxMessageDialog.Create(Null , "Please select a item in the right box" , "Error" , wxOK | wxICON_ERROR)
					MessageBox.ShowModal()
					MessageBox.Free()		
					Return
				else
					If ManualGESearchWin.EXEList.GetStringSelection() = "No Executables Found" then
						MessageBox = New wxMessageDialog.Create(Null , "Please select a item in the right box" , "Error" , wxOK | wxICON_ERROR)
						MessageBox.ShowModal()
						MessageBox.Free()		
						Return
					Else
						'EXE and Search correct
						item = ManualGESearchWin.DatabaseSearchPanel.SearchList.GetSelection()
						EXEitem = ManualGESearchWin.EXEList.GetSelection()
						ManualGESearchWin.UnHideWindow.UpdateListWithGameData(ManualGESearchWin.DatabaseSearchPanel.SearchList.GetString(item), ManualGESearchWin.DatabaseSearchPanel.SearchSource.GetValue() + "||" + String(ManualGESearchWin.DatabaseSearchPanel.SearchList.GetItemClientData(item) ) , ManualGESearchWin.EXEList.GetString(EXEitem) )
									
						ManualGESearchWin.Exitfun(event)				
					EndIf
				EndIf
			EndIf			
		Else
		
		
			If ManualGESearchWin.DatabaseSearchPanel.SearchList.GetSelection() = wxNOT_FOUND then
				MessageBox = New wxMessageDialog.Create(Null , "Please select a item in the left box" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()	
				Return
			Else
				If ManualGESearchWin.DatabaseSearchPanel.SearchList.GetStringSelection() = "No Search Results Returned" then
					MessageBox = New wxMessageDialog.Create(Null , "Please select a item in the left box" , "Error" , wxOK | wxICON_ERROR)
					MessageBox.ShowModal()
					MessageBox.Free()		
					Return
				Else
					item = ManualGESearchWin.DatabaseSearchPanel.SearchList.GetSelection()
					ManualGESearchWin.UnHideWindow.UpdateListWithGameData(ManualGESearchWin.DatabaseSearchPanel.SearchList.GetString(item), ManualGESearchWin.DatabaseSearchPanel.SearchSource.GetValue() + "||" + String(ManualGESearchWin.DatabaseSearchPanel.SearchList.GetItemClientData(item) ) )
					ManualGESearchWin.Exitfun(event)
				EndIf
			EndIf		
		
		
		
		

		EndIf		
		
	End Function
	
	Function ResetSearchFun(event:wxEvent)
		PrintF("ResetSearchFun - ManualGESearch")
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		ManualGESearchWin.GameSelected = 0
		ManualGESearchWin.EXEList.Clear()
	End Function
	
	Function GameSelectedFun(event:wxEvent)
		'Rem
		PrintF("GameSelectedFun - ManualGESearch")
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		Local MessageBox:wxMessageDialog
		If GlobalPlatforms.GetPlatformByID(ManualGESearchWin.PlatformNum ).PlatType = "Folder" then
			Rem
			Local item:Int = ManualGESearchWin.DatabaseSearchPanel.SearchList.GetStringSelection()
			If item = - 1 Or ManualGESearchWin.SearchList.GetString(item) = "No Search Results Returned" then
				MessageBox = New wxMessageDialog.Create(Null , "Please select a game" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()	
				PrintF("No game selected")	
				Return
			EndIf			
			EndRem
			ManualGESearchWin.GameSelected = True
			
			GName:String = ManualGESearchWin.DatabaseSearchPanel.SearchText.GetStringSelection()
			
			Rem
			PrintF("Selected: " + GName)
			Local Start:Int = - 1
			Local Finish:Int = - 1
			For a = 1 To Len(GName)
				If Mid(GName , a , 2) = "::" then
					If Start = - 1 then
						Start = a + 2
					Else
						Finish = a 
						Exit
					EndIf
				EndIf
			Next
			GName = Mid(GName , Start , Finish-Start)
			EndRem
		
			ManualGESearchWin.EXETList = GetEXEList(ManualGESearchWin.GameFilePath , GName)
			ManualGESearchWin.EXEList.Clear()
			PrintF("Populating EXEList")
			For EXE:String = EachIn ManualGESearchWin.EXETList
				ManualGESearchWin.EXEList.Append(EXE)
			Next
			If CountList(ManualGESearchWin.EXETList) < 1 then
				ManualGESearchWin.EXEList.Append("No Executables Found")
			EndIf
		Else
			OkClickedFun(event)
		EndIf
		
		'EndRem
	End Function

	Function Exitfun(event:wxEvent)
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		ManualGESearchWin.UnHideWindow.Show()
		ManualGESearchWin.Destroy()
		ManualGESearchWin = Null
		PrintF("Finish ManualGESearch")
	End Function

	Method Destroy()
		Self.DatabaseSearchPanel.Destroy()
		Self.DatabaseSearchPanel = Null
		Super.Destroy()
	End Method

	Rem
	Function ProcessSearch(event:wxEvent)
		Local ManualGESearchWin:ManualGESearch = ManualGESearch(event.parent)
		ManualGESearchWin.Search()
	End Function
	EndRem
End Type
