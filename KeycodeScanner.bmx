Local FileToRead:String
Local SourceLine:String

SourceCodeList:TList = CreateList()
ListAddLast(SourceCodeList,"PhotonFrontEnd.bmx")

Repeat
	If ListIsEmpty(SourceCodeList) Then Exit 
	FileToRead = String(SourceCodeList.RemoveFirst())
	ReadSourceCode=ReadFile(FileToRead)
	Print "Scanning: "+FileToRead
	
	
	Repeat
		SourceLine = ReadLine(ReadSourceCode)
		
		If Left(SourceLine,1)="'" Then Continue 
		If Instr(SourceLine,"PrintF") Then Continue  
		If Instr(SourceLine,"Include") Then 
			LineMode=1
			For a=1 To Len(SourceLine)
				Select LineMode
					Case 1
						If Mid(SourceLine,a,1)=Chr(34) Then 
							SourceStart=a+1
							LineMode=2
						EndIf 
					Case 2
						If Mid(SourceLine,a,1)=Chr(34) Then 
							SourceEnd=a
							LineMode=1
							ListAddLast(SourceCodeList,Mid(SourceLine,SourceStart,SourceEnd-SourceStart))
							Print "Adding: "+Mid(SourceLine,SourceStart,SourceEnd-SourceStart)
						EndIf
				End Select
			Next 
		ElseIf Instr(SourceLine,"KeyHit") Or Instr(SourceLine,"KeyDown") 
			LineMode=1
			For a=1 To Len(SourceLine)
				Select LineMode
					Case 1
						If Mid(SourceLine,a,1)="(" Then 
							SourceStart=a+1
							LineMode=2
						EndIf 
					Case 2
						If Mid(SourceLine,a,1)=")" Then 
							SourceEnd=a
							LineMode=1
							Print Mid(SourceLine,SourceStart,SourceEnd-SourceStart)+"  "+Mid(SourceLine,SourceStart-1,SourceEnd-SourceStart+2)
						EndIf
				End Select
			Next 
		EndIf
		
		
		If Eof(ReadSourceCode) Then Exit 
	Forever
	
	CloseFile(ReadSourceCode)

Forever
