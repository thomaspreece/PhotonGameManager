Type ScreenShotInterface Extends GeneralType
	'Field ScreenShotWall:ScreenShotType
	Field KeyDelayTimer:Int
	Field ScreenShots:String[]
	Field ScreenShotNumber:Int 
	Field Screens:ScreenType[]
	Field CurrentScreenShot:Int 
	Field OldCurrentScreenShot:Int 
	Field itemsPerRow:Int 
	Field Parent:TPivot 
	Field BigCover:Int = 0
	Field Screen:ScreenShotButtonType
	
	Method Init()
		
		Screen:ScreenShotButtonType = New ScreenShotButtonType
		If WideScreen = 1 Then
			Screen.DrawX = GWidth * (Float(30) / 800)
		Else
			Screen.DrawX = GWidth * (Float(20) / 800)
		EndIf 
		Screen.DrawY = GHeight * (Float(560) / 600) - GWidth * (Float(15) / 800)
		Screen.Mode = 1
		Screen.Init()
		
		Local File:String
		Local ScreenShotList:TList = CreateList()
		Local LocalTextureStack:TList = CreateList()
		
		Local ReadScreenShotFolder = ReadDir(GAMEDATAFOLDER+GameArray[CurrentGamePos]+FolderSlash+"ScreenShots")
		Repeat
			File = NextFile(ReadScreenShotFolder)
			If File=".." Then Continue
			If File="." Then Continue
			If FileType(GAMEDATAFOLDER+GameArray[CurrentGamePos]+FolderSlash+"ScreenShots"+FolderSlash+File)=2 Then Continue 
			If File="" Then Exit
			If ExtractExt(File)="jpg" Then
				ListAddLast(ScreenShotList,"ScreenShots"+FolderSlash+File)
			EndIf 
		Forever
		CloseDir(ReadScreenShotFolder)
		
		If CountList(ScreenShotList)=0 Then 
			If FileType(GAMEDATAFOLDER+GameArray[CurrentGamePos]+FolderSlash+"Shot1_OPT.jpg")=1 Then
				ListAddLast(ScreenShotList,"Shot1_OPT.jpg")
			EndIf 
			If FileType(GAMEDATAFOLDER+GameArray[CurrentGamePos]+FolderSlash+"Shot2_OPT.jpg")=1 Then
				ListAddLast(ScreenShotList,"Shot2_OPT.jpg")
			EndIf 			
		EndIf 
		
		If CountList(ScreenShotList)<>0 Then
			ScreenShotNumber = CountList(ScreenShotList)
			ScreenShots = New String[ScreenShotNumber]
			For a = 0 To ScreenShotNumber - 1
				ScreenShots[a] = String(ScreenShotList.RemoveFirst())
				ListAddLast(LocalTextureStack,GAMEDATAFOLDER+GameArray[CurrentGamePos]+FolderSlash+ScreenShots[a])
			Next
		Else
			ScreenShotNumber = 0
		EndIf
		
		CurrentScreenShot = 0
		OldCurrentScreenShot = 0
		
		LockMutex(Mutex_ProcessStack)
		ProcessStack = LocalTextureStack
		UnlockMutex(Mutex_ProcessStack)	
		
		itemsPerRow = Max(Ceil(Float(ScreenShotNumber) / 5) , 5)
		
		Parent = CreatePivot()
		PositionEntity Parent , 0 , 0 , 2
		
		Screens = New ScreenType[ScreenShotNumber]
		
		For a = 0 To ScreenShotNumber - 1
			Screens[a] = New ScreenType
			Screens[a].Position = a
			Screens[a].TexturePath = ScreenShots[a]
			Screens[a].Init(Parent)
			Screens[a].x = Pos(a , 1 , Screens[a].NormY)
			Screens[a].y = Pos(a , 2 , Screens[a].NormY)
			Screens[a].z = Pos(a , 3 , Screens[a].NormY)
			Screens[a].Rotx = 0
			Screens[a].Roty = 0
			Screens[a].Rotz = 0
			PositionEntity(Screens[a].Mesh , Screens[a].x , Screens[a].y , Screens[a].z , Screens[a].GlobalPosition)
		Next
		
		ListAddLast(UpdateTypeList , Self)	
		
	End Method	

	Method LoadBigCover()
		Rem
		Local BTex:TTexture		
		If BigCover = 0 Then
		
			For a = 0 To ScreenShotNumber - 1
				Screens[a].GlobalPosition = True
				'Screens[a].y = Screens[a].NormY
	
				If WideScreen = 1 Then
					Screens[a].z = - 2
				Else
					Screens[a].z = - 2.3
				EndIf
			
			Next
			
			BigCover = 1	
			'Rem	
			If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+Screens[CurrentScreenShot].TexturePath) = 1 Then
				BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash +"Front_OPT_2X.jpg")
				LockMutex(TTexture.Mutex_tex_list)
				ListAddLast(InUseTextures , BTex.file)
				UnlockMutex(TTexture.Mutex_tex_list)
				EntityTexture(Covers[CurrentGamePos].Mesh , BTex)
			EndIf				
			'EndRem
		Else
			For a = 0 To ScreenShotNumber - 1
				Screens[a].z = Pos(Screens[a].Position , 3 , Screens[a].NormY)
				'Screens[a].y = Pos(Screens[a].Position , 2 , Screens[a].NormY)
				Screens[a].GlobalPosition = False 
			Next	
			BigCover = 0
		EndIf	
		EndRem 
		If BigCover = 0 Then
			BigCover = 1
		Else
			BigCover = 0
		EndIf 
		OldCurrentScreenShot = -1
	End Method



	Method Max2D()
		Screen.Max2D()
	End Method 
	
	Method Update()
		Screen.Update()
		For a = 0 To ScreenShotNumber - 1
			Screens[a].Update()
			If Screens[a].ResetCoverPosition = True Then
				Screens[a].y = Pos(a , 2 , Screens[a].NormY)
				PositionEntity(Screens[a].Mesh , EntityX(Screens[a].Mesh) , Screens[a].y , EntityZ(Screens[a].Mesh) )	
				Screens[a].ResetCoverPosition = False 			
			EndIf 
		Next	
		If OldCurrentScreenShot <> CurrentScreenShot Then
			For a = 0 To ScreenShotNumber - 1
				Screens[a].x = Pos(a , 1 , Screens[a].NormY)
				Screens[a].y = Pos(a , 2 , Screens[a].NormY)
				Screens[a].z = Pos(a , 3 , Screens[a].NormY)				
			Next 
			If LowProcessor = True Then
				PositionEntity(Screens[a].Mesh , Screens[a].x , Screens[a].y , Screens[a].z , Screens[a].GlobalPosition)
			EndIf 
			OldCurrentScreenShot = CurrentScreenShot
		EndIf 
	End Method
	
	Method Clear()
		For a = 0 To ScreenShotNumber - 1		
			Screens[a].Clear()
			Screens[a] = Null 
		Next
		FreeEntity(Parent)
		
		'ScreenShotWall.Clear()
		'ScreenShotWall = Null
		Screen.Clear()
		Screen = Null 
		ListRemove(UpdateTypeList , Self)
	End Method 
	
	Method UpdateMouse()
		If Screen.UpdateMouse() = True Then Return True
		'MouseSwipe 1: Swipe left/right
		'MouseSwipe 2: Hold Down mouse browse
		'MouseSwipe 3: Hold state for '2' allowing swipemode interface to be drawn
		'MouseSwipe 4: Swipe up/down
		Local DoNotStopSwipe:Int = False
		Local a:Int = 0
		Local b:Object
		Local SelectedCover:Int = - 1
		Local ClickCoverList:TList = CreateList()
		If MouseClick = 1 Then
			MouseClick = 0
			For a = 0 To ScreenShotNumber - 1
				If Screens[a].MouseOver() = True
					ListAddLast(ClickCoverList , String(a) )
				EndIf
			Next	
			If ClickCoverList.Count() > 0 Then
				If ListContains(ClickCoverList , String(CurrentScreenShot) ) Then
					LoadBigCover()
				Else
					For b = EachIn ClickCoverList
						a = Int(String(b))
						If a > CurrentScreenShot Then
							If a < SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf
						ElseIf a < CurrentScreenShot Then
							If a > SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf						
						EndIf
					Next
					CurrentScreenShot = SelectedCover
				EndIf	
			EndIf
			Return True 
		EndIf
		If MouseClick = 2 Then
			MouseClick = 0
			Return True 
		EndIf		
		If MouseSwipe = 1 Then
			MouseSwipe = 0
			PrintF("You swiped mouse, X:" + String(MouseEnd[0] - MouseStart[0]) + " T:" + MouseSwipeTime)
			If CurrentScreenShot = ScreenShotNumber - 1 Or CurrentScreenShot = 0 Then DoNotStopSwipe = True 
			CurrentScreenShot = CurrentScreenShot + Int( ( ( (Float(MouseEnd[0] - MouseStart[0]) * 10) / GWidth) * 1000	) / MouseSwipeTime)
			If DoNotStopSwipe = False Then
				If CurrentScreenShot > ScreenShotNumber - 1 Then CurrentScreenShot = ScreenShotNumber - 1
				If CurrentScreenShot < 0 Then CurrentScreenShot = 0
			Else
				If CurrentScreenShot > ScreenShotNumber - 1 Then CurrentScreenShot = 0
				If CurrentScreenShot < 0 Then CurrentScreenShot = ScreenShotNumber - 1
			EndIf
			Return True 
		ElseIf MouseSwipe = 2 Then
			MouseSwipe = 3
			CurrentScreenShot = CurrentScreenShot + Int((Float(MouseX()-(GWidth/2))/ GWidth) * 6)
			
			If CurrentScreenShot > ScreenShotNumber - 1 Then CurrentScreenShot = ScreenShotNumber - 1
			If CurrentScreenShot < 0 Then CurrentScreenShot = 0		
			Return True
		ElseIf MouseSwipe = 4 Then
			MouseSwipe = 0
			If MouseEnd[1] - MouseStart[1] > 0 Then
				LoadBigCover()		
			ElseIf MouseEnd[1] - MouseStart[1] < 0
				
			EndIf
			Return True
		EndIf
		Return False
	End Method
		
	Method UpdateJoy()
		If Screen.UpdateJoy() = True Then Return True
		For J=0 To JoyCount()-1 
			If JoyHit(JOY_CANCEL,J) Then 
				ChangeInterface(CurrentInterfaceNumber,1,0)
				Return True
			EndIf 
			
			If JoyHit(JOY_BIGCOVER,J) Then
				LoadBigCover()
				Return True 
			EndIf
			
			If Tol(JoyY(J),0,0.2) <> 1 Then 
				If JoyY(J) > 0 Then 
					If MilliSecs() - KeyDelayTimer > 100/(JoyY(J)*1.5)
						If CurrentScreenShot + itemsPerRow > ScreenShotNumber - 1 Then
					
						Else
							CurrentScreenShot = CurrentScreenShot + itemsPerRow
						EndIf 
						KeyDelayTimer = MilliSecs()	
					EndIf
					Return True 
				Else
					If MilliSecs() - KeyDelayTimer > 100/(-JoyY(J)*1.5)
						If CurrentScreenShot - itemsPerRow < 0 Then
					
						Else
							CurrentScreenShot = CurrentScreenShot - itemsPerRow
						EndIf  
						KeyDelayTimer = MilliSecs()	
					EndIf 
					Return True 			
				EndIf 
			EndIf 
			
			If Tol(JoyX(J),0,0.2) <> 1 Then 
				If JoyX(J) > 0 Then 
					If MilliSecs() - KeyDelayTimer > 100/(JoyX(J)*1.5)
						CurrentScreenShot = CurrentScreenShot + 1
						KeyDelayTimer = MilliSecs()
						If CurrentScreenShot > ScreenShotNumber - 1 Then CurrentScreenShot = ScreenShotNumber - 1 'CurrentGamePos - GameArrayLen
					EndIf
					Return True 
				Else
					If MilliSecs() - KeyDelayTimer > 100/(-JoyX(J)*1.5)
						CurrentScreenShot = CurrentScreenShot - 1
						KeyDelayTimer = MilliSecs()		
						If CurrentScreenShot < 0 Then CurrentScreenShot = 0
					EndIf
					Return True 			
				EndIf 
			EndIf 			
		
			If Tol(JoyHat(J),0.5,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100
					If CurrentScreenShot + itemsPerRow > ScreenShotNumber - 1 Then
					
					Else
						CurrentScreenShot = CurrentScreenShot + itemsPerRow
					EndIf 
					KeyDelayTimer = MilliSecs()	
				EndIf
				Return True			
			EndIf 
			If Tol(JoyHat(J),0,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100
					If CurrentScreenShot - itemsPerRow < 0 Then
					
					Else
						CurrentScreenShot = CurrentScreenShot - itemsPerRow
					EndIf 
					KeyDelayTimer = MilliSecs()	
				EndIf 
				Return True 		
			EndIf 		
			If Tol(JoyHat(J),0.25,0.1) Then 	
				If MilliSecs() - KeyDelayTimer > 100 
					CurrentScreenShot = CurrentScreenShot + 1
					KeyDelayTimer = MilliSecs()
					If CurrentScreenShot > ScreenShotNumber - 1 Then CurrentScreenShot = ScreenShotNumber - 1 'CurrentGamePos - GameArrayLen
				EndIf
				Return True 			
			EndIf 
			If Tol(JoyHat(J),0.75,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100 
					CurrentScreenShot = CurrentScreenShot - 1
					KeyDelayTimer = MilliSecs()		
					If CurrentScreenShot < 0 Then CurrentScreenShot = 0
				EndIf		
			EndIf 
		Next 	

	End Method 	
		
	Method UpdateKeyboard()
		If Screen.UpdateKeyboard() = True Then Return True
		If KeyHit(KEYBOARD_ESC) Then 
			ChangeInterface(CurrentInterfaceNumber,1,0)
			Return True
		EndIf 

		If KeyHit(KEYBOARD_BIGCOVER) Then
			LoadBigCover()
			Return True 
		EndIf
					
		If KeyDown(KEYBOARD_RIGHT) Then
			If MilliSecs() - KeyDelayTimer > 100 
				CurrentScreenShot = CurrentScreenShot + 1
				KeyDelayTimer = MilliSecs()
				If CurrentScreenShot > ScreenShotNumber - 1 Then CurrentScreenShot = ScreenShotNumber - 1 'CurrentGamePos - GameArrayLen
			EndIf
			Return True 
		EndIf
		If KeyDown(KEYBOARD_LEFT) Then
			If MilliSecs() - KeyDelayTimer > 100 
				CurrentScreenShot = CurrentScreenShot - 1
				KeyDelayTimer = MilliSecs()		
				If CurrentScreenShot < 0 Then CurrentScreenShot = 0
			EndIf
		EndIf
	
		If KeyDown(KEYBOARD_UP) Then
			If MilliSecs() - KeyDelayTimer > 100 
				If CurrentScreenShot - itemsPerRow < 0 Then
					
				Else
					CurrentScreenShot = CurrentScreenShot - itemsPerRow
				EndIf 
				KeyDelayTimer = MilliSecs()		
			EndIf
		EndIf		
		If KeyDown(KEYBOARD_DOWN) Then
			If MilliSecs() - KeyDelayTimer > 100
				If CurrentScreenShot + itemsPerRow > ScreenShotNumber - 1 Then
					
				Else
					CurrentScreenShot = CurrentScreenShot + itemsPerRow
				EndIf 
				KeyDelayTimer = MilliSecs()		

			EndIf
		EndIf			
	End Method

	Method Pos:Float(Num:Int , Axis:Int , NormY:Float)
		Local Row:Int = - 1 , CRow:Int = - 1
		Local Col:Int = - 1 , CCol:Int = - 1
		If Num < itemsPerRow Then
			Row = 1
			Col = Num
		ElseIf Num < (itemsPerRow * 2)  Then
			Row = 2
			Col = Num - itemsPerRow
		ElseIf Num < (itemsPerRow * 3) Then
			Row = 3
			Col = Num - itemsPerRow * 2
		ElseIf Num < (itemsPerRow * 4) Then
			Row = 4
			Col = Num -  itemsPerRow * 3
		ElseIf Num < (itemsPerRow * 5) Then
			Row = 5
			Col = Num - itemsPerRow *4
		EndIf

		If CurrentScreenShot < itemsPerRow Then
			CRow = 1
			CCol = CurrentScreenShot
		ElseIf CurrentScreenShot < (itemsPerRow * 2) Then
			CRow = 2
			CCol = CurrentScreenShot - itemsPerRow
		ElseIf CurrentScreenShot < (itemsPerRow * 3) Then
			CRow = 3
			CCol = CurrentScreenShot - itemsPerRow * 2
		ElseIf CurrentScreenShot < (itemsPerRow * 4) Then
			CRow = 4
			CCol = CurrentScreenShot -  itemsPerRow * 3
		ElseIf CurrentScreenShot < (itemsPerRow * 5) Then
			CRow = 5
			CCol = CurrentScreenShot - itemsPerRow *4
		EndIf
		
		Select Axis
			Case 1
				Return Float(Col-CCol)*1.6
			Case 2
				Return Float(CRow-Row)*1.5 '+ NormY 
			Case 3
				If BigCover = 1 Then
					If (CRow - Row) = 0 And (Col - CCol) = 0 Then
						Return - 4.8
					Else
						Return - 4.8
					EndIf 
				Else
					If (CRow - Row) = 0 And (Col - CCol) = 0 Then
						Return - 2
					Else
						Return -1
					EndIf 
				EndIf 
		End Select 
	End Method 

	  
End Type


Type CoverWallInterface Extends GeneralType
	Field CoverWall:CoverWallType
	Field KeyDelayTimer:Int
	Field Info:InfoType
	Field Completed:CompletedType
	Field Rating:RatingType
	Field Screen:ScreenShotButtonType
	
	Method Init()
		CoverWall = New CoverWallType
		CoverWall.BigCoverEnabled = True
		CoverWall.CoverFlipEnabled = True 
		CoverWall.Init()	
		ListAddLast(UpdateTypeList , Self)	
		
		FrontNeeded = 1
		BackNeeded = 1
		ScreenNeeded = 0
		BannerNeeded = 0	
						
		
		Screen:ScreenShotButtonType = New ScreenShotButtonType
		If WideScreen = 1 Then
			Screen.DrawX = GWidth * (Float(80) / 800)
		Else
			Screen.DrawX = GWidth * (Float(60) / 800)
		EndIf 
		Screen.DrawY = GHeight * (Float(560) / 600) - GWidth * (Float(15) / 800)
		Screen.Init()
		
		
		Info:InfoType = New InfoType
		If WideScreen = 1 Then
			Info.DrawX = GWidth * (Float(40) / 800)
		Else
			Info.DrawX = GWidth * (Float(20) / 800)
		EndIf 
		Info.DrawY = GHeight * (Float(560) / 600) - GWidth * (Float(15) / 800)
		Info.Init()				
		
		Completed = New CompletedType
		Rating = New RatingType
		
		
		Completed.Init(GWidth * (Float(400) / 800) , GHeight * (Float(560) / 600) , True )
		
		
		If WideScreen = 1 Then
			Rating.Init(GWidth * (Float(720) / 800) , GHeight * (Float(560) / 600) , True )	
			'460
		Else
			Rating.Init(GWidth * (Float(700) / 800) , GHeight * (Float(560) / 600) , True )	
			'475
		EndIf 

		
		
	End Method
	
	Method Max2D()
		If CoverWall.BigCover <> 1 Then
			Screen.Max2D()
			Completed.Max2D()
			Rating.Max2D()
			SetImageFont(NameFont)
			SetColor(0,0,0)
			SetAlpha(0.7)
			DrawRect( (GWidth - TextWidth(GameNode.Name) ) / 2 - 20 , GHeight / 1.2 , TextWidth(GameNode.Name) + 40 , TextHeight(GameNode.Name) + 5)
			If MouseSwipe = 3 Then
				DrawRect((GWidth - TextWidth(Left(GameNode.Name,1)) ) / 2 - 20,GHeight / 1.1,TextWidth(Left(GameNode.Name,1))+40,TextHeight(Left(GameNode.Name,1))+5)
			EndIf
			SetColor(255 , 255 , 255)
			SetAlpha(1)
			DrawText(GameNode.Name , (GWidth - TextWidth(GameNode.Name) ) / 2 , GHeight / 1.2)		
			If MouseSwipe = 3 Then
				DrawText(Left(GameNode.Name,1) , (GWidth - TextWidth(Left(GameNode.Name,1)) ) / 2 , GHeight / 1.1)
			EndIf
		EndIf
		
	End Method
	
	Method Update()
		CoverWall.Update()
		Completed.Update()
		Rating.Update()	
		Screen.Update()			
	End Method
	
	Method Clear()
		Screen.Clear()
		CoverWall.Clear()
		CoverWall = Null
		ListRemove(UpdateTypeList , Self)
		Completed.Clear()
		Rating.Clear()
		Completed = Null
		Rating = Null
		Info.Clear()
		Info = Null 
		Screen = Null 
	End Method 
	
	Method UpdateMouse()
		If Screen.UpdateMouse() = True Then Return True
		If Completed.UpdateMouse() = True Then Return True
		If Rating.UpdateMouse() = True Then Return True			
		If CoverWall.UpdateMouse() = True Then Return True
		Return False 
	End Method
		
	Method UpdateJoy()
		If Screen.UpdateJoy() = True Then Return True			
		For J=0 To JoyCount()-1 
			If JoyHit(JOY_BIGCOVER,J) Then
				If CoverWall.BigCoverEnabled = True Then
					CoverWall.LoadBigCover()
				EndIf 
				Return True 
			EndIf
			If JoyHit(JOY_FLIPCOVER,J) Then
				If CoverWall.CoverFlipEnabled = True Then 
					CoverWall.FlipCover()
				EndIf 
				Return True
			EndIf
			
			If Tol(JoyY(J),0,0.2) <> 1 Then 
				If JoyY(J) > 0 Then 
					If MilliSecs() - KeyDelayTimer > 100/(JoyY(J)*1.5)
						If CurrentGamePos + CoverWall.itemsPerRow > GameArrayLen - 1 Then
							
						Else
							CurrentGamePos = CurrentGamePos + CoverWall.itemsPerRow
						EndIf 
						KeyDelayTimer = MilliSecs()	
					EndIf
					Return True 
				Else
					If MilliSecs() - KeyDelayTimer > 100/(-JoyY(J)*1.5)
						If CurrentGamePos - CoverWall.itemsPerRow < 0 Then
							
						Else
							CurrentGamePos = CurrentGamePos - CoverWall.itemsPerRow
						EndIf 
						KeyDelayTimer = MilliSecs()	
					EndIf 
					Return True 			
				EndIf 
			EndIf 
			
			If Tol(JoyX(J),0,0.2) <> 1 Then 
				If JoyX(J) > 0 Then 
					If MilliSecs() - KeyDelayTimer > 100/(JoyX(J)*1.5)
						CurrentGamePos = CurrentGamePos + 1
						KeyDelayTimer = MilliSecs()
						If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1 'CurrentGamePos - GameArrayLen
					EndIf
					Return True 
				Else
					If MilliSecs() - KeyDelayTimer > 100/(-JoyX(J)*1.5)
						CurrentGamePos = CurrentGamePos - 1
						KeyDelayTimer = MilliSecs()		
						If CurrentGamePos < 0 Then CurrentGamePos = 0'CurrentGamePos + GameArrayLen
					EndIf	
					Return True 			
				EndIf 
			EndIf 			
		
			If Tol(JoyHat(J),0.5,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100
					If CurrentGamePos + CoverWall.itemsPerRow > GameArrayLen - 1 Then
						
					Else
						CurrentGamePos = CurrentGamePos + CoverWall.itemsPerRow
					EndIf 
					KeyDelayTimer = MilliSecs()	
				EndIf
				Return True			
			EndIf 
			If Tol(JoyHat(J),0,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100
					If CurrentGamePos - CoverWall.itemsPerRow < 0 Then
						
					Else
						CurrentGamePos = CurrentGamePos - CoverWall.itemsPerRow
					EndIf 
					KeyDelayTimer = MilliSecs()	
				EndIf 
				Return True 		
			EndIf 		
			If Tol(JoyHat(J),0.25,0.1) Then 	
				If MilliSecs() - KeyDelayTimer > 100 
					CurrentGamePos = CurrentGamePos + 1
					KeyDelayTimer = MilliSecs()
					If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1 'CurrentGamePos - GameArrayLen
				EndIf
				Return True 			
			EndIf 
			If Tol(JoyHat(J),0.75,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100 
					CurrentGamePos = CurrentGamePos - 1
					KeyDelayTimer = MilliSecs()		
					If CurrentGamePos < 0 Then CurrentGamePos = 0'CurrentGamePos + GameArrayLen
				EndIf			
			EndIf 
		Next 	
	End Method 	
		
	Method UpdateKeyboard()
		If Screen.UpdateKeyboard() = True Then Return True	
		If KeyHit(KEYBOARD_BIGCOVER) Then
			If CoverWall.BigCoverEnabled = True Then
				CoverWall.LoadBigCover()
			EndIf 
			Return True 
		EndIf
		If KeyHit(KEYBOARD_FLIPCOVER) Then
			If CoverWall.CoverFlipEnabled = True Then 
				CoverWall.FlipCover()
			EndIf 
			Return True
		EndIf		
		If KeyDown(KEYBOARD_RIGHT) Then
			If MilliSecs() - KeyDelayTimer > 100 
				CurrentGamePos = CurrentGamePos + 1
				KeyDelayTimer = MilliSecs()
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1 'CurrentGamePos - GameArrayLen
			EndIf
			Return True 
		EndIf
		If KeyDown(KEYBOARD_LEFT) Then
			If MilliSecs() - KeyDelayTimer > 100 
				CurrentGamePos = CurrentGamePos - 1
				KeyDelayTimer = MilliSecs()		
				If CurrentGamePos < 0 Then CurrentGamePos = 0'CurrentGamePos + GameArrayLen
			EndIf
		EndIf
		If KeyDown(KEYBOARD_UP) Then
			If MilliSecs() - KeyDelayTimer > 100 
				If CurrentGamePos - CoverWall.itemsPerRow < 0 Then
					
				Else
					CurrentGamePos = CurrentGamePos - CoverWall.itemsPerRow
				EndIf 
				KeyDelayTimer = MilliSecs()		
				'If CurrentGamePos < 0 Then CurrentGamePos = CurrentGamePos + GameArrayLen + 2 'CurrentGamePos + GameArrayLen
			EndIf
		EndIf		
		If KeyDown(KEYBOARD_DOWN) Then
			If MilliSecs() - KeyDelayTimer > 100
				If CurrentGamePos + CoverWall.itemsPerRow > GameArrayLen - 1 Then
					
				Else
					CurrentGamePos = CurrentGamePos + CoverWall.itemsPerRow
				EndIf 
				KeyDelayTimer = MilliSecs()		
				'If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = CurrentGamePos - GameArrayLen - 2
			EndIf
		EndIf				
	End Method  
End Type

Type ListViewInterface Extends GeneralType
	Field Cover:CoverType
	Field CoverAlphaBack:TMesh
	Field Back:BackType
	Field CoverPivot:TPivot
	Field GameList:GameListType
	Field KeyDelayTimer:Int
	Field OldCurrentGamePos:Int = -1 
	Field TextList:TList
	Field FontHeight:Int
	
	Field Info:InfoType
	Field Completed:CompletedType
	Field Rating:RatingType
	Field Screen:ScreenShotButtonType
	
	Field BigCover:Int = 0
	
	Method FlipCover()
		If Cover.Roty > 90 Then
			Cover.Roty = 0
		ElseIf Cover.Roty < 90 Then
			Cover.Roty = 180
		EndIf		
	End Method				

	Method LoadBigCover()
		Local BTex:TTexture		
		If BigCover = 0 Then
			Cover.GlobalPosition = True
			Cover.y = 0

			If WideScreen = 1 Then
				Cover.z = - 2
			Else
				Cover.z = - 2.3
			EndIf
			BigCover = 1		
			If Cover.Roty = 180 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Front_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Front_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Cover.Mesh , BTex)
				EndIf
			ElseIf Cover.Roty = 0 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Back_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Back_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Cover.BackMesh , BTex)
				EndIf					
			EndIf
		Else
			'Rem

			'EndRem 
			
			Cover.z = 0
			Cover.y = Cover.NormY
			Cover.GlobalPosition = False 
			BigCover = 0
		EndIf		
	End Method
		
	Method Init()
		
		FrontNeeded = 1
		BackNeeded = 1
		ScreenNeeded = 1
		BannerNeeded = 0
				
		GameList = New GameListType
		If WideScreen = 1 Then
			GameList.Init(GWidth * (Float(540) / 800) , GHeight * (Float(50) / 600) , GWidth , GHeight * (Float(400) / 600) )
		Else
			GameList.Init(GWidth * (Float(450) / 800) , GHeight * (Float(50) / 600) , GWidth , GHeight * (Float(400) / 600) )
		EndIf 
		
		Cover = New CoverType
		Cover.Position = CurrentGamePos
		Cover.Reflections = False
		
		Info:InfoType = New InfoType
		If WideScreen = 1 Then
			Info.DrawX = GWidth * (Float(720) / 800)
		Else
			Info.DrawX = GWidth * (Float(700) / 800)
		EndIf 
		Info.DrawY = GHeight * (Float(560) / 600) - GWidth * (Float(15) / 800)
		Info.Init()		
		
		Screen:ScreenShotButtonType = New ScreenShotButtonType
		If WideScreen = 1 Then
			Screen.DrawX = GWidth * (Float(680) / 800)
		Else
			Screen.DrawX = GWidth * (Float(660) / 800)
		EndIf 
		Screen.DrawY = GHeight * (Float(560) / 600) - GWidth * (Float(15) / 800)
		Screen.Init()			
		
		Completed = New CompletedType
		Rating = New RatingType
		
		
		If WideScreen = 1 Then
			Completed.Init(GWidth * (Float(180) / 800) , GHeight * (Float(560) / 600) , True )
		Else
			Completed.Init(GWidth * (Float(250) / 800) , GHeight * (Float(560) / 600) , True )
		EndIf 
		
		
		If WideScreen = 1 Then
			Rating.Init(GWidth * (Float(460) / 800) , GHeight * (Float(560) / 600) , True )	
		Else
			Rating.Init(GWidth * (Float(475) / 800) , GHeight * (Float(560) / 600) , True )	
		EndIf 

		
		Back = New BackType
		Back.Init()
		
		CoverPivot = CreatePivot()
		Cover.Init(CoverPivot)
		CoverAlphaBack = CreateCube(CoverPivot)
		EntityAlpha(CoverAlphaBack , 0.8)
		tex = LoadPreloadedTexture(RESFOLDER + "Black.jpg")	
		If tex <> Null
			EntityTexture(CoverAlphaBack,tex)
		EndIf
		
		
		ScaleEntity(CoverAlphaBack,100,1.3,0)
		MoveEntity(CoverAlphaBack , 0 , 0 , 0.01)
		If WideScreen = 1 Then
			PositionEntity(CoverPivot , - 6.2 , - 2.8 , 3.5)
		Else
			PositionEntity(CoverPivot , - 4.5 , - 3 , 2)
		EndIf 
		ListAddLast(UpdateTypeList , Self)	
		
		SetImageFont(MainTextFont)
		FontHeight = TextHeight("A") + (Float(5)/600)*GHeight

	End Method
	
	Method Clear()
		Cover.Clear()
		Back.Clear()
		GameList.Clear()
		Completed.Clear()
		Rating.Clear()
		Info.Clear()
		FreeEntity(CoverPivot)
		ListRemove(UpdateTypeList , Self)	
		Cover = Null
		Completed = Null
		Rating = Null
		Info = Null 
		Back = Null
		GameList = Null
		Screen.Clear()
		Screen = Null 		
	End Method 
	
	Method Update()
		If OldCurrentGamePos <> CurrentGamePos Then
			UpdateCover()
			SetImageFont(MainTextFont)
			TextList = GetTextList(GameNode.Desc)	
			OldCurrentGamePos = CurrentGamePos
		EndIf 
		
		Cover.Update()
		'ScaleEntity(CoverAlphaBack , 100 , Cover.NormY + 1.2 , 0)
		'PositionEntity(CoverAlphaBack , EntityX(CoverAlphaBack) , Cover.NormY , EntityZ(CoverAlphaBack)) 
		Back.Update()
		GameList.Update()
		Completed.Update()
		Rating.Update()	
		Screen.Update()	
	End Method
	
	Method UpdateJoy()
		If Screen.UpdateJoy() = True Then Return True			
		For J=0 To JoyCount()-1 
			If JoyHit(JOY_BIGCOVER,J) Then
				LoadBigCover()
				Return True 
			EndIf
			If JoyHit(JOY_FLIPCOVER,J) Then
				FlipCover()
				Return True
			EndIf
			If Tol(JoyY(J),0,0.2) <> 1 Then 
				If JoyY(J) > 0 Then 
					If MilliSecs() - KeyDelayTimer > 100/(JoyY(J)*1.5)
						CurrentGamePos = CurrentGamePos + 1
						KeyDelayTimer = MilliSecs()
						If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1 'CurrentGamePos - GameArrayLen
					EndIf
					Return True 
				Else
					If MilliSecs() - KeyDelayTimer > 100/(-JoyY(J)*1.5)
						CurrentGamePos = CurrentGamePos - 1
						KeyDelayTimer = MilliSecs()		
						If CurrentGamePos < 0 Then CurrentGamePos = 0'CurrentGamePos + GameArrayLen
					EndIf	
					Return True 			
				EndIf 
			EndIf 	
		
			If Tol(JoyHat(J),0.5,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100 
					CurrentGamePos = CurrentGamePos + 1
					KeyDelayTimer = MilliSecs()
					If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1 'CurrentGamePos - GameArrayLen
				EndIf
				Return True			
			EndIf 
			If Tol(JoyHat(J),0,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100 
					CurrentGamePos = CurrentGamePos - 1
					KeyDelayTimer = MilliSecs()		
					If CurrentGamePos < 0 Then CurrentGamePos = 0'CurrentGamePos + GameArrayLen
				EndIf	
				Return True 		
			EndIf 			
		Next 	
	End Method 
	
	Method UpdateKeyboard()
		If Screen.UpdateKeyboard() = True Then Return True	
		If KeyHit(KEYBOARD_BIGCOVER) Then
			LoadBigCover()
			Return True 
		EndIf
		If KeyHit(KEYBOARD_FLIPCOVER) Then
			FlipCover()
			Return True
		EndIf		
		If KeyDown(KEYBOARD_DOWN) Then
			If MilliSecs() - KeyDelayTimer > 100 
				CurrentGamePos = CurrentGamePos + 1
				KeyDelayTimer = MilliSecs()
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1 'CurrentGamePos - GameArrayLen
			EndIf
			'UpdateCover()
			Return True 
		EndIf
		If KeyDown(KEYBOARD_UP) Then
			If MilliSecs() - KeyDelayTimer > 100 
				CurrentGamePos = CurrentGamePos - 1
				KeyDelayTimer = MilliSecs()		
				If CurrentGamePos < 0 Then CurrentGamePos = 0'CurrentGamePos + GameArrayLen
			EndIf
			'UpdateCover()
			Return True 
		EndIf
		Return False 		
	End Method
	
	Method UpdateMouse()
		If Screen.UpdateMouse() = True Then Return True
		If Completed.UpdateMouse() = True Then Return True
		If Rating.UpdateMouse() = True Then Return True			
		If Cover.MouseOver() = True Then
			If MouseClick = 1 Then
				LoadBigCover()
				Return True 									
			ElseIf MouseClick = 2 Then
				FlipCover()
				Return True					
			EndIf 
		EndIf
		
		If GameList.UpdateMouse() = True Then Return True
		
		Return False 
	End Method 
	
	Method UpdateCover()
		Cover.Position = CurrentGamePos
		Cover.Textured = False 
		Cover.BackTextured = False 	
	End Method
	
	Method Max2D()
		If BigCover <> 1 Then 
			Screen.Max2D()
			Completed.Max2D()
			Rating.Max2D()		
			Local DescLine:String
			Local a:Int = 1
			GameList.Max2D()
			SetImageFont(NameFont)
			If WideScreen = 1 Then
				DrawText(GameNode.Name , GWidth * (Float(460) / 800) - ( TextWidth(GameNode.Name) / 2) , GHeight * (Float(420) / 600) )
			Else
				DrawText(GameNode.Name , GWidth * (Float(475) / 800) - ( TextWidth(GameNode.Name) / 2) , GHeight * (Float(420) / 600) )
			EndIf 
			SetImageFont(MainTextFont)
			
			For DescLine = EachIn TextList
				If a > 3 Then
					If WideScreen = 1 Then
						DrawText(DescLine + "..." , GWidth * (Float(140) / 800) , GHeight * (Float(440) / 600) + (a * FontHeight) )	
					Else
						DrawText(DescLine + "..." , GWidth * (Float(200) / 800) , GHeight * (Float(440) / 600) + (a * FontHeight) )	
					EndIf 
					Exit
				EndIf
				If WideScreen = 1 Then
					DrawText(DescLine , GWidth * (Float(140) / 800) , GHeight * (Float(440) / 600) + (a * FontHeight) )	
				Else
					DrawText(DescLine , GWidth * (Float(200) / 800) , GHeight * (Float(440) / 600) + (a * FontHeight) )	
				EndIf 
				a = a + 1
			Next			
		EndIf 
	End Method
	
	Method GetTextList:TList(Desc:String)
		Desc = Desc + " "
		Local List:TList = CreateList()
		Local b:Int = 1
		Local LastSpace:Int = 1
		For a = 1 To Len(Desc)
			If Mid(Desc , a , 1) = " " Then
				
				If (TextWidth(Mid(Desc , b , a - b) ) > GWidth*(Float(550)/800) And WideScreen = 0) Or (TextWidth(Mid(Desc , b , a - b) ) > GWidth*(Float(620)/800) And WideScreen = 1) Then
					ListAddLast(List , Mid(Desc , b , LastSpace - b) )
					b = LastSpace + 1
					a = LastSpace + 1
				EndIf
				LastSpace = a
			EndIf
		Next
		ListAddLast(List , Mid(Desc , b , LastSpace - b) )
		Return List
	End Method
	
	
End Type

Type InfoViewBannerInterface Extends GeneralType
	Field CoverFlow:BannerFlowType
	Field Info:InfoType
	Field Back:BackType
	Field TempVal1:Int
	Field TempVal2:Int 	
	Field TempVal3:Int
	Field TempVal4:Int
	
	Field Completed:CompletedType
	Field Rating:RatingType	
	Field Screen:ScreenShotButtonType
	
	Field TextList:TList
	Field FontHeight2:Int
	Field FontHeight:Int
	Field Genre:String
	
	Field Height40Scaled:Int
	Field StartHeight:Int
	Field TextScrollOverride:Int 
	
	Field initial:Int = True
	Field DescTextY:Int
	Field OldCurrentGamePos = -1
	
	Method Init()
		Back = New BackType
		Back.Init()
		CoverFlow = New BannerFlowType
		CoverFlow.CoverMode = 2
		CoverFlow.BigCoverEnabled = False  
		CoverFlow.ReflectiveFloorEnabled = False 
		CoverFlow.FlowBackEnabled = True  
		CoverFlow.CoverFlipEnabled = False 
				
		If WideScreen = 0 Then 				
			CoverFlow.Init(0 , - 3.4 , 2)
		Else
			CoverFlow.Init(0 , - 3.35 , 4)
		EndIf 
		ListAddLast(UpdateTypeList , Self)	
		FrontNeeded = 0
		BackNeeded = 0
		ScreenNeeded = 1
		BannerNeeded = 1

		
		Info:InfoType = New InfoType
		Info.DrawX = GWidth * (Float(50) / 800)
		'GWidth * (Float(30) / 800)
		Info.DrawY = GHeight * (Float(375) / 600)
		'GHeight* (1-(Float(50) / 600))
		Info.Init()	
		
		Screen:ScreenShotButtonType = New ScreenShotButtonType
		Screen.DrawX = GWidth * (Float(90) / 800)
		Screen.DrawY = GHeight * (Float(375) / 600)
		Screen.Init()						
		
		TempVal1 = GWidth * (Float(30) / 800)
		TempVal2 = GWidth * (Float(20) / 800)
		TempVal3 = GHeight - (GHeight * (Float(20) / 600) )	
		TempVal4 = GWidth * (Float(10) / 800)
		
		Height40Scaled = GHeight * (Float(40)/600)
		
		Completed = New CompletedType
		Rating = New RatingType
		Completed.Init(GWidth * (Float(700) / 800) , GHeight * (Float(390) / 600) , True )
		Rating.Init(GWidth * (Float(400) / 800) , GHeight * (Float(390) / 600) , True )	
					
	End Method

	Method GetTextList:TList(Desc:String)
		Desc = Desc + " "
		Local List:TList = CreateList()
		Local b:Int = 1
		Local LastSpace:Int = 1
		For a = 1 To Len(Desc)
			If Mid(Desc,a,1)=" " Then
				If TextWidth(Mid(Desc , b , a - b) ) > GWidth - 3*TempVal1 Then
					ListAddLast(List , Mid(Desc , b , LastSpace - b) )
					b = LastSpace + 1
					a = LastSpace + 1
				EndIf
				LastSpace = a
			EndIf
		Next
		ListAddLast(List , Mid(Desc , b , LastSpace - b) )
		Return List
	End Method
	
	Method Max2D()		
		If CoverFlow.BigCover <> 1 Then
			Local DescLine:String
			Local a:Int = 0,b:Int = 0
			Local Gen:String
	
			SetColor(0,0,0)
			SetAlpha(0.7)
			If WideScreen = 0 Then
				DrawRect(TempVal4 , 1.3 * Height40Scaled , GWidth - 2 * TempVal4 , 2.2 * Height40Scaled + (5 * FontHeight2) + (7) * FontHeight)		
			Else
				DrawRect(TempVal4 , 1.3 * Height40Scaled , GWidth - 2 * TempVal4 , 2.4 * Height40Scaled + (5 * FontHeight2) + (7) * FontHeight)		
			EndIf 
	
			SetColor(255,255,255)
			SetAlpha(1)
	
			
			SetImageFont(NameFont)
			DrawText(GameNode.Name , (GWidth - TextWidth(GameNode.Name) ) / 2 , 1.5*Height40Scaled)
			SetImageFont(MainTextFont)
			
			If OldCurrentGamePos <> CurrentGamePos Then
				TextList = GetTextList(GameNode.Desc)
				Genre = ""
				For Gen = EachIn GameNode.Genres
					Genre = Genre + Gen + "/"
				Next	
				Genre = Left(Genre , Len(Genre) - 1)
				
			EndIf
				
			If initial = True Then	
				FontHeight = TextHeight("A") + (Float(5)/600)*GHeight
				FontHeight2 = FontHeight + (Float(5)/600)*GHeight
				initial = False
				DescTextY = 0
			EndIf
			
			For DescLine = EachIn TextList
				If a > 4 Then
					DrawText(DescLine + "..." , TempVal1 , DescTextY + 2.5 * Height40Scaled + (a * FontHeight) )	
					Exit
				EndIf
				DrawText(DescLine , TempVal1 , DescTextY + 2.5 * Height40Scaled + (a * FontHeight) )	
				a = a + 1
			Next	
				
					
			If OldCurrentGamePos <> CurrentGamePos Then 		
				StartHeight = (a + 1) * FontHeight
				OldCurrentGamePos = CurrentGamePos
			EndIf	
			a = 0
			DrawLine(TempVal1 , 2.5*Height40Scaled + ( StartHeight ) , GWidth - 30 , 2.5*Height40Scaled + ( StartHeight ) )
			a = a + 1
			DrawText("Genre:   " + Genre , 2*TempVal1 , 2.5*Height40Scaled + StartHeight + (a * FontHeight2) )
			DrawText("Certificate:   " + GameNode.Cert , (GWidth / 2)+TempVal1 , 2.5*Height40Scaled + StartHeight + (a*FontHeight2) )	
			a = a + 1
			DrawText("Developer:   "+GameNode.Dev, 2*TempVal1 , 2.5*Height40Scaled + StartHeight + (a*FontHeight2) )			
			DrawText("Publisher:   " + GameNode.Pub , (GWidth / 2)+TempVal1 , 2.5*Height40Scaled + StartHeight + (a*FontHeight2) )
			a = a + 1
			DrawText("Platform:   " + GlobalPlatforms.GetPlatformByID(GameNode.PlatformNum).Name , 2 * TempVal1 , 2.5 * Height40Scaled + StartHeight + (a * FontHeight2) )	
			DrawText("Released:   " + GameNode.ReleaseDate , (GWidth / 2) + TempVal1 , 2.5*Height40Scaled + StartHeight + (a * FontHeight2) )
			a = a + 1
			DrawText("Players:   " + GameNode.Players , 2*TempVal1 , 2.5*Height40Scaled + StartHeight + (a * FontHeight2) )
			DrawText("Co-op:   " + GameNode.CoOp , ( GWidth / 2) + TempVal1 , 2.5*Height40Scaled + StartHeight + (a * FontHeight2) )
		
			Completed.Max2D()
			Rating.Max2D()
			Screen.Max2D()
		EndIf 		
	End Method
	
	Method Update()
		Completed.Update()
		Rating.Update()		
		CoverFlow.Update()
		Back.Update()
		Screen.Update()
	End Method
	
	Method UpdateJoy()
		If Screen.UpdateJoy() = True Then Return True			
		CoverFlow.UpdateJoy()
	End Method 
	
	Method UpdateKeyboard()
		If Screen.UpdateKeyboard() = True Then Return True	
		CoverFlow.UpdateKeyboard()
	End Method
	
	Method UpdateMouse()
		If Screen.UpdateMouse() = True Then Return True
		If Completed.UpdateMouse() = True Then Return True
		If Rating.UpdateMouse() = True Then Return True		
		CoverFlow.UpdateMouse()
	End Method
	
	Method Clear()
		CoverFlow.Clear()
		Back.Clear()
		Completed.Clear()
		Rating.Clear()
		Info.Clear()
		ListRemove(UpdateTypeList , Self)	
		Info = Null 
		Completed = Null
		Rating = Null 
		CoverFlow = Null
		Back = Null 	
		Screen.Clear()
		Screen = Null 
	End Method	
	
End Type 



Type InfoViewInterface Extends GeneralType
	Field CoverFlow:CoverFlowType
	Field Info:InfoType
	Field Back:BackType
	Field TempVal1:Int
	Field TempVal2:Int 	
	Field TempVal3:Int
	Field TempVal4:Int
	
	Field Completed:CompletedType
	Field Rating:RatingType	
	Field Screen:ScreenShotButtonType
	
	Field TextList:TList
	Field FontHeight2:Int
	Field FontHeight:Int
	Field Genre:String
	
	Field Height40Scaled:Int
	Field StartHeight:Int
	Field TextScrollOverride:Int 
	
	Field initial:Int = True
	Field DescTextY:Int
	Field OldCurrentGamePos = -1
	
	Method Init()
		Back = New BackType
		Back.Init()
		CoverFlow = New CoverFlowType
		CoverFlow.CoverMode = 2
		CoverFlow.BigCoverEnabled = True 
		CoverFlow.ReflectiveFloorEnabled = False 
		CoverFlow.FlowBackEnabled = True  
		CoverFlow.CoverFlipEnabled = True
				
		If WideScreen = 0 Then 				
			CoverFlow.Init(0 , - 3.4 , 2)
		Else
			CoverFlow.Init(0 , - 3.35 , 4)
		EndIf 
		ListAddLast(UpdateTypeList , Self)	
		FrontNeeded = 1
		BackNeeded = 1
		ScreenNeeded = 1
		BannerNeeded = 0

		
		Info:InfoType = New InfoType
		Info.DrawX = GWidth * (Float(50) / 800)
		'GWidth * (Float(30) / 800)
		Info.DrawY = GHeight * (Float(375) / 600)
		'GHeight* (1-(Float(50) / 600))
		Info.Init()			
		
		Screen:ScreenShotButtonType = New ScreenShotButtonType
		Screen.DrawX = GWidth * (Float(90) / 800)
		Screen.DrawY = GHeight * (Float(375) / 600)
		Screen.Init()				
		
		TempVal1 = GWidth * (Float(30) / 800)
		TempVal2 = GWidth * (Float(20) / 800)
		TempVal3 = GHeight - (GHeight * (Float(20) / 600) )	
		TempVal4 = GWidth * (Float(10) / 800)
		
		Height40Scaled = GHeight * (Float(40)/600)
		
		Completed = New CompletedType
		Rating = New RatingType
		Completed.Init(GWidth * (Float(700) / 800) , GHeight * (Float(390) / 600) , True )
		Rating.Init(GWidth * (Float(400) / 800) , GHeight * (Float(390) / 600) , True )	
					
	End Method

	Method GetTextList:TList(Desc:String)
		Desc = Desc + " "
		Local List:TList = CreateList()
		Local b:Int = 1
		Local LastSpace:Int = 1
		For a = 1 To Len(Desc)
			If Mid(Desc,a,1)=" " Then
				If TextWidth(Mid(Desc , b , a - b) ) > GWidth - 3*TempVal1 Then
					ListAddLast(List , Mid(Desc , b , LastSpace - b) )
					b = LastSpace + 1
					a = LastSpace + 1
				EndIf
				LastSpace = a
			EndIf
		Next
		ListAddLast(List , Mid(Desc , b , LastSpace - b) )
		Return List
	End Method
	
	Method Max2D()		
		If CoverFlow.BigCover <> 1 Then
			Local DescLine:String
			Local a:Int = 0,b:Int = 0
			Local Gen:String
	
			SetColor(0,0,0)
			SetAlpha(0.7)
			If WideScreen = 0 Then
				DrawRect(TempVal4 , 1.3 * Height40Scaled , GWidth - 2 * TempVal4 , 2.2 * Height40Scaled + (5 * FontHeight2) + (7) * FontHeight)		
			Else
				DrawRect(TempVal4 , 1.3 * Height40Scaled , GWidth - 2 * TempVal4 , 2.4 * Height40Scaled + (5 * FontHeight2) + (7) * FontHeight)		
			EndIf 
	
			SetColor(255,255,255)
			SetAlpha(1)
	
			
			SetImageFont(NameFont)
			DrawText(GameNode.Name , (GWidth - TextWidth(GameNode.Name) ) / 2 , 1.5*Height40Scaled)
			SetImageFont(MainTextFont)
			
			If OldCurrentGamePos <> CurrentGamePos Then
				TextList = GetTextList(GameNode.Desc)
				Genre = ""
				For Gen = EachIn GameNode.Genres
					Genre = Genre + Gen + "/"
				Next	
				Genre = Left(Genre , Len(Genre) - 1)
				
			EndIf
				
			If initial = True Then	
				FontHeight = TextHeight("A") + (Float(5)/600)*GHeight
				FontHeight2 = FontHeight + (Float(5)/600)*GHeight
				initial = False
				DescTextY = 0
			EndIf
			
			For DescLine = EachIn TextList
				If a > 4 Then
					DrawText(DescLine + "..." , TempVal1 , DescTextY + 2.5 * Height40Scaled + (a * FontHeight) )	
					Exit
				EndIf
				DrawText(DescLine , TempVal1 , DescTextY + 2.5 * Height40Scaled + (a * FontHeight) )	
				a = a + 1
			Next	
				
					
			If OldCurrentGamePos <> CurrentGamePos Then 		
				StartHeight = (a + 1) * FontHeight
				OldCurrentGamePos = CurrentGamePos
			EndIf	
			a = 0
			DrawLine(TempVal1 , 2.5*Height40Scaled + ( StartHeight ) , GWidth - 30 , 2.5*Height40Scaled + ( StartHeight ) )
			a = a + 1
			DrawText("Genre:   " + Genre , 2*TempVal1 , 2.5*Height40Scaled + StartHeight + (a * FontHeight2) )
			DrawText("Certificate:   " + GameNode.Cert , (GWidth / 2)+TempVal1 , 2.5*Height40Scaled + StartHeight + (a*FontHeight2) )	
			a = a + 1
			DrawText("Developer:   "+GameNode.Dev, 2*TempVal1 , 2.5*Height40Scaled + StartHeight + (a*FontHeight2) )			
			DrawText("Publisher:   " + GameNode.Pub , (GWidth / 2)+TempVal1 , 2.5*Height40Scaled + StartHeight + (a*FontHeight2) )
			a = a + 1
			DrawText("Platform:   " + GlobalPlatforms.GetPlatformByID(GameNode.PlatformNum).Name , 2*TempVal1 , 2.5*Height40Scaled + StartHeight + (a*FontHeight2) )	
			DrawText("Released:   " + GameNode.ReleaseDate , (GWidth / 2) + TempVal1 , 2.5*Height40Scaled + StartHeight + (a * FontHeight2) )
			a = a + 1
			DrawText("Players:   " + GameNode.Players , 2*TempVal1 , 2.5*Height40Scaled + StartHeight + (a * FontHeight2) )
			DrawText("Co-op:   " + GameNode.CoOp , ( GWidth / 2) + TempVal1 , 2.5*Height40Scaled + StartHeight + (a * FontHeight2) )
		
			Completed.Max2D()
			Rating.Max2D()
			Screen.Max2D()
		EndIf 		
	End Method
	
	Method Update()
		Completed.Update()
		Rating.Update()		
		CoverFlow.Update()
		Back.Update()
		Screen.Update()
	End Method
	
	Method UpdateJoy()
		If Screen.UpdateJoy() = True Then Return True			
		CoverFlow.UpdateJoy()
	End Method 
	
	Method UpdateKeyboard()
		If Screen.UpdateKeyboard() = True Then Return True	
		CoverFlow.UpdateKeyboard()
	End Method
	
	Method UpdateMouse()
		If Completed.UpdateMouse() = True Then Return True
		If Rating.UpdateMouse() = True Then Return True	
		If Screen.UpdateMouse() = True Then Return True	
		CoverFlow.UpdateMouse()
	End Method
	
	Method Clear()
		CoverFlow.Clear()
		Back.Clear()
		Completed.Clear()
		Rating.Clear()
		Info.Clear()
		ListRemove(UpdateTypeList , Self)	
		Info = Null 
		Completed = Null
		Rating = Null 
		CoverFlow = Null
		Back = Null 	
		Screen.Clear()
		Screen = Null 		
	End Method	
	
End Type 


Type CoverFlowInterface Extends GeneralType
	Field CoverFlow:CoverFlowType
	Field Info:InfoType
	Field Completed:CompletedType
	Field Rating:RatingType
	Field Screen:ScreenShotButtonType

	Method Init()
		CoverFlow = New CoverFlowType
		CoverFlow.CoverMode = 1
		CoverFlow.BigCoverEnabled = True
		CoverFlow.ReflectiveFloorEnabled = True 
		CoverFlow.FlowBackEnabled = False 
		CoverFlow.CoverFlipEnabled = True	
		Info:InfoType = New InfoType
		Info.DrawX = GWidth * (Float(30) / 800)
		Info.DrawY = GHeight* (1-(Float(50) / 600))
		Info.Init()			
		
		Screen:ScreenShotButtonType = New ScreenShotButtonType
		Screen.DrawX = GWidth * (Float(70) / 800)
		Screen.DrawY = GHeight* (1-(Float(50) / 600))
		Screen.Init()		
					
		CoverFlow.Init(0 , 0 , 0)
		ListAddLast(UpdateTypeList , Self)		
		FrontNeeded = 1
		BackNeeded = 1
		ScreenNeeded = 0
		BannerNeeded = 0	

		
		Completed = New CompletedType
		Rating = New RatingType
		Completed.Init(GWidth * (Float(700) / 800) , GHeight * (Float(540) / 600) , True )
		Rating.Init(GWidth * (Float(700) / 800) , GHeight * (Float(570) / 600) , True )	
	End Method
	
	Method Max2D()
		If CoverFlow.BigCover <> 1 Then
			Screen.Max2D()
			Completed.Max2D()
			Rating.Max2D()
			SetImageFont(NameFont)
			SetColor(0,0,0)
			SetAlpha(0.7)
			DrawRect( (GWidth - TextWidth(GameNode.Name) ) / 2 - 20 , GHeight / 1.2 , TextWidth(GameNode.Name) + 40 , TextHeight(GameNode.Name) + 5)
			If MouseSwipe = 3 Then
				DrawRect((GWidth - TextWidth(Left(GameNode.Name,1)) ) / 2 - 20,GHeight / 1.1,TextWidth(Left(GameNode.Name,1))+40,TextHeight(Left(GameNode.Name,1))+5)
			EndIf
			SetColor(255 , 255 , 255)
			SetAlpha(1)
			DrawText(GameNode.Name , (GWidth - TextWidth(GameNode.Name) ) / 2 , GHeight / 1.2)		
			If MouseSwipe = 3 Then
				DrawText(Left(GameNode.Name,1) , (GWidth - TextWidth(Left(GameNode.Name,1)) ) / 2 , GHeight / 1.1)
			EndIf
		EndIf
	End Method
	
	Method Update() 
		Completed.Update()
		Rating.Update()		
		Screen.Update()
		CoverFlow.Update()
	End Method
	
	Method UpdateJoy()
		If Screen.UpdateJoy() = True Then Return True			
		If CoverFlow.UpdateJoy() = True Then Return True
	End Method 
	
	Method UpdateKeyboard()
		If Screen.UpdateKeyboard() = True Then Return True
		If CoverFlow.UpdateKeyboard() = True Then Return True
	End Method
	
	Method UpdateMouse()
		If Screen.UpdateMouse() = True Then Return True
		If Completed.UpdateMouse() = True Then Return True
		If Rating.UpdateMouse() = True Then Return True		
		CoverFlow.UpdateMouse()
	End Method
	
	Method Clear()
		Screen.Clear()
		Completed.Clear()
		Rating.Clear()
		Info.Clear()		
		CoverFlow.Clear()
		ListRemove(UpdateTypeList , Self)
		CoverFlow = Null
		Rating = Null 
		Completed = Null 
		Info = Null 
		Screen = Null 
	End Method	
End Type


Type BannerFlowInterface Extends GeneralType
	Field Cover:CoverType	
	Field CoverAlphaBack:TMesh
	Field Back:BackType
	Field CoverPivot:TPivot
	Field KeyDelayTimer:Int
	Field OldCurrentGamePos:Int = -1 
	Field TextList:TList
	Field FontHeight:Int
	
	Field BannerFlow:BannerFlowType
	Field Info:InfoType
	Field Completed:CompletedType
	Field Rating:RatingType	
	Field Screen:ScreenShotButtonType		

	Field BigCover:Int = 0
	
	Method FlipCover()
		If Cover.Roty > 90 Then
			Cover.Roty = 0
		ElseIf Cover.Roty < 90 Then
			Cover.Roty = 180
		EndIf		
	End Method				

	Method LoadBigCover()
		Local BTex:TTexture		
		If BigCover = 0 Then
			Cover.GlobalPosition = True
			Cover.y = Cover.NormY

			If WideScreen = 1 Then
				Cover.z = - 2
			Else
				Cover.z = - 2.3
			EndIf
			BigCover = 1		
			If Cover.Roty = 180 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Front_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Front_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Cover.Mesh , BTex)
				EndIf
			ElseIf Cover.Roty = 0 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Back_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Back_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Cover.BackMesh , BTex)
				EndIf					
			EndIf
		Else
			Cover.z = 0 'Cover.Pos(Cover.CoverNum , 3)
			Cover.y = 0 'Cover.Pos(Cover.CoverNum , 2)
			Cover.GlobalPosition = False 
			BigCover = 0
		EndIf		
	End Method


	Method UpdateCover()
		Cover.Position = CurrentGamePos
		Cover.Textured = False 
		Cover.BackTextured = False 	
	End Method
		
	Method Init()
		
		FrontNeeded = 1
		BackNeeded = 1
		ScreenNeeded = 1
		BannerNeeded = 1

		
		BannerFlow = New BannerFlowType
		BannerFlow.CoverMode = 1
		BannerFlow.BigCoverEnabled = False  
		BannerFlow.ReflectiveFloorEnabled = False 
		BannerFlow.FlowBackEnabled = False 
		BannerFlow.CoverFlipEnabled = False 
			
		BannerFlow.Init(0 , 1.4 , 0.9)

		Cover = New CoverType
		Cover.Position = CurrentGamePos
		Cover.Reflections = False

		
		Info:InfoType = New InfoType
		If WideScreen = 1 Then
			Info.DrawX = GWidth * (Float(720) / 800)
		Else
			Info.DrawX = GWidth * (Float(700) / 800)
		EndIf 
		Info.DrawY = GHeight * (Float(560) / 600) - GWidth * (Float(15) / 800)
		Info.Init()				
		
		Screen:ScreenShotButtonType = New ScreenShotButtonType
		If WideScreen = 1 Then
			Screen.DrawX = GWidth * (Float(680) / 800)
		Else
			Screen.DrawX = GWidth * (Float(660) / 800)
		EndIf 
		Screen.DrawY = GHeight * (Float(560) / 600) - GWidth * (Float(15) / 800)
		Screen.Init()		
		
		Completed = New CompletedType
		Rating = New RatingType
		
		
		If WideScreen = 1 Then
			Completed.Init(GWidth * (Float(180) / 800) , GHeight * (Float(560) / 600) , True )
		Else
			Completed.Init(GWidth * (Float(250) / 800) , GHeight * (Float(560) / 600) , True )
		EndIf 
		
		
		If WideScreen = 1 Then
			Rating.Init(GWidth * (Float(460) / 800) , GHeight * (Float(560) / 600) , True )	
		Else
			Rating.Init(GWidth * (Float(475) / 800) , GHeight * (Float(560) / 600) , True )	
		EndIf 

		
		Back = New BackType
		Back.Init()
		
		CoverPivot = CreatePivot()
		Cover.Init(CoverPivot)
		CoverAlphaBack = CreateCube(CoverPivot)
		EntityAlpha(CoverAlphaBack , 0.8)
		tex = LoadPreloadedTexture(RESFOLDER + "Black.jpg")	
		If tex <> Null
			EntityTexture(CoverAlphaBack,tex)
		EndIf
		
		
		ScaleEntity(CoverAlphaBack,100,1.3,0)
		MoveEntity(CoverAlphaBack , 0 , 0 , 0.01) 'was 0.01
		If WideScreen = 1 Then
			PositionEntity(CoverPivot , - 6.2 , - 2.8 , 3.5) 
		Else
			PositionEntity(CoverPivot , - 4.5 , - 3 , 2)
		EndIf 
		ListAddLast(UpdateTypeList , Self)	
		
		SetImageFont(MainTextFont)
		FontHeight = TextHeight("A") + (Float(5)/600)*GHeight

	End Method
	
	Method Clear()
		BannerFlow.Clear()
		Back.Clear()
		Completed.Clear()
		Rating.Clear()
		Info.Clear()
		FreeEntity(CoverPivot)
		ListRemove(UpdateTypeList , Self)	
		Completed = Null
		BannerFlow = Null 
		Rating = Null
		Info = Null 
		Back = Null
		Screen.Clear()
		Screen = Null 		
	End Method 
	
	Method Update()
		If OldCurrentGamePos <> CurrentGamePos Then
			UpdateCover()		
			SetImageFont(MainTextFont)
			TextList = GetTextList(GameNode.Desc)	
			OldCurrentGamePos = CurrentGamePos
		EndIf 
		'ScaleEntity(CoverAlphaBack , 100 , Cover.NormY + 1.2 , 0)
		'PositionEntity(CoverAlphaBack , EntityX(CoverAlphaBack) , Cover.NormY , EntityZ(CoverAlphaBack))
		Cover.Update()
		BannerFlow.Update()
		Back.Update()
		Completed.Update()
		Rating.Update()		
		Screen.Update()
	End Method
	
	Method UpdateJoy()
		If Screen.UpdateJoy() = True Then Return True			
		BannerFlow.UpdateJoy()
	End Method 
	
	Method UpdateKeyboard()
		If Screen.UpdateKeyboard() = True Then Return True	
		If KeyHit(KEYBOARD_BIGCOVER) Then
			LoadBigCover()
			Return True 
		EndIf
		If KeyHit(KEYBOARD_FLIPCOVER) Then
			FlipCover()
			Return True
		EndIf			
		If KeyDown(KEYBOARD_DOWN) Then
			If MilliSecs() - KeyDelayTimer > 100 
				CurrentGamePos = CurrentGamePos + 1
				KeyDelayTimer = MilliSecs()
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1 'CurrentGamePos - GameArrayLen
			EndIf
			Return True 
		EndIf
		If KeyDown(KEYBOARD_UP) Then
			If MilliSecs() - KeyDelayTimer > 100 
				CurrentGamePos = CurrentGamePos - 1
				KeyDelayTimer = MilliSecs()		
				If CurrentGamePos < 0 Then CurrentGamePos = 0'CurrentGamePos + GameArrayLen
			EndIf
			Return True 
		EndIf
		Return False 	
		'BannerFlow.UpdateKeyboard()	
	End Method
	
	Method UpdateMouse()
		If Cover.MouseOver() = True Then
			If MouseClick = 1 Then
				LoadBigCover()
				Return True 									
			ElseIf MouseClick = 2 Then
				FlipCover()
				Return True					
			EndIf 
		EndIf		
		If Completed.UpdateMouse() = True Then Return True
		If Rating.UpdateMouse() = True Then Return True				
		If Screen.UpdateMouse() = True Then Return True
		BannerFlow.UpdateMouse()
		Return False 
	End Method 
	
	Method Max2D()
		If BigCover <> 1 Then 
			Completed.Max2D()
			Rating.Max2D()	
			Screen.Max2D()	
			Local DescLine:String
			Local a:Int = 1
			SetImageFont(NameFont)
			If WideScreen = 1 Then
				DrawText(GameNode.Name , GWidth * (Float(460) / 800) - ( TextWidth(GameNode.Name) / 2) , GHeight * (Float(420) / 600) )
			Else
				DrawText(GameNode.Name , GWidth * (Float(475) / 800) - ( TextWidth(GameNode.Name) / 2) , GHeight * (Float(420) / 600) )
			EndIf 
			SetImageFont(MainTextFont)
			
			For DescLine = EachIn TextList
				If a > 3 Then
					If WideScreen = 1 Then
						DrawText(DescLine + "..." , GWidth * (Float(140) / 800) , GHeight * (Float(440) / 600) + (a * FontHeight) )	
					Else
						DrawText(DescLine + "..." , GWidth * (Float(200) / 800) , GHeight * (Float(440) / 600) + (a * FontHeight) )	
					EndIf 
					Exit
				EndIf
				If WideScreen = 1 Then
					DrawText(DescLine , GWidth * (Float(140) / 800) , GHeight * (Float(440) / 600) + (a * FontHeight) )	
				Else
					DrawText(DescLine , GWidth * (Float(200) / 800) , GHeight * (Float(440) / 600) + (a * FontHeight) )	
				EndIf 
				a = a + 1
			Next			
		EndIf 		
	End Method
	
	Method GetTextList:TList(Desc:String)
		Desc = Desc + " "
		Local List:TList = CreateList()
		Local b:Int = 1
		Local LastSpace:Int = 1
		For a = 1 To Len(Desc)
			If Mid(Desc , a , 1) = " " Then
				
				If (TextWidth(Mid(Desc , b , a - b) ) > GWidth*(Float(550)/800) And WideScreen = 0) Or (TextWidth(Mid(Desc , b , a - b) ) > GWidth*(Float(620)/800) And WideScreen = 1) Then
					ListAddLast(List , Mid(Desc , b , LastSpace - b) )
					b = LastSpace + 1
					a = LastSpace + 1
				EndIf
				LastSpace = a
			EndIf
		Next
		ListAddLast(List , Mid(Desc , b , LastSpace - b) )
		Return List
	End Method
	
	
End Type

