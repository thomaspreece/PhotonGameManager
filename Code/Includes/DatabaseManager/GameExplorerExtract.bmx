
Function OutputGDFs()
	PrintF("----------------------------OutputGDFs----------------------------")
	'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Log" , , , 300 , 400) )
	Log1.Show(1)
	Log1.AddText("Looking for games...")
	Local MessageBox:wxMessageDialog
	?Threaded
	Local RawGDFThread:TThread
	?
	'If OUTPUTGDFSCOMPLETED = False Then
	If FileType(TEMPFOLDER + "GDF") = 2 Then
		MessageBox = New wxMessageDialog.Create(Null, "Refresh Local Game Explorer Data? (Only needed if new games have been added to game explorer since last import)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES Then
			?Threaded
			RawGDFThread = CreateThread(Thread_WriteRawGDF, Null)
			While RawGDFThread.Running()
				DatabaseApp.Yield()
				Delay 100
			Wend
			?Not Threaded
			Thread_WriteRawGDF(Null)
			?
		EndIf
	Else
		?Threaded
		RawGDFThread = CreateThread(Thread_WriteRawGDF, Null)
		While RawGDFThread.Running()
			DatabaseApp.Yield()
			Delay 100
		Wend
		?Not Threaded
		Thread_WriteRawGDF(Null)
		?
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
	If StartTagEnd = "" And EndTagEnd = "" then
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
		else
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
			Name = Left(Name, a - 1) + Right(Name, Len(Name) - a)
			Exit
		EndIf
	Next
	If a=>Len(Name) Then 
		Return Name
	EndIf
Forever
End Function

Function Thread_WriteRawGDF:Object(obj:Object)	
	DeleteCreateFolder(TEMPFOLDER + "GDF")
	Local RegKeys$
	Local GameRegs$
	Local GDFDataWrite:TStream
	Local Dir$, GDF$, Title$, Desc$, EXE$, Dev$, Gen$, Pub$, Rel$, TitleDir$
	Local ReadExtractDir:Int , GDFFound:Int
	Local tempString:String, tempEXE:String
	
	Local GDFFile:String,File:String,GDFFileString:String
	RegKeys = ReturnReg("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\GameUX")
	Repeat
		For a = 1 To Len(RegKeys)
			If Mid(RegKeys, a, 1) = "|" then
				Game$ = Left(RegKeys, a - 1)
				GameRegs = GameRegs + ReturnReg(Game)
				RegKeys = Right(RegKeys, Len(RegKeys) - a)
				
				Delay 100
				Exit
			EndIf
		Next
		If Len(RegKeys)<=1 Then Exit
	Forever

	Repeat
		For a = 1 To Len(GameRegs)
			If Mid(GameRegs , a , 1) = "|" then
				PrintF("Searching New Reg")
				Game$ = Left(GameRegs , a - 1)
							
				Dir$ = StripSlash(ReturnGDFDatas(Game , "ConfigApplicationPath") ) + FolderSlash
				Dir = StandardiseSlashes(Dir)
				GDF$=ReturnGDFDatas(Game,"ConfigGDFBinaryPath")
				Title$ = ReturnGDFDatas(Game , "Title")
				Desc$ = ReturnGDFDatas(Game , "Description")
				Title = GameReadType.GameNameFilter(Title)
				TitleDir = GameReadType.GameNameDirFilter(Title)
				
				Desc = GameReadType.GameDescFilter(Desc)				
				EXE$ = ReturnGDFDatas(Game , "AppExePath")
				EXE = StandardiseSlashes(EXE)
				
				Devs$ = ReturnGDFDatas(Game , "DeveloperName")
				Gens$ = ReturnGDFDatas(Game , "Genre")
				Pubs$ = ReturnGDFDatas(Game , "PublisherName")
				Rel$ = ReturnGDFDatas(Game , "ReleaseDate")	
				
				Rem							
				If Left(EXE , Len(Dir) ) = Dir then EXE = Right(EXE , Len(EXE) - Len(Dir) )
				If Right(Dir , Len(EXE) ) = EXE Then Dir = Left(Dir , Len(Dir) - Len(EXE) )
				EndRem
				
				
				'Game must have valid Dir otherwise not installed!
				If FileType(StripSlash(Dir) ) = 0 Or FileType(StripSlash(Dir) ) = 1 Then
					PrintF("Dir Error")
					PrintF(Dir)					
					Title = ""
				EndIf
				
							
				If Title = "" then
					PrintF("No File/Title for " + Game)
				else
					PrintF("Title: " + Title)
					
					Local GEXEs:TList = CreateList()
					Local GEXEs2:TList = CreateList()

					DeleteCreateFolder(TEMPFOLDER + "GDFExtract")
					ExtractGDFProcess = CreateProcess(ResourceExtractPath + " /Source " + Chr(34) + GDF + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "GDFExtract"+ FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 1 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 0 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 0")
					Repeat
						Delay 10
						If ProcessStatus(ExtractGDFProcess)=0 Then Exit
					Forever	
					ReadExtractDir = ReadDir(TEMPFOLDER + "GDFExtract" + FolderSlash)			
					Repeat
						File = NextFile(ReadExtractDir)
						If File = "" Then Exit
						If File="." Or File=".." Then Continue
						For b = 1 To Len(File) - Len("GDF_XML_DATA")
							If Mid(File , b , Len("GDF_XML_DATA") ) = "GDF_XML_DATA" Then
								GDFFound = True
								GDFFile = TEMPFOLDER + "GDFExtract"+ FolderSlash + File
								PrintF("Found GDF: "+GDFFile)
								Exit
							EndIf
						Next
						If GDFFound = True Then Exit
					Forever 
					CloseDir(ReadExtractDir)
					
					GDFFileString = ""
					If GDFFound = False Then
						PrintF("No GDF Found")
					Else
												
						'No repeat needed but used so we can use exit command.
						Repeat

							Local Gamedoc:TxmlDoc
							Local RootNode:TxmlNode, SubRootNode:TxmlNode , node:TxmlNode , SubNode:TxmlNode , SubSubNode:TxmlNode, SubSubSubNode:TxmlNode , SubSubSubSubNode:TxmlNode
							
							Local Regfilter:TRegEx = New TRegEx.Create("://") 'Look for :// as in http://
							Local Regfilter2:TRegEx = New TRegEx.Create(":\\") 'Look for :\ as in C:\
																	
							Local ChildrenList:TList, ChildrenList2:TList, ChildrenList3:TList, ChildrenList4:TList , ChildrenList5:TList , ChildrenList6:TList
									
							Gamedoc = TxmlDoc.parseFile(GDFFile)
							PrintF("Parsed File")
							If Gamedoc = Null then
								PrintF("XML Document not parsed successfully, GameExplorerExtract. " + GName)
								Exit			
								
							End If
									
							RootNode = Gamedoc.getRootElement()
							PrintF("Root Element")
							If RootNode = Null Then
								Gamedoc.free()
								Gamedoc = Null 
								PrintF("Empty document, GetGameXML. "+ GName)
								Exit				
								
							End If		

							If RootNode.getName() <> "GameDefinitionFile" then
								Gamedoc.free()
								Gamedoc = Null 
								PrintF("Document of the wrong type, root node <> GameDefinitionFile, GameExplorerExtract. "+ GName)
								Exit		
								
							End If
									
							PrintF("Retrieved Child List")
							ChildrenList = RootNode.getChildren()
							If ChildrenList = Null Or ChildrenList.IsEmpty() Then
								Gamedoc.free()
								Gamedoc = Null
								PrintF("Document error, no data contained within, GameExplorerExtract. " + GName)
								Exit
									
							EndIf

							For SubRootNode = EachIn ChildrenList
								If SubRootNode.getName() = "GameDefinition" then
									ChildrenList2 = SubRootNode.getChildren()
									If ChildrenList2 = Null Or ChildrenList2.IsEmpty() then
										Gamedoc.free()
										Gamedoc = Null
										PrintF("Document error, no data contained within, GameExplorerExtract. " + GName)
										Exit
												
									EndIf
									For node = EachIn ChildrenList2
										Select node.getName()
											Case "Description"
												Desc = node.GetText()
											Case "ReleaseDate"
												Rel = node.GetText()
											Case "Genres"
												ChildrenList3 = node.getChildren()
												If ChildrenList3 = Null Or ChildrenList3.IsEmpty() then
												
												else
													Gens = ""
													For SubNode = EachIn ChildrenList3
														If SubNode.getName() = "Genre" then
															Gens = Gens + SubNode.GetText() + "/"
														EndIf
													Next
													If Len(Gens) > 0 then Gens = Left(Gens, Len(Gens) - 1)
												EndIf
											Case "Developers"
												ChildrenList3 = node.getChildren()
												If ChildrenList3 = Null Or ChildrenList3.IsEmpty() then
												
												else
													Devs = ""
													For SubNode = EachIn ChildrenList3
														If SubNode.getName() = "Developer" then
															Devs = Devs + SubNode.GetText() + "/"
														EndIf
													Next
													If Len(Devs) > 0 then Devs = Left(Devs, Len(Devs) - 1)
												EndIf				
											Case "Publishers"
												ChildrenList3 = node.getChildren()
												If ChildrenList3 = Null Or ChildrenList3.IsEmpty() then
												
												else
													Pubs = ""
													For SubNode = EachIn ChildrenList3
														If SubNode.getName() = "Publisher" then
															Pubs = Pubs + SubNode.GetText() + "/"
														EndIf
													Next
													If Len(Pubs) > 0 then Pubs = Left(Pubs, Len(Pubs) - 1)
												EndIf					
											Case "GameExecutables"
												ChildrenList3 = node.getChildren()
												If ChildrenList3 = Null Or ChildrenList3.IsEmpty() then
												
												else
													For SubNode = EachIn ChildrenList3
														If SubNode.getName() = "GameExecutable" then
															If Regfilter.Find(SubNode.getAttribute("path") ) = Null And Regfilter2.Find(SubNode.getAttribute("path") ) = Null then
																ListAddLast(GEXEs, Dir + SubNode.getAttribute("path") )
															else
																ListAddLast(GEXEs, SubNode.getAttribute("path") )
															EndIf
														EndIf
													Next
													
												EndIf	
											Case "ExtendedProperties"
												ChildrenList3 = node.getChildren()
												If ChildrenList3 = Null Or ChildrenList3.IsEmpty() then
												
												else
													For SubNode = EachIn ChildrenList3
														If SubNode.getName() = "GameTasks"
															ChildrenList4 = SubNode.getChildren()
															If ChildrenList4 = Null Or ChildrenList4.IsEmpty() then
													
															else
																For SubSubNode = EachIn ChildrenList4
																	
																	If SubSubNode.getName() = "Play" Or SubSubNode.getName() = "Support" then
																			ChildrenList5 = SubSubNode.getChildren()
																			If ChildrenList5 = Null Or ChildrenList5.IsEmpty() then
																	
																			else
																				For SubSubSubNode = EachIn ChildrenList5
																					If SubSubSubNode.getName() = "Primary" then
																						ChildrenList6 = SubSubSubNode.getChildren()
																						If ChildrenList6 = Null Or ChildrenList6.IsEmpty() then
																	
																						else
																							For SubSubSubSubNode = EachIn ChildrenList6
																								Select SubSubSubSubNode.getName()
																									Case "URLTask"
																										ListAddFirst(GEXEs, SubSubSubSubNode.getAttribute("Link"))
																									Case "FileTask"
																										If Regfilter.Find(SubSubSubSubNode.getAttribute("path") ) = Null And Regfilter2.Find(SubSubSubSubNode.getAttribute("path") ) = Null then
																											ListAddFirst(GEXEs, Dir + SubSubSubSubNode.getAttribute("path") )
																										else
																											ListAddFirst(GEXEs, SubSubSubSubNode.getAttribute("path"))
																										EndIf 
																								End Select
																							Next
																						EndIf
																					else
																						ChildrenList6 = SubSubSubNode.getChildren()
																						If ChildrenList6 = Null Or ChildrenList6.IsEmpty() then
																	
																						else
																							For SubSubSubSubNode = EachIn ChildrenList6
																								Select SubSubSubSubNode.getName()
																									Case "URLTask"
																										ListAddLast(GEXEs, SubSubSubSubNode.getAttribute("Link") + "|" + SubSubSubNode.getAttribute("name") )
																									Case "FileTask"
																										If Regfilter.Find(SubSubSubSubNode.getAttribute("path") ) = Null And Regfilter2.Find(SubSubSubSubNode.getAttribute("path") ) = Null then
																											ListAddLast(GEXEs, Dir + SubSubSubSubNode.getAttribute("path") + "|" + SubSubSubNode.getAttribute("name") )
																										else
																											ListAddLast(GEXEs, SubSubSubSubNode.getAttribute("path") + "|" + SubSubSubNode.getAttribute("name") )
																										EndIf
																								End Select
																							Next
																						EndIf
																					EndIf
																				Next
																			EndIf																			
																	EndIf 
																Next
															EndIf
														EndIf
													Next
												EndIf
												
										End Select
									Next
									
									Exit
								EndIf
							Next

							Exit
						Forever						
						
						Desc = GameReadType.GameDescFilter(Desc)
										
					EndIf
					
					Local LEXE:String, LEXE2:String
					
					For LEXE = EachIn GEXEs
						LEXE2 = LEXE					
						For b = 1 To Len(LEXE)
							If Mid(LEXE, b, 1) = "|" then
								LEXE2 = Left(LEXE, b - 1)
								Exit
							EndIf
						Next
						If ListContains(GEXEs2, LEXE) then
						
						else
							If Regfilter.Find(LEXE2) = Null then
								If FileType(LEXE2) = 1 then
									ListAddLast(GEXEs2, LEXE)	
								EndIf
							else
								ListAddLast(GEXEs2, LEXE)
							EndIf
						EndIf
					Next
					
					EXE = ""
					
					For LEXE = EachIn GEXEs2
						EXE = EXE + LEXE + "||"
					Next
					If Right(EXE, 2) = "||" then EXE = Left(EXE, Len(EXE) - 2)
										
					PrintF( "Dir: " + Dir$)
					PrintF( "GDF: " + GDF$)
					PrintF( "Desc: " + Desc$)
					PrintF( "EXE: " + EXE$)
					PrintF( "Dev: " + Devs$)
					PrintF( "Gen: " + Gens$)
					PrintF( "Pub: " + Pubs$)
					PrintF( "Rel: " + Rel$)	
					
					
					rem
					tempEXE = ""
					
					If Left(EXE, Len("desura://") ) = "desura://" then
						If Left(EXE, Len("desura://launch/games") ) = "desura://launch/games" then
							tempEXE = EXE
						EndIf
					else
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
					EndIf
					EndRem
					
					If EXE = "" then
						PrintF("EXE null")
					else
						Log1.AddText("Found: " + Title)
						CreateDir(TEMPFOLDER + "GDF" + FolderSlash + TitleDir)
						PrintF("Writing Data to file")
						DirFile = WriteFile(TEMPFOLDER + "GDF" + FolderSlash + TitleDir + FolderSlash + "Data.txt")
						WriteLine(DirFile , Title ) 'Name
						WriteLine(DirFile , Desc ) 'Description
						WriteLine(DirFile , EXE ) 'EXEs
						WriteLine(DirFile , Rel ) 'Release Date
						WriteLine(DirFile , Devs ) 'Developer
						WriteLine(DirFile , Pubs ) 'Publisher		
						WriteLine(DirFile , Gens ) 'Genres			
						CloseFile(DirFile)				
						PrintF("Done writing data")					
					EndIf
					If Log1.LogClosed = True Then
						ExitGDF = True 
						Exit
					EndIf
				EndIf
			
				GDFFound = False			
				GameRegs = Right(GameRegs, Len(GameRegs) - a)
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
	
	Log1.AddText("Finished")
	?Threaded
	Delay 1000
	?	
	
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
		If Left(temp, Len(Reg) ) = Reg then
			If temp=Reg Then
			
			Else
				RegOutput$=RegOutput+temp+"|"
			EndIf
		EndIf	
		
	Forever
			
	CloseFile(tempRead)
	Return RegOutput
End Function

Function ReturnGDFDatas:String(Reg$, Data$)

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
		
		
		While temp_proc.Status() Or (temp_proc.pipe.ReadAvail() And ReturnValueSet = False)
			If temp_proc.pipe.ReadAvail() And ReturnValueSet = False then
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

