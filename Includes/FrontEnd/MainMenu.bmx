
Type MainMenuType Extends GeneralType
	Field MenuFlow:MenuFlowType
	Field PlatformList:TList
	Field GenreList:TList
	Field YearList:TList
	Field ScoreList:TList
	Field CompletedList:TList 
	Field MainList:TList
	Field PlayersList:TList
	Field CoOpList:TList
	Field DeveloperList:TList
	Field PublisherList:TList
	Field CertificateList:TList
	
	Field KeyDelayTimer:Int 
	
	Method Init()
		ResetFilters()
		PopulateGames()
		LoadMenuItems()
		MenuFlow = New MenuFlowType
		'MenuFlow.CoverMode = 1
		'MenuFlow.ReflectiveFloorEnabled = True 
		FilterType = ""
		FilterName = ""
		MenuFlow.Init(MainList,"Main")
		
		ListAddLast(UpdateTypeList , Self)	
	End Method
	
	Method Clear()
		MenuFlow.Clear()
		ListRemove(UpdateTypeList , Self)	
		
	End Method 
	
	Method Update()
		MenuFlow.Update()
	End Method
	
	Method UpdateKeyboard()
		If KeyDown(KEYBOARD_RIGHT) Then
			If MilliSecs() - KeyDelayTimer > 100 
				MenuFlow.CurrentMenuPos = MenuFlow.CurrentMenuPos + 1
				KeyDelayTimer = MilliSecs()
				If MenuFlow.CurrentMenuPos > MenuFlow.MenuArrayLen - 1 Then MenuFlow.CurrentMenuPos = MenuFlow.MenuArrayLen - 1 'CurrentGamePos - GameArrayLen
				If MenuFlow.MenuResFolder = "Main" Then 
					MainMenuPos = MenuFlow.CurrentMenuPos
				EndIf 
			EndIf
			Return True 
		EndIf
		If KeyDown(KEYBOARD_LEFT) Then
			If MilliSecs() - KeyDelayTimer > 100 
				MenuFlow.CurrentMenuPos = MenuFlow.CurrentMenuPos - 1
				KeyDelayTimer = MilliSecs()		
				If MenuFlow.CurrentMenuPos < 0 Then MenuFlow.CurrentMenuPos = 0'CurrentGamePos + GameArrayLen
				If MenuFlow.MenuResFolder = "Main" Then 
					MainMenuPos = MenuFlow.CurrentMenuPos
				EndIf 				
			EndIf
			Return True 
		EndIf		
		If KeyDown(KEYBOARD_ENTER) Then
			MenuItemClicked(MenuFlow.CurrentMenuPos)
		EndIf 
	End Method
	
	Method UpdateJoy()
		For J=0 To JoyCount()-1 
			If JoyHit(JOY_ENTER,J) Then
				MenuItemClicked(MenuFlow.CurrentMenuPos)
				Return True 
			EndIf
		
			If Tol(JoyX(J),0,0.2) <> 1 Then 
				If JoyX(J) > 0 Then 
					If MilliSecs() - KeyDelayTimer > 100 
						MenuFlow.CurrentMenuPos = MenuFlow.CurrentMenuPos + 1
						KeyDelayTimer = MilliSecs()
						If MenuFlow.CurrentMenuPos > MenuFlow.MenuArrayLen - 1 Then MenuFlow.CurrentMenuPos = MenuFlow.MenuArrayLen - 1 'CurrentGamePos - GameArrayLen
						If MenuFlow.MenuResFolder = "Main" Then 
							MainMenuPos = MenuFlow.CurrentMenuPos
						EndIf 
					EndIf
					Return True 
				Else
					If MilliSecs() - KeyDelayTimer > 100 
						MenuFlow.CurrentMenuPos = MenuFlow.CurrentMenuPos - 1
						KeyDelayTimer = MilliSecs()		
						If MenuFlow.CurrentMenuPos < 0 Then MenuFlow.CurrentMenuPos = 0'CurrentGamePos + GameArrayLen
						If MenuFlow.MenuResFolder = "Main" Then 
							MainMenuPos = MenuFlow.CurrentMenuPos
						EndIf 				
					EndIf
					Return True  			
				EndIf 
			EndIf 
		
			If Tol(JoyHat(J),0.25,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100 
					MenuFlow.CurrentMenuPos = MenuFlow.CurrentMenuPos + 1
					KeyDelayTimer = MilliSecs()
					If MenuFlow.CurrentMenuPos > MenuFlow.MenuArrayLen - 1 Then MenuFlow.CurrentMenuPos = MenuFlow.MenuArrayLen - 1 'CurrentGamePos - GameArrayLen
					If MenuFlow.MenuResFolder = "Main" Then 
						MainMenuPos = MenuFlow.CurrentMenuPos
					EndIf 
				EndIf
				Return True 			
			EndIf 
			If Tol(JoyHat(J),0.75,0.1) Then 
				If MilliSecs() - KeyDelayTimer > 100 
					MenuFlow.CurrentMenuPos = MenuFlow.CurrentMenuPos - 1
					KeyDelayTimer = MilliSecs()		
					If MenuFlow.CurrentMenuPos < 0 Then MenuFlow.CurrentMenuPos = 0'CurrentGamePos + GameArrayLen
					If MenuFlow.MenuResFolder = "Main" Then 
						MainMenuPos = MenuFlow.CurrentMenuPos
					EndIf 				
				EndIf
				Return True 		
			EndIf 			
		Next
		Return False 
	End Method 
	
	
	Method MenuItemClicked(item:Int)
		FlushKeys()
		PrintF(item)
		If MenuFlow.MenuArray[item] = ".." Then 
			MenuFlow.Clear()
			MenuFlow.Init(MainList , "Main")
			FilterType = ""
			FilterName = ""
		Else
			Select MenuFlow.MenuResFolder
				Case "Main"
					Select MenuFlow.MenuArray[item]	
								
						
						Case "All Games"
							PopulateGames()
							FilterType = "All Games"
							FilterName = ""
							ChangeInterface(CurrentInterfaceNumber)
						Case "Platforms"
							MenuFlow.Clear()
							MenuFlow.Init(PlatformList , "Platforms" , 1)
							FilterType = "Platform"
							FilterName = ""
						Case "Genres"
							MenuFlow.Clear()
							MenuFlow.Init(GenreList , "Genres" , 1)
							FilterType = "Genre"
							FilterName = ""
						Case "Release Date"
							MenuFlow.Clear()
							MenuFlow.Init(YearList , "Years" , 1)
							FilterType = "Release Date"
							FilterName = ""
						Case "Rating"
							MenuFlow.Clear()
							MenuFlow.Init(ScoreList , "Rating" , 1)
							FilterType = "Rating"
							FilterName = ""
						Case "Completed"
							MenuFlow.Clear()
							MenuFlow.Init(CompletedList , "Completed" , 1)						
							FilterType = "Status"
							FilterName = ""
						Case "Players"
							MenuFlow.Clear()
							MenuFlow.Init(PlayersList , "Players" , 1)
							FilterType = "Players"
							FilterName = ""						
						Case "Co-Op"
							MenuFlow.Clear()
							MenuFlow.Init(CoOpList , "Co-Op" , 1)
							FilterType = "Co-Op"
							FilterName = ""													
						
						Case "Developers"
							MenuFlow.Clear()
							MenuFlow.Init(DeveloperList , "Developers" , 1)
							FilterType = "Developer"
							FilterName = ""												
						Case "Publisher"
							MenuFlow.Clear()
							MenuFlow.Init(PublisherList , "Publisher" , 1)
							FilterType = "Publisher"
							FilterName = ""												
						Case "Certificate"
							MenuFlow.Clear()
							MenuFlow.Init(CertificateList , "Certificate" , 1)
							FilterType = "Certificate"
							FilterName = ""								
					End Select
				Case "Platforms"	
					If MenuFlow.MenuArray[item] = "Sort By Platform" Then
						FilterName = ""
						GamesSortFilter = "Platform"
					Else
						GamesPlatformFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf
					PopulateGames()
					ChangeInterface(CurrentInterfaceNumber)
				Case "Genres"
					If MenuFlow.MenuArray[item] = "Sort By Genre" Then
						FilterName = ""
						GamesSortFilter = "Genre"
					Else				
						GamesGenreFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					
					PopulateGames()					
					ChangeInterface(CurrentInterfaceNumber)
				Case "Years"
					If MenuFlow.MenuArray[item] = "Sort By Release Date" Then				
						FilterName = ""
						GamesSortFilter = "Release Date"
					Else
						GamesRelFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					
					PopulateGames()
					ChangeInterface(CurrentInterfaceNumber)
				Case "Rating"
					If MenuFlow.MenuArray[item] = "Sort By Rating" Then
						FilterName = ""
						GamesSortFilter = "Rating"
					Else				
						GamesRateFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					
					PopulateGames()
					ChangeInterface(CurrentInterfaceNumber)					
				Case "Completed"
					If MenuFlow.MenuArray[item] = "Sort by Completed Status" Then				
						FilterName = ""
						GamesSortFilter = "Completed"
					Else	
						GamesCompFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					PopulateGames()					
					ChangeInterface(CurrentInterfaceNumber)					
					
				Case "Players"
					If MenuFlow.MenuArray[item] = "Sort by Player Number" Then				
						FilterName = ""
						GamesSortFilter = "Players"
					Else	
						GamesPlayerFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					PopulateGames()					
					ChangeInterface(CurrentInterfaceNumber)					
					
				Case "Co-Op"												
					If MenuFlow.MenuArray[item] = "Sort by Co-Op" Then				
						FilterName = ""
						GamesSortFilter = "Co-Op"
					Else	
						GamesCoopFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					PopulateGames()					
					ChangeInterface(CurrentInterfaceNumber)		
										
				Case "Developers"
					If MenuFlow.MenuArray[item] = "Sort by Developer" Then				
						FilterName = ""
						GamesSortFilter = "Developer"
					Else	
						GamesDeveloperFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					PopulateGames()					
					ChangeInterface(CurrentInterfaceNumber)				
									
				Case "Publisher"
					If MenuFlow.MenuArray[item] = "Sort by Publisher" Then				
						FilterName = ""
						GamesSortFilter = "Publisher"
					Else	
						GamesPublisherFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					PopulateGames()					
					ChangeInterface(CurrentInterfaceNumber)
					
				Case "Certificate"
					If MenuFlow.MenuArray[item] = "Sort by Certificate" Then				
						FilterName = ""
						GamesSortFilter = "Certificate"
					Else	
						GamesCertificateFilter = MenuFlow.MenuArray[item]
						FilterName = MenuFlow.MenuArray[item]
					EndIf 
					PopulateGames()					
					ChangeInterface(CurrentInterfaceNumber)										
			End Select		
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
			For a = 0 To MenuFlow.MenuArrayLen - 1
				If MenuFlow.Covers[a].MouseOver() = True
					ListAddLast(ClickCoverList , String(a) )
				EndIf
			Next	
			If ClickCoverList.Count() > 0 Then
				If ListContains(ClickCoverList , String(MenuFlow.CurrentMenuPos) ) Then
					MenuItemClicked(MenuFlow.CurrentMenuPos)
				Else
					For b = EachIn ClickCoverList
						a = Int(String(b))
						If a > MenuFlow.CurrentMenuPos Then
							If a < SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf
						ElseIf a < MenuFlow.CurrentMenuPos Then
							If a > SelectedCover Or SelectedCover = - 1 Then
								SelectedCover = a
							EndIf						
						EndIf
					Next
					MenuFlow.CurrentMenuPos = SelectedCover
				EndIf	
			EndIf
			Return True 
		EndIf	
		If MouseSwipe = 1 Then
			MouseSwipe = 0
			PrintF("You swiped mouse, X:" + String(MouseEnd[0] - MouseStart[0]) + " T:" + MouseSwipeTime)
			If MenuFlow.CurrentMenuPos = MenuFlow.MenuArrayLen - 1 Or MenuFlow.CurrentMenuPos = 0 Then DoNotStopSwipe = True 
			MenuFlow.CurrentMenuPos = MenuFlow.CurrentMenuPos + Int( ( ( (Float(MouseEnd[0] - MouseStart[0]) * 5) / 1000) * GWidth	) / MouseSwipeTime)
			If DoNotStopSwipe = False Then
				If MenuFlow.CurrentMenuPos > MenuFlow.MenuArrayLen - 1 Then MenuFlow.CurrentMenuPos = MenuFlow.MenuArrayLen - 1
				If MenuFlow.CurrentMenuPos < 0 Then MenuFlow.CurrentMenuPos = 0
			Else
				If MenuFlow.CurrentMenuPos > MenuFlow.MenuArrayLen - 1 Then MenuFlow.CurrentMenuPos = 0
				If MenuFlow.CurrentMenuPos < 0 Then MenuFlow.CurrentMenuPos = MenuFlow.MenuArrayLen - 1
			EndIf
			Return True 
		ElseIf MouseSwipe = 2 Then
			MouseSwipe = 3
			MenuFlow.CurrentMenuPos = MenuFlow.CurrentMenuPos + Int(((Float(MouseX()-(GWidth/2))/ 800)*GWidth) / 75)
			
			If MenuFlow.CurrentMenuPos > MenuFlow.MenuArrayLen - 1 Then MenuFlow.CurrentMenuPos = MenuFlow.MenuArrayLen - 1
			If MenuFlow.CurrentMenuPos < 0 Then MenuFlow.CurrentMenuPos = 0		
			Return True
		EndIf
		Return False 		
	End Method 
	
	Method Max2D()
		MenuFlow.Max2D()
	End Method 
	
	Method LoadMenuItems()
		PlatformList = CreateList()
		GenreList = CreateList()
		YearList = CreateList()
		ScoreList = CreateList()
		MainList = CreateList()
		CompletedList = CreateList()
		
		PlayersList = CreateList()
		CoOpList = CreateList()
		DeveloperList = CreateList()
		PublisherList = CreateList()
		CertificateList = CreateList()
		
		
		ListAddLast(MainList , "Platforms")
		ListAddLast(MainList , "Genres")
		ListAddLast(MainList , "Release Date")
		ListAddLast(MainList , "Rating")
		ListAddLast(MainList , "Completed")


		
		ListAddLast(MainList , "Players")
		ListAddLast(MainList , "Co-Op")
		ListAddLast(MainList , "Developers")
		ListAddLast(MainList , "Publisher")
		ListAddLast(MainList , "Certificate")
		
		Local a:Int
		Local Genre:String 
		Local GameNode:GameReadType = New GameReadType
		For a = 0 To GameArrayLen - 1
			GameNode.GetGame(GameArray[a])
			If ListContains(PlatformList , GameNode.Plat) <> 1 And GameNode.Plat <> "" Then
				ListAddLast(PlatformList , GameNode.Plat)
			EndIf
			For Genre = EachIn GameNode.Genres
				If ListContains(GenreList , Genre) <> 1 Then
					ListAddLast(GenreList , Genre)
				EndIf		
			Next
			If ListContains(YearList , Left(GameNode.ReleaseDate,4)) <> 1 And Left(GameNode.ReleaseDate,4) <> "" And Left(GameNode.ReleaseDate,4) <> "-1" Then
				ListAddLast(YearList , Left(GameNode.ReleaseDate,4))
			EndIf		
			If ListContains(ScoreList , GameNode.Rating) <> 1 And GameNode.Rating <> "" And GameNode.Rating <> "0" Then
				ListAddLast(ScoreList , GameNode.Rating)
			EndIf	
			If ListContains(CompletedList , "Completed") <> 1 And GameNode.Completed = 1 Then
				ListAddLast(CompletedList , "Completed")
			EndIf
			If ListContains(CompletedList , "Not Completed") <> 1 And GameNode.Completed = 0 Then
				ListAddLast(CompletedList , "Not Completed")
			EndIf 			
			If ListContains(DeveloperList , GameNode.Dev) <> 1 And GameNode.Dev <> "" Then
				ListAddLast(DeveloperList , GameNode.Dev)
			EndIf	
			If ListContains(PublisherList , GameNode.Pub) <> 1 And GameNode.Pub <> "" Then
				ListAddLast(PublisherList , GameNode.Pub)
			EndIf				
			If ListContains(CertificateList , GameNode.Cert) <> 1 And GameNode.Cert <> "" Then
				ListAddLast(CertificateList , GameNode.Cert)
			EndIf						
			If ListContains(PlayersList , GameNode.Players) <> 1 And GameNode.Players <> "" Then
				ListAddLast(PlayersList , GameNode.Players)
			EndIf					
			If ListContains(CoOpList , GameNode.Coop) <> 1 And GameNode.Coop <> "" Then
				ListAddLast(CoOpList , GameNode.Coop)
			EndIf				
			
		Next
		
		SortList(PlatformList , True)
		SortList(GenreList , True)
		SortList(YearList , True)
		SortList(ScoreList , True)
		SortList(MainList , True)
		SortList(PlayersList , True)
		SortList(CoOpList , True)
		SortList(DeveloperList , True)
		SortList(PublisherList , True)
		SortList(CertificateList , True)
		
		If ListContains(ScoreList , "10") Then
			ListRemove(ScoreList , "10")
			ListAddLast(ScoreList , "10")
		EndIf 
		
		
		ListAddFirst(PlatformList , "Sort By Platform")
		ListAddFirst(GenreList , "Sort By Genre")
		ListAddFirst(YearList , "Sort By Release Date")
		ListAddFirst(ScoreList , "Sort By Rating")
		ListAddFirst(CompletedList , "Sort by Completed Status")
		ListAddFirst(PlayersList , "Sort by Player Number")
		ListAddFirst(CoOpList , "Sort by Co-Op")
		ListAddFirst(DeveloperList , "Sort by Developer")
		ListAddFirst(PublisherList , "Sort by Publisher")
		ListAddFirst(CertificateList , "Sort by Certificate")		

		
		ListAddFirst(MainList , "All Games")	
		ListAddFirst(PlatformList , "..")
		ListAddFirst(GenreList , "..")
		ListAddFirst(YearList , "..")
		ListAddFirst(ScoreList , "..")
		ListAddFirst(CompletedList , "..")
		
		ListAddFirst(PlayersList , "..")
		ListAddFirst(CoOpList , "..")
		ListAddFirst(DeveloperList , "..")
		ListAddFirst(PublisherList , "..")
		ListAddFirst(CertificateList , "..")		
	
	End Method  	
	
End Type 

Type MenuFlowType
	Field Parent:TPivot
	Field Covers:MainMenuItemType[]
	Field CoverFloor:TMesh	
	Field MenuArray:String[]
	Field MenuArrayLen:Int 
	Field MenuResFolder:String
	Field CurrentMenuPos:Int
	Field DelayPos:Int 
	
	Function UpdateStack(List:TList , ResourceFolder:String)
		Local Stack:TList = CreateList()
		Local item:String
		If FileType(RESFOLDER + "Menu"+FolderSlash+"Back.jpg") = 1 Then
			ListAddLast(Stack , RESFOLDER + "Menu"+FolderSlash+"Back.jpg")
		EndIf 
		If FileType(RESFOLDER + "Menu"+FolderSlash+"Sort.jpg") = 1 Then
			ListAddLast(Stack , RESFOLDER + "Menu"+FolderSlash+"Sort.jpg")
		EndIf 
		
		For item = EachIn List
			If FileType(RESFOLDER + "Menu"+FolderSlash+ ResourceFolder + FolderSlash + item + ".jpg") = 1 Then
				ListAddLast(Stack , RESFOLDER + "Menu"+FolderSlash + ResourceFolder + FolderSlash + item + ".jpg")
			EndIf 
		Next
		
		
		LockMutex(Mutex_ProcessStack)
		ProcessStack = Stack
		UnlockMutex(Mutex_ProcessStack)	
	End Function	
	
	Method Init(List:TList , ResourceFolder:String , SetCurrentPos:Int = 0)
		DelayPos = 1
		FilterMenuEnabled = True 
		UpdateStack(List , ResourceFolder)
		CurrentMenuPos = SetCurrentPos
		If CurrentMenuPos > List.Count()-1 Then
			CurrentMenuPos = 0
		EndIf
		'MenuList = List 'Array
		MenuResFolder = ResourceFolder
		MenuArray = MenuArray[..List.count()]
		Covers = Covers[..List.Count()]
		Local item:String 
		Local a:Int = 0
		For item = EachIn List
			MenuArray[a] = item
			a = a + 1
		Next
		MenuArrayLen = List.Count()
		
		Local tex:TTexture 
				
		Parent = CreatePivot()
		PositionEntity Parent , x , y , z
		
		CoverFloor = CreateCube(Parent)
		PositionEntity CoverFloor , 0 , -1 , 0
		ScaleEntity CoverFloor , 100 , 0 , 100
		EntityAlpha CoverFloor , 0.8
		tex = LoadPreloadedTexture(RESFOLDER + "Black.jpg")	
		If tex <> Null
			EntityTexture(CoverFloor , tex)
		EndIf
					
		
		For a = 0 To MenuArrayLen - 1
			Covers[a] = New MainMenuItemType
			Covers[a].Position = a
			Covers[a].CoverNum = -1
			If Left(MenuArray[a],Len("Sort"))="Sort" Then
				Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash+"Sort.jpg"
			ElseIf MenuArray[a] = ".." Then 
				Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash+"Back.jpg"
			Else
				Select ResourceFolder
					Case "Genres"
						If FileType(RESFOLDER + "Menu"+FolderSlash + ResourceFolder + FolderSlash + MenuArray[a] + ".jpg") = 1 Then 
							Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash + ResourceFolder + FolderSlash + MenuArray[a] + ".jpg" 
						Else
							Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash+"Main"+FolderSlash+"Genres.jpg" 
						EndIf 						
					Case "Publisher"
						If FileType(RESFOLDER + "Menu"+FolderSlash + ResourceFolder + FolderSlash + MenuArray[a] + ".jpg") = 1 Then 
							Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash + ResourceFolder + FolderSlash + MenuArray[a] + ".jpg" 
						Else
							Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash+"Main"+FolderSlash+"Publisher.jpg" 
						EndIf 
					
					Case  "Developers" 
						If FileType(RESFOLDER + "Menu"+FolderSlash + ResourceFolder + FolderSlash + MenuArray[a] + ".jpg") = 1 Then 
							Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash + ResourceFolder + FolderSlash + MenuArray[a] + ".jpg" 
						Else
							Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash+"Main"+FolderSlash+"Developers.jpg" 
						EndIf 
					Default
						Covers[a].TexName = RESFOLDER + "Menu"+FolderSlash + ResourceFolder + FolderSlash + MenuArray[a] + ".jpg" 
				End Select
			EndIf 
			Covers[a].Init(Parent)
			b = Covers[a].Position
			Covers[a].x = Pos(b , 1 , Covers[a].NormY)
			Covers[a].y = Pos(b , 2 , Covers[a].NormY)
			Covers[a].z = Pos(b , 3 , Covers[a].NormY)
			Covers[a].Rotx = Rot(b , 1)
			Covers[a].Roty = Rot(b , 2)
			Covers[a].Rotz = Rot(b , 3)
			PositionEntity(Covers[a].Mesh , Covers[a].x , Covers[a].y , Covers[a].z , Covers[a].GlobalPosition)
			RotateEntity(Covers[a].Mesh , Covers[a].Rotx , Covers[a].Roty , Covers[a].Rotz)			
			
		Next
	
	End Method

	Method Max2D()
		SetImageFont(NameFont)
		SetColor(0,0,0)
		SetAlpha(0.7)
		DrawRect( (GWidth - TextWidth(MenuArray[CurrentMenuPos]) ) / 2 - 20 , GHeight / 1.2 , TextWidth(MenuArray[CurrentMenuPos]) + 40 , TextHeight(MenuArray[CurrentMenuPos]) + 5)
		SetColor(255 , 255 , 255)
		SetAlpha(1)
		DrawText(MenuArray[CurrentMenuPos] , (GWidth - TextWidth(MenuArray[CurrentMenuPos]) ) / 2 , GHeight / 1.2)			
	End Method 
	
	Method Update()
		Local a:Int , b:Int  
		'OldCurrentGamePos = CurrentGamePos
		For a = 0 To MenuArrayLen - 1
			Covers[a].Update()
			b = Covers[a].Position - CurrentMenuPos + 4
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
		
		If DelayPos = 1 Then
			If MenuResFolder = "Main" And MainMenuPos <> -1 Then
				CurrentMenuPos = MainMenuPos
			EndIf		
			DelayPos = 0
		EndIf 
	End Method


	Method Pos:Float(Num:Int , Axis:Int , NormY:Float)
		Local CoverDistance:Float = 1
		
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
	End Method 
	
	Method Rot:Float(Num:Int , Axis:Int)	
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
	End Method 	
	
	Method Clear()
		For a = 0 To MenuArrayLen - 1
			Covers[a].Clear()
			Covers[a] = Null
		Next		
		FreeEntity(Parent)
		Parent = Null
		FreeEntity(CoverFloor)
		CoverFloor = Null
		FilterMenuEnabled = False 
	End Method
	
End Type

Type MainMenuItemType
	Field Mesh:TMesh
	'Field BackMesh:TMesh	
	Field ReflectMesh:TMesh
	'Field BackReflectMesh:TMesh	
	'Field Reflections:Int 
	
	Field TexName:String
	
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
	'Field BackTextured:Int	
	Field Tex:TTexture
	'Field BackTex:TTexture
		
	
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
		endrem 
		Mesh = CreateCover(0 , Parent)
		'BackMesh = CreateCover(0 , Mesh)
		'RotateEntity(BackMesh,0,180,0)
		Textured = False
		'BackTextured = False
		EntityFX Mesh , 1
		'EntityFX BackMesh , 1
		'CoverNum = Position - CurrentGamePos + 4
		CoverNum = -1
		PositionEntity Mesh , Pos(CoverNum , 1) , Pos(CoverNum , 2) , Pos(CoverNum , 3)
		ScaleEntity Mesh , 0.75 , 1 , 0 
		RotateEntity Mesh , Rot(CoverNum , 1) , Rot(CoverNum , 2) , Rot(CoverNum , 3)		
		x = EntityX(Mesh)
		y = EntityY(Mesh)
		z = EntityZ(Mesh)
		Rotx = EntityPitch(Mesh)
		Roty = EntityYaw(Mesh)
		Rotz = EntityRoll(Mesh)
		
			ReflectMesh = CreateCover(1,Mesh)
			MoveEntity ReflectMesh , 0 , - 2.05 , 0
			EntityFX ReflectMesh , 1
			ScaleEntity ReflectMesh , - 1 , - 1 , 0
			
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
			tempx = EntityPitch(Mesh)
			tempy = EntityYaw(Mesh)
			tempz = EntityRoll(Mesh)
			RotateEntity(Mesh , 0 , 0 , 0 )
			MoveEntity(Mesh , ((x - EntityX(Mesh,GlobalPosition) ) / 10), ((y - EntityY(Mesh,GlobalPosition) ) / 2) , ((z - EntityZ(Mesh,GlobalPosition) ) / 2) )
			RotateEntity(Mesh , tempx , tempy , tempz )
			If Abs((Roty - EntityYaw(Mesh) ) / 10)*SpeedRatio < 1 Then
				If Roty = 180 Then
					RotateEntity(Mesh , EntityPitch(Mesh) , 180 , EntityRoll(Mesh))
				ElseIf Roty = 0
					RotateEntity(Mesh , EntityPitch(Mesh) , 0 , EntityRoll(Mesh))
				EndIf
			Else
				TurnEntity(Mesh , (Rotx - EntityPitch(Mesh))*SpeedRatio , ((Roty - EntityYaw(Mesh) ) / 10)*SpeedRatio , (Rotz - EntityRoll(Mesh))*SpeedRatio , 1 )
			EndIf
		EndIf 

	End Method
	
	Method LoadCoverTexture()		
		'NFIX: Make texture loaded have transparency layer (No Idea what this fix wants me to do)
		Local Hi:Float
		Local BHi:Float
		If EntityInView(Mesh , Camera)>0 Then
			If Textured = False Then
				If FileType(TexName) = 1 Then
					If ListContains(ProcessedTextures , TexName) = True Then
						Tex = LoadPreloadedTexture(TexName)
						If Tex <> Null
							EntityTexture(Mesh , Tex)
							EntityTexture(ReflectMesh , Tex)
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
							EntityTexture(ReflectMesh , Tex)
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
						EntityTexture(ReflectMesh , Tex)
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
		Local CoverDistance:Float = 1
	
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
	End Method 
	
	Method Rot:Float(Num:Int , Axis:Int)	
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
	End Method 	
	
End Type
	




