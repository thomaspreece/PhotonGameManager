Type HotkeyPluginWindow Extends wxFrame
	Field KeyCode:wxTextCtrl
	Field KeyCodeValue:int
	Field ConfigLocation:String
	Field ActiveField:int = - 1
	Field KeyCountdown:wxTimer
	Field Parent:PluginsWindow
	
	Method OnInit()
		Self.Parent = PluginsWindow(GetParent() )
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		Local ST1 = New wxStaticText.Create(Self , wxID_ANY , "Click the Change button to set a hotkey for this plugin" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)			
		
	
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		KeyCode = New wxTextCtrl.Create(Self , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local KeyCodeButton:wxButton = New HotKeyInputButton.Create(Self , HKPW_KCB , "Change")
		hbox.Add(KeyCode, 1, wxEXPAND | wxALL, 4)
		hbox.Add(KeyCodeButton, 0 , wxEXPAND | wxALL, 4)
		
		Local hbox2:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local SaveButton:wxButton = New wxButton.Create(Self , HKPW_SB , "Save")
		Local BackButton:wxButton = New wxButton.Create(Self , HKPW_BB , "Back")
		hbox2.Add(BackButton, 1 , wxEXPAND | wxALL, 4)
		hbox2.Add(SaveButton, 1, wxEXPAND | wxALL, 4)
		

		
		vbox.Add(ST1, 0 , wxEXPAND , 0)
		vbox.AddSizer(hbox, 0, wxEXPAND, 0)
		vbox.AddSizer(hbox2, 1, wxEXPAND, 0)
		Self.SetSizer(vbox)
		Self.Show()
		Self.Center()
		
		KeyCountdown = New wxTimer.Create(Self, HKPW_T)
			
		Connect(HKPW_T , wxEVT_TIMER , KeyTimeout)			
		
		Connect(HKPW_KCB , wxEVT_COMMAND_BUTTON_CLICKED , ChangeKeyCodeFun)
		Connect(HKPW_SB , wxEVT_COMMAND_BUTTON_CLICKED , SavePluginFun)
		Connect(HKPW_BB , wxEVT_COMMAND_BUTTON_CLICKED , BackFun)
		ConnectAny(wxEVT_CLOSE , BackFun)
	End Method

	Function ChangeKeyCodeFun(event:wxEvent)
		Local HotkeyWindow:HotkeyPluginWindow = HotkeyPluginWindow(event.parent)
		HotkeyWindow.ActiveField = 1
		HotkeyWindow.KeyCode.SetValue("Press Key Now!")
		HotkeyWindow.KeyCountdown.Start(3000, 1)	
	End Function
	
	Function KeyTimeout(event:wxEvent)
		Local HotkeyWindow:HotkeyPluginWindow = HotkeyPluginWindow(event.parent)
		HotkeyWindow.KeyCode.ChangeValue(String(HotkeyWindow.KeyCodeValue) + " (" + getKeyCodeChar(HotkeyWindow.KeyCodeValue) + ")")
	End Function	

	Function SavePluginFun(event:wxEvent)
		Local HotkeyWindow:HotkeyPluginWindow = HotkeyPluginWindow(event.parent)
		If HotkeyWindow.SavePlugin() = True then
			HotkeyWindow.Parent.Enable()
			HotkeyWindow.Destroy()
		EndIf 
	End Function 
	
	Method SavePlugin()
		Local MessageBox:wxMessageDialog
		Local SaveSettings:SettingsType = New SettingsType
		SaveSettings.ParseFile(ConfigLocation , "PluginConfig")
		SaveSettings.SaveSetting("key" , String(KeyCodeValue) )
		SaveSettings.SaveFile()
		SaveSettings.CloseFile()	
		
		Return True 	
	End Method 

	Function BackFun(event:wxEvent)
		Local HotkeyWindow:HotkeyPluginWindow = HotkeyPluginWindow(event.parent)
		HotkeyWindow.Parent.Enable()
		HotkeyWindow.Destroy()
	End Function	
	
	Method UpdateData(ConfigFile:String)
		ConfigLocation = ConfigFile
		Local temp:String 
		Local ReadSettings:SettingsType = New SettingsType
		ReadSettings.ParseFile(ConfigFile , "PluginConfig")
		Local Key:Int = Int(ReadSettings.GetSetting("key") )
		ReadSettings.CloseFile()		
		KeyCode.ChangeValue(String(Key) + " (" + getKeyCodeChar(Key) + ")")
		KeyCodeValue = Key
	End Method
End Type


Type HotKeyInputButton Extends wxButton
	Field ParentWin:HotkeyPluginWindow
	
	Method OnInit()
		ParentWin = HotkeyPluginWindow( GetParent() )
		
		Super.OnInit()
		ConnectAny(wxEVT_KEY_DOWN, OnKeyDown)
	End Method
		
	Function OnKeyDown(event:wxEvent)
		Local HotkeyPluginWin:HotkeyPluginWindow = HotKeyInputButton( event.parent ).ParentWin
		Local evt:wxKeyEvent = wxKeyEvent(event)
		If HotkeyPluginWin.ActiveField = - 1 then
		
		Else
			HotkeyPluginWin.KeyCountdown.Stop()
			HotkeyPluginWin.KeyCodeValue = MapWxKeyCodeToBlitz(evt.GetKeyCode() )
			HotkeyPluginWin.KeyCode.ChangeValue(String(HotkeyPluginWin.KeyCodeValue) + " (" + getKeyCodeChar(HotkeyPluginWin.KeyCodeValue) + ")")
			HotkeyPluginWin.ActiveField = - 1
			event.StopPropagation()
		EndIf
		
	End Function
End Type


Type PowerPlanPluginWindow Extends wxFrame
	Field PowPlans:TList 
	Field StartPlanBox:wxListBox	
	Field FinishPlanBox:wxListBox
	Field ConfigLocation:String 
	Field Parent:PluginsWindow
	
	Method OnInit()
		Self.Parent = PluginsWindow(GetParent() )
		PowPlans = Self.GetPowerPlans()
		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local ST1 = New wxStaticText.Create(Self , wxID_ANY , "Game Start PowerPlan" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)	
		StartPlanBox = New wxListBox.Create(Self, wxID_ANY , Null , - 1 , -1 , -1 , -1 , wxLB_SINGLE)
		Local ST2 = New wxStaticText.Create(Self , wxID_ANY , "Game Finish PowerPlan" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)
		FinishPlanBox = New wxListBox.Create(Self, wxID_ANY , Null , - 1 , -1 , -1 , -1 , wxLB_SINGLE)
		
		Local tempPower:String
		For tempPower = EachIn PowPlans
			StartPlanBox.Append(tempPower)
			FinishPlanBox.Append(tempPower)
		Next 
		
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local SaveButton:wxButton = New wxButton.Create(Self , PPPW_SB , "Save")
		Local BackButton:wxButton = New wxButton.Create(Self , PPPW_BB , "Back")
		hbox.Add(BackButton, 1, wxEXPAND | wxALL, 4)
		hbox.Add(SaveButton, 1, wxEXPAND | wxALL, 4)
				
		vbox.Add(ST1, 0 , wxEXPAND , 0)
		vbox.Add(StartPlanBox, 1 , wxEXPAND , 0)
		vbox.Add(ST2, 0 , wxEXPAND , 0)
		vbox.Add(FinishPlanBox, 1 , wxEXPAND , 0)
		vbox.AddSizer(hbox, 0, wxEXPAND, 0)
		
		Connect(PPPW_SB , wxEVT_COMMAND_BUTTON_CLICKED , SavePluginFun)
		ConnectAny(wxEVT_CLOSE , BackFun)
		Connect(PPPW_BB, wxEVT_COMMAND_BUTTON_CLICKED, BackFun)
		
		SetSizer(vbox)
		Self.Centre()
		Self.Show()		
	End Method 
	
	Function BackFun(event:wxEvent)
		Local PowerWindow:PowerPlanPluginWindow = PowerPlanPluginWindow(event.parent)
		PowerWindow.Parent.Enable()
		PowerWindow.Destroy()
	End Function		
	
	Function SavePluginFun(event:wxEvent)
		Local PowerWindow:PowerPlanPluginWindow = PowerPlanPluginWindow(event.parent)
		If PowerWindow.SavePlugin() = True then
			PowerWindow.Parent.Enable()
			PowerWindow.Destroy()
		EndIf 
	End Function 
	
	Method SavePlugin()
		Local MessageBox:wxMessageDialog
		If StartPlanBox.GetStringSelection() = "" Then 
			MessageBox = New wxMessageDialog.Create(Null , "Please select a start powerplan" , "Info" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return 
		EndIf 
		If FinishPlanBox.GetStringSelection() = "" Then
			MessageBox = New wxMessageDialog.Create(Null , "Please select a finish powerplan" , "Info" , wxOK | wxICON_INFORMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return 		
		EndIf 
		
		Local startGUID:String = StartPlanBox.GetStringSelection()
		For a=1 To Len(startGUID)
			If Mid(startGUID,a,3)=" - " Then 
				startGUID = Right(startGUID,Len(startGUID)-a-2)
				Exit 
			EndIf 
		Next
		
		Local endGUID:String = FinishPlanBox.GetStringSelection()
		For a=1 To Len(endGUID)
			If Mid(endGUID,a,3)=" - " Then 
				endGUID = Right(endGUID,Len(endGUID)-a-2)
				Exit 
			EndIf 
		Next		
		Local SaveSettings:SettingsType = New SettingsType
		SaveSettings.ParseFile(ConfigLocation , "PluginConfig")
		SaveSettings.SaveSetting("startGUID" , startGUID)
		SaveSettings.SaveSetting("endGUID" , endGUID)
		SaveSettings.SaveFile()
		SaveSettings.CloseFile()	
		
		Return True 	
	End Method 
	
	Method UpdateData(ConfigFile:String)
		ConfigLocation = ConfigFile
		Local temp:String 
		Local ReadSettings:SettingsType = New SettingsType
		ReadSettings.ParseFile(ConfigFile , "PluginConfig")
		Local StartGUID:String = ReadSettings.GetSetting("startGUID")
		Local FinishGUID:String = ReadSettings.GetSetting("endGUID")
		ReadSettings.CloseFile()		
		For temp = EachIn PowPlans
			If Right(temp,Len(StartGUID)) = StartGUID Then 
				StartPlanBox.SetStringSelection(temp)
				Exit
			EndIf 			
		Next 
		For temp = EachIn PowPlans
			If Right(temp,Len(FinishGUID)) = FinishGUID Then 
				FinishPlanBox.SetStringSelection(temp)
				Exit
			EndIf 			
		Next 		
		
	End Method 
	
	Function GetPowerPlans:TList()
		Local PList:TList = CreateList()
		Local temp:String 
		Local PProc:TProcess = CreateProcess("powercfg -L" , 1)
		While PProc.status() Or PProc.pipe.ReadAvail()
			If PProc.pipe.ReadAvail() Then
				temp = PProc.pipe.ReadLine()
				If Left(temp,Len("Power Scheme GUID: "))="Power Scheme GUID: " Then 
					temp = Right(temp,Len(temp)-Len("Power Scheme GUID: "))
					'tempPower:PowerType = New PowerType
					For a=1 To Len(temp)
						If Mid(temp,a,1)=" " Then 
							'tempPower.GUID = Left(temp,a-1)
							'tempPower.Name = Right(temp , Len(temp) - a)
							ListAddLast(PList , Right(temp , Len(temp) - a)+" - "+Left(temp,a-1))
							Exit 
						EndIf 
					Next 
				EndIf 
			EndIf 
		Wend 
		Return PList
	End Function 

End Type 

'Type PowerType
'	Field Name:String
'	Field GUID:String 
'End Type 