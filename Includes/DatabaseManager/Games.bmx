Function ValidateGames()
	Local GameNode:GameType
	ReadGamesDir = ReadDir(GAMEDATAFOLDER)
	Repeat
		Dir:String = NextFile(ReadGamesDir)
		If Dir = "" Then Exit
		If Dir="." Or Dir=".." Then Continue 
		
		GameNode = New GameType
		If GameNode.GetGame(Dir) = - 1 Then
			
		Else
			GameNode.SaveGame()
			GameNode.OptimizeArtwork()
		EndIf

	Forever
End Function

Type GameType Extends GameReadType

	Method SaveGame:Int()
		Local GName:String , GDesc:String
		Local MessageBox:wxMessageDialog
		
		GName = GameNameSanitizer(Self.Name) + "---" + Self.Plat
		GName = Lower(GName)
		GDesc = GameDescriptionSanitizer(Self.Desc)
		
		RenameFile(GAMEDATAFOLDER+ Self.OrginalName , GAMEDATAFOLDER+Lower(Self.OrginalName))
		Self.OrginalName = Lower(Self.OrginalName)
		
		'Self.Dir = StandardiseSlashes(Self.Dir)
		Self.ROM = StandardiseSlashes(Self.ROM)
		If Self.OrginalName = "" Or Self.OrginalName = Null Or Self.OrginalName = " " Then
			If FileType(GAMEDATAFOLDER + GName) = 2 Then
				MessageBox = New wxMessageDialog.Create(Null, GName+ " is already in the database, overwrite it? (All fan art will be deleted)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_YES Then
					DeleteCreateFolder(GAMEDATAFOLDER + GName)
				Else
					Return 2
				EndIf
			Else
				DeleteCreateFolder(GAMEDATAFOLDER + GName)
			EndIf
			
		Else
			If Self.OrginalName = GName Then
				
			Else
				If FileType(GAMEDATAFOLDER + GName) = 2 Then
					MessageBox = New wxMessageDialog.Create(Null , "Game name already exists using the old name" , "Info" , wxOK)
					PrintF("OldName: " + OrginalName)
					PrintF("NewName: " + GName)
					MessageBox.ShowModal()
					MessageBox.Free()
					For a = 1 To Len(Self.OrginalName)
						If Mid(Self.OrginalName , a , 3) = "---" Then
							Self.Name = Left(Self.OrginalName , a - 1)
							Self.Plat = Right(Self.OrginalName , Len(Self.OrginalName) - a - 2)
							Exit 
						EndIf 
					Next
					
					'Self.Name = Self.OrginalName
					GName = GameNameSanitizer(Self.Name) + "---" + Self.Plat
				Else
					RenameFile(GAMEDATAFOLDER + Self.OrginalName ,GAMEDATAFOLDER + GName)
				EndIf
			EndIf		
		EndIf
		If FileType(GAMEDATAFOLDER + GName) = 0 Then
			CustomRuntimeError("Error 33: GameType Folder Missing") 'MARK: Error 33
		EndIf
		
		Self.OutputInfo()
		Self.OutputArtInfo()
		'OutputIcon()
		'OutputFanart()
		Return 1
	End Method
	
	Method ExtractIcon(Override:Int)
		?Win32	
		Local GName:String = GameNameSanitizer(Self.Name) + "---" + Self.Plat
		Local temp:String , File:String
			
		Local EXE:String = StandardiseSlashes(StripCmdOpt(Self.RunEXE))
		DeleteCreateFolder(TEMPFOLDER + "Icons")
		DeleteCreateFolder(TEMPFOLDER + "Icons2")
		Local ExtractIcon:TProcess = CreateProcess(ResourceExtractPath + " /Source " + Chr(34) + EXE + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons"+FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1")
		If ExtractIcon <> Null Then 
			Repeat
				Delay 10
				If ProcessStatus(ExtractIcon)=0 Then Exit
			Forever	
		Else
			PrintF("Failed to extract Icon")
		EndIf 
		ReadIcons = ReadDir(TEMPFOLDER + "Icons"+FolderSlash)
		temp = ""
		Repeat
			File = NextFile(ReadIcons)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue
			If ExtractExt(File) = "ico" Then
				temp = TEMPFOLDER + "Icons"+FolderSlash + File
				Exit			
			EndIf
		Forever
		CloseDir(ReadIcons)		
		If temp = "" Then
		Else
			If FileType(GAMEDATAFOLDER + GName + FolderSlash +"Icon.ico") = 1 And Override = False Then
				'Do Nothing
			Else
				DeleteFile(GAMEDATAFOLDER + GName + FolderSlash +"Icon.ico")
				CopyFile(temp , GAMEDATAFOLDER + GName + FolderSlash +"Icon.ico")
			EndIf
						
		EndIf
		?
	End Method
	
	Method DownloadArtWorkThumbs(Log1:LogWindow , ArtType:Int)
		Local GName:String = Lower(GameNameSanitizer(Self.Name) + "---" + Self.Plat)
		Local MessageBox:wxMessageDialog
		Local Downloadexe:TProcess
		Local NumCorrect = 0
		Local b:Int = 0
		If FileType(GAMEDATAFOLDER + GName + FolderSlash + "Thumbs" + String(ArtType) ) = 2 Then
		
			ReadThumbs = ReadDir(GAMEDATAFOLDER + GName + FolderSlash +"Thumbs" + String(ArtType) )
			Repeat
				file:String = NextFile(ReadThumbs)
				If file="." Or file=".." Then Continue 
				If file = "" Then Exit
				b = b + 1
			Forever
			
			Select ArtType
				Case 3
					If CountList(Self.Fanart) = b Then
						NumCorrect = 1
					EndIf
				Case 4
					If CountList(Self.BannerArt) = b Then
						NumCorrect = 1
					EndIf					
			End Select
		
			If NumCorrect = 1 Then
		
				MessageBox = New wxMessageDialog.Create(Null, "Would you like to refresh Artwork Thumbs?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_NO Then
					Return
				EndIf
			EndIf
		EndIf
		DeleteCreateFolder(GAMEDATAFOLDER + GName + FolderSlash +"Thumbs"+String(ArtType))
		Local a:Int = 0
		Select ArtType
			Case 3 'Fanart
				For Thumb:String = EachIn Self.FanartThumbs
		
					Downloadexe = RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile " + Chr(34) + Thumb + Chr(34) + " -DownloadPath " + Chr(34) + GAMEDATAFOLDER + GName + FolderSlash +"Thumbs"+String(ArtType) + Chr(34) + " -DownloadName " + Chr(34) + "Thumb" + String(a) + "." + Lower(ExtractExt(Thumb) ) + Chr(34))
					Log1.AddText("Downloading Thumb "+a)
					PrintF("Downloading "+Thumb)			
					Repeat
						If ProcessStatus(Downloadexe) = 0 Then						
							Exit
						EndIf	
						If Downloadexe.pipe.ReadAvail()  Then
							Log1.AddText(Downloadexe.pipe.ReadLine())
						EndIf 						
						Delay 100
						If Log1.LogClosed = True Then
							ExitArt = True
							Exit
						EndIf
					Forever	
					a = a + 1	
					If ExitArt = True Then Exit
				Next
			Case 4 'Banner
				For Thumb:String = EachIn Self.BannerArt
		
					Downloadexe = RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile " + Chr(34) + Thumb + Chr(34) + " -DownloadPath " + Chr(34) + GAMEDATAFOLDER + GName + FolderSlash +"Thumbs"+String(ArtType) + Chr(34) + " -DownloadName " + Chr(34) + "Thumb" + String(a) + "." + Lower(ExtractExt(Thumb) ) + Chr(34))
					Log1.AddText("Downloading Thumb"+a)
					PrintF("Downloading "+Thumb)			
					Repeat
						If ProcessStatus(Downloadexe) = 0 Then						
							Exit
						EndIf	
						If Downloadexe.pipe.ReadAvail()  Then
							Log1.AddText(Downloadexe.pipe.ReadLine())
						EndIf 						
						Delay 100
						If Log1.LogClosed = True Then
							ExitArt = True
							Exit
						EndIf						
					Forever	
					a = a + 1	
					If ExitArt = True Then Exit
				Next
		End Select	
		Delay 1000		
		Return
	End Method
	
	Method DownloadGameArtWork(Override:Int , Log1:LogWindow)
		
		Local FanartArray:Object[] = ListToArray(Self.Fanart)
		Local FrontBoxArtArray:Object[] = ListToArray(Self.FrontBoxArt)
		Local BackBoxArtArray:Object[] = ListToArray(Self.BackBoxArt)
		Local BannerArtArray:Object[] = ListToArray(Self.BannerArt)
		Local ScreenShotsArray:Object[] = ListToArray(Self.ScreenShots)
		
		Local GName:String = Lower(GameNameSanitizer(Self.Name)+"---"+Self.Plat)

		DeleteCreateFolder(TEMPFOLDER + "ArtWork")
		
		Local SkipFanArt = False
		Local SkipBoxArt = False
		Local SkipBanner = False
		Local SkipBackArt = False
		
		If Len(FanartArray) = 0 Then SkipFanArt = True
		If Len(FrontBoxArtArray) = 0 Then SkipBoxArt = True
		If Len(BackBoxArtArray) = 0 Then SkipBackArt = True
		If Len(BannerArtArray) = 0 Then SkipBanner = True
		
		If FileType(GAMEDATAFOLDER + GName + FolderSlash+"Front.jpg") = 1 And Override=False Then SkipBoxArt = True
		If FileType(GAMEDATAFOLDER + GName + FolderSlash+"Back.jpg") = 1 And Override=False Then SkipBackArt = True
		If FileType(GAMEDATAFOLDER + GName + FolderSlash+"Screen.jpg") = 1 And Override=False Then SkipFanArt = True
		If FileType(GAMEDATAFOLDER + GName + FolderSlash+"Banner.jpg") = 1 And Override=False Then SkipBanner = True

		If SkipFanArt = False Then
			Log1.AddText("Downloading Fanart")
			PrintF("Downloading Fanart")
			PrintF("A: " + String(FanartArray[0]) )
			Downloadexe:TProcess=RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile "+Chr(34)+String(FanartArray[0])+Chr(34)+" -DownloadPath "+Chr(34)+TEMPFOLDER + "ArtWork"+Chr(34)+" -DownloadName "+Chr(34)+"Screen."+Lower(ExtractExt(String(FanartArray[0])))+Chr(34))
		EndIf
		
		If SkipBoxArt = False Then
			Log1.AddText("Downloading Front Boxart")
			PrintF("Downloading F BA")
			PrintF("A: "+String(FrontBoxArtArray[0]))
			Downloadexe2:TProcess=RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile "+Chr(34)+String(FrontBoxArtArray[0])+Chr(34)+" -DownloadPath "+Chr(34)+TEMPFOLDER + "ArtWork"+Chr(34)+" -DownloadName "+Chr(34)+"Front."+Lower(ExtractExt(String(FrontBoxArtArray[0])))+Chr(34))
		EndIf	
		
		If SkipBanner = False Then
			Log1.AddText("Downloading Banner art")
			PrintF("Downloading Banner art")
			PrintF("A: "+String(BannerArtArray[0]))
			Downloadexe3:TProcess=RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile "+Chr(34)+String(BannerArtArray[0])+Chr(34)+" -DownloadPath "+Chr(34)+TEMPFOLDER + "ArtWork"+Chr(34)+" -DownloadName "+Chr(34)+"Banner."+Lower(ExtractExt(String(BannerArtArray[0])))+Chr(34))
		EndIf
		
		If SkipBackArt = False Then
			Log1.AddText("Downloading Back Boxart")
			PrintF("Downloading Back Boxart")
			PrintF("A: "+String(BackBoxArtArray[0]))
			PrintF("")
			Downloadexe4:TProcess=RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile "+Chr(34)+String(BackBoxArtArray[0])+Chr(34)+" -DownloadPath "+Chr(34)+TEMPFOLDER + "ArtWork"+Chr(34)+" -DownloadName "+Chr(34)+"Back."+Lower(ExtractExt(String(BackBoxArtArray[0])))+Chr(34))
		EndIf			
		
		Local BoxStatus=0
		Local FanStatus=0
		Local BanStatus=0
		Local BackStatus=0		
		
		Repeat	
			If SkipFanArt=False Then
				If ProcessStatus(Downloadexe) = 1 Then 
					If Downloadexe.pipe.ReadAvail()  Then
						Log1.AddText(Downloadexe.pipe.ReadLine())
					EndIf 
				ElseIf FanStatus = 0 Then
					FanStatus = 1
					Log1.AddText("Finished Downloading Fanart")
				EndIf
			Else
				FanStatus=1
			EndIf			
			
			If SkipBoxArt=False Then
				If ProcessStatus(Downloadexe2) = 1 Then 
					If Downloadexe2.pipe.ReadAvail()  Then
						Log1.AddText(Downloadexe2.pipe.ReadLine())
					EndIf 			
				ElseIf BoxStatus = 0 Then
					BoxStatus = 1
					Log1.AddText("Finished Downloading Front Boxart")
				EndIf
			Else
				BoxStatus=1
			EndIf
			
			If SkipBanner=False Then
				If ProcessStatus(Downloadexe3) = 1 Then 
					If Downloadexe3.pipe.ReadAvail()  Then
						Log1.AddText(Downloadexe3.pipe.ReadLine())
					EndIf 			
				ElseIf BanStatus = 0 Then
					BanStatus = 1
					Log1.AddText("Finished Downloading Banner art")
				EndIf
			Else
				BanStatus=1
			EndIf
			
			If SkipBackArt=False Then
				If ProcessStatus(Downloadexe4) = 1 Then 
					If Downloadexe4.pipe.ReadAvail()  Then
						Log1.AddText(Downloadexe4.pipe.ReadLine())
					EndIf 			
				ElseIf BackStatus = 0 Then
					BackStatus = 1
					Log1.AddText("Finished Downloading Back Boxart")
				EndIf
			Else
				BackStatus=1
			EndIf			
					
			If BoxStatus = 1 And FanStatus = 1 And BanStatus = 1 And BackStatus = 1 Then Exit
			Log1.Update()
			If Log1.LogClosed = True Then
				Return
			EndIf
		Forever
		
		
		Local Screen1 = False
		Local Screen2 = False
		
		
		If Len(ScreenShotsArray) > 0 Then Screen1 = True
		If Len(ScreenShotsArray) > 1 Then Screen2 = True
		
		If FileType(GAMEDATAFOLDER + GName + FolderSlash+"Shot1.jpg") = 1 And Override=False Then Screen1 = False
		If FileType(GAMEDATAFOLDER + GName + FolderSlash+"Shot2.jpg") = 1 And Override=False Then Screen2 = False
		
		Local SNum:Int = 0
		
		If Screen1 = True Then
			PrintF("Download Screen1")
			Downloadexe:TProcess = RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile " + Chr(34) + String(ScreenShotsArray[0]) + Chr(34) + " -DownloadPath " + Chr(34) + TEMPFOLDER + "ArtWork" + Chr(34) + " -DownloadName " + Chr(34) + "Shot1." + Lower(ExtractExt(String(ScreenShotsArray[0]) ) ) + Chr(34))
			SNum=SNum+1
		EndIf
		
		If Screen2 = True Then
			PrintF("Download Screen2")
			Downloadexe2:TProcess = RunProcess(DOWNLOADERPROGRAM+" -Mode 2 -DownloadFile " + Chr(34) + String(ScreenShotsArray[1]) + Chr(34) + " -DownloadPath " + Chr(34) + TEMPFOLDER + "ArtWork" + Chr(34) + " -DownloadName " + Chr(34) + "Shot2." + Lower(ExtractExt(String(ScreenShotsArray[1]) ) ) + Chr(34))
			SNum=SNum+1
		EndIf	
		If Screen1=True Or Screen2=True Then
			Log1.AddText("Downloading "+SNum+" Screenshots")
		EndIf
		Local S1Status=0
		Local S2Status=0
		Repeat	
			If Screen1=True Then
				If ProcessStatus(Downloadexe) = 1 Then 
					If Downloadexe.pipe.ReadAvail()  Then
						Log1.AddText(Downloadexe.pipe.ReadLine())
					EndIf 
				ElseIf S1Status = 0 Then
					S1Status = 1
					Log1.AddText("Finished Downloading Screenshot 1")
				EndIf
			Else
				S1Status=1
			EndIf
			
			If Screen2=True Then
				If ProcessStatus(Downloadexe2) = 1 Then 			
					If Downloadexe2.pipe.ReadAvail()  Then
						Log1.AddText(Downloadexe2.pipe.ReadLine())
					EndIf 			
				ElseIf S2Status = 0 Then
					S2Status = 1
					Log1.AddText("Finished Downloading Screenshot 2")
				EndIf
			Else
				S2Status=1
			EndIf
			If S2Status = 1 And S1Status = 1 Then Exit
			Log1.Update()
			If Log1.LogClosed = True Then Return
		Forever
		
		Log1.AddText("Cleaning Up and Optimizing Artwork")
		Local File:String , FileName:String
		Local Pixmap:TPixmap , PixmapH:Int , PixmapW:Int , NewWid:Int
		ReadGames = ReadDir(TEMPFOLDER + "ArtWork" )
		Repeat
			File = NextFile(ReadGames)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue 
			FileName = StripExt(File)
			Select FileName
				Case "Screen" , "Shot1" , "Shot2" , "Front" , "Back"
					Pixmap = LoadPixmap(TEMPFOLDER + "ArtWork"+FolderSlash + File)
					SavePixmapJPeg(Pixmap , GAMEDATAFOLDER+GName+FolderSlash+FileName+".jpg" , 100 )
					PixmapW = PixmapWidth(Pixmap)
					PixmapH = PixmapHeight(Pixmap)
					If PixmapH < 1 Or PixmapW < 1 Then
					
					Else
						If PixmapW > GraphicsW Or PixmapH > GraphicsH Then
							NewWid = Min(GraphicsW , (Float(PixmapW) / PixmapH) * GraphicsH)
							Pixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						EndIf						
					EndIf
					SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT.jpg" , ArtworkCompression )
				Case "Banner"
					Pixmap = LoadPixmap(TEMPFOLDER + "ArtWork"+FolderSlash + File)
					SavePixmapJPeg(Pixmap , GAMEDATAFOLDER+GName+FolderSlash+FileName+".jpg" , 100 )
					PixmapW = PixmapWidth(Pixmap)
					PixmapH = PixmapHeight(Pixmap)
					If PixmapH < 1 Or PixmapW < 1 Then
					
					Else
				
					EndIf
					SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT.jpg" , ArtworkCompression )				
			End Select
		Forever
		CloseDir(ReadGames)
		
		ExtractIcon(Override)
		
	End Method
	
	Method OptimizeArtwork()
		Local GName:String = Lower(GameNameSanitizer(Self.Name) + "---" + Self.Plat)
		Local File:String , FileName:String
		Local Pixmap:TPixmap , SmallPixmap:TPixmap , OptPixmap:TPixmap , Opt2Pixmap:TPixmap
		'Cleanup
		ReadGames = ReadDir(GAMEDATAFOLDER + GName )
		Repeat
			File = NextFile(ReadGames)
			If File = "" Then Exit
			If File="." Or File=".." Then Continue 
			If Lower(ExtractExt(File) ) = "jpg" Then
				If Left(File,4)="Shot" Then Continue
				Select StripExt(File)
					Case "Screen" , "Front" , "Back" , "Banner"
					
					Default
						DeleteFile(GAMEDATAFOLDER + GName + FolderSlash + File)
				End Select
			EndIf
		Forever
		CloseDir(ReadGames)
		
		
		
		ReadGames = ReadDir(GAMEDATAFOLDER + GName )
		Repeat
			File = NextFile(ReadGames)
			If File = "" Then Exit
			If File = "." Or File=".." Then Continue 
			FileName = StripExt(File)
			If Lower(ExtractExt(File) ) = "jpg" Then
				'Do nothing
			Else
				Continue
			EndIf
			Select FileName
				Case "Screen"
					'background
					PrintF(GAMEDATAFOLDER + GName + FolderSlash + File)
					Pixmap = LoadPixmap(GAMEDATAFOLDER + GName + FolderSlash + File)
					PixmapW = PixmapWidth(Pixmap)
					PixmapH = PixmapHeight(Pixmap)
					PrintF("Loading")
					If PixmapH < 1 Or PixmapW < 1 Then
						OptPixmap = Pixmap
						Opt2Pixmap = Pixmap
						SmallPixmap = Pixmap
					Else
						'Take Background to be biggest of 100% width of screen or 100% height of screen
						If PixmapW > GraphicsW Or PixmapH > GraphicsH Then
							NewWid = Max(GraphicsW , (Float(PixmapW) / PixmapH) * GraphicsH)
							OptPixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							OptPixmap = Pixmap
						EndIf							
							
						If PixmapW > 512 Or PixmapH > 512 Then
							NewWid = Min(512 , (Float(PixmapW) / PixmapH) * 512)
							SmallPixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							SmallPixmap = Pixmap
						EndIf						
					EndIf
					SavePixmapJPeg(OptPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT_2X.jpg" , ArtworkCompression )
					SavePixmapJPeg(OptPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT.jpg" , ArtworkCompression )
					SavePixmapJPeg(SmallPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_THUMB.jpg" , ArtworkCompression )
				
				Case "Front" , "Back"
					PrintF(GAMEDATAFOLDER + GName + FolderSlash + File)
					Pixmap = LoadPixmap(GAMEDATAFOLDER + GName + FolderSlash + File)
					PixmapW = PixmapWidth(Pixmap)
					PixmapH = PixmapHeight(Pixmap)
					PrintF("Loading")
					If PixmapH < 1 Or PixmapW < 1 Then
						OptPixmap = Pixmap
						Opt2Pixmap = Pixmap
						SmallPixmap = Pixmap
					Else
						'Take Large covers to be smallest of 50% width of screen or 100% height of screen
						If PixmapW > GraphicsW Or PixmapH > GraphicsH Then
							NewWid = Min(GraphicsW , (Float(PixmapW) / PixmapH) * GraphicsH)
							Opt2Pixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							Opt2Pixmap = Pixmap
						EndIf	
						
						'Take covers to be smallest of 25% width of screen or 50% height of screen
						If PixmapW > 0.25*GraphicsW Or PixmapH > 0.5*GraphicsH Then
							NewWid = Min(0.25*GraphicsW , (Float(PixmapW) / PixmapH) * 0.5*GraphicsH)
							OptPixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							OptPixmap = Pixmap
						EndIf							
							
						If PixmapW > 512 Or PixmapH > 512 Then
							NewWid = Min(512 , (Float(PixmapW) / PixmapH) * 512)
							SmallPixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							SmallPixmap = Pixmap
						EndIf						
					EndIf
					SavePixmapJPeg(Opt2Pixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT_2X.jpg" , ArtworkCompression )
					SavePixmapJPeg(OptPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT.jpg" , ArtworkCompression )
					SavePixmapJPeg(SmallPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_THUMB.jpg" , ArtworkCompression )
				
				Case "Shot1" , "Shot2"
					PrintF(GAMEDATAFOLDER + GName + FolderSlash + File)
					Pixmap = LoadPixmap(GAMEDATAFOLDER + GName + FolderSlash + File)
					PixmapW = PixmapWidth(Pixmap)
					PixmapH = PixmapHeight(Pixmap)
					PrintF("Loading")
					If PixmapH < 1 Or PixmapW < 1 Then
						OptPixmap = Pixmap
						Opt2Pixmap = Pixmap
						SmallPixmap = Pixmap
					Else
						If PixmapW > 2*GraphicsW Or PixmapH > 2*GraphicsH Then
							NewWid = Min(2*GraphicsW , (Float(PixmapW) / PixmapH) * 2*GraphicsH)
							Opt2Pixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							Opt2Pixmap = Pixmap
						EndIf	

						If PixmapW > GraphicsW Or PixmapH > GraphicsH Then
							NewWid = Min(GraphicsW , (Float(PixmapW) / PixmapH) * GraphicsH)
							OptPixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							OptPixmap = Pixmap
						EndIf							
							
						If PixmapW > 512 Or PixmapH > 512 Then
							NewWid = Min(512 , (Float(PixmapW) / PixmapH) * 512)
							SmallPixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							SmallPixmap = Pixmap
						EndIf						
					EndIf
					SavePixmapJPeg(Opt2Pixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT_2X.jpg" , ArtworkCompression )
					SavePixmapJPeg(OptPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT.jpg" , ArtworkCompression )
					SavePixmapJPeg(SmallPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_THUMB.jpg" , ArtworkCompression )
				Case "Banner"
					Pixmap = LoadPixmap(GAMEDATAFOLDER + GName + FolderSlash + File)
					PixmapW = PixmapWidth(Pixmap)
					PixmapH = PixmapHeight(Pixmap)
					If PixmapH < 1 Or PixmapW < 1 Then
						SmallPixmap = Pixmap
					Else
						'Take banners to be smallest of 78% width of screen or 20% height of screen
						If PixmapW > 0.78*GraphicsW Or PixmapH > 0.2*GraphicsH Then
							NewWid = Min(0.78*GraphicsW , (Float(PixmapW) / PixmapH) * 0.2 * GraphicsH)
							OptPixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							OptPixmap = Pixmap
						EndIf							
					
						If PixmapW > 512 Or PixmapH > 512 Then
							NewWid = Min(512 , (Float(PixmapW) / PixmapH) * 512)
							SmallPixmap = ResizePixmap(Pixmap , NewWid , (Float(PixmapH) / PixmapW) * NewWid)
						Else
							SmallPixmap = Pixmap
						EndIf					
					EndIf
					SavePixmapJPeg(OptPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_OPT.jpg" , ArtworkCompression )				
					SavePixmapJPeg(SmallPixmap , GAMEDATAFOLDER + GName + FolderSlash + FileName + "_THUMB.jpg" , ArtworkCompression )					
			End Select
		Forever
		CloseDir(ReadGames)		
	End Method
	
	Method DownloadGameInfo()
		Local GameDB:String = "http://thegamesdb.net"
		Local tempCurrentSearchLine:String
		If Int(Self.ID) = 0 Then
			CustomRuntimeError("Error: 35 DownloadGameInfo, ID is 0") 'MARK: Error 35
		EndIf
		
		Self.IntialiseFanartLists()	
		
		Select GameDB
			Case "http://thegamesdb.net"
				PrintF("thegamesdb.net")
				'Location = StripSlash(Location)
				
				GetGameInfo(Self.ID)	
				PrintF("Got Game Info, Parsing...")		
		
				
				Local Gamedoc:TxmlDoc
				Local RootNode:TxmlNode , GenreNode:TxmlNode , node:TxmlNode , node2:TxmlNode , node3:TxmlNode , Mainnode:TxmlNode
				Local OEXE:String
				
				Gamedoc = TxmlDoc.parseFile(TEMPFOLDER+"GameInfo.txt")
			
				If Gamedoc = Null Then
					CustomRuntimeError( "Error 50: XML Document not parsed successfully, DownloadGameInfo(). "+ GName) 'MARK: Error 50
				End If
				
				RootNode = Gamedoc.getRootElement()
				
				If RootNode = Null Then
					Gamedoc.free()
					CustomRuntimeError( "Error 51: Empty document, DownloadGameInfo(). "+ GName) 'MARK: Error 51
				End If		
		
				If RootNode.getName() <> "Data" Then
					Gamedoc.free()
					CustomRuntimeError( "Error 52: Document of the wrong type, root node <> Game, DownloadGameInfo(). "+ GName) 'MARK: Error 52
				End If
				
				Local ChildrenList:TList = RootNode.getChildren()
				If ChildrenList = Null Or ChildrenList.IsEmpty() Then
					Gamedoc.free()
					CustomRuntimeError( "Error 53: Document error, no data contained within, DownloadGameInfo(). "+ GName) 'MARK: Error 53			
				EndIf
				Local BaseURL:String
				Local TrailerURL:String
				For Mainnode = EachIn ChildrenList
					Select Mainnode.getName()
						Case "baseImgUrl"
							BaseURL = Mainnode.getText()
						Case "Game"
							Local GameList:TList = Mainnode.getChildren()
							If GameList = Null Or GameList.IsEmpty() Then
								
							Else
								Self.Genres = CreateList()
								For node = EachIn GameList
									Select node.getName()
										Case "Youtube"
											TrailerURL = node.getText()
										Case "GameTitle"
											Self.Name = node.getText()
										Case "Overview"
											Self.Desc = node.getText()
										Case "Platform"
											Self.Plat =  node.getText()
										Case "ReleaseDate"
											Self.ReleaseDate = GetDateFromLocalFormat(node.getText(),"US")
										Case "ESRB"
											Self.Cert = node.getText()
										Case "Developer"
											Self.Dev = node.getText()
										Case "Publisher"
											Self.Pub = node.getText()
										Case "Genres"
											'GenreNode = node
											Local GenreList:TList = node.getChildren()
											If GenreList = Null Or GenreList.IsEmpty() Then
											Else
												For node2 = EachIn GenreList
													If node2.getName() = "genre" Then
														ListAddLast(Self.Genres , node2.getText())
													EndIf
												Next
											EndIf
										Case "Co-op"
											Self.Coop = node.getText()
										Case "Players"
											Self.Players = node.getText()
										Case "Images"
											Local ArtList:TList = node.getChildren()
											If ArtList = Null Or ArtList.IsEmpty() Then
											
											Else
												For node2 = EachIn ArtList
													Select node2.getName()
														Case "fanart"																									
															Local FanArtList:TList = node2.getChildren()
															If FanArtList = Null Or FanArtList.IsEmpty() Then
															
															Else
																For node3 = EachIn FanArtList
																	Select node3.getName()
																		Case "original"
																			ListAddLast(Self.Fanart , BaseURL+node3.getText())
																		Case "thumb"
																			ListAddLast(Self.FanartThumbs , BaseURL+node3.getText())
																	End Select
																Next
															EndIf
														Case "boxart"
															Select node2.getAttribute("side")
																Case "back"
																	ListAddLast(Self.BackBoxArt , BaseURL+node2.getText())
																Case "front"
																	ListAddLast(Self.FrontBoxArt , BaseURL+node2.getText())
															End Select
														Case "banner"
															ListAddLast(Self.BannerArt , BaseURL+node2.getText())
														Case "screenshot"
															Local ScreenList:TList = node2.getChildren()
															If ScreenList = Null Or ScreenList.IsEmpty() Then
															
															Else
																For node3 = EachIn ScreenList
																	Select node3.getName()
																		Case "original"
																			ListAddLast(Self.ScreenShots , BaseURL+node3.getText())
																		Case "thumb"
																			ListAddLast(Self.ScreenShotThumbs , BaseURL+node3.getText())
																	End Select
																Next
															EndIf								
													End Select
												Next
											EndIf				
										Case "id"
											Self.ID = Int(node.getText())
										Case "Rating"
											Self.Rating = Int(node.getText())
									End Select
								Next
							EndIf
					End Select
				Next	
				If IsntNull(TrailerURL) Then
					For a = 1 To Len(TrailerURL)
						If Mid(TrailerURL , a , 1) = "=" Then
							Self.Trailer = Right(TrailerURL , Len(TrailerURL) - a)
							Exit
						EndIf
					Next
				EndIf

				Gamedoc.free()

			Default
				CustomRuntimeError("Error 20: Invalid GameDB") 'MARK: Error 20
		End Select
		Return Self.SaveGame()
	End Method
	
	Method OutputInfoOLD()
		Local GName:String
		GName = GameNameSanitizer(Self.Name)+"---"+Self.Plat
		WriteData = WriteFile(GAMEDATAFOLDER + GName + FolderSlash +"Info.txt")
			WriteLine(WriteData,Self.Name)
			WriteLine(WriteData,Self.Desc)
			If Self.Plat = "PC" Then
				'WriteLine(WriteData,Self.Dir)
				'WriteLine(WriteData,Self.EXE)
			Else
				WriteLine(WriteData,Self.ROM)
				WriteLine(WriteData,Self.ExtraCMD)
			EndIf
			WriteLine(WriteData,Self.ReleaseDate)
			WriteLine(WriteData,Self.Cert)
			WriteLine(WriteData,Self.Dev)
			WriteLine(WriteData , Self.Pub)
			
			Local GenreList:String = "",SingleGenre:String = ""
			For SingleGenre = EachIn Self.Genres
				GenreList = GenreList +  SingleGenre + "/"
			Next			
			GenreList = Left(GenreList , Len(GenreList)-1)
			WriteLine(WriteData,GenreList)
			WriteLine(WriteData,Self.ID)
			WriteLine(WriteData,Self.Rating)
			WriteLine(WriteData,Self.Plat)
			WriteLine(WriteData,Self.EmuOverride)

		CloseFile(WriteData)
	End Method
	
	Method OutputInfo()
		Local GName:String
		GName = GameNameSanitizer(Self.Name) + "---" + Self.Plat
		GName = Lower(GName)	
		CreateEmptyXMLGame(GAMEDATAFOLDER + GName + FolderSlash +"Info.xml")
		'DebugStop()
		
		Local Gamedoc:TxmlDoc
		Local RootNode:TxmlNode , EXENode:TxmlNode , GenreNode:TxmlNode , SubEXENode:TxmlNode , ArtNode:TxmlNode , ArtThumbNode:TxmlNode
		Local OEXE:String
		
		Gamedoc = TxmlDoc.parseFile(GAMEDATAFOLDER + GName + FolderSlash+"Info.xml")
	
		If Gamedoc = Null Then
			CustomRuntimeError( "Error 36: XML Document not parsed successfully, OutputInfoXML") 'MARK: Error 36
		End If
		
		RootNode = Gamedoc.getRootElement()
		
		If RootNode = Null Then
			Gamedoc.free()
			Gamedoc = Null 
			CustomRuntimeError( "Error 37: Empty document, OutputInfoXML") 'MARK: Error 37
		End If		

		If RootNode.getName() <> "Game" Then
			Gamedoc.free()
			Gamedoc = Null 
			CustomRuntimeError( "Error 38: Document of the wrong type, root node <> Game") 'MARK: Error 38
		End If
		
		RootNode.addTextChild("Name" , Null , Self.Name)
		RootNode.addTextChild("Description" , Null , Self.Desc)
		RootNode.addTextChild("Platform" , Null , Self.Plat)
		RootNode.addTextChild("Co-op" , Null , Self.Coop)
		RootNode.addTextChild("Players" , Null , Self.Players)
		RootNode.addTextChild("PreBatchFile" , Null , Self.PreBF)
		RootNode.addTextChild("PreBatchFileWait" , Null , Self.PreBFWait)
		RootNode.addTextChild("PostBatchFile" , Null , Self.PostBF)
		RootNode.addTextChild("PostBatchFileWait" , Null , Self.PostBFWait)		
		
		RootNode.addTextChild("GameRunnerAlwaysOn" , Null , Self.GameRunnerAlwaysOn)
		RootNode.addTextChild("StartWaitEnabled" , Null , Self.StartWaitEnabled)
		

		RootNode.addTextChild("Mounter" , Null , Self.Mounter)
		RootNode.addTextChild("VDriveNum" , Null , Self.VDriveNum)
		RootNode.addTextChild("UnMount" , Null , Self.UnMount)
		RootNode.addTextChild("DiscImage" , Null , Self.DiscImage)
		
	
		EXENode = RootNode.addTextChild("EXEs" , Null , "")
		If Self.Plat = "PC" Then
			EXENode.addTextChild("RUN" , Null , Self.RunEXE)
		Else
			EXEnode.addTextChild("ROM" , Null , Self.ROM)
			EXEnode.addTextChild("ExtraCMD" , Null , Self.ExtraCMD)
			EXEnode.addTextChild("EmulatorOverride" , Null , Self.EmuOverride)
		EndIf
		
		Local OEXEsArray:Object[] = ListToArray(Self.OEXEs)
		Local OEXEsNameArray:Object[] = ListToArray(Self.OEXEsName)
		
		If Len(OEXEsArray) = Len(OEXEsNameArray) Then
			For a = 0 To Len(OEXEsArray) - 1
				SubEXENode = EXEnode.addTextChild("ExtraEXE" , Null , String(OEXEsArray[a]))
				SubEXENode.addAttribute("name", String(OEXEsNameArray[a]))
			Next
		Else
			CustomRuntimeError("Error 42: OEXE arrays dont match in size") 'MARK: Error 42
		EndIf
		
		If Self.WatchEXEs <> Null Then 
			For WatchEXEString:String = EachIn Self.WatchEXEs
				EXEnode.addTextChild("WatchEXEs" , Null , WatchEXEString)
			Next
		EndIf 
		
			
		RootNode.addTextChild("Trailer" , Null , Self.Trailer)
		'RootNode.addTextChild("TrailerURL" , Null , Self.TrailerURL)
		RootNode.addTextChild("ReleaseDate" , Null , Self.ReleaseDate)
		RootNode.addTextChild("Certificate" , Null , Self.Cert)
		RootNode.addTextChild("Developer" , Null , Self.Dev)
		RootNode.addTextChild("Publisher" , Null , Self.Pub)
		
		Local SingleGenre:String
		GenreNode = RootNode.addTextChild("Genres" , Null , "")
		For SingleGenre = EachIn Self.Genres
			GenreNode.addTextChild("Genre" , Null , SingleGenre)
		Next
		
		Rem Removed untill we ask users their permission to do this
		?Win32
		If ConnectedPGM = 1 Then
			Local DBFolder:String
			Local DBID:String
			Local DBEXE:String
			Local DBName:String
			If Self.ID < 0 Then
			
			Else
				If Self.Plat = "PC" Then
					DBFolder = SanitiseForInternet(StripDir(ExtractDir(Self.RunEXE ) ))
					DBEXE = SanitiseForInternet(FolderSlash+StripDir(Self.RunEXE))
				Else
					DBFolder = SanitiseForInternet(StripExt(StripDir(Self.ROM ) ))
					DBEXE = ""
				EndIf
				DBID = SanitiseForInternet(Self.ID)
				DBName = SanitiseForInternet(Self.Name)
				s:TStream = ReadStream("http::photongamemanager.com/GamesEXEDatabase/GameSubmit.php?ID="+DBID+"&Folder="+DBFolder+"&EXE="+DBEXE+"&Name="+DBName)
	
			EndIf 
		EndIf
		? 
		EndRem 
		
		Local FBA:String , BBA:String , FA:String , BA:String , SSA:String
		ArtNode = RootNode.addTextChild("ArtWork" , Null , "")
		For FBA = EachIn Self.FrontBoxArt
			ArtNode.addTextChild("FrontBoxArt" , Null , FBA)
		Next
		For BBA = EachIn Self.BackBoxArt
			ArtNode.addTextChild("BackBoxArt" , Null , BBA)
		Next
		For FA = EachIn Self.Fanart
			ArtNode.addTextChild("FanArt" , Null , FA)
		Next
		For BA = EachIn Self.BannerArt
			ArtNode.addTextChild("BannerArt" , Null , BA)
		Next		
		For SSA = EachIn Self.ScreenShots
			ArtNode.addTextChild("ScreenShot" , Null , SSA)
		Next		
		
		Local SSTA:String , FTA:String
		ArtThumbNode = RootNode.addTextChild("ArtWorkThumbs" , Null , "")
		For SSTA = EachIn Self.ScreenShotThumbs
			ArtThumbNode.addTextChild("ScreenShot" , Null , SSTA)
		Next		
		For FTA = EachIn Self.FanartThumbs
			ArtThumbNode.addTextChild("FanArt" , Null , FTA)
		Next				
		
		RootNode.addTextChild("ID" , Null , Self.ID)
		RootNode.addTextChild("Rating" , Null , Self.Rating)
		
		CopyFile(GAMEDATAFOLDER + GName + FolderSlash +"Info.xml" , TEMPFOLDER + "temp.xml") 
		For b=1 To 10
			SaveStatus = Gamedoc.saveFormatFile(GAMEDATAFOLDER + GName + FolderSlash+"Info.xml" , False)
			PrintF("SaveXML Try: "+b+" Status: "+SaveStatus)
			If SaveStatus <> - 1 Then Exit
			Delay 100
		Next
		If b = 10 Then
			CopyFile(TEMPFOLDER + "temp.xml" , GAMEDATAFOLDER + GName + FolderSlash+"Info.xml") 
			CustomRuntimeError("Error 44: Could Not Write XML File") 'MARK: Error 44
		EndIf
		Gamedoc.free()
		Gamedoc = Null 
		
		
	End Method
	
	Method OutputArtInfo()
		Local GName:String
		GName = GameNameSanitizer(Self.Name)+"---"+Self.Plat
		GName = Lower(GName)
		
		Local FanartArray:Object[], FanartThumbsArray:Object[]
		FanartArray = ListToArray(Self.Fanart) 
		FanartThumbsArray = ListToArray(Self.FanartThumbs) 
		
		If Len(FanartArray) = Len(FanartThumbsArray) Then
		
		Else
			CustomRuntimeError("Error 35: # of thumbs doesn't match # of fanart")
			'MARK: Error 35
		EndIf
		FanArtWrite = WriteFile(GAMEDATAFOLDER + GName + FolderSlash +"Fanart.txt")
		For a = 0 To Len(FanartArray) - 1
			WriteLine(FanArtWrite,String(FanartThumbsArray[a]))
			WriteLine(FanArtWrite,String(FanartArray[a]))
		Next
		CloseFile(FanArtWrite)

		Local ScreenShotsArray:Object[], ScreenShotThumbsArray:Object[]
		ScreenShotsArray = ListToArray(Self.ScreenShots) 
		ScreenShotThumbsArray = ListToArray(Self.ScreenShotThumbs) 
		
		If Len(ScreenShotsArray) = Len(ScreenShotThumbsArray) Then
		
		Else
			CustomRuntimeError("Error 36: # of thumbs doesn't match # of screenshots") 'MARK: Error 36
		EndIf
		ScreenShotsWrite = WriteFile(GAMEDATAFOLDER + GName + FolderSlash+"ScreenShot.txt")
		For a = 0 To Len(ScreenShotsArray) - 1
			WriteLine(ScreenShotsWrite,String(ScreenShotThumbsArray[a]))
			WriteLine(ScreenShotsWrite,String(ScreenShotsArray[a]))
		Next
		CloseFile(ScreenShotsWrite)		
		
		
		
		Local FrontBoxArtArray:Object[]
		FrontBoxArtArray = ListToArray(Self.FrontBoxArt) 
				
		FrontBoxArtWrite = WriteFile(GAMEDATAFOLDER + GName + FolderSlash+"FrontBoxArt.txt")
		For a = 0 To Len(FrontBoxArtArray) - 1
			WriteLine(FrontBoxArtWrite,String(FrontBoxArtArray[a]))
		Next
		CloseFile(FrontBoxArtWrite)		

		Local BackBoxArtArray:Object[]
		BackBoxArtArray = ListToArray(Self.BackBoxArt) 
				
		BackBoxArtWrite = WriteFile(GAMEDATAFOLDER + GName + FolderSlash +"BackBoxArt.txt")
		For a = 0 To Len(BackBoxArtArray) - 1
			WriteLine(BackBoxArtWrite,String(BackBoxArtArray[a]))
		Next
		CloseFile(BackBoxArtWrite)			

		Local BannerArtArray:Object[]
		BannerArtArray = ListToArray(Self.BannerArt) 
				
		BannerArtWrite = WriteFile(GAMEDATAFOLDER + GName + FolderSlash +"Banner.txt")
		For a = 0 To Len(BannerArtArray) - 1
			WriteLine(BannerArtWrite,String(BannerArtArray[a]))
		Next
		CloseFile(BannerArtWrite)		
		
		Local IconArtArray:Object[]
		IconArtArray = ListToArray(Self.IconArt) 
				
		IconArtWrite = WriteFile(GAMEDATAFOLDER + GName + FolderSlash +"Icon.txt")
		For a = 0 To Len(IconArtArray) - 1
			WriteLine(IconArtWrite,String(IconArtArray[a]))
		Next
		CloseFile(IconArtWrite)			
	End Method	
	
End Type