
?Win32

Type PE32

	Field bank:TBank

End Type



' -----------------------------------------------------------------------------

' -----------------------------------------------------------------------------
' Create a new 'process' list entry...
' -----------------------------------------------------------------------------

Function CreatePE32:PE32 ()
	p:PE32 = New PE32
	ListAddLast PE32List, p
	p.bank = CreateBank (SizeOf_PE32)
	If p.bank
		PokeInt p.bank, 0, SizeOf_PE32
	Else
		ListRemove PE32List, p
		Return Null
	EndIf
	Return p
End Function

' -----------------------------------------------------------------------------
' Free process list entry...
' -----------------------------------------------------------------------------

Function FreePE32 (p:PE32)
	If p.bank
		ListRemove PE32List, p
	EndIf
End Function

' -----------------------------------------------------------------------------
' Redundant info...
' -----------------------------------------------------------------------------

Function PrintProc (bank)
	Print ""
	Print "Name    : " + ProcessName$ (bank)
	Print "Usage   : " + PeekInt (bank, 4)
	Print "Proc ID : " + PeekInt (bank, 8)
	Print "Heap ID : " + PeekInt (bank, 12)
	Print "Mod  ID : " + PeekInt (bank, 16)
	Print "Threads : " + PeekInt (bank, 20)
	Print "Parent  : " + PeekInt (bank, 24)
	Print "ClasBas : " + PeekInt (bank, 28)
	Print "Flags   : " + PeekInt (bank, 32)
End Function

' -----------------------------------------------------------------------------
' Eeuurrggghhhh... leech process name from bank...
' -----------------------------------------------------------------------------

Function ProcessName$ (bank:TBank)
	For s = 36 To BankSize (bank) - 1
		_byte = PeekByte (bank, s)
		If _byte
			result$ = result$ + Chr (_byte)
		Else
			Exit
		EndIf
	Next
	Return result$
End Function

Global PROC_COUNT

' -----------------------------------------------------------------------------
' Constants required by process functions, etc...
' -----------------------------------------------------------------------------



' -----------------------------------------------------------------------------
' Take snapshot of running processes...
' -----------------------------------------------------------------------------

Function CreateProcessList ()
	PROC_COUNT = 0
	Return CreateToolhelp32Snapshot (TH32CS_SNAPPROCESS, 0)
End Function

' -----------------------------------------------------------------------------
' Free list of processes (created via CreateProcessList and GetProcesses)...
' -----------------------------------------------------------------------------

Function FreeProcessList (snap)
	For p:PE32 = EachIn PE32List
		FreePE32 (p)
	Next
	CloseHandle (snap)
	PROC_COUNT = 0
End Function

Function GetProcesses (snap)

	PROC_COUNT = 0
	
	' Check snapshot is valid...
	
	If snap <> INVALID_HANDLE_VALUE

		' Hack up a PE32 (PROCESSENTRY32) structure...
		
		p:PE32 = CreatePE32 ()

		' Find the first process, stick info into PE32 bank...
		
		If Process32First (snap, BankBuf (p.bank))
	
			' Increase global process counter...
			
			PROC_COUNT = PROC_COUNT + 1
			
			Repeat
		
				' Create a new PE32 structure for every following process...
				
				p:PE32 = CreatePE32 ()
			
				' Find the next process, stick into PE32 bank...
				
				nextproc = Process32Next (snap, BankBuf (p.bank))
		
				' Got one? Increase process count. If not, free the last PE32 structure...
				
				If nextproc	
					PROC_COUNT = PROC_COUNT + 1
				Else
					FreePE32 (p)
				EndIf
				
			' OK, no more processes...
			
			Until nextproc = 0
			
		Else
		
			' No first process found, so delete the PE32 structure it used...
			
			FreePE32 (p)
			Return False
			
		EndIf
				
		Return True
	
	Else
	
		Return False
		
	EndIf
	
End Function

' -----------------------------------------------------------------------------
' Fill treeview gadget...
' -----------------------------------------------------------------------------

Function ListProcesses:TList ()
	Local ProcessList:TList = CreateList()
	snap = CreateProcessList ()

	If GetProcesses (snap)
	
		For p:PE32 = EachIn PE32List
			pid = PeekInt (p.bank, 8)
			parent = PeekInt (p.bank, 24)
			proc$ = ProcessName$ (p.bank)
			'Print proc
			ListAddLast(ProcessList,proc)
			'CompareProcs (p , 0 , ProcessList)
		Next
	
		FreeProcessList (snap)

	Else
		Notify "Failed to create process list!", True
	EndIf			
	Return ProcessList
End Function

Function ListChildProcesses:TList(Child:String)
	Local ProcessList:TList = CreateList()
	snap = CreateProcessList ()

	If GetProcesses (snap)
	
		For p:PE32 = EachIn PE32List
			'pid = PeekInt (p.bank, 8)
			'parent = PeekInt (p.bank, 24)
			proc$ = ProcessName$ (p.bank)
			
			If proc=Child Then
				ProcessList = CompareProcs (p , ProcessList)
				Return ProcessList
			EndIf
		Next
	
		FreeProcessList (snap)

	Else
		Notify "Failed to create process list!", True
	EndIf			
	Return ProcessList
End Function

' -----------------------------------------------------------------------------
' Find child processes (ah, the joys of trial and error)...
' -----------------------------------------------------------------------------

Function CompareProcs:TList (p:PE32 , ProcessList:TList)
	
	For q:PE32 = EachIn PE32List
		
		If p <> q
		
			pid		= PeekInt (p.bank, 8)
			qid		= PeekInt (q.bank, 8)
			qparent = PeekInt (q.bank, 24)
		
			If pid = qparent
			
				proc$ = ProcessName (q.bank)
				
				ListAddLast(ProcessList , proc)
				
			EndIf
		
		EndIf
		
	Next
	
	Return ProcessList
End Function

Rem
S = MilliSecs()
ListProcesses()
E = MilliSecs()
ListChildProcesses("explorer.exe")
EndRem


Rem
Extern "win32"
	Function CreateToolhelp32Snapshot:Int(flags:Int, th32processid:Int) 
	Function Process32First:Int(snapshot:Int, entry:Byte Ptr)
	Function Process32Next:Int(snapshot:Int, entry:Byte Ptr)
	Function CloseHandle:Int(_Object:Int) 
EndExtern
EndRem

'Const TH32CS_SNAPPROCESS:Int = $2
'Const INVALID_HANDLE_VALUE:Int = -1

Type TWinProc 

	Global _list:TList = New TList

	Field dwSize:Int = 296
	Field cntUsage:Int
	Field th32ProcessID:Int
	Field th32DefaultHeapID:Int
	Field th32ModuleID:Int
	Field cntThreads:Int
	Field th32ParentProcessID:Int
	Field pcProClassBase:Int
	Field dwFlags:Int
	Field szExeFile:String

	Field kids:TList = New TList
	Field KidsNames:TList = New TList 

	Method New()
		_list.AddLast Self
	EndMethod

	Method Free()
		_list.Remove Self
	EndMethod

	Method ToString:String()

		Local ret:String 
		ret =  "Name    : " + szExeFile
		ret :+ "Usage   : " + cntUsage
		ret :+ "Proc ID : " + th32ProcessID
		ret :+ "Heap ID : " + th32DefaultHeapID
		ret :+ "Mod  ID : " + th32ModuleID
		ret :+ "Threads : " + cntThreads
		ret :+ "Parent  : " + th32ParentProcessID
		ret :+ "ClasBas : " + pcProClassBase
		ret :+ "Flags   : " + dwFlags
	
	EndMethod

	Function CreateFromBank:TWinProc( bank:TBank )
		
		Local p:TWinProc = New TWinProc
		p.dwSize 				= PeekInt(bank,0)
		p.cntUsage 				= PeekInt(bank,4)
		p.th32ProcessID 		= PeekInt(bank,8)
		p.th32DefaultHeapID 	= PeekInt(bank,12)
		p.th32ModuleID 			= PeekInt(bank,16)
		p.cntThreads 			= PeekInt(bank,20)
		p.th32ParentProcessID	= PeekInt(bank,24)
		p.pcProClassBase 		= PeekInt(bank,28)
		p.dwFlags 				= PeekInt(bank,32)
		
		Local offset:Int = 36
		While offset<p.dwSize-1
			If PeekByte(bank,offset)
				p.szExeFile :+ Chr(PeekByte(bank,offset))
			Else
				Exit
			EndIf
			offset :+ 1
		Wend
		
		Return p
	
	EndFunction

	Function GetProcesses:Int()
	
		_list.Clear()

		Local snap:Int = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)

		Local bank:TBank = CreateBank( 296 )
		PokeInt bank,0,296

		If snap <> INVALID_HANDLE_VALUE

			If Process32First(snap, BankBuf(bank))
				
				Local nextproc:Int 
			
				Repeat
			
					TWinProc.CreateFromBank( bank )
					nextproc = Process32Next (snap, BankBuf(bank))
							
				Until nextproc = 0
				
			EndIf
			
			'
			' Arrange so kids are attached etc
			For Local p:TWinProc = EachIn TWinProc._list
				ArrangeProcess(p)
			Next
			
			CloseHandle(snap)
				
			Return True		
		Else
			Return False
		EndIf
		
	End Function

	Function ArrangeProcess( p:TWinProc )
		For Local q:TWinProc = EachIn _list
			If p <> q
				If p.th32ProcessID = q.th32ParentProcessID
					p.kids.AddLast q
					p.kidsNames.AddLast q.szExeFile
					_list.Remove q
					ArrangeProcess(q)
				EndIf
			EndIf
		Next
	EndFunction
	
	Function Find:TWinProc( name:String, list:TList = Null )
		
		If list = Null
			list = _list
		EndIf
		
		For Local p:TWinProc = EachIn list
			If p.szExeFile = name
				Return p
			EndIf
			
			Local ret:TWinProc = Find( name, p.kids )
			If ret
				Return ret
			EndIf
		Next
		
	EndFunction

	'
	' Count the number of times a process is running
	'
	Function Count:Int( name:String, list:TList = Null )
		
		Local cnt:Int
		
		If list = Null
			list = _list
		EndIf
		
		For Local p:TWinProc = EachIn list
			If p.szExeFile = name
				cnt :+ 1
			EndIf
			
			cnt :+ Count( name, p.kids )
		Next

		Return cnt
		
	EndFunction
	
End Type

?
