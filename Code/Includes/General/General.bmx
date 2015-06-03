Include "PlatformReader.bmx"
Include "SanitiseFunctions.bmx"
Include "StartupChecks.bmx"
Include "DBUpdates.bmx"

Function ExtractSubVersion(Text:String , Part:Int)
	Local SubVersions:Int[] = [0,0,0,0]
	Local b:Int = 0
	Local c:Int = 0
	
	Repeat
		c = 0
		For a = 1 To Len(Text)
			If Mid(Text,a,1)=Chr(10) Then
				SubVersions[b] = Int(Left(Text, a - 1) )
				b = b + 1
				Text = Right(Text, Len(Text) - a)
				c = 1
				Exit 
			EndIf 
		Next	
		If c = 0 Then
			SubVersions[b] = Int(Text)
			Exit 	
		EndIf
		If b = 4 Then Exit 
	Forever
	
	Select Part
		Case 1
			Return SubVersions[0]
		Case 2
			Return SubVersions[1]
		Case 3
			Return SubVersions[2]
		Case 4
			Return SubVersions[3]
		Default
			Return -1
	End Select 

End Function



?Win32
Extern "win32"
	
	'Function EnumWindows(lpEnumFunc:Byte Ptr ,lParam )
	'Function WinExec(lpCmdLine$z , nCmdShow)
	Function GetEnvironmentVariable(lpName$z, lpBuffer:Byte Ptr, nSize) = "GetEnvironmentVariableA@12"

	'Used to bring Windows to the front
	Function SetForegroundWindow(hWnd:Int)
	Function SetActiveWindow(hWnd:Int)
	Function BringWindowToTop(hWnd:Int)

	'Used to hook into currently active thread
	Function GetCurrentThreadId()
	Function GetWindowThreadProcessId(hwnd:Int,lpdwProcessId:Byte Ptr)
	Function GetForegroundWindow()
	Function AttachThreadInput(Thread1:Int,Thread2:Int,Attached:Int)
	Function AllowSetForegroundWindow(dwProcessId:Int)
	
	'Used in ShellExecute
	Function CoInitialize(pvReserved)
	Function GetLastError()
	Function ShellExecuteEx(pExecInfo:Byte Ptr)
	Function WaitForSingleObject(hHandle,dwMilliseconds)
	Function CloseHandle(hHandle) 'Also used in ProcessManager, PhotonManager
	
	'Used in TExecuter
	Function Win32CreateProcess (  lpApplicationName$z, lpCommandLine$z, ..
                           lpProcessAttributes, lpThreadAttributes, ..
						   bInheritHandles, dwCreationFlags, lpEnvironment, ..
						   lpCurrentDirectory$z, lpStartupInfo:Byte Ptr, ..
						   lpProcessInformation:Byte Ptr ) "WIN32" = "CreateProcessA@40"
		
End Extern


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

Function ShellExec(lpCmdLine$ , nCmdShow , nWait = False )
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

Type StartUpInfo
	Field cb:Int
	Field lpReserved:Byte Ptr, lpDesktop:Byte Ptr, lpTitle:Byte Ptr 'Pointer
	Field dwX:Int, dwY:Int, dwXSize:Int, dwYSize:Int
	Field dwXCountChars:Int, dwYCountChars:Int
	Field dwFillAttribute:Int, dwFlags:Int
	Field wShowWindow:Short, cbReserved2:Short
	Field lpReserved2:Byte Ptr 'PBYTE
	Field hStdInput:Byte Ptr, hStdOutput:Byte Ptr, hStdError:Byte Ptr
End Type

Type ProcessInformation
	Field hProcess:Int, hThread:Int
	Field dwProcessId:Byte Ptr, dwThreadId:Byte Ptr
End Type

Type TExecuter 

	Field FName:String
	Field Parameters:String

	Field res:Int, nhandles:Int
	Field handles:Int[2]
	Field StartInf:StartUpInfo
	Field ProInf:ProcessInformation
	Field lasterror:Int
	
	Method New ()
		StartInf:StartUpInfo	= New StartUpInfo
		StartInf.cb				= SizeOf(StartUpInfo)
   		ProInf					= New ProcessInformation
	End Method
	
	Method Delete ()
		StartInf 	= Null
		ProInf 		= Null
	End Method
	

	Method Execute (Proc:String,CommandLine:String)
		Local res:Int
		Local appname:String
		res = Win32CreateProcess (Proc, CommandLine, Null,Null,False,Null,Null,Null,StartInf, ProInf)
		
		lasterror = GetLastError()
		Return(lasterror)
	End Method
	
End Type

Function GetEnv$(envVar$)
		Local buff@[64]
		
		Local rtn = GetEnvironmentVariable(envVar$, buff@, buff.length)
		If rtn > buff.length
			buff@ = buff@[..rtn]
			rtn = GetEnvironmentVariable(envVar$, buff@, buff.length)
		EndIf
		
		Return String.FromBytes(buff@, rtn)
End Function

?Not Win32
Function ShellExec(lpCmdLine$ , nCmdShow , nWait = False )
	CustomRuntimeError("WinExec should not be run on this platform")
End Function 
?

Function PhotonSuiteRunProcess:Int(Command:String, Program:String)
	Local cmdOpts:String
	If Left(Command,Len(Program))=Program Then 
		PrintF(Program)
		cmdOpts = Right(Command, Len(Command) - Len(Program) )
		PrintF("cmdOpts: "+cmdOpts)
		ShellExec(Chr(34)+Program+Chr(34)+cmdOpts,1)
		Return 1
	Else
		Return 0		
	EndIf 
End Function 

Function RunProcess:TProcess(Command:String,Detach:Int = 0)
	Local ReturnedValue = 0
	Local ID = -1
	Local Command1:String
	Local Command2:String
	
	?MacOS
	'Fixed Bug: Mac cannot take command line arguments starting with - when using Blitz programs, eg -Mode so adjusted to remove -.
	If Left(Command,Len(FRONTENDPROGRAM))=FRONTENDPROGRAM Or Left(Command,Len(MANAGERPROGRAM))=MANAGERPROGRAM Or Left(Command,Len(EXPLORERPROGRAM))=EXPLORERPROGRAM Or Left(Command,Len(DOWNLOADERPROGRAM))=DOWNLOADERPROGRAM Or Left(Command,Len(UPDATEPROGRAM))=UPDATEPROGRAM Then
		Command = Replace(Command, " -", " ")
	EndIf 
	?

	'BUG: My Programs Crash and others Using CreateProcess on Windows, No Idea Why...
	?Win32
	If Detach = 1 Then 
		ReturnedValue = ReturnedValue + PhotonSuiteRunProcess(Command, FRONTENDPROGRAM)
		ReturnedValue = ReturnedValue + PhotonSuiteRunProcess(Command, MANAGERPROGRAM)
		ReturnedValue = ReturnedValue + PhotonSuiteRunProcess(Command, EXPLORERPROGRAM)
		ReturnedValue = ReturnedValue + PhotonSuiteRunProcess(Command, DOWNLOADERPROGRAM)
		ReturnedValue = ReturnedValue + PhotonSuiteRunProcess(Command, UPDATEPROGRAM)
		If ReturnedValue = 0 Then 
			Local Ex:TExecuter = New TExecuter
			If Left(Command,1)=Chr(34) Then
				For a=2 To Len(Command)
					If Mid(Command,a,1)=Chr(34) Then 
						Command1=Mid(Command,2,a-2)
						Command2=Right(Command,Len(Command)-a)
						Exit
					EndIf 
				Next
			Else
			
			EndIf 			
			If Command2="" Or Command2=" " Then Command2=Null 
			PrintF("Command1: "+Command1+" Command2: "+Command2)
			Ex.Execute(Command1, Command2)
			'ShellExec(Chr(34)+Command1+Chr(34),1)
			ReturnedValue = 1
		EndIf
	EndIf 
	?
	
	If ReturnedValue = 0 Then 
		If Detach = 1 Then 
			PrintF("Running: "+Command+" (Detached)")
		Else
			PrintF("Running: "+Command+" (Attached)")
		EndIf 
		Local Process:TProcess = CreateProcess(Command)
		If Process=Null Then
			PrintF("Invalid Command: "+Command)
		Else			
			If Detach = 1 Then ProcessDetach(Process)
		EndIf 
		Return Process
	Else
		PrintF("WinExec/TExecuter Used")
	EndIf 
End Function

Function IsntNull(a:String)
	If a = "" Or a = " " Or a = Null Then
		Return False
	Else
		Return True
	EndIf
End Function

Function StripCmdOpt:String(Path:String)
	Local temp1:String
	For a = 1 To Len(Path)
		temp1 = Mid(Path , a , 5)
		If Left(temp1 , 1) = "." And Right(temp1 , 1) = " " Then
			Return Left(Path , a+3)
		EndIf
	Next
	Return Path
End Function



Function GetEmulator:String(Plat:String)
	Local Line:String
	If FileType(SETTINGSFOLDER + "Platforms.txt") = 1 Then
		ReadPlatform = ReadFile(SETTINGSFOLDER + "Platforms.txt")
		Repeat
			Line = ReadLine(ReadPlatform)
			If Left(Line , Len(Plat) ) = Plat Then
				For a = 1 To Len(Line)
					If Mid(Line , a , 1) = ">" Then
						Return Right(Line, Len(Line) - a)
					EndIf
				Next
			EndIf
			If Eof(ReadPlatform) Then Exit
		Forever
		CloseFile(ReadPlatform)
	Else
		Return ""
	EndIf
End Function 

Function SetupPlatforms()
	GlobalPlatforms = New PlatformReader
	If FileType(SETTINGSFOLDER + "Platforms.xml") = 1 then
		GlobalPlatforms.ReadInPlatforms()	
	Else
		GlobalPlatforms.PopulateDefaultPlatforms()
		GlobalPlatforms.ReadInPlatforms()
	EndIf
End Function

Function OldPlatformListChecks()
	If GlobalPlatforms = Null then
		CustomRuntimeError("OldPlatformListChecks: GlobalPlatforms Null")
	EndIf
	PrintF("Checking for Old Platform Lists")
	Local Line:String, EmuPath:String
	Local ReadPlatform:TStream
	Local MovePlat = False
	Local a:Int, b:Int	
	Local Platform:PlatformType
	
	If FileType("Platforms.txt") = 1 then
		MovePlat = True
		PrintF("Upgrading Original Platforms.txt")
	EndIf
	If FileType(SETTINGSFOLDER + "Platforms.txt") = 1 And MovePlat = True then
		MovePlat = False
		DeleteFile("Platforms.txt")
		PrintF("New Platforms.txt Found, deleting old Platforms.txt")
	EndIf
	If MovePlat = True then
		CopyFile("Platforms.txt",SETTINGSFOLDER + "Platforms.txt")
		DeleteFile("Platforms.txt")
	EndIf
	

	If FileType(SETTINGSFOLDER + "Platforms.txt") = 1 then
		ReadPlatform = ReadFile(SETTINGSFOLDER + "Platforms.txt")
		b = 1
		Repeat
			'PC is 24 and not used in Platforms.txt so skip
			If b = 24 then b = 25
			Line = ReadLine(ReadPlatform)
			EmuPath = ""
			For a = 1 To Len(Line)
				If Mid(Line, a, 1) = ">" then
					EmuPath = Right(Line, Len(Line) - a)
					Exit
				EndIf
			Next
			If EmuPath = "" Or EmuPath = " " then
				'Do nothing
			Else
				Platform = GlobalPlatforms.GetPlatformByID(b)
				If Platform.Emulator = "" Or Platform.Emulator = Null Or Platform.Emulator = " " then
					Platform.Emulator = EmuPath
				EndIf
			EndIf
			
			
			If Eof(ReadPlatform) then
				Exit
			EndIf
			b = b + 1
		Forever
		GlobalPlatforms.SavePlatforms()
		CloseFile(ReadPlatform)
		DeleteFile(SETTINGSFOLDER + "Platforms.txt")
	EndIf

End Function


Function DeleteCreateFolder(Folder:String)
	Folder = StripSlash(Folder)
	PrintF("DeleteCreateFolder: "+Folder)
	For a=1 To 20
		If FileType(Folder)=2 Then
			DeleteDir(Folder , 1)
			Delay 100
		Else
			Exit
		EndIf
	Next
	PrintF("DeleteDir Loop "+a)
	If FileType(Folder) = 2 Then
		CustomRuntimeError("Error 7: Cannot Delete Folder "+Folder) 'MARK: Error 7
	EndIf
	For a = 1 To 20
		If FileType(Folder)=0 Then
			CreateDir(Folder)
			Delay 100
		Else
			Exit
		EndIf
	Next	
	PrintF("CreateDir Loop "+a)
	If FileType(Folder) = 0 Then
		CustomRuntimeError("Error 11: Cannot Create Folder "+Folder) 'MARK: Error 11
	EndIf
End Function

Function CreateFolder(Folder:String)
	For a = 1 To 20
		If FileType(Folder)=0 Then
			CreateDir(Folder)
			Delay 100
		Else
			Exit
		EndIf
	Next	
	PrintF("CreateDir Loop " + a)
	If FileType(Folder) = 0 Then
		CustomRuntimeError("Error 11: Cannot Create Folder "+Folder) 'MARK: Error 11
	EndIf
End Function

Type GameReadType {expose}
	Field OrginalName:String
	Field Name:String
	Field Desc:String
	'Field Dir:String ,
	Field ROM:String
	'Field EXE:String ,
	Field ExtraCMD:String
	
	Field RunEXE:String
	Field OEXEs:TList
	Field OEXEsName:TList
	
	Field ReleaseDate:String
	Field Cert:String
	Field Dev:String
	Field Pub:String
	Field Trailer:String
	'Field TrailerURL:String
	
	'Field Genre:String
	Field Genres:TList
	
	Field LuaFile:String
	Field LuaIDData:String
	
	
	Field ID:Int
	Field Rating:String
	Field Plat:String
	Field PlatformNum:Int 
	Field EmuOverride:String
	Field Coop:String
	Field Players:String
	
	Field Completed:Int
	
	Field Fanart:TList
	Field FanartThumbs:TList
	Field ScreenShots:TList
	Field ScreenShotThumbs:TList	
	
	Field FrontBoxArt:TList
	Field BackBoxArt:TList
	Field BannerArt:TList
	Field IconArt:TList
	
	Field Mounter:String
	Field VDriveNum:String
	Field UnMount:String
	Field DiscImage:String
	
	Field PreBF:String
	Field PreBFWait:Int 
	Field PostBF:String
	Field PostBFWait:Int 
		
	Field GameRunnerAlwaysOn:Int 
	Field StartWaitEnabled:Int 
	Field WatchEXEs:TList
	
	Field OverideArtwork:Int = 0
	
	'Field ScreenShotNumber:Int '1 if there is screenshots/0 otherwise
	Field ScreenShotsAvailable:Int
	

	Function GameNameFilter:String(Text:String)
		'Strips out all characters that cannot be displayed in GameManager suite programs	
		Local Regfilter:TRegEx = New TRegEx.Create("&amp;")
		Local Regfilter2:TRegEx = New TRegEx.Create("[^0-9a-zA-Z\-!\^%&*()+={}\[\];:'@#<>,./?\\|` _"+Chr(34)+"]")
		
		Text = Regfilter.ReplaceAll(Text, "&")
		Text = Regfilter2.ReplaceAll(Text, "")
		
		Return Text
		
	End Function

	Method GetEXEPart:String(Part:Int)
		If Left(Self.RunEXE, 1) = Chr(34) then
			For a = 2 To Len(Self.RunEXE)
				If Mid(Self.RunEXE , a , 1) = Chr(34) then
					If Part = 1 then
						'EXE
						Return Left(Self.RunEXE , a)
					Else
						'Commandline
						Return Right(Self.RunEXE , Len(Self.RunEXE) - (a + 1) )
					EndIf
				EndIf
			Next				
		Else
			For a = 1 To Len(Self.RunEXE)
				If Mid(Self.RunEXE , a , 1) = " " then
					If Part = 1 then
						'EXE
						Return Left(Self.RunEXE , a - 1)
					Else
						'Commandline
						Return Right(Self.RunEXE , Len(Self.RunEXE) - a )
					EndIf
				EndIf
			Next							
		EndIf 
	
	End Method

	Function GameDescFilter:String(Text:String)
		'Strips out all characters that cannot be displayed in GameManager suite programs	
		Local Regfilter:TRegEx = New TRegEx.Create("&amp;")
		Local Regfilter2:TRegEx = New TRegEx.Create("[^0-9a-zA-Z\-!\^%&*()+={}\[\];:'@#<>,./?\\|` _"+Chr(34)+"]")
		
		Text = Regfilter.ReplaceAll(Text, "&")
		Text = Regfilter2.ReplaceAll(Text, "")
		
		Return Text
	End Function


	Function GameNameDirFilter:String(Text:String)
		'Strips out all characters not allowed in filesystems
		
		Local Regfilter:TRegEx = New TRegEx.Create("&(amp;|)")
		Local Regfilter2:TRegEx = New TRegEx.Create("[^0-9a-zA-Z\- _]")
		Local Regfilter3:TRegEx = New TRegEx.Create(" ")

		Text = Regfilter.ReplaceAll(Text, "and")
		Text = Regfilter2.ReplaceAll(Text, "")
		Text = Regfilter3.ReplaceAll(Text, "_")

		Return Text
	End Function	
	
	Method NewGame()
		IntialiseFanartLists()
		Self.Genres = CreateList()	
		Self.OEXEs = CreateList()
		Self.OEXEsName = CreateList()
		Self.WatchEXEs = CreateList()
		Self.GameRunnerAlwaysOn = False 
		Self.StartWaitEnabled = False 
	End Method
	
	Method IntialiseFanartLists()
		Self.Fanart = CreateList()
		Self.FanartThumbs = CreateList()
		Self.ScreenShots = CreateList()
		Self.ScreenShotThumbs = CreateList()
		Self.FrontBoxArt = CreateList()
		Self.BackBoxArt = CreateList()
		Self.BannerArt = CreateList()
		Self.IconArt = CreateList() 			
	End Method
	
	Method DeleteGame()
		Local GName:String = Lower(Self.GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum)
		DeleteDir(GAMEDATAFOLDER + GName , 1)
		
	End Method
	
	Method AddToList(list:TList,item:String)
		If list = Null Then list=CreateList()
		ListAddLast(list,item)
	End Method	
	
	Method GetGame(GName:String)
		Self.NewGame()
		Self.PlatformNum = 0
		GName = Self.GameNameDirFilter(GName)
		Self.OrginalName = GName
		
		If FileType(GAMEDATAFOLDER + GName + FolderSlash + "Info.xml") = 1 then
		Else
			Return -1
		EndIf		
		PrintF("Starting GetGame: "+GName)
		Local Gamedoc:TxmlDoc
		Local RootNode:TxmlNode , EXENode:TxmlNode , GenreNode:TxmlNode , node:TxmlNode , node2:TxmlNode
		Local OEXE:String
		
		Gamedoc = TxmlDoc.parseFile(GAMEDATAFOLDER + GName + FolderSlash+"Info.xml")
		PrintF("Parsed File")
		If Gamedoc = Null then
			PrintF("XML Document not parsed successfully, GetGameXML. "+ GName)
			Return -1				
			'CustomRuntimeError( "Error 39: XML Document not parsed successfully, GetGameXML. "+ GName) 'MARK: Error 39
		End If
		
		RootNode = Gamedoc.getRootElement()
		PrintF("Root Element")
		If RootNode = Null Then
			Gamedoc.free()
			Gamedoc = Null 
			PrintF("Empty document, GetGameXML. "+ GName)
			Return -1				
			'CustomRuntimeError( "Error 40: Empty document, GetGameXML. "+ GName) 'MARK: Error 40
		End If		

		If RootNode.getName() <> "Game" Then
			Gamedoc.free()
			Gamedoc = Null 
			PrintF("Document of the wrong type, root node <> Game, GetGameXML. "+ GName)
			Return -1			
			'CustomRuntimeError( "Error 41: Document of the wrong type, root node <> Game, GetGameXML. "+ GName) 'MARK: Error 41
		End If
		
		PrintF("Retrieved Child List")
		Local ChildrenList:TList = RootNode.getChildren()
		If ChildrenList = Null Or ChildrenList.IsEmpty() Then
			Gamedoc.free()
			Gamedoc = Null 
			PrintF("Document error, no data contained within, GetGameXML. " + GName)
			Return -1
			'CustomRuntimeError( "Error 45: Document error, no data contained within, GetGameXML. "+ GName) 'MARK: Error 45			
		EndIf
		For node = EachIn ChildrenList
			Select node.getName()
				Case "PreBatchFileWait"
					Self.PreBFWait = Int(node.GetText() )
				Case "PostBatchFileWait"
					Self.PostBFWait = Int(node.getText())
				Case "StartWaitEnabled"
					Self.StartWaitEnabled = Int(node.getText())
				Case "GameRunnerAlwaysOn"
					Self.GameRunnerAlwaysOn = Int(node.GetText() )	
				Case "LuaFile"
					Self.LuaFile = node.GetText()
				Case "LuaIDData"
					Self.LuaIDData = node.GetText()				
				Case "Mounter"
					Self.Mounter = node.GetText()
				Case "VDriveNum"
					Self.VDriveNum = node.getText()
				Case "UnMount"
					Self.UnMount = node.getText()
				Case "DiscImage"
					Self.DiscImage = node.getText()
				Case "Trailer"
					Self.Trailer = node.getText()
				'Case "TrailerURL"
				'	Self.TrailerURL = node.getText()
				Case "Name"
					Self.Name = node.getText()
				Case "Description"
					Self.Desc = node.getText()
				Case "Platform"
					Self.Plat = node.getText()
				Case "PlatformNumber"
					Self.PlatformNum = Int(node.getText())
				Case "Co-op"
					Self.Coop = node.getText()
				Case "Players"
					Self.Players = node.getText()
				Case "PreBatchFile"
					Self.PreBF = node.getText()
				Case "PostBatchFile"
					Self.PostBF = node.getText()
				Case "EXEs"
					'EXENode = node
					Local EXEList:TList = node.getChildren()
					If EXEList = Null Or EXEList.IsEmpty() Then

					Else
						For node2 = EachIn EXEList
							Select node2.getName()
								Case "RUN"
									Self.RunEXE = node2.getText()
								Case "ROM"
									Self.ROM = node2.getText()
								Case "ExtraCMD"
									Self.ExtraCMD = node2.getText()
								Case "EmulatorOverride"
									Self.EmuOverride = node2.getText()
								Case "ExtraEXE"
									ListAddLast(Self.OEXEs , node2.getText() )
									ListAddLast(Self.OEXEsName , node2.getAttribute("name") )
								Case "WatchEXEs"
									ListAddLast(Self.WatchEXEs , node2.getText() )
							End Select	 
						Next
					EndIf
				
				Case "ReleaseDate"
					Self.ReleaseDate = node.getText()
				Case "Certificate"
					Self.Cert = node.getText()
				Case "Developer"
					Self.Dev = node.getText()
				Case "Publisher"
					Self.Pub = node.getText()
				Case "Genres"
					'GenreNode = node
					Local GenreList:TList = node.getChildren()
					If GenreList = Null Or GenreList.IsEmpty() Then
					
					Else
						For node2 = EachIn GenreList
							If node2.getName() = "Genre" Then
								ListAddLast(Self.Genres , node2.getText())
							EndIf
						Next
					EndIf
				Case "ArtWork"
					Local ArtList:TList = node.getChildren()
					If ArtList = Null Or ArtList.IsEmpty() Then
					
					Else
						For node2 = EachIn ArtList
							Select node2.getName()
								Case "FrontBoxArt"
									ListAddLast(Self.FrontBoxArt , node2.getText() )
								Case "BackBoxArt"
									ListAddLast(Self.BackBoxArt , node2.getText() )
								Case "FanArt"
									ListAddLast(Self.Fanart , node2.getText() )
								Case "BannerArt"
									ListAddLast(Self.BannerArt , node2.getText() )
								Case "ScreenShot"
									ListAddLast(Self.ScreenShots , node2.getText())																											
							End Select
						Next
					EndIf

				Case "ArtWorkThumbs"
					Local ArtListT:TList = node.getChildren()
					If ArtListT = Null Or ArtListT.IsEmpty() Then
					
					Else
						For node2 = EachIn ArtListT
							Select node2.getName()
								Case "FanArt"
									ListAddLast(Self.FanartThumbs , node2.getText() )
								Case "ScreenShot"
									ListAddLast(Self.ScreenShotThumbs , node2.getText())																											
							End Select
						Next
					EndIf		
				Case "ID"
					If node.GetText() = "0" then
					Else
						Self.LuaFile = "thegamesdb.net.lua"
						Self.LuaIDData = Int(node.GetText() )
					EndIf
				Case "Rating"
					Self.Rating = Int(node.getText())
			End Select
			
			'Gather number of screenshots
			Self.ScreenShotsAvailable=0
			
			Local File:String 
			
			If FileType(GAMEDATAFOLDER + GName +FolderSlash+"Shot1_OPT.jpg")=1 Then
				Self.ScreenShotsAvailable =  1
			ElseIf FileType(GAMEDATAFOLDER + GName +FolderSlash+"Shot2_OPT.jpg")=1 Then
				Self.ScreenShotsAvailable =  1
			EndIf 	
			If FileType(GAMEDATAFOLDER + GName +FolderSlash+"ScreenShots") = 2 Then
			
			Else
				CreateDir(GAMEDATAFOLDER + GName +FolderSlash+"ScreenShots")
			EndIf 
			
			If FileType(GAMEDATAFOLDER + GName +FolderSlash+"ScreenShots") = 2 Then 
				If Self.ScreenShotsAvailable=0 Then 
					Local ReadScreenShotFolder = ReadDir(GAMEDATAFOLDER + GName +FolderSlash+"ScreenShots")
					Repeat
						File = NextFile(ReadScreenShotFolder)
						If File=".." Then Continue
						If File="." Then Continue
						If File="" Then Exit
						If FileType(GAMEDATAFOLDER + GName +FolderSlash+"ScreenShots"+FolderSlash+File)=2 Then Continue 
						If ExtractExt(File)="jpg" Then
							Self.ScreenShotsAvailable = 1
							Exit
						EndIf 
					Forever
					CloseDir(ReadScreenShotFolder)
				EndIf 
			EndIf
			
		Next	
		
		PrintF("Getting userdata")
		If FileType(GAMEDATAFOLDER + GName + FolderSlash + "userdata.txt") = 1 then
			Local ReadUserData = ReadFile(GAMEDATAFOLDER + GName + FolderSlash+"userdata.txt")
				Self.Rating = ReadLine(ReadUserData)
				Self.Completed = Int(ReadLine(ReadUserData) )
			CloseFile(ReadUserData)
		Else
			Self.Completed = 0
		EndIf

		Gamedoc.free()
		Gamedoc = Null 
	End Method
	
	Method WriteUserData()
		Local GName:String = Lower(Self.GameNameDirFilter(Self.Name) + "---" + Self.PlatformNum)
		WriteUserDataFile = WriteFile(GAMEDATAFOLDER + GName + FolderSlash+"userdata.txt")
		WriteLine(WriteUserDataFile,Self.Rating)
		WriteLine(WriteUserDataFile , Self.Completed)
		CloseFile(WriteUserDataFile)
	End Method 
	


	Rem

	Function GameDescriptionSanitizer$(Name$)
		
		CustomRuntimeError("This function should not be used!")
	
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
		
		CustomRuntimeError("This function should not be used!")
		
		Repeat
		For a = 1 To Len(Name)
			If Mid(Name,a,1)=Chr(8211) Then
				Name=Left(Name,a-1)+"-"+Right(Name,Len(Name)-a-1)
				Exit			
			EndIf				
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
		Next
		If a=>Len(Name) Then 
			Exit 
		EndIf
		Forever
		Repeat
			For a=1 To Len(Name)
				temp = Asc(Mid(Name,a,1))
					If temp > 122 Or temp =92 Or temp = 62 Or temp =60 Or temp = 58 Or temp = 47 Or temp = 42 Or temp = 34 Or temp< 30
					Name=Left(Name,a-1)+""+Right(Name,Len(Name)-a)
					Exit							
				EndIf 
			Next 		
			If a=>Len(Name) Then 
				Exit 
			EndIf		
		Forever
		Return Name
	End Function
	
	EndRem
	
	Function CreateEmptyXMLGame(File:String)
		WriteXML = WriteFile(File)
		WriteLine(WriteXML , "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?><Game></Game>")
		CloseFile(WriteXML)
	End Function		
End Type
	
	
?Not Threaded
Function PrintF(Tex:String)
	If Debug = True Then
		Print Tex
	Else
		If DebugLogEnabled = True Then 
			WriteLog = OpenFile(LOGFOLDER + LogName)
			SeekStream(WriteLog, StreamSize(WriteLog) )
			WriteLog.WriteLine(Tex)
			CloseFile(WriteLog)
		EndIf 
	EndIf
End Function

?Threaded
Function PrintF(Tex:String, File:String = "")
	If File = "" then
		File = LogName
	EndIf
	If Debug = True Then
		LockMutex(mutex_Print)
		Print Tex
		UnlockMutex(mutex_Print)
	Else
		If DebugLogEnabled = True Then 
			LockMutex(Mutex_DebugLog)
			WriteLog = OpenFile(LOGFOLDER + File)
			SeekStream(WriteLog,StreamSize(WriteLog))
			WriteLog.WriteLine(Tex)
			CloseFile(WriteLog)
			UnlockMutex(Mutex_DebugLog)
		EndIf 
	EndIf
End Function
?

Function CustomRuntimeError(ERROR:String)
	PrintF(ERROR)
	DebugStop()
	?Threaded
		RuntimeError ERROR
	?Not Threaded
		'Local dial:wxMessageDialog = New wxMessageDialog.Create(Null, ERROR, "Runtime Error", wxOK | wxICON_ERROR)
		'dial.ShowModal()
		'dial.Free()	
		RuntimeError ERROR
	?
	End
End Function

Function Check7zip()
	If FileType(SevenZipPath) = 0 Then Return False
	Return True
End Function


Type MounterReadType
	Field MountersList:TList = CreateList()
	Field CurrentMounter:String
	Field MounterEXE:String
	Field MountString:String
	Field UnMountString:String
	Field Drives:TList = CreateList()
	Field MounterPath:String
	Field Platform:String
	
	
	Method Init()
		MountersList = CreateList()
		Local File:String
		ReadMounters = ReadDir(MOUNTERFOLDER)
		Repeat
			File = NextFile(ReadMounters)
			If File = "" Then Exit 
			If File="." Or File=".." Then Continue
			If FileType(MOUNTERFOLDER + File) = 1 Then
				PrintF("Checking: "+File)
				If ExtractExt(File) = "xml" Then
					If GetMounter(File) <> - 1 Then
						If IsntNull(MounterEXE) And IsntNull(MountString) And Drives.Count()>0 Then
							?Win32	
							If Platform = "Win32"	
							?Linux
							If Platform = "Linux"
							?MacOS
							If Platform = "Mac"
							?																
								ListAddLast(MountersList , File)
							EndIf 
						EndIf
					EndIf
				EndIf
			EndIf
		Forever
		CloseDir(ReadMounters)
	End Method

	Function CreateEmptyXMLGame(File:String)
		WriteXML = WriteFile(File)
		WriteLine(WriteXML , "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?><Mounter></Mounter>")
		CloseFile(WriteXML)
	End Function	
	
	Method SaveMounter:Int()
		CopyFile(MOUNTERFOLDER + Self.CurrentMounter , TEMPFOLDER + "temp.xml") 
		CreateEmptyXMLGame(MOUNTERFOLDER + Self.CurrentMounter)
		
		Local Mounterdoc:TxmlDoc
		Local RootNode:TxmlNode , DrivesNode:TxmlNode 

		Mounterdoc = TxmlDoc.parseFile(MOUNTERFOLDER + Self.CurrentMounter)
	
		If Mounterdoc = Null Then
			CustomRuntimeError( "Error 36: XML Document not parsed successfully, SaveMounter") 'MARK: Error 36
		End If
		
		RootNode = Mounterdoc.getRootElement()
		
		If RootNode = Null Then
			Mounterdoc.free()
			CustomRuntimeError( "Error 37: Empty document, SaveMounter") 'MARK: Error 37
		End If		

		If RootNode.getName() <> "Mounter" Then
			Mounterdoc.free()
			CustomRuntimeError( "Error 38: Document of the wrong type, root node <> Mounter") 'MARK: Error 38
		End If
		
		RootNode.addTextChild("MounterEXE" , Null , Self.MounterEXE)
		RootNode.addTextChild("MounterPath" , Null , Self.MounterPath)
		RootNode.addTextChild("Mount" , Null , Self.MountString)
		RootNode.addTextChild("UnMount" , Null , Self.UnMountString)
		RootNode.addTextChild("Platform" , Null , Self.Platform)	
		
		DrivesNode = RootNode.addTextChild("Drives" , Null , "")
		For Drive:String = EachIn Drives
			DrivesNode.addTextChild("Drive" , Null , Drive)
		Next
		
		For b=1 To 10
			SaveStatus = Mounterdoc.saveFormatFile(MOUNTERFOLDER + Self.CurrentMounter , False)
			PrintF("SaveXML Try: "+b+" Status: "+SaveStatus)
			If SaveStatus <> - 1 Then Exit
			Delay 100
		Next
		If b = 10 Then
			CopyFile(TEMPFOLDER + "temp.xml" , MOUNTERFOLDER + Self.CurrentMounter) 
			CustomRuntimeError("Error 44: Could Not Write XML File") 'MARK: Error 44
		EndIf			
		
		Mounterdoc.free()
		
	End Method
	
	Method GetMounter:Int(File:String)
		CurrentMounter = File
		Drives = CreateList()
		MounterPath = ""
		MounterEXE = ""
		MountString = ""
		UnMountString = ""
		Platform = ""
		
		
		If FileType(MOUNTERFOLDER+File) <> 1 Then
			Return -1
		EndIf		
		
		Local Mounterdoc:TxmlDoc
		Local RootNode:TxmlNode , node:TxmlNode , node2:TxmlNode
		
		Mounterdoc = TxmlDoc.parseFile(MOUNTERFOLDER+File)
	
		If Mounterdoc = Null Then
			PrintF("XML Document not parsed successfully, Mounter.")
			Return -1				
			'CustomRuntimeError( "Error 39: XML Document not parsed successfully, GetGameXML. "+ GName) 'MARK: Error 39
		End If
		
		RootNode = Mounterdoc.getRootElement()
		
		If RootNode = Null Then
			Mounterdoc.free()
			PrintF("Empty document, Mounter.")
			Return -1				
			'CustomRuntimeError( "Error 40: Empty document, GetGameXML. "+ GName) 'MARK: Error 40
		End If		

		If RootNode.getName() <> "Mounter" Then
			Mounterdoc.free()
			PrintF("Document of the wrong type, root node <> Mounter, Mounter.")
			Return -1			
			'CustomRuntimeError( "Error 41: Document of the wrong type, root node <> Game, GetGameXML. "+ GName) 'MARK: Error 41
		End If
		
		Local ChildrenList:TList = RootNode.getChildren()
		If ChildrenList = Null Or ChildrenList.IsEmpty() Then
			Mounterdoc.free()
			PrintF("Document error, no data contained within, Mounter.")
			Return -1
			'CustomRuntimeError( "Error 45: Document error, no data contained within, GetGameXML. "+ GName) 'MARK: Error 45			
		EndIf
		For node = EachIn ChildrenList
			Select node.getName()
				Case "MounterPath"
					Self.MounterPath = node.getText()
				Case "Drives"
					'EXENode = node
					Local DriveList:TList = node.getChildren()
					If DriveList = Null Or DriveList.IsEmpty() Then

					Else
						For node2 = EachIn DriveList
							Select node2.getName()
								Case "Drive"
									ListAddLast(Self.Drives , node2.getText())
							End Select	 
						Next
					EndIf
				Case "MounterEXE"
					Self.MounterEXE = node.getText()
				Case "Mount"
					Self.MountString = node.getText()
				Case "UnMount"
					Self.UnMountString = node.getText()
				Case "Platform"
					Self.Platform = node.getText()
			End Select
		Next	
					
		Mounterdoc.free()
		
	End Method 
End Type

Type SettingsType
	Field File:String
	Field SettingsList:TList
	Field Settingdoc:TxmlDoc
	Field RootNode:TxmlNode
	Field DType:String = "Settings"

	Function CreateEmptyXMLGame(Fil:String , DType:String)
		WriteXML = WriteFile(Fil)
		WriteLine(WriteXML , "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?><"+DType+"></"+DType+">")
		CloseFile(WriteXML)
	End Function
	
	Method SaveSetting(SetName:String , SetValue:String)
		If File <> Null Or FileType(ExtractDir(File) ) <> 2 Then
			If Settingdoc = Null Then
				CreateEmptyXMLGame(File,Self.DType)
				Self.ParseFile()
			EndIf
			Local NameFound = False
			Local node:TxmlNode
			
			If SettingsList <> Null Then
				For node = EachIn SettingsList
					If node.getName()	 = SetName Then
						node.setContent(SetValue)
						NameFound = True 
					EndIf
				Next
			EndIf
			
			If NameFound <> True Then
				RootNode.addTextChild(SetName , Null , SetValue)
			EndIf
			
			SettingsList = RootNode.getChildren()
		EndIf
	End Method
	
	Method SaveFile()
		For b=1 To 10
			SaveStatus = Settingdoc.saveFormatFile(File , False)
			PrintF("SaveXML Try: "+b+" Status: "+SaveStatus)
			If SaveStatus <> - 1 Then Exit
			Delay 100
		Next		
		Self.CloseFile()
		Self.ParseFile()
	End Method 
	
	Method ParseFile(Fil:String = Null, TDType:String = Null)
		If Fil <> Null Then
			Self.File = Fil
		EndIf 
		
		If TDType = Null Then

		Else
			Self.DType = TDType
		EndIf
				
		If FileType(Self.File) <> 1 Then
			Self.SettingsList = Null
			Self.Settingdoc = Null 
			Return
		EndIf		
	
		Settingdoc = TxmlDoc.parseFile(Self.File)
	
		If Settingdoc = Null Then
			PrintF("XML Document not parsed successfully, ParseFile.")
			Self.SettingsList = Null 
			Return			
		End If
		
		RootNode = Settingdoc.getRootElement()
		
		If RootNode = Null Then
			Settingdoc.free()
			PrintF("Empty document, ParseFile.")
			Self.SettingsList = Null
			Self.Settingdoc = Null 
			Return				
		End If		

		If RootNode.getName() <> Self.DType Then
			Settingdoc.free()
			PrintF("Document of the wrong type, root node <> "+Self.DType+", ParseFile.")
			Self.SettingsList = Null
			Self.Settingdoc = Null
			Self.RootNode = Null
			Return		

		End If
		
		SettingsList = RootNode.getChildren()
	End Method
	
	Method GetSetting:String(Set:String)
		Local node:TxmlNode
		If SettingsList <> Null Then
			For node = EachIn SettingsList
				If node.getName()	 = Set Then
					Return node.getText()
				EndIf
			Next
		EndIf
		Return ""
	End Method
	
	Method CloseFile()
		If Settingdoc <> Null Then
			Settingdoc.free()
		EndIf 
	End Method 
End Type

Type DownloadListObject
	Field URL:String
	Field Name:String
End Type

Function CheckInternet:Int()
	'Connected Needs to be Global
	
	'FIX: remove this after
	Connected = 1
	Return 1
	
	Local ReturnValue:String 
	Local temp_proc:TProcess
	?Win32	
	Const PingError1:String = "Ping request could not find host www.google.com. Please check the name and try again."
	?Linux
	Const PingError1:String = "ping: unknown host www.google.com"
	?MacOS
	Const PingError1:String = "ping: cannot resolve www.google.com: Unknown host"
	?
	If Connected = 1 Then
		PrintF("Connected to Internet - Already Checked")
		Return 1
	ElseIf Connected = 0 Then
		ReturnValue = "" 
		?Win32
		temp_proc = CreateProcess("ping www.google.com -n 1")
		?Linux
		temp_proc = CreateProcess("ping www.google.com -c 1")
		?MacOS
		temp_proc = CreateProcess("ping -c 1 www.google.com")
		?
		While temp_proc.status()
			If temp_proc.pipe.ReadAvail() Then
				ReturnValue = ReturnValue + temp_proc.pipe.ReadLine()
			EndIf
		Wend 
		PrintF("Return: "+ReturnValue)

		If ReturnValue = "" Or ReturnValue = " " Then 
			PrintF("Failed To Connect to Internet")
			Connected = 0
			Return 0
		Else
			If Instr(ReturnValue,PingError1) = 0 Then 
			
			Else
				PrintF("Failed To Connect to Internet")
				Connected = 0
				Return 0
			EndIf

		EndIf 		
		PrintF("Connected to Internet")
		Connected = 1
		Return 1
	EndIf
	
End Function 

Rem
Function CheckPGMInternet:Int()

	'ConnectedPGM Needs to be Global
	If PerminantPGMOff = 1 Or Connected = 0 Then
		PrintF("Either unconnected or PGM Turned Off")
		ConnectedPGM = 0
		Return 0
	EndIf	
	
	Local ReturnValue:String 
	Local temp_proc:TProcess
	?Win32	
	Const PingError1:String = "Ping request could not find host photongamemanager.com. Please check the name and try again."
	?Not Win32
	Const PingError1:String = "ping: unknown host photongamemanager.com"
	?
	If ConnectedPGM = 1 Then
		Return 1
	ElseIf ConnectedPGM = 0 Then
		ReturnValue = "" 
		?Win32
		temp_proc = CreateProcess("ping photongamemanager.com -n 1")
		?Not Win32
		temp_proc = CreateProcess("ping photongamemanager.com -c 1")
		?
		While temp_proc.status()
			If temp_proc.pipe.ReadAvail() Then
				ReturnValue = ReturnValue + temp_proc.pipe.ReadLine()
			EndIf
		Wend
		PrintF("Return:"+ReturnValue)
		
		If ReturnValue="" Or ReturnValue=" " Then 
			PrintF("Failed To Connect to PGM")
			ConnectedPGM = 0
			Return 0
		Else		
			If Instr(ReturnValue,PingError1) = 0 Then 
			
			Else
				PrintF("Failed To Connect to PGM")
				ConnectedPGM = 0
				Return 0
			EndIf

		EndIf 
		
		PrintF("Connected to PGM")
		ConnectedPGM = 1
		Return 1
	EndIf
	
End Function
EndRem 

Function ValidatePlugin(PluginPath:String , PluginType:String)
	If FileType(PluginPath+FolderSlash+"PM-CONFIG.xml")=1 Then
		Return True
	Else
		Return False
	EndIf 
End Function

Function keygen:String(name:String, v:String = "23456DDE7ES3428HG9ABCDEFGHHUEYSJKLM7J262KNPQRST8U4V3WXKAS2YZ")
	
	If Len(name) = 0 then
		name = "0"
	EndIf 
	
'	change v$ to as many or few random or unrandom letters, numbers, characters whatever
'	this is what the key is going to be made out of
'	You can have duplicates all over the place if you want, it's up to you!
'	This is one part that will make your keys unique to other people using this program
'	e.g. v$="I1D9U0AJ5PFWIN1TR3EKLWZID42HU7KL8S6LTBN9VMCXOF6T46GY3JHIE9T7VTLFDEQ3Y38P"

	Local tname:String = name:String

'	make name longer if necessary
'	again adjust this to make your keys unique

	Local namel:Int = 20
	Local temp:String = ""
	Local n:Int 
	
	Repeat
		If Len(tname) <= namel
			temp = ""
			For n = 0 To Len(tname) - 1
				temp = temp + Chr(tname[n] + 1)
			Next
			tname = tname + temp
		EndIf
	Until Len(tname) > namel

	
'	this bit makes sure that you don't get any obvious repetitions over the 20 character key
	For n = 5 To 100 Step 5
		If Len(tname) = n Then tname = tname + "~~"
	Next

'	create encrypt string
	Local encrypt:String = ""
	For n = 0 To 19
		encrypt = encrypt + Chr(1)
	Next
	
	Local ee:Int
	Local nn:Int
'	over load encrypt 30 times
'	change this to make your keys unique further
	Local a:Int
	Local tl:Int
	For Local l:Int = 1 To 30
		For n = 0 To Len(tname) - 1
		
			a = tname[n]
			a = a - 32
			temp = ""

			For nn = 0 To 19
				tl = encrypt[nn]
				If nn = ee Then temp = temp + Chr(tl + a Mod 256)Else temp = temp + Chr(tl)
			Next
			encrypt = temp
			ee = ee + 1
			If ee = 19 Then ee = 0
			
		Next
	Next

'	suck out the key
	Local encrypted:String = ""
	Local e:Int
	For ee = 0 To 19
		e = encrypt[ee] Mod Len(v) - 1
		If e = - 1 then e = 0
		encrypted = encrypted + Chr(v[e])
	Next

'	format the key with -'s
	encrypted = encrypted[..5] + "-" + encrypted[5..10] + "-" + encrypted[10..15] + "-" + encrypted[15..20]

'	return the key
	Return encrypted

End Function

Function CheckKey()
	?Linux
	EvaluationMode = False
	?
	
	Local Name:String = ""
	Local Key:String = ""
	
	EvaluationMode = False

	If FileType("ProgramKey.txt") = 1 then
		KeyFile = ReadFile("ProgramKey.txt")
		Name = ReadLine(KeyFile)
		Key = ReadLine(KeyFile)	
		CloseFile(KeyFile)
	ElseIf FileType(SETTINGSFOLDER + "ProgramKey.txt") = 1 then
		KeyFile = ReadFile(SETTINGSFOLDER + "ProgramKey.txt")
		Name = ReadLine(KeyFile)
		Key = ReadLine(KeyFile)		
		CloseFile(KeyFile)
	EndIf	

	'Temp User Key:
	If key = "PRW2W-2MGQS-2V2J6-YSD22" Then 
		EvaluationMode = True
		Return			
	EndIf
	If Key = keygen(Name) then
		EvaluationMode = False 
		Return
	EndIf
	
	
	EvaluationMode = True
	Return
	

End Function

Function CheckVersion:Int()
	Local Line:String
	Local Version:String 
	Local Online:String
	Local Important:String 
	Local Error:Int
	
	'FIX: Remove this later
	Return 0
	

	If Connected = 0 Then
		Return 0
	EndIf 
	
	Local TempVersionFile:TStream	
	Local curl:TCurlEasy
	TempVersionFile=WriteFile(TEMPFOLDER+"TempVersion.txt")
	curl = TCurlEasy.Create()
	curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
	curl.setOptInt(CURLOPT_HEADER, 0)
	curl.setOptInt(CURLOPT_VERBOSE, 0)
	curl.setOptInt(CURLOPT_CONNECTTIMEOUT, 1)
	curl.setWriteStream(TempVersionFile)
	?Win32
	curl.setOptString(CURLOPT_URL, "http://photongamemanager.com/PackageManager/LatestVersionWin.txt")
	?Not Win32
	curl.setOptString(CURLOPT_URL, "http://photongamemanager.com/PackageManager/LatestVersionLinux.txt")
	?	
	Error = curl.perform()
	CloseFile(TempVersionFile)
	If Error>0 Then 
		Return 0
	EndIf
	curl.cleanup()
	curl = Null  
	
	Local testversionstream:TStream	
	If FileType(TEMPFOLDER+"TempVersion.txt")=1 Then 
		testversionstream = ReadFile(TEMPFOLDER+"TempVersion.txt")
	Else
		Return 0
	EndIf 
	Rem
	?Win32
	Local testversionstream:TStream = ReadStream("http::photongamemanager.com/PackageManager/LatestVersionWin.txt")
	?Not Win32
	Local testversionstream:TStream = ReadStream("http::photongamemanager.com/PackageManager/LatestVersionLinux.txt")
	?
	EndRem
	
	If testversionstream=Null Then 
		Return 0
	EndIf 
	
	Repeat
		Line = ReadLine(testversionstream)
		Version = Left(Line,5)
		If CurrentVersion = Version Then 
			Exit 
		EndIf 	
		If Eof(testversionstream) Then 
			CloseFile(testversionstream)
			Return 0
		EndIf 
	Forever
	CloseFile(testversionstream)
	
	
	Line = Right(Line,Len(Line)-6)
	
	Local a:Int = 0
	Local start:Int = 1
	Local b:Int = 0
	
	For a=1 To Len(Line)
		If Mid(Line,a,1)="," Then
			Select b
				Case 0
					Version = Mid(Line,start,a-start)					
				Case 1
					'Package = Mid(Line,start,a-start)	
				Case 2
					Online = Mid(Line,start,a-start)
				Case 3
					Important = Mid(Line,start,a-start)
					Exit 
			End Select
			start=a+1			
			b=b+1
		EndIf 
	Next 
	
	Local ReadUpdate:TStream
	Local WriteUpdate:TStream
	
	PrintF("Version: "+Version)
	Local NNVersion:String
	If Online = "ONLINE" Then 
		If Int(Right(Version,2)) > Int(Right(CurrentVersion,2)) Then 
			If Important = "YES" Then 
				Notify("There is an important update to GameManager, you must update to continue using this product.") 
				RunProcess("PhotonUpdater.exe" , 1)
				End 
			Else
				If FileType(SETTINGSFOLDER+"Update.txt") = 1 Then
					ReadUpdate = ReadFile(SETTINGSFOLDER+"Update.txt")			
					NNVersion = ReadLine(ReadUpdate)
					CloseFile(ReadUpdate)
				EndIf 
				If NNVersion <> Version Then 
					If Confirm("There is a new version of GameManager would you like to update?") Then
						RunProcess("PhotonUpdater.exe" , 1)
						End 	
					Else
						WriteUpdate = WriteFile(SETTINGSFOLDER+"Update.txt")			
						WriteLine(WriteUpdate,Version)
						CloseFile(WriteUpdate)
					EndIf 
				EndIf 
				
			EndIf 
		EndIf
	EndIf 
		
	Return 1
	
End Function

Function StandardSlashes:String(Text:String)
	If FolderSlash = "/" Then 
		Text = Replace(Text,"\",FolderSlash)	
	Else
		Text = Replace(Text,"/",FolderSlash)
	EndIf 
	Return Text
End Function


Function getKeyCodeChar:String(inNum:Int)

If inNum=8  Then Return "Backspace"
If inNum=9  Then Return "Tab"
If inNum=12 Then Return "Clear"
If inNum=13 Then Return "Return"
If inNum=19 Then Return "Pause"
If inNum=20 Then Return "Caps Lock"
If inNum=27 Then Return "Esc"
If inNum=32 Then Return "Space"
If inNum=33 Then Return "Page Up"
If inNum=34 Then Return "Page Down"
If inNum=35 Then Return "End"
If inNum=36 Then Return "Home"
If inNum=37 Then Return "Left"
If inNum=38 Then Return "Up"
If inNum=39 Then Return "Right"
If inNum=40 Then Return "Down"
If inNum=41 Then Return "Select"
If inNum=42 Then Return "'print"
If inNum=43 Then Return "Execute"
If inNum=44 Then Return "Screen"
If inNum=45 Then Return "Insert"
If inNum=46 Then Return "Delete"
If inNum=47 Then Return "Help"
If inNum=48 Then Return "0"
If inNum=49 Then Return "1"
If inNum=50 Then Return "2"
If inNum=51 Then Return "3"
If inNum=52 Then Return "4"
If inNum=53 Then Return "5"
If inNum=54 Then Return "6"
If inNum=55 Then Return "7"
If inNum=56 Then Return "8"
If inNum=57 Then Return "9"
If inNum=65 Then Return "A"
If inNum=66 Then Return "B"
If inNum=67 Then Return "C"
If inNum=68 Then Return "D"
If inNum=69 Then Return "E"
If inNum=70 Then Return "F"
If inNum=71 Then Return "G"
If inNum=72 Then Return "H"
If inNum=73 Then Return "I"
If inNum=74 Then Return "J"
If inNum=75 Then Return "K"
If inNum=76 Then Return "L"
If inNum=77 Then Return "M"
If inNum=78 Then Return "N"
If inNum=79 Then Return "O"
If inNum=80 Then Return "P"
If inNum=81 Then Return "Q"
If inNum=82 Then Return "R"
If inNum=83 Then Return "S"
If inNum=84 Then Return "T"
If inNum=85 Then Return "U"
If inNum=86 Then Return "V"
If inNum=87 Then Return "W"
If inNum=88 Then Return "X"
If inNum=89 Then Return "Y"
If inNum=90 Then Return "Z"
If inNum=96 Then Return "Numpad 0"
If inNum=97 Then Return "Numpad 1"
If inNum=98 Then Return "Numpad 2"
If inNum=99 Then Return "Numpad 3"
If inNum=100 Then Return "Numpad 4"
If inNum=101 Then Return "Numpad 5"
If inNum=102 Then Return "Numpad 6"
If inNum=103 Then Return "Numpad 7"
If inNum=104 Then Return "Numpad 8"
If inNum=105 Then Return "Numpad 9"
If inNum=106 Then Return "Numpad *"
If inNum=107 Then Return "Numpad +"
If inNum=109 Then Return "Numpad -"
If inNum=110 Then Return "Numpad ."
If inNum=111 Then Return "Numpad /"
If inNum=112 Then Return "F1"
If inNum=113 Then Return "F2"
If inNum=114 Then Return "F3"
If inNum=115 Then Return "F4"
If inNum=116 Then Return "F5"
If inNum=117 Then Return "F6"
If inNum=118 Then Return "F7"
If inNum=119 Then Return "F8"
If inNum=120 Then Return "F9"
If inNum=121 Then Return "F10"
If inNum=122 Then Return "F11"
If inNum=123 Then Return "F12"
If inNum=144 Then Return "Num Lock"
If inNum = 145 then Return "Scroll Lock"
If inNum=160 Then Return "Shift (Left)"
If inNum=161 Then Return "Shift (Right)"
If inNum=162 Then Return "Control (Left)"
If inNum=163 Then Return "Control (Right)"
If inNum=164 Then Return "Alt key (Left)"
If inNum=165 Then Return "Alt key (Right)"
If inNum=192 Then Return "Tilde"
If inNum = 107 then Return "Minus"
If inNum=109 Then Return "Equals"
If inNum=219 Then Return "Bracket (Open)"
If inNum=221 Then Return "Bracket (Close)"
If inNum=226 Then Return "Backslash"
If inNum=186 Then Return "Semi-colon"
If inNum=222 Then Return "Quote"
If inNum = 188 then Return "Comma"
If inNum=190 Then Return "Period"		
If inNum=191 Then Return "Slash"

Return Chr(inNum)

End Function


?Not Threaded
'Function TryLockMutex(obj:Object)
'End Function

'Function UnlockMutex(obj:Object)
'End Function
?

