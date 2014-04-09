
ReadSourceCode=ReadFile("PhotonManager.bmx")
Local SourceLine:String

Repeat
	SourceLine = ReadLine(ReadSourceCode)
	
	If Left(SourceLine,1)="'" Then Continue 
	If Instr(SourceLine,"PrintF") Then Continue  
	
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
					If Mid(SourceLine,SourceStart,SourceEnd-SourceStart)="" Or Instr(SourceLine,"/") Or Instr(SourceLine,"\") Then 
					Else
						Print Mid(SourceLine,SourceStart,SourceEnd-SourceStart)
					EndIf
				EndIf
		End Select
	Next 
	
	If Eof(ReadSourceCode) Then Exit 
Forever

CloseFile(ReadSourceCode)

