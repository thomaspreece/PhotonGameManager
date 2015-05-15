Type KeyboardInputWindow Extends wxFrame
	Field ParentWin:SettingsWindow
	Field InputBoxes:wxTextCtrl[14]
	Field ActiveField:Int
	Field ActiveValue:String
	Field KeyCountdown:wxTimer
	Field FrontEndSettingFile:SettingsType
	
	Method OnInit()
	
		FrontEndSettingFile = New SettingsType
		FrontEndSettingFile.ParseFile(SETTINGSFOLDER + "FrontEnd.xml")
	
		ParentWin = SettingsWindow(GetParent() )
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Self.Centre()
		Self.Hide()
		
		Self.ActiveField = - 1
		Local ScrollBox:wxScrolledWindow = New wxScrolledWindow.Create(Self, wxID_ANY, - 1, - 1, - 1, - 1, wxVSCROLL)
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local BottomButtonSizer:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BackButton:wxButton = New wxButton.Create(Self , KIW_BB , "Back")
		Local OKButton:wxButton = New wxButton.Create(Self, KIW_OB , "Save")
		BottomButtonSizer.Add(BackButton, 1 , wxEXPAND | wxALL , 4)
		BottomButtonSizer.Add(OKButton, 1 , wxEXPAND | wxALL , 4)
		
		Local InputSizer:wxBoxSizer 
		Local StaticText:wxStaticText
		Local Button:KeyboardInputButton
		
		For a=0 To 13
			InputSizer = New wxBoxSizer.Create(wxHORIZONTAL)
			StaticText = New wxStaticText.Create(ScrollBox , wxID_ANY , KeyboardInputText[a] , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
			InputBoxes[a] = New wxTextCtrl.Create(ScrollBox , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 , 0 )
			Button = KeyboardInputButton(New KeyboardInputButton.Create(ScrollBox, Int(KIW_B + a) , "Change") )
			InputSizer.Add(StaticText, 2 , wxEXPAND | wxALL , 4)
			InputSizer.Add(InputBoxes[a], 2 , wxEXPAND | wxALL , 4)
			InputSizer.Add(Button, 1 , wxEXPAND | wxALL , 4)
			vbox2.AddSizer(InputSizer, 0 , wxEXPAND | wxALL , 4)
			Connect(Int(KIW_B+a) , wxEVT_COMMAND_BUTTON_CLICKED , SetKey, String(a))
		Next
		
		ScrollBox.SetSizer(vbox2)
		ScrollBox.SetScrollRate(20, 20)
		
		Local temp:Int 
			
		If FrontEndSettingFile.GetSetting("KEYBOARD_BIGCOVER") <> "" then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_BIGCOVER"))
			InputBoxes[0].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[0].ChangeValue(KEY_1+" ("+getKeyCodeChar(KEY_1)+")")
		EndIf 
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_FLIPCOVER") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_FLIPCOVER"))
			InputBoxes[1].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[1].ChangeValue(KEY_2+" ("+getKeyCodeChar(KEY_2)+")")
		EndIf 		
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_RIGHT") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_RIGHT"))
			InputBoxes[2].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[2].ChangeValue(KEY_RIGHT+" ("+getKeyCodeChar(KEY_RIGHT)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_LEFT") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_LEFT"))
			InputBoxes[3].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[3].ChangeValue(KEY_LEFT+" ("+getKeyCodeChar(KEY_LEFT)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_UP") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_UP"))
			InputBoxes[4].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[4].ChangeValue(KEY_UP+" ("+getKeyCodeChar(KEY_UP)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_DOWN") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_DOWN"))
			InputBoxes[5].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[5].ChangeValue(KEY_DOWN+" ("+getKeyCodeChar(KEY_DOWN)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_ENTER") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_ENTER"))
			InputBoxes[6].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[6].ChangeValue(KEY_ENTER+" ("+getKeyCodeChar(KEY_ENTER)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_INFO") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_INFO"))
			InputBoxes[7].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[7].ChangeValue(KEY_I+" ("+getKeyCodeChar(KEY_I)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_ESC") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_ESC"))
			InputBoxes[8].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[8].ChangeValue(KEY_F1+" ("+getKeyCodeChar(KEY_F1)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_MENU") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_MENU"))
			InputBoxes[9].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[9].ChangeValue(KEY_M+" ("+getKeyCodeChar(KEY_M)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_FILTER") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_FILTER"))
			InputBoxes[10].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[10].ChangeValue(KEY_F+" ("+getKeyCodeChar(KEY_F)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_PLATROTATE") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_PLATROTATE"))
			InputBoxes[11].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[11].ChangeValue(KEY_P+" ("+getKeyCodeChar(KEY_P)+")")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_SCREEN") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_SCREEN"))
			InputBoxes[12].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[12].ChangeValue(KEY_S+" ("+getKeyCodeChar(KEY_S)+")")			
		EndIf
		
		If FrontEndSettingFile.GetSetting("KEYBOARD_END") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("KEYBOARD_END"))
			InputBoxes[13].ChangeValue(temp+" ("+getKeyCodeChar(temp)+")")
		Else
			InputBoxes[13].ChangeValue(KEY_ESCAPE+" ("+getKeyCodeChar(KEY_ESCAPE)+")")			
		EndIf																			
		
		KeyCountdown = New wxTimer.Create(Self,KIW_T)
			
		Connect(KIW_T , wxEVT_TIMER , KeyTimeout)	
		
		vbox.Add(ScrollBox, 1, wxEXPAND, 0)
		vbox.AddSizer(BottomButtonSizer, 0 , wxEXPAND | wxALL , 4)

		Connect(KIW_BB , wxEVT_COMMAND_BUTTON_CLICKED , ShowSettingsWindows)
		Connect(KIW_OB , wxEVT_COMMAND_BUTTON_CLICKED , SaveInputFun)

		SetSizer(vbox)
		
	End Method
	
	Function SaveInputFun(event:wxEvent)
		Local KeyboardInputWin:KeyboardInputWindow = KeyboardInputWindow(event.parent)

		If Int(KeyboardInputWin.InputBoxes[0].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_BIGCOVER" , Int(KeyboardInputWin.InputBoxes[0].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[1].GetValue())<>0		
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_FLIPCOVER" , Int(KeyboardInputWin.InputBoxes[1].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[2].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_RIGHT" , Int(KeyboardInputWin.InputBoxes[2].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[3].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_LEFT" , Int(KeyboardInputWin.InputBoxes[3].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[4].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_UP" , Int(KeyboardInputWin.InputBoxes[4].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[5].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_DOWN" , Int(KeyboardInputWin.InputBoxes[5].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[6].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_ENTER" , Int(KeyboardInputWin.InputBoxes[6].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[7].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_INFO" , Int(KeyboardInputWin.InputBoxes[7].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[8].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_ESC" , Int(KeyboardInputWin.InputBoxes[8].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[9].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_MENU" , Int(KeyboardInputWin.InputBoxes[9].GetValue()))
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[10].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_FILTER" , Int(KeyboardInputWin.InputBoxes[10].GetValue()))		
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[11].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_PLATROTATE" , Int(KeyboardInputWin.InputBoxes[11].GetValue()))		
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[12].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_SCREEN" , Int(KeyboardInputWin.InputBoxes[12].GetValue()))		
		EndIf 
		If Int(KeyboardInputWin.InputBoxes[13].GetValue())<>0
			KeyboardInputWin.FrontEndSettingFile.SaveSetting("KEYBOARD_END" , Int(KeyboardInputWin.InputBoxes[13].GetValue()))		
		EndIf 		
		
		KeyboardInputWin.FrontEndSettingFile.SaveFile()
		
		Local MessageBox:wxMessageDialog

		MessageBox = New wxMessageDialog.Create(Null , "Settings saved." , "Info" , wxOK | wxICON_INFORMATION)
		MessageBox.ShowModal()
		MessageBox.Free()			
		
		KeyboardInputWin.ShowSettingsWindows(event)
	End Function 	

	Function SetKey(event:wxEvent)
		Local KeyboardInputWin:KeyboardInputWindow = KeyboardInputWindow(event.parent)
		
		Local a:String=String(event.userData)
		Local b:Int = Int(String(a))

		KeyboardInputWin.ActiveValue = KeyboardInputWin.InputBoxes[b].GetValue()
		KeyboardInputWin.InputBoxes[b].ChangeValue("Press Key Now!")
		KeyboardInputWin.ActiveField = b
		KeyboardInputWin.KeyCountdown.Start(3000)	
	End Function 
	
	Function KeyTimeout(event:wxEvent)
		Local KeyboardInputWin:KeyboardInputWindow = KeyboardInputWindow(event.parent)
		If KeyboardInputWin.ActiveField = -1 Then 
			KeyboardInputWin.KeyCountdown.Stop()
		Else
			KeyboardInputWin.KeyCountdown.Stop()
			KeyboardInputWin.InputBoxes[KeyboardInputWin.ActiveField].ChangeValue(KeyboardInputWin.ActiveValue)
			KeyboardInputWin.ActiveField = -1
		EndIf 

		
	End Function 	

	Function ShowSettingsWindows(event:wxEvent)
		Local SettingsWin:SettingsWindow = KeyboardInputWindow(event.parent).ParentWin
		SettingsWin.Show()
		SettingsWin.KeyboardInputField.Destroy()
		SettingsWin.KeyboardInputField = Null 
	End Function
	

End Type 

Type KeyboardInputButton Extends wxButton
	Field ParentWin:KeyboardInputWindow
	
	Method OnInit()
		ParentWin = KeyboardInputWindow( wxScrolledWindow(GetParent() ).GetParent() )
		
		Super.OnInit()
		ConnectAny(wxEVT_KEY_DOWN, OnKeyDown)
	End Method
		
	Function OnKeyDown(event:wxEvent)
		Local KeyboardInputWin:KeyboardInputWindow = KeyboardInputWindow(KeyboardInputButton(event.parent).ParentWin)
		Local evt:wxKeyEvent = wxKeyEvent(event)
		If KeyboardInputWin.ActiveField = - 1 then
		
		Else
			KeyboardInputWin.InputBoxes[KeyboardInputWin.ActiveField].ChangeValue(MapWxKeyCodeToBlitz(evt.GetKeyCode())+" ("+getKeyCodeChar(MapWxKeyCodeToBlitz(evt.GetKeyCode()))+")")
			For b=0 To 10
				If b=KeyboardInputWin.ActiveField Then 
				
				Else
					If Int(KeyboardInputWin.InputBoxes[b].GetValue())=MapWxKeyCodeToBlitz(evt.GetKeyCode()) Then 
						KeyboardInputWin.InputBoxes[b].ChangeValue("")
					EndIf 
				EndIf
			Next	
			
			KeyboardInputWin.ActiveValue = ""
			KeyboardInputWin.ActiveField = -1
			event.StopPropagation()
		EndIf
		
	End Function
End Type





Type JoyStickInputWindow Extends wxFrame
	Field ParentWin:SettingsWindow
	Field InputBoxes:wxTextCtrl[10]
	Field ActiveField:Int 
	Field ActiveValue:String
	Field JoyCountdown:wxTimer
	Field JoyKeyTimer:wxTimer
	Field FrontEndSettingFile:SettingsType
	Field JoyNumber:Int
	
	Method OnInit()
	
		JoyNumber = JoyCount()
	
		FrontEndSettingFile = New SettingsType
		FrontEndSettingFile.ParseFile(SETTINGSFOLDER+"FrontEnd.xml")
	
		ParentWin = SettingsWindow(GetParent())
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )		
		Self.SetBackgroundColour(New wxColour.Create(PMRed, PMGreen, PMBlue) )
		Self.SetFont(PMFont)
		Self.SetForegroundColour(New wxColour.Create(PMRedF, PMGreenF, PMBlueF) )
		
		Self.Centre()
		Self.Hide()
		
		Self.ActiveField = - 1
		Local ScrollBox:wxScrolledWindow = New wxScrolledWindow.Create(Self, wxID_ANY, - 1, - 1, - 1, - 1, wxHSCROLL)
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local vbox2:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		
		Local BottomButtonSizer:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local BackButton:wxButton = New wxButton.Create(Self , KIW_BB , "Back")
		Local OKButton:wxButton = New wxButton.Create(Self, KIW_OB , "Save")
		BottomButtonSizer.Add(BackButton, 1 , wxEXPAND | wxALL , 4)
		BottomButtonSizer.Add(OKButton, 1 , wxEXPAND | wxALL , 4)
		
		Local InputSizer:wxBoxSizer 
		Local StaticText:wxStaticText
		Local Button:wxButton 
		
		For a=0 To 9
			InputSizer = New wxBoxSizer.Create(wxHORIZONTAL)
			StaticText = New wxStaticText.Create(ScrollBox , wxID_ANY , JoyStickInputText[a] , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)	
			InputBoxes[a] = New wxTextCtrl.Create(ScrollBox , wxID_ANY , "" , - 1 , - 1 , - 1 , - 1 , 0 )
			Button = New wxButton.Create(ScrollBox, Int(KIW_B + a) , "Change")
			InputSizer.Add(StaticText, 2 , wxEXPAND | wxALL , 4)
			InputSizer.Add(InputBoxes[a], 2 , wxEXPAND | wxALL , 4)
			InputSizer.Add(Button, 1 , wxEXPAND | wxALL , 4)
			vbox2.AddSizer(InputSizer, 0 , wxEXPAND | wxALL , 4)
			Connect(Int(KIW_B+a) , wxEVT_COMMAND_BUTTON_CLICKED , SetKey, String(a))
		Next
		ScrollBox.SetSizer(vbox2)
		ScrollBox.SetScrollRate(20,20)
		Local temp:Int 
			
		If FrontEndSettingFile.GetSetting("JOY_BIGCOVER") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_BIGCOVER"))
			InputBoxes[0].ChangeValue(temp)
		Else
			InputBoxes[0].ChangeValue("4")
		EndIf 
		
		If FrontEndSettingFile.GetSetting("JOY_FLIPCOVER") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_FLIPCOVER"))
			InputBoxes[1].ChangeValue(temp)
		Else
			InputBoxes[1].ChangeValue("6")
		EndIf 		
		
		If FrontEndSettingFile.GetSetting("JOY_ENTER") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_ENTER"))
			InputBoxes[2].ChangeValue(temp)
		Else
			InputBoxes[2].ChangeValue("2")		
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("JOY_MENU") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_MENU"))
			InputBoxes[3].ChangeValue(temp)
		Else
			InputBoxes[3].ChangeValue("9")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("JOY_FILTER") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_FILTER"))
			InputBoxes[4].ChangeValue(temp)
		Else
			InputBoxes[4].ChangeValue("8")			
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("JOY_CANCEL") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_CANCEL"))
			InputBoxes[5].ChangeValue(temp)
		Else
			InputBoxes[5].ChangeValue("3")		
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("JOY_INFO") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_INFO"))
			InputBoxes[6].ChangeValue(temp)
		Else
			InputBoxes[6].ChangeValue("1")		
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("JOY_PLATROTATE") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_PLATROTATE"))
			InputBoxes[7].ChangeValue(temp)
		Else
			InputBoxes[7].ChangeValue("5")		
		EndIf 	
		
		If FrontEndSettingFile.GetSetting("JOY_SCREEN") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_SCREEN"))
			InputBoxes[8].ChangeValue(temp)
		Else
			InputBoxes[8].ChangeValue("7")		
		EndIf 
		
		If FrontEndSettingFile.GetSetting("JOY_END") <> "" Then
			temp = Int(FrontEndSettingFile.GetSetting("JOY_END"))
			InputBoxes[9].ChangeValue(temp)
		Else
			InputBoxes[9].ChangeValue("10")		
		EndIf 																	
		
		JoyCountdown = New wxTimer.Create(Self,KIW_T)
		JoyKeyTimer = New wxTimer.Create(Self,KIW_JKT)
 
			
		Connect(KIW_T , wxEVT_TIMER , JoyTimeout)	
		Connect(KIW_JKT , wxEVT_TIMER , GetJoyKey)	
		
		vbox.Add(ScrollBox, 1, wxEXPAND, 0)
		vbox.AddSizer(BottomButtonSizer, 0 , wxEXPAND | wxALL , 4)

		Connect(KIW_BB , wxEVT_COMMAND_BUTTON_CLICKED , ShowSettingsWindows)
		Connect(KIW_OB , wxEVT_COMMAND_BUTTON_CLICKED , SaveInputFun)

		SetSizer(vbox)
		
	End Method
	
	Function SaveInputFun(event:wxEvent)
		Local JoyStickInputWin:JoyStickInputWindow = JoyStickInputWindow(event.parent)

		If Int(JoyStickInputWin.InputBoxes[0].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_BIGCOVER" , Int(JoyStickInputWin.InputBoxes[0].GetValue()))
		EndIf
		If Int(JoyStickInputWin.InputBoxes[1].GetValue())<>0		
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_FLIPCOVER" , Int(JoyStickInputWin.InputBoxes[1].GetValue()))
		EndIf 
		If Int(JoyStickInputWin.InputBoxes[2].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_ENTER" , Int(JoyStickInputWin.InputBoxes[2].GetValue()))
		EndIf 
		If Int(JoyStickInputWin.InputBoxes[3].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_MENU" , Int(JoyStickInputWin.InputBoxes[3].GetValue()))
		EndIf 
		If Int(JoyStickInputWin.InputBoxes[4].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_FILTER" , Int(JoyStickInputWin.InputBoxes[4].GetValue()))
		EndIf 
		If Int(JoyStickInputWin.InputBoxes[5].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_CANCEL" , Int(JoyStickInputWin.InputBoxes[5].GetValue()))
		EndIf 
		If Int(JoyStickInputWin.InputBoxes[6].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_INFO" , Int(JoyStickInputWin.InputBoxes[6].GetValue()))
		EndIf 
		If Int(JoyStickInputWin.InputBoxes[7].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_PLATROTATE" , Int(JoyStickInputWin.InputBoxes[7].GetValue()))
		EndIf 	
		If Int(JoyStickInputWin.InputBoxes[8].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_SCREEN" , Int(JoyStickInputWin.InputBoxes[8].GetValue()))
		EndIf 
		If Int(JoyStickInputWin.InputBoxes[9].GetValue())<>0
			JoyStickInputWin.FrontEndSettingFile.SaveSetting("JOY_END" , Int(JoyStickInputWin.InputBoxes[9].GetValue()))
		EndIf			
				
		JoyStickInputWin.FrontEndSettingFile.SaveFile()
		
		Local MessageBox:wxMessageDialog

		MessageBox = New wxMessageDialog.Create(Null , "Settings saved." , "Info" , wxOK | wxICON_INFORMATION)
		MessageBox.ShowModal()
		MessageBox.Free()			
		
		JoyStickInputWin.ShowSettingsWindows(event)
	End Function 	

	Function SetKey(event:wxEvent)
		Local JoyStickInputWin:JoyStickInputWindow = JoyStickInputWindow(event.parent)
		
		Local a:String=String(event.userData)
		Local b:Int = Int(String(a))

		JoyStickInputWin.ActiveValue = JoyStickInputWin.InputBoxes[b].GetValue()
		JoyStickInputWin.InputBoxes[b].ChangeValue("Press Joy Key Now!")
		JoyStickInputWin.ActiveField = b
		JoyStickInputWin.JoyCountdown.Start(3000)	
		JoyStickInputWin.JoyKeyTimer.Start(100)	

	End Function 
	
	Function GetJoyKey(event:wxEvent)
		Local JoyStickInputWin:JoyStickInputWindow = JoyStickInputWindow(event.parent)
		
		If JoyStickInputWin.JoyNumber > 0 then
			For a = 1 To 20
				If JoyHit(a) then
					JoyStickInputWin.InputBoxes[JoyStickInputWin.ActiveField].ChangeValue(a)
					'Delete Duplicate Values
					For b = 0 To 6
						If b=JoyStickInputWin.ActiveField Then 
						
						Else
							If Int(JoyStickInputWin.InputBoxes[b].GetValue())=a Then 
								JoyStickInputWin.InputBoxes[b].ChangeValue("")
							EndIf 
						EndIf
					Next				
					JoyStickInputWin.ActiveValue = ""
					JoyStickInputWin.ActiveField = -1
					JoyStickInputWin.JoyKeyTimer.Stop()
					Return 			
				EndIf 
			Next
		EndIf
	End Function
	
	Function JoyTimeout(event:wxEvent)
		Local JoyStickInputWin:JoyStickInputWindow = JoyStickInputWindow(event.parent)
		If JoyStickInputWin.ActiveField = - 1 then
			JoyStickInputWin.JoyCountdown.Stop()
		Else
			JoyStickInputWin.JoyCountdown.Stop()
			JoyStickInputWin.InputBoxes[JoyStickInputWin.ActiveField].ChangeValue(JoyStickInputWin.ActiveValue)
			JoyStickInputWin.ActiveField = -1
		EndIf 

		
	End Function 	

	Function ShowSettingsWindows(event:wxEvent)
		Local SettingsWin:SettingsWindow = JoyStickInputWindow(event.parent).ParentWin
		SettingsWin.JoyStickInputField.JoyCountdown.Stop()
		SettingsWin.JoyStickInputField.JoyKeyTimer.Stop()
		
		SettingsWin.Show()
		SettingsWin.JoyStickInputField.Destroy()
		SettingsWin.JoyStickInputField = Null 
	End Function
	

End Type 

Rem

Type JoystickInputButton Extends wxButton
	Field ParentWin:JoyStickInputWindow
	
	Method OnInit()
		ParentWin = JoyStickInputWindow(GetParent())
		Super.OnInit()
		ConnectAny(wxEVT_KEY_DOWN, OnKeyDown)
	End Method
		
	Function OnKeyDown(event:wxEvent)
		Local JoyStickInputWin:JoyStickInputWindow = JoyStickInputWindow(KeyboardInputButton(event.parent).ParentWin)
		Local evt:wxKeyEvent = wxKeyEvent(event)
		If JoyStickInputWin.ActiveField = -1 Then 
		
		Else
			JoyStickInputWin.InputBoxes[JoyStickInputWin.ActiveField].ChangeValue(MapWxKeyCodeToBlitz(evt.GetKeyCode())+" ("+getKeyCodeChar(MapWxKeyCodeToBlitz(evt.GetKeyCode()))+")")
			JoyStickInputWin.ActiveValue = ""
			JoyStickInputWin.ActiveField = -1
			event.StopPropagation()
		EndIf 
		
	End Function
End Type

EndRem 