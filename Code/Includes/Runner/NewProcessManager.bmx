?Win32
Type PE32

	Field bank:TBank
	
'    dwSize.l
'    cntUsage.l
'    th32ProcessID.l
'    th32DefaultHeapID.l
'    th32ModuleID.l
'    cntThreads.l
'    th32ParentProcessID.l
'    pcPriClassBase.l
'    dwFlags.l
'    szExeFile.b [#MAX_PATH]

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

Function ListProcesses()
	Local Process:ProcessType
	
	snap = CreateProcessList ()

	If GetProcesses (snap)
		MainProcessList = New ProcessListingType
		MainProcessList.ProcessListHierarchical = CreateList()
		MainProcessList.ProcessListAll = CreateList()
		For P:PE32 = EachIn PE32List
			pid = PeekInt (P.bank, 8)
			parent = PeekInt (P.bank, 24)
			proc$ = ProcessName$ (P.bank)
			Process = New ProcessType
			Process.Name = proc
			Process.p = P
			Process.Children = CreateList()
			CompareProcs (P, Process.Children)
			ListAddLast(MainProcessList.ProcessListHierarchical, Process)
			ListAddLast(MainProcessList.ProcessListAll, Process)
		Next
	
		FreeProcessList (snap)

	Else
		Notify "Failed to create process list!", True
	EndIf			

End Function

' -----------------------------------------------------------------------------
' Find child processes (ah, the joys of trial and error)...
' -----------------------------------------------------------------------------

Function CompareProcs (p:PE32, ChildrenList:TList )
	Local Process:ProcessType
	
	For q:PE32 = EachIn PE32List
		
		If p <> q
		
			pid		= PeekInt (p.bank, 8)
			qid		= PeekInt (q.bank, 8)
			qparent = PeekInt (q.bank, 24)
		
			If pid = qparent
			
				proc$ = ProcessName (q.bank)
				
				Process = New ProcessType
				Process.Name = proc
				Process.p = q
				Process.Children = CreateList()
								
				CompareProcs (q, Process.Children)
				
				ListAddLast(ChildrenList, Process)
				ListAddLast(MainProcessList.ProcessListAll, Process)				
				ListRemove PE32List, q
				
			EndIf
		
		EndIf
		
	Next
	
End Function

Function PrintProcesses(List:TList , Depth:String )
	For a:ProcessType = EachIn List
		Print(Depth + a.Name)
		PrintProcesses(a.Children, Depth + "-")
	Next
End Function

Type ProcessListingType
	Field ProcessListHierarchical:TList
	Field ProcessListAll:TList
End Type

Type ProcessType
	Field Name:String
	Field p:PE32
	Field Children:TList
	
	Method GetAllChildren:TList()
		Local AllChildren:TList = CreateList()
		Local AllChildrenChildren:TList
		Local Process:ProcessType, Process2:ProcessType
		For Process = EachIn Self.Children
			ListAddLast(AllChildren, Process)
			AllChildrenChildren = Process.GetAllChildren()
			For Process2 = EachIn AllChildrenChildren
				ListAddLast(AllChildren, Process2)
			Next
		Next
		Return AllChildren
	End Method
End Type


?