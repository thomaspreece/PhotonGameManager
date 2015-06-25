Type AddEditPlatformsList Extends wxFrame
	Field PlatformWindow:PlatformsList
	Field ItemNumber:int
	
	Field IDTextBox:wxTextCtrl
	Field NameTextBox:wxTextCtrl
	Field TypeDropdown:wxComboBox
	Field EmulatorTextBox:wxTextCtrl
	Field EmulatorButton:wxButton 
	Field Edit:int 'Is it an edit box or an add new box? 1-edit, 0-add
	
	Method SetValues(Item:Int, Edit:Int = 0)
		Self.Edit = Edit
		
		Local col1:wxListItem, col2:wxListItem, col3:wxListItem, col4:wxListItem
		
		If Self.Edit = 1 then
			Self.ItemNumber = Item
			col1 = New wxListItem.Create()
			col2 = New wxListItem.Create()
			col3 = New wxListItem.Create()
			col4 = New wxListItem.Create()
			col1.SetId(Item)
			col2.SetId(Item)
			col3.SetId(Item)
			col4.SetId(Item)
			col1.SetColumn(0)
			col2.SetColumn(1)
			col3.SetColumn(2)
			col4.SetColumn(3)
			col1.SetMask(wxLIST_MASK_TEXT)
			col2.SetMask(wxLIST_MASK_TEXT)
			col3.SetMask(wxLIST_MASK_TEXT)
			col4.SetMask(wxLIST_MASK_TEXT)
			PlatformWindow.PlatformListCtrl.GetItem(col1)
			PlatformWindow.PlatformListCtrl.GetItem(col2)
			PlatformWindow.PlatformListCtrl.GetItem(col3)
			PlatformWindow.PlatformListCtrl.GetItem(col4)
			
			Self.IDTextBox.SetValue(col1.GetText() )
			Self.NameTextBox.SetValue(col3.GetText() )
			Self.TypeDropdown.SetValue(col2.GetText() )
			Self.EmulatorTextBox.SetValue(col4.GetText() )
			
			If col2.GetText() = "Folder" then
				Self.EmulatorTextBox.Disable()
				Self.EmulatorButton.Disable()
			EndIf
			
			'Don't Allow ID edit if it is a default platform
			If Int(col1.GetText() ) > 0 And Int(col1.GetText() ) < DEFAULTPLATFORMNUM + 1 then
				Self.IDTextBox.Disable()
			EndIf
		Else
			Self.TypeDropdown.SetSelection(0)
			Local a:Int = DEFAULTPLATFORMNUM + 1
			Local ItemLoop:Int = - 1
			Local NumberUsed:Int = 0
			Repeat
				ItemLoop = - 1
				NumberUsed = 0
				Repeat
					ItemLoop = Self.PlatformWindow.PlatformListCtrl.GetNextItem( ItemLoop , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
					If ItemLoop = - 1 then Exit
					col1 = New wxListItem.Create()
					col1.SetId(ItemLoop)
					col1.SetColumn(0)
					col1.SetMask(wxLIST_MASK_TEXT)
					Self.PlatformWindow.PlatformListCtrl.GetItem(col1)
					If a = Int(col1.GetText() ) then
						NumberUsed = 1
						Exit
					EndIf
				Forever
				
				If NumberUsed = 0 then Exit
				a = a + 1
			Forever
			
			Self.IDTextBox.SetValue(a)
			Self.NameTextBox.SetValue("New Platform")
		EndIf
		
	End Method
	
	Function BackFun(event:wxEvent)
		Local Window:AddEditPlatformsList = AddEditPlatformsList(event.parent)
		Window.PlatformWindow.Enable()
		Window.Destroy()
	End Function
	
	Function SaveFun(event:wxEvent)
		Local Window:AddEditPlatformsList = AddEditPlatformsList(event.parent)
		Local MessageBox:wxMessageDialog
		If Window.Edit = 0 then
			If Int(Window.IDTextBox.GetValue() ) > 0 And Int(Window.IDTextBox.GetValue() ) < DEFAULTPLATFORMNUM + 1 then
				MessageBox = New wxMessageDialog.Create(Null , "The Numbers Between 1 and " + DEFAULTPLATFORMNUM + " are reserved" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()			
				Return
			EndIf
		EndIf
		Local item:Int = - 1	
		Local col1:wxListItem, col2:wxListItem
		Repeat
			item = Window.PlatformWindow.PlatformListCtrl.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 then Exit
			If Window.Edit = 1 then
				If item = Window.ItemNumber then Continue
			EndIf
			col1 = New wxListItem.Create()
			col2 = New wxListItem.Create()
			col1.SetId(item)
			col2.SetId(item)
			col1.SetColumn(0)
			col2.SetColumn(2)
			col1.SetMask(wxLIST_MASK_TEXT)
			col2.SetMask(wxLIST_MASK_TEXT)
			Window.PlatformWindow.PlatformListCtrl.GetItem(col1)
			Window.PlatformWindow.PlatformListCtrl.GetItem(col2)
			
			If Window.IDTextBox.GetValue() = col1.GetText() then
				MessageBox = New wxMessageDialog.Create(Null , "Another platform already exists with that ID" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()			
				Return			
			EndIf
			
			If Window.NameTextBox.GetValue() = col2.GetText() then
				MessageBox = New wxMessageDialog.Create(Null , "Another platform already exists with that name" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()			
				Return						
			EndIf
		Forever
		Local index:Int
		Local ItemLoop:Int = - 1
		Local InsertPoint:Int = Window.PlatformWindow.PlatformListCtrl.GetItemCount()
		
		If Window.Edit = 0 then
			Repeat
				ItemLoop = Window.PlatformWindow.PlatformListCtrl.GetNextItem( ItemLoop , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
				If ItemLoop = - 1 then Exit
				col1 = New wxListItem.Create()
				col2 = New wxListItem.Create()
				col1.SetId(ItemLoop)
				col2.SetId(ItemLoop)
				col1.SetColumn(0)
				col2.SetColumn(1)
				col1.SetMask(wxLIST_MASK_TEXT)
				col2.SetMask(wxLIST_MASK_TEXT)
				Window.PlatformWindow.PlatformListCtrl.GetItem(col1)
				Window.PlatformWindow.PlatformListCtrl.GetItem(col2)
				If col2.GetText() = "-" Or Int(Window.IDTextBox.GetValue() ) < Int(col1.GetText() ) then
					InsertPoint = ItemLoop
					Exit
				EndIf
			Forever		
		
			index = Window.PlatformWindow.PlatformListCtrl.InsertStringItem( InsertPoint , Window.IDTextBox.GetValue() )
			Window.PlatformWindow.PlatformListCtrl.SetStringItem(index , 1 , Window.TypeDropdown.GetValue() )
			Window.PlatformWindow.PlatformListCtrl.SetStringItem(index , 2 , Window.NameTextBox.GetValue() )
			Window.PlatformWindow.PlatformListCtrl.SetStringItem(index , 3 , Window.EmulatorTextBox.GetValue() )
			
			Local PlatformC:PlatformCount
			Local Count:Int = 0

			For PlatformC = EachIn Window.PlatformWindow.PlatformCountList
				If PlatformC.ID = Int(Window.IDTextBox.GetValue() ) then
					Count = PlatformC.Count
					Exit
				EndIf
			Next

			Window.PlatformWindow.PlatformListCtrl.SetStringItem(index , 4 , Count )		
			
			
			Window.PlatformWindow.PlatformListCtrl.SetItemState(index, wxLIST_STATE_SELECTED, wxLIST_STATE_SELECTED)
			Window.PlatformWindow.PlatformListCtrl.SetItemState(index, wxLIST_STATE_FOCUSED, wxLIST_STATE_FOCUSED)		
		Else
			Window.PlatformWindow.PlatformListCtrl.SetStringItem(Window.ItemNumber , 1 , Window.TypeDropdown.GetValue() )
			Window.PlatformWindow.PlatformListCtrl.SetStringItem(Window.ItemNumber , 2 , Window.NameTextBox.GetValue() )
			Window.PlatformWindow.PlatformListCtrl.SetStringItem(Window.ItemNumber , 3 , Window.EmulatorTextBox.GetValue() )
			Window.PlatformWindow.PlatformListCtrl.SetItemState(Window.ItemNumber, wxLIST_STATE_SELECTED, wxLIST_STATE_SELECTED)
			Window.PlatformWindow.PlatformListCtrl.SetItemState(Window.ItemNumber, wxLIST_STATE_FOCUSED, wxLIST_STATE_FOCUSED)				
		EndIf

		Window.PlatformWindow.Changes = True
		Window.PlatformWindow.PlatformListCtrl.SetColumnWidth(2 , wxLIST_AUTOSIZE)
		Window.PlatformWindow.PlatformListCtrl.SetColumnWidth(3 , wxLIST_AUTOSIZE)
		
		Window.BackFun(event)
	End Function
	
	Function BrowseFun(event:wxEvent)
		Local Window:AddEditPlatformsList = AddEditPlatformsList(event.parent)
		?Not Win32	
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EmuWin, "Select emulator path for: " + Window.NameTextBox.GetValue() )	
		If openFileDialog.ShowModal() = wxID_OK then
			Window.EmulatorTextBox.ChangeValue(Chr(34)+openFileDialog.GetPath()+Chr(34)+" [ROMPATH] [EXTRA-CMD]")
		EndIf
		?Win32
		tempFile:String = RequestFile("Select emulator path for: " + Window.NameTextBox.GetValue() )
		If tempFile <> "" then
			Window.EmulatorTextBox.ChangeValue(Chr(34)+tempFile+Chr(34)+" [ROMPATH] [EXTRA-CMD]")
		EndIf
		? 	
	
	End Function
	
	Function PlatTypeUpdatedFun(event:wxEvent)
		Local Window:AddEditPlatformsList = AddEditPlatformsList(event.parent)
		If Window.TypeDropdown.GetValue() = "Folder" then
			Window.EmulatorTextBox.Disable()
			Window.EmulatorButton.Disable()		
		Else
			Window.EmulatorTextBox.Enable()
			Window.EmulatorButton.Enable()		
		EndIf
	End Function
	
	Method OnInit()
		PlatformWindow = PlatformsList(Self.GetParent() )
		Self.Edit = 0
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local gridbox:wxFlexGridSizer = New wxFlexGridSizer.Create(2)
		gridbox.SetFlexibleDirection(wxHORIZONTAL)
		gridbox.AddGrowableCol(1, 1)
		
		Local IDText:wxStaticText = New wxStaticText.Create(Self, wxID_ANY , "ID:")
		Self.IDTextBox = New wxTextCtrl.Create(Self, wxID_ANY, "", - 1, - 1, - 1, - 1)
		Local NameText:wxStaticText = New wxStaticText.Create(Self, wxID_ANY , "Name:")
		Self.NameTextBox = New wxTextCtrl.Create(Self, wxID_ANY, "", - 1, - 1, - 1, - 1)
		Local TypeText:wxStaticText = New wxStaticText.Create(Self, wxID_ANY , "Type:")
		Self.TypeDropdown = New wxComboBox.Create(Self, AEPL_TDD, "", ["File", "Folder"], - 1, - 1, - 1, - 1, wxCB_DROPDOWN | wxCB_READONLY )
		
		Local EmulatorText:wxStaticText = New wxStaticText.Create(Self, wxID_ANY , "Emulator:")
		Self.EmulatorTextBox = New wxTextCtrl.Create(Self, wxID_ANY, "", - 1, - 1, - 1, - 1)
		EmulatorButton = New wxButton.Create(Self, AEPL_EB, "Browse")
		
		Local hbox1:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		hbox1.Add(EmulatorTextBox, 1, wxEXPAND, 0)
		hbox1.Add(EmulatorButton, 0, wxEXPAND, 0)
		
		gridbox.Add(IDText, 0, wxEXPAND | wxALL, 5)
		gridbox.Add(IDTextBox, 0, wxEXPAND | wxALL, 5)
		gridbox.Add(NameText, 0, wxEXPAND | wxALL, 5)
		gridbox.Add(NameTextBox, 0, wxEXPAND | wxALL, 5)
		gridbox.Add(TypeText, 0, wxEXPAND | wxALL, 5)
		gridbox.Add(TypeDropdown, 0, wxEXPAND | wxALL, 5)
		gridbox.Add(EmulatorText, 0, wxEXPAND | wxALL, 5)
		gridbox.AddSizer(hbox1, 0, wxEXPAND | wxALL, 5)
		
		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BackButton:wxButton = New wxButton.Create(Self, AEPL_BB, "Back")
		Local SaveButton:wxButton = New wxButton.Create(Self, AEPL_SA, "Save")
		
		hbox2.Add(BackButton, 1, wxEXPAND | wxRIGHT, 10)
		hbox2.Add(SaveButton, 1, wxEXPAND, 0)
		
		vbox.AddSizer(gridbox, 0, wxEXPAND, 0)
		vbox.AddSizer(hbox2, 1, wxEXPAND | wxALL, 10)
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Self.SetSizer(vbox)
		Self.Center()
		Self.Show(1)
		
		Connect(AEPL_BB , wxEVT_COMMAND_BUTTON_CLICKED , BackFun)
		Connect(AEPL_EB , wxEVT_COMMAND_BUTTON_CLICKED , BrowseFun)
		Connect(AEPL_SA , wxEVT_COMMAND_BUTTON_CLICKED , SaveFun)
		Connect(AEPL_TDD , wxEVT_COMMAND_COMBOBOX_SELECTED , PlatTypeUpdatedFun)
		
	End Method
End Type

Type PlatformsList Extends wxFrame
	Field ParentWin:MainWindow
	Field PlatformListCtrl:wxListCtrl
	Field Changes:int = False
	Field DeleteButton:wxButton
	Field PlatformCountList:TList = CreateList()
	
	Method OnInit()

		ParentWin = MainWindow(GetParent() )
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Local vbox2:wxBoxSizer
		Local hbox:wxBoxSizer , P1Hbox:wxBoxSizer, P2Hbox:wxBoxSizer, P3Hbox:wxBoxSizer, gridbox:wxFlexGridSizer
		Local Panel1:wxPanel, Panel2:wxPanel, Panel3:wxPanel
		'Local tempstatictext:wxStaticText, tempstatictext2:wxStaticText, tempstatictext3:wxStaticText, tempstatictext4:wxStaticText, tempstatictext5:wxStaticText
		'Local temptextctrl:wxTextCtrl
		'Local tempbutton:wxButton, tempbutton2:wxButton
		'Local a:String
		'Local b:Int = 10
		'Local Plat:String , Path:String


		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		'Self.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
		
		'TextCtrlList = CreateList()
		'StaticTextList = CreateList()
		'ButtonList = CreateList()
	
		
		
		
		Panel1 = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		P1Hbox = New wxBoxSizer.Create(wxHORIZONTAL)
		BackButton:wxButton = New wxButton.Create(Panel1 , PL_BB , "Back")
		OKButton:wxButton = New wxButton.Create(Panel1, PL_OK , "Save")

		P1Hbox.Add(BackButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.AddStretchSpacer(4)

		P1Hbox.Add(OKButton , 1 , wxEXPAND | wxALL , 10)
		
		Panel1.SetSizer(P1Hbox)
		
		Panel3 = New wxPanel.Create(Self , wxID_ANY)
		Panel3.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		P3Hbox = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local AddButton:wxButton = New wxButton.Create(Panel3 , PL_ADD , "Add")
		Local EditButton:wxButton = New wxButton.Create(Panel3 , PL_ED , "Edit")
		DeleteButton = New wxButton.Create(Panel3 , PL_DEL , "Delete")
		Local RestoreDefaultButton:wxButton = New wxButton.Create(Panel3 , PL_RD , "Restore to Default")
		
		
		P3Hbox.Add(AddButton , 1 , wxEXPAND | wxALL , 10)
		P3Hbox.Add(EditButton , 1 , wxEXPAND | wxALL , 10)
		P3Hbox.Add(DeleteButton , 1 , wxEXPAND | wxALL , 10)
		P3Hbox.Add(RestoreDefaultButton , 1 , wxEXPAND | wxALL , 10)
		
		
		Panel3.SetSizer(P3Hbox)
		
		Panel2 = New wxPanel.Create(Self , wxID_ANY)
		Panel2.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		P2Hbox = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local ExplainText:String = "Here you can enter the default path to the emulator for various different platforms. ~n" + ..
		"Use the browse button to select the emulator. You may then need to change the path in the box next to the browse button afterwards, [ROMPATH] is where GameManager will insert the path of the rom, [EXTRA-CMD] is where GameManager will insert the extra command line options you specify for each rom. ~n" + ..
		"If you are unsure what should be in the box, you should search the internet for '{emulator name} command line options' ~n" + ..
		"Click OK to save"
				
		'tempstatictext = New wxStaticText.Create(Panel2 , wxID_ANY , ExplainText)
		Local HelpText:wxTextCtrl = New wxTextCtrl.Create(Panel2, wxID_ANY, ExplainText, - 1, - 1, - 1, - 1, wxTE_READONLY | wxTE_MULTILINE | wxTE_CENTER)
		HelpText.SetBackgroundColour(New wxColour.Create(PMRed2, PMGreen2, PMBlue2) )
		P2Hbox.Add(HelpText , 1 , wxEXPAND | wxALL , 10)

		Panel2.SetSizer(P2Hbox)

		Self.PlatformListCtrl = New wxListCtrl.Create(Self, PL_PLC, - 1, - 1, - 1, - 1, wxLC_REPORT | wxLC_SINGLE_SEL)
				
		Local sl1:wxStaticLine = New wxStaticLine.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		Local sl2:wxStaticLine = New wxStaticLine.Create(Self, wxID_ANY, - 1, - 1, - 1, - 1, wxLI_HORIZONTAL)		
		Local sl3:wxStaticLine = New wxStaticLine.Create(Self, wxID_ANY, - 1, - 1, - 1, - 1, wxLI_HORIZONTAL)		
		
		vbox.Add(Panel2 , 4 , wxEXPAND , 0)
		vbox.Add(sl1 , 0, wxEXPAND , 0)
		vbox.Add(PlatformListCtrl , 20 , wxEXPAND , 0)
		vbox.Add(sl2 , 0, wxEXPAND , 0)
		vbox.Add(Panel3, 0 , wxEXPAND , 0)
		vbox.Add(sl3 , 0, wxEXPAND , 0)
		vbox.Add(Panel1, 0 , wxEXPAND , 0)
		SetSizer(vbox)
		
		'Self.HideNonUsedPlatforms()
		
		Self.PopulatePlatformCount()
		Self.LoadPlatforms()
		
		If PMMaximize = 1 then
			Self.Maximize(1)
		EndIf
		Centre()		
		Hide()
		Connect(PL_PLC, wxEVT_COMMAND_LIST_ITEM_SELECTED, SelectedItemFun)	
		
		Connect(PL_RD, wxEVT_COMMAND_BUTTON_CLICKED, RestoreDefaultFun)
		Connect(PL_DEL , wxEVT_COMMAND_BUTTON_CLICKED , DeleteItemFun)
		Connect(PL_ED , wxEVT_COMMAND_BUTTON_CLICKED , EditItemFun)
		Connect(PL_ADD , wxEVT_COMMAND_BUTTON_CLICKED , AddItemFun)
		Connect(PL_BB , wxEVT_COMMAND_BUTTON_CLICKED , BackFun)
		Connect(PL_OK , wxEVT_COMMAND_BUTTON_CLICKED , FinishFun)
		ConnectAny(wxEVT_CLOSE , CloseApp)
		
		
		
	End Method
	
	Function BackFun(event:wxEvent)
		Local PlatList:PlatformsList = PlatformsList(event.parent)
		Local MessageBox:wxMessageDialog
		If PlatList.Changes = True then
			MessageBox = New wxMessageDialog.Create(Null, "You have unsaved changes. Are you sure you wish to discard them?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_YES then	
				PlatList.ShowMainMenu(event)
			EndIf
		Else
			PlatList.ShowMainMenu(event)
		EndIf
	End Function
	
	Function RestoreDefaultFun(event:wxEvent)
		Local PlatList:PlatformsList = PlatformsList(event.parent)
		Local MessageBox:wxMessageDialog
		Local item:Int = PlatList.PlatformListCtrl.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		Local Platform:PlatformType
		PrintF("Delete item: " + item)
		If item = - 1 then
			MessageBox = New wxMessageDialog.Create(Null , "Please select an item to restore to default settings" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()				
		Else
			Local col1:wxListItem = New wxListItem.Create()
			Local col2:wxListItem = New wxListItem.Create()
			col1.SetId(item)
			col2.SetId(item)
			col1.SetColumn(0)
			col2.SetColumn(1)
			col1.SetMask(wxLIST_MASK_TEXT)
			col2.SetMask(wxLIST_MASK_TEXT)
			PlatList.PlatformListCtrl.GetItem(col1)
			PlatList.PlatformListCtrl.GetItem(col2)
			If col2.GetText() = "-" then
				MessageBox = New wxMessageDialog.Create(Null , "Please restore item first" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()					
			Else
				Platform = DefaultPlatforms.GetPlatformByID(Int(col1.GetText() ) )
				If Platform.ID = 0 then
					MessageBox = New wxMessageDialog.Create(Null , "Not a built in platform so has no default settings" , "Error" , wxOK | wxICON_ERROR)
					MessageBox.ShowModal()
					MessageBox.Free()				
				Else
					PlatList.PlatformListCtrl.SetStringItem(item , 1 , Platform.PlatType )
					PlatList.PlatformListCtrl.SetStringItem(item , 2 , Platform.Name )
					PlatList.PlatformListCtrl.SetStringItem(item , 3 , Platform.Emulator )		
					PlatList.Changes = True 
				EndIf			
			EndIf
			
			
			
		EndIf
	End Function
	
	Function SelectedItemFun(event:wxEvent)
		Local PlatList:PlatformsList = PlatformsList(event.parent)
		Local item:Int = PlatList.PlatformListCtrl.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		
		If item = - 1 then
			CustomRuntimeError("PlatformList - SelectedItemFun: Invalid item selection")
		EndIf
		
		Local col1:wxListItem = New wxListItem.Create()
		Local col2:wxListItem = New wxListItem.Create()
		col2.SetId(item)
		col1.SetId(item)
		col2.SetColumn(1)
		col1.SetColumn(0)
		col2.SetMask(wxLIST_MASK_TEXT)
		col1.SetMask(wxLIST_MASK_TEXT)
		PlatList.PlatformListCtrl.GetItem(col2)
		PlatList.PlatformListCtrl.GetItem(col1)
		If col2.GetText() = "-" then
			PlatList.DeleteButton.SetLabel("Restore")
		Else
			If Int(col1.GetText() ) > 0 And Int(col1.GetText() ) < DEFAULTPLATFORMNUM + 1 then
				PlatList.DeleteButton.SetLabel("Hide")
			Else
				PlatList.DeleteButton.SetLabel("Delete")
			EndIf
		EndIf
		
	End Function
	
	Function AddItemFun(event:wxEvent)
		Local PlatList:PlatformsList = PlatformsList(event.parent)
		Local tempwin:AddEditPlatformsList = AddEditPlatformsList(New AddEditPlatformsList.Create(PlatList , wxID_ANY , "Add" , , , 600 , 250) )
		tempwin.SetValues(0, 0)
		PlatList.Disable()
	End Function
	
	Function EditItemFun(event:wxEvent)
		Local PlatList:PlatformsList = PlatformsList(event.parent)
		Local MessageBox:wxMessageDialog
		Local item:Int = PlatList.PlatformListCtrl.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		PrintF("Delete item: " + item)
		If item = - 1 then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a item to delete" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()				
		Else
			Local col2:wxListItem = New wxListItem.Create()
			col2.SetId(item)
			col2.SetColumn(1)
			col2.SetMask(wxLIST_MASK_TEXT)
			PlatList.PlatformListCtrl.GetItem(col2)
			If col2.GetText() = "-" then
				MessageBox = New wxMessageDialog.Create(Null , "Item is hidden. You must restore the item first before making any changes" , "Error" , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()			
			Else
				Local tempwin:AddEditPlatformsList = AddEditPlatformsList(New AddEditPlatformsList.Create(PlatList , wxID_ANY , "Edit" , , , 600 , 250) )
				tempwin.SetValues(item, 1)
				PlatList.Disable()
			EndIf 
		EndIf
	End Function	
	
	Function DeleteItemFun(event:wxEvent)
		Local PlatList:PlatformsList = PlatformsList(event.parent)
		Local MessageBox:wxMessageDialog
		Local item:Int = PlatList.PlatformListCtrl.GetNextItem( - 1 , wxLIST_NEXT_ALL , wxLIST_STATE_SELECTED)
		PrintF("Delete item: " + item)
		If item = - 1 then
			MessageBox = New wxMessageDialog.Create(Null , "Please select an item to delete" , "Error" , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()				
		Else
			Local col1:wxListItem, col2:wxListItem
			Local Platform:PlatformType
			Local index:Int, InsertPoint:Int = 0
			Local ItemLoop = - 1
			col2 = New wxListItem.Create()
			col2.SetId(item)
			col2.SetColumn(1)
			col2.SetMask(wxLIST_MASK_TEXT)
			PlatList.PlatformListCtrl.GetItem(col2)
			If col2.GetText() = "-" then
				PlatList.Changes = True
				col1 = New wxListItem.Create()
				col1.SetId(item)
				col1.SetColumn(0)
				col1.SetMask(wxLIST_MASK_TEXT)
				PlatList.PlatformListCtrl.GetItem(col1)
				Platform = DefaultPlatforms.GetPlatformByID(Int(col1.GetText() ) )

				PlatList.PlatformListCtrl.SetItemState(item + 1, wxLIST_STATE_SELECTED, wxLIST_STATE_SELECTED)
				PlatList.PlatformListCtrl.SetItemState(item + 1, wxLIST_STATE_FOCUSED, wxLIST_STATE_FOCUSED)				
				PlatList.PlatformListCtrl.DeleteItem(item)	
				InsertPoint = PlatList.PlatformListCtrl.GetItemCount()
				
				Repeat
					ItemLoop = PlatList.PlatformListCtrl.GetNextItem( ItemLoop , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
					If ItemLoop = - 1 then Exit
					col1 = New wxListItem.Create()
					col2 = New wxListItem.Create()
					col1.SetId(ItemLoop)
					col2.SetId(ItemLoop)
					col1.SetColumn(0)
					col2.SetColumn(1)
					col1.SetMask(wxLIST_MASK_TEXT)
					col2.SetMask(wxLIST_MASK_TEXT)
					PlatList.PlatformListCtrl.GetItem(col1)
					PlatList.PlatformListCtrl.GetItem(col2)
					If col2.GetText() = "-" Or Platform.ID < Int(col1.GetText() ) then
						InsertPoint = ItemLoop
						Exit
					EndIf
				Forever	
				
							
				index = PlatList.PlatformListCtrl.InsertStringItem( InsertPoint , Platform.ID )
				PlatList.PlatformListCtrl.SetStringItem(index , 1 , Platform.PlatType )
				PlatList.PlatformListCtrl.SetStringItem(index , 2 , Platform.Name )
				PlatList.PlatformListCtrl.SetStringItem(index , 3 , Platform.Emulator)
				
				Local PlatformC:PlatformCount
				Local Count:Int = 0

				For PlatformC = EachIn PlatList.PlatformCountList
					If PlatformC.ID = Platform.ID then
						Count = PlatformC.Count
						Exit
					EndIf
				Next

				PlatList.PlatformListCtrl.SetStringItem(index , 4 , Count)
			Else
				col1 = New wxListItem.Create()
				col1.SetId(item)
				col1.SetColumn(4)
				col1.SetMask(wxLIST_MASK_TEXT)
				PlatList.PlatformListCtrl.GetItem(col1)
				If Int(col1.GetText() ) > 0 then
					MessageBox = New wxMessageDialog.Create(Null, "There are games associated with this Platform. Removing this platform will cause those games to no longer have a valid platform. Are you sure you wish to continue?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
					If MessageBox.ShowModal() = wxID_NO then	
						Return
					EndIf
				EndIf
			
				PlatList.Changes = True
				PlatList.PlatformListCtrl.SetItemState(item + 1, wxLIST_STATE_SELECTED, wxLIST_STATE_SELECTED)
				PlatList.PlatformListCtrl.SetItemState(item + 1, wxLIST_STATE_FOCUSED, wxLIST_STATE_FOCUSED)
				PlatList.PlatformListCtrl.DeleteItem(item)
				PlatList.LoadRestorePlatforms()
			EndIf
		EndIf
				
	End Function
	
	Method LoadRestorePlatforms()
		Local IDList:TList = CreateList()
		Local item:Int = - 1, index:Int
		Local col1:wxListItem
		Repeat
			item = Self.PlatformListCtrl.GetNextItem( item , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If item = - 1 then Exit
			col1 = New wxListItem.Create()
			col1.SetId(item)
			col1.SetColumn(0)
			col1.SetMask(wxLIST_MASK_TEXT)
			Self.PlatformListCtrl.GetItem(col1)
			ListAddLast(IDList, String(col1.GetText() ) )
		Forever
		
		For Platform:PlatformType = EachIn DefaultPlatforms.PlatformList
			If ListContains(IDList, String(Platform.ID) ) then
				Continue
			Else
				index = Self.PlatformListCtrl.InsertStringItem( Self.PlatformListCtrl.GetItemCount() , Platform.ID)
				Self.PlatformListCtrl.SetStringItem(index , 1 , "-")
				Self.PlatformListCtrl.SetStringItem(index , 2 , Platform.Name + " [Hidden]")
				Self.PlatformListCtrl.SetStringItem(index , 3 , "")				
				
				Local PlatformC:PlatformCount
				Local Count:Int = 0

				For PlatformC = EachIn Self.PlatformCountList
					If PlatformC.ID = Platform.ID then
						Count = PlatformC.Count
						Exit
					EndIf
				Next

				Self.PlatformListCtrl.SetStringItem(index , 4 , Count)				
				Self.PlatformListCtrl.SetItemTextColour(index, New wxColour.Create(255, 0, 0) )
			EndIf
		Next
	End Method

	Method LoadPlatforms()
	
		Self.PlatformListCtrl.ClearAll()
		
		Self.PlatformListCtrl.InsertColumn(0 , "ID")
		Self.PlatformListCtrl.SetColumnWidth(0, 80)
		Self.PlatformListCtrl.InsertColumn(1 , "Type")
		Self.PlatformListCtrl.SetColumnWidth(1, 120)
		Self.PlatformListCtrl.InsertColumn(2 , "Platform Name")
		Self.PlatformListCtrl.InsertColumn(3 , "Default Emulator Path")
		Self.PlatformListCtrl.InsertColumn(4 , "# of Games")
		'Self.PlatformListCtrl.SetColumnWidth(2 , 200)
		Local a:Int = 0
		Local Count:Int = 0
		Local PlatformC:PlatformCount
		
		For Platform:PlatformType = EachIn GlobalPlatforms.PlatformList
			Count = 0
			
			index = Self.PlatformListCtrl.InsertStringItem( a , Platform.ID)
			Self.PlatformListCtrl.SetStringItem(index , 1 , Platform.PlatType)
			Self.PlatformListCtrl.SetStringItem(index , 2 , Platform.Name)
			Self.PlatformListCtrl.SetStringItem(index , 3 , Platform.Emulator)
			
			For PlatformC = EachIn Self.PlatformCountList
				If PlatformC.ID = Platform.ID then
					count = PlatformC.Count
					Exit
				EndIf
			Next
			
			Self.PlatformListCtrl.SetStringItem(index , 4 , Count)
			a = a + 1
		Next
		
		Self.PlatformListCtrl.SetColumnWidth(2 , wxLIST_AUTOSIZE)
		Self.PlatformListCtrl.SetColumnWidth(3 , wxLIST_AUTOSIZE)
		
		LoadRestorePlatforms()
	End Method

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = PlatformsList(event.parent).ParentWin
		MainWin.Close(True)
	End Function	
	
	Method Finish()
		Local Platform:PlatformType
		GlobalPlatforms.PlatformList = CreateList()
		Local ItemLoop:Int = - 1
		Local MessageBox:wxMessageDialog
		Local col1:wxListItem, col2:wxListItem, col3:wxListItem, col4:wxListItem
		Repeat
			ItemLoop = Self.PlatformListCtrl.GetNextItem( ItemLoop , wxLIST_NEXT_ALL , wxLIST_STATE_DONTCARE)
			If ItemLoop = - 1 then Exit
			col1 = New wxListItem.Create()
			col2 = New wxListItem.Create()
			col3 = New wxListItem.Create()
			col4 = New wxListItem.Create()			
			col1.SetId(ItemLoop)
			col2.SetId(ItemLoop)
			col3.SetId(ItemLoop)
			col4.SetId(ItemLoop)			
			col1.SetColumn(0)
			col2.SetColumn(1)
			col3.SetColumn(2)
			col4.SetColumn(3)			
			col1.SetMask(wxLIST_MASK_TEXT)
			col2.SetMask(wxLIST_MASK_TEXT)
			col3.SetMask(wxLIST_MASK_TEXT)
			col4.SetMask(wxLIST_MASK_TEXT)			
			Self.PlatformListCtrl.GetItem(col1)
			Self.PlatformListCtrl.GetItem(col2)
			Self.PlatformListCtrl.GetItem(col3)
			Self.PlatformListCtrl.GetItem(col4)	
								
			If col2.GetText() = "-" then
			
			Else
				Platform = New PlatformType.Init(Int(col1.GetText() ), col3.GetText(), col2.GetText(), col4.GetText() )
				ListAddLast(GlobalPlatforms.PlatformList, Platform)
			EndIf
		Forever	
		
		GlobalPlatforms.SavePlatforms()
		MessageBox = New wxMessageDialog.Create(Null , "Saved successfully" , "Info" , wxOK | wxICON_INFORMATION)
		MessageBox.ShowModal()
		MessageBox.Free()		
	End Method

Rem	
	Method Finish()
		Local StaticTextListArray:wxStaticText[]
		Local TextCtrlListArray:wxTextCtrl[] 
		Local Plat:String, Path:String
		StaticTextListArray = wxStaticText[](ListToArray(StaticTextList))
		TextCtrlListArray = wxTextCtrl[](ListToArray(TextCtrlList))
		
		WritePlatforms = WriteFile(SETTINGSFOLDER + "Platforms.txt")
		For a = 0 To Len(TextCtrlListArray) - 1
			Plat = StaticTextListArray[a].GetLabel()
			Path = TextCtrlListArray[a].GetValue()
			WriteLine(WritePlatforms,Plat+">"+Path)
		Next
		CloseFile(WritePlatforms)
	End Method
EndRem

	Function FinishFun(event:wxEvent)
		Local MainWin:MainWindow = PlatformsList(event.parent).ParentWin
		Local EmuList:PlatformsList = PlatformsList(event.parent)
		
		EmuList.Finish()
		
		EmuList.ShowMainMenu(event)			
	End Function

	Function ShowMainMenu(event:wxEvent)
		Local MainWin:MainWindow = PlatformsList(event.parent).ParentWin
		MainWin.Show()
		MainWin.PlatformsListField.Destroy()
		MainWin.PlatformsListField = Null 

	End Function

	Function OnQuit(event:wxEvent)
		' true is to force the frame to close
		wxWindow(event.parent).Close(True)
	End Function
	
	
	Method PopulatePlatformCount()
		Local GameNode:GameType
		Local ReadGamesDir:Int
		Local Dir:String
		Local PlatformC:PlatformCount
		Local Counted:Int
		
		ReadGamesDir = ReadDir(GAMEDATAFOLDER)
		Repeat
			Dir = NextFile(ReadGamesDir)
			If Dir = "" then Exit
			If Dir = "." Or Dir = ".." then Continue
			
			GameNode = New GameType
			If GameNode.GetGame(Dir) = - 1 then
			
			Else
				Counted = False
				For PlatformC = EachIn Self.PlatformCountList
					If PlatformC.ID = GameNode.PlatformNum then
						PlatformC.Count = PlatformC.Count + 1
						Counted = True
						Exit
					EndIf
				Next
				If Counted = False then
					PlatformC = New PlatformCount.Init(GameNode.PlatformNum, 1)
					ListAddLast(Self.PlatformCountList, PlatformC)
				EndIf
			EndIf
		Forever
		CloseDir(ReadGamesDir)	
	
	End Method
	
End Type

Type PlatformCount
	Field ID:int
	Field Count:int
	
	Function Init:PlatformCount(PID:Int, PCount:Int )
		PC:PlatformCount = New PlatformCount
		PC.ID = PID
		PC.Count = PCount
		Return PC
	End Function
End Type
