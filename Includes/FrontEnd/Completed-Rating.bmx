Type ScreenShotButtonType Extends GeneralType
	Field CameraImage:TImage
	Field CameraSImage:TImage	

	Field BackImage:TImage
	Field BackSImage:TImage	
	
	Field TempVal1:Int 
	
	Field DrawX:Int
	Field DrawY:Int
	
	Field Selected:Int = 0
	
	Field Mode:Int = 0
	Field Show:Int = 1
		
	Method Clear()
		CameraImage = Null
		CameraSImage = Null	
		BackImage = Null
		BackSImage = Null	
	End Method 	
		
	Method Init()
		
		TempVal1 = GWidth * (Float(30) / 800)
		
		Local CameraPix:TPixmap = LoadPixmap(RESFOLDER + "ScreenShot_UnSelected.png")
		CameraPix = ResizePixmap(CameraPix , TempVal1 , TempVal1 )
		CameraImage = LoadImage(CameraPix)
		If CameraImage = Null Then RuntimeError "ScreenShot_UnSelected.png Missing!"
		
		Local CameraSPix:TPixmap = LoadPixmap(RESFOLDER + "ScreenShot.png")
		CameraSPix = ResizePixmap(CameraSPix , TempVal1 , TempVal1 )
		CameraSImage = LoadImage(CameraSPix)		
		If CameraSImage = Null Then RuntimeError "ScreenShot.png Missing!"
		
		
		Local BackPix:TPixmap = LoadPixmap(RESFOLDER + "Back_UnSelected.png")
		BackPix = ResizePixmap(BackPix , TempVal1 , TempVal1 )
		BackImage = LoadImage(BackPix)
		If BackImage = Null Then RuntimeError "Back_UnSelected.png Missing!"
		
		Local BackSPix:TPixmap = LoadPixmap(RESFOLDER + "Back.png")
		BackSPix = ResizePixmap(BackSPix , TempVal1 , TempVal1 )
		BackSImage = LoadImage(BackSPix)		
		If BackSImage = Null Then RuntimeError "Back.png Missing!"
	End Method
	
	Method Max2D()
		If ShowScreenButton = True Then 
			If Self.Show = True Then
				If Self.Selected = True Then
					If Mode = 0 Then 
						DrawImage(CameraSImage , DrawX ,  DrawY )
					ElseIf Mode = 1 Then 
						DrawImage(BackSImage , DrawX ,  DrawY )
					EndIf 
				Else
					If Mode = 0 Then 
						DrawImage(CameraImage , DrawX ,  DrawY )
					ElseIf Mode = 1 Then 
						DrawImage(BackImage , DrawX ,  DrawY )
					EndIf 
				EndIf
			EndIf 
		EndIf 
	End Method 
	
	Method UpdateMouse()
		If ShowScreenButton = True Then 
			If Self.Selected = True Then
				If MouseClick = 1 Then 
					If Mode = 0 Then 
						ChangeInterface(7,1,0)
					Else
						ChangeInterface(CurrentInterfaceNumber,1,0)
					EndIf 
					Return True
				EndIf
			EndIf 
		EndIf
		Return False
	End Method
	
	Method UpdateKeyboard()
		If FilterMenuEnabled <> 1 And MenuActivated <> 1  Then 
			If KeyHit(KEYBOARD_SCREEN) Then 
				If Self.Show = True Then 
					If Mode = 0 Then 
						ChangeInterface(7,1,0)
					Else
						ChangeInterface(CurrentInterfaceNumber,1,0)
					EndIf
				EndIf 
				'Flush key by returning True
				Return True
			EndIf
		EndIf 
		Return False
	End Method
	
	Method UpdateJoy()
		If FilterMenuEnabled <> 1 And MenuActivated <> 1 Then 
			For J=0 To JoyCount()-1 
				If JoyHit(JOY_SCREEN,J) Then 
					If Self.Show = True Then 
						If Mode = 0 Then 
							ChangeInterface(7,1,0)
						Else
							ChangeInterface(CurrentInterfaceNumber,1,0)
						EndIf 
					EndIf
					'Flush key by returning True
					Return True
				EndIf
				Return False
			Next 	
		EndIf 
	End Method 
	
		
	Method Update()
		If GameNode.ScreenShotNumber = 0 Then 
			Self.Show = False 
		Else
			Self.Show = True
		EndIf 
		
		If Self.Show = True Then 
			If MouseX() > DrawX And MouseX() < DrawX + TempVal1 And MouseY() > DrawY And MouseY() < DrawY + TempVal1 Then
				Self.Selected = True
			Else
				Self.Selected = False 
			EndIf	
		EndIf
	End Method
	
End Type 

Type CompletedType
	Field Ticked:TImage
	Field UnTicked:TImage
	Field GrayTicked:TImage
	Field Selected:Int
	
	Field x:Int
	Field y:Int
	
	Method Clear()
		Ticked = Null 
		UnTicked = Null
		GrayTicked = Null
	End Method 
	
	Method Init(setx:Int = -1 , sety:Int = -1 , center:Int = 0)
		TickedPix:TPixmap = LoadPixmap(RESFOLDER + "Tick.png")
		TickedPix = ResizePixmap(TickedPix , GWidth*(Float(25)/800) , GHeight*(Float(25)/600) )
		Ticked = LoadImage(TickedPix)				
		If Ticked = Null Then RuntimeError "Tick.png Missing!"	
		
		UnTickedPix:TPixmap = LoadPixmap(RESFOLDER + "UnTick.png")
		UnTickedPix = ResizePixmap(UnTickedPix , GWidth*(Float(25)/800) , GHeight*(Float(25)/600) )
		UnTicked = LoadImage(UnTickedPix)				
		If UnTicked = Null Then RuntimeError "UnTick.png Missing!"	

		GrayTickedPix:TPixmap = LoadPixmap(RESFOLDER + "GreyTick.png")
		GrayTickedPix = ResizePixmap(GrayTickedPix , GWidth*(Float(25)/800) , GHeight*(Float(25)/600) )
		GrayTicked = LoadImage(GrayTickedPix)				
		If GrayTicked = Null Then RuntimeError "GreyTick.png Missing!"					
		
		If setx = -1 Then 
			x = GWidth * (1 - Float(150) / 800)
		Else
			If Center = True Then
						
				x = setx - 	GetWidth()		
			Else
				x = setx			
			EndIf
		EndIf
		If sety = -1 Then 
			y = GHeight - GHeight * (Float(40) / 600)
		Else
			y = sety
		EndIf
	End Method
	
	Method GetWidth()
		SetImageFont(MenuButtonFont)	
		Return (Ticked.Width + TextWidth("Incomplete"))/2
	End Method
	
	Method Max2D()
		SetImageFont(MenuButtonFont)
		SetColor 255 , 255 , 255
		SetAlpha(1)
		If (GameNode.Completed = True And Selected = False) Or (GameNode.Completed = False And Selected = True) Then
			If Selected = True Then
				SetColor 180 , 180 , 180
				DrawImage(GrayTicked , x , y - Ticked.Height/2 )
			Else
				SetColor 255 , 255 , 255
				DrawImage(Ticked , x , y - Ticked.Height/2 )
			EndIf 
			
			DrawText("Complete" , x + Ticked.Width , y - TextHeight("Complete")/2 )
		Else
			If Selected = True Then
				SetColor 180,180,180
			Else
				SetColor 255,255,255
			EndIf 		
			DrawImage(UnTicked , x , y - UnTicked.Height/2 )
			DrawText("Incomplete" , x + UnTicked.Width , y - TextHeight("Incomplete")/2 )
		EndIf 
	End Method
	
	Method UpdateMouse()
		If MouseClick = 1 And Selected = True Then
			If GameNode.Completed = True Then
				GameNode.Completed = False
			Else
				GameNode.Completed = True
			EndIf
			GameNode.WriteUserData()
			
			Return True
		EndIf
		Return False
	End Method 
	
	Method Update()
		If MouseY() > y - Ticked.Height / 2 And MouseY() < y + Ticked.Height / 2 And..
		MouseX() > x And MouseX() < x + UnTicked.Width + TextWidth("Incomplete") Then
			Selected = True
		Else
			Selected = False
		EndIf
	End Method 
		
End Type


Type RatingType
	Field Half:TImage
	Field Full:TImage
	Field Empty:TImage
	Field Grey:TImage
	
	Field Selected:Int
	
	Field x:Int
	Field y:Int
	
	Method Clear()
		Half = Null
		Full = Null
		Empty = Null
		Grey = Null 		
	End Method 
	
	Method Init(setx:Int = - 1 , sety:Int = - 1 , center:Int = 0)
		temp1:Int = GWidth * (Float(25) / 800)
		temp2:Int = GHeight*(Float(25)/600)
		
		HalfPix:TPixmap = LoadPixmap(RESFOLDER + "Star_half.png")
		HalfPix = ResizePixmap(HalfPix , temp1 , temp2 )
		Half = LoadImage(HalfPix)				
		If Half = Null Then RuntimeError "Star_half.png Missing!"	
		
		EmptyPix:TPixmap = LoadPixmap(RESFOLDER + "Star_Empty.png")
		EmptyPix = ResizePixmap(EmptyPix ,  temp1 , temp2 )
		Empty = LoadImage(EmptyPix)				
		If Empty = Null Then RuntimeError "Star_Empty.png Missing!"	
		
		FullPix:TPixmap = LoadPixmap(RESFOLDER + "Star.png")
		FullPix = ResizePixmap(FullPix ,  temp1 , temp2 )
		Full = LoadImage(FullPix)				
		If Full = Null Then RuntimeError "Star.png Missing!"			

		GreyPix:TPixmap = LoadPixmap(RESFOLDER + "Star_Grey.png")
		GreyPix = ResizePixmap(GreyPix ,  temp1 , temp2 )
		Grey = LoadImage(GreyPix)				
		If Grey = Null Then RuntimeError "Star_Grey.png Missing!"					
		
		If setx = -1 Then 
			x = GWidth * (1 - Float(150) / 800)
		Else
			If Center = True Then 
				x = setx - (Float(2.5)*Full.Width)			
			Else
				x = setx			
			EndIf
		EndIf
		If sety = -1 Then 
			y = GHeight - GHeight * (Float(40) / 600)
		Else
			y = sety
		EndIf
		
	End Method
	
	Method Max2D()
		SetColor 255 , 255 , 255
		SetAlpha(1)
		Local Rat:Int 
		If Selected <> - 1 Then
			Rat = Selected
		Else
			Rat = Int(GameNode.Rating)
		EndIf
		
		For a=0 To Floor(Float(Rat)/2) -1
			DrawImage(Full , x + (Float(a) * Full.Width) , y - Full.Height/2)
		Next
		b = Floor(Float(Rat)/2)
		If Int(Rat) Mod 2 = 1 Then
			DrawImage(Half , x + (Float(b) * Full.Width) , y - Full.Height/2)
			b = b + 1
		EndIf
		For c = b To 4
			'If Int(Rat) = 0 Then
				'DrawImage(Grey , x + (Float(c) * Full.Width) , y - Full.Height/2)
			'else
				DrawImage(Empty , x + (Float(c) * Full.Width) , y - Full.Height/2)
			'EndIf 
		Next 
	End Method
	
	Method UpdateMouse()
		If MouseClick = 1 And Selected > 0 Then
			GameNode.Rating = Selected
			GameNode.WriteUserData()
			Return True 
		EndIf
		Return False
	End Method 
	
	Method Update()
		If MouseY() > y - Full.Height And MouseY() < y + Full.Height Then
			Selected = (Float(MouseX() - x )) / (Full.Width/2) 
			If Selected < 1 Then
				Selected = -1
			EndIf
			If Selected > 10 Then
				Selected = - 1
			EndIf
		Else
			Selected = -1
		EndIf 
	End Method 
		
End Type 