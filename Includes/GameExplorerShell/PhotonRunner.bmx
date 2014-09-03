Type PhotonRunner Extends wxApp
	Field Runner:RunnerWindow
	Field GameNode:String 
	Field EXENum:Int 
	
	Method OnInit:Int()		
		wxImage.AddHandler( New wxICOHandler)
		Runner = RunnerWindow(New RunnerWindow.Create(Null , wxID_ANY , "PhotonRunner" , - 1 , - 1 , 300 , 300) )
		Runner.SetGame(GameNode,EXENum)
		Return True
	End Method
	
	Method SetGame(GN:String , EN:Int)
		PrintF(GN+" " + EN)
		GameNode = GN
		EXENum = EN
	End Method 
End Type

Type RunnerWindow Extends wxFrame
	Field GameNode:GameReadType
	Field EXENum:Int
	Field Mounter:MounterReadType
	
	Field MounterOFF:Int
	Field BatchOFF:Int 
	Field UnMountOFF:Int
	
	Field RunEXE:String
	Field EXEOnly:String 
	Field PreBatch:String
	Field PreBatchWait:Int 
	Field PostBatch:String
	Field PostBatchWait:Int 	
	Field MountCommand:String
	Field UnMountCommand:String
	
	Global ScreenShotPlugin:ScreenShotPluginType
	Global PowerPlanPlugin:PowerPlanPluginType
	Global VideoPlugin:VideoPluginType
	
	Field Timer:wxTimer
	Field Timer2:wxTimer
	'Field KeyTimer:wxTimer
	Field ProgramStarted:Int = False
	
	Field SteamProcessList:TList 
	Field ExtraWatchEXEs:TList 
	
	Field TextCtrl:wxTextCtrl
	Field EndButton:wxButton
	
	Method OnInit()
		FinishProgramRunning = 0
		Local Vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON2,wxBITMAP_TYPE_ICO)
		Self.SetIcon(Icon)
		Timer = New wxTimer.Create(Self,PR_T)
		Timer2 = New wxTimer.Create(Self,PR_T2)
		'KeyTimer = New wxTimer.Create(Self,PR_KT)
		Timer.Start(100)

		'KeyTimer.Start(10)
		TextCtrl = New wxTextCtrl.Create(Self,wxID_ANY,"(Initialising)" , -1, -1 ,-1 , -1 , wxTE_WORDWRAP | wxTE_MULTILINE | wxTE_READONLY)
		EndButton = New wxButton.Create(Self , PR_EB , "Close PhotonRunner")
		
		Vbox.Add(TextCtrl , 3 , wxEXPAND | wxALL , 4)
		Vbox.Add(EndButton , 3 , wxEXPAND | wxALL , 4)

		Self.SetSizer(Vbox)	
		
		Self.Centre()
		Self.Show()	
		Connect(PR_EB , wxEVT_COMMAND_BUTTON_CLICKED , ManualClose)
		?Win32
		Connect(PR_T , wxEVT_TIMER , TimerUpdate)	
		?
		Connect(PR_T2 , wxEVT_TIMER , TimerUpdate2)		
		'Connect(PR_KT , wxEVT_TIMER, KeyTimerUpdate)
	End Method 

	Function ManualClose(event:wxEvent)
		MainWin:RunnerWindow = RunnerWindow(event.parent)
		Select MainWin.EndButton.GetLabel()
			Case "Close PhotonRunner"
				MainWin.FinishProgram()		
			Case "Skip"
				MainWin.EndButton.Disable()
				SkipBatchWait = 1
			Default
				PrintF("Manual Close Select Fail")
		End Select
	End Function
	
	Function TimerUpdate(event:wxEvent)	
		PhotonRunnerApp.Yield()
		If ScreenShotPlugin.Enabled = True Then 
			HotKey.SetKeyNumber(ScreenShotPlugin.Key)
			If HotKey.KeyHit() Then 
				ScreenShotPlugin.TakeScreenShot()
			EndIf 		
		EndIf 
		If VideoPlugin.Enabled = True Then 
			HotKey.SetKeyNumber(VideoPlugin.Key)
			If HotKey.KeyHit() Then 
				VideoPlugin.TakeScreenShot()
			EndIf 		
		EndIf 		


	End Function
	
	Function TimerUpdate2(event:wxEvent)
		
		Local ProcessList:TList = Null
		Local SteamProcessList:TList = Null  
		Local Running = True 
		?Win32
		Local p:TWinProc
		?
		MainWin:RunnerWindow = RunnerWindow(event.parent)
		MainWin.Timer2.Stop()
				
		?Linux
		'Hack to bypass executable search code
		'Do Nothing
		
		?Win32	
		
		If MainWin.ProgramStarted = True Then
			
			If Lower(MainWin.EXEOnly) = "steam.exe" Then
				TWinProc.GetProcesses()
				p = TWinProc.Find("Steam.exe",TWinProc._list)
				
				SteamProcessList = CreateList()
				GetSteamProcesses(p,SteamProcessList)
				'SteamProcessList = p.kidsNames	
					
				SteamProcessList = StripSteamProcesses(SteamProcessList)		
				If SteamProcessList = Null Or SteamProcessList.Count() < 1 Then
					Running = False
				Else
					Running = True 
				EndIf 	
				
				If Running = False Then 
					ProcessList = ListProcesses()
					For Process:String = EachIn ProcessList
						If ListContains(MainWin.ExtraWatchEXEs,Low(Process)) Then
							Running = True 
							Exit 
						EndIf 
					Next 
				EndIf 
				Rem
				PrintF("Printing SubProcesses")
				For a:String = EachIn SteamProcessList
					PrintF(a)
				Next 
				PrintF("Finished Printing Subprocesses")
				EndRem 
				ClearList(SteamProcessList)					
				
			Else
				ProcessList = ListProcesses()
				For Process:String = EachIn ProcessList
					If Lower(Process) = Lower(MainWin.EXEOnly) Or ListContains(MainWin.ExtraWatchEXEs,Low(Process)) Then
						Running = True
						Exit 
					Else
						Running = False 
					EndIf 
				Next
				ClearList(ProcessList)
			EndIf 
			If Running = False Then 
				MainWin.FinishProgram()
			EndIf 
		Else
			If Lower(MainWin.EXEOnly) = "steam.exe" Then
				TWinProc.GetProcesses()
				p = TWinProc.Find("Steam.exe",TWinProc._list)
				SteamProcessList = CreateList()
				GetSteamProcesses(p,SteamProcessList)				
				'SteamProcessList:TList = p.kidsNames
				SteamProcessList = StripSteamProcesses(SteamProcessList)		
				If SteamProcessList <> Null And SteamProcessList.Count() > 0 Then
					Delay 1000
					MainWin.ProgramStarted = True
					PrintF("Steam - ProgramStarted")
					PrintF("Printing SubProcesses")
					For a:String = EachIn SteamProcessList
						PrintF(a)
					Next 
					PrintF("Finished Printing Subprocesses")
				EndIf 						
					
			EndIf 
		EndIf

		?	
		MainWin.Timer2.Start(3000)
	End Function 

	Method FinishProgram()
		Timer.Stop()
		Timer2.Stop()
		If FinishProgramRunning = 0 Then 
			FinishProgramRunning = 1
			'To fix out of focus FrontEnd
			TextCtrl.AppendText("~n~n~n~n~n")
			TextCtrl.AppendText("Program Closing...~n")
			EndButton.Disable()
			PhotonRunnerApp.Yield()
						
			Local Process:Tprocess 
			PrintF("FinishProgram")
			?Win32 
			If PowerPlanPlugin.Enabled = True Then 
				PowerPlanPlugin.ActivatePlugin("End")
				TextCtrl.AppendText("Activating End PowerPlan...~n")
				PhotonRunnerApp.Yield()			
			EndIf 	
			Local CDir:String = StandardSlashes(CurrentDir())
			PrintF("CWD: "+CDir)		
			If BatchOFF = False Then
				If PostBatch="" Then
				
				Else
					PrintF("BF: "+ExtractEXEDir(PostBatch))
					ChangeDir(ExtractEXEDir(PostBatch))			
					'Past version compatability 	
		
					If PostBatchWait = True Then 
						If Left(PostBatch,1)=Chr(34) Then 
							Process = RunProcess(PostBatch, 0)
						Else
							Process = RunProcess(Chr(34) + PostBatch + Chr(34), 0)
						EndIf 
						TextCtrl.AppendText("Activating End Batch File And Waiting For It To Finish...~n")	
						PhotonRunnerApp.Yield()
						PrintF("Waiting for Batch to Complete")
						EndButton.Enable()
						EndButton.SetLabel("Skip")
						Repeat 
							If Process = Null Then Exit 
							If ProcessStatus(Process)=0 Then Exit 
							Delay 100
							PhotonRunnerApp.Yield()
							If SkipBatchWait = 1 Then 
								ProcessDetach(Process)
								Exit 
							EndIf 
						Forever
						SkipBatchWait = 0
						EndButton.Disable()
						EndButton.SetLabel("Close PhotonRunner")							
					Else
						TextCtrl.AppendText("Activating End Batch File...~n")
						PhotonRunnerApp.Yield()				
						If Left(PostBatch,1)=Chr(34) Then 
							RunProcess(PostBatch, 1)
						Else
							RunProcess(Chr(34) + PostBatch + Chr(34), 1)
						EndIf 
					EndIf 
					ChangeDir(CDir)
					PrintF("Batch Complete")
				EndIf 
			EndIf 
			If MounterOFF = False And UnMountOFF = False Then
				TextCtrl.AppendText("Unmounting Disc Images...~n")
				PhotonRunnerApp.Yield()		
				PrintF("MF: "+ExtractEXEDir(UnMountCommand))
				ChangeDir(ExtractEXEDir(UnMountCommand))
				RunProcess(UnMountCommand , 1)
				ChangeDir(CDir)
				PrintF("Mounter Complete")
			EndIf
			? 
			PrintF("FinishProgram End")
			If CabinateEnable Then 
				Select CmdLineCabinate
					Case 0
						PrintF("No Cabinate")
					Case 1
						PrintF("FrontEnd Cabinate")
						TextCtrl.AppendText("Loading FrontEnd~n")
						PhotonRunnerApp.Yield()						
						RunProcess(FRONTENDPROGRAM+" -Wait 1000 -ForceFront 1",1)
					Case 2
						PrintF("Explorer Cabinate")
						TextCtrl.AppendText("Loading Explorer~n")
						PhotonRunnerApp.Yield()						
						RunProcess(EXPLORERPROGRAM,1)	
					Default 
						CustomRuntimeError("Error: Incorrect Cabinate mode in Photon Runner")
				End Select 
			Else
				PrintF("CabinateEnabled = false")
			EndIf
			End 
		EndIf 
	End Method
	
	Method StartProgram()
		TextCtrl.Clear()
		TextCtrl.AppendText("Loading...~n")
		If RunnerButtonCloseOnly = True Then 
			PrintF("Always ON Active (Global)")
			TextCtrl.AppendText("Auto Detect Game Closing: OFF (Global):~n")
		EndIf
		If GameNode.GameRunnerAlwaysOn = True 
			PrintF("Always ON Active (This Game Only)")
			TextCtrl.AppendText("Auto Detect Game Closing: OFF (This Game Only):~n")
		EndIf
		EndButton.Disable()
		PhotonRunnerApp.Yield()	
		
		
	
		Local Process:TProcess
		PrintF("StartProgram")
		Local CDir:String = StandardSlashes(CurrentDir())
		PrintF("CWD: "+CDir)
		
		?Win32
		If PowerPlanPlugin.Enabled = True Then 
			TextCtrl.AppendText("Activating Power Plan~n")
			PhotonRunnerApp.Yield()		
			PowerPlanPlugin.ActivatePlugin("Start")
			PrintF("PowerPlan Started")
		EndIf 
		?
			
		?Win32	
		If BatchOFF = False Then
			If PreBatch="" Then 
			
			Else
				PrintF("BF: "+ExtractEXEDir(PreBatch))
				ChangeDir(ExtractEXEDir(PreBatch))
				'Past version compatability 
				If PreBatchWait = True Then 
					TextCtrl.AppendText("Activating Start Batch File And Waiting For It To Finish...~n")	
					PhotonRunnerApp.Yield()			
					If Left(PreBatch,1)=Chr(34) Then 
						Process = RunProcess(PreBatch, 0)
					Else
						Process = RunProcess(Chr(34) + PreBatch + Chr(34), 0)
					EndIf 
					PrintF("Waiting for Batch to Complete")
					EndButton.Enable()
					EndButton.SetLabel("Skip")
					Repeat 
						If Process=Null Then Exit 
						If ProcessStatus(Process)=0 Then Exit 
						Delay 100
						PhotonRunnerApp.Yield()
						If SkipBatchWait = 1 Then 
							ProcessDetach(Process)
							Exit 
						EndIf 
					Forever
					SkipBatchWait = 0
					EndButton.Disable()
					EndButton.SetLabel("Close PhotonRunner")
				Else
					TextCtrl.AppendText("Activating Start Batch File...~n")	
					PhotonRunnerApp.Yield()			
					If Left(PreBatch,1)=Chr(34) Then 
						RunProcess(PreBatch, 1)
					Else
						RunProcess(Chr(34) + PreBatch + Chr(34), 1)
					EndIf 
				EndIf 
				ChangeDir(CDir)
				PrintF("Batch Complete")
			EndIf 
		EndIf
		
		If MounterOFF = False Then
			TextCtrl.AppendText("Mounting Disc Image...~n")	
			PhotonRunnerApp.Yield()		
			PrintF("MF: "+ExtractEXEDir(MountCommand))
			ChangeDir(ExtractEXEDir(MountCommand))
			RunProcess(MountCommand , 1)
			ChangeDir(CDir)
			Delay 4000
			PrintF("Mounter Complete")
		EndIf	
		?
		
		
		PrintF("EF: "+ExtractEXEDir(RunEXE) )
		ChangeDir(ExtractEXEDir(RunEXE))
		
		'Past Version Compatability 
		TextCtrl.AppendText("Running Program...~n")	
		PhotonRunnerApp.Yield()
		
		'Rem
		Local hWnd:Byte Ptr=Self.GetHandle()
		OurThreadID = GetCurrentThreadId()
		
		Local ahwnd:Byte Ptr 
		CurrentThreadID = GetWindowThreadProcessId(GetForegroundWindow(),ahwnd)
		
		PrintF("Our Thread: "+OurThreadID)
		PrintF("Current Thread: "+CurrentThreadID)
		PrintF("Win: "+Int(hWnd))
		
		If OurThreadID<>CurrentThreadID Then 
			AttachThreadInput(OurThreadID,CurrentThreadID,True)
		EndIf 
		
		SetForegroundWindow(Int(hWnd))
		BringWindowToTop(Int(hWnd))
		'SetActiveWindow(hWnd)
		
		If OurThreadID<>CurrentThreadID Then 
			AttachThreadInput(OurThreadID,CurrentThreadID,False)
		EndIf 
		'EndRem 

		Delay 1000			

		EndButton.Enable()
	
					
		If Left(RunEXE,1)=Chr(34) Then 
			RunProcess(RunEXE , 1)
		Else
			RunProcess(Chr(34)+ RunEXE +Chr(34) , 1)
		EndIf 
		'AllowSetForegroundWindow(-1)
		ChangeDir(CDir)

		If Low(EXEOnly) <> "steam.exe" Then
			PrintF("Steam Program")
			ProgramStarted = True
		EndIf
		If SilentRunnerEnabled = False Then
			End
		EndIf 
		PrintF("StartProgram End")	
		
		Delay 5000
		
		If OriginWaitEnabled = True Then 
			'Detect Origin and delay by half a miniute
			Local ProcessList:TList = Null
			ProcessList = ListProcesses()
			For ProcessString:String = EachIn ProcessList
				If Low(ProcessString) = "origin.exe" Then 
					TextCtrl.AppendText("~n~n")	
					TextCtrl.AppendText("Detected Origin Running. Waiting extra 30 seconds for origin to start.~n")
					For k=1 To 30
						PhotonRunnerApp.Yield()
						TextCtrl.AppendText(k+"  ")	
						Delay 1000
					Next
					Exit
				EndIf 
			Next	
		Else
			If GameNode.StartWaitEnabled = True Then 
				TextCtrl.AppendText("~n~n")	
				TextCtrl.AppendText("Waiting for 30 seconds (Advanced setting for this game)~n")
				For k=1 To 30
					PhotonRunnerApp.Yield()
					TextCtrl.AppendText(k+"  ")	
					Delay 1000
				Next
			EndIf 
		EndIf 
		
		TextCtrl.AppendText("~n~n~n~n~n")	
		TextCtrl.AppendText("If you are seeing this window after your game has ended Then Game Manager has failed To detect the game finishing properly. ~n" + ..
		"Click 'Close PhotonRunner' to close GameManager, run any post-batch scripts set and unmount any game images if required.")
		TextCtrl.AppendText("~n~n~n")

		If RunnerButtonCloseOnly = False Then 
			If GameNode.GameRunnerAlwaysOn = False Then 
				Timer2.Start(3000)		
			EndIf
		EndIf
	End Method
	
	Function ExtractEXEDir:String(Dir:String)
		Local DirOnly:String = ""
		Dir = Replace(Dir,Chr(34),"")
		For a = 1 To Len(Dir)
			If Mid(Dir , a , 1) = "\" Or Mid(Dir , a , 1) = "/" Then
				If FileType(Left(Dir , a - 1) ) = 2 Then
					DirOnly = Left(Dir , a - 1)
				Else
					Exit 
				EndIf
			EndIf
		Next
		Return DirOnly
	End Function 

	Method SetGame(GN:String , EN:Int)
		ExtraWatchEXEs = CreateList()
		EXENum = EN
		GameNode = New GameReadType
		GameNode.GetGame(GN)

		If GameNode.Mounter = "None" Or GameNode.Mounter = "" Or EXENum > 1 Then
			MounterOFF = True 
		Else
			MounterOFF = False
			Mounter = New MounterReadType
			Mounter.GetMounter(GameNode.Mounter)
			Local MountString:String = Mounter.MountString
			Local UnMountString:String = Mounter.UnMountString
			Local MounterPath:String = Mounter.MounterPath
			
			Local VDriveNum:String = GameNode.VDriveNum
			Local Image:String = GameNode.DiscImage
			
			MountString = Replace(MountString , "[MounterPath]" , MounterPath)
			MountString = Replace(MountString , "[MounterNum]" , VDriveNum)
			MountString = Replace(MountString , "[GameISOPath]" , Image)
			
			UnMountString = Replace(UnMountString , "[MounterPath]" , MounterPath)
			UnMountString = Replace(UnMountString , "[MounterNum]" , VDriveNum)
			UnMountString = Replace(UnMountString , "[GameISOPath]" , Image)			
			
			MountCommand = MountString
			UnMountCommand = UnMountString
			
			If GameNode.UnMount = "Yes" Then
				UnMountOFF = False
			Else
				UnMountOFF = True
			EndIf 
		EndIf
		
		If EXENum > 1 Then
			BatchOFF = True		
		Else
			BatchOFF = False
			PreBatch = GameNode.PreBF
			PreBatchWait = GameNode.PreBFWait
			PrintF("PRe wait on")
			PostBatch = GameNode.PostBF				
			PostBatchWait = GameNode.PostBFWait
			PrintF("Post wait on")
		EndIf
		
		Local OEXE:Object[] = ListToArray(GameNode.OEXEs)
		
		If GameNode.Plat = "PC" Then 
			If EXENum = 1 Then
				RunEXE = GameNode.RunEXE
			Else
				If (EXENum - 2) > Len(OEXE) - 1 Then
					CustomRuntimeError("Error 110: EXENum out of bounds") 'MARK: Error 110
				Else
					RunEXE = String(OEXE[EXENum - 2])
				EndIf 
			EndIf 
		Else
			If EXENum = 1 Then
				If IsntNull(GameNode.EmuOverride) = True Then
					RunEXE = GameNode.EmuOverride
				Else
					RunEXE = GetEmulator(GameNode.Plat)
				EndIf						
				RunEXE = Replace(RunEXE , "[ROMPATH]" , GameNode.ROM)
				RunEXE = Replace(RunEXE , "[EXTRA-CMD]" , GameNode.ExtraCMD)

			Else
				If (EXENum - 2) > Len(OEXE) - 1 Then
					CustomRuntimeError("Error 110: EXENum out of bounds") 'MARK: Error 110
				Else
					RunEXE = String(OEXE[EXENum - 2])
				EndIf 
			EndIf 

		EndIf
		
		
		
		If Left(RunEXE,1)=Chr(34) Then 
			For a=2 To Len(RunEXE)
				If Mid(RunEXE,a,1)=Chr(34)
					
					EXEOnly=Mid(RunEXE,2,a-2)
					EXEOnly=StripDir(EXEOnly)
					Exit 
				EndIf
			Next			
				
		Else
			For a=1 To Len(RunEXE)
				If Mid(RunEXE,a,1)=" " Then 
					EXEOnly=Mid(RunEXE,1,a-1)
					EXEOnly=StripDir(EXEOnly)
					Exit 
				EndIf
			Next 
		EndIf
		
		
		
		For WatchEXEString:String = EachIn GameNode.WatchEXEs
			If FileType(WatchEXEString)=1 Then
				ListAddLast(Self.ExtraWatchEXEs,Low(StripDir(WatchEXEString)))
			EndIf 
			If FileType(WatchEXEString)=2 Then 
				GetEXEsFromFolder(WatchEXEString,Self.ExtraWatchEXEs)
			EndIf 
		Next
		
		
		?Win32
		ScreenShotPlugin = New ScreenShotPluginType
		ScreenShotPlugin.LoadPlugin(GN)
		
		PowerPlanPlugin = New PowerPlanPluginType
		PowerPlanPlugin.LoadPlugin(GN)		
		
		VideoPlugin = New VideoPluginType
		VideoPlugin.LoadPlugin(GN)		
		?	
		
		Local WatchEXEPrintString:String = "WatchEXEList: "
		For WatchEXEString:String = EachIn Self.ExtraWatchEXEs 
			WatchEXEPrintString = WatchEXEPrintString + WatchEXEString + ", "
		Next
		
		
		PrintF("PhotonRunner Given Following Data")
		PrintF("RunEXE: " + RunEXE)
		PrintF("EXEOnly: "+EXEOnly)
		PrintF("PreBatch: "+PreBatch)
		PrintF("PostBatch: "+PostBatch)
		PrintF("MountCommand: "+MountCommand)
		PrintF("UnMountCommand: "+UnMountCommand)
		PrintF(WatchEXEPrintString)
		PrintF("---------------------------------")
		
		
		Self.StartProgram()
	End Method 
End Type

Function GetEXEsFromFolder(Folder:String,List:TList)
	If Right(Folder,1)="\" Or Right(Folder,1)="/" Then
		Folder = Left(Folder,Len(Folder)-1)
	EndIf 
	Local Dir = ReadDir(Folder)
	Local File:String
	
	Repeat
		File = NextFile(Dir)
		If File="." Then Continue
		If File=".." Then Continue
		If File="" Then Exit
		If FileType(Folder+FolderSlash+File)=1 Then
			If ExtractExt(File)="exe" Then
				ListAddLast(List,Lower(File))
			EndIf 
		EndIf 
		If FileType(Folder+FolderSlash+File)=2 Then 
			GetEXEsFromFolder(Folder+FolderSlash+File,List)
		EndIf 
	Forever
	CloseDir(Dir)
End Function

Function Low:String(Text:String)
	Return Lower(Text)
End Function 

?Win32
Extern "win32"
	Function GetAsyncKeyState:Int(vKey:Int)
EndExtern
?

Type GlobalHotkey
	Field KeyNumber:Int = -1
	Field IsKeyDownList:TList = CreateList()
	
	Method SetKeyNumber(Number:Int)
		Self.KeyNumber = Number
	End Method 
	
	Method KeyDown()
		?Win32	
		If (GetAsyncKeyState:Int(Self.KeyNumber) And %1000000000000000) > 0 Then
			Return True
		Else
			Return False
		EndIf
		?Linux
		Return False	
		? 
	End Method
	
	Method KeyHit()
		?Win32	
		If (GetAsyncKeyState:Int(Self.KeyNumber) And %1000000000000000) > 0 Then
			If Self.IsKeyDownList.Contains(String(Self.KeyNumber)) Then
				Return False
			Else
				ListAddLast(Self.IsKeyDownList , String(Self.KeyNumber))
				Return True
			EndIf		
		Else
			If Self.IsKeyDownList.Contains(String(Self.KeyNumber)) Then
				Self.IsKeyDownList.Remove(String(Self.KeyNumber))	
			EndIf 
			Return False
		EndIf
		?Linux
		Return False
		? 
	End Method 
End Type


Type PowerPlanPluginType
	Field Enabled:Int 
	Field StartCommand:String
	Field EndCommand:String 
	
	Method LoadPlugin(GName:String)
		Local temp:String 
		Local ReadSettings:SettingsType = New SettingsType
		Local ReadSettings2:SettingsType = New SettingsType
		ReadSettings.ParseFile(APPFOLDER + "powerplan" + FolderSlash +"PM-CONFIG.xml" , "PluginSelection")
		If ReadSettings.GetSetting("enabled") = "Yes" Then
			Self.Enabled = True
			temp = ReadSettings.GetSetting("plugin")
			ReadSettings2.ParseFile(APPFOLDER + "powerplan"+ FolderSlash + temp + FolderSlash + "PM-CONFIG.xml" , "PluginConfig")
			Self.StartCommand = ReadSettings2.GetSetting("startPath")
			Self.EndCommand = ReadSettings2.GetSetting("endPath")
			
			Self.StartCommand = Replace(Self.StartCommand , "[POWERGUID]" , ReadSettings2.GetSetting("startGUID"))
			Self.EndCommand = Replace(Self.EndCommand , "[POWERGUID]" , ReadSettings2.GetSetting("endGUID"))
			ReadSettings2.CloseFile()
		Else
			Self.Enabled = False 
		EndIf
	End Method 
	
	Method ActivatePlugin(T:String)
		Select T
			Case "Start"
				RunProcess(StartCommand , 1)
			Case "End"
				RunProcess(EndCommand , 1)
		End Select 
	End Method 
End Type 


Type ScreenShotPluginType
	Field Enabled:Int 
	Field Command:String 
	Field Format:String
	Field Key:Int
	Field GameName:String
	
	Method LoadPlugin(GName:String)
		Local temp:String
		Local ReadSettings:SettingsType = New SettingsType
		Local ReadSettings2:SettingsType = New SettingsType
		Self.GameName = GName
		ReadSettings.ParseFile(APPFOLDER + "screenshots" + FolderSlash +"PM-CONFIG.xml" , "PluginSelection")
		If ReadSettings.GetSetting("enabled") = "Yes" Then
			Self.Enabled = True
			temp = ReadSettings.GetSetting("plugin")
			ReadSettings2.ParseFile(APPFOLDER + "screenshots"+FolderSlash + temp +FolderSlash+ "PM-CONFIG.xml" , "PluginConfig")
			Self.Command = ReadSettings2.GetSetting("path")
			Self.Format = ReadSettings2.GetSetting("format")
			Self.Command = Replace(Self.Command , "[CURRENTDIR]" , APPFOLDER + "screenshots"+FolderSlash + temp)
			Self.Command = Replace(Self.Command , "[FILENAME]" , TEMPFOLDER + "shot" + Self.Format )
			Self.Key = Int(ReadSettings2.GetSetting("key") )
			ReadSettings2.CloseFile()
		Else
			Self.Enabled = False 
		EndIf
		If Self.Key = 0 Then
			Self.Enabled = False
		EndIf 
		ReadSettings.CloseFile()
		If FileType(GAMEDATAFOLDER + Self.GameName +FolderSlash +"ScreenShots") <> 2 Then
			CreateDir(GAMEDATAFOLDER + Self.GameName + FolderSlash +"ScreenShots")
		EndIf
	End Method
	
	Method TakeScreenShot()
		Local ScreenProc:TProcess = CreateProcess(Self.Command , 1)
		Local StartTimer:Int = MilliSecs()
		Repeat
			If MilliSecs() - StartTimer > 2000 Then
				TerminateProcess(ScreenProc)
			EndIf 
			If ProcessStatus(ScreenProc) = 0 Then Exit
			Delay 10
		Forever
		Local Name:String = ScreenShotName(Self.GameName)
		Local NewMap:TPixmap = LoadPixmap(TEMPFOLDER + "shot" + Self.Format)
		
		If NewMap <> Null Then
			SavePixmapJPeg(NewMap , Name , 80)
		EndIf 	
		DeleteFile(TEMPFOLDER + "shot" + Self.Format)	
		PlaySound(Beep)
	End Method
	
	Function ScreenShotName$(Game$)
		Number=1
		Repeat
			If FileType(GAMEDATAFOLDER+Game+FolderSlash+"ScreenShots"+FolderSlash+"Shot"+Number+".jpg")=1 Then
				Number=Number+1
			Else
				Exit
			EndIf
		Forever
		Return GAMEDATAFOLDER+Game+FolderSlash+"ScreenShots"+FolderSlash+"Shot"+Number+".jpg"
	End Function	
End Type 

Type VideoPluginType
	Field Enabled:Int 
	Field Command:String 
	Field Format:String
	Field Key:Int
	Field GameName:String
	
	Method LoadPlugin(GName:String)
		Local temp:String
		Local ReadSettings:SettingsType = New SettingsType
		Local ReadSettings2:SettingsType = New SettingsType
		Self.GameName = GName
		ReadSettings.ParseFile(APPFOLDER + "video" + FolderSlash +"PM-CONFIG.xml" , "PluginSelection")
		If ReadSettings.GetSetting("enabled") = "Yes" Then
			Self.Enabled = True
			temp = ReadSettings.GetSetting("plugin")
			ReadSettings2.ParseFile(APPFOLDER + "video"+FolderSlash + temp +FolderSlash +"PM-CONFIG.xml" , "PluginConfig")
			Self.Command = ReadSettings2.GetSetting("capturepath")
			Self.Format = ReadSettings2.GetSetting("format")
			Self.Command = Replace(Self.Command , "[CURRENTDIR]" , APPFOLDER + "video"+FolderSlash + temp)
			'Self.Command = Replace(Self.Command , "[FILENAME]" , VideoName(GName , Self.Format))
			Self.Key = Int(ReadSettings2.GetSetting("key") )
			ReadSettings2.CloseFile()
		Else
			Self.Enabled = False 
		EndIf
		If Self.Key = 0 Then
			Self.Enabled = False
		EndIf 
		ReadSettings.CloseFile()
		If FileType(GAMEDATAFOLDER + Self.GameName + FolderSlash +"ScreenShots") <> 2 Then
			CreateDir(GAMEDATAFOLDER + Self.GameName + FolderSlash +"ScreenShots")
		EndIf
	End Method
	
	Method TakeScreenShot()
		Print WinDir + "\sysnative\cmd.exe /C "+Chr(34)+ Replace(Self.Command , "[FILENAME]" , Chr(34)+"C:\GameManagerV4"+"\"+VideoName(Self.GameName , Self.Format)+Chr(34))+Chr(34)
		
		Select WinBit
			Case 64		
				RunProcess(  WinDir + "\sysnative\cmd.exe /C "+Chr(34)+ Replace(Self.Command , "[FILENAME]" , Chr(34)+VideoName(Self.GameName , Self.Format)+Chr(34))+Chr(34) , 1)
			Case 32
				RunProcess(  WinDir + "\system32\cmd.exe /C "+Chr(34)+ Replace(Self.Command , "[FILENAME]" , Chr(34)+VideoName(Self.GameName , Self.Format)+Chr(34))+Chr(34) , 1)
		End Select 			
		PlaySound(Beep)
	End Method
	
	Function VideoName$(Game$,Format$)
		Number=1
		Repeat
			If FileType(GAMEDATAFOLDER+Game+FolderSlash+"ScreenShots"+FolderSlash+"Vid"+Number+Format)=1 Then
				Number=Number+1
			Else
				Exit
			EndIf
		Forever
		Return GAMEDATAFOLDER+Game+FolderSlash+"ScreenShots"+FolderSlash+"Vid"+Number+Format
	End Function	
End Type 

?Win32
Function GetSteamProcesses(p:TWinProc,List:TList)
	'Get all child processes of p and put them into List. This includes children of child processes etc.
	Local a:TWinProc
	If p.kids <> Null And CountList(p.kids) <> 0 Then 
		For a:TWinProc = EachIn p.kids
			ListAddLast(List,a.szExeFile)
			If a.kids <> Null And CountList(a.kids) <> 0 Then
				GetSteamProcesses(a,List)
			EndIf 
		Next
	EndIf 
End Function 
?

Function StripSteamProcesses:TList(ProcessList:TList)
	ListRemove(ProcessList,"GameOverlayUI.exe")
	ListRemove(ProcessList,"steamservice.exe")
	ListRemove(ProcessList,"steamerrorreporter.exe")	
	ListRemove(ProcessList,"steamerrorreporter64.exe")
	ListRemove(ProcessList,"SteamTmp.exe")
	ListRemove(ProcessList,"streaming_client.exe")
	ListRemove(ProcessList,"x64launcher.exe")
	ListRemove(ProcessList,"x86launcher.exe")
	
	'Fix for steam launching UPlay Games
	ListRemove(ProcessList,"uplay.exe")	

	Return ProcessList	
End Function