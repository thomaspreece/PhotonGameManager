
Type OfflineImport Extends wxWizard
	Field ParentWin:MainWindow
	Field StartPage:wxWizardPageSimple
	Field ImportPage:wxWizardPageSimple
	Field FinishPage:wxWizardPageSimple
	'Field CheckBoxList:wxCheckListBox
	'Field CheckBoxNumber:Int
	Field StartPageInt:Int
	Field ScrollBox:wxScrolledWindow
	Field VPanelList:TList
	Field CheckBoxList:TList
	Field GDFNameList:TList
	Field EXEName:TList		
	
	Method Setup()
		PrintF("Creating Offline Wizard")
		StartPageInt = -1
		ParentWin = MainWindow(GetParent() )
		CheckBoxNumber = 0
		StartPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		ImportPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		FinishPage = New wxWizardPageSimple.CreateSimple(Self , Null , Null)
		
		StartPage.SetNext(ImportPage)
		ImportPage.SetNext(FinishPage)
		
		ImportPage.SetPrev(StartPage)
		
		Local ExplainText:String = "This wizard will import installed games from windows Game Explorer, the game management tool built into Windows Vista and 7. ~n" + ..
		"If you do not know what Game Explorer is, don't worry your games will have automatically been added to it and so you will be able to import them via this wizard. ~n" + ..
		"This is the OFFLINE version of the wizard, this means that only locally stored information will be added unlike the online version which downloads missing information. ~n~n" + ..
		"Click Next to continue"
		
		Local ExplainText2:String = "Select from the list the games you wish to add to GameManager. ~n" + ..
		"Red: Game already in database   Blue: Game not in database"
		
		Local EndText:String = "Operation Completed Successfully."
		
		Local TextField = New wxStaticText.Create(StartPage , wxID_ANY , ExplainText, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
		Local P1vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		P1vbox.AddStretchSpacer(1)
		P1vbox.Add(TextField , 1 , wxEXPAND | wxALL , 10)
		P1vbox.AddStretchSpacer(1)		
		StartPage.SetSizer(P1vbox)
		

		tempPanel3:wxPanel = New wxPanel.Create(ImportPage , - 1)
		'ListAddLast VPanelList,tempPanel
		'tempPanel.SetBackgroundColour(New wxColour.Create(200,200,255))
		tempVbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		
		BOLDFONT1:wxFont = New wxFont.Create()
		BOLDFONT1.SetWeight(wxFONTWEIGHT_BOLD)
		
		Local tempStaticText:wxStaticText
		
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "Import?")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 0 , wxEXPAND | wxLEFT | wxRIGHT , 10)
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "Game Explorer Name")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10)	
		tempStaticText = New wxStaticText.Create(tempPanel3 , wxID_ANY , "EXE Name")
		tempStaticText.SetFont(BOLDFONT1)
		tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxLEFT | wxRIGHT , 10)			
		tempPanel3.SetSizer(tempVbox)
		
		Local sl3:wxStaticLine = New wxStaticLine.Create(ImportPage , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)


		Local P2vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		ScrollBox = New wxScrolledWindow.Create(ImportPage)

		tempPanel:wxPanel = New wxPanel.Create(ImportPage , - 1)
		'tempPanel.SetBackgroundColour(New wxColour.Create(200,200,200))
		tempVbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		SAButton:wxButton = New wxButton.Create(tempPanel , MI_SA , "Select All")
		DAButton:wxButton = New wxButton.Create(tempPanel, MI_DA , "DeSelect All")			
		tempVbox.Add(SAButton , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 10)
		tempVbox.Add(DAButton , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 10)	
		tempPanel.SetSizer(tempVbox)	
				
		Self.UpdateList()
		
		Local sl1:wxStaticLine = New wxStaticLine.Create(ImportPage , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		'Local sl2:wxStaticLine = New wxStaticLine.Create(ImportPage , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		
		tempPanel2:wxPanel = New wxPanel.Create(ImportPage , - 1)
		Local TextField3 = New wxStaticText.Create(tempPanel2 , wxID_ANY , ExplainText2, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
		Local P2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		P2hbox.AddStretchSpacer(1)
		P2hbox.Add(TextField3 , 6 , wxEXPAND , 0)
		P2hbox.AddStretchSpacer(1)		
		tempPanel2.SetSizer(P2hbox)
		
	
		
		P2vbox.Add(tempPanel2,  0 , wxEXPAND, 0)
		'P2vbox.Add(sl2 , 0 , wxEXPAND , 0)
		P2vbox.AddSpacer(10)
		P2vbox.Add(tempPanel3 , 1 , wxEXPAND, 0)
		P2vbox.Add(sl3 , 0 , wxEXPAND , 0)
		P2vbox.Add(ScrollBox , 15 , wxEXPAND , 0)
		P2vbox.Add(sl1 , 0 , wxEXPAND , 0)
		P2vbox.Add(tempPanel,  1 , wxEXPAND, 0)	
		ImportPage.SetSizer(P2vbox)


		Local TextField2 = New wxStaticText.Create(FinishPage , wxID_ANY , EndText, -1 , -1 , -1 , -1 , wxALIGN_CENTER)
		Local P3vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		P3vbox.AddStretchSpacer(1)	
		P3vbox.Add(TextField2 , 1 , wxEXPAND | wxALL , 10)	
		P3vbox.AddStretchSpacer(1)		
		FinishPage.SetSizer(P3vbox)		

		Connect(MI_SA , wxEVT_COMMAND_BUTTON_CLICKED , SelectAllFun)		
		Connect(MI_DA , wxEVT_COMMAND_BUTTON_CLICKED , DeSelectAllFun)
		ConnectAny(wxEVT_WIZARD_PAGE_CHANGED , PageChange)
		PrintF("Finished Creating Wizard")
	End Method


	Method UpdateList()
		PrintF("Update OnlineImport List")
		OutputGDFs()

		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local tempVbox:wxBoxSizer
		Local tempPanel:wxPanel		
		Local tempCheckBox:wxCheckBox		
		Local tempEXEName:wxComboBox		
		Local tempStaticText:wxStaticText
		Local sl:wxStaticLine
		
		VPanelList = CreateList()
		CheckBoxList = CreateList()
		GDFNameList = CreateList()
		EXEName = CreateList()
						
		
		
		'hbox2.Add(tempPanel , 0 , wxEXPAND , 0)
		'hbox2.Add(sl2 , 0 , wxEXPAND , 0)
		
		Delay 300
		
		ReadGDFFolder = ReadDir(TEMPFOLDER + "GDF")
		Local File:String
		Local GDFEXEs:String
		Local ID:String
		Local GameName:String
		Local Platform:String
		Repeat
			File = NextFile(ReadGDFFolder)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue
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
			
			
			tempPanel = New wxPanel.Create(ScrollBox , - 1)
			If FileType(GAMEDATAFOLDER+File+"---PC")=2 Then 
				tempPanel.SetBackgroundColour(New wxColour.Create(255 , 200 , 200) )
			Else
				tempPanel.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
			EndIf
			tempVbox = New wxBoxSizer.Create(wxHORIZONTAL)
			
			tempCheckBox = New wxCheckBox.Create(tempPanel , wxID_ANY)
			ListAddLast CheckBoxList,tempCheckBox
			tempVbox.Add(tempCheckBox,  0 , wxEXPAND | wxALL, 20)
			
			tempStaticText = New wxStaticText.Create(tempPanel , wxID_ANY , File)
			ListAddLast GDFNameList , tempStaticText
			tempVbox.Add(tempStaticText , 1 , wxEXPAND | wxALL , 20)			

			tempEXEName = New wxComboBox.Create(tempPanel , wxID_ANY, Null, Null, -1, -1, -1, -1, wxCB_READONLY)
			ListAddLast EXEName , tempEXEName
			tempVbox.Add(tempEXEName , 1 , wxEXPAND | wxALL , 20)
			
			b=1
			For a = 1 To Len(GDFEXEs)
				If Mid(GDFEXEs , a , 1) = "|" Then
					tempEXEName.Append(Mid(GDFEXEs , b , a - b) )
					b = a + 1
				EndIf
			Next	
			tempEXEName.Append(Mid(GDFEXEs , b , a - b) )
			tempEXEName.SelectItem(0)
			
			
			tempPanel.SetSizer(tempVbox)
			ListAddLast VPanelList,tempPanel
			CloseFile(ReadGDFFile)
			
		Forever		
		CloseDir(ReadGDFFolder)
		
		For temp2:wxPanel=EachIn VPanelList
			hbox2.Add(temp2 , 0 , wxEXPAND , 0)
			sl = New wxStaticLine.Create(ScrollBox , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
			hbox2.Add(sl , 0 , wxEXPAND , 0)
		Next			
		hbox2.AddSpacer(60)
		hbox2.RecalcSizes()
		ScrollBox.SetSizer(hbox2)
		ScrollBox.SetScrollRate(10 , 10)
		Self.Update()
		ScrollBox.Update()
		Self.SelectAll()
		PrintF("Finished Updating")
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
		Local EXE:String, Dir:String
		Local ID:String
		Local RealName:String
		Local overwrite:String
		'DeleteCreateFolder(TEMPFOLDER + "Games\")
		
		For a = 0 To ArrayLength - 1
			If CheckBoxListArray[a].IsChecked() Then
				GDFGameName = GDFNameListArray[a].GetLabel()
				PrintF("Game Checked: "+GDFGameName)
				'ReadGDFFile = ReadFile(TEMPFOLDER + "GDF\" + GDFGameName + "\Data.txt")
				'ReadLine(ReadGDFFile)
				'ReadLine(ReadGDFFile)
				'GameDir = ReadLine(ReadGDFFile)
				'PrintF("Game Dir: "+GameDir)	
				'CloseFile(ReadGDFFile)
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
				
				CloseFile(ReadGameData)
				
				GameNode.RunEXE = Chr(34)+Dir + EXE+Chr(34)
				
				For b = 0 To EXENameArray[a].GetCount() - 1
					If EXE = EXENameArray[a].GetString(b) Then
					
					Else
						ListAddLast(GameNode.OEXEs , Dir + EXENameArray[a].GetString(b))
						ListAddLast(GameNode.OEXEsName , StripExt(StripDir(EXENameArray[a].GetString(b))) )
					EndIf
					
				Next
				
				
				GameNode.SaveGame()
				Rem
				DeleteCreateFolder(TEMPFOLDER + "GDF\" + GDFGameName + "A")
				ReadGameData = ReadFile(TEMPFOLDER + "GDF\" + GDFGameName + "\Data.txt")
				WriteGameData = WriteFile(TEMPFOLDER + "GDF\" + GDFGameName + "A" + "\Info.txt")
				WriteLine(WriteGameData , ReadLine(ReadGameData) )
				WriteLine(WriteGameData , ReadLine(ReadGameData) )
				Dir = ReadLine(ReadGameData)
				WriteLine(WriteGameData , Dir)								
				WriteLine(WriteGameData , EXE)
				ReadLine(ReadGameData)
				Repeat
					WriteLine(WriteGameData , ReadLine(ReadGameData) )
					If Eof(ReadGameData) Then Exit
				Forever
				CloseFile(ReadGameData)
				CloseFile(WriteGameData)
				Local File:String , temp:String
				Local ExtractIcon:TProcess
				overwrite=False
				If FileType(GAMEDATAFOLDER + GDFGameName) = 2 Then
					MessageBox = New wxMessageDialog.Create(Null, GDFGameName+ " is already in the database, overwrite it? (All fan art will be deleted)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
					If MessageBox.ShowModal() = wxID_YES Then
						overwrite = 1		
					Else
						overwrite = 2
					EndIf
				Else
					overwrite = 0
				EndIf
				Select overwrite
					Case 0
						PrintF("Game doesn't exist, copying game data")
						CopyDir(TEMPFOLDER + "GDF\" + GDFGameName + "A" , GAMEDATAFOLDER + GDFGameName )			
						GetGameIcon(Dir+EXE , GDFGameName)						
					Case 1
						PrintF("Game Exists, overwriting it")
						If FileType(GAMEDATAFOLDER + GDFGameName + "\userdata.txt") = 1 Then
							PrintF("Userdata found and copied")
							CopyFile(GAMEDATAFOLDER + GDFGameName + "\userdata.txt" , TEMPFOLDER + "userdata.txt")
							DeleteDir(GAMEDATAFOLDER + GDFGameName , 1)
							PrintF( "Adding To Database: "+GAMEDATAFOLDER + GDFGameName)
							PrintF("Copying Dir: " + CopyDir(TEMPFOLDER + "GDF\" + GDFGameName + "A" , GAMEDATAFOLDER + GDFGameName ) )
							CopyFile(TEMPFOLDER + "userdata.txt" , GAMEDATAFOLDER + GDFGameName + "\userdata.txt")
							DeleteFile(TEMPFOLDER + "userdata.txt")
						Else
							PrintF("No userdata found")
							DeleteDir(GAMEDATAFOLDER + GDFGameName , 1)
							PrintF( "Adding To Database: "+GAMEDATAFOLDER + GDFGameName)
							PrintF("Copying Dir: " + CopyDir(TEMPFOLDER + "GDF\" + GDFGameName + "A", GAMEDATAFOLDER + GDFGameName ) )
						EndIf	
						GetGameIcon(Dir+EXE , GDFGameName)	
					Case 2
						PrintF("Do Not Overwrite")
					Default
						CustomRuntimeError("Error 18: Wrong overwrite type") 'MARK: Error 18
				End Select
				DeleteDir(TEMPFOLDER + "GDF\" + GDFGameName + "A" , 1)
				endrem
			EndIf		
		Next
		
		PrintF("Finished Update Games")
	End Method



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
		Local OfflineWiz:OfflineImport = OfflineImport(event.parent)
		OfflineWiz.SelectAll()
	End Function 

	Function DeSelectAllFun(event:wxEvent)
		Local OfflineWiz:OfflineImport = OfflineImport(event.parent)
		OfflineWiz.DeSelectAll()
	End Function 

	Function PageChange(event:wxEvent)
		WizEvent:wxWizardEvent = wxWizardEvent(event)
		Local MessageBox:wxMessageDialog
		Local overwrite = False
		Local OfflineWin:OfflineImport = OfflineImport(event.parent)		
		Local CopyGameName:String
		Local Page:Int = WizEvent.GetPage()	
		If OfflineWin.StartPageInt = - 1 Then
			OfflineWin.StartPage.SetInitialSize(800, 500)
			OfflineWin.StartPage.Refresh()		
			OfflineWin.StartPageInt = Page
		EndIf
		
		If Page = OfflineWin.StartPageInt + 2 Then
			OfflineWin.UpdateGames()
			Rem
			For a = 0 To OfflineWin.CheckBoxNumber - 1
				If OfflineWin.CheckBoxList.IsChecked(a) Then
					overwrite = False
					CopyGameName = OfflineWin.CheckBoxList.GetString(a)
					PrintF("Box Checked: "+CopyGameName)
					If FileType(GAMEDATAFOLDER + CopyGameName) = 2 Then
						MessageBox = New wxMessageDialog.Create(Null, CopyGameName+ " is already in the database, overwrite it? (All fan art will be deleted)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
						If MessageBox.ShowModal() = wxID_YES Then
							overwrite = 1	
						Else
							overwrite = 2
						EndIf
					Else
						overwrite = 0
					EndIf
					Select overwrite
						Case 0
							PrintF("Game doesn't exist, copying game data")						
							CreateDir(GAMEDATAFOLDER + CopyGameName)
							PrintF( "Adding To Database: "+GAMEDATAFOLDER + CopyGameName)
							PrintF("Copying File: " + CopyFile(TEMPFOLDER + "GDF\" + CopyGameName + "\Data.txt" , GAMEDATAFOLDER + CopyGameName + "\Info.txt") )
						Case 1
							PrintF("Game Exists, overwriting it")
							If FileType(GAMEDATAFOLDER + CopyGameName + "\userdata.txt") = 1 Then
								CopyFile(GAMEDATAFOLDER + CopyGameName + "\userdata.txt" , TEMPFOLDER + "userdata.txt")
								DeleteCreateFolder(GAMEDATAFOLDER + CopyGameName)
								PrintF( "Adding To Database: "+GAMEDATAFOLDER + CopyGameName)
								PrintF("Copying File: " + CopyFile(TEMPFOLDER + "GDF\" + CopyGameName + "\Data.txt" , GAMEDATAFOLDER + CopyGameName + "\Info.txt") )
								CopyFile(TEMPFOLDER + "userdata.txt" , GAMEDATAFOLDER + CopyGameName + "\userdata.txt")
								DeleteFile(TEMPFOLDER + "userdata.txt")
							Else
								DeleteCreateFolder(GAMEDATAFOLDER + CopyGameName)
								PrintF( "Adding To Database: "+GAMEDATAFOLDER + CopyGameName)
								PrintF("Copying File: " + CopyFile(TEMPFOLDER + "GDF\" + CopyGameName + "\Data.txt" , GAMEDATAFOLDER + CopyGameName + "\Info.txt") )
							EndIf
						Case 2
							PrintF("Do Not Overwrite")
						Default
							CustomRuntimeError("Error 17: Wrong overwrite type") 'MARK: Error 17
					End Select	
				EndIf
			Next
			endrem
		EndIf
	End Function
	

End Type
