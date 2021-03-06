
Type DatabaseSearchPanelType Extends wxPanel
	Field ParentWin:wxWindow
	Field SearchSource:wxComboBox
	Field SearchText:wxTextCtrl
	Field SearchList:wxListBox
	Field SearchPlatform:wxComboBox
	Field SourceText:wxHyperlinkCtrl
	
	Field ListDepth:Int = 1
	Field PlatformNum:Int
	Field OldSearch:String
	
	Field LuaTimer:wxTimer
	
	Field InitialSearch:String

	Method SetPlatformNum(PlatformNum:Int)
		Self.PlatformNum = PlatformNum
	End Method

	Method OnInit()
		ParentWin = GetParent()
		PrintF("Creating DatabaseSearchPanelType")
		LuaInternet.Reset()
		OldSearch = ""
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		LuaTimer = New wxTimer.Create(Self, DSP_T)
		
		Local SShbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local SSText:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , "Source:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		SearchSource:wxComboBox = New wxComboBox.Create(Self, DSP_SS, "", [""] , - 1, - 1, - 1, - 1 , wxCB_DROPDOWN | wxCB_READONLY)
		Local SPText:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , "Platform:" , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		SearchPlatform:wxComboBox = New wxComboBox.Create(Self, DSP_SP, "", [""] , - 1, - 1, - 1, - 1 , wxCB_DROPDOWN | wxCB_READONLY)
		SShbox.Add(SSText, 0, wxEXPAND | wxALL , 5)
		SShbox.Add(SearchSource, 1, wxEXPAND | wxALL , 5)
		SShbox.Add(SPText, 0, wxEXPAND | wxALL , 5)
		SShbox.Add(SearchPlatform, 1, wxEXPAND | wxALL , 5)
		
		Local SourceTList:TList = GetLuaList(1)
		Local SourceTListItem:String
		SearchSource.Clear()
		For SourceTListItem = EachIn SourceTList
			SearchSource.Append(SourceTListItem)
		Next
		
		SearchSource.SetStringSelection(LuaHelper_GetDefaultGame())
			
		
		Local Shbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local SearchTextText:wxStaticText = New wxStaticText.Create(Self , wxID_ANY , "Search: ")
		SearchText = New wxTextCtrl.Create(Self , DSP_ST , "", - 1 , - 1 , - 1 , - 1 , wxTE_PROCESS_ENTER)
		Local SearchButton = New wxButton.Create(Self , DSP_SB , "Go")
		
		Shbox.Add(SearchTextText , 0 , wxEXPAND | wxALL , 5)
		Shbox.Add(SearchText , 3 , wxEXPAND | wxALL, 5)
		Shbox.Add(SearchButton , 1 , wxEXPAND | wxALL , 5)
				
		SearchList = New wxListBox.Create(Self, DSP_SL, Null, - 1, - 1, - 1, - 1, wxLB_SINGLE)
		
		?Win32
		SourceText:wxHyperlinkCtrl = New wxHyperlinkCtrl.Create(Self, DSP_HLC, "Loading...", "")
		?Not Win32
		SourceText:wxHyperlinkCtrl = New wxHyperlinkCtrl.Create(Self, DSP_HLC, "Loading...", "",-1,-1,-1,-1,wxHL_ALIGN_LEFT)
		?
		
		vbox.AddSizer(SShbox, 0, wxEXPAND, 0)
		vbox.AddSizer(Shbox, 0, wxEXPAND, 0)
		vbox.Add(SearchList, 1, wxEXPAND, 0)
		vbox.Add(SourceText, 0, wxEXPAND | wxALL, 5)
		
		LuaTimer.Start(100)
		
		Self.SetSizer(vbox)
	
		Connect(DSP_ST , wxEVT_COMMAND_TEXT_ENTER , SearchFun)
		Connect(DSP_SB , wxEVT_COMMAND_BUTTON_CLICKED , SearchFun)
		
		Connect(DSP_SL, wxEVT_COMMAND_LISTBOX_DOUBLECLICKED , ListItemSelectedFun)
		
		Connect(DSP_HLC, wxEVT_COMMAND_HYPERLINK, HyperLinkFun)
		
		Connect(DSP_SS, wxEVT_COMMAND_TEXT_UPDATED, SourceChangedFun)
		
		Connect(DSP_T, wxEVT_TIMER , CheckLuaEvent)
		Self.Show(1)
		
		'SourceText.SetLabel("")
		
		vbox.RecalcSizes()
		
		'Local event:wxCommandEvent = New wxCommandEvent.NewEvent(wxEVT_COMMAND_TEXT_UPDATED, SearchSource.GetId() )
		'SearchSource.GetEventHandler().AddPendingEvent( event )	
		
	End Method
	
	Method Destroy()
		'Timer causes Memory Access Violation when not Disconnected and stopped.
		'Must call DatabaseSearchPanelType.Destroy from Windows Destroy as it isn't destroyed automatically
		Disconnect(DSP_T, wxEVT_TIMER)
		LuaTimer.Stop()
		DatabaseApp.Yield()
		Super.Destroy()
	End Method
	
	Function CheckLuaEvent(event:wxEvent)
		?Threaded
		Local DatabaseSearchPanel:DatabaseSearchPanelType = DatabaseSearchPanelType(event.parent)
		Local LuaEvent2:String

		LockMutex(LuaEventMutex)
		LuaEvent2 = LuaEvent
		LuaEvent = ""
		UnlockMutex(LuaEventMutex)
		
		Select LuaEvent2
			Case "SourceChanged"
				DatabaseSearchPanel.SourceChangedReturn()
			Case "Search"
				DatabaseSearchPanel.SearchReturn()
			Case "FurtherSearch"
				DatabaseSearchPanel.FurtherSearchReturn()
			Case ""
				'Do nothing
			Default
				'Error
		End Select
		
		?
	End Function

	Function HyperLinkFun(event:wxEvent)
		Local DatabaseSearchPanel:DatabaseSearchPanelType = DatabaseSearchPanelType(event.parent)
		Local MessageBox:wxMessageDialog = New wxMessageDialog.Create(Null, "Goto website: " + DatabaseSearchPanel.SourceText.GetURL() + "?~n(Note that Photon Game Manager does not take any responsibility for the content or quality of the link and the site it points to)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			wxLaunchDefaultBrowser(DatabaseSearchPanel.SourceText.GetURL() )	
		EndIf
	End Function

	Function SourceChangedFun(event:wxEvent)
		DatabaseSearchPanel:DatabaseSearchPanelType = DatabaseSearchPanelType(event.parent)
		DatabaseSearchPanel.SourceChanged()
	End Function

	Method SourceChanged()
		Local event:wxCommandEvent = New wxCommandEvent.NewEvent( wxEVT_COMMAND_SEARCHPANEL_SOURCECHANGED, GetId() )
		event.SetEventObject( Self )
		GetEventHandler().AddPendingEvent( event )	
	
		LuaMutexLock()
		
		Self.SearchList.Clear()
		Self.SearchPlatform.Clear()
		
		'Create Platform List
		Local LuaList:LuaListType = New LuaListType.Create()
		'Get Lua File
		Local LuaFile:String = LUAFOLDER + "Game" + FolderSlash + SearchSource.GetValue() + ".lua"
		
		
		
		If LuaHelper_LoadString(LuaVM, "" , LuaFile) <> 0 Then
			LuaMutexUnlock()
			Return
		EndIf
		PrintF("Running: " + LuaFile)
		
		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "GetPlatforms")
		lua_pushinteger( LuaVM , Self.PlatformNum)
		lua_pushbmaxobject( LuaVM, LuaList )
		lua_pushbmaxobject(LuaVM, LUAFOLDER)
		LuaMutexUnlock()
		
		Self.Disable()
		
		?Threaded
		Local LuaThreadType:LuaThread_pcall_Type = New LuaThread_pcall_Type.Create(LuaVM, 3, 4, "SourceChanged")
		Local LuaThread:TThread = CreateThread(LuaThread_pcall_Funct, LuaThreadType)
		
		?Not Threaded
		LuaMutexLock()
		If LuaHelper_pcall(LuaVM, 3, 4) <> 0 Then
			Return
			LuaMutexUnlock()
		Else
			LuaMutexUnlock()
		EndIf
		SourceChangedReturn()
		?
	End Method
	
	Method SourceChangedReturn()
	
		Self.Enable()
	
		LuaMutexLock()
		Local ErrorString:String
		Self.SourceText.SetLabel("")
		Local Error:Int
		
		'Get Return status
		If lua_isnumber(LuaVM, 1) = False Then
			Error = 198
		Else		
			Error = luaL_checkint( LuaVM, 1 )
		EndIf
		
		If Error <> 0 Then
			If lua_isstring(LuaVM, 2) = False Or lua_isnumber(LuaVM, 1) = False Then
				ErrorString = "Lua code did not return int @1 or/and string @2"
			Else
				ErrorString = luaL_checkstring(LuaVM , 2)
			EndIf 
			LuaHelper_FunctionError(LuaVM, Error, ErrorString)
			LuaMutexUnlock()
			Return
		EndIf
		
		
		'Get selected platform
		If lua_isstring(LuaVM, 3) = False Then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return string object @3")
			LuaMutexUnlock()
			Return		
		EndIf
		Local SelectedPlatform:String = luaL_checkstring(LuaVM , 3)
		If lua_isbmaxobject(LuaVM, 4) = False Then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return correct object @4")
			LuaMutexUnlock()
			Return		
		EndIf
		Local LuaList:LuaListType = LuaListType(lua_tobmaxobject( LuaVM, 4 ) )
		Local SinglePlatform:LuaListItemType
		
		'Remove 2 return values from stack
		LuaHelper_CleanStack(LuaVM)
		
		For SinglePlatform = EachIn LuaList.List
			Self.SearchPlatform.Append(SinglePlatform.ItemName, SinglePlatform.ClientData)
		Next
		
		Local SelectedPlatformItem:Int = Self.SearchPlatform.FindString(SelectedPlatform)
		If SelectedPlatformItem <> - 1 Then
			Self.SearchPlatform.SetSelection(SelectedPlatformItem)
		EndIf
		
		
		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "GetText")
		LuaHelper_pcall(LuaVM, 0, 3)
		
		Error = luaL_checkint( LuaVM, 1 )
		
		If Error <> 0 Then
			LuaHelper_FunctionError(LuaVM, Error, "Error Getting Website Source Link")
			LuaMutexUnlock()
			Return
		EndIf
		
		Local ReturnedSourceText:String = luaL_checkstring(LuaVM , 2)
		Local ReturnedSourceURL:String = luaL_checkstring(LuaVM , 3)
		LuaHelper_CleanStack(LuaVM)
		
		Self.SourceText.SetLabel(ReturnedSourceText)
		Self.SourceText.SetURL(ReturnedSourceURL)
		
		'Blank out lua Code
		If LuaHelper_LoadString(LuaVM, LuaBlank) <> 0 Then CustomRuntimeError("Blank Lua Code Error")
		
		LuaMutexUnlock()
		
		If Self.InitialSearch = Null Or Self.InitialSearch = "" Then
			Return
		Else
			Self.SearchText.ChangeValue(Self.InitialSearch)
			Self.InitialSearch = ""
			Self.Search()
		EndIf
	End Method
	
	Method Search()
		LuaMutexLock()
		
		Local event:wxCommandEvent = New wxCommandEvent.NewEvent( wxEVT_COMMAND_SEARCHPANEL_NEWSEARCH, GetId() )
		event.SetEventObject( Self )
		GetEventHandler().AddPendingEvent( event )		
	
		Self.ListDepth = 1
		Self.SearchList.Enable()
		Self.SearchList.Clear()
		
		Local SearchTerm:String = Self.SearchText.GetValue()
		
		Local PlatformData:String
		If Self.SearchPlatform.GetSelection() = wxNOT_FOUND Then
			LuaMutexUnlock()
			Return			
		Else
			PlatformData = String(Self.SearchPlatform.GetItemClientData(Self.SearchPlatform.GetSelection() ) )
		EndIf
		
		Local LuaList:LuaListType = New LuaListType.Create()
		
		Local LuaFile:String = LUAFOLDER + "Game" + FolderSlash + Self.SearchSource.GetValue() + ".lua"
		If LuaHelper_LoadString(LuaVM, "", LuaFile) <> 0 Then
			LuaMutexUnlock()
			Return
		EndIf
		
		Self.OldSearch = SearchTerm
		
		'Get Lua Function
		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "SearchGame")
		'Push PlatformNum and empty list
		lua_pushbmaxobject( LuaVM , SearchTerm)
		lua_pushbmaxobject( LuaVM , "")
		lua_pushbmaxobject( LuaVM , PlatformData)
		lua_pushinteger( LuaVM , Self.ListDepth)
		lua_pushbmaxobject( LuaVM, LuaInternet )
		lua_pushbmaxobject( LuaVM, LuaList )
		lua_pushbmaxobject(LuaVM, LUAFOLDER)
		'Call Lua Function
		
		LuaMutexUnlock()
		
		Self.Disable()
		
		?Threaded
		Local LuaThreadType:LuaThread_pcall_Type = New LuaThread_pcall_Type.Create(LuaVM, 7, 4, "Search" )
		Local LuaThread:TThread = CreateThread(LuaThread_pcall_Funct, LuaThreadType)
		
		?Not Threaded
		LuaMutexLock()
		If LuaHelper_pcall(LuaVM, 7, 4) <> 0 then
			Return
			LuaMutexUnlock()
		Else
			LuaMutexUnlock()
		EndIf
		SearchReturn()
		?
		
	End Method
		
	Method SearchReturn()
		PlaySound SearchBeep
		Local ErrorString:String
		
		Self.Enable()
		
		LuaMutexLock()
		Local Error:Int
		
		'Get Return status
		If lua_isnumber(LuaVM, 1) = False Then
			Error = 198
		Else		
			Error = luaL_checkint( LuaVM, 1 )
		EndIf
		
		If Error <> 0 Then
			If lua_isstring(LuaVM, 2) = False Or lua_isnumber(LuaVM, 1) = False Then
				ErrorString = "Lua code did not return int @1 or/and string @2"
			Else
				ErrorString = luaL_checkstring(LuaVM , 2)
			EndIf 
			LuaHelper_FunctionError(LuaVM, Error, ErrorString)
			LuaMutexUnlock()
			Return
		EndIf
		
					
		If lua_isstring(LuaVM, 3) = False Then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return string object @3")
			LuaMutexUnlock()
			Return		
		EndIf
		Self.ListDepth = luaL_checkint( LuaVM , 3)
		If lua_isbmaxobject(LuaVM, 4) = False Then
			LuaHelper_FunctionError(LuaVM, 199, "Lua code did not return correct object @4")
			LuaMutexUnlock()
			Return		
		EndIf		
		Local LuaList:LuaListType = LuaListType(lua_tobmaxobject( LuaVM, 4 ) )
		
		LuaHelper_CleanStack(LuaVM)
		
		
		If CountList(LuaList.List) > 0 Then
			Local LuaListItem:LuaListItemType
			For LuaListItem = EachIn LuaList.List
				Self.SearchList.Append(LuaListItem.ItemName, LuaListItem.ClientData)
			Next
		Else
			Self.SearchList.Append("No Search Results Returned", "")
		EndIf
		
		LuaHelper_LoadString(LuaVM, LuaBlank)
		LuaMutexUnlock()
	End Method

	Method ListItemSelected()
		Local MessageBox:wxMessageDialog
		If Self.ListDepth = 0 Then
			'Send Event			
			'Self.SearchList.Clear()
			If Self.SearchList.GetStringSelection() = "No Search Results Returned" Then
				PrintF("Invalid search selection")
				MessageBox = New wxMessageDialog.Create(Null , "Not a valid selection!" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()					
			Else
				Self.SearchList.Disable()
				Self.ListDepth = 1
				Local event:wxCommandEvent = New wxCommandEvent.NewEvent( wxEVT_COMMAND_SEARCHPANEL_SELECTED, GetId() )
				event.SetEventObject( Self )
				event.SetClientData(String(Self.SearchList.GetItemClientData(Self.SearchList.GetSelection() ) ) )
				GetEventHandler().AddPendingEvent( event )
				
			EndIf
		Else
			Self.FurtherSearch(String(Self.SearchList.GetItemClientData(Self.SearchList.GetSelection() ) ) )
		EndIf
	End Method
	
	Method FurtherSearch(ClientData:String)
		LuaMutexLock()
		
		Self.SearchList.Clear()
		
		Local PlatformData:String = String(Self.SearchPlatform.GetItemClientData(Self.SearchPlatform.GetSelection() ) )
		Local LuaList:LuaListType = New LuaListType.Create()
		Local LuaInternet:LuaInternetType = LuaInternetType(New LuaInternetType.Create() )
		
		Local LuaFile:String = LUAFOLDER + "Game" + FolderSlash + Self.SearchSource.GetValue() + ".lua"
		If LuaHelper_LoadString(LuaVM, "", LuaFile) <> 0 Then
			LuaMutexUnlock()
			Return
		EndIf
		
		'Get Lua Function
		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "SearchGame")
		'Push PlatformNum and empty list
		lua_pushbmaxobject( LuaVM , Self.OldSearch)
		lua_pushbmaxobject( LuaVM , ClientData)
		lua_pushbmaxobject( LuaVM , PlatformData)
		lua_pushinteger( LuaVM , Self.ListDepth)
		lua_pushbmaxobject( LuaVM, LuaInternet )
		lua_pushbmaxobject( LuaVM, LuaList )
		lua_pushbmaxobject(LuaVM, LUAFOLDER)
		'Call Lua Function
		
		Self.Disable()
		
		LuaMutexUnlock()
		
		?Threaded
		Local LuaThreadType:LuaThread_pcall_Type = New LuaThread_pcall_Type.Create(LuaVM, 7, 4, "FurtherSearch" )
		Local LuaThread:TThread = CreateThread(LuaThread_pcall_Funct, LuaThreadType)
		?Not Threaded
		LuaMutexLock()
		If LuaHelper_pcall(LuaVM, 7, 4) <> 0 Then
			Return
			LuaMutexUnlock()
		Else
			LuaMutexUnlock()
		EndIf
		FurtherSearchReturn()
		?
		
	End Method

	Method FurtherSearchReturn()
	
		Self.Enable()
		LuaMutexLock()
	
		Local Error:Int
		
		'Get Return status
		Error = luaL_checkint( LuaVM, 1 )
		
		If Error <> 0 Then
			Local ErrorString:String = luaL_checkstring(LuaVM , 2)
			LuaHelper_FunctionError(LuaVM, Error, ErrorString)
			LuaMutexUnlock()
			Return
		EndIf
				
		Self.ListDepth = luaL_checkint( LuaVM , 3)
		Local LuaList:LuaListType = LuaListType(lua_tobmaxobject( LuaVM, 4 ) )
		
		LuaHelper_CleanStack(LuaVM)
		
		Local LuaListItem:LuaListItemType
		For LuaListItem = EachIn LuaList.List
			Self.SearchList.Append(LuaListItem.ItemName, LuaListItem.ClientData)
		Next
		
		LuaHelper_LoadString(LuaVM, LuaBlank)
		
		LuaMutexUnlock()
							
	End Method

	Function ListItemSelectedFun(event:wxEvent)
		DatabaseSearchPanel:DatabaseSearchPanelType = DatabaseSearchPanelType(event.parent)
		DatabaseSearchPanel.ListItemSelected()	
	End Function

	Function SearchFun(event:wxEvent)
		Local MessageBox:wxMessageDialog
		DatabaseSearchPanel:DatabaseSearchPanelType = DatabaseSearchPanelType(event.parent)
		If DatabaseSearchPanel.SearchPlatform.GetSelection() = wxNOT_FOUND Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a platform" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
		Else
			DatabaseSearchPanel.Search()	
		EndIf
	End Function

End Type