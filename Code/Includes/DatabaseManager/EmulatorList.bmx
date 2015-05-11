Type EmulatorsList Extends wxFrame
	Field ParentWin:MainWindow
	Field PanelList:TList
	Field TextCtrlList:TList
	Field StaticTextList:TList
	Field TogglePlatforms:wxButton
	Field vbox2:wxBoxSizer
	Field ScrollBox:wxScrolledWindow
	
	Method OnInit()
		ParentWin = MainWindow(GetParent() )
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		'Local vbox2:wxBoxSizer
		Local hbox:wxBoxSizer , P1Hbox:wxBoxSizer, P2Hbox:wxBoxSizer
		Local temppanel:wxPanel , Panel1:wxPanel, Panel2:wxPanel
		Local tempstatictext:wxStaticText
		Local temptextctrl:wxTextCtrl
		Local tempbutton:wxButton
		Local a:String
		Local b:Int = 10
		Local Plat:String , Path:String

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		'Self.SetBackgroundColour(New wxColour.Create(200 , 200 , 255) )
		
		TextCtrlList = CreateList()
		StaticTextList = CreateList()
		PanelList = CreateList()
	
		
		Panel1 = New wxPanel.Create(Self , wxID_ANY)
		Panel1.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		P1Hbox = New wxBoxSizer.Create(wxHORIZONTAL)
		BackButton:wxButton = New wxButton.Create(Panel1 , EL_BB , "Back")
		TogglePlatforms = New wxButton.Create(Panel1 , EL_TP , "Hide Unused Platforms")
		OKButton:wxButton = New wxButton.Create(Panel1, EL_OK , "OK")

		P1Hbox.Add(BackButton , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.AddStretchSpacer(1.5)
		P1Hbox.Add(TogglePlatforms , 1 , wxEXPAND | wxALL , 10)
		P1Hbox.AddStretchSpacer(1.5)
		P1Hbox.Add(OKButton , 1 , wxEXPAND | wxALL , 10)
		
		Panel1.SetSizer(P1Hbox)
		
		Panel2 = New wxPanel.Create(Self , wxID_ANY)
		Panel2.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		P2Hbox = New wxBoxSizer.Create(wxHORIZONTAL)
		
		Local ExplainText:String = "Here you can enter the default path to the emulator for various different platforms. ~n" + ..
		"Use the browse button to select the emulator. You may then need to change the path in the box next to the browse button afterwards, [ROMPATH] is where GameManager will insert the path of the rom, [EXTRA-CMD] is where GameManager will insert the extra command line options you specify for each rom. ~n" + ..
		"If you are unsure what should be in the box, you should search the internet for '{emulator name} command line options' ~n" + ..
		"Click OK to save"
				
		tempstatictext = New wxStaticText.Create(Panel2 , wxID_ANY , ExplainText)
	
		P2Hbox.Add(tempstatictext , 1 , wxEXPAND | wxALL , 10)

		Panel2.SetSizer(P2Hbox)
				
		ScrollBox = New wxScrolledWindow.Create(Self)
		vbox2 = New wxBoxSizer.Create(wxVERTICAL)

		
		For Platform:PlatformType = EachIn GlobalPlatforms.PlatformList
			If Platform.PlatType = "Folder" then Continue
			temppanel = New wxPanel.Create(ScrollBox,wxID_ANY)
			hbox = New wxBoxSizer.Create(wxHORIZONTAL)
			
			tempstatictext = New wxStaticText.Create(temppanel,wxID_ANY , Platform.Name)
			temptextctrl = New wxTextCtrl.Create(temppanel , wxID_ANY , Platform.Emulator)
			tempbutton = New wxButton.Create(temppanel , 100 + b , "Browse")
			Connect(100 + b , wxEVT_COMMAND_BUTTON_CLICKED , BrowseClickFun)
			
			ListAddLast(StaticTextList , tempstatictext)
			ListAddLast(TextCtrlList , temptextctrl)
			ListAddLast(PanelList, temppanel)
			
			hbox.Add(tempstatictext , 1 , wxEXPAND | wxALL , 0)
			hbox.Add(temptextctrl , 2 , wxEXPAND | wxALL , 0)
			hbox.Add(tempbutton,  0 , wxEXPAND | wxALL, 0)
			
			temppanel.SetSizer(hbox)
			b = b + 1
			
			vbox2.Add(temppanel , 0 , wxEXPAND | wxALL , 20)
		Next
		
		Rem
		ReadPlatforms = ReadFile(SETTINGSFOLDER + "Platforms.txt")
		Repeat
			a = ReadLine(ReadPlatforms)
			For c = 1 To Len(a)+1
				If Mid(a , c , 1) = ">" Then
					Plat = Left(a , c - 1 )
					If c = Len(a) Then
						Path=""
					Else
						Path = Right(a , Len(a) - c )
					EndIf
				EndIf
			Next
			temppanel = New wxPanel.Create(ScrollBox,wxID_ANY)
			hbox = New wxBoxSizer.Create(wxHORIZONTAL)
			
			tempstatictext = New wxStaticText.Create(temppanel,wxID_ANY , Plat)
			temptextctrl = New wxTextCtrl.Create(temppanel , wxID_ANY , Path)
			tempbutton = New wxButton.Create(temppanel , 100 + b , "Browse")
			Connect(100 + b , wxEVT_COMMAND_BUTTON_CLICKED , BrowseClickFun)
			
			ListAddLast(StaticTextList , tempstatictext)
			ListAddLast(TextCtrlList , temptextctrl)
			ListAddLast(PanelList, temppanel)
			
			hbox.Add(tempstatictext , 1 , wxEXPAND | wxALL , 0)
			hbox.Add(temptextctrl , 2 , wxEXPAND | wxALL , 0)
			hbox.Add(tempbutton,  0 , wxEXPAND | wxALL, 0)
			
			temppanel.SetSizer(hbox)
			b = b + 1
			
			vbox2.Add(temppanel , 0 , wxEXPAND | wxALL , 20)
			If Eof(ReadPlatforms) Then Exit
		Forever
		CloseFile(ReadPlatforms)
		EndRem
		
		
		vbox2.RecalcSizes()
		ScrollBox.SetSizer(vbox2)
		ScrollBox.SetScrollRate(10 , 10)
		Self.Update()
		ScrollBox.Update()
		
		Local sl1:wxStaticLine = New wxStaticLine.Create(Self , wxID_ANY , - 1 , - 1 , - 1 , - 1 , wxLI_HORIZONTAL)
		Local sl2:wxStaticLine = New wxStaticLine.Create(Self, wxID_ANY, -1, -1, -1,-1,wxLI_HORIZONTAL)		
		
		vbox.Add(Panel2 , 3 , wxEXPAND , 0)
		vbox.Add(sl1 , 0,  wxEXPAND  , 0)
		vbox.Add(ScrollBox , 10 , wxEXPAND  ,0)
		vbox.Add(sl2 , 0,  wxEXPAND  , 0)
		vbox.Add(Panel1, 1 , wxEXPAND  , 0)
		SetSizer(vbox)
		
		'Self.HideNonUsedPlatforms()
		
		Centre()		
		Hide()
		Connect(EL_BB , wxEVT_COMMAND_BUTTON_CLICKED , ShowMainMenu)
		Connect(EL_OK , wxEVT_COMMAND_BUTTON_CLICKED , FinishFun)
		Connect(EL_TP , wxEVT_COMMAND_BUTTON_CLICKED , TogglePlatformsFun)
		ConnectAny(wxEVT_CLOSE , CloseApp)
	End Method
	

	Function CloseApp(event:wxEvent)
		Local MainWin:MainWindow = EmulatorsList(event.parent).ParentWin
		MainWin.Close(True)
	End Function	
	
	Function TogglePlatformsFun(event:wxEvent)
		Local EmuWin:EmulatorsList = EmulatorsList(event.parent)
		EmuWin.ToggleThePlatforms()
	End Function
	
	Method ToggleThePlatforms()
		
		
		If TogglePlatforms.GetLabel() = "Hide Unused Platforms" Then
			TogglePlatforms.SetLabel("Show All Platforms")
			Self.HideNonUsedPlatforms()
			Self.Refresh()
			vbox2.RecalcSizes()
			ScrollBox.SetSizer(vbox2)
			ScrollBox.SetScrollRate(10 , 10)
			ScrollBox.Update()			
		ElseIf TogglePlatforms.GetLabel() = "Show All Platforms" Then
			TogglePlatforms.SetLabel("Hide Unused Platforms")
			Self.ShowAllPlatforms()
			Self.Refresh()
			vbox2.RecalcSizes()
			ScrollBox.SetSizer(vbox2)
			ScrollBox.SetScrollRate(10 , 10)
			ScrollBox.Update()			
		EndIf
	End Method

	Method ShowAllPlatforms()
		Local StaticTextListArray:wxStaticText[]
		Local PanelListArray:wxPanel[] 
				
		StaticTextListArray = wxStaticText[](ListToArray(StaticTextList))
		PanelListArray = wxPanel[](ListToArray(PanelList) )
		
		For a = 0 To Len(StaticTextListArray)-1
			PanelListArray[a].Show()
		Next
	End Method

	Method HideNonUsedPlatforms()
		Local StaticTextListArray:wxStaticText[]
		Local PanelListArray:wxPanel[] 
				
		StaticTextListArray = wxStaticText[](ListToArray(StaticTextList))
		PanelListArray = wxPanel[](ListToArray(PanelList) )
		
		Local UsedPlatformList:TList = CreateList()
		
		Local GameNode:GameType

		
		ReadGamesDir = ReadDir(GAMEDATAFOLDER)
		Repeat
			Dir:String = NextFile(ReadGamesDir)
			If Dir = "" Then Exit
			If Dir="." Or Dir=".." Then Continue
			
			GameNode = New GameType
			If GameNode.GetGame(Dir) = - 1 Then
			
			Else
				ListAddLast(UsedPlatformList , GlobalPlatforms.GetPlatformByID(GameNode.PlatformNum).Name )
			EndIf

		Forever
		CloseDir(ReadGamesDir)
		
		For a = 0 To Len(StaticTextListArray)-1
			If UsedPlatformList.Contains(StaticTextListArray[a].GetLabel() ) = True Then
				PanelListArray[a].Show()
			Else
				PanelListArray[a].Hide()
			EndIf
			
		Next		
		Rem
		For a = 0 To Len(StaticTextListArray)-1
			If UsedPlatform(StaticTextListArray[a].GetLabel() ) = True Then
				PanelListArray[a].Show()
			Else
				PanelListArray[a].Hide()
			EndIf
			
		Next
		EndRem
	End Method

Rem
	Function UsedPlatform(Text:String)
		Local GameNode:GameType

		
		ReadGamesDir = ReadDir(GAMEDATAFOLDER)
		Repeat
			Dir:String = NextFile(ReadGamesDir)
			If Dir = "" Then Exit
			If Dir="." Or Dir=".." Then Continue
			
			GameNode = New GameType
			If GameNode.GetGame(Dir) = - 1 Then
			
			Else
				If GameNode.Plat = Text Then Return True
			EndIf
				
			'Rem
			If FileType(GAMEDATAFOLDER + Dir + "\Info.txt")=1 Then
				ReadGameFile = ReadFile(GAMEDATAFOLDER + Dir + "\Info.txt")
				For a = 1 To 11
					ReadLine(ReadGameFile)
				Next
				If ReadLine(ReadGameFile) = Text Then Return True
				CloseFile(ReadGameFile)
			EndIf
			'EndRem
		Forever
		'CloseDir(ReadGamesDir)
		Return False
	End Function
EndRem

	Function BrowseClickFun(event:wxEvent)
		Local EmuWin:EmulatorsList = EmulatorsList(event.parent)
		EmuWin.BrowseClick(event.GetID() - 110)
	End Function
	
	Method BrowseClick(BrowseID:Int)
		PrintF("BrowseClick: "+BrowseID)
		Local StaticTextListArray:wxStaticText[]
		Local TextCtrlListArray:wxTextCtrl[] 
				
		StaticTextListArray = wxStaticText[](ListToArray(StaticTextList))
		TextCtrlListArray = wxTextCtrl[](ListToArray(TextCtrlList))
		?Not Win32	
		Local openFileDialog:wxFileDialog = New wxFileDialog.Create(EmuWin, "Select emulator path for: "+StaticTextListArray[BrowseID].GetLabel())	
		If openFileDialog.ShowModal() = wxID_OK Then
			TextCtrlListArray[BrowseID].ChangeValue(Chr(34)+openFileDialog.GetPath()+Chr(34)+" [ROMPATH] [EXTRA-CMD]")
		EndIf
		?Win32
		tempFile:String = RequestFile("Select emulator path for: "+StaticTextListArray[BrowseID].GetLabel() )
		If tempFile <> "" Then 
			TextCtrlListArray[BrowseID].ChangeValue(Chr(34)+tempFile+Chr(34)+" [ROMPATH] [EXTRA-CMD]")
		EndIf
		? 
	End Method
	
	
	Method Finish()
		Local StaticTextListArray:wxStaticText[]
		Local TextCtrlListArray:wxTextCtrl[] 
		Local Platform:PlatformType
		StaticTextListArray = wxStaticText[](ListToArray(StaticTextList))
		TextCtrlListArray = wxTextCtrl[](ListToArray(TextCtrlList))
		
		For a = 0 To Len(TextCtrlListArray) - 1
			Platform = GlobalPlatforms.GetPlatformByName( StaticTextListArray[a].GetLabel() )
			Platform.Emulator = TextCtrlListArray[a].GetValue()
		Next
		
		GlobalPlatforms.SavePlatforms()

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
		Local MainWin:MainWindow = EmulatorsList(event.parent).ParentWin
		Local EmuList:EmulatorsList = EmulatorsList(event.parent)
		
		EmuList.Finish()
		
		MainWin.Show()
		MainWin.EmulatorsListField.Hide()			
	End Function

	Function ShowMainMenu(event:wxEvent)
		Local MainWin:MainWindow = EmulatorsList(event.parent).ParentWin
		MainWin.Show()
		MainWin.EmulatorsListField.Destroy()
		MainWin.EmulatorsListField = Null 

	End Function

	Function OnQuit(event:wxEvent)
		' true is to force the frame to close
		wxWindow(event.parent).Close(True)
	End Function
End Type