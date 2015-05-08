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

	'Returns 	2- game already in database, dont overwrite
	'			1- success
	Method SaveGame:Int()
		Local GName:String
		Local MessageBox:wxMessageDialog
		
		GName = Self.GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum
		GName = Lower(GName)
		
		
		If Self.OrginalName = Lower(Self.OrginalName) Then
		
		Else 
			RenameFile(GAMEDATAFOLDER + Self.OrginalName , GAMEDATAFOLDER + Lower(Self.OrginalName) )
			Self.OrginalName = Lower(Self.OrginalName)
		EndIf
		
		Self.ROM = StandardiseSlashes(Self.ROM)
		If Self.OrginalName = "" Or Self.OrginalName = Null Or Self.OrginalName = " " Then
			If FileType(GAMEDATAFOLDER + GName) = 2 Then
				MessageBox = New wxMessageDialog.Create(Null, GName + " is already in the database, overwrite it? (All fan art will be deleted)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_YES then
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
				If FileType(GAMEDATAFOLDER + GName) = 2 then
					MessageBox = New wxMessageDialog.Create(Null , "New game name already exists. Using the old name" , "Info" , wxOK)
					PrintF("OldName: " + OrginalName)
					PrintF("NewName: " + GName)
					MessageBox.ShowModal()
					MessageBox.Free()
					For a = 1 To Len(Self.OrginalName)
						If Mid(Self.OrginalName , a , 3) = "---" Then
							Self.Name = Left(Self.OrginalName , a - 1)
							Self.PlatformNum = Int(Right(Self.OrginalName , Len(Self.OrginalName) - a - 2))
							Exit 
						EndIf 
					Next
					
					'Self.Name = Self.OrginalName
					GName = GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum
				Else
					RenameFile(GAMEDATAFOLDER + Self.OrginalName ,GAMEDATAFOLDER + GName)
				EndIf
			EndIf		
		EndIf
		If FileType(GAMEDATAFOLDER + GName) = 0 Then
			CustomRuntimeError("Error 33: GameType Folder Missing") 'MARK: Error 33
		EndIf
		
		Self.OutputInfo()
		'Self.OutputArtInfo()
		'OutputIcon()
		'OutputFanart()
		Return 1
	End Method
	
	Method ExtractIcon(Override:Int)
		?Win32	
		Local GName:String = Self.GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum
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
		Local GName:String = Lower(Self.GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum)
		Local a:Int = 0
		Local MessageBox:wxMessageDialog
		Local NumCorrect = 0
		
		If FileType(GAMEDATAFOLDER + GName + FolderSlash + "Thumbs" + String(ArtType) ) = 2 Then
		
			ReadThumbs = ReadDir(GAMEDATAFOLDER + GName + FolderSlash +"Thumbs" + String(ArtType) )
			Repeat
				file:String = NextFile(ReadThumbs)
				If file="." Or file=".." Then Continue 
				If file = "" then Exit
				b = b + 1
			Forever
			
			Select ArtType
				Case 3
					If CountList(Self.Fanart) = b then
						NumCorrect = 1
					EndIf
				Case 4
					If CountList(Self.BannerArt) = b then
						NumCorrect = 1
					EndIf					
			End Select
		
			If NumCorrect = 1 then
		
				MessageBox = New wxMessageDialog.Create(Null, "Would you like to refresh Artwork Thumbs?" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_NO Then
					Return
				EndIf
			EndIf
		EndIf
		
		DeleteCreateFolder(GAMEDATAFOLDER + GName + FolderSlash + "Thumbs" + String(ArtType) )
		DeleteCreateFolder(TEMPFOLDER + "Thumbs")
		
		Local curl:TCurlEasy
		Local TFile:TStream
		Local Pixmap:TPixmap
		Local res:Int
		curl = TCurlEasy.Create()
		'perform Download		
			
		
		
		Select ArtType
			Case 3 'Fanart
				For ThumbURL:String = EachIn Self.FanartThumbs
					Log1.AddText("Downloading Thumb" + String(a) )
					TFile = WriteFile(TEMPFOLDER + "Thumbs" + FolderSlash + "Thumb" + String(a) )
			
					ThumbURL = Replace(ThumbURL, " ", "%20")

					curl.setOptString(CURLOPT_URL, ThumbURL)
					curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
					curl.setProgressCallback(DownloadArtwork_ProgressCallback)
					curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
					curl.setWriteStream(TFile)
					
					res = curl.perform()
					
					CloseFile(TFile)

					If res then
						PrintF("DownloadError: " + CurlError(res) )
						Log1.AddText("Download failed")
						DeleteFile(TEMPFOLDER + "Thumbs" + FolderSlash + "Thumb" + String(a) )
					Else
						'perform convert to correct type, move
						Pixmap = LoadPixmap(TEMPFOLDER + "Thumbs" + FolderSlash + "Thumb" + String(a) )
						SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GName + FolderSlash + "Thumbs" + String(ArtType) + FolderSlash + "Thumb" + String(a) + ".jpg" , 100 )	
					EndIf	
					
					a = a + 1
					If Log1.LogClosed = True then
						Exit
					EndIf				
				Next
			Case 4 'Banner
				For ThumbURL:String = EachIn Self.BannerArt
					Log1.AddText("Downloading Thumb" + String(a) )
					TFile = WriteFile(TEMPFOLDER + "Thumbs" + FolderSlash + "Thumb" + String(a) )
			
					ThumbURL = Replace(ThumbURL, " ", "%20")

					curl.setOptString(CURLOPT_URL, ThumbURL)
					curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
					curl.setProgressCallback(DownloadArtwork_ProgressCallback)
					curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
					curl.setWriteStream(TFile)
					
					res = curl.perform()
					
					CloseFile(TFile)

					If res then
						PrintF("DownloadError: " + CurlError(res) )
						Log1.AddText("Download failed")
						DeleteFile(TEMPFOLDER + "Thumbs" + FolderSlash + "Thumb" + String(a) )
					Else
						'perform convert to correct type, move
						Pixmap = LoadPixmap(TEMPFOLDER + "Thumbs" + FolderSlash + "Thumb" + String(a) )
						SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GName + FolderSlash + "Thumbs" + String(ArtType) + FolderSlash + "Thumb" + String(a) + ".jpg" , 100 )	
					EndIf						
					
					a = a + 1
					If Log1.LogClosed = True then
						Exit 
					EndIf
				Next
		End Select
		Delay 1000	
	End Method
	
	
	Rem
	Method DownloadArtWorkThumbs(Log1:LogWindow , ArtType:Int)
		Local GName:String = Lower(Self.GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum)
		Local MessageBox:wxMessageDialog
		Local Downloadexe:TProcess
		Local NumCorrect = 0
		Local b:Int = 0
		If FileType(GAMEDATAFOLDER + GName + FolderSlash + "Thumbs" + String(ArtType) ) = 2 Then
		
			ReadThumbs = ReadDir(GAMEDATAFOLDER + GName + FolderSlash +"Thumbs" + String(ArtType) )
			Repeat
				file:String = NextFile(ReadThumbs)
				If file="." Or file=".." Then Continue 
				If file = "" then Exit
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
							Log1.AddText(Downloadexe.pipe.ReadLine() )
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
	EndRem
	
	Method DownloadGameArtWork()
		Local Override:Int = Self.OverideArtwork
		Self.OverideArtwork = 0
		Local ArtworkListItem:DownloadArtworkListItemType
		Local URL:String
		Local GName:String = Lower(Self.GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum)
		Local ItemNumber:Int = 0
		Local DownloadArtworkList:TList
		
		Log1.AddText("Downloading artwork...")
		

		DownloadArtworkList = CreateList()
		
		'Add all artwork to DownloadArtworkList
		If Self.FrontBoxArt.Count() > 0 then
			URL = String(Self.FrontBoxArt.First() )
			ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Front")
			If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Front.jpg") = 0 then
				ListAddLast(DownloadArtworkList, ArtworkListItem)
			EndIf
		EndIf
		
		If Self.Fanart.Count() > 0 then
			URL = String(Self.Fanart.First() )
			ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Screen")
			If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Screen.jpg") = 0 then
				ListAddLast(DownloadArtworkList, ArtworkListItem)
			EndIf
		EndIf

		If Self.BackBoxArt.Count() > 0 then
			URL = String(Self.BackBoxArt.First() )
			ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Back")
			If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Back.jpg") = 0 then
				ListAddLast(DownloadArtworkList, ArtworkListItem)
			EndIf
		EndIf		
		
		If Self.BannerArt.Count() > 0 then
			URL = String(Self.BannerArt.First() )
			ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Banner")
			If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Banner.jpg") = 0 then
				ListAddLast(DownloadArtworkList, ArtworkListItem)
			EndIf
		EndIf			
											If Self.FrontBoxArt.Count() > 1 then
			ItemNumber = 0
			For URL = EachIn Self.FrontBoxArt
				ItemNumber = ItemNumber + 1
				'Already added first in list above so skip it
				If ItemNumber = 1 then Continue
				'Add other front covers to downloadlist
				ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Front" + ItemNumber)
				If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Front" + ItemNumber + ".jpg") = 0 then
					ListAddLast(DownloadArtworkList, ArtworkListItem)
				EndIf
			Next
		EndIf

		If Self.BackBoxArt.Count() > 1 then
			ItemNumber = 0
			For URL = EachIn Self.BackBoxArt
				ItemNumber = ItemNumber + 1
				'Already added first in list above so skip it
				If ItemNumber = 1 then Continue
				'Add other back covers to downloadlist
				ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Back" + ItemNumber)
				If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Back" + ItemNumber + ".jpg") = 0 then
					ListAddLast(DownloadArtworkList, ArtworkListItem)
				EndIf
			Next
		EndIf
		
		If Self.Fanart.Count() > 1 then
			ItemNumber = 0
			For URL = EachIn Self.Fanart
				ItemNumber = ItemNumber + 1
				'Already added first in list above so skip it
				If ItemNumber = 1 then Continue
				'Add other fanarts to downloadlist
				ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Screen" + ItemNumber)
				If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Screen" + ItemNumber + ".jpg") = 0 then
					ListAddLast(DownloadArtworkList, ArtworkListItem)
				EndIf 
			Next
		EndIf		
		
		If Self.BannerArt.Count() > 1 then
			ItemNumber = 0
			For URL = EachIn Self.BannerArt
				ItemNumber = ItemNumber + 1
				'Already added first in list above so skip it
				If ItemNumber = 1 then Continue
				'Add other banners to downloadlist
				ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Banner" + ItemNumber)
				If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Banner" + ItemNumber + ".jpg") = 0 then
					ListAddLast(DownloadArtworkList, ArtworkListItem)
				EndIf
			Next
		EndIf		

		If Self.ScreenShots.Count() > 0 then
			ItemNumber = 0
			For URL = EachIn Self.ScreenShots
				ItemNumber = ItemNumber + 1
				'Add other banners to downloadlist
				ArtworkListItem = New DownloadArtworkListItemType.Create(URL, "Shot" + ItemNumber)
				If Override = 1 Or FileType(GAMEDATAFOLDER + GName + FolderSlash + "Shot" + ItemNumber + ".jpg") = 0 then
					ListAddLast(DownloadArtworkList, ArtworkListItem)
				EndIf
			Next
		EndIf	

		
		DeleteCreateFolder(TEMPFOLDER + "ArtWork")


		Local curl:TCurlEasy
		Local Pixmap:TPixmap
		curl = TCurlEasy.Create()
		
		Repeat
		
			If DownloadArtworkList.Count() > 0 then
				ArtworkListItem = DownloadArtworkListItemType(DownloadArtworkList.RemoveFirst() )
			Else
				'Exit Repeat loop
				Exit
			EndIf

			Log1.AddText("Downloading " + ArtworkListItem.Filename)
			
			
			'perform Download		
			Local TFile:TStream = WriteFile(TEMPFOLDER + "Artwork" + FolderSlash + ArtworkListItem.Filename)
			
			ArtworkListItem.URL = Replace(ArtworkListItem.URL, " ", "%20")

			curl.setOptString(CURLOPT_URL, ArtworkListItem.URL)
			curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
			curl.setProgressCallback(DownloadArtwork_ProgressCallback)
			curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
			curl.setWriteStream(TFile)
			
			Local res:Int = curl.perform()
			
			CloseFile(TFile)

			If res then
				PrintF("DownloadError: " + CurlError(res) )
				Log1.AddText("Download failed")
				DeleteFile(TEMPFOLDER + "Artwork" + FolderSlash + ArtworkListItem.Filename)
				
			Else
				'perform convert to correct type, move
				Pixmap = LoadPixmap(TEMPFOLDER + "ArtWork" + FolderSlash + ArtworkListItem.Filename)
				SavePixmapJPeg(Pixmap , GAMEDATAFOLDER + GName + FolderSlash + ArtworkListItem.Filename + ".jpg" , 100 )				
			EndIf			

			If Log1.LogClosed = True then
				Exit
			EndIf	

		Forever		
		
		If Log1.LogClosed = False then
			Log1.AddText("Optimizing Artwork...")
			Self.OptimizeArtwork()
		EndIf
		
	End Method
	
	Method OptimizeArtwork()
		Local GName:String = Lower(Self.GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum)
		Local File:String , FileName:String
		Local Pixmap:TPixmap , SmallPixmap:TPixmap , OptPixmap:TPixmap , Opt2Pixmap:TPixmap
		'Cleanup
		ReadGames = ReadDir(GAMEDATAFOLDER + GName )
		Repeat
			File = NextFile(ReadGames)
			If File = "" then Exit
			If File = "." Or File = ".." then Continue
			If Lower(Right(File, 8) ) = "_opt.jpg" Or Lower(Right(File, 11) ) = "_opt_2x.jpg" Or Lower(Right(File, 10) ) = "_thumb.jpg" then
				DeleteFile(GAMEDATAFOLDER + GName + FolderSlash + File)
			EndIf
		Forever
		CloseDir(ReadGames)
		
		
		
		ReadGames = ReadDir(GAMEDATAFOLDER + GName )
		Repeat
			If Log1.LogClosed = True then
				Exit
			EndIf
			File = NextFile(ReadGames)
			If File = "" Then Exit
			If File = "." Or File = ".." then Continue
			FileName = StripExt(File)
			If Lower(ExtractExt(File) ) = "jpg" then
				'Do nothing
			Else
				Continue
			EndIf
			Select FileName
				Case "Screen"
					Log1.AddText("Optimizing " + FileName)
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
					Log1.AddText("Optimizing " + FileName)
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
					Log1.AddText("Optimizing " + FileName)
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
					Log1.AddText("Optimizing "+Filename)
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
		Local ErrorMessage:String
		Local MessageBox:wxMessageDialog
		
		Self.IntialiseFanartLists()	
		Self.Genres = CreateList()
		
		LuaMutexLock()
		
		'TODO: Check that LuaFile is valid and LuaIDData is not empty
	
		Local LuaFile:String = LUAFOLDER + "Game" + FolderSlash + Self.LuaFile
		If LuaHelper_LoadString(LuaVM, "", LuaFile) <> 0 then
			LuaMutexUnlock()
			Return
		EndIf
		
		
		'Get Lua Function
		lua_getfield(LuaVM, LUA_GLOBALSINDEX, "GetGame")
		'Push PlatformNum and empty list
		lua_pushbmaxobject( LuaVM , Self)
		lua_pushbmaxobject( LuaVM , LuaInternet)
		lua_pushbmaxobject( LuaVM , Self.LuaIDData)
		'Call Lua Function
		

		Result = lua_pcall(LuaVM, 3, 2, 0)
	
			
		If (Result <> 0) then
			ErrorMessage = luaL_checkstring(LuaVM, - 1)
			LuaHelper_CleanStack(LuaVM)
			LuaMutexUnlock()
			
			PrintF("Lua Runtime Error: ~n" + ErrorMessage)
			MessageBox = New wxMessageDialog.Create(Null , "Lua Runtime Error: ~n" + ErrorMessage, "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			'Return without saving game
			Return 0
		EndIf
		
		LuaHelper_CleanStack(LuaVM)
		LuaMutexUnlock()
			
		Return Self.SaveGame()	
	End Method
	
	Rem
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
											Self.Plat = node.GetText()
											If GlobalPlatforms.GetPlatformByName(Self.Plat).ID > 0 Then
												Self.PlatformNum = GlobalPlatforms.GetPlatformByName(Self.Plat).ID
											EndIf
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
	EndRem
	
	Method OutputInfo()
		Local GName:String
		GName = GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum
		GName = Lower(GName)	
		CreateEmptyXMLGame(GAMEDATAFOLDER + GName + FolderSlash + "Info.xml")
		'DebugStop()
		
		Self.Name = Self.GameNameFilter(Self.Name)
		Self.Desc = Self.GameDescFilter(Self.Desc)
		
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
		RootNode.addTextChild("PlatformNumber" , Null , Self.PlatformNum)
		RootNode.addTextChild("Co-op" , Null , Self.Coop)
		RootNode.addTextChild("Players" , Null , Self.Players)
		RootNode.addTextChild("PreBatchFile" , Null , Self.PreBF)
		RootNode.addTextChild("PreBatchFileWait" , Null , Self.PreBFWait)
		RootNode.addTextChild("PostBatchFile" , Null , Self.PostBF)
		RootNode.addTextChild("PostBatchFileWait" , Null , Self.PostBFWait)		

		RootNode.addTextChild("LuaFile" , Null , Self.LuaFile)
		RootNode.addTextChild("LuaIDData" , Null , Self.LuaIDData)
		
		RootNode.addTextChild("GameRunnerAlwaysOn" , Null , Self.GameRunnerAlwaysOn)
		RootNode.addTextChild("StartWaitEnabled" , Null , Self.StartWaitEnabled)
		

		RootNode.addTextChild("Mounter" , Null , Self.Mounter)
		RootNode.addTextChild("VDriveNum" , Null , Self.VDriveNum)
		RootNode.addTextChild("UnMount" , Null , Self.UnMount)
		RootNode.addTextChild("DiscImage" , Null , Self.DiscImage)
		
	
		EXENode = RootNode.addTextChild("EXEs" , Null , "")
		If GlobalPlatforms.GetPlatformByID(Self.PlatformNum).PlatType = "Folder" Then
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
		
		RootNode.addTextChild("Rating" , Null , Self.Rating)
		
		'TODO: Not sure whether this CopyFile is useless due to CreateEmptyXML() above wiping file first
		CopyFile(GAMEDATAFOLDER + GName + FolderSlash + "Info.xml" , TEMPFOLDER + "temp.xml")
		For b = 1 To 10
			SaveStatus = Gamedoc.saveFormatFile(GAMEDATAFOLDER + GName + FolderSlash + "Info.xml" , False)
			PrintF("SaveXML Try: "+b+" Status: "+SaveStatus)
			If SaveStatus <> - 1 Then Exit
			Delay 100
		Next
		If b = 10 then
			CopyFile(TEMPFOLDER + "temp.xml" , GAMEDATAFOLDER + GName + FolderSlash+"Info.xml") 
			CustomRuntimeError("Error 44: Could Not Write XML File") 'MARK: Error 44
		EndIf
		Gamedoc.free()
		Gamedoc = Null 
		
		
	End Method
	
Rem	
	Method OutputArtInfo()
		Local GName:String
		GName = GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum
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
EndRem

End Type

Type DownloadArtworkListItemType
	Field URL:String
	Field Filename:String
	
	Method Create:DownloadArtworkListItemType(URL:String, Filename:String)
		Self.URL = URL
		Self.Filename = Filename
		Return Self
	End Method	
End Type


Function DownloadArtwork_ProgressCallback:Int(data:Object, dltotal:Double, dlnow:Double, ultotal:Double, ulnow:Double) {hidden}
	PrintF( dlnow + "/" + dltotal + " bytes")
	?Not Threaded
	DatabaseApp.Yield()
	?
	
	If Log1.LogClosed = True then
		Return 1
	EndIf	
	Return 0	
End Function
