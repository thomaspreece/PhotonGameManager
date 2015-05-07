
If FileType("PhotonUpdater2.exe")=1 Then
	If FileType("PhotonUpdater.exe")=1 Then 
		If DeleteFile("PhotonUpdater.exe") Then 
			If CopyFile("PhotonUpdater2.exe","PhotonUpdater.exe") Then
				If FileType("PhotonUpdater.exe")=1 Then 
					DeleteFile("PhotonUpdater2.exe")
				EndIf 
			EndIf 
		EndIf 
	Else
		If CopyFile("PhotonUpdater2.exe","PhotonUpdater.exe") Then
			If FileType("PhotonUpdater.exe")=1 Then 
				DeleteFile("PhotonUpdater2.exe")
			EndIf 
		EndIf 	
	EndIf 
EndIf

Notify "PhotonUpdater Updated, running PhotonUpdater please update to the latest version"

WinExec(Chr(34)+"PhotonUpdater.exe"+Chr(34),1)


?Win32
Extern "win32"
	'Function WinExec(lpCmdLine$z , nCmdShow)
	Function GetEnvironmentVariable(lpName$z, lpBuffer:Byte Ptr, nSize) = "GetEnvironmentVariableA@12"
End Extern
?
'Import "-lole32"
'CoInitialize(0) 'Just in case COM is needed by the other App?

Const SEE_MASK_NOCLOSEPROCESS = $00000040
Const INFINITE = $FFFFFFFF



?Win32
Extern"Win32"
	Function CoInitialize(pvReserved)
	Function GetLastError()
	Function ShellExecuteEx(pExecInfo:Byte Ptr)
	Function WaitForSingleObject(hHandle,dwMilliseconds)
	Function CloseHandle(hHandle)
EndExtern


Type SHELLEXECUTEINFO
	Field cbSize
	Field fMask
	Field hwnd
	Field lpVerb:Byte Ptr
	Field lpFile:Byte Ptr
	Field lpParameters:Byte Ptr
	Field lpDirectory:Byte Ptr
	Field nShow
	Field hInstApp
	Field lpIDList:Byte Ptr
	Field lpClass:Byte Ptr
	Field hkeyClass:Byte Ptr
	Field dwHotKey
	Field hIcon
	Field hProcess
EndType

Function WinExec(lpCmdLine$ , nCmdShow , nWait = False )
	'If lpCmdLine = "" Or lpCmdLine = Null Or lpCmdLine = " " Then Return 
	
	Local ShExecInfo:SHELLEXECUTEINFO = New SHELLEXECUTEINFO
	ShExecInfo.cbSize = SizeOf(SHELLEXECUTEINFO)
	ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS
	ShExecInfo.hWnd = 0
	ShExecInfo.lpVerb = "open".ToCString() 'Can change this to 'runas' to prevent UAC
	
	
	ShExecInfo.nShow = 1'SW_SHOW
	ShExecInfo.hInstApp = 0
	
	Local App:String
	Local Param:String 
	Local Dir:String 
	
	If Left(lpCmdLine,1)=Chr(34) Then 
		For a=2 To Len(lpCmdLine)
			If Mid(lpCmdLine,a,1)=Chr(34) Then
				App = Left(lpCmdLine,a-1)
				App = Right(App,Len(App)-1)
				If Mid(App,2,1)=":" Then 
					Dir = Null
				Else
					Dir = CurrentDir()
				EndIf 
				Param = Right(lpCmdLine,Len(lpCmdLine)-a)
				Exit 
			EndIf 		
		Next 
	Else
		For a=1 To Len(lpCmdLine)
			If Mid(lpCmdLine,a,1)=" " Then
				App = Left(lpCmdLine,a-1)
				Param = Right(lpCmdLine,Len(lpCmdLine)-a)
				If Mid(App,2,1)=":" Then 
					Dir = Null
				Else
					Dir = CurrentDir()
				EndIf 				
				Exit 
			EndIf 
		Next 
		If a=Len(lpCmdLine) Then 
			App = lpCmdLine
			Param = ""
		EndIf 
	EndIf 
		
	If FileType(App) <> 1 Then Return 
		
	ShExecInfo.lpDirectory = Null
	ShExecInfo.lpParameters = Param.ToCString()
	ShExecInfo.lpFile = App.ToCString() 'Insert filename here
	
	 
	If ShellExecuteEx(ShExecInfo)'Start the exe
		If nWait = True Then
			WaitForSingleObject(ShExecInfo.hProcess,INFINITE) 'Wait for it to finish - no interaction, just make sure it quits before we continue
		EndIf 
		CloseHandle(ShExecInfo.hProcess) 'Close it
	EndIf
End Function 