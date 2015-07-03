Type OfflineImport2 Extends wxFrame
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


		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
				
		Self.UnSavedChanges = False
		
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)

		Local Panel1:wxPanel = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local P1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local ExplainText:String = "This window will import installed games from Games Explorer."
			
		Panel1.SetSizer(P1hbox)
		
		

		
		'SourceItemsList = New wxListCtrl.Create(Self , SOI2_SIL , - 1 , - 1 , - 1 , - 1 , wxLC_REPORT | wxLC_SINGLE_SEL )


		ScrollBox = New wxScrolledWindow.Create(Self)
		ScrollBox.SetBackgroundColour(New wxColour.Create(255, 255, 255) )
		
		Self.UpdateList()

		
		Local sl2:wxStaticLine = New wxStaticLine.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		Local BackButtonPanel:wxPanel = New wxPanel.Create(Self , - 1)
		BackButtonPanel.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Local BackButtonHbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local BackButton:wxButton = New wxButton.Create(BackButtonPanel , OI2_EXIT , "Back")
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
		'vbox.Add(Panel3 , 0 , wxEXPAND , 0)
		'vbox.Add(SourceItemsList , 1 , wxEXPAND , 0)
		
		
		vbox.Add(ScrollBox, 1, wxEXPAND , 0)
		vbox.Add(sl2 , 0 , wxEXPAND , 0)
		vbox.Add(BackButtonPanel, 0 , wxEXPAND, 0)		
		SetSizer(vbox)
		Centre()		
		Hide()
		If PMMaximize = 1 then
			Self.Maximize(1)
		EndIf
		
		
	
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
		Local OnlineWin:OfflineImport2 = OfflineImport2(event.parent)
		OnlineWin.UpdateGames()
		OnlineWin.ShowMainMenu(event)
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
		Local OnlineWin:OfflineImport2 = OfflineImport2(event.parent)
		OnlineWin.SelectAll()
	End Function 

	Function DeSelectAllFun(event:wxEvent)
		Local OnlineWin:OfflineImport2 = OfflineImport2(event.parent)
		OnlineWin.DeSelectAll()
	End Function 	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = OfflineImport2(event.parent).ParentWin
		MainWin.Close(True)
	End Function	

	Function ShowMainMenu(event:wxEvent)
		PrintF("Showing main menu")
		Local OnlineWin:OfflineImport2 = OfflineImport2(event.parent)
		Local MainWin:MainWindow = OfflineImport2(event.parent).ParentWin
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
		MainWin.OfflineImport2Field.Destroy()
		MainWin.OfflineImport2Field = Null 			
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
		
		Log1.Show(1)
		Log1.AddText("Searching Online For Games")
		ReadGDFFolder = ReadDir(TEMPFOLDER + "GDF")
		Local File:String , Title:String 
		Local GDFEXEs:String
		Local ID:String
		Local GameName:String
		Local Platform:String
		
		
		tempPanel = New wxPanel.Create(ScrollBox , - 1)
		gridbox = New wxFlexGridSizer.CreateRC(0, 3, 10, 10)		gridbox.SetFlexibleDirection(wxHORIZONTAL)
		gridbox.AddGrowableCol(2, 1)

		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Import?", - 1, - 1, - 1, - 1, wxALIGN_CENTER)
		'tempStaticText.SetFont(BOLDFONT1)
		gridbox.Add(tempStaticText , 1 , wxEXPAND | wxTOP | wxLEFT | wxRIGHT, 20)
		tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , "Game Explorer Name", - 1, - 1, - 1, - 1, wxALIGN_CENTER)
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
			Title = ReadLine(ReadGDFFile)
			ReadLine(ReadGDFFile)
			GDFEXEs = ReadLine(ReadGDFFile)
			
			tempCheckBox = New wxCheckBox.Create(tempPanel , wxID_ANY)
			ListAddLast CheckBoxList, tempCheckBox
			gridbox.Add(tempCheckBox, 0 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 20)
			
			tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , Title)
			ListAddLast GDFNameList , tempStaticText
			gridbox.Add(tempStaticText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 20)
			
			tempEXEName = New wxComboBox.Create(tempPanel , wxID_ANY, Null, Null, - 1, - 1, - 1, - 1, wxCB_READONLY)
			ListAddLast EXEName , tempEXEName
			gridbox.Add(tempEXEName , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 20)
			
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
			
		
			CloseFile(ReadGDFFile)
			If Log1.LogClosed = True then Exit
		Forever		
		CloseDir(ReadGDFFolder)
		gridbox.SetFlexibleDirection(wxHORIZONTAL)
		tempPanel.SetSizer(gridbox)
				
		hbox2.Add(tempPanel, 1, wxEXPAND, 0)
	
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
				
		Local EXENameArray:wxComboBox[]
		EXENameArray = wxComboBox[](ListToArray(EXEName) )		
		
		Local ArrayLength:Int
		For Local i=EachIn GDFNameListArray.Dimensions()
			ArrayLength = i
			PrintF("Number of Games: "+ArrayLength)
		Next
		
		Local GDFGameName:String
		Local GameDir:String
		Local GameName:String
		Local EXE:String, EXEs:String
		Local ID:String
		Local RealName:String
		Local overwrite:String
		Local tempString:String , tempEXE:String , tempName:String
		'DeleteCreateFolder(TEMPFOLDER + "Games\")
		
		For a = 0 To ArrayLength - 1
			If CheckBoxListArray[a].IsChecked() Then
				GDFGameName = GDFNameListArray[a].GetLabel()
				PrintF("Game Checked: " + GDFGameName)
				'ReadGDFFile = ReadFile(TEMPFOLDER + "GDF\" + GDFGameName + "\Data.txt")
				'ReadLine(ReadGDFFile)
				'ReadLine(ReadGDFFile)
				'GameDir = ReadLine(ReadGDFFile)
				'PrintF("Game Dir: "+GameDir)	
				'CloseFile(ReadGDFFile)
				EXE = EXENameArray[a].GetValue()
				PrintF("EXE: " + EXE)
				
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
				
				GameNode.RunEXE = Chr(34) + EXE + Chr(34)
				
				If PM_GE_AddAllEXEs = True then
					b = 1
					For d = 1 To Len(EXEs)
						If Mid(EXEs , d , 2) = "||" then
							tempString = Mid(EXEs , b , d - b)
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
							
							b = d + 2
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
				EndIf 				
				GameNode.SaveGame()

			EndIf		
		Next
		
		PrintF("Finished Update Games")
		
		MessageBox = New wxMessageDialog.Create(Null , "Games successfully added to database" , "Info" , wxOK | wxICON_INFORMATION)
		MessageBox.ShowModal()
		MessageBox.Free()
		
	End Method

End Type





