'Disabled Timer1

Function Thread_StartGame:Object(obj:Object)
	Local Runner:RunnerWindow = RunnerWindow(obj)
	PrintF("Start of StartGame Thread")
	
	Runner.TextCtrl.Clear()
	Runner.TextCtrl.AppendText("Loading...~n")
	If RunnerButtonCloseOnly = True then
		PrintF("Always ON Active (Global)")
		Runner.TextCtrl.AppendText("Auto Detect Game Closing: OFF (Global):~n")
	EndIf
	If Runner.GameNode.GameRunnerAlwaysOn = True
		PrintF("Always ON Active (This Game Only)")
		Runner.TextCtrl.AppendText("Auto Detect Game Closing: OFF (This Game Only):~n")
	EndIf
	Runner.EndButton.Disable()
	
	Local ExeProcess:TProcess
	
	Local CDir:String = StandardSlashes(CurrentDir() )
	PrintF("CWD: " + CDir)
	
	?Win32
	If Runner.PowerPlanPlugin.Enabled = True then
		Runner.TextCtrl.AppendText("Activating Power Plan~n")
		Runner.PowerPlanPlugin.ActivatePlugin("Start")
		PrintF("PowerPlan Started")
	EndIf
	?
		
	?Win32	
	If Runner.PreBatchOFF = False then
		PrintF("BF: " + Runner.PreBatchFolder )
		PrintF("Batching: " + Runner.PreBatch )
		ChangeDir(Runner.PreBatchFolder )
		If Runner.PreBatchWait = True then
			PrintF("Waiting for Batch to Complete")
			Runner.TextCtrl.AppendText("Activating Start Batch File And Waiting For It To Finish...~n")	
			ExeProcess = RunProcess(Runner.PreBatch, 0)
			
			Runner.EndButton.Enable()
			Runner.EndButton.SetLabel("Skip")			
			If ExeProcess = Null then
				PrintF("Batch Process NULL")
			Else
				Repeat
					If ProcessStatus(ExeProcess) = 0 then Exit
					Delay 100
					If SkipBatchWait = 1 then
						ProcessDetach(ExeProcess)
						Exit
					EndIf
				Forever
			EndIf
			SkipBatchWait = 0
			Runner.EndButton.Disable()
			Runner.EndButton.SetLabel("Close PhotonRunner")
		Else
			Runner.TextCtrl.AppendText("Activating Start Batch File...~n")	
			RunProcess(Runner.PreBatch, 1)
		EndIf
		
		ChangeDir(CDir)
		PrintF("Batch Complete")
	EndIf
	
	If Runner.MounterOFF = False then
		Runner.TextCtrl.AppendText("Mounting Disc Image...~n")	
		PrintF("MF: " + Runner.MountCommandFolder )
		PrintF("Mounting: " + Runner.MountCommand )
		ChangeDir(Runner.MountCommandFolder )
		RunProcess(Runner.MountCommand , 1)
		ChangeDir(CDir)
		Delay Runner.MountDelay
		PrintF("Mounter Complete")
	EndIf	
	?
	
	Rem
	Local hWnd:Byte Ptr = Self.GetHandle()
	OurThreadID = GetCurrentThreadId()
	
	Local ahwnd:Byte Ptr 
	CurrentThreadID = GetWindowThreadProcessId(GetForegroundWindow(), ahwnd)
	
	PrintF("Our Thread: "+OurThreadID)
	PrintF("Current Thread: "+CurrentThreadID)
	PrintF("Win: "+Int(hWnd))
	
	If OurThreadID<>CurrentThreadID Then 
		AttachThreadInput(OurThreadID,CurrentThreadID,True)
	EndIf
	
	SetForegroundWindow(Int(hWnd) )
	BringWindowToTop(Int(hWnd))
	'SetActiveWindow(hWnd)
	
	If OurThreadID<>CurrentThreadID Then 
		AttachThreadInput(OurThreadID,CurrentThreadID,False)
	EndIf 
	Delay(1000)
	EndRem	
	
	Delay(1000)
	
	PrintF("EF: " + Runner.RunEXEFolder )
	ChangeDir(Runner.RunEXEFolder )
	Runner.TextCtrl.AppendText("Running Program...~n")		
	PrintF("Running: " + Runner.RunEXE)
	RunProcess(Runner.RunEXE , 1)
	ChangeDir(CDir)
	Runner.EndButton.Enable()
	
	'If Low(Runner.EXEOnly) <> "steam.exe" then
	'	PrintF("Steam Program")
	'	Runner.ProgramStarted = True
	'EndIf
	
	If SilentRunnerEnabled = False then
		PrintF("SilentRunner not enabled. Closing...")
		End
	EndIf
	
	
	'Delay(5000)
	Local ProcessString:String
	Local Process:ProcessType
	
	Rem
	If OriginWaitEnabled = True then
		PrintF("Looking for origin")
		'Detect Origin and delay by half a miniute
		ListProcesses()
		For Process = EachIn MainProcessList.ProcessListHierarchical
			ProcessString = Process.Name
			If Low(ProcessString) = "origin.exe" then
				Runner.TextCtrl.AppendText("~n~n")	
				Runner.TextCtrl.AppendText("Detected Origin Running. Waiting extra 30 seconds for origin to start.~n")
				For k = 1 To 30
					Runner.TextCtrl.AppendText(k + "  ")	
					Delay(1000)
				Next
				Exit
			EndIf 
		Next	
	Else
		If Runner.GameNode.StartWaitEnabled = True then
			Runner.TextCtrl.AppendText("~n~n")	
			Runner.TextCtrl.AppendText("Waiting for 30 seconds (Advanced setting for this game)~n")
			For k=1 To 30
				Runner.TextCtrl.AppendText(k + "  ")	
				Delay(1000)
			Next
		EndIf
	EndIf 
	EndRem
	
	Runner.TextCtrl.AppendText("~n~n~n~n~n")	
	Runner.TextCtrl.AppendText("If you are seeing this window after your game has ended Then Photon has failed To detect the game finishing properly. ~n" + ..
	"Click 'Close PhotonRunner' to close Photon, run any post-batch scripts set and unmount any game images if required.")
	Runner.TextCtrl.AppendText("~n~n~n")
	
	PrintF("StartGame Thread End")	
End Function

Function Thread_FinishGame:Object(obj:Object)
	Local Runner:RunnerWindow = RunnerWindow(obj)
	If FinishProgramRunning = 0 then
		FinishProgramRunning = 1
		Runner.TextCtrl.AppendText("~n~n~n~n~n")
		Runner.TextCtrl.AppendText("Program Closing...~n")
		Runner.EndButton.Disable()
							
		Local Process:Tprocess 
		PrintF("FinishGame Thread")
		?Win32 
		If Runner.PowerPlanPlugin.Enabled = True then
			Runner.PowerPlanPlugin.ActivatePlugin("End")
			Runner.TextCtrl.AppendText("Activating End PowerPlan...~n")
		EndIf 	
		Local CDir:String = StandardSlashes(CurrentDir() )
		PrintF("CWD: " + CDir)	
					
		If Runner.PostBatchOFF = False then
			PrintF("BF: " + Runner.PostBatchFolder )
			PrintF("Batching: " + Runner.PostBatch )
			ChangeDir(Runner.PostBatchFolder)			
	
			If Runner.PostBatchWait = True then
				Process = RunProcess(Runner.PostBatch, 0)
				Runner.TextCtrl.AppendText("Activating End Batch File And Waiting For It To Finish...~n")	
				
				If Process = Null then
					PrintF("Batch Process NULL")
				Else
					PrintF("Waiting for Batch to Complete")
					Runner.EndButton.Enable()
					Runner.EndButton.SetLabel("Skip")
					Repeat 
	 
						If ProcessStatus(Process)=0 Then Exit 
						Delay 100
						If SkipBatchWait = 1 Then 
							ProcessDetach(Process)
							Exit 
						EndIf 
					Forever
				EndIf
				SkipBatchWait = 0
				Runner.EndButton.Disable()
				Runner.EndButton.SetLabel("Close PhotonRunner")							
			Else
				Runner.TextCtrl.AppendText("Activating End Batch File...~n")
				RunProcess(Runner.PostBatch, 1)
			EndIf
			ChangeDir(CDir)
			PrintF("Batch Complete")
		EndIf
		If Runner.MounterOFF = False And Runner.UnMountOFF = False then
			Runner.TextCtrl.AppendText("Unmounting Disc Images...~n")
			PrintF("MF: " + Runner.UnMountCommandFolder)
			PrintF("Mounting: " + Runner.UnMountCommand)
			ChangeDir(Runner.UnMountCommandFolder)
			RunProcess(Runner.UnMountCommand , 1)
			ChangeDir(CDir)
			PrintF("Mounter Complete")
		EndIf
		?
		
		If CabinateEnable then
			Select CmdLineCabinate
				Case 0
					PrintF("No Cabinate")
				Case 1
					PrintF("FrontEnd Cabinate")
					Runner.TextCtrl.AppendText("Loading FrontEnd~n")
					RunProcess(FRONTENDPROGRAM + " -Wait 1000 -ForceFront 1", 1)
				Case 2
					PrintF("Explorer Cabinate")
					Runner.TextCtrl.AppendText("Loading Explorer~n")
					RunProcess(EXPLORERPROGRAM, 1)	
				Default 
					CustomRuntimeError("Error: Incorrect Cabinate mode in Photon Runner")
			End Select
		Else
			PrintF("CabinateEnabled = false")
		EndIf
		
		PrintF("FinishGame Thread End")
	EndIf
End Function


Type RunnerDebugWindow Extends wxFrame
	Field ProcessList:wxTreeListCtrl
	Field LogList:wxTextCtrl
	Field WatchEXEList:wxListCtrl
	Field MainWin:RunnerWindow
	Field EXEList:TList
	
	Field InactiveEXEList:TList
	
	Field GreenColour:wxColour
	Field RedColour:wxColour
	
	Method OnInit()	
		MainWin = RunnerWindow(GetParent() )
		
		Self.GreenColour = New wxColour.Create(190, 255, 190)
		Self.RedColour = New wxColour.Create(255, 190, 190)
		
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local subvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Self.SetBackgroundColour(New wxColour.Create(PRRed, PRGreen, PRBlue) )
		
		ProcessList = New wxTreeListCtrl.Create(Self, wxID_ANY, - 1, - 1, - 1, - 1, wxTR_HAS_BUTTONS | wxTR_FULL_ROW_HIGHLIGHT | wxTR_HIDE_ROOT)
		Self.ProcessList.AddColumn("Processes", 350, wxALIGN_LEFT)
		Self.ProcessList.SetColumnEditable(0, True)
		Local Root:wxTreeItemId = Self.ProcessList.AddRoot("Processes")
		
		LogList = New wxTextCtrl.Create(Self, wxID_ANY, "", - 1, - 1, - 1, - 1, wxTE_MULTILINE | wxTE_READONLY)
		LogList.AppendText("This window is open because you are in debug mode. Turn debug mode off to stop this window appearing~n")
		LogList.AppendText("Logging debug information...~n~n")		
		
		WatchEXEList = New wxListCtrl.Create(Self, wxID_ANY, - 1, - 1, - 1, - 1, wxLC_REPORT)
		WatchEXEList.InsertColumn(0, "Watch List")
		WatchEXEList.SetColumnWidth(0, 350)

		subvbox.Add(ProcessList, 2, wxEXPAND, 0)
		subvbox.Add(WatchEXEList, 1, wxEXPAND, 0)
		
		hbox.AddSizer(subvbox, 1, wxEXPAND, 0)
		hbox.Add(LogList, 1, wxEXPAND, 0)
		
		Local item:Int
		
		'item = WatchEXEList.InsertStringItem(WatchEXEList.GetItemCount(), "Steam.exe")
		'item = WatchEXEList.InsertStringItem(WatchEXEList.GetItemCount(), "ASSASSIN.exe")
		'WatchEXEList.SetItemBackgroundColour(item, New wxColour.Create(255, 0, 0) )
		
		Self.SetSizer(hbox)
		Self.Show(1)
		
	End Method
	
	Method LoadInEXEs()
		Self.EXEList = CreateList()
		If MainWin.EXEOnly = "steam.exe" then
		
		Else
			ListAddLast(Self.EXEList, MainWin.EXEOnly )
		EndIf
		Local EXE:String
		For EXE = EachIn MainWin.ExtraWatchEXEs
			ListAddLast(Self.EXEList, Low(EXE) )
		Next
	End Method
	
	Method UpdateEXEs()
		Local EXE:String	
		For EXE = EachIn MainWin.ExtraWatchEXEs
			If ListContains(Self.EXEList, Low(EXE) ) then
			
			Else
				ListAddLast(Self.EXEList, Low(EXE) )
			EndIf
		Next		
	End Method
	
	Method UpdateTreeMain()
		UpdateEXEs()
		Local EXE:String, Item:Int
		Self.ProcessList.Disable()
		Self.ProcessList.DeleteRoot()
		Local Root:wxTreeItemId = Self.ProcessList.AddRoot("Processes")
		Self.InactiveEXEList = EXEList.Copy()
		Self.UpdateTree(Self.ProcessList, Root, MainProcessList.ProcessListHierarchical)
		Self.ProcessList.ExpandAll(Root)
		
		Self.WatchEXEList.DeleteAllItems()
		For EXE = EachIn Self.EXEList
			Item = Self.WatchEXEList.InsertStringItem(WatchEXEList.GetItemCount(), EXE)
			If ListContains(Self.InactiveEXEList, EXE ) then
				Self.WatchEXEList.SetItemBackgroundColour(Item, Self.RedColour )
			Else
				Self.WatchEXEList.SetItemBackgroundColour(Item, Self.GreenColour )
			EndIf
		Next
		Self.ProcessList.Enable()
	End Method
	
	Method UpdateTree(Tree:wxTreeListCtrl, Node:wxTreeItemId, List:TList)
		Local P:ProcessType
		Local Item:wxTreeItemId
		
		For P = EachIn List
			Item = Tree.AppendItem(Node, P.Name)
			If ListContains(Self.EXEList, Low(P.Name) ) then
				Tree.SetItemBackgroundColour(Item, Self.GreenColour)
				If ListContains(Self.InactiveEXEList, Low(P.Name) ) then
					ListRemove(Self.InactiveEXEList, Low(P.Name) )
				EndIf
			EndIf
			Self.UpdateTree(Tree, Item, P.Children)
		Next
	End Method 	
	
End Type




Type RunnerWindow Extends wxFrame
	Field GameNode:GameReadType
	Field EXENum:int
	Field Mounter:MounterReadType
	

	
	Field RunEXE:String
	Field RunEXEFolder:String
	Field EXEOnly:String
	
	
	Field PreBatchOFF:int
	Field PreBatch:String
	Field PreBatchFolder:String
	Field PreBatchWait:int
	
	Field PostBatchOFF:int 
	Field PostBatch:String
	Field PostBatchFolder:String
	Field PostBatchWait:int

	Field MounterOFF:int
	Field UnMountOFF:int
	Field MountCommand:String
	Field MountCommandFolder:String
	Field UnMountCommand:String
	Field UnMountCommandFolder:String
	Field MountDelay:int
	
	
	
	Global ScreenShotPlugin:ScreenShotPluginType
	Global PowerPlanPlugin:PowerPlanPluginType
	Global VideoPlugin:VideoPluginType
	
	Field Timer:wxTimer
	Field Timer2:wxTimer
	
	Field StartProgramTimer:wxTimer
	'Field KeyTimer:wxTimer
	Field ProgramStarted:int = - 1
	
	Field SteamProcessList:TList 
	Field ExtraWatchEXEs:TList
	
	Field TextCtrl:wxTextCtrl
	Field EndButton:wxButton
	
	Field RunnerDebug:RunnerDebugWindow
	Field RunnerDebugEnabled:int = False
	
	Method OnInit()
		If DebugLogEnabled = True then
			RunnerDebugEnabled = True
		EndIf
		?Debug
			RunnerDebugEnabled = True
		?
	
		If RunnerDebugEnabled = True
			RunnerDebug = RunnerDebugWindow(New RunnerDebugWindow.Create(Self , wxID_ANY , "PhotonRunnerDebug" , - 1 , - 1 , 800 , 500) )
		EndIf
	
		Self.SetBackgroundColour(New wxColour.Create(PRRed, PRGreen, PRBlue) )	
		FinishProgramRunning = 0
		Local Vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON2,wxBITMAP_TYPE_ICO)
		Self.SetIcon(Icon)
		Timer = New wxTimer.Create(Self, PR_T)
		Timer2 = New wxTimer.Create(Self, PR_T2)
		StartProgramTimer = New wxTimer.Create(Self, PR_SPT)
		'KeyTimer = New wxTimer.Create(Self,PR_KT)
		
		'Timer.Start(100)

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
		Connect(PR_T , wxEVT_TIMER , PluginUpdateFun)	
		?
		Connect(PR_T2 , wxEVT_TIMER , StatusUpdateFun)	
					
		Connect(PR_SPT, wxEVT_TIMER, StartProgramFun)
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
	
	Function PluginUpdateFun(event:wxEvent)	
		PhotonRunnerApp.Yield()
		If ScreenShotPlugin.Enabled = True then
			HotKey.SetKeyNumber(ScreenShotPlugin.Key)
			If HotKey.KeyHit() then
				ScreenShotPlugin.TakeScreenShot()
			EndIf 		
		EndIf 
		If VideoPlugin.Enabled = True then
			HotKey.SetKeyNumber(VideoPlugin.Key)
			If HotKey.KeyHit() Then 
				VideoPlugin.TakeScreenShot()
			EndIf 		
		EndIf 		


	End Function
	
	Function NullPluginUpdateFun(event:wxEvent)	
		Local MainWin:RunnerWindow = RunnerWindow(event.parent)
		MainWin.Timer.Stop()	
	End Function
	
	Function NullStatusUpdateFun(event:wxEvent)
		Local MainWin:RunnerWindow = RunnerWindow(event.parent)
		MainWin.Timer2.Stop()
	End Function
	
	Method StatusUpdate()
		Local Process:ProcessType, Process2:ProcessType
		Local RunningProcessCount:Int = 0
		ListProcesses()
		
		If Self.RunnerDebugEnabled = True then
			Self.RunnerDebug.UpdateTreeMain()
		EndIf		
		
		Select Self.EXEOnly
			Case "steam.exe"
				Select Self.ProgramStarted
					Case - 1
						'Loop through all processes and see if it matches any in our watch list
						For Process = EachIn MainProcessList.ProcessListAll
							If ListContains(Self.ExtraWatchEXEs, Low(Process.Name) ) then
								If Self.ProgramStarted = 1 then
								
								Else
									Self.ProgramStarted = 1
									If RunnerDebugEnabled = True then
										RunnerDebug.LogList.AppendText(CurrentTime() + ": Program Detected as RUNNING (" + Process.Name + ")~n")	
									EndIf
								EndIf
							EndIf
							If Low(Process.Name) = Self.EXEOnly then
								For Process2 = EachIn Process.GetAllChildren()
									If ListContains(Self.ExtraWatchEXEs, Low(Process2.Name) ) then
									
									Else
										If OnExcludeList(Low(Process2.Name) ) = False then
											ListAddLast(Self.ExtraWatchEXEs, Low(Process2.Name) )
											If RunnerDebugEnabled = True then
												RunnerDebug.LogList.AppendText(CurrentTime() + ": Added " + Process2.Name + " (Child of " + Process.Name + ") to watch list~n")
											EndIf
										EndIf
									EndIf
								Next
							EndIf
						Next
					Case 1
						RunningProcessCount = 0
						For Process = EachIn MainProcessList.ProcessListAll
							If ListContains(Self.ExtraWatchEXEs, Low(Process.Name) ) then
								RunningProcessCount = RunningProcessCount + 1
								For Process2 = EachIn Process.GetAllChildren()
									If ListContains(Self.ExtraWatchEXEs, Low(Process2.Name) ) then
									
									Else
										ListAddLast(Self.ExtraWatchEXEs, Low(Process2.Name) )
										If RunnerDebugEnabled = True then
											RunnerDebug.LogList.AppendText(CurrentTime() + ": Added " + Process2.Name + " (Child of " + Process.Name + ") to watch list~n")
										EndIf
									EndIf
								Next
							EndIf
							If Low(Process.Name) = Self.EXEOnly then
								For Process2 = EachIn Process.GetAllChildren()
									If ListContains(Self.ExtraWatchEXEs, Low(Process2.Name) ) then
									
									Else
										If OnExcludeList(Low(Process2.Name) ) = False then
											ListAddLast(Self.ExtraWatchEXEs, Low(Process2.Name) )
											If RunnerDebugEnabled = True then
												RunnerDebug.LogList.AppendText(CurrentTime() + ": Added " + Process2.Name + " (Child of " + Process.Name + ") to watch list~n")
											EndIf
										EndIf
									EndIf
								Next
							EndIf																				
						Next
						
						If RunningProcessCount = 0 then
							If RunnerDebugEnabled = True then
								RunnerDebug.LogList.AppendText(CurrentTime() + ": Program Detected as FINISHED ~n")	
							EndIf
							Self.ProgramStarted = 0
							Self.FinishProgram()
						EndIf
					Case 0
						
					Default
						CustomRuntimeError("StatusUpdate Error: Invalid Program State")
				End Select
			Default
				Select Self.ProgramStarted
					Case - 1
						'Loop through all processes and see if it matches any in our watch list+ runEXE
						For Process = EachIn MainProcessList.ProcessListAll
							If ListContains(Self.ExtraWatchEXEs, Low(Process.Name) ) Or Low(Process.Name) = Self.EXEOnly then
								Self.ProgramStarted = 1
								If RunnerDebugEnabled = True then
									RunnerDebug.LogList.AppendText(CurrentTime() + ": Program Detected as RUNNING (" + Process.Name + ")~n")	
								EndIf
							EndIf
						Next
					Case 1
						RunningProcessCount = 0
						For Process = EachIn MainProcessList.ProcessListAll
							If ListContains(Self.ExtraWatchEXEs, Low(Process.Name) ) Or Low(Process.Name) = Self.EXEOnly then
								RunningProcessCount = RunningProcessCount + 1
								For Process2 = EachIn Process.GetAllChildren()
									If ListContains(Self.ExtraWatchEXEs, Low(Process2.Name) ) then
									
									Else
										ListAddLast(Self.ExtraWatchEXEs, Low(Process2.Name) )
										If RunnerDebugEnabled = True then
											RunnerDebug.LogList.AppendText(CurrentTime() + ": Added " + Process2.Name + " (Child of " + Process.Name + ") to watch list~n")
										EndIf
									EndIf
								Next
							EndIf						
						Next
						
						If RunningProcessCount = 0 then
							If RunnerDebugEnabled = True then
								RunnerDebug.LogList.AppendText(CurrentTime() + ": Program Detected as FINISHED ~n")	
							EndIf
							Self.ProgramStarted = 0
							Self.FinishProgram()
						EndIf
					Case 0
						'Do Nothing
					Default
						CustomRuntimeError("StatusUpdate Error: Invalid Program State")
				End Select
			End Select
	End Method
	
	Function StatusUpdateFun(event:wxEvent)
		Local MainWin:RunnerWindow = RunnerWindow(event.parent)
		PrintF("Running Status Update")
		MainWin.Timer2.Stop()
		MainWin.StatusUpdate()
		MainWin.Timer2.Start(2000)
		
		
		
		
		Rem - Rem'ed while testing debug window
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
		
		If MainWin.ProgramStarted = True then
			
			If Lower(MainWin.EXEOnly) = "steam.exe" Then
				TWinProc.GetProcesses()
				p = TWinProc.Find("Steam.exe", TWinProc._list)
				
				SteamProcessList = CreateList()
				GetSteamProcesses(p, SteamProcessList)
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
						If ListContains(MainWin.ExtraWatchEXEs, Low(Process) ) then
							Running = True 
							Exit
						EndIf
					Next
				EndIf

				ClearList(SteamProcessList)					
				
			Else
				ProcessList = ListProcesses()
				For Process:String = EachIn ProcessList
					If Lower(Process) = Lower(MainWin.EXEOnly) Or ListContains(MainWin.ExtraWatchEXEs, Low(Process) ) then
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
		EndRem
	End Function 

	Method FinishProgram()
		Local GameFinishThread:TThread
		Timer.Stop()
		
		'Connect Timer2 to Null Function that should stop timer
		Connect(PR_T2 , wxEVT_TIMER , NullStatusUpdateFun)	
		'Connect Timer to Null Function that should stop timer
		Connect(PR_T , wxEVT_TIMER , NullPluginUpdateFun)	
		
		If RunnerDebugEnabled = True then
			RunnerDebug.LogList.AppendText(CurrentTime() + ": Finish Program Triggered~n")
		EndIf
		
		
		?Threaded
		GameFinishThread = CreateThread(Thread_FinishGame, Self)
		While GameFinishThread.Running()
			PhotonRunnerApp.Yield()
			Delay 50
		Wend
		?Not Threaded
		Thread_FinishGame(Self)
		?	

		If RunnerDebugEnabled = True then
			RunnerDebug.LogList.AppendText(CurrentTime() + ": Program Ended~n")
			RunnerDebug.LogList.AppendText("~nClose window manually when ready~n")
		Else
			End			
		EndIf		
		'Program terminates here unless debug enabled
	End Method
	
	Function StartProgramFun(event:wxEvent)
		'Function triggered by one off timer, which is set in SetGame
		Local Runner:RunnerWindow = RunnerWindow(event.parent)	
		Local GameStartThread:TThread
		If Runner.RunnerDebugEnabled = True then
			Runner.RunnerDebug.LogList.AppendText(CurrentTime() + ": Start Program Triggered~n")
		EndIf
		
		
		?Threaded
		GameStartThread = CreateThread(Thread_StartGame, Runner)
		While GameStartThread.Running()
			PhotonRunnerApp.Yield()
			Delay 50
		Wend
		?Not Threaded
		Thread_StartGame(Runner)
		?	
		If RunnerButtonCloseOnly = False then
			If Runner.GameNode.GameRunnerAlwaysOn = False then
				Runner.Timer2.Start(2000)		
			EndIf
		EndIf	
		If Runner.RunnerDebugEnabled = True then
			Runner.RunnerDebug.LogList.AppendText(CurrentTime() + ": Start Program Finished~n")
		EndIf		
	End Function
	
	Method SetGame(GN:String , EN:Int)
		ExtraWatchEXEs = CreateList()
		EXENum = EN
		GameNode = New GameReadType
		If GameNode.GetGame(GN) = - 1 then
			Notify "Could Not Get Game"
			End
		EndIf
		
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
			
			Self.MountCommand = MountString
			Self.MountCommandFolder = ExtractEXEDir(Self.MountCommand)
			Self.UnMountCommand = UnMountString
			Self.UnMountCommandFolder = ExtractEXEDir(Self.UnMountCommand)
			Self.MountDelay = Mounter.MounterDelay
						
			If GameNode.UnMount = "Yes" then
				UnMountOFF = False
			Else
				UnMountOFF = True
			EndIf 
		EndIf
		
		If EXENum > 1 then
			PreBatchOFF = True		
			PostBatchOFF = True
		Else
			PreBatchOFF = False 	
			PostBatchOFF = False
			PreBatch = GameNode.PreBF
			PreBatchFolder = ExtractEXEDir(PreBatch)
			PreBatchWait = GameNode.PreBFWait
			If PreBatch = "" then
				PreBatchOFF = True
				PrintF("PreBatch OFF")
			Else
				PrintF("PreBatch ON")
				If Left(PreBatch, 1) = Chr(34) then
					
				Else
					PreBatch = Chr(34) + PreBatch + Chr(34)
				EndIf
			EndIf
			
			
			PostBatch = GameNode.PostBF		
			PostBatchFolder = ExtractEXEDir(PostBatch)
			PostBatchWait = GameNode.PostBFWait
			If PostBatch = "" then
				PostBatchOFF = True
				PrintF("PostBatch OFF")
			Else
				PrintF("PostBatch ON")
				If Left(PostBatch, 1) = Chr(34) then
					
				Else
					PostBatch = Chr(34) + PostBatch + Chr(34)
				EndIf				
			EndIf
		EndIf
		
		Local OEXE:Object[] = ListToArray(GameNode.OEXEs)
		
		If GlobalPlatforms.GetPlatformByID(GameNode.PlatformNum).PlatType = "Folder" then
			If EXENum = 1 then
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
				If (EXENum - 2) > Len(OEXE) - 1 then
					CustomRuntimeError("Error 110: EXENum out of bounds") 'MARK: Error 110
				Else
					RunEXE = String(OEXE[EXENum - 2])
				EndIf 
			EndIf 

		EndIf
		
		If Left(RunEXE, 1) = Chr(34) then

		Else
			RunEXE = Chr(34) + RunEXE + Chr(34)
		EndIf
		
		For a = 2 To Len(RunEXE)
			If Mid(RunEXE,a,1)=Chr(34)
				EXEOnly=Mid(RunEXE,2,a-2)
				EXEOnly=StripDir(EXEOnly)
				Exit 
			EndIf
		Next		
					
		EXEOnly = Low(EXEOnly)
		
		RunEXEFolder = ExtractEXEDir(RunEXE)
		
		For WatchEXEString:String = EachIn GameNode.WatchEXEs
			If FileType(WatchEXEString) = 1 then
				ListAddLast(Self.ExtraWatchEXEs, Low(StripDir(WatchEXEString) ) )
			EndIf
			If FileType(WatchEXEString)=2 Then 
				GetEXEsFromFolder(WatchEXEString, Self.ExtraWatchEXEs)
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
		PrintF("EXEOnly: " + EXEOnly)
		PrintF("PreBatch: " + PreBatch)
		PrintF("PostBatch: "+PostBatch)
		PrintF("MountCommand: "+MountCommand)
		PrintF("UnMountCommand: "+UnMountCommand)
		PrintF(WatchEXEPrintString)
		PrintF("---------------------------------")
		
		If Self.RunnerDebugEnabled = True then
			Self.RunnerDebug.LoadInEXEs()
		EndIf
		
		'Use Timer to prevent event queue clog at startup
		Self.StartProgramTimer.Start(1000, True)
	End Method
End Type

Function GetEXEsFromFolder(Folder:String, List:TList)
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
		Number = 1
		Repeat
			If FileType(GAMEDATAFOLDER+Game+FolderSlash+"ScreenShots"+FolderSlash+"Vid"+Number+Format)=1 Then
				Number=Number+1
			Else
				Exit
			EndIf
		Forever
		Return GAMEDATAFOLDER + Game + FolderSlash + "ScreenShots" + FolderSlash + "Vid" + Number + Format
	End Function	
End Type

Rem
?Win32
Function GetSteamProcesses(p:TWinProc, List:TList)
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
EndRem

Function ExtractEXEDir:String(Dir:String)
	Local DirOnly:String = ""
	Dir = Replace(Dir,Chr(34),"")
	For a = 1 To Len(Dir)
		If Mid(Dir , a , 1) = "\" Or Mid(Dir , a , 1) = "/" Then
			If FileType(Left(Dir , a - 1) ) = 2 then
				DirOnly = Left(Dir , a - 1)
			Else
				Exit
			EndIf
		EndIf
	Next
	Return DirOnly
End Function 

'Returns true if EXE should be excluded
Function OnExcludeList(EXE:String)
	If EXE = "gameoverlayui.exe" then Return 1
	If EXE = "steamservice.exe" then Return 1
	If EXE = "steamerrorreporter.exe" then Return 1
	If EXE = "steamerrorreporter64.exe" then Return 1
	If EXE = "Steamtmp.exe" then Return 1
	If EXE = "streaming_client.exe" then Return 1
	If EXE = "x64launcher.exe" then Return 1
	If EXE = "x86launcher.exe" then Return 1
	If EXE = "steamwebhelper.exe" then Return 1
	
	If EXE = "uplay.exe" then Return 1
	
	Return 0
End Function
Rem
Function StripSteamProcesses:TList(ProcessList:TList)
	ListRemove(ProcessList, "GameOverlayUI.exe")
	ListRemove(ProcessList,"steamservice.exe")
	ListRemove(ProcessList,"steamerrorreporter.exe")	
	ListRemove(ProcessList,"steamerrorreporter64.exe")
	ListRemove(ProcessList, "SteamTmp.exe")
	ListRemove(ProcessList,"streaming_client.exe")
	ListRemove(ProcessList, "x64launcher.exe")
	ListRemove(ProcessList,"x86launcher.exe")
	
	'Fix for steam launching UPlay Games
	ListRemove(ProcessList, "uplay.exe")	

	Return ProcessList	
End Function
EndRem