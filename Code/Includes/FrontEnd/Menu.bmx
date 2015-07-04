Type MenuWrapperType Extends GeneralType
	
	Field MenuImage:TImage
	Field MenuImage2:TImage
	Field MenuImage3:TImage 	
	Field FilterImage:TImage
	Field MenuPix:TPixmap
	Field MenuPix2:TPixmap
	Field MenuPix3:TPixmap
	
	Field OldFilterType:String = ""
	Field OldFilterName:String = ""
	
	Field MenuSelected:Int 
	Field FilterSelected:Int

	Field MenuActive:Int
	Field KeyDelayTimer:Int 
	Field FilterActive:Int
	
	Field BackAlpha:Float
	Field Menu1:Menu1Type
	Field Menu2:Menu2Type
	Field ActiveMenuNumber:Int 
	
	Field SelectedMenuAlpha:Float
	Field AlphaDir:Int
	
	Field TouchButton:TImage
	
	Field TouchKeySelected:int
	Field TouchJoySelected:Int 
'	Field TouchKeyboardEnabled:Int = True
	
	Field FirstMenu1Run:Int 
	
	Field FilterTypeSelected:Int
	Field FilterNameSelected:Int 
	
	Field Width80:Int = GWidth * (Float(80) / 800)
	Field Height75:int = GHeight * (Float(75) / 600)
	Field Height300:Int = GHeight * (Float(300)/600)
	
	Method Init()
		SelectedMenuAlpha = 1
		TouchJoySelected = -1
		AlphaDir = - 1
		Menu1 = New Menu1Type
		Menu1.Init()
		
		Menu2 = New Menu2Type
		Menu2.Init()
		
		InfoSelected = False
		MenuSelected = False
		
		FilterTypeSelected = False
		FilterNameSelected = False 		
		
		MenuActive = False
		FilterSelected = False
		FilterActive = False 

		ListAddFirst(UpdateTypeList , Self)
		
		FilterPix:TPixmap = LoadPixmap(RESFOLDER + "FilterButton.png")
		If FilterPix = Null then RuntimeError "FilterButton.png Missing!"	
		'FilterPix = ResizePixmap(FilterPix , GWidth*(Float(300)/800) , GHeight*(Float(25)/600) )
		FilterImage = LoadImage(ResizeMenuPixmap(FilterPix, GWidth * (Float(300) / 800) , GHeight * (Float(23) / 600) , "FilterButton.png", 1) )				
		If FilterImage = Null then RuntimeError "FilterButton.png Missing!"	
		
		MenuPix = LoadPixmap(RESFOLDER + "MenuButton.png")
		If MenuPix = Null then RuntimeError "MenuButton.png Missing!"	
				
		MenuPix2 = LoadPixmap(RESFOLDER + "SubMenuButton.png")
		If MenuPix2 = Null then RuntimeError "SubMenuButton.png Missing!"	
		
		MenuPix3 = LoadPixmap(RESFOLDER + "SubSubMenuButton.png")
		If MenuPix3 = Null then RuntimeError "SubSubMenuButton.png Missing!"	
		
		MenuImage = LoadImage(ResizeMenuPixmap(MenuPix, GWidth * (Float(80) / 800), GHeight * (Float(25) / 600) , "MenuButton.png") )
		MenuImage2 = LoadImage(ResizeMenuPixmap(MenuPix2, GWidth * (Float(140) / 800) , GHeight * (Float(23) / 600), "SubMenuButton.png" ) )
		MenuImage3 = LoadImage(ResizeMenuPixmap(MenuPix3, GWidth * (Float(140) / 800) , GHeight * (Float(21) / 600), "SubSubMenuButton.png" ) )
		
		If MenuImage = Null then RuntimeError "MenuButton.png Missing!"	
		If MenuImage2 = Null then RuntimeError "SubMenuButton.png Missing!"	
		If MenuImage3 = Null then RuntimeError "SubSubMenuButton.png Missing!"			
		
		TouchPix:TPixmap = LoadPixmap(RESFOLDER + "TouchButton.png")
		If TouchPix = Null Then RuntimeError "TouchButton.png Missing!"			
		TouchPix = ResizePixmap(TouchPix , GWidth*(Float(80)/800) , GHeight*(Float(75)/600) )
		TouchButton = LoadImage(TouchPix)				
		If TouchButton = Null Then RuntimeError "TouchButton.png Missing!"			
	End Method
	
	Function ResizeMenuPixmap:TPixmap(Pixmap:TPixmap, TargetW:Int, TargetH:Int, Name:String, CropDirection:Int = - 1)
		'Resize Pixmap to have height TargetH but keep dimensions same
		Local MenuPixResized:TPixmap = ResizePixmap(Pixmap, Pixmap.width * (Float(TargetH) / Pixmap.height), TargetH )
		If MenuPixResized.width < TargetW then
			CustomRuntimeError("ResizeMenuPixmap: Pixmap is too small in length (" + TargetW + ">" + MenuPixResized.width + ") " + Name)
		EndIf
		If CropDirection = - 1 then
			'Crop from right hand side to have correct width
			Return PixmapWindow(MenuPixResized, MenuPixResized.width - TargetW, 0, TargetW, MenuPixResized.height).Copy()
		Else
			'Crop from left hand side to have correct width
			Return PixmapWindow(MenuPixResized, 0, 0, TargetW, MenuPixResized.height).Copy()
		EndIf
	End Function
	
	Method Max2D()
		If OldFilterType <> FilterType Then
			SetImageFont(SmallMenuButtonFont)
			MenuImage2 = LoadImage(ResizeMenuPixmap(MenuPix2, TextWidth(FilterType) + GWidth * (Float(35) / 800) , GHeight * (Float(23) / 600) , "SubMenuButton.png") )
			OldFilterType = FilterType
		EndIf
		
		If OldFilterName <> FilterName then
			SetImageFont(SmallMenuButtonFont)
			MenuImage3 = LoadImage(ResizeMenuPixmap(MenuPix3, TextWidth(FilterName) + GWidth * (Float(35) / 800) , GHeight * (Float(21) / 600), "SubSubMenuButton.png" ) )
			OldFilterName = FilterName
		EndIf
		
		If ShowNavigation = True then
			If FilterType <> "" then
				If FilterName <> "" then
					If ShowMenuButton = True then
						DrawImage(MenuImage3 , MenuImage.width + MenuImage2.width, 0 )
					Else
						DrawImage(MenuImage3 , MenuImage2.width, 0 )
					EndIf
				EndIf
				If ShowMenuButton = True then
					DrawImage(MenuImage2 , MenuImage.width, 0 )
				Else
					DrawImage(MenuImage2 , 0, 0 )
				EndIf
			EndIf
		EndIf
		

		If ShowMenuButton = True then
			DrawImage(MenuImage , 0 , 0 )
			If MenuSelected = True then
				If AlphaDir = 1 Then
					SelectedMenuAlpha = SelectedMenuAlpha - 0.01
					If SelectedMenuAlpha < 0.3 Then AlphaDir = -1
				ElseIf AlphaDir = -1
					SelectedMenuAlpha = SelectedMenuAlpha + 0.01
					If SelectedMenuAlpha > 0.9 Then AlphaDir = 1		
				EndIf 		
				SetColor 135 , 153 , 255
				SetAlpha(SelectedMenuAlpha)
			Else
				SetColor 255 , 255 , 255
			EndIf
			SetImageFont(MenuButtonFont)
			DrawText("Menu" , MenuImage.width / 2 - (TextWidth("Menu") / 2) , (MenuImage.height / 2 - (TextHeight("Menu") / 2) ) - GHeight * (Float(2) / 600) )
		EndIf
		
		
		
		If ShowNavigation = True then
			If FilterTypeSelected = True then
				If AlphaDir = 1 Then
					SelectedMenuAlpha = SelectedMenuAlpha - 0.01
					If SelectedMenuAlpha < 0.3 Then AlphaDir = -1
				ElseIf AlphaDir = -1
					SelectedMenuAlpha = SelectedMenuAlpha + 0.01
					If SelectedMenuAlpha > 0.9 Then AlphaDir = 1		
				EndIf 		
				SetColor 135 , 153 , 255
				SetAlpha(SelectedMenuAlpha)
			Else
				SetColor 255 , 255 , 255
				SetAlpha(1)
			EndIf
			
			SetImageFont(SmallMenuButtonFont)
			If FilterType <> "" then
				If ShowMenuButton = True then
					DrawText(FilterType , MenuImage.width + MenuImage2.width / 2 - ( (TextWidth(FilterType) / 2) ) , (MenuImage2.height / 2 - (TextHeight("Menu") / 2) ) - GHeight * (Float(2) / 600) )
				Else
					DrawText(FilterType , MenuImage2.width / 2 - ( (TextWidth(FilterType) / 2) ) , (MenuImage2.height / 2 - (TextHeight("Menu") / 2) ) - GHeight * (Float(2) / 600) )
				EndIf
			EndIf
			
			If FilterNameSelected = True then
				If AlphaDir = 1 Then
					SelectedMenuAlpha = SelectedMenuAlpha - 0.01
					If SelectedMenuAlpha < 0.3 Then AlphaDir = -1
				ElseIf AlphaDir = -1
					SelectedMenuAlpha = SelectedMenuAlpha + 0.01
					If SelectedMenuAlpha > 0.9 Then AlphaDir = 1		
				EndIf 		
				SetColor 135 , 153 , 255
				SetAlpha(SelectedMenuAlpha)
			Else
				SetColor 255 , 255 , 255
				SetAlpha(1)
			EndIf		
			
			If FilterType <> "" And FilterName <> "" then
				If ShowMenuButton = True then
					DrawText(FilterName , MenuImage.width + MenuImage2.width + MenuImage3.width / 2 - ( (TextWidth(FilterName) / 2) ) , (MenuImage3.height / 2 - (TextHeight("Menu") / 2) ) - GHeight * (Float(2) / 600) )
				Else
					DrawText(FilterName , MenuImage2.width + MenuImage3.width / 2 - ( (TextWidth(FilterName) / 2) ) , (MenuImage3.height / 2 - (TextHeight("Menu") / 2) ) - GHeight * (Float(2) / 600) )
				EndIf
			EndIf 	
			SetImageFont(MenuButtonFont)
			SetColor 255 , 255 , 255
			SetAlpha(1)							
		EndIf
		

		

		If ShowSearchBar = True then 
			DrawImage(FilterImage , GWidth * (1 - Float(300) / 800) , 0 )
			If (FilterSelected = False And FilterActive = True) Or (FilterSelected = True And FilterActive = False) then
				If AlphaDir = 1 Then
					SelectedMenuAlpha = SelectedMenuAlpha - 0.01
					If SelectedMenuAlpha < 0.3 Then AlphaDir = -1
				ElseIf AlphaDir = -1
					SelectedMenuAlpha = SelectedMenuAlpha + 0.01
					If SelectedMenuAlpha > 0.9 Then AlphaDir = 1		
				EndIf 		
				SetColor 135 , 153 , 255
				SetAlpha(SelectedMenuAlpha)	
				'SetImageFont(FilterFont)	
				'SetImageFont(MenuButtonFont)
				SetImageFont(SmallMenuButtonFont)
			ElseIf (FilterSelected = False And FilterActive = False) Or (FilterSelected = True And FilterActive = True)
				SetColor 255 , 255 , 255
				'SetImageFont(MenuButtonFont)
				SetImageFont(SmallMenuButtonFont)
			EndIf
			
			DrawText("Search: " + Filter , GWidth * (1 - Float(290) / 800) , (MenuImage.height / 2 - (TextHeight("Filter Box:") / 2) ) - GHeight * (Float(2) / 600) )
		EndIf
		
		SetAlpha(1)
		SetColor 255, 255, 255
		
		Local Gap:Int = GWidth - 10 * Width80
		
		If FilterActive = True then
			
			If TouchKeyboardEnabled = True then
				SetImageFont(MenuButtonFont)
				SetAlpha(0.9)
				For b = 0 To 3			
					For a = 0 To 9
						If TouchKeySelected = b * 10 + a + 1 Or TouchJoySelected = b * 10 + a + 1 then
							SetColor(150 , 150 , 150)
						Else
							SetColor(255 , 255 , 255)
						EndIf
						DrawImage(TouchButton , Gap / 2 + a * Width80 , Height300 + b * Height75)
						SetColor(255, 255, 255)
						DrawText(KeyboardLayout[b * 10 + a] , Gap / 2 + (Float(a + 0.5) * Width80) - TextWidth(KeyboardLayout[b * 10 + a]) / 2 , Height300 + (Float(b + 0.5) * Height75) - TextHeight(KeyboardLayout[b * 10 + a]) / 2 )
					Next
				Next
			EndIf
		EndIf 
	
		
		If MenuActive = True And ActiveMenuNumber = 1 Then
			SetColor(0,0,0)
			SetAlpha(BackAlpha)
			DrawRect(0,0,GWidth,GHeight) 
			SetColor(255,255,255)
			SetAlpha(1)		
			
			Menu1.DrawMenu(GWidth/2 , GHeight/2)	
		EndIf
		
		If MenuActive = True And ActiveMenuNumber = 2 Then		
			SetColor(0,0,0)
			SetAlpha(BackAlpha)
			DrawRect(0,0,GWidth,GHeight) 
			SetColor(255,255,255)
			SetAlpha(1)		
			
			Menu2.DrawMenu()		
		EndIf 
	End Method

	Method Update()
		If UpdateTypeList.First() <> Self Then
			UpdateTypeList.Remove(Self)
			ListAddFirst(UpdateTypeList , Self)
		EndIf
		Local LeftGap:Int = (GWidth - 10 * Width80) / 2
		Local RightGap:Int = (GWidth - 10 * Width80) - (GWidth - 10 * Width80) / 2
		Local LineNum:Int 
		If MouseY() > Height300 And MouseX() > LeftGap And MouseX() < (GWidth - RightGap - 1) then
			If MouseY() < Height300 + (1 * Height75) then
				LineNum = 0
			ElseIf MouseY() < Height300 + (2*Height75) Then
				LineNum = 1		
			ElseIf MouseY() < Height300 + (3*Height75) Then
				LineNum = 2		
			ElseIf MouseY() < Height300 + (4*Height75) Then
				LineNum = 3
			EndIf
			
			TouchKeySelected = Int( (MouseX() - (LeftGap / 2) ) / Width80) + 1 + LineNum * 10
		Else
			TouchKeySelected = - 1
		EndIf	
		
		If GameArrayLen < 1 Then
			MenuActive = False
		EndIf 
		If MenuActive = True Then
			If ActiveMenuNumber = 1 Then
				If FirstMenu1Run = True Then 
					Menu1.UpdateRunColumn()
					Menu1.UpdateRatingColumn()
					Menu1.UpdateCompleteColumn()
					FirstMenu1Run = False 
				EndIf 
			EndIf
			If ActiveMenuNumber = 2 Then
				Menu2.Update()
			EndIf 
			MenuActivated = True
			If BackAlpha < 0.9
				BackAlpha = BackAlpha + 0.05 * SpeedRatio
				If BackAlpha > 0.9 Then BackAlpha = 0.9
			Else
				BackAlpha = 0.9
			EndIf
		Else
			Menu1.SelectedMenu = 4
			FirstMenu1Run = True
			MenuActivated = False
			If MouseX() > 0 And MouseX() < MenuImage.width And MouseY() < MenuImage.height And ShowMenuButton = True then
				MenuSelected = True
			Else
				MenuSelected = False 
			EndIf

		EndIf

		If ShowMenuButton = True then
			If MouseX() > MenuImage.width And MouseX() < MenuImage.width + MenuImage2.width And MouseY() < MenuImage2.height And FilterType <> "" then
				FilterTypeSelected = True 
			Else
				FilterTypeSelected = False 
			EndIf
			
			If MouseX() > MenuImage.Width + MenuImage2.Width And MouseX() < MenuImage.Width + MenuImage2.Width + MenuImage3.Width And MouseY() < MenuImage2.Height And FilterType <> "" And FilterName <> "" Then
				FilterNameSelected = True 
			Else
				FilterNameSelected = False 
			EndIf
		Else
			If MouseX() > 0 And MouseX() < MenuImage2.Width And MouseY() < MenuImage2.Height And FilterType <> "" Then
				FilterTypeSelected = True 
			Else
				FilterTypeSelected = False 
			EndIf
			
			If MouseX() > MenuImage2.width And MouseX() < MenuImage2.width + MenuImage3.width And MouseY() < MenuImage2.height And FilterType <> "" And FilterName <> "" then
				FilterNameSelected = True 
			Else
				FilterNameSelected = False 
			EndIf		
		EndIf
		
		If MouseX() > GWidth*(1 - Float(300)/800) And MouseX() < GWidth And MouseY() < FilterImage.Height - 5 Then
			FilterSelected = True
		Else
			FilterSelected = False 
		EndIf			

	End Method
	
	Method UpdateMouse()
		If FilterActive = True then
		
			If TouchKeyboardEnabled = True Then
				Local Key:String
				If MouseClick = 1 And TouchKeySelected <> - 1 then
					Key = KeyboardLayout[TouchKeySelected - 1]
					Select Key
						Case "Cancel"
							Filter = ""
							FilterActive = False					
						Case "BkSp"
							Filter = Left(Filter,Len(Filter)-1)
						Case "Space"
							Filter = Filter + " "
							If Left(Filter , 1) = " " Then
								Filter = ""
							EndIf 
						Case "Go"
							If GameArrayLen > 0 then
								
								FilterActive = False
							EndIf
						Default
							Filter = Filter + Key
					End Select
					Return True 
				EndIf
			EndIf
			Return True 
		EndIf 
		If FilterTypeSelected = True And MouseClick = 1 Then
			If FilterName <> "" Then
				FilterName = ""
				ResetFilters()
				Select FilterType
					Case "Platform"
						GamesSortFilter = "Platform"
					Case "Genre"	
						GamesSortFilter = "Genre"
					Case "Release Date"
						GamesSortFilter = "Release Date"
					Case "Rating"
						GamesSortFilter = "Rating"
					Case "Status"
						GamesSortFilter = "Completed"
					Case "Players"
						GamesSortFilter = "Players"
					Case "Co-Op"
						GamesSortFilter = "Co-Op"
					Case "Developer"
						GamesSortFilter = "Developer"
					Case "Publisher"
						GamesSortFilter = "Publisher"
					Case "Certificate"
						GamesSortFilter = "Certificate"
					Default
						RuntimeError("Invalid Filter Type")
				End Select
				CurrentInterface.Clear()
				PopulateGames()
				ChangeInterface(CurrentInterfaceNumber , False, False)				
				Return True
			Else
				ChangeInterface(0, True , False )
				Return True 
			EndIf 
		EndIf
		If FilterNameSelected = True And MouseClick = 1 then
			ChangeInterface(0, True , False )
			Return True 
		EndIf		
		
		If MenuSelected = True And MouseClick = 1 Then
			ActiveMenuNumber = 2
			MenuSelected = False
			MenuActive = True
			BackAlpha = 0
			Return True 
		EndIf
		If FilterSelected = True And MouseClick = 1 then
			If FilterActive = False then
				FilterActive = True
				TouchJoySelected = - 1
				TouchKeySelected = - 1		
				FlushKeys()
				FlushJoy()
			Else
				If GameArrayLen > 0 then
					FilterActive = False
				EndIf
			EndIf
			FilterSelected = False
			Return True	
		EndIf		
		If MenuActive = True And ActiveMenuNumber = 2 And MouseClick = 1 Then
			Select Menu2.ActiveMenu
				Case "Main"
					Select Menu2.SelectedItem
						Case 1 'PlayGame
							Menu2.ActiveMenu = "PlayGame"
						Case 2 'Filter
							ChangeInterface(0, True , False )
							MenuActive = False
						Case 3 'Extras
							Menu2.ActiveMenu = "Extras"
						Case 4 'Install
							InstallGame()
						Case 5 'Interface
							Menu2.ActiveMenu = "Interface"
						Case 6 'Editgame
							RunProcess(MANAGERPROGRAM+" -EditGame "+Chr(34)+GameNode.OrginalName+Chr(34),1)
							ExitProgramCall = True 							
						Case 7 'Exit menu
							MenuActive = False 									
						Case 8 'Exit program
							ExitProgramCall = True 
					End Select
				Case "PlayGame"
					Select Menu2.SelectedItem
						Case 1 '..
							Menu2.ActiveMenu = "Main"
						Default
							RunProcess(RUNNERPROGRAM + " -GameName " + Chr(34) + GameNode.OrginalName + Chr(34) + " -EXENum " + String(Menu2.SelectedItem - 1) + " -Cabinate 1" , 1)
							ExitProgramCall = True
					End Select
				Case "Extras"
							
					Select Menu2.SelectedItem
						Case 1 '..
							Menu2.ActiveMenu = "Main"
						Case 2 'Patches
							RunProcess(EXPLORERPROGRAM + " -Game " + Chr(34) + GameNode.OrginalName + Chr(34) + " -GameTab Patches", 1)		
							ExitProgramCall = True
						Case 3 'Walkthroughs
							RunProcess(EXPLORERPROGRAM + " -Game " + Chr(34) + GameNode.OrginalName + Chr(34) + " -GameTab Walkthroughs", 1)		
							ExitProgramCall = True						
						Case 4 'ScreenShots
							If GameNode.ScreenShotsAvailable = 1 then
								ChangeInterface(7, True, 0 )
								MenuActive = False
							Else
								MenuActive = False
							EndIf
							'RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab ScreenShots",1)		
							'ExitProgramCall = True						
						Case 5 'Cheats
							RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab Cheats",1)		
							ExitProgramCall = True	
						Case 6 'Manuals
							RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab Manuals",1)		
							ExitProgramCall = True													
					End Select
					
				Case "Interface"
					Select Menu2.SelectedItem
						Case 1 '..
							Menu2.ActiveMenu = "Main"
						Case 2 'CoverFlow
							ChangeInterface(1)
							MenuActive = False 	
							SettingFile.SaveSetting("Interface" , "1")
							SettingFile.SaveFile()							
						Case 3 'InfoView
							ChangeInterface(2)
							MenuActive = False
							SettingFile.SaveSetting("Interface" , "2")
							SettingFile.SaveFile()							
						Case 4 'BannerView
							ChangeInterface(3)
							MenuActive = False
							SettingFile.SaveSetting("Interface" , "3")
							SettingFile.SaveFile()						
						Case 5 'ListView
							ChangeInterface(4)
							MenuActive = False
							SettingFile.SaveSetting("Interface" , "4")
							SettingFile.SaveFile()		
						Case 6
							ChangeInterface(5)
							MenuActive = False
							SettingFile.SaveSetting("Interface" , "5")
							SettingFile.SaveFile()																						
						Case 7
							ChangeInterface(6)
							MenuActive = False
							SettingFile.SaveSetting("Interface" , "6")
							SettingFile.SaveFile()							
					End Select										
			End Select		
			
			Return True 
		EndIf 
		If MenuActive = True Or FilterActive=True  Then
			Return True
		EndIf		
	End Method

	Method UpdateJoy()
		For J=0 To JoyCount()-1 
			Local Char:Int
			If MenuActive = True Then
				If ActiveMenuNumber = 1 Then 
					If ( Tol(JoyHat(J),0.25,0.1) Or Tol(JoyX(J),1,0.4) ) And MilliSecs() - KeyDelayTimer > 100 Then
						KeyDelayTimer = MilliSecs()
						Menu1.SelectedMenu = Menu1.SelectedMenu + 1
						If Menu1.SelectedMenu > Menu1.ColumnList.Count() - 1 Then
							Menu1.SelectedMenu = Menu1.ColumnList.Count() - 1
						EndIf
					EndIf
					If (Tol(JoyHat(J),0.75,0.1) Or Tol(JoyX(J),-1,0.4) ) And MilliSecs() - KeyDelayTimer > 100 Then
						KeyDelayTimer = MilliSecs()
						Menu1.SelectedMenu = Menu1.SelectedMenu - 1
						If Menu1.SelectedMenu < 0 then
							Menu1.SelectedMenu = 0
						EndIf
					EndIf		
					
					If (Tol(JoyHat(J),0,0.1) Or Tol(JoyY(J),-1,0.4) ) And MilliSecs() - KeyDelayTimer > 100 Then
						KeyDelayTimer = MilliSecs()
						Menu1.Columns[Menu1.SelectedMenu].SelectedItem = Menu1.Columns[Menu1.SelectedMenu].SelectedItem - 1
						If Menu1.Columns[Menu1.SelectedMenu].SelectedItem < 0 Then Menu1.Columns[Menu1.SelectedMenu].SelectedItem = 0
					EndIf	
					If (Tol(JoyHat(J),0.5,0.1) Or Tol(JoyY(J),1,0.4) ) And MilliSecs() - KeyDelayTimer > 100 Then
						KeyDelayTimer = MilliSecs()
						Menu1.Columns[Menu1.SelectedMenu].SelectedItem = Menu1.Columns[Menu1.SelectedMenu].SelectedItem + 1
						If Menu1.Columns[Menu1.SelectedMenu].SelectedItem > Menu1.Columns[Menu1.SelectedMenu].ItemNum - 1 Then
							Menu1.Columns[Menu1.SelectedMenu].SelectedItem = Menu1.Columns[Menu1.SelectedMenu].ItemNum - 1
						EndIf
					EndIf
					If JoyHit(JOY_ENTER , J)
						Select Menu1.SelectedMenu
							Case 1 'Exit
								Select Menu1.Columns[Menu1.SelectedMenu].SelectedItem
									Case 0 'Exit Menu
										MenuActive = False 
									Case 1 'Exit Program
										ExitProgramCall = True 
								End Select		
							Case 0 'Install Menu		
								InstallGame()	
							Case 4 'Play menu
								RunProcess(RUNNERPROGRAM+" -GameName " + Chr(34) + GameNode.OrginalName + Chr(34) + " -EXENum " + String(Menu1.Columns[Menu1.SelectedMenu].SelectedItem + 1)+" -Cabinate 1" , 1)
								ExitProgramCall = True
							
							Case 5 'Filters
								Select Menu1.Columns[Menu1.SelectedMenu].SelectedItem
									Case 0 'Select Filter
										ChangeInterface(0, True , False )
										MenuActive = False								
									Case 1 'Search Term
										MenuActive = False								
										FilterActive = True
								End Select
							Case 3 'Extras Menu
								Select Menu1.Columns[Menu1.SelectedMenu].SelectedItem
									Case 0 'Patches
										RunProcess(EXPLORERPROGRAM + " -Game " + Chr(34) + GameNode.OrginalName + Chr(34) + " -GameTab Patches", 1)		
										ExitProgramCall = True
									Case 1 'Walkthroughs
										RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab Walkthroughs",1)		
										ExitProgramCall = True						
									Case 2 'ScreenShots
										If GameNode.ScreenShotsAvailable = 1 then
											ChangeInterface(7, True, 0 )
											MenuActive = False	
										EndIf 
										'RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab ScreenShots",1)		
										'ExitProgramCall = True						
									Case 3 'Cheats
										RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab Cheats",1)		
										ExitProgramCall = True	
									Case 4 'Cheats
										RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab Manuals",1)		
										ExitProgramCall = True															
								End Select						
							Case 6 'Rating Menu
								GameNode.Rating = Int(Menu1.Columns[Menu1.SelectedMenu].SelectedItem) + 1
								GameNode.WriteUserData()
								MenuActive = False
							Case 7 'Completed Menu
								If Int(Menu1.Columns[Menu1.SelectedMenu].SelectedItem) = 0 Then 
									GameNode.Completed = 1
								Else
									GameNode.Completed = 0
								EndIf 
								GameNode.WriteUserData()
								MenuActive = False						
			
								
							Case 2 'Interface Menu
								Select Menu1.Columns[Menu1.SelectedMenu].SelectedItem
									Case 0
										ChangeInterface(1)
										MenuActive = False 	
										SettingFile.SaveSetting("Interface" , "1")
										SettingFile.SaveFile()	
									Case 1
										ChangeInterface(2)
										MenuActive = False
										SettingFile.SaveSetting("Interface" , "2")
										SettingFile.SaveFile()	
									Case 2
										ChangeInterface(3)
										MenuActive = False
										SettingFile.SaveSetting("Interface" , "3")
										SettingFile.SaveFile()									
									Case 3
										ChangeInterface(4)
										MenuActive = False
										SettingFile.SaveSetting("Interface" , "4")
										SettingFile.SaveFile()									
									Case 4
										ChangeInterface(5)
										MenuActive = False
										SettingFile.SaveSetting("Interface" , "5")
										SettingFile.SaveFile()	
									Case 5									
										ChangeInterface(6)
										MenuActive = False
										SettingFile.SaveSetting("Interface" , "6")
										SettingFile.SaveFile()									
								End Select		
								
							Case 8 'Edit Game
								RunProcess(MANAGERPROGRAM+" -EditGame "+Chr(34)+GameNode.OrginalName+Chr(34),1)
								ExitProgramCall = True 
						End Select
	
					EndIf 	
					If JoyHit(JOY_MENU,J) Or JoyHit(JOY_Cancel,J) Then
						MenuActive = False
					EndIf
					FlushJoy()	
					Return True 				
				EndIf
				Return True
			Else
				If FilterActive <> True Then 
					If JoyHit(JOY_PLATROTATE,J) Then
						GetNextPlatform()
					EndIf
					If JoyHit(JOY_MENU,J) Then
						MenuSelected = False
						ActiveMenuNumber = 1
						MenuActive = True
						BackAlpha = 0
						FlushJoy()
						Return True 		
					EndIf
				EndIf 
			EndIf
			If FilterActive = True Then
				If JoyHit(JOY_CANCEL, J) then
					Filter = ""
					FilterActive = False				
				EndIf 
				If JoyHit(JOY_FILTER,J) Then
					If GameArrayLen > 0 Then								
						FilterActive = False
						TouchJoySelected = - 1
					EndIf
					Return True 
				EndIf				
				If JoyHit(JOY_ENTER,J) Then
					If TouchJoySelected <> - 1 Then
						Local Key:String = KeyboardLayout[TouchJoySelected - 1]
						Select Key
							Case "Cancel"
								Filter = ""
								FilterActive = False	
								TouchJoySelected = - 1				
							Case "BkSp"
								Filter = Left(Filter,Len(Filter)-1)
							Case "Space"
								Filter = Filter + " "
								If Left(Filter , 1) = " " Then
									Filter = ""
								EndIf 
							Case "Go"
								If GameArrayLen > 0 Then								
									FilterActive = False
									TouchJoySelected = - 1
								EndIf
							Default
								Filter = Filter + Key
						End Select 
					Else
						If GameArrayLen > 0 Then 
							FilterActive = False
						EndIf
					EndIf
					Return True 
				EndIf		
				If TouchKeyboardEnabled = True
	
					If (Tol(JoyHat(J),0.75,0.1) Or Tol(JoyX(J),-1,0.4) ) And MilliSecs() - KeyDelayTimer > 100 Then
						KeyDelayTimer = MilliSecs()
						Select TouchJoySelected
							Case - 1
								TouchJoySelected = 1
							Case 1
								TouchJoySelected = 10
							Case 11
								TouchJoySelected = 20
							Case 21
								TouchJoySelected = 30
							Case 31
								TouchJoySelected = 40
							Default 
								TouchJoySelected = TouchJoySelected - 1
								'If TouchJoySelected < 1 Then TouchJoySelected = 1
						End Select 
						Return True 
					EndIf
					
					If (Tol(JoyHat(J),0.25,0.1) Or Tol(JoyX(J),1,0.4) ) And MilliSecs() - KeyDelayTimer > 100 Then
						KeyDelayTimer = MilliSecs()
						Select TouchJoySelected
							Case - 1
								TouchJoySelected = 1
							Case 10
								TouchJoySelected = 1
							Case 20
								TouchJoySelected = 11
							Case 30
								TouchJoySelected = 21
							Case 40
								TouchJoySelected = 31
							Default
								TouchJoySelected = TouchJoySelected + 1
						End Select 		
						Return True 
					EndIf
					
					If (Tol(JoyHat(J),0,0.1) Or Tol(JoyY(J),-1,0.4) ) And MilliSecs() - KeyDelayTimer > 100 Then
						KeyDelayTimer = MilliSecs()
						If TouchJoySelected < 1 Then
							TouchJoySelected = 1
						Else
							TouchJoySelected = TouchJoySelected - 10
							If TouchJoySelected < 1 Then TouchJoySelected = TouchJoySelected + 40
						EndIf
						Return True 
					EndIf
					
					If (Tol(JoyHat(J),0.5,0.1) Or Tol(JoyY(J),1,0.4) ) And MilliSecs() - KeyDelayTimer > 100 Then
						KeyDelayTimer = MilliSecs()
						If TouchJoySelected < 1 Then
							TouchJoySelected = 1
						Else
							TouchJoySelected = TouchJoySelected + 10
							If TouchJoySelected > 40 Then TouchJoySelected = TouchJoySelected - 40
						EndIf
						Return True 
					EndIf 
				EndIf 
				FlushJoy()				
				Return True
			Else
				If JoyHit(JOY_FILTER,J) Then
					FilterActive = True
					FlushKeys()
					Return True 
				EndIf
			EndIf	
		Next 	
	End Method

	Method UpdateKeyboard()
		Local Char:Int
		If MenuActive = True Then
			If ActiveMenuNumber = 1 Then 
				If KeyHit(KEYBOARD_ESC) then
					MenuActive = False
				EndIf
				If KeyHit(KEYBOARD_RIGHT) Then
					Menu1.SelectedMenu = Menu1.SelectedMenu + 1
					If Menu1.SelectedMenu > Menu1.ColumnList.Count() - 1 Then
						Menu1.SelectedMenu = Menu1.ColumnList.Count() - 1
					EndIf
				EndIf
				If KeyHit(KEYBOARD_LEFT) Then
					Menu1.SelectedMenu = Menu1.SelectedMenu - 1
					If Menu1.SelectedMenu < 0 Then
						Menu1.SelectedMenu = 0
					EndIf
				EndIf		
				
				If KeyHit(KEYBOARD_UP) Then
					Menu1.Columns[Menu1.SelectedMenu].SelectedItem = Menu1.Columns[Menu1.SelectedMenu].SelectedItem - 1
					If Menu1.Columns[Menu1.SelectedMenu].SelectedItem < 0 Then Menu1.Columns[Menu1.SelectedMenu].SelectedItem = 0
				EndIf	
				If KeyHit(KEYBOARD_DOWN) Then
					Menu1.Columns[Menu1.SelectedMenu].SelectedItem = Menu1.Columns[Menu1.SelectedMenu].SelectedItem + 1
					If Menu1.Columns[Menu1.SelectedMenu].SelectedItem > Menu1.Columns[Menu1.SelectedMenu].ItemNum - 1 Then
						Menu1.Columns[Menu1.SelectedMenu].SelectedItem = Menu1.Columns[Menu1.SelectedMenu].ItemNum - 1
					EndIf
				EndIf
				If KeyHit(KEYBOARD_ENTER)
					Select Menu1.SelectedMenu
						Case 1 'Exit
							Select Menu1.Columns[Menu1.SelectedMenu].SelectedItem
								Case 0 'Exit Menu
									MenuActive = False 
								Case 1 'Exit Program
									ExitProgramCall = True 
							End Select		
						Case 0 'Install Menu		
							InstallGame()	
						Case 4 'Play menu
							RunProcess(RUNNERPROGRAM+" -GameName " + Chr(34) + GameNode.OrginalName + Chr(34) + " -EXENum " + String(Menu1.Columns[Menu1.SelectedMenu].SelectedItem + 1)+" -Cabinate 1" , 1)
							ExitProgramCall = True
						
						Case 5 'Filters
							Select Menu1.Columns[Menu1.SelectedMenu].SelectedItem
								Case 0 'Select Filter
									ChangeInterface(0, True , False )
									MenuActive = False								
								Case 1 'Search Term
									MenuActive = False								
									FilterActive = True
							End Select 
						Case 3 'Extras Menu
							Select Menu1.Columns[Menu1.SelectedMenu].SelectedItem
								Case 0 'Patches
									RunProcess(EXPLORERPROGRAM + " -Game " + Chr(34) + GameNode.OrginalName + Chr(34) + " -GameTab Patches", 1)		
									ExitProgramCall = True
								Case 1 'Walkthroughs
									RunProcess(EXPLORERPROGRAM + " -Game " + Chr(34) + GameNode.OrginalName + Chr(34) + " -GameTab Walkthroughs", 1)		
									ExitProgramCall = True						
								Case 2 'ScreenShots								
									If GameNode.ScreenShotsAvailable = 1 then
										ChangeInterface(7, True, 0 )
										MenuActive = False	
									EndIf
									'RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab ScreenShots",1)		
									'ExitProgramCall = True						
								Case 3 'Cheats
									RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab Cheats",1)		
									ExitProgramCall = True	
								Case 4 'Cheats
									RunProcess(EXPLORERPROGRAM+" -Game "+Chr(34)+GameNode.OrginalName+Chr(34)+" -GameTab Manuals",1)		
									ExitProgramCall = True															
							End Select						
						Case 6 'Rating Menu
							GameNode.Rating = Int(Menu1.Columns[Menu1.SelectedMenu].SelectedItem) + 1
							GameNode.WriteUserData()
							MenuActive = False
						Case 7 'Completed Menu
							If Int(Menu1.Columns[Menu1.SelectedMenu].SelectedItem) = 0 Then 
								GameNode.Completed = 1
							Else
								GameNode.Completed = 0
							EndIf 
							GameNode.WriteUserData()
							MenuActive = False						
		
							
						Case 2 'Interface Menu
							Select Menu1.Columns[Menu1.SelectedMenu].SelectedItem
								Case 0
									ChangeInterface(1)
									MenuActive = False 	
									SettingFile.SaveSetting("Interface" , "1")
									SettingFile.SaveFile()	
								Case 1
									ChangeInterface(2)
									MenuActive = False
									SettingFile.SaveSetting("Interface" , "2")
									SettingFile.SaveFile()	
								Case 2
									ChangeInterface(3)
									MenuActive = False
									SettingFile.SaveSetting("Interface" , "3")
									SettingFile.SaveFile()									
								Case 3
									ChangeInterface(4)
									MenuActive = False
									SettingFile.SaveSetting("Interface" , "4")
									SettingFile.SaveFile()									
								Case 4
									ChangeInterface(5)
									MenuActive = False
									SettingFile.SaveSetting("Interface" , "5")
									SettingFile.SaveFile()	
								Case 5									
									ChangeInterface(6)
									MenuActive = False
									SettingFile.SaveSetting("Interface" , "6")
									SettingFile.SaveFile()									
							End Select		
							
						Case 8 'Edit Game
							RunProcess(MANAGERPROGRAM+" -EditGame "+Chr(34)+GameNode.OrginalName+Chr(34),1)
							ExitProgramCall = True 
					End Select

				EndIf 
								
				If KeyHit(KEYBOARD_MENU) Then
					MenuActive = False
				EndIf
				FlushKeys()	
				Return True 				
			EndIf
			If ActiveMenuNumber = 2 Then
				If KeyHit(KEYBOARD_ESC) Then
					MenuActive = False
					
				EndIf				
			EndIf 
			Return True
		Else
			If FilterActive <> True Then 
				If KeyHit(KEYBOARD_MENU) Then
					MenuSelected = False
					ActiveMenuNumber = 1
					MenuActive = True
					BackAlpha = 0
					FlushKeys()
					Return True 		
				EndIf
				If KeyHit(KEYBOARD_PLATROTATE) Then 
					GetNextPlatform()
				EndIf 
				
			EndIf 
		EndIf
		If FilterActive = True then
			If KeyHit(KEYBOARD_ESC) then
				If TouchJoySelected <> - 1 then
					TouchJoySelected = - 1
				Else
					Filter = ""
					FilterActive = False
				EndIf
				Return True 
			EndIf		
			If KeyHit(KEYBOARD_ENTER) then
				If TouchJoySelected <> - 1 Then
					Local Key:String = KeyboardLayout[TouchJoySelected - 1]
					Select Key
						Case "Cancel"
							Filter = ""
							FilterActive = False	
							TouchJoySelected = - 1				
						Case "BkSp"
							Filter = Left(Filter,Len(Filter)-1)
						Case "Space"
							Filter = Filter + " "
							If Left(Filter , 1) = " " Then
								Filter = ""
							EndIf 
						Case "Go"
							If GameArrayLen > 0 Then								
								FilterActive = False
								TouchJoySelected = - 1
							EndIf
						Default
							Filter = Filter + Key
					End Select 
				Else
					If GameArrayLen > 0 then
						FilterActive = False
					EndIf
				EndIf
				Return True 
			EndIf		
			If TouchKeyboardEnabled = True
				If KeyHit(KEYBOARD_LEFT) Then
					Select TouchJoySelected
						Case - 1
							TouchJoySelected = 1
						Case 1
							TouchJoySelected = 10
						Case 11
							TouchJoySelected = 20
						Case 21
							TouchJoySelected = 30
						Case 31
							TouchJoySelected = 40
						Default 
							TouchJoySelected = TouchJoySelected - 1
							'If TouchJoySelected < 1 Then TouchJoySelected = 1
					End Select 
					Return True 
				EndIf
				
				If KeyHit(KEYBOARD_RIGHT) Then
					Select TouchJoySelected
						Case - 1
							TouchJoySelected = 1
						Case 10
							TouchJoySelected = 1
						Case 20
							TouchJoySelected = 11
						Case 30
							TouchJoySelected = 21
						Case 40
							TouchJoySelected = 31
						Default
							TouchJoySelected = TouchJoySelected + 1
					End Select 		
					Return True 
				EndIf
				
				If KeyHit(KEYBOARD_UP) Then
					If TouchJoySelected < 1 Then
						TouchJoySelected = 1
					Else
						TouchJoySelected = TouchJoySelected - 10
						If TouchJoySelected < 1 Then TouchJoySelected = TouchJoySelected + 40
					EndIf
					Return True 
				EndIf
				
				If KeyHit(KEYBOARD_DOWN) Then
					If TouchJoySelected < 1 Then
						TouchJoySelected = 1
					Else
						TouchJoySelected = TouchJoySelected + 10
						If TouchJoySelected > 40 Then TouchJoySelected = TouchJoySelected - 40
					EndIf
					Return True 
				EndIf 
			EndIf 
			Repeat
				Char = GetChar()
				If Char = 0 Then Exit

				If (Char > 31 And Char < 126) Then
					Filter = Filter + Chr(Char)
				EndIf
				If Char = 127 Or Char = 8 Then
					Filter = Left(Filter , Len(Filter) - 1)
				EndIf
				If Left(Filter , 1) = " " Then
					Filter = ""
				EndIf 				
			Forever
			FlushKeys()				
			Return True
		Else
			If KeyHit(KEYBOARD_FILTER) Then
				FilterActive = True
				FlushKeys()
				Return True 
			EndIf
		EndIf		
	End Method
End Type

Type Menu2Type
	Field MainList:TList
	Field InterfaceList:TList
	Field ExtrasList:TList
	Field PlayGameList:TList
	
	Field ListWidthItems:Int 
	Field TouchButton:TImage 
	Field OldCurrentGamePos:Int = - 1
	
	Field SelectedItem:Int = - 1
	
	Field ActiveMenu:String = "Main"
	
	Field TouchButtonsML:TImage[]
	Field TouchButtonsI:TImage[]
	Field TouchButtonsE:TImage[]
	Field TouchButtonsPG:TImage[]
	
	Field tempInterfaceImage:TImage
	Field tempInterfaceBlankImage:TImage
	Field tempGameExtraBlankImage:TImage
	Field tempBackImage:TImage
	Field tempPlayImage:TImage
	Field tempPlayBlankImage:TImage
		
	Method Init()
		
		
		TouchPix:TPixmap = LoadPixmap(RESFOLDER + "TouchMenuButton.png")
		If TouchPix = Null Then RuntimeError "TouchMenuButton.png Missing!"			
		TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )
		TouchButton = LoadImage(TouchPix)				
		If TouchButton = Null Then RuntimeError "TouchMenuButton.png Missing!"			
		ListWidthItems = 3
		
		
		If FileType(RESFOLDER + "SubMenu"+FolderSlash+"MainList"+FolderSlash+"Back.png") Then 
			TouchPix = LoadPixmap(RESFOLDER + "SubMenu"+FolderSlash+"MainList"+FolderSlash+"Back.png")
			If TouchPix = Null Then RuntimeError "Back.png Missing!"	
			TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )	
			tempBackImage = LoadImage(TouchPix)				
			If tempBackImage = Null Then RuntimeError "Back.png Missing!"
		Else
			tempBackImage = TouchButton
		EndIf 		
		
		If FileType(RESFOLDER + "SubMenu" + FolderSlash + "MainList" + FolderSlash + "Game Extras Blank.png") then
			TouchPix = LoadPixmap(RESFOLDER + "SubMenu" + FolderSlash + "MainList" + FolderSlash + "Game Extras Blank.png")
			If TouchPix = Null then RuntimeError "Game Extras Blank.png Missing!"	
			TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )	
			tempGameExtraBlankImage = LoadImage(TouchPix)				
			If tempGameExtraBlankImage = Null then RuntimeError "Game Extras Blank.png Missing!"
		Else
			tempGameExtraBlankImage = TouchButton
		EndIf 		

		If FileType(RESFOLDER + "SubMenu" + FolderSlash + "MainList" + FolderSlash + "Interface.png") then
			TouchPix = LoadPixmap(RESFOLDER + "SubMenu"+FolderSlash+"MainList"+FolderSlash+"Interface.png")
			If TouchPix = Null Then RuntimeError "Interface.png Missing!"	
			TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )	
			tempInterfaceImage = LoadImage(TouchPix)				
			If tempInterfaceImage = Null Then RuntimeError "Interface.png Missing!"
		Else
			tempInterfaceImage = TouchButton
		EndIf
		
		If FileType(RESFOLDER + "SubMenu" + FolderSlash + "MainList" + FolderSlash + "Interface Blank.png") then
			TouchPix = LoadPixmap(RESFOLDER + "SubMenu" + FolderSlash + "MainList" + FolderSlash + "Interface Blank.png")
			If TouchPix = Null then RuntimeError "Interface Blank.png Missing!"	
			TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )	
			tempInterfaceBlankImage = LoadImage(TouchPix)				
			If tempInterfaceBlankImage = Null then RuntimeError "Interface Blank.png Missing!"
		Else
			tempInterfaceBlankImage = TouchButton
		EndIf 		
		
		If FileType(RESFOLDER + "SubMenu" + FolderSlash + "MainList" + FolderSlash + "Play Game.png") then
			TouchPix = LoadPixmap(RESFOLDER + "SubMenu"+FolderSlash+"MainList"+FolderSlash+"Play Game.png")
			If TouchPix = Null Then RuntimeError "Play Game.png Missing!"	
			TouchPix = ResizePixmap(TouchPix , GWidth * (Float(240) / 800) , GHeight * (Float(75) / 600) )	
			tempPlayImage = LoadImage(TouchPix)				
			If tempPlayImage = Null Then RuntimeError "Play Game.png Missing!"
		Else
			tempPlayImage = TouchButton
		EndIf 		
		
		If FileType(RESFOLDER + "SubMenu" + FolderSlash + "MainList" + FolderSlash + "Play Game Blank.png") then
			TouchPix = LoadPixmap(RESFOLDER + "SubMenu" + FolderSlash + "MainList" + FolderSlash + "Play Game Blank.png")
			If TouchPix = Null then RuntimeError "Play Game Blank.png Missing!"	
			TouchPix = ResizePixmap(TouchPix , GWidth * (Float(240) / 800) , GHeight * (Float(75) / 600) )	
			tempPlayBlankImage = LoadImage(TouchPix)				
			If tempPlayBlankImage = Null then RuntimeError "Play Game Blank.png Missing!"
		Else
			tempPlayBlankImage = TouchButton
		EndIf 			

		PopulateLists()
	End Method
	
	Method Update()
		SelectedItem = - 1
		Local col:Int
		Local row:Int
		
		If MouseX() > GWidth * (Float(20) / 800) And MouseX() < GWidth * (Float(260) / 800) Then
			Col = 1
		ElseIf MouseX() > GWidth * (Float(280) / 800) And MouseX() < GWidth * (Float(520) / 800) Then
			Col = 2
		ElseIf MouseX() > GWidth * (Float(540) / 800) And MouseX() < GWidth * (Float(780) / 800)
			Col = 3
		Else
			Col = - 1
		EndIf
		
		If MouseY() > GHeight * (Float(20) / 600) And MouseY() < GHeight * (Float(95) / 600) Then
			Row = 1
		ElseIf MouseY() > GHeight * (Float(110) / 600) And MouseY() < GHeight * (Float(185) / 600)
			Row = 2
		ElseIf MouseY() > GHeight * (Float(200) / 600) And MouseY() < GHeight * (Float(275) / 600)
			Row = 3
		Else
			Row = -1
		EndIf
		
		If Row <> -1 And Col <> -1 Then 
			SelectedItem = (Row - 1) * 3 + Col
			'PrintF("SElected")
		EndIf
		
	End Method 
	
	Method DrawMenu()
		Local List:TList
		Local TouchArray:TImage[]
		Select ActiveMenu
			Case "Main"
				List = MainList
				TouchArray = TouchButtonsML
			Case "Interface"
				List = InterfaceList
				TouchArray = TouchButtonsI
			Case "Extras"
				List = ExtrasList
				TouchArray = TouchButtonsE
			Case "PlayGame"
				List = PlayGameList
				TouchArray = TouchButtonsPG
		End Select 
		Local item:String 
		If OldCurrentGamePos <> CurrentGamePos Then
			PopulateGameList()
			OldCurrentGamePos = CurrentGamePos
		EndIf
		SetImageFont(MenuButtonFont2)

		SetAlpha(0.7)
		
		Local a:Int = 0
		Local b:Int = 0
		For item = EachIn List
			SetColor(179 , 179 , 179)
			If b*3+a+1 = SelectedItem Then 
				'SetAlpha(0.3)
				SetAlpha(1)
			Else
				SetAlpha(0.7)			
			EndIf
			If item = "ScreenShots" then
				If GameNode.ScreenShotsAvailable = 0 then
					item = "No ScreenShots"
				Else
					item = "ScreenShots"
				EndIf
			EndIf

			DrawImage(TouchArray[b * 3 + a] , a * GWidth * (Float(260) / 800) + GWidth * (Float(20) / 800) , b * GHeight * (Float(90) / 600) + GHeight * (Float(20) / 600) )
			SetAlpha(1)		
			If (ActiveMenu = "PlayGame" Or ActiveMenu = "Interface" Or ActiveMenu = "Extras") And (a > 0 Or b > 0) then
				If TouchArray[b * 3 + a] = tempInterfaceBlankImage Or TouchArray[b * 3 + a] = tempGameExtraBlankImage Or TouchArray[b * 3 + a] = tempPlayBlankImage then
					DrawText(item , a * GWidth * (Float(260) / 800) + GWidth * (Float(110) / 800) , b * GHeight * (Float(90) / 600) + GHeight * (Float(57.5) / 600) - TextHeight(item) / 2 )
					
				EndIf
			EndIf
			
			a = a + 1
			If a > 2 Then
				b = b + 1
				a = 0
			EndIf 
		Next 
		
	End Method 
	
	Method PopulateLists()
		Local item:String
		Local a:Int = 0
		Local TouchPix:TPixmap
		MainList = CreateList()
		InterfaceList = CreateList()
		ExtrasList = CreateList()

		
		
		ListAddLast(MainList , "Play Game")
		ListAddLast(MainList , "Filter Games")
		ListAddLast(MainList , "Game Extras")
				
		ListAddLast(MainList , "Install From CD")
		ListAddLast(MainList , "Interface")
		ListAddLast(MainList , "Edit Game")
		
		ListAddLast(MainList , "Exit Menu")		
		ListAddLast(MainList , "Exit Program")
		
		TouchButtonsML = TouchButtonsML[..MainList.Count()]
		For item = EachIn MainList
			If FileType(RESFOLDER + "SubMenu"+FolderSlash+"MainList"+FolderSlash + item + ".png") = 1 Then
				TouchPix = LoadPixmap(RESFOLDER + "SubMenu"+FolderSlash+"MainList"+FolderSlash + item + ".png")
				If TouchPix = Null Then RuntimeError item+".png Missing!"			
				TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )
				TouchButtonsML[a] = LoadImage(TouchPix)				
				If TouchButtonsML[a] = Null Then RuntimeError item+".png Missing!"							
			Else
				TouchButtonsML[a] = TouchButton
			EndIf
			a = a + 1
		Next 
		
		
		'DebugStop
		
		ListAddLast(InterfaceList , "..")
		ListAddLast(InterfaceList , "CoverFlow")
		ListAddLast(InterfaceList , "InfoView #1")
		ListAddLast(InterfaceList , "InfoView #2")
		ListAddLast(InterfaceList , "ListView")
		ListAddLast(InterfaceList , "BannerFlow")
		ListAddLast(InterfaceList , "CoverWall")		
		
		
		TouchButtonsI = TouchButtonsI[..InterfaceList.Count()]
		
		a = 0
		For item = EachIn InterfaceList
			If item = ".." Then 
				TouchButtonsI[a] = tempBackImage
			Else
				If FileType(RESFOLDER + "SubMenu" + FolderSlash + "InterfacesList" + FolderSlash + item + ".png") = 1 then
					TouchPix = LoadPixmap(RESFOLDER + "SubMenu" + FolderSlash + "InterfacesList" + FolderSlash + item + ".png")
					If TouchPix = Null then RuntimeError item + ".png Missing!"			
					TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )
					TouchButtonsI[a] = LoadImage(TouchPix)				
					If TouchButtonsI[a] = Null then RuntimeError item + ".png Missing!"							
				Else
					TouchButtonsI[a] = tempInterfaceBlankImage
				EndIf
			EndIf 
			a = a + 1
		Next 		
		
		ListAddLast(ExtrasList , "..")
		ListAddLast(ExtrasList , "Patches")
		ListAddLast(ExtrasList , "Walkthroughs")
		ListAddLast(ExtrasList , "ScreenShots")
		ListAddLast(ExtrasList , "Cheats")	
		ListAddLast(ExtrasList , "Manuals")
		
		a = 0
		TouchButtonsE = TouchButtonsE[..ExtrasList.Count()]
		For item = EachIn ExtrasList
			If item = ".." then
				TouchButtonsE[a] = tempBackImage
			Else
				If FileType(RESFOLDER + "SubMenu" + FolderSlash + "GameExtrasList" + FolderSlash + item + ".png") = 1 then
					TouchPix = LoadPixmap(RESFOLDER + "SubMenu" + FolderSlash + "GameExtrasList" + FolderSlash + item + ".png")
					If TouchPix = Null Then RuntimeError item+".png Missing!"			
					TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )
					TouchButtonsE[a] = LoadImage(TouchPix)				
					If TouchButtonsE[a] = Null then RuntimeError item + ".png Missing!"							
				Else
					TouchButtonsE[a] = tempGameExtraBlankImage
				EndIf
			EndIf
			a = a + 1
		Next 									
	End Method
	
	Method PopulateGameList()
		Local a:Int = 0
		Local item:String 
		PlayGameList = CreateList()
		ListAddLast(PlayGameList , "..")
		ListAddLast(PlayGameList , "Play Game")
		Local EXEName:String 
		For EXEName = EachIn GameNode.OEXEsName
			ListAddLast(PlayGameList , EXEName)
		Next
		
		TouchButtonsPG = TouchButtonsPG[..PlayGameList.Count()]
		
		If FileType(RESFOLDER + "SubMenu"+FolderSlash+"MainList"+FolderSlash+"Play Game.png") Then 
			TouchPix = LoadPixmap(RESFOLDER + "SubMenu"+FolderSlash+"MainList"+FolderSlash+"Play Game.png")
			If TouchPix = Null Then RuntimeError "Play Game.png Missing!"	
			TouchPix = ResizePixmap(TouchPix , GWidth*(Float(240)/800) , GHeight*(Float(75)/600) )	
			tempImage = LoadImage(TouchPix)				
			If tempImage = Null Then RuntimeError "Play Game.png Missing!"
		Else
			tempImage = TouchButton
		EndIf 

		
		For item = EachIn PlayGameList
			If item = ".." Then 
				TouchButtonsPG[a] = tempBackImage
			Else
				TouchButtonsPG[a] = tempPlayBlankImage
			EndIf 
			a = a + 1
		Next 			
	End Method 
End Type 

Type Menu1Type
	Field ColumnList:TList = CreateList()
	Field RunColumn:Menu1ColumnType
	Field RatingColumn:Menu1ColumnType
	Field CompleteColumn:Menu1ColumnType

	Field Columns:Menu1ColumnType[]
	Field SelectedMenu:Int
	Field WidthCalculated:Int
	
	Field Scaled40Wid:Int 
	
	Method Init()
		Scaled40Wid = ((Float(40)/800)*GWidth)
		WidthCalculated = 0

		Column1:Menu1ColumnType = New Menu1ColumnType
		ListAddLast(Column1.ItemList , "Install From CD")
		'ListAddLast(Column1.ItemList , "Install From HD")
		ListAddLast(ColumnList , Column1)
		Column1.SelectedItem = 0
		Column1.MenuName = "Install"
		Column1.ItemNum = 1

		Column0:Menu1ColumnType = New Menu1ColumnType
		ListAddLast(Column0.ItemList , "Exit Menu")
		ListAddLast(Column0.ItemList , "Exit Program")
		ListAddLast(ColumnList , Column0)
		Column0.SelectedItem = 0
		Column0.MenuName = "Exit"
		Column0.ItemNum = 2

		Column4:Menu1ColumnType = New Menu1ColumnType
		ListAddLast(Column4.ItemList , "CoverFlow")
		ListAddLast(Column4.ItemList , "InfoView #1(Covers)")
		ListAddLast(Column4.ItemList , "InfoView #2(Banners)")
		ListAddLast(Column4.ItemList , "ListView")
		ListAddLast(Column4.ItemList , "BannerFlow")
		ListAddLast(Column4.ItemList , "CoverWall")
		ListAddLast(ColumnList , Column4)
		If SettingFile.GetSetting("Interface") = "" Then
			Column4.SelectedItem = 0
		Else
			Column4.SelectedItem = Int(SettingFile.GetSetting("Interface") ) - 1
		EndIf 
		Column4.MenuName = "Interface"
		Column4.ItemNum = Column4.ItemList.Count()

		Column3:Menu1ColumnType = New Menu1ColumnType
		ListAddLast(Column3.ItemList , "Patches")
		ListAddLast(Column3.ItemList , "Walkthroughs")
		If GameNode.ScreenShotsAvailable = 1 then
			ListAddLast(Column3.ItemList , "ScreenShots")
		Else
			ListAddLast(Column3.ItemList , "No ScreenShots")
		EndIf
		ListAddLast(Column3.ItemList , "Cheats")
		ListAddLast(Column3.ItemList , "Manuals")
		ListAddLast(ColumnList , Column3)
		Column3.SelectedItem = 0
		Column3.MenuName = "Game Extras"
		Column3.ItemNum = Column3.ItemList.Count()
		
		Column2:Menu1ColumnType = New Menu1ColumnType
		ListAddLast(Column2.ItemList , "Play Game")
		ListAddLast(ColumnList , Column2)
		Column2.SelectedItem = 0
		Column2.MenuName = "Play"
		Column2.ItemNum = 1
		
		RunColumn = Column2
		
		Column9:Menu1ColumnType = New Menu1ColumnType	
		ListAddLast(Column9.ItemList , "Filters Menu")	
		ListAddLast(Column9.ItemList , "Search Term")	
		ListAddLast(ColumnList , Column9)
		Column9.SelectedItem = 0
		Column9.MenuName = "Filter"
		Column9.ItemNum = 2			
		
	
		
		Column6:Menu1ColumnType = New Menu1ColumnType
		ListAddLast(Column6.ItemList , "1")
		ListAddLast(Column6.ItemList , "2")
		ListAddLast(Column6.ItemList , "3")
		ListAddLast(Column6.ItemList , "4")
		ListAddLast(Column6.ItemList , "5")
		ListAddLast(Column6.ItemList , "6")
		ListAddLast(Column6.ItemList , "7")
		ListAddLast(Column6.ItemList , "8")
		ListAddLast(Column6.ItemList , "9")
		ListAddLast(Column6.ItemList , "10")
		ListAddLast(ColumnList , Column6)
		Column6.SelectedItem = 0
		Column6.MenuName = "Game Rating"
		Column6.ItemNum = 10	
		
		RatingColumn = Column6	
		
		Column7:Menu1ColumnType = New Menu1ColumnType
		ListAddLast(Column7.ItemList , "Yes")
		ListAddLast(Column7.ItemList , "No")
		ListAddLast(ColumnList , Column7)
		Column7.SelectedItem = 0
		Column7.MenuName = "Completed"
		Column7.ItemNum = 2
		
		CompleteColumn = Column7		
		

		Column5:Menu1ColumnType = New Menu1ColumnType		
		ListAddLast(Column5.ItemList , "In PhotonManager")
		ListAddLast(ColumnList , Column5)
		Column5.SelectedItem = 0
		Column5.MenuName = "Edit Game"
		Column5.ItemNum = 1		
		
		SelectedMenu = 4
		
		Columns = Menu1ColumnType[](ListToArray(ColumnList) )
	End Method
	
	Method UpdateRunColumn()
		RunColumn.ItemList.Clear()
		Local a:Int = 1
		ListAddLast(RunColumn.ItemList , "Play Game")
		Local Name:String
		For Name = EachIn GameNode.OEXEsName
			ListAddLast(RunColumn.ItemList , Name)
			a = a + 1
		Next
		If RunColumn.SelectedItem > a - 1 Then
			RunColumn.SelectedItem = a - 1
		EndIf
		RunColumn.ItemNum = a
		
	End Method
	
	Method UpdateRatingColumn()
		If Int(GameNode.Rating) - 1 = -1 Then
			RatingColumn.SelectedItem = 0
		Else
			RatingColumn.SelectedItem = Int(GameNode.Rating) - 1
		EndIf 
	End Method
	
	Method UpdateCompleteColumn()
		If GameNode.Completed = 1 Then
			CompleteColumn.SelectedItem = 0
		Else
			CompleteColumn.SelectedItem = 1
		EndIf 
	End Method
	
	Method DrawMenu(x , y)
		Local Column:Menu1ColumnType
		Local Ex:Int
		'Local a
		If WidthCalculated = 0 Then
			SetImageFont(BigMenuFont)
			For Column = EachIn ColumnList
				Column.GetWidth()
			Next
		EndIf
		
		Columns[SelectedMenu].DrawColumn(x , y , True)
		Ex = Columns[SelectedMenu].MenuWidth/2
		
		For a = SelectedMenu+1 To Len(Columns) - 1
			Ex = Ex + Columns[a].MenuWidth/2
			Columns[a].DrawColumn(x + Ex + (a-SelectedMenu)*Scaled40Wid , y)
			Ex = Ex + Columns[a].MenuWidth/2
		Next
		
		Ex = -Columns[SelectedMenu].MenuWidth/2
		For a = SelectedMenu - 1 To 0 Step - 1
			Ex = Ex - Columns[a].MenuWidth/2
			Columns[a].DrawColumn(x + Ex + (a - SelectedMenu) *Scaled40Wid , y)
			Ex = Ex - Columns[a].MenuWidth/2
		Next		
	End Method 
	
	
End Type


Type Menu1ColumnType
	Field ItemList:TList = CreateList()
	Field SelectedItem:Int 
	Field MenuWidth:Int = - 1
	Field ItemNum:Int
	Field MenuName:String
	
	Field SelectedAlpha:Float = 1
	Field AlphaDir:Int = 1	
	
	Method GetWidth()
		Local item:String
		SetImageFont(BigMenuFont)
		If TextWidth(MenuName) > Self.MenuWidth Then
			Self.MenuWidth = TextWidth(MenuName)
		EndIf		
		SetImageFont(MenuFont)	
		For item = EachIn ItemList
			If TextWidth(item) > Self.MenuWidth Then
				Self.MenuWidth = TextWidth(item)
			EndIf
		Next
	End Method
	
	Method DrawColumn(x , y , SelectedMenu:Int  = False )
		Local item:String
		Local a:Int = 0
		
		If AlphaDir = 1 Then
			SelectedAlpha = SelectedAlpha - 0.01
			If SelectedAlpha < 0.3 Then AlphaDir = -1
		ElseIf AlphaDir = -1
			SelectedAlpha = SelectedAlpha + 0.01
			If SelectedAlpha > 0.9 Then AlphaDir = 1		
		EndIf 
		
		If SelectedMenu = True Then
			SetColor 255 , 255 , 255
			SetImageFont(BigMenuFont)
			DrawText(MenuName , x - TextWidth(MenuName) / 2 , y - TextHeight(MenuName) / 2 )	
			SetImageFont(MenuFont)	
			For item = EachIn ItemList
				SetColor 150, 150 , 150
				If (a - SelectedItem) = 0 Then
					SetColor 135 , 153 , 255
					SetAlpha(SelectedAlpha)
					DrawText(item , x - TextWidth(item) / 2 , y + TextHeight(item) / 2 + 20 )
					SetAlpha(1)
				ElseIf (a - SelectedItem) > 0
					DrawText(item , x - TextWidth(item) / 2 , y + TextHeight(item) / 2 + (a - SelectedItem) * (TextHeight(item) + 20) + 20)
				ElseIf (a - SelectedItem) < 0
					DrawText(item , x - TextWidth(item) / 2 , y + TextHeight(item) / 2 + (a - SelectedItem ) * (TextHeight(item) + 20) - 20 )
				EndIf
				a = a + 1
			Next
		Else
			SetColor 150 , 150 ,150
			SetImageFont(BigMenuFont)
			DrawText(MenuName , x - TextWidth(MenuName) / 2 , y - TextHeight(MenuName) / 2 )
			SetImageFont(MenuFont)							
		EndIf 
	End Method 
End Type 





Function InstallGame()
	Local Line:String
	Local Execute:String 
	For a = 67 To 90
		If FileType(Chr(a) + ":\autorun.cfg") = 1 Or FileType(Chr(a) + ":\autorun.inf") = 1 Then
			PrintF("Running CD from drive: "+Chr(a))
			If FileType(Chr(a) + ":\autorun.cfg") = 1 Then
				ReadAutorun = ReadFile(Chr(a) + ":\autorun.cfg")
			Else
				ReadAutorun = ReadFile(Chr(a) + ":\autorun.inf")			
			EndIf
			Repeat			
				Line = ReadLine(ReadAutorun)
				If Left(Lower(Line),Len("open"))="open" Then 
					Execute = Right(Line,Len(Line)-Len("open")-1)
					PrintF("Executing: "+Chr(a) + ":\"+Execute)
					RunProcess(Chr(a) + ":\"+Execute,1)
					End 
				EndIf 
				If Left(Lower(Line),Len("shellexecute"))="shellexecute" Then 
					Execute = Right(Line,Len(Line)-Len("shellexecute")-1)
					PrintF("Opening: "+Chr(a) + ":\"+Execute)
					OpenURL(Chr(a) + ":\"+Execute)
					End
				EndIf 
			
				If Eof(ReadAutorun) Then Exit 
			Forever
			CloseFile(ReadAutorun)
			Exit
		EndIf 
	Next 
	PrintF("No Install Disk Found")
End Function 



Function GetNextPlatform()

	'This function gets all the platforms and gets the next one on from our current platform. It then filters the games by that new platform category
	Local Selected:String = ""
	Local SelectNext = 0
	Local FirstPlatform:String = ""
	For a:String = EachIn UsedPlatformList
		PrintF("List-" + a)
		If FirstPlatform = "" then
			FirstPlatform = a
		EndIf 
		If SelectNext = 1 Then
			Selected = a
			SelectNext = 0
			Exit
		EndIf
		If a = GamesPlatformFilter Then
			SelectNext = 1
		EndIf 
	Next
	ChangeInterface(0, True , False ) 'Resets filters & Changes to menu interface temperourily
	If SelectNext = 1 then
		PrintF("SelectNext - All Games")
		FilterType = "All Games"
		FilterName = ""
		GamesPlatformFilter = 0
	Else
		If Selected="" Then 
			If FirstPlatform = Null Then
				PrintF("Selected - All Games")
				FilterType = "All Games"
				FilterName = ""		
				GamesPlatformFilter = 0	
			Else
				PrintF(FirstPlatform)
				FilterType = "Platform"
				FilterName = GlobalPlatforms.GetPlatformByID(Int(FirstPlatform) ).Name
				GamesPlatformFilter = Int(FirstPlatform)
			EndIf 
		Else
			PrintF(Selected)
			FilterType = "Platform"
			FilterName = GlobalPlatforms.GetPlatformByID(Int(Selected)).Name
			GamesPlatformFilter = Int(Selected)
		EndIf 	
	EndIf
	
	PopulateGames()
	ChangeInterface(CurrentInterfaceNumber, True , False )
End Function





