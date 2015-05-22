
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

Function ReturnTagInfo$(SearchLine$, Tag$, EndTag$)
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
	EndPos = 0
	StartFound=False
	For a = 1 To Len(SearchLine) - Len(Tag)
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
