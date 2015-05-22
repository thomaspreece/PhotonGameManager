Function GetEXEList:TList(Path:String , Name:String)
	Path = StripSlash(Path) + FolderSlash
	Local List:TList , TermList:TList , RankedList:TList
	List = CreateList()
	PrintF("Searching for EXEs")
	List = WriteEXEs(Path , "" , List , 1)
	PrintF("Writing Term List")
	TermList = WriteTermList(Name , StripSlash(StripDir(Path) ) )
	RankedList = RankEXEs(List , TermList)
	Return RankedList
End Function


Function ContainedWithin(Str$, Term$)
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

Function RankEXEs:TList(EXEList:TList , TermList:TList)
	RankedEXEListWC:TList = CreateList()
	RankedEXEList:TList = CreateList()
	
	For EXE:String = EachIn EXEList
		EXEStrip$=StripDir(EXE)
		Count=CountContains2(EXEStrip , TermList)
		Count=Count-MinusCount(EXEStrip)+AddCount(EXEStrip)
		ListAddLast(RankedEXEListWC,String(Count)+">>>"+EXE)
	Next
	
	SortList(RankedEXEListWC , False , SortFunction)
	
	For EXE:String = EachIn RankedEXEListWC
		For a = 1 To Len(EXE)
			If Mid(EXE , a , 3) = ">>>" Then
				ListAddLast(RankedEXEList , Right(EXE , Len(EXE) - a - 2) )
				Exit
			EndIf
		Next
	Next
	PrintF("--Ranked EXES--")
	For EXE:String = EachIn RankedEXEList
		PrintF(EXE)
	Next
	PrintF("--END of Ranked EXES")
	Return RankedEXEList
End Function

Function SortFunction:Int(s1:Object, s2:Object)
	s1int:Int = Int(String(s1))
	s2int:Int = Int(String(s2))
	If s1int < s2int
		Return -1
	ElseIf s1int > s2int
		Return 1
	Else
		Return 0
	EndIf
End Function

Function AddCount(FileName$)
	Count=0
	Count=Count+ContainedWithin(FileName,"Autorun")	
	Count=Count+ContainedWithin(FileName,"launch")
	Count=Count+ContainedWithin(FileName,"Startup")	
	Return Count 
End Function

Function MinusCount(FileName$)
	Count=0
	Count=Count+ContainedWithin(FileName,"Uninst")
	Count=Count+ContainedWithin(FileName,"uninstll")
	Count=Count+ContainedWithin(FileName,"Setup")
	Count=Count+ContainedWithin(FileName,"Uninstall")
	Count=Count+ContainedWithin(FileName,"UNINSTAL")	
	Count=Count+ContainedWithin(FileName,"UNWISE")	
	Count=Count+ContainedWithin(FileName,"config")	
	Count=Count+ContainedWithin(FileName,"unins")		
	Count=Count+ContainedWithin(FileName,"Server")	
	Count=Count+ContainedWithin(FileName,"Editor")	
	Count=Count+ContainedWithin(FileName,"Register")	
	Count=Count+ContainedWithin(FileName,"WorldBuilder")		
	Return Count 
End Function

Function CountContains2(FileName$ , TermList:TList)
	Count=0
	Intials$=""
	ReadSearchTerms = ReadFile("GamePartList.txt")
	For Term:String = EachIn TermList
		Intials=Intials+Left(Term,1)
		Count=Count+ContainedWithin(FileName,Term)
	Next
	Count=Count+ContainedWithin(FileName,Intials)
	Return Count
End Function

Function WriteEXEs:TList(GlobalPath:String, Path:String , EXEList:TList , Level:Int )
	If Level > 3 Then Return EXEList
	Local File:String 
	ReadEXEDir=ReadDir(GlobalPath + Path)
	Repeat
			File = NextFile(ReadEXEDir)
			If File="." Or File=".." Then Continue
			If File = "" Then Exit
				
			If FileType(GlobalPath + Path + File)=1 Then
				?Win32
				If Lower(ExtractExt(File))="exe" Then
					ListAddLast(EXEList , Path + File)
				EndIf
				?Not Win32
				Flags = FileMode(GlobalPath+Path+File) 
				testbit=%000001000
				If Flags = -1 Then 
				
				Else
					If Flags & testbit Then 
						Print "Path: "+GlobalPath+Path+File
						Print "Flag:"+ Flags
						Print "Per: "+Permissions(Flags)
						Print "----------------------------------------------"
						ListAddLast(EXEList , Path + File)
					EndIf 
				EndIf 
				?
			ElseIf FileType(GlobalPath + Path + File) = 2 Then
				EXEList = WriteEXEs(GlobalPath , Path + File + FolderSlash , EXEList , Level+1)
			EndIf
	Forever
	CloseDir(ReadEXEDir)
	Return EXEList
End Function

Function Permissions$(mode)
	Local	testbit,pos
	Local	p$="rwxrwxrwx"
	testbit=%100000000
	pos=1
	While (testbit)
		If mode & testbit res$:+Mid$(p$,pos,1) Else res$:+"-"
		testbit=testbit Shr 1
		pos:+1	
	Wend
	Return res
End Function

Function WriteTermList:TList(Name$,Dir$)
	ReturnList:TList = CreateList()
	Start=1
	For a=1 To Len(Name)
		If Mid(Name , a , 1) = " " Then
			ListAddLast(ReturnList,Mid(Name,Start,a-Start))
			Start=a+1
		EndIf
	Next
	ListAddLast(ReturnList,Mid(Name,Start,a-Start))
	
	Start=1
	For a=1 To Len(Dir)
		If Mid(Dir,a,1)=" "  Then 
			ListAddLast(ReturnList,Mid(Dir,Start,a-Start))
			Start=a+1
		EndIf
	Next	
	If Mid(Dir , Start , a - Start) = "" Or Mid(Dir , Start , a - Start) = " " Then
	
	Else
		ListAddLast(ReturnList , Mid(Dir , Start , a - Start) )
	EndIf
	
	Return ReturnList
End Function

