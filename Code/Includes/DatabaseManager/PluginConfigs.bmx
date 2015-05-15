Type HotkeyPluginWindow Extends wxFrame
	Field KeyCode:wxTextCtrl
	Field ConfigLocation:String 
	
	Method OnInit()
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		Local ST1 = New wxStaticText.Create(Self , wxID_ANY , "Enter hotkey number for this plugin. ~nUse the button to bring up a list of valid hotkey values (Use binary values)" , - 1 , - 1 , - 1 , - 1 , wxALIGN_CENTRE)			
		Local KeyCodeButton:wxButton = New wxButton.Create(Self , HKPW_KCB , "Open Keycode List")
	
		
		KeyCode = New wxTextCtrl.Create(Self , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 , 0 )
		Local SaveButton:wxButton = New wxButton.Create(Self , HKPW_SB , "Save")
		
		vbox.Add(ST1, 1 , wxEXPAND , 0)
		vbox.AddSpacer(20)
		vbox.Add(KeyCode, 1 , wxEXPAND , 0)
		vbox.AddSpacer(20)
		vbox.Add(KeyCodeButton, 1 , wxEXPAND , 0)
		vbox.AddSpacer(20)
		vbox.Add(SaveButton, 1 , wxEXPAND , 0)
		Self.SetSizer(vbox)
		Self.Show()
		Self.Center()
		
		Connect(HKPW_KCB , wxEVT_COMMAND_BUTTON_CLICKED , OpenKeyListFun)
		Connect(HKPW_SB , wxEVT_COMMAND_BUTTON_CLICKED , SavePluginFun)
	End Method 

	Function OpenKeyListFun(event:wxEvent)
		OpenURL("http://www.indigorose.com/webhelp/ams/Program_Reference/Misc/Virtual_Key_Codes.htm")
	End Function 

	Function SavePluginFun(event:wxEvent)
		HotkeyWindow:HotkeyPluginWindow = HotkeyPluginWindow(event.parent)
		If HotkeyWindow.SavePlugin() = True Then
			HotkeyWindow.Destroy()
		EndIf 
	End Function 
	
	Method SavePlugin()
		Local MessageBox:wxMessageDialog
		Local SaveSettings:SettingsType = New SettingsType
		SaveSettings.ParseFile(ConfigLocation , "PluginConfig")
		SaveSettings.SaveSetting("key" , KeyCode.GetValue())
		SaveSettings.SaveFile()
		SaveSettings.CloseFile()	
		
		Return True 	
	End Method 

	
	Method UpdateData(ConfigFile:String)
		ConfigLocation = ConfigFile
		Local temp:String 
		Local ReadSettings:SettingsType = New SettingsType
		ReadSettings.ParseFile(ConfigFile , "PluginConfig")
		Local Key:String = ReadSettings.GetSetting("key")
		ReadSettings.CloseFile()		
		KeyCode.ChangeValue(Key)
	End Method
End Type 

Type PowerPlanPluginWindow Extends wxFrame
	Field PowPlans:TList 
	Field StartPlanBox:wxListBox	
	Field FinishPlanBox:wxListBox
	Field ConfigLocation:String 
	
	Method OnInit()
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
		
		Local SaveButton:wxButton = New wxButton.Create(Self , PPPW_SB , "Save")
		
		vbox.Add(ST1, 0 , wxEXPAND , 0)
		vbox.Add(StartPlanBox, 1 , wxEXPAND , 0)
		vbox.Add(ST2, 0 , wxEXPAND , 0)
		vbox.Add(FinishPlanBox, 1 , wxEXPAND , 0)
		vbox.Add(SaveButton, 0 , wxEXPAND , 0)
		
		Connect(PPPW_SB , wxEVT_COMMAND_BUTTON_CLICKED , SavePluginFun)
		
		SetSizer(vbox)
		Self.Centre()
		Self.Show()		
	End Method 
	
	Function SavePluginFun(event:wxEvent)
		PowerWindow:PowerPlanPluginWindow = PowerPlanPluginWindow(event.parent)
		If PowerWindow.SavePlugin() = True Then
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