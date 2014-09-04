
Function CheckEXEDatabaseStatus:Int()
	Local curl:TCurlEasy
	TFile=WriteFile(TEMPFOLDER+"TempEXEStatus.txt")
	curl = TCurlEasy.Create()
	curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
	curl.setOptInt(CURLOPT_HEADER, 0)
	curl.setOptInt(CURLOPT_VERBOSE, 0)
	curl.setOptInt(CURLOPT_CONNECTTIMEOUT, 2)
	curl.setWriteStream(TFile)
	curl.setOptString(CURLOPT_URL, "http://photongamemanager.com/GamesEXEDatabase/StatusV4.html")
	Error = curl.perform()
	CloseFile(TFile) 
	If Error>0 Then 
		Return 0
	EndIf
	
	Local testEXEStatus:TStream	
	If FileType(TEMPFOLDER+"TempEXEStatus.txt")=1 Then 
		testEXEStatus = ReadFile(TEMPFOLDER+"TempEXEStatus.txt")
	Else
		Return 0
	EndIf 

	If testEXEStatus=Null Then 
		PrintF("Failed To Connect to EXE Status")
		EXEDatabaseOff = True 
		Return 0
	Else
		Line$=ReadLine(testEXEStatus)
		PrintF("PGM Status: "+Line)
		If Line="OFF" Then
			EXEDatabaseOff = True 
			CloseStream testEXEStatus
			Return 0
		EndIf
		If Line = "ON" Then
			PrintF("Connected to PGM")
			EXEDatabaseOff = False 
			CloseStream testEXEStatus
			Return 1
		EndIf	
		
		EXEDatabaseOff = True 
		CloseStream testEXEStatus
		Return 0	
	EndIf
End Function

Function StandardiseSlashes:String(Text:String)
	For a = 1 To Len(Text)
		If Mid(Text , a , 1) = "/" Then
			Text = Left(Text,a-1)+FolderSlash+Right(Text,Len(Text)-a)
		EndIf
	Next
	Return Text
End Function

Function CleanUpPath$(Path$)
	Rem
	Function:	Cleans up the address of boxart/fanart
			By removing the remaining of the tag from start of Path
	Input:	Path - The string address to clean up
	Return:	the cleaned up path
	SubCalls:	None
	EndRem
	For a=1 To Len(Path)
		If Mid(Path,a,1)=">" Then
			Return Right(Path,Len(Path)-a)
		EndIf
	Next
End Function	

Rem
Function GameDescriptionSanitizer$(Name$)
	Repeat
	For a=1 To Len(Name)
		If Mid(Name,a,1)="&" Then
			If Mid(Name,a,4)="&amp" Then 
				Name=Left(Name,a)+Right(Name,Len(Name)-a-4)
				Exit
			EndIf
		EndIf
		If Mid(Name,a,1)=Chr(226) Then
			Name=Left(Name,a-1)+Right(Name,Len(Name)-a-2)
			Exit			
		EndIf		
	Next
	If a=>Len(Name) Then 
		Return Name
	EndIf
	Forever
End Function	


Function GameNameSanitizer$(Name$)
	Repeat
	For a = 1 To Len(Name)
		
		If Mid(Name,a,1)="®" Then 
			Name=Left(Name,a-1)+Right(Name,Len(Name)-a)
			Exit
		EndIf
		If Mid(Name , a , 1) = "©" Then
			Name=Left(Name,a-1)+Right(Name,Len(Name)-a)
			Exit
		EndIf		
		If Mid(Name,a,1)=Chr(226) Then
			Name=Left(Name,a-1)+"-"+Right(Name,Len(Name)-a-2)
			Exit			
		EndIf		
		If Mid(Name,a,1)=":" Then 
			Name=Left(Name,a-1)+Right(Name,Len(Name)-a)
			Exit
		EndIf
		If Mid(Name,a,1)="/" Then 
			Name=Left(Name,a-1)+Right(Name,Len(Name)-a)
			Exit
		EndIf		
		If Mid(Name,a,1)="&" Then
			If Mid(Name,a,4)="&amp" Then 
				Name=Left(Name,a)+Right(Name,Len(Name)-a-4)
				Exit
			EndIf
		EndIf
		If Mid(Name,a,1)=Chr(124) Then
			Name=Left(Name,a-1)+" "+Right(Name,Len(Name)-a)
			Exit			
		EndIf
		If Mid(Name,a,1)="€" Then
			Name=Left(Name,a-1)+"-"+Right(Name,Len(Name)-a-1)
			Exit			
		EndIf		
	Next
	If a=>Len(Name) Then 
		Return Name
	EndIf
	Forever
End Function	
EndRem

Function ReturnTagInfo$(SearchLine$,Tag$,EndTag$)
	Rem
	Function:	Finds first instance of Tag and EndTag in SearchLine and returns the characters inbetween
			Sets CurrentSearchLine to the rest of SearchLine(Bit not containing Tag/EndTag)
	Input:	SearchLine - The String to search within
			Tag - The start term
			EndTag - The end term
	Return:	The string containing the characters between tags
	SubCalls:	None
	EndRem
	StartPos=0
	EndPos=0
	StartFound=False
	For a=1 To Len(SearchLine)-Len(Tag)
		If Mid(SearchLine,a,Len(Tag))=Tag$ Then
			StartPos = a + Len(Tag)
			StartFound=True
			Exit
		EndIf
	Next
	For a=1 To Len(SearchLine)-StartPos
		If Mid(SearchLine, a + StartPos, Len(EndTag) ) = EndTag$ then
			EndPos=a+StartPos
			CurrentSearchLine = Right(SearchLine , Len(SearchLine) - EndPos)
			CurrentSearchLine = Left(CurrentSearchLine , Len(CurrentSearchLine) - Len(EndTag))
			Exit			
		EndIf
	Next	
	If StartFound=True Then
		Return Mid(SearchLine,StartPos,EndPos-StartPos)
	Else
		Return ""
	EndIf
End Function

Function ReturnTagInfo2$(SearchLine$,Tag$,EndTag$)
	Rem
	Function:	Finds first instance of Tag and EndTag in SearchLine and returns the characters inbetween
			Sets CurrentSearchLine to the rest of SearchLine(Bit not containing Tag/EndTag)
	Input:	SearchLine - The String to search within
			Tag - The start term
			EndTag - The end term
	Return:	The string containing the characters between tags
	SubCalls:	None
	EndRem
	StartPos=0
	EndPos=0
	StartFound=False
	For a=1 To Len(SearchLine)-Len(Tag)
		If Mid(SearchLine,a,Len(Tag))=Tag$ Then
			StartPos=a+Len(Tag)
			StartFound=True
			Exit
		EndIf
	Next
	For a=1 To Len(SearchLine)-Len(Tag)-StartPos
		If Mid(SearchLine,a+StartPos,Len(EndTag))=EndTag$ Then
			EndPos=a+StartPos
			CurrentSearchLine=Right(SearchLine,Len(SearchLine)-EndPos)
			Exit			
		EndIf
	Next	
	If StartFound=True Then
		Return Mid(SearchLine,StartPos,EndPos-StartPos)
	Else
		Return ""
	EndIf
End Function

Function WriteGameList(SearchTerm$,Platform:String)
	Rem
	Function: Searches for SearchTerm via online database using function Search()
			Filters and sorts raw search HTML into a list of valid Game Names/IDs
	Input:	SearchTerm - String used for online Search
	Returns:	Void
	SubCalls:	GameSearchSanitizer()
			Search()
			ReturnTagInfo()
	EndRem
	SearchTerm = GameSearchSanitizer(SearchTerm)
	Search(SearchTerm,Platform)
	SearchResults=ReadFile(TEMPFOLDER +"SearchList.txt")
	SearchLine$=""
	Repeat 
		If Eof(SearchResults) Then Exit
		SearchLine=SearchLine+ReadLine(SearchResults)+" "
	Forever
	CurrentSearchLine=CurrentSearchLine+SearchLine
	CloseFile(SearchResults)
	DeleteFile(TEMPFOLDER +"SearchList.txt")
	GameListFile = WriteFile(TEMPFOLDER + "SearchGameList.txt")
	PrintF("Writing SearchGameList")
	Repeat
		'Runs through each set of tags 
		'ReturnTagInfo() will reduce CurrentSearchLine each time it runs
		ID$=ReturnTagInfo2(CurrentSearchLine,"<id>","</id>")
		GameTitle$=ReturnTagInfo2(CurrentSearchLine,"<GameTitle>","</GameTitle>")
		GamePlatform$=ReturnTagInfo2(CurrentSearchLine,"<Platform>","</Platform>")
		
		If GamePlatform=Platform Or GamePlatform="" Or Platform="" Then
			If GameTitle="" Then 
				Exit
			Else
				PrintF("Writing "+GameTitle)
				WriteLine(GameListFile,ID)
				WriteLine(GameListFile , GameTitle)
				WriteLine(GameListFile, GamePlatform)
			EndIf
		EndIf
	Forever

	CloseFile(GameListFile)
	'PlaySound SearchBeep
End Function

Function GameSearchSanitizer$(Name$)
	Rem
	Function:	Removes Illegal Characters from SearchName and returns result
	Input:	Name - SearchName to be Sanitized
	Return:	The Sanitized SearchName
	SubCalls:	None
	EndRem
	Repeat
	For a=1 To Len(Name)
		If Mid(Name,a,1)=Chr(226) Then
			Name=Left(Name,a-1)+"-"+Right(Name,Len(Name)-a-2)
			Exit			
		EndIf	
		If Mid(Name,a,1)="&" Then
			Name = Left(Name , a - 1) + "and" + Right(Name , Len(Name) - a)
			Exit
		EndIf
		If Mid(Name , a , 1) = " " Then
			Name = Left(Name , a - 1) + "%20" + Right(Name , Len(Name) - a)
			Exit			
		EndIf
	Next
	If a=>Len(Name) Then 
		Return Name
	EndIf
	Forever
End Function

Function AddPluses$(Line:String)
	For a=0 To Len(Line)
		If Mid(Line,a,1)=" " Then
			Line=Left(Line,a-1)+"+"+Right(Line,Len(Line)-a)
		EndIf
	Next
	Return Line
End Function

Function Search(Term$,Platform:String)
	Rem
	Function:	Searches thegamesdb.net for games related to Term and saves HTML response to SearchList.txt
	Input:	Term - The String to search for
	Return:	Void
	SubCalls:	AddPluses()
	EndRem
	Local s:TStream
	If Platform = "" Then
	
	Else
		Platform = AddPluses(Platform)
	EndIf
	PrintF( "Searching For: "+Term)
	PrintF( "PLATFORM: "+Platform)

	NoStream=False
	For a = 1 To 5
		If Platform = "" Then
			s = ReadStream("http::thegamesdb.net/api/GetGamesList.php?name=" + Term + "&" + ExtraKeyData)
		Else
			s = ReadStream("http::thegamesdb.net/api/GetGamesList.php?name=" + Term + "&platform=" + Platform + "&" + ExtraKeyData)
		EndIf
		If s=Null Then
			NoStream=True
		Else
			Exit
		EndIf
	Next
	SL:TStream = WriteFile(TEMPFOLDER +"SearchList.txt")
	If NoStream=False Then
		While Not s.Eof()
			HTTPRead$=s.ReadLine()
			WriteLine(SL,HTTPRead)
		Wend
	EndIf
	CloseFile(SL)
	CloseStream(s)
End Function

Rem
Function ReturnTagInfo$(SearchLine$,Tag$,EndTag$)
	'Rem
	Function:	Finds first instance of Tag And EndTag in SearchLine And returns the characters inbetween
			Sets CurrentSearchLine To the rest of SearchLine(Bit Not containing Tag/EndTag)
	Input:	SearchLine - The String To search within
			Tag - The start term
			EndTag - The End term
	Return:	The String containing the characters between tags
	SubCalls:	None
	'EndRem
	StartPos=0
	EndPos=0
	StartFound=False
	For a=1 To Len(SearchLine)-Len(Tag)
		If Mid(SearchLine,a,Len(Tag))=Tag$ Then
			StartPos=a+Len(Tag)
			StartFound=True
			Exit
		EndIf
	Next
	For a=1 To Len(SearchLine)-Len(Tag)-StartPos
		If Mid(SearchLine,a+StartPos,Len(EndTag))=EndTag$ Then
			EndPos=a+StartPos
			CurrentSearchLine=Right(SearchLine,Len(SearchLine)-EndPos)
			Exit			
		EndIf
	Next	
	If StartFound=True Then
		Return Mid(SearchLine,StartPos,EndPos-StartPos)
	Else
		Return ""
	EndIf
End Function
endrem

Function GetGameInfo(id$)
	Rem
	Function:	Gets raw HTTP data of game with specified ID and saves it to GameInfo.txt
	Input:	id - ID of game
	Return:	Void
	SubCalls:	None
	EndRem
	NoStream=False
	For a=1 To 5
		'Print "PAGE: http::thegamesdb.net/api/GetGame.php?id="+id+"&"+ExtraKeyData
		Local s:TStream = ReadStream("http::thegamesdb.net/api/GetGame.php?id="+id+"&"+ExtraKeyData)
		If s=Null Then
			NoStream=True
		Else
			Exit
		EndIf
	Next
	For a=1 To 5
		GI:TStream = WriteFile(TEMPFOLDER+"GameInfo.txt")
		If GI=Null Then

		Else
			Exit
		EndIf
	Next
	If GI=Null Then CustomRuntimeError("Error 24: GameInfo Fail") 'MARK: Error 24
	If NoStream=False Then
		While Not s.Eof()
			HTTPRead$=s.ReadLine()
			WriteLine(GI,HTTPRead)
		Wend
	EndIf
	CloseFile(GI)
	CloseStream(s)
End Function

Function SortGameList(Name$)
	Rem
	Function:	Runs WriteGameTermList() and RankGames()			
			Reorganises SearchGameList.txt into ranked order 
	Input:	Name - Game Name
	Return:	Void
	SubCalls:	WriteGameTermList()
			RankGames()
			GetRank()
	EndRem
	PrintF("Write GameTerms and Ranking Games")
	WriteGameTermList(Name$,Name$)
	MaxCount=RankGames()
	WriteGame = WriteFile(TEMPFOLDER + "SearchGameList.txt")
	PrintF("Sorted Game List:")
	For a=MaxCount To 0	Step -1
		ReadGame=ReadFile(TEMPFOLDER +"RankedGames.txt")
		While Not Eof(ReadGame)
			ID$=ReadLine(ReadGame)
			Line$ = ReadLine(ReadGame)
			Plat$ = ReadLine(ReadGame)
			Rank=GetRank(Line)
			Name$=Left(Line,Len(Line)-Len(Rank)-2)
			If Rank = a Then
				PrintF("Game: "+Name)
				WriteLine(WriteGame,ID)
				WriteLine(WriteGame , Name)
				WriteLine(WriteGame, Plat)
			EndIf
		Wend
		CloseFile(ReadGame)
	Next
	CloseFile(WriteGame)
	DeleteFile(TEMPFOLDER +"RankedGames.txt")
	DeleteFile(TEMPFOLDER +"GamePartList.txt")
End Function

Function WriteGameTermList(Name$,Dir$)
	Rem
	Function:	Takes the words of Name and Dir and writes them to GamePartList.txt with 'spaces' on the ends
	Input:	Name - Game Name
			Dir - Directory of game
	Return:	Void
	SubCalls:	None
	EndRem
	WriteList=WriteFile(TEMPFOLDER +"GamePartList.txt")
	Start=1
	For a=1 To Len(Name)
		If Mid(Name,a,1)=" " Then 
			WriteLine(WriteList,Mid(Name,Start,a-Start))
			Start=a+1
		EndIf
	Next
	WriteLine(WriteList,Mid(Name,Start,a-Start))
	
	Start=1
	For a=1 To Len(Dir)
		If Mid(Dir,a,1)=" " Then 
			If Start=1 Then
				WriteLine(WriteList,Mid(Dir,Start,a-Start)+" ")
			Else
				WriteLine(WriteList," "+Mid(Dir,Start,a-Start)+" ")
			EndIf
			Start=a+1
		EndIf
	Next	
	WriteLine(WriteList," "+Mid(Dir,Start,a-Start))
	
	CloseFile(WriteList)
End Function

Function RankGames()
	Rem
	Function:	Uses CountContains()
			Then ammends '>[Rank]' onto the end of each game name and saves it in RankedGames.txt
	Return:	Largest Rank Number
	SubCalls:	CountContains()
	EndRem
	HighestCount=0
	ReadGame=ReadFile(TEMPFOLDER +"SearchGameList.txt")
	WriteGame=WriteFile(TEMPFOLDER +"RankedGames.txt")
	Repeat
		ID$=ReadLine(ReadGame)
		Game$ = ReadLine(ReadGame)
		Plat$ = ReadLine(ReadGame)
		If Game="" Then Exit
		Count=CountContains(Game)
		If Count>HighestCount Then HighestCount=Count
		WriteLine(WriteGame,ID)
		WriteLine(WriteGame , Game + " >" + String(Count) )
		WriteLine(WriteGame , Plat)
	Forever 
	CloseFile(WriteGame)
	CloseFile(ReadGame)
	Return HighestCount
End Function

Function CountContains(FileName$)
	Rem
	Function:	Compares FileName to each term in GamePartList.txt and then adds one to rank for each match
	Input:	FileName - The String to search and rank
	Return:	Rank
	SubCalls:	ContainedWithin()
	EndRem
	Count=0
	Intials$=""
	ReadSearchTerms=ReadFile(TEMPFOLDER +"GamePartList.txt")
	Repeat
		Term$=ReadLine(ReadSearchTerms)
		If Term="" Then 
			Exit
		Else
			Intials=Intials+Left(Term,1)
		EndIf
		Count=Count+ContainedWithin(FileName,Term)
	Forever
	Count=Count+ContainedWithin(FileName,Intials)
	CloseFile(ReadSearchTerms)
	Return Count
End Function

Function ContainedWithin(Str$,Term$)
	Rem
	Function:	Searches for a term within a string and returns true/false
	Input:	Str - The String to search within
			Term - The Term to search for
	Return:	True - Term contained within Str
			False - Term not contained within Str
	SubCalls:	None
	EndRem
	For a=1 To Len(Str)-Len(Term)+1
		If Lower(Mid(Str,a,Len(Term)))=Lower(Term) Then
			Return True
		EndIf
	Next
	Return False
End Function

Function GetRank(Line$)
	Rem
	Function:	Returns the rank
	Input:	Line - Game and Rank in a string
	Return:	Void
	SubCalls:	None
	EndRem	
	For a=Len(Line) To 1 Step -1
		If Mid(Line,a,1)=">" Then
			Return Int(Right(Line,Len(Line)-a))
		EndIf 
	Next
End Function

Rem
Function DownloadGameInformation(GameNo:String , Location:String , GameDir:String , EXE:String , GameDB:String = "http://thegamesdb.net")	
	Select GameDB
		Case "http://thegamesdb.net"
			PrintF("thegamesdb.net")
			Location = StripSlash(Location)
			If FileType(Location) = 2 then
				
			Else
				CustomRuntimeError("Error 19: DownloadGameInformation Location Invalid") 'MARK: Error 19
			EndIf
			Location = Location + FolderSlash
			
			GetGameInfo(GameNo)
			
			GameInfo=ReadFile("GameInfo.txt")
			GameLine$=""
			While Not Eof(GameInfo)
				GameLine=GameLine+ReadLine(GameInfo)+" "
			Wend	
			CloseFile GameInfo
			
			GameBaseURL$ = ReturnTagInfo2(GameLine , "<baseImgUrl>" , "</baseImgUrl>")
			GameTitle$ = ReturnTagInfo2(GameLine,"<GameTitle>","</GameTitle>")
			GameTitle = GameNameSanitizer$(GameTitle)
			GameOverview$ = GameDescriptionSanitizer$(ReturnTagInfo2(GameLine,"<Overview>","</Overview>"))
			RelDate$=ReturnTagInfo2(GameLine,"<ReleaseDate>","</ReleaseDate>")
			ESRB$=ReturnTagInfo2(GameLine,"<ESRB>","</ESRB>")
			Develop$=ReturnTagInfo2(GameLine,"<Developer>","</Developer>")
			Publish$=ReturnTagInfo2(GameLine,"<Publisher>","</Publisher>")
			Rating$ = ReturnTagInfo2(GameLine , "<Rating>" , "</Rating>")
			Plat$ = ReturnTagInfo2(GameLine , "<Platform>" , "</Platform>")
			If Rating="" Then Rating="0"
		
			CurrentSearchLine=ReturnTagInfo2(GameLine,"<Genres>","</Genres>")
			Genres$=""
			Repeat
				genre$=ReturnTagInfo2(CurrentSearchLine,"<genre>","</genre>")
				If genre="" Then Exit
				Genres=Genres+"/"+genre
			Forever
			Genres = Right(Genres , Len(Genres) - 1)
			
			PrintF("GameTitle: "+GameTitle)
			PrintF("GameTitle: " + GameOverview)
			PrintF("GameTitle: " + GameDir)
			PrintF("GameTitle: " + EXE)
			PrintF("GameTitle: " + RelDate)
			PrintF("GameTitle: " + ESRB)
			PrintF("GameTitle: " + Develop)
			PrintF("GameTitle: " + Publish)
			PrintF("GameTitle: " + Genres)
			PrintF("GameTitle: " + GameNo)
			PrintF("GameTitle: " + Rating)
			PrintF("GameTitle: " + Plat)
			
			TempInfo=WriteFile(Location+"Info.txt")
			WriteLine(TempInfo,GameTitle)
			WriteLine(TempInfo,GameOverview)
			WriteLine(TempInfo,GameDir)
			WriteLine(TempInfo,EXE)
			WriteLine(TempInfo,RelDate)
			WriteLine(TempInfo,ESRB)
			WriteLine(TempInfo,Develop)
			WriteLine(TempInfo,Publish)
			WriteLine(TempInfo,Genres)
			WriteLine(TempInfo,GameNo)
			WriteLine(TempInfo,Rating)
			WriteLine(TempInfo,Plat)
			CloseFile(TempInfo)	
			
			
			Local FanArtText:String
			Local FanArtThumb:String
			Local FanArtPath:String
			CurrentSearchLine=GameLine
			TempFanArts=WriteFile(Location+"FanArt.txt")
			Repeat
				FanArtText=ReturnTagInfo2(CurrentSearchLine,"<fanart>","</fanart>")
				If FanArtText = "" Exit	
				FanArtThumb=GameBaseURL+ReturnTagInfo2(FanArtText,"<thumb>","</thumb>")
				FanArtPath=ReturnTagInfo2(FanArtText,"<original","</original>")
				FanArtPath=GameBaseURL+CleanUpPath$(FanArtPath)
				WriteLine(TempFanArts,FanArtThumb)
				WriteLine(TempFanArts,FanArtPath)			
			Forever
			CloseFile(TempFanArts)
			
			
			Local ScreenShotText:String
			Local ScreenShotThumb:String
			Local ScreenShotPath:String
			CurrentSearchLine=GameLine
			TempScreenShot=WriteFile(Location+"ScreenShot.txt")
			Repeat
				ScreenShotText=ReturnTagInfo2(CurrentSearchLine,"<screenshot>","</screenshot>")
				If ScreenShotText="" Then Exit	
				ScreenShotThumb=GameBaseURL+ReturnTagInfo2(ScreenShotText,"<thumb>","</thumb>")
				ScreenShotPath=ReturnTagInfo2(ScreenShotText,"<original","</original>")
				ScreenShotPath=GameBaseURL+CleanUpPath$(ScreenShotPath)
				WriteLine(TempScreenShot,ScreenShotThumb)
				WriteLine(TempScreenShot,ScreenShotPath)			
			Forever
			CloseFile(TempScreenShot)
				
			Local GameBoxArt:String	
			Local GameBoxArtBack:String
			
			TempBoxArt=WriteFile(Location+"FrontBoxArt.txt")
			GameBoxArt = ReturnTagInfo2(GameLine , "<boxart side=" + Chr(34) + "front" + Chr(34) , "</boxart>")
			tempCleanPath:String = CleanUpPath$(GameBoxArt)
			If tempCleanPath = "" Or tempCleanPath = " " Then
			
			Else
				GameBoxArt = GameBaseURL + tempCleanPath
			EndIf
			WriteLine(TempBoxArt , GameBoxArt)
			CloseFile(TempBoxArt)			
			
			TempBoxArt=WriteFile(Location+"BackBoxArt.txt")			
			GameBoxArtBack = ReturnTagInfo2(GameLine , "<boxart side=" + Chr(34) + "back" + Chr(34) , "</boxart>")	
			tempCleanPath:String = CleanUpPath$(GameBoxArtBack)
			If tempCleanPath = "" Or tempCleanPath = " " Then
			
			Else
				GameBoxArtBack = GameBaseURL +  tempCleanPath
			EndIf
			WriteLine(TempBoxArt , GameBoxArtBack)
			CloseFile(TempBoxArt)
				
			Local GameBannerArt:String
			CurrentSearchLine=GameLine
			TempBanner=WriteFile(Location+"Banner.txt")
			Repeat
				GameBannerArt = ReturnTagInfo2(CurrentSearchLine , "<banner " , "</banner>")
				If GameBannerArt = "" Then Exit
				GameBannerArt = GameBaseURL+CleanUpPath$(GameBannerArt)
				WriteLine(TempBanner , GameBannerArt)
			Forever
			CloseFile(TempBanner)
			
			TempIcon = WriteFile(Location+"Icon.txt")
			WriteLine(TempIcon , GameDir + EXE)
			CloseFile(TempIcon)
		Default
			CustomRuntimeError("Error 20: Invalid GameDB") 'MARK: Error 20
	End Select
End Function	

EndRem
	
Function IntegrateGameData(Ssrc:String , Msrc:String , dest:String)
	If FileType(Ssrc) = 1 Then
	
	Else
		CustomRuntimeError("Error 21: IntegrateGameData, Ssrc error") 'MARK: Error 21
	EndIf
	If FileType(Msrc) = 1 Then
	
	Else
		CustomRuntimeError("Error 22: IntegrateGameData, Msrc error") 'MARK: Error 22
	EndIf	
	If FileType(dest) = 1 Then
		PrintF("Dest: " + dest)
		PrintF("Msrc: " + Msrc)
		PrintF("Ssrc: " + Ssrc)
		CustomRuntimeError("Error 23: IntegrateGameData, dest error") 'MARK: Error 23
	EndIf	
	WriteData = WriteFile(dest)
	ReadMaster = ReadFile(Msrc)
	ReadSlave = ReadFile(Ssrc)
	Local MasterLine:String,SlaveLine:String
	Repeat
		MasterLine = ReadLine(ReadMaster)
		SlaveLine = ReadLine(ReadSlave)
		If MasterLine = "" Then
			PrintF("Printing Slave Line")
			WriteLine(WriteData,SlaveLine)
		Else
			PrintF("Printing Master Line")
			WriteLine(WriteData,MasterLine)
		EndIf
		If Eof(ReadMaster) And Eof(ReadSlave) Then Exit	
	Forever
	CloseFile(ReadMaster)
	CloseFile(ReadSlave)
	CloseFile(WriteData)
End Function

Function SanitiseForInternet:String(Text:String)
	Local RepeatLoop:Int
	Local CharCode:String
	Repeat
		RepeatLoop = False
		For a = 1 To Len(Text)
			
			Select Mid(Text , a , 1)
				Case " " , "&" , "." , "," , "!" , "$" , "'"
					Select Mid(Text , a , 1)
						Case " "
							CharCode = "%20"
						Case "&"
							CharCode = "%26"
						Case ","
							CharCode = "%2C"
						Case "!"
							CharCode = "%21"	
						Case "."
							CharCode = "%2E"	
						Case "$"
							CharCode = "%24"
						Case "'"
							CharCode = "%27"
											
					End Select
					Text = Left(Text , a - 1) + CharCode + Right(Text , Len(Text) - a)
					RepeatLoop = True
					Exit									
			End Select
		Next
		If RepeatLoop = False Then Exit
	Forever
	Return Text
End Function