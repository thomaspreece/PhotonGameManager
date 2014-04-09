
Function OutputGDFs()
	PrintF("----------------------------OutputGDFs----------------------------")
	'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Log" , , , 300 , 400) )
	Log1.Show(1)
	Local MessageBox:wxMessageDialog
	'If OUTPUTGDFSCOMPLETED = False Then
	If FileType(TEMPFOLDER + "GDF") = 2 Then
		MessageBox = New wxMessageDialog.Create(Null, "Refresh Local Game Explorer Data? (Only needed if new games have been added to game explorer since last import)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			WriteRawGDF(Log1)		
		EndIf
	Else
		WriteRawGDF(Log1)
	EndIf
	'EndIf
	PrintF("Finish GDF Output")
	'Log1.Destroy()	
	Log1.Show(0)
End Function

Function ExtractMults:String(Tex:String , StartTag:String , EndTag:String , StartTagEnd:String = "" , EndTagEnd:String = "" , SepTag:String = "/")
	CurrentSearchLine = Tex
	Local ReturnValues:String = ""
	Local temp:String = "" , temp2:String = "" , tempCSL:String = ""
	If StartTagEnd = "" And EndTagEnd = "" Then
		Repeat
			temp = ReturnTagInfo(CurrentSearchLine , StartTag , EndTag)
			If temp = "" Then Exit
			ReturnValues = ReturnValues + StripSpaces(StripQuotes(temp)) + SepTag
		Forever
		ReturnValues = Left(ReturnValues , Len(ReturnValues) - 1)
	Else
		Repeat
			
			temp = ReturnTagInfo(CurrentSearchLine , StartTag , EndTag)
			If temp = "" Then Exit
			tempCSL = CurrentSearchLine
			temp2 = ReturnTagInfo(temp , StartTagEnd , EndTagEnd)
			CurrentSearchLine = tempCSL
			ReturnValues = ReturnValues + StripSpaces(StripQuotes(temp2)) + SepTag
		Forever
		ReturnValues = Left(ReturnValues , Len(ReturnValues) - 1)
	EndIf

	Return ReturnValues
End Function

Function StripSpaces:String(Tex:String)
	Repeat
		If Left(Tex , 1) = " " Then
			Tex = Right(Tex , Len(Tex)-1 )
		Else
			Exit
		EndIf
	Forever
	Repeat
		If Right(Tex , 1) = " " Then
			Tex = Left(Tex , Len(Tex)-1 )
		Else
			Exit
		EndIf
	Forever	
	Return Tex
End Function

Function StripQuotes:String(Tex:String)
Name:String = Tex
Repeat
	For a = 1 To Len(Name)
		
		If Mid(Name,a,1)=Chr(34) Then 
			Name=Left(Name,a-1)+Right(Name,Len(Name)-a)
			Exit
		EndIf
	Next
	If a=>Len(Name) Then 
		Return Name
	EndIf
Forever
End Function

Function WriteRawGDF(Log1:LogWindow)	
	DeleteCreateFolder(TEMPFOLDER + "GDF")
	Local RegKeys$
	Local GameRegs$
	Local GDFDataWrite:TStream
	Local Dir$,GDF$,Title$,Desc$,EXE$,Dev$,Gen$,Pub$,Rel$
	Local ReadExtractDir:Int , GDFFound:Int
	Local tempString:String, tempEXE:String
	
	Local GDFFile:String,File:String,GDFFileString:String
	RegKeys = ReturnReg("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\GameUX")
	Repeat
		For a=1 To Len(RegKeys)
			If Mid(RegKeys,a,1)="|" Then
				Game$=Left(RegKeys,a-1)
				GameRegs=GameRegs+ ReturnReg(Game)
				RegKeys=Right(RegKeys,Len(RegKeys)-a)
				Delay 100
				Exit
			EndIf
		Next
		If Len(RegKeys)<=1 Then Exit
	Forever

	Repeat
		For a=1 To Len(GameRegs)
			If Mid(GameRegs , a , 1) = "|" Then
				PrintF("Searching New Reg")
				Game$ = Left(GameRegs , a - 1)
				Dir$ = StripSlash(ReturnGDFDatas(Game , "ConfigApplicationPath") ) + FolderSlash
				Dir = StandardiseSlashes(Dir)
				GDF$=ReturnGDFDatas(Game,"ConfigGDFBinaryPath")
				Title$ = ReturnGDFDatas(Game , "Title")
				Desc$ = ReturnGDFDatas(Game , "Description")
				Title = GameNameSanitizer(Title)
				
				Desc = GameDescriptionSanitizer(Desc)				
				EXE$ = ReturnGDFDatas(Game , "AppExePath")
				EXE = StandardiseSlashes(EXE)
				
				Dev$ = ReturnGDFDatas(Game , "DeveloperName")
				Gen$ = ReturnGDFDatas(Game , "Genre")
				Pub$ = ReturnGDFDatas(Game , "PublisherName")
				Rel$ = ReturnGDFDatas(Game , "ReleaseDate")	
				
											
				If Left(EXE , Len(Dir) ) = Dir Then EXE = Right(EXE , Len(EXE) - Len(Dir) )
				If Right(Dir , Len(EXE) ) = EXE Then Dir = Left(Dir , Len(Dir) - Len(EXE) )
								
				If FileType(StripSlash(Dir) ) = 0 Or FileType(StripSlash(Dir) ) = 1 Then
					PrintF("Dir Error")
					PrintF(Dir)					
					Title = ""
				EndIf
							
				If Title = "" Then
					PrintF("No File/Title for "+Game)
				Else
					PrintF("Title: " + Title)
					
					Local GDesc:String = ""
					Local GGens:String = ""
					Local GEXEs:String = ""
					Local GPubs:String = ""
					Local GDevs:String = ""
					Local GRel:String = ""

					DeleteCreateFolder(TEMPFOLDER + "GDFExtract")
					ExtractGDFProcess = CreateProcess(ResourceExtractPath + " /Source " + Chr(34) + GDF + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "GDFExtract"+ FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 1 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 0 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 0")
					Repeat
						Delay 10
						If ProcessStatus(ExtractGDFProcess)=0 Then Exit
					Forever	
					ReadExtractDir = ReadDir(TEMPFOLDER + "GDFExtract"+FolderSlash)			
					Repeat
						File = NextFile(ReadExtractDir)
						If File = "" Then Exit
						If File="." Or File=".." Then Continue
						For b = 1 To Len(File)-Len("GDF_XML_DATA")
							If Mid(File , b , Len("GDF_XML_DATA") ) = "GDF_XML_DATA" Then
								GDFFound = True
								GDFFile = TEMPFOLDER + "GDFExtract"+ FolderSlash + File
								PrintF("Found GDF: "+GDFFile)
								Exit
							EndIf
						Next
						If GDFFound = True Then Exit
					Forever

					GDFFileString = ""
					If GDFFound = False Then
						PrintF("No GDF Found")
					Else
						ReadGDFData = ReadFile(GDFFile)
						Repeat
							Local temp:String
							temp = ReadLine(ReadGDFData)
							If Eof(ReadGDFData) Then Exit
							GDFFileString = GDFFileString + temp
						Forever
						CloseFile(ReadGDFData)
						
						GDesc = ReturnTagInfo(GDFFileString , "<Description>" , "</Description>")
						GGens = ReturnTagInfo(GDFFileString , "<Genres>" , "</Genres>")
						GGens = ExtractMults(GGens , "<Genre>" , "</Genre>")
						GEXEs = ReturnTagInfo(GDFFileString , "<GameExecutables>" , "</GameExecutables>")
						GEXEs = ExtractMults(GEXEs , "<GameExecutable path=" , "/>" , "" , "" , "|" )
						GEXEs = StandardiseSlashes(GEXEs)
						GPubs = ReturnTagInfo(GDFFileString , "<Publishers>" , "</Publishers>")
						GPubs = ExtractMults(GPubs , "<Publisher " , "/Publisher>" , ">" , "<")
						GDevs = ReturnTagInfo(GDFFileString , "<Developers>" , "</Developers>")
						GDevs = ExtractMults(GDevs , "<Developer " , "/Developer>" , ">" , "<")
						GRel = ReturnTagInfo(GDFFileString , "<ReleaseDate>" , "</ReleaseDate>")
						
						GDesc = GameDescriptionSanitizer(GDesc)
										
					EndIf
					CloseDir(ReadExtractDir)
					
					If IsntNull(GDesc) Then Desc = GDesc
					If IsntNull(GEXEs) Then EXE = GEXEs
					If IsntNull(GRel) Then Rel = GRel
					If IsntNull(GDevs) Then Dev = GDevs
					If IsntNull(GPubs) Then Pub = GPubs
					If IsntNull(GGens) Then Gen = GGens
					
				
					PrintF( "Dir: "+Dir$)
					PrintF( "GDF: "+GDF$)
					PrintF( "Desc: "+Desc$)
					PrintF( "EXE: "+EXE$)
					PrintF( "Dev: "+Dev$)
					PrintF( "Gen: "+Gen$)
					PrintF( "Pub: "+Pub$)
					PrintF( "Rel: "+Rel$)	
					
					tempEXE = ""
					tempString = ""
					
					j = 1
					For k = 1 To Len(EXE)
						If Mid(EXE , k , 1) = "|" Then
							tempString = Mid(EXE , j , k - j)
							If FileType(StripSlash(Dir) + FolderSlash + tempString)=1 Then
								tempEXE = tempEXE + tempString + "|"
							EndIf
							j = k + 1
						EndIf
					Next	
					tempString = Mid(EXE , j , k - j)
					If FileType(StripSlash(Dir) + FolderSlash + tempString)=1 Then
						tempEXE = tempEXE + tempString + "|"
					EndIf
					tempEXE = Left(tempEXE , Len(tempEXE) - 1)
					If tempEXE = "" Then
						PrintF("tempEXE null")
					Else
						Log1.AddText("Found: "+Title)
						CreateDir(TEMPFOLDER + "GDF" + FolderSlash + Title)
						PrintF("Writing Data to file")
						DirFile = WriteFile(TEMPFOLDER + "GDF" + FolderSlash + Title + FolderSlash +"Data.txt")
						WriteLine(DirFile , Title ) 'Name
						WriteLine(DirFile , Desc ) 'Description
						WriteLine(DirFile , Dir ) 'Path
						WriteLine(DirFile , tempEXE ) 'EXEs
						WriteLine(DirFile , Rel ) 'Release Date
						WriteLine(DirFile , "" ) 'Rating
						WriteLine(DirFile , Dev ) 'Developer
						WriteLine(DirFile , Pub ) 'Publisher		
						WriteLine(DirFile , Gen ) 'Genres	
						WriteLine(DirFile , "" ) 'ID
						WriteLine(DirFile , "" ) 'Score
						WriteLine(DirFile , "PC") 'Platform					
						CloseFile(DirFile)				
						PrintF("Done writing data")					
					EndIf
					If Log1.LogClosed = True Then
						ExitGDF = True 
						Exit
					EndIf
				EndIf 
			
				GDFFound = False			
				GameRegs=Right(GameRegs,Len(GameRegs)-a)
				Exit
			EndIf
		Next
		PrintF("")
		If Len(GameRegs)<=1 Or ExitGDF = True Then Exit
	Forever
	'CloseFile(GDFDataWrite)
	DeleteDir(TEMPFOLDER + "GDFExtract"+FolderSlash , 0)	
	DeleteFile(TEMPFOLDER + "RawGDF.txt")	
	DeleteFile(TEMPFOLDER + "Reg.txt")
End Function



Function ReturnReg:String(Reg$)
	Local RegOutput:String
	Local temp_proc:TProcess
	PrintF("Returning Reg: "+Reg)
	DeleteFile(TEMPFOLDER + "Reg.txt")
	PrintF("Windows Bit: "+WinBit)
	Select WinBit
		Case 64
			'WinExec WinDir + "\sysnative\cmd.exe /C "+Chr(34)+ WinDir + "\system32\reg.exe QUERY "+Reg+" >> "+TEMPFOLDER + "Reg.txt"+Chr(34), 1
			temp_proc = CreateProcess(WinDir + "\sysnative\cmd.exe /C "+Chr(34)+ WinDir + "\system32\reg.exe QUERY "+Reg+" >> "+TEMPFOLDER + "Reg.txt"+Chr(34) , 1)
		Case 32
			'WinExec WinDir + "\system32\cmd.exe /C "+Chr(34)+ WinDir + "\system32\reg.exe QUERY "+Reg+" >> "+TEMPFOLDER + "Reg.txt"+Chr(34), 1
			temp_proc = CreateProcess(WinDir + "\system32\cmd.exe /C "+Chr(34)+ WinDir + "\system32\reg.exe QUERY "+Reg+" >> "+TEMPFOLDER + "Reg.txt"+Chr(34) , 1)
		Default
			CustomRuntimeError("Error 12: Invalid Windows Bit") 'MARK: Error 12				
	End Select

	While temp_proc.status()
		Delay 100
	Wend

	timer = MilliSecs()
	Repeat
		If FileType(TEMPFOLDER + "Reg.txt") = 1 Then Exit
		Delay 100
		If MilliSecs() - timer > 10000 Then
			CustomRuntimeError("Error 13: Failed to Return Registry Data, reg.exe unresponsive.") 'MARK: Error 13
		EndIf
	Forever
	tempRead = ReadFile(TEMPFOLDER + "Reg.txt")
	
	Repeat
		If Eof(tempRead) Then Exit
		temp:String = ReadLine(tempRead)
		PrintF("Reg.exe Output: "+temp)
		If Left(temp,Len(Reg))=Reg Then
			If temp=Reg Then
			
			Else
				RegOutput$=RegOutput+temp+"|"
			EndIf
		EndIf	
		
	Forever
			
	CloseFile(tempRead)
	Return RegOutput
End Function

Function ReturnGDFDatas:String(Reg$,Data$)
	Local RegOutput:String
	Local ReturnValueSet = False
	Local ReturnValue:String
	Local temp_proc:TProcess
	
	For c = 1 To 3
				
		Select WinBit
			Case 64
				temp_proc = CreateProcess(WinDir + "\sysnative\reg.exe QUERY " + Reg + " /v " + Data , 1)
			Case 32
				temp_proc = CreateProcess(WinDir + "\system32\reg.exe QUERY " + Reg + " /v " + Data , 1)
			Default
				CustomRuntimeError("Error 14: Invalid Windows Bit")	'MARK: Error 14
		End Select	
		
		
		While temp_proc.status() Or (temp_proc.pipe.ReadAvail() And ReturnValueSet=False)
			If temp_proc.pipe.ReadAvail() And ReturnValueSet=False  Then
				temp$ = temp_proc.pipe.ReadLine()

				Select Data
					Case "Description","AppExePath","DeveloperName","Genre","PublisherName","ReleaseDate"
						If SearchString(temp,Data)=1 Then
							For a = 1 To Len(temp)
								If Mid(temp , a , Len("REG_SZ") ) = "REG_SZ" Then
									temp = Right(temp , Len(temp) - a - Len("REG_SZ") )
									For b = 1 To Len(temp)
										If Mid(temp , b , 1) = " " Then
				
										Else
											ReturnValue = Right(temp , Len(temp) - b + 1)
											ReturnValueSet = True	
																		
										EndIf
										If ReturnValueSet = True Then Exit
									Next
								EndIf
								If ReturnValueSet = True Then Exit						
							Next
						EndIf
						ReturnNull = True
					Case "ConfigApplicationPath"
						If SearchString(temp,"ConfigApplicationPath")=1 Then
							For a=1 To Len(temp)
								If Mid(temp,a,1)="\" Or Mid(temp,a,1)="/" Then
									'Print Right(temp,Len(temp)-a+3)
									ReturnValue = Right(temp , Len(temp) - a + 3)
									ReturnValueSet = True	
									Exit					
								EndIf
							Next
						EndIf
					Case "ConfigGDFBinaryPath"
						If SearchString(temp,"ConfigGDFBinaryPath")=1 Then
							For a=1 To Len(temp)
								If Mid(temp,a,1)="\" Or Mid(temp,a,1)="/" Then
									'Print Right(temp,Len(temp)-a+3)
									ReturnValue = Right(temp , Len(temp) - a + 3)
									ReturnValueSet = True
									Exit
								EndIf
							Next
						EndIf	
						ReturnNull = True				
					Case "Title"
						If SearchString(temp,"Title")=1 Then
							For a = 1 To Len(temp)
								If Mid(temp , a , Len("REG_SZ") ) = "REG_SZ" Then
									temp = Right(temp , Len(temp) - a - Len("REG_SZ") )
									For b = 1 To Len(temp)
										If Mid(temp , b , 1) = " " Then
				
										Else
											ReturnValue = Right(temp , Len(temp) - b + 1)
											ReturnValueSet = True	
																		
										EndIf
										If ReturnValueSet = True Then Exit
									Next
								EndIf
								If ReturnValueSet = True Then Exit						
							Next
						EndIf
					Default
						CustomRuntimeError("Error 15: Non Suitable data type provided in ReturnGDFDatas") 'MARK: Error 15
				End Select
			EndIf
		Wend
		
		If ReturnValueSet = True Then
			Delay 100
			Return ReturnValue
		EndIf	
		If ReturnNull = True Then
			Delay 100
			Return ""
		EndIf
	Next	
	
	CustomRuntimeError("Error 16: Extract GDF App Error. Reg: "+Reg+" Data: "+Data) 'MARK: Error 16
End Function


Function SearchString(Word:String,SearchWord:String)
	For a=1 To Len(Word)-Len(SearchWord)
		If Mid(Word,a,Len(SearchWord))=SearchWord Then
			Return 1
		EndIf
	Next
	Return 0
End Function

