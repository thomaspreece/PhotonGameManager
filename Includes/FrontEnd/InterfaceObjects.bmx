Type ScreenType
	Field Mesh:TMesh
	
	Field Position:Int
	Field TexturePath:String 
	
	Field x:Float
	Field y:Float
	Field z:Float
	Field Rotx:Float
	Field Roty:Float
	Field Rotz:Float
	Field NormY:Float
	Field GlobalPosition:Int = False 
	
	Field Textured:Int
	Field Tex:TTexture
			
	Field Positioned:Int = False
	Field OldCurrentGamePos:Int 
	Field ResetCoverPosition:Int = False 

	Method Init(Parent:TPivot)
		Mesh = CreateCover(0 , Parent)
		Textured = False
		EntityFX Mesh , 1
'		CoverNum = -1
		ScaleEntity Mesh , 0.75 , 1 , 0 
		'x = EntityX(Mesh)
		'y = EntityY(Mesh)
		'z = EntityZ(Mesh)
		'Rotx = EntityPitch(Mesh)
		'Roty = EntityYaw(Mesh)
		'Rotz = EntityRoll(Mesh)
	End Method
	
	Method MouseOver()
		Local Box:Float[4]
		Box = GetBoundingBox(Mesh)
		If MouseX() > Box[0] And MouseX() < Box[2] And MouseY() > Box[1] And MouseY() < Box[3] Then
			Return True
		Else
			Return False
		EndIf
	End Method 
	
	Method Update()
		LoadCoverTexture()
		
		If LowProcessor = False Then
			
			'If Positioned = True And OldCurrentGamePos <> CurrentGamePos Then
			'	Positioned = False
			'EndIf
			
			'If (x - EntityX(Mesh , GlobalPosition) ) < 0.05 And (y - EntityY(Mesh , GlobalPosition) ) < 0.05 And (z - EntityZ(Mesh , GlobalPosition) ) < 0.05 Then
			'	If (Rotx - EntityPitch(Mesh) ) < 0.1 And (Roty - EntityYaw(Mesh) ) < 0.1 And (Rotz - EntityRoll(Mesh) ) < 0.1 Then
			'		Positioned = True
			'	EndIf 
			'EndIf 
				
			'RotateEntity(Mesh , 0 , 0 , 0 )
			MoveEntity(Mesh , ((x - EntityX(Mesh,GlobalPosition) ) / 10^(1/SpeedRatio)), ((y - EntityY(Mesh,GlobalPosition) ) / 2^(1/SpeedRatio)) , ((z - EntityZ(Mesh,GlobalPosition) ) / 2^(1/SpeedRatio)) )
		EndIf 
		
		Rem
		If GameArrayLen <> 0 Then 
			LoadCoverTexture()
		EndIf
		If Positioned = False Then 
			OldCurrentGamePos = CurrentGamePos
		EndIf 
		
		
		EndRem
	End Method
	
	Method LoadCoverTexture()
		Local Hi:Float
		Local BHi:Float
		
		If EntityInView(Mesh , Camera)>0 Then
			If Textured = False Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash + TexturePath) = 1 Then
					If ListContains(ProcessedTextures , GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ TexturePath) = True Then
						Tex = LoadPreloadedTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ TexturePath)
						If Tex <> Null
							EntityTexture(Mesh , Tex)

							LockMutex(TTexture.Mutex_tex_list)
							Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
							'Self.y = Hi-1
							UnlockMutex(TTexture.Mutex_tex_list)
														
							ScaleEntity(Mesh , 0.75 , Hi , 0)
							NormY = Hi - 1
							'Repositioning done via hack flag - ResetCoverPosition which is updated via CoverWallType-Update()							
							ResetCoverPosition = True 

							LockMutex(TTexture.Mutex_tex_list)
							ListAddLast(InUseTextures , tex.file)
							UnlockMutex(TTexture.Mutex_tex_list)
							Textured = True 
						EndIf	
					Else
						Tex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
						If Tex <> Null Then
							EntityTexture(Mesh , Tex)
							LockMutex(TTexture.Mutex_tex_list)
							Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth) /2
							'Self.y = Hi-1
							UnlockMutex(TTexture.Mutex_tex_list)
							ScaleEntity(Mesh , 0.75 , Hi , 0)
							'PositionEntity(Mesh , EntityX(Mesh) , EntityY(Mesh) + Hi - 1 , EntityZ(Mesh) )	
							NormY = Hi - 1
							
							ResetCoverPosition = True 
							'y = EntityY(Mesh) + NormY
							Textured = False
						Else
							RuntimeError "Loading.jpg Missing!"
						EndIf							
					EndIf
				Else
					Tex = LoadPreloadedTexture(RESFOLDER + "NoCover.jpg")	
					If Tex <> Null Then
						EntityTexture(Mesh , tex)
						LockMutex(TTexture.Mutex_tex_list)
						Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth) /2
						'Self.y = Hi-1
						UnlockMutex(TTexture.Mutex_tex_list)
						ScaleEntity(Mesh , 0.75 , Hi , 0)
						'PositionEntity(Mesh , EntityX(Mesh) , EntityY(Mesh) + Hi - 1 , EntityZ(Mesh) )
						NormY = Hi - 1
						'y = EntityY(Mesh) + NormY
						
						'LockMutex(TTexture.Mutex_tex_list)
						'ScaleEntity(Mesh , 0.75 , Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth) , 0)
						'UnlockMutex(TTexture.Mutex_tex_list)
						Textured = True
					Else
						RuntimeError "NoCover.jpg Missing!"
					EndIf
				EndIf	

				
			EndIf
			
		Else
			If LowMemory = True Then
				If Textured = True Then
					LockMutex(TTexture.Mutex_tex_list)
					ListRemove(InUseTextures , Tex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					Tex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
					If Tex <> Null Then
						EntityTexture(Mesh , Tex)
						Textured = False
					Else
						RuntimeError "Loading.jpg Missing!"
					EndIf		
				EndIf			
			EndIf
		EndIf 

	End Method
	
	
	Method Clear()
		Rem
		FreeEntity(Mesh)
		LockMutex(TTexture.Mutex_tex_list)
		If Tex <> Null Then
			ListRemove(InUseTextures , Tex.file)
		EndIf
		UnlockMutex(TTexture.Mutex_tex_list)
		EndRem
	End Method
	
End Type




Type CoverWallType
	Field Covers:CoverType2[GameArrayLen]
	Field Parent:TPivot
	Field itemsPerRow:Int 
	Field OldCurrentGamePos:Int = - 1
	Field BigCover:Int = 0
	
	Field BigCoverEnabled:Int 
	Field CoverFlipEnabled:Int 

	Method FlipCover()
		If Covers[CurrentGamePos].Roty > 90 Then
			Covers[CurrentGamePos].Roty = 0
		ElseIf Covers[CurrentGamePos].Roty < 90 Then
			Covers[CurrentGamePos].Roty = 180
		EndIf		
	End Method
	
	Method LoadBigCover()
		Local BTex:TTexture		
		If BigCover = 0 Then
			Covers[CurrentGamePos].GlobalPosition = True
			Covers[CurrentGamePos].y = Covers[CurrentGamePos].NormY

			If WideScreen = 1 Then
				Covers[CurrentGamePos].z = - 2
			Else
				Covers[CurrentGamePos].z = - 2.3
			EndIf
			BigCover = 1		
			If Covers[CurrentGamePos].Roty = 180 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Front_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash +"Front_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Covers[CurrentGamePos].Mesh , BTex)
				EndIf
			ElseIf Covers[CurrentGamePos].Roty = 0 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Back_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Back_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Covers[CurrentGamePos].BackMesh , BTex)
				EndIf					
			EndIf
		Else
			Covers[CurrentGamePos].z = Pos(Covers[CurrentGamePos].Position , 3 , Covers[CurrentGamePos].NormY)
			Covers[CurrentGamePos].y = Pos(Covers[CurrentGamePos].Position , 2 , Covers[CurrentGamePos].NormY)
			Covers[CurrentGamePos].GlobalPosition = False 
			BigCover = 0
		EndIf		
	End Method

	Method UpdateMouse()
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
			For a = 0 To GameArrayLen - 1
				If Covers[a].MouseOver() = True
					ListAddLast(ClickCoverList , String(a) )
				EndIf
			Next	
			If ClickCoverList.Count() > 0 Then
				If ListContains(ClickCoverList , String(CurrentGamePos) ) Then
					If BigCoverEnabled = True Then 
						LoadBigCover()
					EndIf 
				Else
					For b = EachIn ClickCoverList
						a = Int(String(b))
						If a > CurrentGamePos Then
							If a < SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf
						ElseIf a < CurrentGamePos Then
							If a > SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf						
						EndIf
					Next
					CurrentGamePos = SelectedCover
				EndIf	
			EndIf
			Return True 
		EndIf
		If MouseClick = 2 Then
			MouseClick = 0
			If CoverFlipEnabled = True Then 
				FlipCover()
			EndIf 
			Return True 
		EndIf		
		If MouseSwipe = 1 Then
			MouseSwipe = 0
			PrintF("You swiped mouse, X:" + String(MouseEnd[0] - MouseStart[0]) + " T:" + MouseSwipeTime)
			If CurrentGamePos = GameArrayLen - 1 Or CurrentGamePos = 0 Then DoNotStopSwipe = True 
			CurrentGamePos = CurrentGamePos + Int( ( ( (Float(MouseEnd[0] - MouseStart[0]) * 10) / GWidth) * 1000	) / MouseSwipeTime)
			If DoNotStopSwipe = False Then
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1
				If CurrentGamePos < 0 Then CurrentGamePos = 0
			Else
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = 0
				If CurrentGamePos < 0 Then CurrentGamePos = GameArrayLen - 1
			EndIf
			Return True 
		ElseIf MouseSwipe = 2 Then
			MouseSwipe = 3
			CurrentGamePos = CurrentGamePos + Int((Float(MouseX()-(GWidth/2))/ GWidth) * 6)
			
			If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1
			If CurrentGamePos < 0 Then CurrentGamePos = 0		
			Return True
		ElseIf MouseSwipe = 4 Then
			MouseSwipe = 0
			If MouseEnd[1] - MouseStart[1] > 0 Then
				If BigCoverEnabled = True Then
					LoadBigCover()		
				EndIf 
			ElseIf MouseEnd[1] - MouseStart[1] < 0
				If CoverFlipEnabled = True Then 
					FlipCover()
				EndIf 
			EndIf
			Return True
		EndIf
		Return False 
	End Method

	
	Method Init()
		itemsPerRow = Max(Ceil(Float(GameArrayLen) / 5) , 5)
		
		Parent = CreatePivot()
		PositionEntity Parent , 0 , 0 , 2
		
		For a = 0 To GameArrayLen - 1
			Covers[a] = New CoverType2
			Covers[a].Position = a
			Covers[a].Reflections = False 
			Covers[a].Init(Parent)
			Covers[a].x = Pos(a , 1 , Covers[a].NormY)
			Covers[a].y = Pos(a , 2 , Covers[a].NormY)
			Covers[a].z = Pos(a , 3 , Covers[a].NormY)
			Covers[a].Rotx = 0
			Covers[a].Roty = 0
			Covers[a].Rotz = 0
			PositionEntity(Covers[a].Mesh , Covers[a].x , Covers[a].y , Covers[a].z , Covers[a].GlobalPosition)
		Next
		
		
				
	End Method
	
	Method Clear()
		For a = 0 To GameArrayLen - 1		
			Covers[a].Clear()
			Covers[a] = Null 
		Next
		FreeEntity(Parent)
	End Method 
	
	Method Update()
		For a = 0 To GameArrayLen - 1
			Covers[a].Update()
			'Hack - flag to force updated position of Cover once texture loaded
			If Covers[a].ResetCoverPosition = True Then
				'Covers[a].x = Pos(a , 1 , Covers[a].NormY)
				Covers[a].y = Pos(a , 2 , Covers[a].NormY)
				'Covers[a].z = Pos(a , 3 , Covers[a].NormY)
				PositionEntity(Covers[a].Mesh , EntityX(Covers[a].Mesh) , Covers[a].y , EntityZ(Covers[a].Mesh) )	
				Covers[a].ResetCoverPosition = False 
			EndIf 
		Next
		If OldCurrentGamePos <> CurrentGamePos Then
			BigCover = 0		
			For a = 0 To GameArrayLen - 1
				Covers[a].x = Pos(a , 1 , Covers[a].NormY)
				Covers[a].y = Pos(a , 2 , Covers[a].NormY)
				Covers[a].z = Pos(a , 3 , Covers[a].NormY)
				Covers[a].GlobalPosition = False		
			Next
			OldCurrentGamePos = CurrentGamePos
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

		If CurrentGamePos < itemsPerRow Then
			CRow = 1
			CCol = CurrentGamePos
		ElseIf CurrentGamePos < (itemsPerRow * 2) Then
			CRow = 2
			CCol = CurrentGamePos - itemsPerRow
		ElseIf CurrentGamePos < (itemsPerRow * 3) Then
			CRow = 3
			CCol = CurrentGamePos - itemsPerRow * 2
		ElseIf CurrentGamePos < (itemsPerRow * 4) Then
			CRow = 4
			CCol = CurrentGamePos -  itemsPerRow * 3
		ElseIf CurrentGamePos < (itemsPerRow * 5) Then
			CRow = 5
			CCol = CurrentGamePos - itemsPerRow *4
		EndIf
		
		Select Axis
			Case 1
				Return Float(Col-CCol)*1.6
			Case 2
				Return Float(CRow-Row)*2.4 + NormY 'OLD VALUE - 2.2
			Case 3
				If (CRow - Row) = 0 And (Col - CCol) = 0 Then
					Return - 1
				Else
					Return 0
				EndIf 
		End Select 
	End Method 
End Type

Type CoverType2
	Field Mesh:TMesh
	Field BackMesh:TMesh	
	Field ReflectMesh:TMesh
	Field BackReflectMesh:TMesh	
	Field Reflections:Int 
	
	Field Position:Int
	Field CoverNum:Int
	
	Field x:Float
	Field y:Float
	Field z:Float
	Field Rotx:Float
	Field Roty:Float
	Field Rotz:Float
	Field NormY:Float
	Field GlobalPosition:Int = False 
	
	Field Textured:Int
	Field BackTextured:Int	
	Field Tex:TTexture
	Field BackTex:TTexture
		
	Field Positioned:Int = False
	Field OldCurrentGamePos:Int 

	
	'Hack - flag to force updated position of Cover once texture loaded
	Field ResetCoverPosition:Int = False 
	
	
	Method Init(Parent:TPivot)
		Mesh = CreateCover(0 , Parent)
		BackMesh = CreateCover(0 , Mesh)
		RotateEntity(BackMesh,0,180,0)
		Textured = False
		BackTextured = False
		EntityFX Mesh , 1
		EntityFX BackMesh , 1
		'CoverNum = Position - CurrentGamePos + 4
		CoverNum = -1
		ScaleEntity Mesh , 0.75 , 1 , 0 
		x = EntityX(Mesh)
		y = EntityY(Mesh)
		z = EntityZ(Mesh)
		Rotx = EntityPitch(Mesh)
		Roty = EntityYaw(Mesh)
		Rotz = EntityRoll(Mesh)
		
		If Reflections = True Then 
			ReflectMesh = CreateCover(1,Mesh)
			MoveEntity ReflectMesh , 0 , - 2.05 , 0
			EntityFX ReflectMesh , 1
			ScaleEntity ReflectMesh , - 1 , - 1 , 0
			
			BackReflectMesh = CreateCover(1,BackMesh)
			MoveEntity BackReflectMesh , 0 , - 2.05 , 0
			EntityFX BackReflectMesh , 1
			ScaleEntity BackReflectMesh , - 1 , - 1 , 0
		EndIf
	End Method
	
	Method MouseOver()
		Local Box:Float[4]
		Box = GetBoundingBox(Mesh)
		If MouseX() > Box[0] And MouseX() < Box[2] And MouseY() > Box[1] And MouseY() < Box[3] Then
			Return True
		Else
			Return False
		EndIf
	End Method 
	
	Method Update()
		If GameArrayLen <> 0 Then 
			LoadCoverTexture()
		EndIf
		If Positioned = False Then 
			OldCurrentGamePos = CurrentGamePos
		EndIf 
		
		If LowProcessor = False Then
			tempx = EntityPitch(Mesh)
			tempy = EntityYaw(Mesh)
			tempz = EntityRoll(Mesh)
			
			If Positioned = True And OldCurrentGamePos <> CurrentGamePos Then
				Positioned = False
			EndIf
			
			If (x - EntityX(Mesh , GlobalPosition) ) < 0.05 And (y - EntityY(Mesh , GlobalPosition) ) < 0.05 And (z - EntityZ(Mesh , GlobalPosition) ) < 0.05 Then
				If (Rotx - EntityPitch(Mesh) ) < 0.1 And (Roty - EntityYaw(Mesh) ) < 0.1 And (Rotz - EntityRoll(Mesh) ) < 0.1 Then
					Positioned = True
				EndIf 
			EndIf 
				
			RotateEntity(Mesh , 0 , 0 , 0 )
			MoveEntity(Mesh , ((x - EntityX(Mesh,GlobalPosition) ) / 10^(1/SpeedRatio)), ((y - EntityY(Mesh,GlobalPosition) ) / 2^(1/SpeedRatio)) , ((z - EntityZ(Mesh,GlobalPosition) ) / 2^(1/SpeedRatio)) )
			RotateEntity(Mesh , tempx , tempy , tempz )
			If Abs((Roty - EntityYaw(Mesh) ) / 10^(1/SpeedRatio)) < 1 Then
				If Roty = 180 Then
					RotateEntity(Mesh , EntityPitch(Mesh) , 180 , EntityRoll(Mesh))
				ElseIf Roty = 0
					RotateEntity(Mesh , EntityPitch(Mesh) , 0 , EntityRoll(Mesh))
				EndIf
			Else
				TurnEntity(Mesh , (Rotx - EntityPitch(Mesh)) , ((Roty - EntityYaw(Mesh) ) / 10^(1/SpeedRatio)) , (Rotz - EntityRoll(Mesh)) , 1 )
			EndIf
		EndIf 

	End Method
	
	Method LoadCoverTexture()
		Local Hi:Float
		Local BHi:Float
		If EntityInView(Mesh , Camera)>0 Or EntityInView(BackMesh , Camera)>0 Then
			If Textured = False Then
				If FileType(GAMEDATAFOLDER + GameArray[Position] +FolderSlash +"Front_OPT.jpg") = 1 Then
					If ListContains(ProcessedTextures , GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Front_OPT.jpg") = True Then
						Tex = LoadPreloadedTexture(GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Front_OPT.jpg")
						If Tex <> Null
							EntityTexture(Mesh , Tex)
							If Reflections = True Then 							
								EntityTexture(ReflectMesh , Tex)
							EndIf 
							LockMutex(TTexture.Mutex_tex_list)
							Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
							'Self.y = Hi-1
							UnlockMutex(TTexture.Mutex_tex_list)
														
							ScaleEntity(Mesh , 0.75 , Hi , 0)
							NormY = Hi - 1
							'Repositioning done via hack flag - ResetCoverPosition which is updated via CoverWallType-Update()							
							ResetCoverPosition = True 

							LockMutex(TTexture.Mutex_tex_list)
							ListAddLast(InUseTextures , tex.file)
							UnlockMutex(TTexture.Mutex_tex_list)
							Textured = True 
						EndIf	
					Else
						Tex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
						If Tex <> Null Then
							EntityTexture(Mesh , Tex)
							If Reflections = True Then 							
								EntityTexture(ReflectMesh , Tex)
							EndIf
							LockMutex(TTexture.Mutex_tex_list)
							Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
							'Self.y = Hi-1
							UnlockMutex(TTexture.Mutex_tex_list)
							ScaleEntity(Mesh , 0.75 , Hi , 0)
							'PositionEntity(Mesh , EntityX(Mesh) , EntityY(Mesh) + Hi - 1 , EntityZ(Mesh) )	
							NormY = Hi - 1
							'y = EntityY(Mesh) + NormY
							Textured = False
						Else
							RuntimeError "Loading.jpg Missing!"
						EndIf							
					EndIf
				Else
					Tex = LoadPreloadedTexture(RESFOLDER + "NoCover.jpg")	
					If Tex <> Null Then
						EntityTexture(Mesh , tex)
						If Reflections = True Then 						
							EntityTexture(ReflectMesh , Tex)
						EndIf 
						LockMutex(TTexture.Mutex_tex_list)
						Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
						'Self.y = Hi-1
						UnlockMutex(TTexture.Mutex_tex_list)
						ScaleEntity(Mesh , 0.75 , Hi , 0)
						'PositionEntity(Mesh , EntityX(Mesh) , EntityY(Mesh) + Hi - 1 , EntityZ(Mesh) )
						NormY = Hi - 1
						'y = EntityY(Mesh) + NormY
						
						'LockMutex(TTexture.Mutex_tex_list)
						'ScaleEntity(Mesh , 0.75 , Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth) , 0)
						'UnlockMutex(TTexture.Mutex_tex_list)
						Textured = True
					Else
						RuntimeError "NoCover.jpg Missing!"
					EndIf
				EndIf	

				
			EndIf
			If BackTextured = False Then 
				If FileType(GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Back_OPT.jpg") = 1 Then
					If ListContains(ProcessedTextures , GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Back_OPT.jpg") = True Then
						BackTex = LoadPreloadedTexture(GAMEDATAFOLDER + GameArray[Position] +FolderSlash +"Back_OPT.jpg")
						If BackTex <> Null
							EntityTexture(BackMesh , BackTex)
							If Reflections = True Then 
								EntityTexture(BackReflectMesh , BackTex)
							EndIf 
							LockMutex(TTexture.Mutex_tex_list)
							ListAddLast(InUseTextures , BackTex.file)
							UnlockMutex(TTexture.Mutex_tex_list)
							BackTextured = True 
						EndIf	
					Else
						BackTex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
						If BackTex <> Null Then
							EntityTexture(BackMesh , BackTex)
							If Reflections = True Then 							
								EntityTexture(BackReflectMesh , BackTex)
							EndIf 
							BackTextured = False
						Else
							RuntimeError "Loading.jpg Missing!"
						EndIf							
					EndIf
				Else
					BackTex = LoadPreloadedTexture(RESFOLDER + "NoCover.jpg")	
					If BackTex <> Null Then
						EntityTexture(BackMesh , BackTex)
						If Reflections = True Then 						
							EntityTexture(BackReflectMesh , BackTex)
						EndIf 
						BackTextured = True
					Else
						RuntimeError "NoCover.jpg Missing!"
					EndIf
				EndIf	
			EndIf
		Else
			If LowMemory = True Then
				If Textured = True Then
					LockMutex(TTexture.Mutex_tex_list)
					ListRemove(InUseTextures , Tex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					Tex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
					If Tex <> Null Then
						EntityTexture(Mesh , Tex)
						If Reflections = True Then 						
							EntityTexture(ReflectMesh , Tex)
						EndIf 
						Textured = False
					Else
						RuntimeError "Loading.jpg Missing!"
					EndIf		
				EndIf
				If BackTextured = True Then
					LockMutex(TTexture.Mutex_tex_list)
					ListRemove(InUseTextures , BackTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					BackTex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
					If BackTex <> Null Then
						EntityTexture(BackMesh , BackTex)
						If Reflections = True Then 						
							EntityTexture(BackReflectMesh , BackTex)
						EndIf 
						BackTextured = False
					Else
						RuntimeError "Loading.jpg Missing!"
					EndIf		
				EndIf				
			EndIf
		EndIf 
		
	End Method
	
	
	Method Clear()
		FreeEntity(Mesh)
		LockMutex(TTexture.Mutex_tex_list)
		If Tex <> Null Then
			ListRemove(InUseTextures , Tex.file)
		EndIf
		UnlockMutex(TTexture.Mutex_tex_list)
	End Method
	
End Type


Type CoverFlowType
	Field Parent:TPivot
	Field Covers:CoverType[GameArrayLen]
	Field CoverFloor:TMesh
	Field BigCover:Int = 0
	Field OldCurrentGamePos:Int
	Field KeyDelayTimer:Int
		
	Field BigCoverEnabled:Int = False
	Field ReflectiveFloorEnabled:Int = False 
	Field FlowBackEnabled:Int = False 
	Field CoverFlipEnabled:Int = False 
	
	Field CoverMode:Int
	Field CoverFlowBack:TMesh
	'Mode = 1 Normal CoverFlow mode
	'Mode = 2 Flat covers, black back
	
	Method Init(x:Float , y:Float , z:Float)
		Local Tex:TTexture 
		OldCurrentGamePos = CurrentGamePos		
		
		Parent = CreatePivot()
		PositionEntity Parent , x , y , z
		
		If ReflectiveFloorEnabled = True Then 
			CoverFloor = CreateCube(Parent)
			PositionEntity CoverFloor , 0 , -1 , 0
			ScaleEntity CoverFloor , 100 , 0 , 100
			EntityAlpha CoverFloor , 0.8
			tex = LoadPreloadedTexture(RESFOLDER + "Black.jpg")	
			If tex <> Null
				EntityTexture(CoverFloor , tex)
			EndIf
		EndIf
					
		
		For a = 0 To GameArrayLen - 1
			Covers[a] = New CoverType
			Covers[a].Position = a
			'Covers[a].CoverMode = Self.CoverMode
			If ReflectiveFloorEnabled = True Then
				Covers[a].Reflections = True
			Else
				Covers[a].Reflections = False 
			EndIf 
			Covers[a].Init(Parent)
			b = Covers[a].Position - CurrentGamePos + 4
			Covers[a].x = Pos(b , 1 , Covers[a].NormY)
			Covers[a].y = Pos(b , 2 , Covers[a].NormY)
			Covers[a].z = Pos(b , 3 , Covers[a].NormY)
			Covers[a].Rotx = Rot(b , 1)
			Covers[a].Roty = Rot(b , 2)
			Covers[a].Rotz = Rot(b , 3)
			PositionEntity(Covers[a].Mesh , Covers[a].x , Covers[a].y , Covers[a].z , Covers[a].GlobalPosition)
			RotateEntity(Covers[a].Mesh , Covers[a].Rotx , Covers[a].Roty , Covers[a].Rotz)			
			
		Next
		
		If FlowBackEnabled = True Then 
			CoverFlowBack = CreateCube(Parent)
			ScaleEntity(CoverFlowBack , 10 , 1.3 , 0)
			PositionEntity(CoverFlowBack , 0,0,0.01)
			Tex = LoadPreloadedTexture(RESFOLDER + "Gray.jpg")
			If Tex <> Null
				EntityTexture(CoverFlowBack , Tex)
			EndIf
			EntityAlpha(CoverFlowBack , 0.7)
		EndIf 
	End Method


	
	Method Update()
		Local a:Int , b:Int 
		If OldCurrentGamePos <> CurrentGamePos Then
			BigCover = 0
		EndIf 
		OldCurrentGamePos = CurrentGamePos
		For a = 0 To GameArrayLen - 1
			Covers[a].Update()
			b = Covers[a].Position - CurrentGamePos + 4
			If b <> Covers[a].CoverNum Then
				Covers[a].GlobalPosition = False 
				Covers[a].x = Pos(b , 1 , Covers[a].NormY)
				Covers[a].y = Pos(b , 2 , Covers[a].NormY)
				Covers[a].z = Pos(b , 3 , Covers[a].NormY)
				Covers[a].Rotx = Rot(b , 1)
				Covers[a].Roty = Rot(b , 2)
				Covers[a].Rotz = Rot(b , 3)
				Covers[a].CoverNum = b
				If LowProcessor = True Then
					PositionEntity(Covers[a].Mesh , Covers[a].x , Covers[a].y , Covers[a].z , Covers[a].GlobalPosition)
					RotateEntity(Covers[a].Mesh , Covers[a].Rotx , Covers[a].Roty , Covers[a].Rotz)			
				EndIf 
			EndIf			
			
		Next
		If BigCover = 1 Then		
			Local Box:Float[4]
			Box = GetBoundingBox(Covers[CurrentGamePos].Mesh)
			If Box[1] < 50 Or Box[3] > GHeight - 50 Or Box[3] = - 1 Or Box[1] = - 1 Then
				Covers[CurrentGamePos].z = Covers[CurrentGamePos].z + 0.05		
			EndIf 		
		EndIf
	End Method
	
	Method UpdateKeyboard()
		If KeyHit(KEYBOARD_BIGCOVER) Then
			If BigCoverEnabled = True Then
				LoadBigCover()
			EndIf 
			Return True 
		EndIf
		If KeyHit(KEYBOARD_FLIPCOVER) Then
			If CoverFlipEnabled = True Then 
				FlipCover()
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
	End Method 
	
	Method UpdateJoy()
		For J=0 To JoyCount()-1 
			If JoyHit(JOY_BIGCOVER,J) Then
				If BigCoverEnabled = True Then
					LoadBigCover()
				EndIf 
				Return True 
			EndIf
			If JoyHit(JOY_FLIPCOVER,J) Then
				If CoverFlipEnabled = True Then 
					FlipCover()
				EndIf 
				Return True
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
				Return True 		
			EndIf 			
		Next
		Return False 
	End Method 
	
	Method UpdateMouse()
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
			For a = 0 To GameArrayLen - 1
				If Covers[a].MouseOver() = True
					ListAddLast(ClickCoverList , String(a) )
				EndIf
			Next	
			If ClickCoverList.Count() > 0 Then
				If ListContains(ClickCoverList , String(CurrentGamePos) ) Then
					If BigCoverEnabled = True Then 
						LoadBigCover()
					EndIf 
				Else
					For b = EachIn ClickCoverList
						a = Int(String(b))
						If a > CurrentGamePos Then
							If a < SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf
						ElseIf a < CurrentGamePos Then
							If a > SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf						
						EndIf
					Next
					CurrentGamePos = SelectedCover
				EndIf	
			EndIf
			Return True 
		EndIf
		If MouseClick = 2 Then
			MouseClick = 0
			If CoverFlipEnabled = True Then 
				FlipCover()
			EndIf 
			Return True 
		EndIf		
		If MouseSwipe = 1 Then
			MouseSwipe = 0
			PrintF("You swiped mouse, X:" + String(MouseEnd[0] - MouseStart[0]) + " T:" + MouseSwipeTime)
			If CurrentGamePos = GameArrayLen - 1 Or CurrentGamePos = 0 Then DoNotStopSwipe = True 
			CurrentGamePos = CurrentGamePos + Int( ( ( (Float(MouseEnd[0] - MouseStart[0]) * 10) / GWidth) * 1000	) / MouseSwipeTime)
			If DoNotStopSwipe = False Then
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1
				If CurrentGamePos < 0 Then CurrentGamePos = 0
			Else
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = 0
				If CurrentGamePos < 0 Then CurrentGamePos = GameArrayLen - 1
			EndIf
			Return True 
		ElseIf MouseSwipe = 2 Then
			MouseSwipe = 3
			CurrentGamePos = CurrentGamePos + Int((Float(MouseX()-(GWidth/2))/ GWidth)*6 )
			
			If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1
			If CurrentGamePos < 0 Then CurrentGamePos = 0		
			Return True
		ElseIf MouseSwipe = 4 Then
			MouseSwipe = 0
			If MouseEnd[1] - MouseStart[1] > 0 Then
				If BigCoverEnabled = True Then
					LoadBigCover()		
				EndIf 
			ElseIf MouseEnd[1] - MouseStart[1] < 0
				If CoverFlipEnabled = True Then 
					FlipCover()
				EndIf 
			EndIf
			Return True
		EndIf
		Return False 
	End Method
	
	Method FlipCover()
		If Covers[CurrentGamePos].Roty > 90 Then
			Covers[CurrentGamePos].Roty = 0
		ElseIf Covers[CurrentGamePos].Roty < 90 Then
			Covers[CurrentGamePos].Roty = 180
		EndIf		
	End Method
	
	Method LoadBigCover()
		Local BTex:TTexture		
		If BigCover = 0 Then
			Covers[CurrentGamePos].GlobalPosition = True
			Covers[CurrentGamePos].y = Covers[CurrentGamePos].NormY
			

			If WideScreen = 1 Then
				Covers[CurrentGamePos].z = - 2
			Else
				Covers[CurrentGamePos].z = - 2.3
			EndIf
			BigCover = 1		
			If Covers[CurrentGamePos].Roty = 180 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Front_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Front_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Covers[CurrentGamePos].Mesh , BTex)
				EndIf
			ElseIf Covers[CurrentGamePos].Roty = 0 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Back_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Back_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Covers[CurrentGamePos].BackMesh , BTex)
				EndIf					
			EndIf
		Else
			
			Covers[CurrentGamePos].z = Pos(Covers[CurrentGamePos].CoverNum , 3 , Covers[CurrentGamePos].NormY)
			Covers[CurrentGamePos].y = Pos(Covers[CurrentGamePos].CoverNum , 2 , Covers[CurrentGamePos].NormY)
			Covers[CurrentGamePos].x = Pos(Covers[CurrentGamePos].CoverNum , 1 , Covers[CurrentGamePos].NormY)
			Covers[CurrentGamePos].GlobalPosition = False 
			BigCover = 0
		EndIf		
	End Method

	Method Pos:Float(Num:Int , Axis:Int , NormY:Float)
		Local CoverDistance:Float 
		Select CoverMode
			Case 1
				CoverDistance = 1 
			Case 2
				CoverDistance = 1.6
		End Select
		
		Select CoverMode
			Case 1
				Select Axis
					Case 1
					
						Select Num
							Case 3
								Return -1.2*CoverDistance
							Case 4
								Return 0
							Case 5
								Return 1.2*CoverDistance
							
							Default
								Return (Num-4)*CoverDistance		
						End Select
					
						
					Case 2
						Return NormY
					Case 3
						Select Num
							Case 4
								Return -0.5
							Default
								If Num <> 4 Then
									Return 0
								Else
									RuntimeError "Invalid Cover Num"					
								EndIf
						End Select
					Default
						RuntimeError "Invalid Axis"
				End Select
			Case 2
				Select Axis
					Case 1
						Select Num
							Case 4
								Return 0
							
							Default
								If Num > 4 Then 
									Return ((Num - 4) * CoverDistance) + 1
								ElseIf Num < 4 Then
									Return ((Num - 4) * CoverDistance) - 1
								EndIf
						End Select
					Case 2
						Return NormY
					Case 3
						Return 0
					Default
						RuntimeError "Invalid Axis"
				End Select
			
		End Select 
	End Method 
	
	Method Rot:Float(Num:Int , Axis:Int)
		Select CoverMode
			Case 1		
				Select Axis
					Case 1
						Return 0
					Case 2
						Select Num
							Case 4
								Return 0
							Default
								If Num > 4 Then
									Return - 40
								ElseIf Num < 4 Then
									Return 40
								Else
									RuntimeError "Invalid Cover Num"
								EndIf
						End Select
					Case 3
						Return 0
					Default
						RuntimeError "Invalid Axis"
				End Select
			Case 2
				Return 0
		End Select
	End Method 	
	
	Method Clear()
		For a = 0 To GameArrayLen - 1
			Covers[a].Clear()
			Covers[a] = Null
		Next		
		FreeEntity(Parent)
		Parent = Null
	End Method
	
End Type

Type BackType
	Field Mesh:TMesh
	Field OldTextureName:String
	Field LastTex:TTexture
	Field BackAlpha:Float 
	
	Method Init()
		Mesh = CreateCube()
		PositionEntity(Mesh , 0 , 0 , 15)
		If WideScreen = 0 Then 
			ScaleEntity(Mesh , 19 , 14.25 , 0)	
		Else
			ScaleEntity(Mesh , 19 , 10.65 , 0)
		EndIf 
		EntityFX(Mesh,1) 
	End Method
	
	Method Clear()
		FreeEntity(Mesh)
		LockMutex(TTexture.Mutex_tex_list)
		InUseTextures.Remove(LastTex)
		UnlockMutex(TTexture.Mutex_tex_list)	
		LastTex = Null			
	End Method 
	
	Method Update()
		If GameArrayLen <> 0 Then
			If LowProcessor = False Then 
				If BackAlpha <= 1 Then 
					BackAlpha = BackAlpha + 0.05
					EntityAlpha(Mesh , BackAlpha)
				EndIf
			EndIf 
			Local Tex:TTexture
			If FileType(GAMEDATAFOLDER + GameNode.OrginalName +FolderSlash+ "Screen_OPT.jpg") = 1 Then
				If OldTextureName <> GAMEDATAFOLDER + GameNode.OrginalName +FolderSlash+ "Screen_OPT.jpg" Then
					If ListContains(ProcessedTextures , GAMEDATAFOLDER + GameNode.OrginalName +FolderSlash+ "Screen_OPT.jpg") = True Then
						Tex = LoadPreloadedTexture(GAMEDATAFOLDER + GameNode.OrginalName +FolderSlash+ "Screen_OPT.jpg")
						If Tex <> Null
							'HideEntity(Mesh)
							PrintF(EntityTexture(Mesh , Tex) )
							
							LockMutex(TTexture.Mutex_tex_list)
							InUseTextures.Remove(LastTex)
							UnlockMutex(TTexture.Mutex_tex_list)							
							LastTex = Tex
							OldTextureName = GAMEDATAFOLDER + GameNode.OrginalName + FolderSlash+"Screen_OPT.jpg"
							If LowProcessor = False Then
								BackAlpha = 0
								EntityAlpha(Mesh , BackAlpha)
							EndIf 
							LockMutex(TTexture.Mutex_tex_list)
							ListAddLast(InUseTextures , Tex.file)
							UnlockMutex(TTexture.Mutex_tex_list)							
						EndIf
					Else
						Tex = LoadPreloadedTexture(RESFOLDER + "BackLoading.jpg")	
						If Tex <> Null Then
							EntityTexture(Mesh , Tex)
							InUseTextures.Remove(LastTex)
							LastTex = Tex							
							OldTextureName = RESFOLDER + "BackLoading.jpg"
						EndIf 
					EndIf
				EndIf 
			Else 	
				If OldTextureName <> RESFOLDER + "NoBack.jpg" Then 
					Tex = LoadPreloadedTexture(RESFOLDER + "NoBack.jpg")	
					If Tex <> Null Then
						EntityTexture(Mesh , Tex)
						If LowProcessor = False Then
							BackAlpha = 0
							EntityAlpha(Mesh , BackAlpha)	
						EndIf 					
						InUseTextures.Remove(LastTex)
						LastTex = Tex
						OldTextureName = RESFOLDER + "NoBack.jpg"
					EndIf
				EndIf 
			EndIf 
		EndIf  
	End Method 
End Type  

Type CoverType
	Field Mesh:TMesh
	Field BackMesh:TMesh	
	Field ReflectMesh:TMesh
	Field BackReflectMesh:TMesh	
	Field Reflections:Int 
	
	Field Position:Int
	Field CoverNum:Int
	
	Field x:Float
	Field y:Float
	Field z:Float
	Field Rotx:Float
	Field Roty:Float
	Field Rotz:Float
	Field NormY:Float
	Field GlobalPosition:Int = False 
	
	Field Textured:Int
	Field BackTextured:Int	
	Field Tex:TTexture
	Field BackTex:TTexture
		
	Field Positioned:Int = False
	Field OldCurrentGamePos:Int 
	'Field CoverMode:Int 
	'Field CoverDistance:Float
	
	
	Method Init(Parent:TPivot)
		Rem
		Select CoverMode
			Case 1
				CoverDistance = 1 
			Case 2
				CoverDistance = 1.6
		End select
		EndRem 
		Mesh = CreateCover(0 , Parent)
		BackMesh = CreateCover(0 , Mesh)
		RotateEntity(BackMesh,0,180,0)
		Textured = False
		BackTextured = False
		EntityFX Mesh , 1
		EntityFX BackMesh , 1
		'CoverNum = Position - CurrentGamePos + 4
		CoverNum = -1
		'PositionEntity Mesh , Pos(CoverNum , 1) , Pos(CoverNum , 2) , Pos(CoverNum , 3)
		PositionEntity Mesh , 0 , 0 , 0
		ScaleEntity Mesh , 0.75 , 1 , 0 
		'RotateEntity Mesh , Rot(CoverNum , 1) , Rot(CoverNum , 2) , Rot(CoverNum , 3)		
		'RotateEntity Mesh , 0 , 0 , 0
		x = EntityX(Mesh)
		y = EntityY(Mesh)
		z = EntityZ(Mesh)
		Rotx = EntityPitch(Mesh)
		Roty = EntityYaw(Mesh)
		Rotz = EntityRoll(Mesh)
		
		If Reflections = True Then 
			ReflectMesh = CreateCover(1,Mesh)
			MoveEntity ReflectMesh , 0 , - 2.05 , 0
			EntityFX ReflectMesh , 1
			ScaleEntity ReflectMesh , - 1 , - 1 , 0
			
			BackReflectMesh = CreateCover(1,BackMesh)
			MoveEntity BackReflectMesh , 0 , - 2.05 , 0
			EntityFX BackReflectMesh , 1
			ScaleEntity BackReflectMesh , - 1 , - 1 , 0
		EndIf
	End Method
	
	Method MouseOver()
		Local Box:Float[4]
		Box = GetBoundingBox(Mesh)
		If MouseX() > Box[0] And MouseX() < Box[2] And MouseY() > Box[1] And MouseY() < Box[3] Then
			Return True
		Else
			Return False
		EndIf
	End Method 
	
	Method Update()

		If GameArrayLen <> 0 Then 
			LoadCoverTexture()
		EndIf
		If Positioned = False Then 
			OldCurrentGamePos = CurrentGamePos
		EndIf 
		
		If LowProcessor = False Then
			tempx = EntityPitch(Mesh)
			tempy = EntityYaw(Mesh)
			tempz = EntityRoll(Mesh)
			
			If Positioned = True And OldCurrentGamePos <> CurrentGamePos Then
				Positioned = False
			EndIf
			
			If (x - EntityX(Mesh , GlobalPosition) ) < 0.05 And (y - EntityY(Mesh , GlobalPosition) ) < 0.05 And (z - EntityZ(Mesh , GlobalPosition) ) < 0.05 Then
				If (Rotx - EntityPitch(Mesh) ) < 0.1 And (Roty - EntityYaw(Mesh) ) < 0.1 And (Rotz - EntityRoll(Mesh) ) < 0.1 Then
					Positioned = True
				EndIf 
			EndIf 
				
			RotateEntity(Mesh , 0 , 0 , 0 )
			MoveEntity(Mesh , ((x - EntityX(Mesh,GlobalPosition) ) / 10^(1/SpeedRatio)), ((y - EntityY(Mesh,GlobalPosition) ) / 2^(1/SpeedRatio)) , ((z - EntityZ(Mesh,GlobalPosition) ) / 2^(1/SpeedRatio)) )
			RotateEntity(Mesh , tempx , tempy , tempz )
			If Abs((Roty - EntityYaw(Mesh) ) / 10^(1/SpeedRatio)) < 1 Then
				If Roty = 180 Then
					RotateEntity(Mesh , EntityPitch(Mesh) , 180 , EntityRoll(Mesh))
				ElseIf Roty = 0
					RotateEntity(Mesh , EntityPitch(Mesh) , 0 , EntityRoll(Mesh))
				EndIf
			Else
				TurnEntity(Mesh , (Rotx - EntityPitch(Mesh)) , ((Roty - EntityYaw(Mesh) ) / 10^(1/SpeedRatio)) , (Rotz - EntityRoll(Mesh)) , 1 )
			EndIf
		EndIf 

	End Method
	
	Method LoadCoverTexture()
		Local Hi:Float
		Local BHi:Float
		If EntityInView(Mesh , Camera)>0 Or EntityInView(BackMesh , Camera)>0 Then
			If Textured = False Then
				If FileType(GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Front_OPT.jpg") = 1 Then
					If ListContains(ProcessedTextures , GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Front_OPT.jpg") = True Then
						Tex = LoadPreloadedTexture(GAMEDATAFOLDER + GameArray[Position] + FolderSlash +"Front_OPT.jpg")
						If Tex <> Null
							EntityTexture(Mesh , Tex)
							If Reflections = True Then 							
								EntityTexture(ReflectMesh , Tex)
							EndIf 
							LockMutex(TTexture.Mutex_tex_list)
							Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
							'Self.y = Hi-1
							UnlockMutex(TTexture.Mutex_tex_list)
														
							ScaleEntity(Mesh , 0.75 , Hi , 0)
							PositionEntity(Mesh , EntityX(Mesh) , Hi - 1 , EntityZ(Mesh) )
							NormY = Hi - 1
							y = NormY
							LockMutex(TTexture.Mutex_tex_list)
							ListAddLast(InUseTextures , tex.file)
							UnlockMutex(TTexture.Mutex_tex_list)
							Textured = True 
						EndIf	
					Else
						Tex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
						If Tex <> Null Then
							EntityTexture(Mesh , Tex)
							If Reflections = True Then 							
								EntityTexture(ReflectMesh , Tex)
							EndIf
							LockMutex(TTexture.Mutex_tex_list)
							Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
							'Self.y = Hi-1
							UnlockMutex(TTexture.Mutex_tex_list)
							ScaleEntity(Mesh , 0.75 , Hi , 0)
							PositionEntity(Mesh , EntityX(Mesh) , Hi - 1 , EntityZ(Mesh) )							
							NormY = Hi - 1
							y = NormY
							Textured = False
						Else
							RuntimeError "Loading.jpg Missing!"
						EndIf							
					EndIf
				Else
					Tex = LoadPreloadedTexture(RESFOLDER + "NoCover.jpg")	
					If Tex <> Null Then
						EntityTexture(Mesh , tex)
						If Reflections = True Then 						
							EntityTexture(ReflectMesh , Tex)
						EndIf 
						LockMutex(TTexture.Mutex_tex_list)
						Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
						'Self.y = Hi-1
						UnlockMutex(TTexture.Mutex_tex_list)
						ScaleEntity(Mesh , 0.75 , Hi , 0)
						PositionEntity(Mesh , EntityX(Mesh) , Hi - 1 , EntityZ(Mesh) )
						NormY = Hi - 1
						y = NormY
						
						'LockMutex(TTexture.Mutex_tex_list)
						'ScaleEntity(Mesh , 0.75 , Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth) , 0)
						'UnlockMutex(TTexture.Mutex_tex_list)
						Textured = True
					Else
						RuntimeError "NoCover.jpg Missing!"
					EndIf
				EndIf	

				
			EndIf
			If BackTextured = False Then 
				If FileType(GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Back_OPT.jpg") = 1 Then
					If ListContains(ProcessedTextures , GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Back_OPT.jpg") = True Then
						BackTex = LoadPreloadedTexture(GAMEDATAFOLDER + GameArray[Position] +FolderSlash+ "Back_OPT.jpg")
						If BackTex <> Null
							EntityTexture(BackMesh , BackTex)
							If Reflections = True Then 
								EntityTexture(BackReflectMesh , BackTex)
							EndIf 
							LockMutex(TTexture.Mutex_tex_list)
							ListAddLast(InUseTextures , BackTex.file)
							UnlockMutex(TTexture.Mutex_tex_list)
							BackTextured = True 
						EndIf	
					Else
						BackTex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
						If BackTex <> Null Then
							EntityTexture(BackMesh , BackTex)
							If Reflections = True Then 							
								EntityTexture(BackReflectMesh , BackTex)
							EndIf 
							BackTextured = False
						Else
							RuntimeError "Loading.jpg Missing!"
						EndIf							
					EndIf
				Else
					BackTex = LoadPreloadedTexture(RESFOLDER + "NoCover.jpg")	
					If BackTex <> Null Then
						EntityTexture(BackMesh , BackTex)
						If Reflections = True Then 						
							EntityTexture(BackReflectMesh , BackTex)
						EndIf 
						BackTextured = True
					Else
						RuntimeError "NoCover.jpg Missing!"
					EndIf
				EndIf	
			EndIf
		Else
			If LowMemory = True Then
				If Textured = True Then
					LockMutex(TTexture.Mutex_tex_list)
					ListRemove(InUseTextures , Tex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					Tex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
					If Tex <> Null Then
						EntityTexture(Mesh , Tex)
						If Reflections = True Then 						
							EntityTexture(ReflectMesh , Tex)
						EndIf 
						Textured = False
					Else
						RuntimeError "Loading.jpg Missing!"
					EndIf		
				EndIf
				If BackTextured = True Then
					LockMutex(TTexture.Mutex_tex_list)
					ListRemove(InUseTextures , BackTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					BackTex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
					If BackTex <> Null Then
						EntityTexture(BackMesh , BackTex)
						If Reflections = True Then 						
							EntityTexture(BackReflectMesh , BackTex)
						EndIf 
						BackTextured = False
					Else
						RuntimeError "Loading.jpg Missing!"
					EndIf		
				EndIf				
			EndIf
		EndIf 
		
		
	End Method
	
	Method Clear()
		FreeEntity(Mesh)
		LockMutex(TTexture.Mutex_tex_list)
		If Tex <> Null Then
			ListRemove(InUseTextures , Tex.file)
		EndIf
		UnlockMutex(TTexture.Mutex_tex_list)
	End Method
	
	Rem
	Method Pos:Float(Num:Int , Axis:Int)
		Local CoverDistance:Float 
		Select CoverMode
			Case 1
				CoverDistance = 1 
			Case 2
				CoverDistance = 1.6
		End Select
		
		Select CoverMode
			Case 1
				Select Axis
					Case 1
					
						Select Num
							Case 3
								Return -1.2*CoverDistance
							Case 4
								Return 0
							Case 5
								Return 1.2*CoverDistance
							
							Default
								Return (Num-4)*CoverDistance		
						End Select
					
						
					Case 2
						Return NormY
					Case 3
						Select Num
							Case 4
								Return -0.5
							Default
								If Num <> 4 Then
									Return 0
								Else
									RuntimeError "Invalid Cover Num"					
								EndIf
						End Select
					Default
						RuntimeError "Invalid Axis"
				End Select
			Case 2
				Select Axis
					Case 1
						Select Num
							Case 4
								Return 0
							
							Default
								If Num > 4 Then 
									Return ((Num - 4) * CoverDistance) + 1
								ElseIf Num < 4 Then
									Return ((Num - 4) * CoverDistance) - 1
								EndIf
						End Select
					Case 2
						Return NormY
					Case 3
						Return 0
					Default
						RuntimeError "Invalid Axis"
				End Select
			
		End Select 
	End Method 
	EndRem 
	
	Rem
	Method Rot:Float(Num:Int , Axis:Int)
		Select CoverMode
			Case 1		
				Select Axis
					Case 1
						Return 0
					Case 2
						Select Num
							Case 4
								Return 0
							Default
								If Num > 4 Then
									Return - 40
								ElseIf Num < 4 Then
									Return 40
								Else
									RuntimeError "Invalid Cover Num"
								EndIf
						End Select
					Case 3
						Return 0
					Default
						RuntimeError "Invalid Axis"
				End Select
			Case 2
				Return 0
		End Select
	End Method 	
	EndRem 
	
End Type


Type BannerFlowType
	Field Parent:TPivot
	Field Covers:BannerType[GameArrayLen]
	Field CoverFloor:TMesh
	Field BigCover:Int = 0
	Field OldCurrentGamePos:Int
	Field KeyDelayTimer:Int
		
	Field BigCoverEnabled:Int = False
	Field ReflectiveFloorEnabled:Int = False 
	Field FlowBackEnabled:Int = False 
	Field CoverFlipEnabled:Int = False 
	
	Field CoverMode:Int
	Field CoverFlowBack:TMesh
	'Mode = 1 Normal CoverFlow mode
	'Mode = 2 Flat covers, black back
	
	Method Init(x:Float , y:Float , z:Float)
		Local Tex:TTexture 
		OldCurrentGamePos = CurrentGamePos		
		
		Parent = CreatePivot()
		PositionEntity Parent , x , y , z
		
		If ReflectiveFloorEnabled = True Then 
			CoverFloor = CreateCube(Parent)
			PositionEntity CoverFloor , 0 , -1 , 0
			ScaleEntity CoverFloor , 100 , 0 , 100
			EntityAlpha CoverFloor , 0.8
			tex = LoadPreloadedTexture(RESFOLDER + "Black.jpg")	
			If tex <> Null
				EntityTexture(CoverFloor , tex)
			EndIf
		EndIf
					
		
		For a = 0 To GameArrayLen - 1
			Covers[a] = New BannerType
			Covers[a].Position = a
			'Covers[a].CoverMode = Self.CoverMode
			If ReflectiveFloorEnabled = True Then
				Covers[a].Reflections = True
			Else
				Covers[a].Reflections = False 
			EndIf 
			Covers[a].Init(Parent)
			b = Covers[a].Position - CurrentGamePos + 4
			Covers[a].x = Pos(b , 1 , Covers[a].NormY)
			Covers[a].y = Pos(b , 2 , Covers[a].NormY)
			Covers[a].z = Pos(b , 3 , Covers[a].NormY)
			Covers[a].Rotx = Rot(b , 1)
			Covers[a].Roty = Rot(b , 2)
			Covers[a].Rotz = Rot(b , 3)
			
			If CoverMode = 1 Then 
				ScaleEntity(Covers[a].Mesh , 6 , 1.1 , 0  )			
			EndIf 
			PositionEntity(Covers[a].Mesh , Covers[a].x , Covers[a].y , Covers[a].z , Covers[a].GlobalPosition)
			RotateEntity(Covers[a].Mesh , Covers[a].Rotx , Covers[a].Roty , Covers[a].Rotz)			
			
		Next
		
		If FlowBackEnabled = True Then 
			CoverFlowBack = CreateCube(Parent)
			ScaleEntity(CoverFlowBack , 10 , 0.7 , 0)
			PositionEntity(CoverFlowBack , 0,0,0.01)
			Tex = LoadPreloadedTexture(RESFOLDER + "Gray.jpg")
			If Tex <> Null
				EntityTexture(CoverFlowBack , Tex)
			EndIf
			EntityAlpha(CoverFlowBack , 0.7)
		EndIf 
	End Method


	
	Method Update()
		Local a:Int , b:Int 
		If OldCurrentGamePos <> CurrentGamePos Then
			BigCover = 0
		EndIf 
		OldCurrentGamePos = CurrentGamePos
		For a = 0 To GameArrayLen - 1
			Covers[a].Update()
			b = Covers[a].Position - CurrentGamePos + 4
			If b <> Covers[a].CoverNum Then
				Covers[a].GlobalPosition = False 
				Covers[a].x = Pos(b , 1 , Covers[a].NormY)
				Covers[a].y = Pos(b , 2 , Covers[a].NormY)
				Covers[a].z = Pos(b , 3 , Covers[a].NormY)
				Covers[a].Rotx = Rot(b , 1)
				Covers[a].Roty = Rot(b , 2)
				Covers[a].Rotz = Rot(b , 3)
				Covers[a].CoverNum = b
				If LowProcessor = True Then
					PositionEntity(Covers[a].Mesh , Covers[a].x , Covers[a].y , Covers[a].z , Covers[a].GlobalPosition)
					RotateEntity(Covers[a].Mesh , Covers[a].Rotx , Covers[a].Roty , Covers[a].Rotz)			
				EndIf 
			EndIf			
			
		Next
		If BigCover = 1 Then
			Local Box:Float[4]
			Box = GetBoundingBox(Covers[CurrentGamePos].Mesh)
			If Box[1] < 50 Or Box[3] > GHeight - 50 Or Box[3] = - 1 Or Box[1] = - 1 Then
				Covers[CurrentGamePos].z = Covers[CurrentGamePos].z + 0.05		
			EndIf 
		EndIf
	End Method
	
	Method UpdateJoy()
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
		
			If Tol(JoyHat(J),0.5,0.1) Or Tol(JoyHat(J),0.25,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100 
					CurrentGamePos = CurrentGamePos + 1
					KeyDelayTimer = MilliSecs()
					If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1 'CurrentGamePos - GameArrayLen
				EndIf
				Return True			
			EndIf 
			If Tol(JoyHat(J),0,0.1) Or Tol(JoyHat(J),0.75,0.1) Then 
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
		If KeyHit(KEYBOARD_BIGCOVER) Then
			If BigCoverEnabled = True Then
				LoadBigCover()
			EndIf 
			Return True 
		EndIf
		If KeyHit(KEYBOARD_FLIPCOVER) Then
			If CoverFlipEnabled = True Then 
				FlipCover()
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
	End Method 
	
	Method UpdateMouse()
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
			For a = 0 To GameArrayLen - 1
				If Covers[a].MouseOver() = True
					ListAddLast(ClickCoverList , String(a) )
				EndIf
			Next	
			If ClickCoverList.Count() > 0 Then
				If ListContains(ClickCoverList , String(CurrentGamePos) ) Then
					If BigCoverEnabled = True Then 
						LoadBigCover()
					EndIf 
				Else
					For b = EachIn ClickCoverList
						a = Int(String(b))
						If a > CurrentGamePos Then
							If a < SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf
						ElseIf a < CurrentGamePos Then
							If a > SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf						
						EndIf
					Next
					CurrentGamePos = SelectedCover
				EndIf	
			EndIf
			Return True 
		EndIf
		If MouseClick = 2 Then
			MouseClick = 0
			If CoverFlipEnabled = True Then 
				FlipCover()
			EndIf 
			Return True 
		EndIf		
		If MouseSwipe = 1 Then
			MouseSwipe = 0
			PrintF("You swiped mouse, X:" + String(MouseEnd[0] - MouseStart[0]) + " T:" + MouseSwipeTime)
			If CurrentGamePos = GameArrayLen - 1 Or CurrentGamePos = 0 Then DoNotStopSwipe = True 
			CurrentGamePos = CurrentGamePos + Int( ( ( (Float(MouseEnd[0] - MouseStart[0]) * 10) / GWidth) * 1000	) / MouseSwipeTime)
			If DoNotStopSwipe = False Then
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1
				If CurrentGamePos < 0 Then CurrentGamePos = 0
			Else
				If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = 0
				If CurrentGamePos < 0 Then CurrentGamePos = GameArrayLen - 1
			EndIf
			Return True 
		ElseIf MouseSwipe = 2 Then
			MouseSwipe = 3
			CurrentGamePos = CurrentGamePos + Int((Float(MouseX()-(GWidth/2))/ GWidth) * 6)
			
			If CurrentGamePos > GameArrayLen - 1 Then CurrentGamePos = GameArrayLen - 1
			If CurrentGamePos < 0 Then CurrentGamePos = 0		
			Return True
		ElseIf MouseSwipe = 4 Then
			MouseSwipe = 0
			If MouseEnd[1] - MouseStart[1] > 0 Then
				If BigCoverEnabled = True Then
					LoadBigCover()		
				EndIf 
			ElseIf MouseEnd[1] - MouseStart[1] < 0
				If CoverFlipEnabled = True Then 
					FlipCover()
				EndIf 
			EndIf
			Return True
		EndIf
		Return False 
	End Method
	
	Method FlipCover()
		If Covers[CurrentGamePos].Roty > 90 Then
			Covers[CurrentGamePos].Roty = 0
		ElseIf Covers[CurrentGamePos].Roty < 90 Then
			Covers[CurrentGamePos].Roty = 180
		EndIf		
	End Method
	
	Method LoadBigCover()
		Local BTex:TTexture		
		If BigCover = 0 Then
			Covers[CurrentGamePos].GlobalPosition = True
			Covers[CurrentGamePos].y = Covers[CurrentGamePos].NormY

			If WideScreen = 1 Then
				Covers[CurrentGamePos].z = - 2
			Else
				Covers[CurrentGamePos].z = - 2.3
			EndIf
			BigCover = 1		
			If Covers[CurrentGamePos].Roty = 180 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Front_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Front_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Covers[CurrentGamePos].Mesh , BTex)
				EndIf
			ElseIf Covers[CurrentGamePos].Roty = 0 Then
				If FileType(GAMEDATAFOLDER + GameArray[CurrentGamePos] +FolderSlash+ "Back_OPT_2X.jpg") = 1 Then
					BTex = LoadTexture(GAMEDATAFOLDER + GameArray[CurrentGamePos] + FolderSlash+"Back_OPT_2X.jpg")
					LockMutex(TTexture.Mutex_tex_list)
					ListAddLast(InUseTextures , BTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					EntityTexture(Covers[CurrentGamePos].BackMesh , BTex)
				EndIf					
			EndIf
		Else
			Covers[CurrentGamePos].z = Covers[CurrentGamePos].Pos(Covers[CurrentGamePos].CoverNum , 3)
			Covers[CurrentGamePos].y = Covers[CurrentGamePos].Pos(Covers[CurrentGamePos].CoverNum , 2)
			Covers[CurrentGamePos].GlobalPosition = False 
			BigCover = 0
		EndIf		
	End Method

	Method Pos:Float(Num:Int , Axis:Int , NormY:Float)
		Local CoverDistance:Float 
		Select CoverMode
			Case 1
				CoverDistance = 2
			Case 2
				CoverDistance = 5
		End Select
		
		Select CoverMode
			Case 1
				Select Axis
					Case 1
					
						Return 0
										
					Case 2
						Select Num
							Case 2
								Return 2.3*CoverDistance
							Case 3
								Return 1.2*CoverDistance
							Case 4
								Return -0.125
							Case 5
								Return -1.2* CoverDistance
							Case 6
								Return -2.3 * CoverDistance
							
							Default
								If Num > 6 Then
									Return -10
								Else
									Return 10		
								EndIf 
								
						End Select
					
					Case 3
						Select Num
							Case 4
								Return 4
							Default
								If Num <> 4 Then
									Return 5
								Else
									RuntimeError "Invalid Cover Num"					
								EndIf
						End Select
					Default
						RuntimeError "Invalid Axis"
				End Select
			Case 2
				Select Axis
					Case 1
						Select Num
							Case 4
								Return 0
							
							Default
								If Num > 4 Then 
									Return ((Num - 4) * CoverDistance) + 1
								ElseIf Num < 4 Then
									Return ((Num - 4) * CoverDistance) - 1
								EndIf
						End Select
					Case 2
						Return NormY
					Case 3
						Return 0
					Default
						RuntimeError "Invalid Axis"
				End Select
			
		End Select 
	End Method 
	
	Method Rot:Float(Num:Int , Axis:Int)
		Select CoverMode
			Case 1		
				Select Axis
					Case 1
						Return 0
					Case 2
						Return 0
					Case 3
						Return 0
					Default
						RuntimeError "Invalid Axis"
				End Select
			Case 2
				Return 0
		End Select
	End Method 	
	
	Method Clear()
		For a = 0 To GameArrayLen - 1
			Covers[a].Clear()
			Covers[a] = Null
		Next		
		FreeEntity(Parent)
		Parent = Null
	End Method
	
End Type

Type BannerType
	Field Mesh:TMesh
	Field BackMesh:TMesh	
	Field ReflectMesh:TMesh
	Field BackReflectMesh:TMesh	
	Field Reflections:Int 
	
	Field Position:Int
	Field CoverNum:Int
	
	Field x:Float
	Field y:Float
	Field z:Float
	Field Rotx:Float
	Field Roty:Float
	Field Rotz:Float
	Field NormY:Float
	Field GlobalPosition:Int = False 
	
	Field Textured:Int
	Field BackTextured:Int	
	Field Tex:TTexture
	Field BackTex:TTexture
		
	Field Positioned:Int = False
	Field OldCurrentGamePos:Int 
	'Field CoverMode:Int 
	'Field CoverDistance:Float
	
	
	Method Init(Parent:TPivot)
		Rem
		Select CoverMode
			Case 1
				CoverDistance = 1 
			Case 2
				CoverDistance = 1.6
		End select
		EndRem 
		Mesh = CreateCover(0 , Parent)
		BackMesh = CreateCover(0 , Mesh)
		RotateEntity(BackMesh,0,180,0)
		Textured = False
		BackTextured = False
		EntityFX Mesh , 1
		EntityFX BackMesh , 1
		'CoverNum = Position - CurrentGamePos + 4
		CoverNum = -1
		PositionEntity Mesh , Pos(CoverNum , 1) , Pos(CoverNum , 2) , Pos(CoverNum , 3)
		ScaleEntity Mesh , 3 , 0.55 , 0 
		RotateEntity Mesh , Rot(CoverNum , 1) , Rot(CoverNum , 2) , Rot(CoverNum , 3)		
		x = EntityX(Mesh)
		y = EntityY(Mesh)
		z = EntityZ(Mesh)
		Rotx = EntityPitch(Mesh)
		Roty = EntityYaw(Mesh)
		Rotz = EntityRoll(Mesh)
		
		If Reflections = True Then 
			ReflectMesh = CreateCover(1,Mesh)
			MoveEntity ReflectMesh , 0 , - 2.05 , 0
			EntityFX ReflectMesh , 1
			ScaleEntity ReflectMesh , - 1 , - 1 , 0
			
			BackReflectMesh = CreateCover(1,BackMesh)
			MoveEntity BackReflectMesh , 0 , - 2.05 , 0
			EntityFX BackReflectMesh , 1
			ScaleEntity BackReflectMesh , - 1 , - 1 , 0
		EndIf
	End Method
	
	Method MouseOver()
		Local Box:Float[4]
		Box = GetBoundingBox(Mesh)
		If MouseX() > Box[0] And MouseX() < Box[2] And MouseY() > Box[1] And MouseY() < Box[3] Then
			Return True
		Else
			Return False
		EndIf
	End Method 
	
	Method Update()
		If GameArrayLen <> 0 Then 
			LoadCoverTexture()
		EndIf
		If Positioned = False Then 
			OldCurrentGamePos = CurrentGamePos
		EndIf 
		
		If LowProcessor = False Then
			tempx = EntityPitch(Mesh)
			tempy = EntityYaw(Mesh)
			tempz = EntityRoll(Mesh)
			
			If Positioned = True And OldCurrentGamePos <> CurrentGamePos Then
				Positioned = False
			EndIf
			
			If (x - EntityX(Mesh , GlobalPosition) ) < 0.05 And (y - EntityY(Mesh , GlobalPosition) ) < 0.05 And (z - EntityZ(Mesh , GlobalPosition) ) < 0.05 Then
				If (Rotx - EntityPitch(Mesh) ) < 0.1 And (Roty - EntityYaw(Mesh) ) < 0.1 And (Rotz - EntityRoll(Mesh) ) < 0.1 Then
					Positioned = True
				EndIf 
			EndIf 
				
			RotateEntity(Mesh , 0 , 0 , 0 )
			MoveEntity(Mesh , ((x - EntityX(Mesh,GlobalPosition) ) / 10^(1/SpeedRatio)), ((y - EntityY(Mesh,GlobalPosition) ) / 2^(1/SpeedRatio)) , ((z - EntityZ(Mesh,GlobalPosition) ) / 2^(1/SpeedRatio)) )
			RotateEntity(Mesh , tempx , tempy , tempz )
			If Abs((Roty - EntityYaw(Mesh) ) / 10^(1/SpeedRatio)) < 1 Then
				If Roty = 180 Then
					RotateEntity(Mesh , EntityPitch(Mesh) , 180 , EntityRoll(Mesh))
				ElseIf Roty = 0
					RotateEntity(Mesh , EntityPitch(Mesh) , 0 , EntityRoll(Mesh))
				EndIf
			Else
				TurnEntity(Mesh , (Rotx - EntityPitch(Mesh)) , ((Roty - EntityYaw(Mesh) ) / 10^(1/SpeedRatio)) , (Rotz - EntityRoll(Mesh)) , 1 )
			EndIf
		EndIf 

	End Method
	
	Method LoadCoverTexture()
		Local Hi:Float
		Local BHi:Float
		If EntityInView(Mesh , Camera)>0 Or EntityInView(BackMesh , Camera)>0 Then
			If Textured = False Then
				If FileType(GAMEDATAFOLDER + GameArray[Position] + FolderSlash+"Banner_OPT.jpg") = 1 Then
					If ListContains(ProcessedTextures , GAMEDATAFOLDER + GameArray[Position] + FolderSlash+"Banner_OPT.jpg") = True Then
						Tex = LoadPreloadedTexture(GAMEDATAFOLDER + GameArray[Position] + FolderSlash+"Banner_OPT.jpg")
						If Tex <> Null
							EntityTexture(Mesh , Tex)
							If Reflections = True Then 							
								EntityTexture(ReflectMesh , Tex)
							EndIf 
							LockMutex(TTexture.Mutex_tex_list)
							'Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
							'Self.y = Hi-1
							UnlockMutex(TTexture.Mutex_tex_list)
														
							'ScaleEntity(Mesh , 0.75 , Hi , 0)
							'PositionEntity(Mesh , EntityX(Mesh) , Hi - 1 , EntityZ(Mesh) )
							'NormY = Hi - 1
							'y = NormY
							LockMutex(TTexture.Mutex_tex_list)
							ListAddLast(InUseTextures , tex.file)
							UnlockMutex(TTexture.Mutex_tex_list)
							Textured = True 
						EndIf	
					Else
						Tex = LoadPreloadedTexture(RESFOLDER + "BannerLoading.png")	
						If Tex <> Null Then
							EntityTexture(Mesh , Tex)
							If Reflections = True Then 							
								EntityTexture(ReflectMesh , Tex)
							EndIf
							LockMutex(TTexture.Mutex_tex_list)
							'Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
							'Self.y = Hi-1
							UnlockMutex(TTexture.Mutex_tex_list)
							'ScaleEntity(Mesh , 0.75 , Hi , 0)
							'PositionEntity(Mesh , EntityX(Mesh) , Hi - 1 , EntityZ(Mesh) )							
							'NormY = Hi - 1
							'y = NormY
							Textured = False
						Else
							RuntimeError "Loading.jpg Missing!"
						EndIf							
					EndIf
				Else
					Tex = LoadPreloadedTexture(RESFOLDER + "NoBanner.png",2)	
					If Tex <> Null Then
						EntityTexture(Mesh , tex)
						If Reflections = True Then 						
							EntityTexture(ReflectMesh , Tex)
						EndIf 
						LockMutex(TTexture.Mutex_tex_list)
						'Hi = Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth)
						'Self.y = Hi-1
						UnlockMutex(TTexture.Mutex_tex_list)
						'ScaleEntity(Mesh , 0.75 , Hi , 0)
						'PositionEntity(Mesh , EntityX(Mesh) , Hi - 1 , EntityZ(Mesh) )
						'NormY = Hi - 1
						'y = NormY
						
						'LockMutex(TTexture.Mutex_tex_list)
						'ScaleEntity(Mesh , 0.75 , Float(0.75) * (Float(tex.pixHeight) / tex.pixWidth) , 0)
						'UnlockMutex(TTexture.Mutex_tex_list)
						Textured = True
					Else
						RuntimeError "NoBanner.png Missing!"
					EndIf
				EndIf	

				
			EndIf
			If BackTextured = False Then 
				If FileType(GAMEDATAFOLDER + GameArray[Position] + FolderSlash+"Back_OPT.jpg") = 1 Then
					If ListContains(ProcessedTextures , GAMEDATAFOLDER + GameArray[Position] + FolderSlash+"Back_OPT.jpg") = True Then
						BackTex = LoadPreloadedTexture(GAMEDATAFOLDER + GameArray[Position] + FolderSlash+"Back_OPT.jpg")
						If BackTex <> Null
							EntityTexture(BackMesh , BackTex)
							If Reflections = True Then 
								EntityTexture(BackReflectMesh , BackTex)
							EndIf 
							LockMutex(TTexture.Mutex_tex_list)
							ListAddLast(InUseTextures , BackTex.file)
							UnlockMutex(TTexture.Mutex_tex_list)
							BackTextured = True 
						EndIf	
					Else
						BackTex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
						If BackTex <> Null Then
							EntityTexture(BackMesh , BackTex)
							If Reflections = True Then 							
								EntityTexture(BackReflectMesh , BackTex)
							EndIf 
							BackTextured = False
						Else
							RuntimeError "Loading.jpg Missing!"
						EndIf							
					EndIf
				Else
					BackTex = LoadPreloadedTexture(RESFOLDER + "NoCover.jpg")	
					If BackTex <> Null Then
						EntityTexture(BackMesh , BackTex)
						If Reflections = True Then 						
							EntityTexture(BackReflectMesh , BackTex)
						EndIf 
						BackTextured = True
					Else
						RuntimeError "NoCover.jpg Missing!"
					EndIf
				EndIf	
			EndIf
		Else
			If LowMemory = True Then
				If Textured = True Then
					LockMutex(TTexture.Mutex_tex_list)
					ListRemove(InUseTextures , Tex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					Tex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
					If Tex <> Null Then
						EntityTexture(Mesh , Tex)
						If Reflections = True Then 						
							EntityTexture(ReflectMesh , Tex)
						EndIf 
						Textured = False
					Else
						RuntimeError "Loading.jpg Missing!"
					EndIf		
				EndIf
				If BackTextured = True Then
					LockMutex(TTexture.Mutex_tex_list)
					ListRemove(InUseTextures , BackTex.file)
					UnlockMutex(TTexture.Mutex_tex_list)
					BackTex = LoadPreloadedTexture(RESFOLDER + "Loading.jpg")	
					If BackTex <> Null Then
						EntityTexture(BackMesh , BackTex)
						If Reflections = True Then 						
							EntityTexture(BackReflectMesh , BackTex)
						EndIf 
						BackTextured = False
					Else
						RuntimeError "Loading.jpg Missing!"
					EndIf		
				EndIf				
			EndIf
		EndIf 
		
		
		
	End Method
	
	Method Clear()
		FreeEntity(Mesh)
		LockMutex(TTexture.Mutex_tex_list)
		If Tex <> Null Then
			ListRemove(InUseTextures , Tex.file)
		EndIf
		UnlockMutex(TTexture.Mutex_tex_list)
	End Method
	
	Method Pos:Float(Num:Int , Axis:Int)
		Local CoverDistance:Float 
		Select CoverMode
			Case 1
				CoverDistance = 1 
			Case 2
				CoverDistance = 1.6
		End Select
		
		Select CoverMode
			Case 1
				Select Axis
					Case 1
					
						Select Num
							Case 3
								Return -1.2*CoverDistance
							Case 4
								Return 0
							Case 5
								Return 1.2*CoverDistance
							
							Default
								Return (Num-4)*CoverDistance		
						End Select
					
						
					Case 2
						Return NormY
					Case 3
						Select Num
							Case 4
								Return -0.5
							Default
								If Num <> 4 Then
									Return 0
								Else
									RuntimeError "Invalid Cover Num"					
								EndIf
						End Select
					Default
						RuntimeError "Invalid Axis"
				End Select
			Case 2
				Select Axis
					Case 1
						Select Num
							Case 4
								Return 0
							
							Default
								If Num > 4 Then 
									Return ((Num - 4) * CoverDistance) + 1
								ElseIf Num < 4 Then
									Return ((Num - 4) * CoverDistance) - 1
								EndIf
						End Select
					Case 2
						Return NormY
					Case 3
						Return 0
					Default
						RuntimeError "Invalid Axis"
				End Select
			
		End Select 
	End Method 
	
	Method Rot:Float(Num:Int , Axis:Int)
		Select CoverMode
			Case 1		
				Select Axis
					Case 1
						Return 0
					Case 2
						Select Num
							Case 4
								Return 0
							Default
								If Num > 4 Then
									Return - 40
								ElseIf Num < 4 Then
									Return 40
								Else
									RuntimeError "Invalid Cover Num"
								EndIf
						End Select
					Case 3
						Return 0
					Default
						RuntimeError "Invalid Axis"
				End Select
			Case 2
				Return 0
		End Select
	End Method 	
	
End Type




Function CreateCover:TMesh(CType:Int,parent_ent:TEntity=Null)
		Local mesh:TMesh=TMesh.CreateMesh(parent_ent)
	
		Local surf:TSurface=mesh.CreateSurface()
			
		surf.AddVertex(-1.0,-1.0,-1.0)
		surf.AddVertex(-1.0, 1.0,-1.0)
		surf.AddVertex( 1.0, 1.0,-1.0)
		surf.AddVertex( 1.0,-1.0,-1.0)

		surf.VertexNormal(0,0.0,0.0,-1.0)
		surf.VertexNormal(1,0.0,0.0,-1.0)
		surf.VertexNormal(2,0.0,0.0,-1.0)
		surf.VertexNormal(3,0.0,0.0,-1.0)
	

		If CType = 0 Then
			surf.VertexTexCoords(0,0.0,1.0)
			surf.VertexTexCoords(1,0.0,0.0)
			surf.VertexTexCoords(2,1.0,0.0)
			surf.VertexTexCoords(3,1.0,1.0)		
			surf.VertexTexCoords(0,0.0,1.0,0.0,1)
			surf.VertexTexCoords(1,0.0,0.0,0.0,1)
			surf.VertexTexCoords(2,1.0,0.0,0.0,1)
			surf.VertexTexCoords(3 , 1.0 , 1.0 , 0.0 , 1)
		Else
			surf.VertexTexCoords(3,0.0,1.0)
			surf.VertexTexCoords(2,0.0,0.0)
			surf.VertexTexCoords(1,1.0,0.0)
			surf.VertexTexCoords(0,1.0,1.0)		
			surf.VertexTexCoords(3,0.0,1.0,0.0,1)
			surf.VertexTexCoords(2,0.0,0.0,0.0,1)
			surf.VertexTexCoords(1,1.0,0.0,0.0,1)
			surf.VertexTexCoords(0 , 1.0 , 1.0 , 0.0 , 1)						
		EndIf
						
		surf.AddTriangle(0,1,2) ' front
		surf.AddTriangle(0,2,3)

		Return mesh
End Function

Type GameListType
	Field GameNameList:String[GameArrayLen]
	Field GameListLen:Int 
	Field StartX:Int
	Field StartY:Int
	Field EndX:Int
	Field EndY:Int 
	Field FontHeight:Int
	Field Selected:Int
	Field SelectedAlpha:Float = 1
	Field SelectedAlphaDir:Int = -1
	Field MaxWidth:Int 
			
	Method Init(SX:Int , SY:Int , EX:Int , EY:Int)
		StartX = SX
		StartY = SY
		EndX = EX
		EndY = EY
		Local GameNode:GameReadType = New GameNode
		For a = 0 To GameArrayLen - 1
			GameNode.GetGame(GameArray[a])
			GameNameList[a] = GameNode.Name
		Next
		GameNode = Null
		
		SetImageFont(MainTextFont)
		FontHeight = TextHeight("A") + (Float(5) / 600) * GHeight
		GameListLen = Floor(Float(EndY - StartY) / FontHeight) - 2
		EndY = (GameListLen + 2) * FontHeight + StartY
		
		For a = 0 To GameArrayLen - 1
			If MaxWidth < TextWidth(GameNameList[a]) Then
				MaxWidth = TextWidth(GameNameList[a])
			EndIf 
		Next 	
		
		If EndX - 2*FontHeight - MaxWidth > StartX  Then 
			StartX = EndX - 2 * FontHeight - MaxWidth
		EndIf
		

		
	End Method
	
	Method Max2D()
		SetColor(0 , 0 , 0)
		SetAlpha(0.8)
		DrawRect(StartX,StartY,EndX-StartX,EndY-StartY)
		
		Local b:Int = 0
		SetColor(255 , 255 , 255)
		SetAlpha(1)
		SetImageFont(MainTextFont)
	
		
		If CurrentGamePos < Floor(Float(GameListLen)/2) Then
			b = 0
			For a = 0 To Min(GameArrayLen - 1 , GameListLen - 1)
				DrawTextLines(a,b)
				b = b + 1
			Next 
		ElseIf CurrentGamePos > GameArrayLen - Ceil(Float(GameListLen)/2) Then
			b = 0
			For a = Max(0,GameArrayLen - Ceil(Float(GameListLen))) To GameArrayLen - 1
				DrawTextLines(a,b)
				b = b + 1
			Next 		
		Else
			b = 0
			For a = Max(0 , CurrentGamePos - Floor(Float(GameListLen) / 2) ) To Min(GameArrayLen - 1 , Max(0 , CurrentGamePos - Floor(Float(GameListLen) / 2) )+GameListLen-1) 'Min(GameArrayLen - 1 , CurrentGamePos + Ceil(Float(GameListLen) / 2) )
				DrawTextLines(a,b)
				b = b + 1
			Next
		EndIf 
	End Method
	
	Method Update()
		If MouseX() > StartX + FontHeight And MouseX() < EndX - FontHeight And MouseY() > StartY + FontHeight And MouseY() < EndY - FontHeight Then
			If SelectedAlphaDir = -1 Then
				SelectedAlpha = SelectedAlpha + 0.01
			Else
				SelectedAlpha = SelectedAlpha - 0.01
			EndIf
			If SelectedAlpha > 0.7 Then
				SelectedAlphaDir = 1
			ElseIf SelectedAlpha < 0.3 Then
				SelectedAlphaDir = -1
			EndIf 		
			Selected = (MouseY() - StartY - FontHeight) / FontHeight
		Else
			Selected = -1
		EndIf 
	End Method
	
	Method UpdateMouse()
		If MouseClick = 1 And Selected <> - 1 Then
			If GameListLen < GameArrayLen Then 
				If CurrentGamePos < Floor(Float(GameListLen)/2) Then
					CurrentGamePos = Selected
				ElseIf CurrentGamePos > GameArrayLen - Ceil(Float(GameListLen)/2) Then
					CurrentGamePos = GameArrayLen - (GameListLen - Selected)
				Else
					CurrentGamePos = CurrentGamePos + Ceil(Selected - Float(GameListLen)/2)
				EndIf 
			Else
				CurrentGamePos = Selected
			EndIf 
		EndIf 
	End Method 
	
	Method DrawTextLines(a:Int , b:Int)
		Local c:Int
		Local tempDrawText:String 
		If a = CurrentGamePos Then
			SetColor(135 , 153 , 255)
		Else
			SetColor(255 , 255 , 255)
		EndIf
		If b = Selected Then
			SetColor(135 , 153 , 255)
			SetAlpha(SelectedAlpha)
		EndIf
		If TextWidth(GameNameList[a]) > EndX-StartX-2*FontHeight Then 
			For c = 1 To Len(GameNameList[a])
				If TextWidth(Mid(GameNameList[a] , 1 , c) ) > EndX - StartX - 2 * FontHeight Then
					Exit 
				Else
					tempDrawText = Mid(GameNameList[a] , 1 , c)
				EndIf 
			Next
			DrawText(tempDrawText , StartX + FontHeight , StartY + FontHeight + (b * FontHeight) )
		Else
			DrawText(GameNameList[a] , StartX + FontHeight , StartY + FontHeight + (b * FontHeight) )
		EndIf
		SetAlpha(1)
		SetColor(255,255,255)
	End Method 
	
	Method Clear()
		GameNameList = Null
	End Method 
End Type 