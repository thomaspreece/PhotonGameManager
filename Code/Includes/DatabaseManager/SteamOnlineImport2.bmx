Function Thread_AutoSearch_SOI:Object(Obj:Object)
	Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(Obj)
	OnlineWin.Hide()
	Log1.Show(1)
	
	Local item = - 1
	Local GName:String , GPath:String , GNameConv:String
	Local ErrorMessage:String
	Local EXE:String
	Local EXEList:Object[]
	Local SubEXEList:TList
	Local col2:wxListItem
	Local AutoSearchLuaFile:String = LuaHelper_GetDefaultGame()
	Local GPlatNum:Int
	
	Local TotalGames:Int = 0
	Local SavedGames:Int = 0
	
	Repeat
		item = OnlineWin.SourceItemsList.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
		If item = - 1 then Exit
		
		TotalGames = TotalGames + 1
	Forever
	
	item = - 1	

	?Win32
	GPlatNum = 24
	?MacOS
	GPlatNum = 12	
	?Linux
	GPlatNum = 40
	?

	LuaMutexLock()
	
	Local LuaList:LuaListType = New LuaListType.Create()

	Local LuaFile:String = LUAFOLDER + "Game" + FolderSlash + AutoSearchLuaFile + ".lua"
	If LuaHelper_LoadString(LuaVM, "", LuaFile) <> 0 then
		LuaMutexUnlock()
		LuaHelper_FunctionError(LuaVM, - 1, "Could Not Load Lua File")
		Log1.Show(0)
		OnlineWin.Show()
		Return
	EndIf

	'Create Platform List
	Local LuaPlatformList:LuaListType = New LuaListType.Create()
	lua_getfield(LuaVM, LUA_GLOBALSINDEX, "GetPlatforms")
	lua_pushinteger( LuaVM , GPlatNum)
	lua_pushbmaxobject( LuaVM, LuaPlatformList )
	lua_pushbmaxobject( LuaVM, LUAFOLDER )
	
	Result = lua_pcall(LuaVM, 3, 4, 0)
			
	If (Result <> 0) then
		ErrorMessage = luaL_checkstring(LuaVM, - 1)
	
		LuaHelper_FunctionError(LuaVM, Result , ErrorMessage)
		
		LuaMutexUnlock()
		Log1.Show(0)
		OnlineWin.Show()
		Return
	EndIf
	
	
	If lua_isnumber(LuaVM, 1) = False then
		Error = 198
	Else		
		Error = luaL_checkint( LuaVM, 1 )
	EndIf
		
	If Error <> 0 then
		If lua_isstring(LuaVM, 2) = False Or lua_isnumber(LuaVM, 1) = False then
			ErrorMessage = "Lua code did not return int @1 or/and string @2"
		Else
			ErrorMessage = luaL_checkstring(LuaVM , 2)
		EndIf 
		LuaHelper_FunctionError(LuaVM, Error, ErrorMessage)
		LuaMutexUnlock()
		Log1.Show(0)
		OnlineWin.Show()		
		Return
	EndIf	

	If lua_isstring(LuaVM, 3) = False then
		LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return string @3")
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
		col2.SetColumn(2)
		col2.SetMask(wxLIST_MASK_TEXT)
		OnlineWin.SourceItemsList.GetItem(col2)
		GName = col2.GetText()
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
			lua_pushbmaxobject( LuaVM, LUAFOLDER )
			
			Result = lua_pcall(LuaVM, 7, 4, 0)
				
			If (Result <> 0) then
				ErrorMessage = luaL_checkstring(LuaVM, - 1)
				Log1.AddText("Nothing Found")
				Log1.AddText("(Lua Runtime error " + Result + ": " + ErrorMessage + ")")	
				Log1.AddText("")	
				PrintF("Lua Search pcall Error " + Result + ": " + ErrorMessage)
				SkipRepeat = 1
				Exit
			EndIf
			
				
			If lua_isnumber(LuaVM, 1) = False then
				Error = 198
			Else		
				Error = luaL_checkint( LuaVM, 1 )
			EndIf
				
			If Error <> 0 then
				If lua_isstring(LuaVM, 2) = False Or lua_isnumber(LuaVM, 1) = False then
					ErrorMessage = "Lua code did not return int @1 or/and string @2"
				Else
					ErrorMessage = luaL_checkstring(LuaVM , 2)
				EndIf
				Log1.AddText("Nothing Found")
				Log1.AddText("(Lua Error " + Error + ": " + ErrorMessage + ")")
				Log1.AddText("")	
				PrintF("Lua Search Error " + Error + ": " + ErrorMessage)
				SkipRepeat = 1
				Exit
			EndIf	

			If lua_isnumber(LuaVM, 3) = False then
				Log1.AddText("Nothing Found")
				Log1.AddText("(Lua Error 199: Lua code did not return int @3)")				
				Log1.AddText("")	
				PrintF("Lua Search Error 199")
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
		If SkipRepeat = 1 then
			If Log1.LogClosed = True then Exit
			Continue
		EndIf 		
		OnlineWin.SourceItemsList.SetStringItem(item , 0 , "True")
		OnlineWin.SourceItemsList.SetStringItem(item , 1 , NextLuaName)	
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
	
	OnlineWin.SourceItemsList.SetColumnWidth(1 , wxLIST_AUTOSIZE)	
	
	'Log1.Destroy()
	Delay 2000	
	
	Log1.Show(0)
	OnlineWin.Show()
End Function

Function Thread_SaveGames_SOI:Object(obj:Object)
	PrintF("Saving Games - SteamOnlineImport2")
	Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(obj)
	OnlineWin.Hide()
	Log1.Show(1)
	Local item = - 1
	Local GName:String
	Local col1:wxListItem , col3:wxListItem
	Local MessageBox:wxMessageDialog
	Local ClientData:String
	
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
			
			?Win32
			GameNode.Plat = "PC"
			GameNode.PlatformNum = 24
			?MacOS
			GameNode.Plat = "Mac OS"
			GameNode.PlatformNum = 12	
			?Linux
			GameNode.Plat = "Linux"
			GameNode.PlatformNum = 40
			?
			
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
			
			Log1.AddText("Geting info for: " + GName)
			PrintF("Geting info for: " + GName)

			
			
			GameNode.DownloadGameInfo()
			
			GameNode.OverideArtwork = 1
			GameNode.DownloadGameArtWork()
			Log1.AddText("")
			
			OnlineWin.SourceItemsList.SetStringItem(item , 0 , "")		
			SavedGames = SavedGames + 1
			
			Log1.Progress.SetValue( (100 * SavedGames) / TotalGames)	
		EndIf
		If Log1.LogClosed = True Then Exit
	Forever
	
	If SavedGames = TotalGames then
		OnlineWin.UnSavedChanges = False
	EndIf
	
	MessageBox = New wxMessageDialog.Create(Null , "Saved " + String(SavedGames) + "/" + String(TotalGames) + " Successfully" , "Info" , wxOK | wxICON_INFORMATION)
	MessageBox.ShowModal()
	MessageBox.Free()

	'Log1.Destroy()
	Log1.Show(0)
	OnlineWin.Show()
End Function


Type SteamOnlineImport2 Extends wxFrame
	Field ParentWin:MainWindow
	Field SourceItemsList:wxListCtrl 
	Field OA_SourcePath:wxTextCtrl
	Field OA_PlatCombo:wxComboBox
	Field UnSavedChanges:Int
	
	Method OnInit()
		ParentWin = MainWindow(GetParent() )

		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
				
		Self.UnSavedChanges = False
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue))
		Local P1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local ExplainText:String = "This window will import installed games from Steam, a popular digital distribution platform. ~n" + ..
		"If you do not know what Steam is, you don't need to use this wizard. ~n" + ..
		"This is the ONLINE version of the wizard, you must be connected to the internet AND your steam profile must be public! (Otherwise the import will fail) ~n" + ..
		"Powered By Steam (http://steampowered.com)"
			
		SourceItemsList = New wxListCtrl.Create(Self , SOI2_SIL , - 1 , - 1 , - 1 , - 1 , wxLC_REPORT | wxLC_SINGLE_SEL )
		Local Panel3:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel3.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue))
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
		BackButtonPanel.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local BackButtonVbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local BackButton:wxButton = New wxButton.Create(BackButtonPanel , SOI2_EXIT , "Back")
		BackButtonVbox.Add(BackButton , 1 , wxALIGN_LEFT | wxALL , 5)
		BackButtonVbox.AddStretchSpacer(4)
		BackButtonPanel.SetSizer(BackButtonVbox)


		Local HelpPanel:wxPanel = New wxPanel.Create(Self)
		HelpPanel.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local HelpPanelSizer:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local HelpText:wxTextCtrl = New wxTextCtrl.Create(HelpPanel, wxID_ANY, ExplainText, - 1, - 1, - 1, - 1, wxTE_READONLY | wxTE_MULTILINE | wxTE_CENTER)
		If PMHideHelp = 1 then
			HelpText.Hide()
		EndIf 		
		HelpText.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		HelpPanelSizer.Add(HelpText, 1, wxEXPAND | wxALL, 10)
		HelpPanel.SetSizer(HelpPanelSizer)
		
		vbox.Add(HelpPanel, 0 , wxEXPAND, 0)
		vbox.Add(Panel1 , 0 , wxEXPAND , 0)
		vbox.Add(SourceItemsList , 1 , wxEXPAND , 0)
		vbox.Add(Panel3 , 0 , wxEXPAND , 0)
		vbox.Add(sl2 , 0 , wxEXPAND , 0)
		vbox.Add(BackButtonPanel,  0 , wxEXPAND, 0)		
		SetSizer(vbox)
		Centre()		
		Hide()
		If PMMaximize = 1 then
			Self.Maximize(1)
		EndIf
		
		
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




		If FileType(TEMPFOLDER + "Steam") = 2 then
			Local a:Int = 0
			Local ReadSteamFolder:Int
			Local ReadSteamData:TStream
			Local File:String
			Local GameName:String
			Local SteamEXE:String
			
			ReadSteamFolder = ReadDir(TEMPFOLDER + "Steam")
			'FIX: FolderSlash not used here at all
			Repeat
				File = NextFile(ReadSteamFolder)
				If File = "" then Exit
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
				
				Index = SourceItemsList.InsertStringItem( a , "")
				SourceItemsList.SetStringItem(index , 2 , GameName)
				SourceItemsList.SetStringItem(index , 3 , SteamEXE)				
				a = a + 1
			Forever		
			CloseDir(ReadSteamFolder)		
			SourceItemsList.SetColumnWidth(2 , wxLIST_AUTOSIZE)				
			SourceItemsList.SetColumnWidth(3 , wxLIST_AUTOSIZE)				
		EndIf
		
	End Method

	Function SaveGamesFun(event:wxEvent)
		Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(event.parent)
		?Threaded
		Local SaveGamesThread:TThread = CreateThread(Thread_SaveGames_SOI, OnlineWin)
		?Not Threaded
		Thread_SaveGames_SOI(OnlineWin)
		?	
	End Function


	Function AutoSearch(event:wxEvent)
		PrintF("AutoSearch - SteamOnlineImport2")
		Local OnlineWin:SteamOnlineImport2 = SteamOnlineImport2(event.parent)
		
		
		?Threaded
		Local AutoSearchThread:TThread = CreateThread(Thread_AutoSearch_SOI, OnlineWin)
		?Not Threaded
		Thread_AutoSearch_SOI(OnlineWin)
		?		
		
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
		ManualSGWindow.SetValues(OnlineWin.SourceItemsList, col2.GetText(), item)
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
	'Field SearchText:wxTextCtrl
	'Field SearchButton:wxButton
	'Field SearchList:wxListBox
	Field SourceItemsList:wxListCtrl
	Field ListItemNum:Int
	Field PlatformNum:Int
	
	Field DatabaseSearchPanel:DatabaseSearchPanelType	
	
	Method OnInit()
		ParentWin = SteamOnlineImport2(GetParent() )
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		?Win32
		Self.PlatformNum = 24
		?MacOS
		Self.PlatformNum = 12	
		?Linux
		Self.PlatformNum = 40
		?
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Self.DatabaseSearchPanel = DatabaseSearchPanelType(New DatabaseSearchPanelType.Create(Self, MS_DSP) )
		Self.DatabaseSearchPanel.SetPlatformNum(Self.PlatformNum)
		
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

	Method SetValues(SourceList:wxListCtrl,SText:String,Num:Int)
		SourceItemsList = SourceList
		Self.DatabaseSearchPanel.InitialSearch = SText
		Self.DatabaseSearchPanel.SetPlatformNum(Self.PlatformNum)
		ListItemNum = Num
		DatabaseSearchPanel.SourceChanged()
	End Method

	Function Exitfun(event:wxEvent)
		Local ManualSearchWin:ManualSGSearch = ManualSGSearch(event.parent)
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
		Local ManualSearchWin:ManualSGSearch = ManualSGSearch(event.parent)
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
		Local ManualSearchWin:ManualSGSearch = ManualSGSearch(event.parent)
		Local item:Int = ManualSearchWin.DatabaseSearchPanel.SearchList.GetSelection()
		
		
		
		ManualSearchWin.SourceItemsList.SetStringItem(ManualSearchWin.ListItemNum , 1 , ManualSearchWin.DatabaseSearchPanel.SearchList.GetString(item) )
		ManualSearchWin.SourceItemsList.SetStringItem(ManualSearchWin.ListItemNum , 0 , "True")
		ManualSearchWin.SourceItemsList.SetItemData(ManualSearchWin.ListItemNum , ManualSearchWin.DatabaseSearchPanel.SearchSource.GetValue() + "||" + String(ManualSearchWin.DatabaseSearchPanel.SearchList.GetItemClientData(item) ) )
		ManualSearchWin.SourceItemsList.SetColumnWidth(1 , wxLIST_AUTOSIZE)
		ManualSearchWin.ParentWin.UnSavedChanges = True
		ManualSearchWin.ParentWin.Show()
		ManualSearchWin.Destroy()			
		
	End Function
	
	
End Type
