
Type InfoType Extends GeneralType
	Field InfoImage:TImage
	Field InfoSImage:TImage	
	
	Field UpImage:TImage
	Field UpSImage:TImage	
	
	Field DownImage:TImage	
	Field DownSImage:TImage	
		
	Field InfoSelected:Int	
	Field UpSelected:Int
	Field DownSelected:int 	

	Field TempVal1:Int
	Field TempVal2:Int 	
	Field TempVal3:Int
	
	Field InfoActive:Int 	
	Field BackAlpha:Float
	
	Field TextList:TList
	Field FontHeight2:Int
	Field FontHeight:Int
	Field Genre:String
	
	Field Height40Scaled:Int
	Field TextScrolling:Int
	Field TextY:Float
	Field TextStartTime:Int 
	Field StartHeight:Int
	
	Field TextScrollOverride:Int 
	
	Field initial:Int
	Field DrawX:Int
	Field DrawY:Int 
		
	Method Clear()
		InfoImage = Null
		InfoSImage = Null	
		UpImage = Null
		UpSImage = Null	
		DownImage = Null
		DownSImage = Null	
		TextList = Null
		ListRemove(UpdateTypeList , Self)			
	End Method 	
		
	Method Init()
		InfoActive = False
		TextScrollOverride = False 
		initial = True 
		TempVal1 = GWidth * (Float(30) / 800)
		TempVal2 = GWidth * (Float(20) / 800)
		TempVal3 = GHeight - (GHeight * (Float(20) / 600) )	
		
		DownSelected = False
		UpSelected = False
		
		Height40Scaled = GHeight * (Float(40)/600)

		InfoSelected = False		
		InfoPix:TPixmap = LoadPixmap(RESFOLDER + "Info_UnSelected.png")
		InfoPix = ResizePixmap(InfoPix , TempVal1 , TempVal1 )
		InfoImage = LoadImage(InfoPix)
		If InfoImage = Null Then RuntimeError "Info_UnSelected.png Missing!"
		
		InfoSPix:TPixmap = LoadPixmap(RESFOLDER + "Info.png")
		InfoSPix = ResizePixmap(InfoSPix , TempVal1 , TempVal1 )
		InfoSImage = LoadImage(InfoSPix)		
		If InfoSImage = Null Then RuntimeError "Info.png Missing!"
		
		UpSPix:TPixmap = LoadPixmap(RESFOLDER + "Up.png")
		UpSPix = ResizePixmap(UpSPix , TempVal2 , TempVal2 )
		UpSImage = LoadImage(UpSPix)		
		If UpSImage = Null Then RuntimeError "Up.png Missing!"
		
		UpPix:TPixmap = LoadPixmap(RESFOLDER + "Up_UnSelected.png")
		UpPix = ResizePixmap(UpPix , TempVal2 , TempVal2 )
		UpImage = LoadImage(UpPix)
		If UpImage = Null Then RuntimeError "Up_UnSelected.png Missing!"		
		
		DownSPix:TPixmap = LoadPixmap(RESFOLDER + "Down.png")
		DownSPix = ResizePixmap(DownSPix , TempVal2 , TempVal2 )
		DownSImage = LoadImage(DownSPix)		
		If DownSImage = Null Then RuntimeError "Down.png Missing!"
		
		DownPix:TPixmap = LoadPixmap(RESFOLDER + "Down_UnSelected.png")
		DownPix = ResizePixmap(DownPix , TempVal2 , TempVal2 )
		DownImage = LoadImage(DownPix)
		If InfoImage = Null Then RuntimeError "Down_UnSelected.png Missing!"						
		ListAddFirst(UpdateTypeList , Self)	

	End Method

	Method Max2D()
		Local DescLine:String
		Local a:Int = 0,b:Int = 0
		Local Gen:String
		If InfoActive = True Then
			SetColor(0,0,0)
			SetAlpha(0.95)
			DrawRect(0,0,GWidth,GHeight) 
			SetColor(255,255,255)
			SetAlpha(BackAlpha)		
			
			SetImageFont(NameFont)
			DrawText(GameNode.Name , (GWidth - TextWidth(GameNode.Name) ) / 2 , Height40Scaled)
			SetImageFont(MainTextFont)
			
			If initial = True Then
				TextList = GetTextList(GameNode.Desc)
				FontHeight = TextHeight("A") + (Float(5)/600)*GHeight
				FontHeight2 = FontHeight + (Float(5)/600)*GHeight
				
				Genre = ""
				TextScrolling = False
				TextY = 0
				For Gen = EachIn GameNode.Genres
					Genre = Genre + Gen + "/"
				Next	
				Genre = Left(Genre , Len(Genre) - 1)
				TextStartTime = MilliSecs()
			EndIf
			
			For DescLine = EachIn TextList
				If TextY + 2*Height40Scaled + (a * FontHeight) > 5*GHeight / 8 Then
					TextScrolling = True
					b = 1
					Exit
				EndIf
				If TextY + 2 * Height40Scaled + (a * FontHeight) => 2 * Height40Scaled And ..
				TextY + 2*Height40Scaled + (a * FontHeight) =< (5*GHeight / 8) -  FontHeight Then
					DrawText(DescLine , TempVal1 , TextY + 2 * Height40Scaled + (a * FontHeight) )				
				ElseIf TextY + 2 * Height40Scaled + (a * FontHeight) => 1.75* Height40Scaled And ..
				TextY + 2*Height40Scaled + (a * FontHeight) =< (5*GHeight / 8) -  FontHeight Then
					SetAlpha(4*(TextY + 0.25*Height40Scaled + (a * FontHeight))/Height40Scaled)
					DrawText(DescLine , TempVal1 , TextY + 2 * Height40Scaled + (a * FontHeight) )
					SetAlpha(1)
				ElseIf TextY + 2 * Height40Scaled + (a * FontHeight) > (5 * GHeight / 8) - FontHeight
					SetAlpha((TextY + 2*Height40Scaled + (a * FontHeight)-5*GHeight / 8)/(-FontHeight))
					DrawText(DescLine , TempVal1 , TextY + 2 * Height40Scaled + (a * FontHeight) )
					SetAlpha(1)
					b = 1					
				EndIf
				a = a + 1
			Next	
			If b <> 1 Then
				TextScrolling = False
			EndIf 				
			If TextScrolling = True Then
				If MilliSecs() - TextStartTime > 10000 Then
						TextY = TextY - TextScrollRate * SpeedRatio		
				EndIf
			EndIf 
			If initial = True Then		
				StartHeight = (a + 1) * FontHeight
				initial = False
			EndIf	
			a = 0
			DrawLine(TempVal1 , 2*Height40Scaled + ( StartHeight ) , GWidth - 30 , 2*Height40Scaled + ( StartHeight ) )
			a = a + 1
			DrawText("Genre:   " + Genre , 2*TempVal1 , 2*Height40Scaled + StartHeight + (a * FontHeight2) )
			DrawText("Certificate:   " + GameNode.Cert , (GWidth / 2)+TempVal1 , 2*Height40Scaled + StartHeight + (a*FontHeight2) )	
			a = a + 1
			DrawText("Developer:   "+GameNode.Dev, 2*TempVal1 , 2*Height40Scaled + StartHeight + (a*FontHeight2) )			
			DrawText("Publisher:   " + GameNode.Pub , (GWidth / 2)+TempVal1 , 2*Height40Scaled + StartHeight + (a*FontHeight2) )
			a = a + 1
			DrawText("Platform:   " + GlobalPlatforms.GetPlatformByID(GameNode.PlatformNum).Name , 2 * TempVal1 , 2 * Height40Scaled + StartHeight + (a * FontHeight2) )	
			DrawText("Released:   " + GameNode.ReleaseDate , (GWidth / 2) + TempVal1 , 2*Height40Scaled + StartHeight + (a * FontHeight2) )
			a = a + 1
			DrawText("Players:   " + GameNode.Players , 2 * TempVal1 , 2 * Height40Scaled + StartHeight + (a * FontHeight2) )
			DrawText("Co-op:   " + GameNode.CoOp , ( GWidth / 2) + TempVal1 , 2*Height40Scaled + StartHeight + (a * FontHeight2) )
			
			SetColor 255 , 255 , 255
			If TextScrolling <> False Or TextY <> 0 Then 
				If UpSelected = True And MenuActivated = False Then
					DrawImage(UpSImage , GWidth - 2*TempVal2 ,  2 * Height40Scaled)
				Else
					DrawImage(UpImage , GWidth - 2*TempVal2 ,  2 * Height40Scaled )
				EndIf
				If DownSelected = True And MenuActivated = False Then
					DrawImage(DownSImage , GWidth - 2*TempVal2 ,  StartHeight )
				Else
					DrawImage(DownImage , GWidth - 2*TempVal2 ,  StartHeight )
				EndIf
			EndIf
		EndIf
		SetColor 255 , 255 , 255
		
		If ShowInfoButton = True Then
			If InfoSelected = True And MenuActivated = False Then
				If InfoActive = True Then	
					DrawImage(InfoSImage , TempVal2 , TempVal3 - InfoSImage.Height )
				Else
					DrawImage(InfoSImage , DrawX , DrawY)
				EndIf 
				'TempVal2 , TempVal3 - InfoSImage.Height )
			Else
				If InfoActive = True Then
					DrawImage(InfoImage , TempVal2 ,  TempVal3 - InfoImage.Height )
				Else
					DrawImage(InfoImage , DrawX , DrawY)
				EndIf 
				'TempVal2 ,  TempVal3 - InfoImage.Height )
			EndIf
		EndIf 

		
	
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
	
	Method UpdateJoy()
		For J=0 To JoyCount()-1 
			If InfoActive = True Then

				If (Tol(JoyHat(J),0,0.1) Or Tol(JoyY(J),-1,0.4) ) Then
					TextY = TextY + 5
					If TextY > 0 Then TextY = 0
					TextStartTime = MilliSecs() 
				EndIf
				If (Tol(JoyHat(J),0.5,0.1) Or Tol(JoyY(J),1,0.4) ) Then
					If TextScrolling = True Then 
						TextY = TextY - 5
					EndIf
					TextStartTime = MilliSecs()
				EndIf			
			
				If JoyHit(JOY_INFO,J) Then
					InfoSelected = False 
					InfoActive = False
					FlushJoy()			
					Return True 
				EndIf
			Else
				If JoyHit(JOY_INFO,J) Then
					InfoSelected = False 
					InfoActive = True
					BackAlpha = 0
					Return True 			
				EndIf		
			EndIf 
		Next 
	End Method 

	Method UpdateKeyboard()
		If InfoActive = True Then
			
			If KeyDown(KEYBOARD_UP) Then
				TextY = TextY + 5
				If TextY > 0 Then TextY = 0
				TextStartTime = MilliSecs() 
			EndIf
			If KeyDown(KEYBOARD_DOWN) Then
				If TextScrolling = True Then 
					TextY = TextY - 5
				EndIf
				TextStartTime = MilliSecs()
			EndIf
			If KeyHit(KEYBOARD_INFO) Then
				InfoSelected = False 
				InfoActive = False
				FlushKeys()			
			EndIf
			If KeyHit(KEYBOARD_ESC) Then
				InfoSelected = False 
				InfoActive = False
				FlushKeys()
			EndIf				
			Return True
		Else
			If KeyHit(KEYBOARD_INFO) Then
				InfoSelected = False 
				InfoActive = True
				BackAlpha = 0
				Return True 			
			EndIf
		EndIf 
	End Method
	
	Method UpdateMouse()
		If InfoActive = True Then 
			If InfoSelected = True And MouseClick = 1 Then
				InfoSelected = False 
				InfoActive = False
				FlushKeys()
			EndIf			
			If UpSelected = True And MouseDown(1) Then
				TextY = TextY + 5
				If TextY > 0 Then TextY = 0
				TextStartTime = MilliSecs() 				
			EndIf
			If DownSelected = True And MouseDown(1) Then
				If TextScrolling = True Then 
					TextY = TextY - 5
				EndIf
				TextStartTime = MilliSecs()				
			EndIf

			Return True
		Else
			If InfoSelected = True And MouseClick = 1 Then
				InfoSelected = False 
				InfoActive = True
				BackAlpha = 0
				FlushKeys()
				Return True 
			EndIf			
		EndIf
	End Method	
	
	Method Update()
		If MenuActivated = True Then
			InfoActive = False
		EndIf 
		If InfoActive = True Then	
			If MouseX() > TempVal2 And MouseX() < TempVal2 + InfoImage.Width And ..
			MouseY() > TempVal3 - InfoImage.Height And MouseY() < TempVal3 Then
				InfoSelected = True
			Else
				InfoSelected = False 
			EndIf	
			If MouseX() > GWidth - 2 * TempVal2 And MouseX() < GWidth - 0.5 * TempVal2 Then
				If MouseY() > StartHeight And MouseY() < StartHeight + TempVal2 Then
					DownSelected = True
				Else
					DownSelected = False
				EndIf
				If MouseY() > 2 * Height40Scaled And MouseY() < 2 * Height40Scaled + TempVal2 Then
					UpSelected = True
				Else
					UpSelected = False
				EndIf
				
			Else
				DownSelected = False
				UpSelected = False
			EndIf
					
			If BackAlpha < 0.9
				BackAlpha = BackAlpha + 0.05*SpeedRatio
			Else
				BackAlpha = 0.95
			EndIf		
		Else
			If ShowInfoButton = True Then 
				If MouseX() > DrawX And MouseX() < DrawX + InfoImage.Width And ..
				MouseY() > DrawY And MouseY() < DrawY + InfoImage.Height Then
					InfoSelected = True
				Else
					InfoSelected = False 
				EndIf	
				initial = True 
			EndIf 
		EndIf
	End Method 		
End Type