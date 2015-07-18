
Framework wx.wxApp
Import wx.wxFrame
Import wx.wxStaticText
Import wx.wxProgressDialog
Import wx.wxTimer
Import wx.wxMessageDialog
Import wx.wxPanel

Import BRL.StandardIO
Import BRL.FileSystem
Import BRL.Stream
Import BRL.System
Import BRL.Retro
Import brl.threads
Import brl.pixmap
Import brl.pngloader

Import Pub.FreeProcess


Import Bah.Volumes
Import BaH.libcurlssl
Import bah.libxml
Import bah.regex

?Linux
Global FolderSlash:String = "/"

?Win32
Import "..\Icons\PhotonUpdater.o"
Global FolderSlash:String = "\"

?

Include "Includes\General\StartupOverrideCheck.bmx"
Local TempFolderPath:String = OverrideCheck(FolderSlash)

Include "Includes\General\GlobalConsts.bmx"
Include "Includes\Update\GlobalConsts.bmx"

' Revision Version Generation Code
' @bmk include Includes/General/Increment.bmk
' @bmk doOverallVersionFiles Version/OverallVersion.txt
?Win32
' @bmk doIncrement Version/PU-Version.txt 1
?Mac
' @bmk doIncrement Version/PU-Version.txt 2
?Linux
' @bmk doIncrement Version/PU-Version.txt 3
?
Incbin "Version/PU-Version.txt"
Incbin "Version/OverallVersion.txt"

SubVersion = ExtractSubVersion(LoadText("incbin::Version/PU-Version.txt"), 1)
OSubVersion = ExtractSubVersion(LoadText("incbin::Version/OverallVersion.txt"), 1)

Print "Version = " + CurrentVersion
Print "SubVersion = " + SubVersion
Print "OSubVersion = " + OSubVersion

DebugCheck()
FolderCheck()

LogName = "Log-Updater" + CurrentDate() + " " + Replace(CurrentTime(), ":", "-") + ".txt"
CreateFile(LOGFOLDER + LogName)

AppTitle = "PhotonDownloader"

If DebugLogEnabled = False Then
	DeleteFile(LOGFOLDER + LogName)
EndIf

Global BetaDownload = False

If Debug = True Or FileType("BetaDownloads.txt") = 1 then
	BetaDownload = True
EndIf

DownloaderApp = New DownloaderShell
DownloaderApp.Run()



Type DownloaderShell Extends wxApp
	Field Dialog:DownloaderDialog
	Field Splash:SplashFrame
	Field Timer2:wxTimer
	Field Timer3:wxTimer
	
	Method OnInit:Int()
		wxImage.AddHandler( New wxICOHandler)	
		
		Splash = SplashFrame(New SplashFrame.Create(Null, wxID_ANY, "Photon Loading...", - 1, - 1, 600, 225, 0) )	
		Local Timer:wxTimer = New wxTimer.Create(Self, DS_T1)
		Timer.Start(3000, 1)
		Connect(DS_T1, wxEVT_TIMER, StartupFun)	
		
		Timer2 = New wxTimer.Create(Self, DS_T2)
		Connect(DS_T2, wxEVT_TIMER, OnTick)
		
		Timer3 = New wxTimer.Create(Self, DS_T3)
		Connect(DS_T3, wxEVT_TIMER, UpdateDialog)

		Return True

	End Method
	
	Function UpdateDialog(event:wxEvent)
		Local Down:DownloaderShell = DownloaderShell(event.parent)
		Down.Dialog.Update()
	End Function
	
	Function StartupFun(event:wxEvent)
		Local Down:DownloaderShell = DownloaderShell(event.parent)
		
		Down.Splash.Destroy()
		Down.Yield()
		Down.Startup()
	End Function
	
	Method Startup()
		Local MessageBox:wxMessageDialog	
		Dialog = DownloaderDialog(New DownloaderDialog.Create("Updating..." , "", 101, Null, wxPD_APP_MODAL | wxPD_ELAPSED_TIME | wxPD_ESTIMATED_TIME | wxPD_SMOOTH | wxPD_CAN_ABORT) )
		Dialog.SetDimensions(0, 0, 600, 200)
		Dialog.Center()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Dialog.SetIcon( Icon )	
		Dialog.Update()
		Timer2.Start(10)
		Timer3.Start(100)
		
		If FileType(SevenZipPath) <> 1 Then
			MessageBox = New wxMessageDialog.Create(Null , "Error 202: 7zip plugin missing, please reinstall GameManager" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	 		
			Message = "7zip plugin missing, update failed"
			Dialog.UpdateProgress(101 , Message , a)
			Return
		EndIf
		
		If CheckInternet() = 0 Then  
			MessageBox = New wxMessageDialog.Create(Null , "Error 203: You are not connected to the internet or PhotonGameManager.com is offline." , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()	 		
			Message = "No connection, update failed"
			Dialog.UpdateProgress(101 , Message , a)
			Return
		EndIf		
		
		?Threaded
		Local UpdateThread:TThread = CreateThread(Thread_Update, Self)
		While UpdateThread.Running()
			Self.Yield()
			Delay 50
		Wend
		?Not Threaded
		Thread_Update(Self)
		?	
	End Method
	
	Function OnTick(event:wxEvent)
		Local Main:DownloaderShell = DownloaderShell(event.parent)
		If Main.Dialog.IsShown() = 0 Then
			End
		EndIf
	End Function
	
End Type


Function Thread_Update:Object(obj:Object)
	
		Local Main:DownloaderShell = DownloaderShell(obj)
		Local MessageBox:wxMessageDialog	
		Local a:Int
		Local Success:String
		
		If FileType("TempUpdater.bat") = 1 Then
			DeleteFile("TempUpdater.bat")
		EndIf

		
		Message = "Getting Update Package Details"
?Threaded		
		LockMutex(DialogMutex)
?
		DialogText = Message
		DialogPulse = 1
?Threaded			
		UnlockMutex(DialogMutex)
?		
		Local CurrentVersion:String
		If FileType("Version.txt") <> 1 Then 
			CurrentVersion = "V4." + OSubVersion
		Else
			Local v:TStream = ReadFile("Version.txt")
			CurrentVersion = ReadLine(v)
			CloseFile(v)
		EndIf
		
		Local Line:String
		Local Version:String 
		Local Online:String
		Local Important:String
		Local Package:String
		Local Beta:String
		
		
		Local curl:TCurlEasy
		
		Local TFile:TStream = WriteFile(TEMPFOLDER + "UpdateInfo.txt")
		curl = TCurlEasy.Create()
		'curl.setOptString(CURLOPT_POSTFIELDS, "")
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
		curl.setOptInt(CURLOPT_HEADER, 0)
		curl.setWriteStream(TFile)
		curl.setProgressCallback(progressCallback)
		curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
		?Win32
		curl.setOptString(CURLOPT_URL, "https://photongamemanager.com/PackageManager/LatestVersionWin.txt")
		?Linux
		curl.setOptString(CURLOPT_URL, "https://photongamemanager.com/PackageManager/LatestVersionLinux.txt")
		?
		Error = curl.perform()
		CloseFile(TFile)
		If Error > 0 then
			PrintF(CurlError(Error) )
			DeleteFile(TEMPFOLDER + "UpdateInfo.txt")
			Message = "failed to download update info: " + CurlError(Error)
			LockMutex(DialogMutex)
			DialogText = Message
			DialogProgress = 101
			UnlockMutex(DialogMutex)			
			Return
		EndIf	
		
		TFile = ReadFile(TEMPFOLDER + "UpdateInfo.txt")
			
		Repeat
		
			Line = ReadLine(TFile)
			Version = Left(Line, 5)
			If CurrentVersion = Version Then 
				Exit 
			EndIf 	
			If Eof(TFile) then
				Version = CurrentVersion
				Exit
			EndIf
		
		Forever
		CloseStream(TFile)
		
		Line = Right(Line,Len(Line)-6)
		
		Local c:Int = 0
		Local start:Int = 1
		Local b:Int = 0
		
		For c=1 To Len(Line)
			If Mid(Line,c,1)="," Then
				Select b
					Case 0
						Version = Mid(Line,start,c-start)					
					Case 1
						Package = "https://photongamemanager.com/PackageManager/" + Mid(Line, start, c - start)	
					Case 2
						Online = Mid(Line, start, c - start)
					Case 3
						Important = Mid(Line, start, c - start)	
					Case 4
						Beta = Mid(Line, start, c - start)	
						Exit
				End Select
				start = c + 1			
				b = b + 1
			EndIf
		Next
				
		If Online = "ONLINE" then
			
			Message = "Checking Version Information"	
			LockMutex(DialogMutex)
			DialogText = Message
			DialogPulse = 1
			UnlockMutex(DialogMutex)			
			
			If Left(CurrentVersion,2) <> Left(Version,2) Then 
				MessageBox = New wxMessageDialog.Create(Null , "There is a version mismatch, please contact help and support" , "Error" , wxOK | wxICON_EXCLAMATION)
				MessageBox.ShowModal()
				MessageBox.Free()	 
				Message = "Version Mismatch: CV:"+CurrentVersion+" V:"+Version
				LockMutex(DialogMutex)
				DialogText = Message
				DialogProgress = 101
				UnlockMutex(DialogMutex)				
				Return
			EndIf 
	
			If Int(Right(Version, 2) ) > Int(Right(CurrentVersion, 2) ) And (Beta = "NO" Or BetaDownload = True) then
				MessageBox = New wxMessageDialog.Create(Null, "Would you like to update from " + CurrentVersion + " to " + Version + "? ~nPlease backup your game database before updating. Also if you have any custom resources in Photon's Resources folder please also backup those as well before proceeding" , "Question", wxYES_NO | wxYES_DEFAULT | wxICON_QUESTION)
				If MessageBox.ShowModal() = wxID_NO Then
					Message = "Update Canceled By User"
					LockMutex(DialogMutex)
					DialogText = Message
					DialogProgress = 101
					UnlockMutex(DialogMutex)			
					Return
				EndIf
				Message = "Downloading: " + Package
				LockMutex(DialogMutex)
				DialogText = Message
				DialogPulse = 1
				UnlockMutex(DialogMutex)
				PrintF("Downloading: " + Package)
				Success = Download_UpdatePackage(Package)
				If Success <> "1" Then
					Message = "Download Failed: " + Success
					LockMutex(DialogMutex)
					DialogText = Message
					DialogProgress = 101
					UnlockMutex(DialogMutex)	
					Return
				EndIf 			
				Success = Install_UpdatePackage(Main.Dialog)
				
			Else
				MessageBox = New wxMessageDialog.Create(Null , "You currently have the newest version of GameManager" , "Info" , wxOK | wxICON_INFORMATION)
				MessageBox.ShowModal()
				MessageBox.Free()	
				Message = "Finished"
				LockMutex(DialogMutex)
				DialogText = Message
				DialogProgress = 101
				UnlockMutex(DialogMutex)		
				Return
			EndIf 
		Else
			Success = "Online update feature offline or GameManager website offline"		
		EndIf 

		If Success <> "1" Then
			Message = "Update Failed: "+Success
			LockMutex(DialogMutex)
			DialogText = Message
			DialogProgress = 101
			UnlockMutex(DialogMutex)
		Else
			Message = "Update Completed Successfully"
			LockMutex(DialogMutex)
			DialogText = Message
			DialogProgress = 101
			UnlockMutex(DialogMutex)		
		EndIf
End Function







Function Install_UpdatePackage:String(Dialog:DownloaderDialog)
	Message = "Started Installing"
	LockMutex(DialogMutex)
	DialogText = Message
	DialogPulse = 1
	UnlockMutex(DialogMutex)	
	DeleteCreateFolder(TEMPFOLDER+"UpdatePackage")
	Local zipProc:TProcess = CreateProcess(SevenZipPath + " x -aoa -y -o" + Chr(34) + TEMPFOLDER + "UpdatePackage" + Chr(34) + " " + Chr(34) + TEMPFOLDER + "UpdatePackage.zip" + Chr(34), 1)	
	Repeat
		LockMutex(DialogMutex)
		DialogText = Message
		DialogPulse = 1
		UnlockMutex(DialogMutex)
		If ProcessStatus(zipProc) = 0 Then Exit 
		Delay 1000
	Forever
	DeleteFile(TEMPFOLDER+"UpdatePackage.zip")
	Local InstallList:TList = CreateList()
	Local RenamedList:TList = CreateList()
	Local item:String , item2:String 
	Local renamedSucc:Int = 0
	Local UpdateUpdater:Int = 0
	InstallList = GenerateInstallList(InstallList, "")
	Message = "Preparing to install..."	
	LockMutex(DialogMutex)
	DialogText = Message
	DialogProgress = 0
	UnlockMutex(DialogMutex)	

	For item = EachIn InstallList
		LockMutex(DialogMutex)
		DialogText = Message
		DialogPulse = 1
		UnlockMutex(DialogMutex)
		renamedSucc = 0
		If Right(item, Len(item) - 1) <> "PhotonUpdater.exe" then
			If FileType(Right(item,Len(item)-1)+"_tempOLDFile") = 1 Then
				DeleteFile(Right(item,Len(item)-1)+"_tempOLDFile")
			EndIf
			For a = 1 To 5
				If FileType(Right(item,Len(item)-1)) = 1 Then 
					RenameFile(Right(item,Len(item)-1) , Right(item,Len(item)-1)+"_tempOLDFile")
					If FileType(Right(item,Len(item)-1)) = 0 Then 
						ListAddLast(RenamedList , Right(item,Len(item)-1)+"_tempOLDFile")
						renamedSucc = 1
						Exit 
					EndIf 
				Else
					renamedSucc = 1
					Exit
				EndIf 
			Next 
			If renamedSucc <> 1 Then 
				For item2 = EachIn RenamedList
					RenameFile(item2,Left(item2,Len(item2)-Len("_tempOLDFile")))
				Next 
				Return "Could not gain access to: "+item
			EndIf 
		EndIf 
	Next 
	Message = "Installing"
	LockMutex(DialogMutex)
	DialogText = Message
	DialogProgress = 0
	UnlockMutex(DialogMutex)
		
	For item = EachIn InstallList
		LockMutex(DialogMutex)
		DialogText = Message
		DialogPulse = 1
		UnlockMutex(DialogMutex)	
		item2 = Right(item,Len(item)-1)
		If item2 = "PhotonUpdater.exe" Then
			UpdateUpdater = True
		Else
			If FileType(ExtractDir(item2)) = 0 Then 
				CreateDir(ExtractDir(item2), 1)
			EndIf 
			CopyFile(TEMPFOLDER+"UpdatePackage"+item,item2)
		EndIf 
	Next 
	
	LockMutex(DialogMutex)
	DialogText = Message
	DialogProgress = 0
	UnlockMutex(DialogMutex)
	Message = "Cleaning up"	

	For item = EachIn RenamedList
		LockMutex(DialogMutex)
		DialogText = Message
		DialogPulse = -1
		UnlockMutex(DialogMutex)	

		DeleteFile(item)
	Next 
	
	If UpdateUpdater = True Then
		WriteBat = WriteFile("TempUpdater.bat")
		WriteLine(WriteBat,"echo off")
		WriteLine(WriteBat,"echo Updating PhotonUpdater.exe")
		WriteLine(WriteBat,"ping 1.1.1.100 -n 1 -w 2000 > nul")
		WriteLine(WriteBat, "xcopy " + TEMPFOLDER + "UpdatePackage\PhotonUpdater.exe /Y")
		WriteLine(WriteBat, "PhotonUpdater.exe")
		CloseFile(WriteBat)
		WinExec("TempUpdater.bat" , 1)
		End 
	Else
		WriteBat = WriteFile("TempUpdater.bat")
		WriteLine(WriteBat,"Start PhotonUpdater.exe")
		CloseFile(WriteBat)
		WinExec("TempUpdater.bat" , 1)
		End
	EndIf 

	Return "1"
End Function

Function GenerateInstallList:TList(List:TList, Folder:String)
	Local temp:String
	Dir = ReadDir(TEMPFOLDER + "UpdatePackage" + Folder)
	NextFile(Dir)
	NextFile(Dir)
	Repeat
		temp = NextFile(Dir)
		If temp = "" then Exit
		If FileType(TEMPFOLDER + "UpdatePackage" + Folder + "\" + temp) = 2 then
			CreateDir(Right(Folder, Len(Folder) - 1) + "\" + temp, 1)
			List = GenerateInstallList(List, Folder + "\" + temp)
		ElseIf FileType(TEMPFOLDER + "UpdatePackage" + Folder + "\" + temp) = 1 then
			ListAddLast(List, Folder + "\" + temp)	
			Print(Folder + "\" + temp)
		EndIf
	Forever
	CloseDir(Dir)
	Return List
End Function 

Function Download_UpdatePackage:String(Package:String)

	Local curl:TCurlEasy
	
	Local TFile:TStream = WriteFile(TEMPFOLDER + "UpdatePackage.zip")
	curl = TCurlEasy.Create()
	'curl.setOptString(CURLOPT_POSTFIELDS, "")
	curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
	curl.setOptInt(CURLOPT_HEADER, 0)
	curl.setWriteStream(TFile)
	curl.setProgressCallback(progressCallback)
	curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER + "cookie.txt")
	curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
	curl.setOptString(CURLOPT_URL, Package)
	Error = curl.perform()
	CloseFile(TFile)
	If Error>0 Then 
		DeleteFile(TEMPFOLDER+"UpdatePackage.zip")
		Return "failed to download update package"
	EndIf	
	
	PrintF("Finished Downloading Package: "+Package)
	Return "1"
End Function


Type DownloaderDialog Extends wxProgressDialog	
	'Field Timer:wxTimer
	
	Method OnInit()
		'Timer = New wxTimer.Create(Self, wxID_ANY)
		'Timer.Start(100)
		
		'ConnectAny(wxEVT_TIMER, UpdateFun)
	End Method
	
	Rem
	Function UpdateFun(event:wxEvent)
		Local DD:DownloaderDialog = DownloaderDialog(event.parent)
		DD.Update()
	End Function
	EndRem
	
	Method Update()
		Local a:Int 
		LockMutex(DialogMutex)
		If DialogResume <> - 1 Then
			DialogResume = - 1
			DialogNotCanceled = True
			Self.Resume()
		EndIf 		
		If DialogPulse = 1 Then
			DialogPulse = - 1
			Self.Pulse(DialogText, a)
		Else
			If DialogProgress <> - 1 Then
				DialogNotCanceled = Self.UpdateProgress(DialogProgress , DialogText , a)
				DialogProgress = - 1
			EndIf
		EndIf
		UnlockMutex(DialogMutex)
	End Method
End Type

Function progressCallback:Int(data:Object , dltotal:Double , dlnow:Double , ultotal:Double , ulnow:Double)
	Local Dialog:DownloaderDialog = DownloaderApp.Dialog
	Local MessageBox:wxMessageDialog
	Local a:Int
	Local NotCanceled:Int = True
	If dltotal <> 0 Then 
		If MilliSecs()-DownloadSpeedTimer>1000 Then
			DownloadSpeed=(dlnow/1000-Downloaded)/(Float(MilliSecs()-DownloadSpeedTimer)/1000)
			DownloadSpeedTimer=MilliSecs()
			Downloaded=dlnow/1000
		EndIf
		
		Print dlnow + "/" + dltotal
		Local Value:Float = 100 * (Float(dlnow) / dltotal)
		LockMutex(DialogMutex)
		DialogText = Message+" "+Int(dlnow/1000)+" / "+Int(dltotal/1000)+" KB @ "+DownloadSpeed+" KB/s"
		DialogProgress = Value
		NotCanceled = DialogNotCanceled
		UnlockMutex(DialogMutex)		
		
		If NotCanceled = False Then
			MessageBox = New wxMessageDialog.Create(Null, "Are you sure you want to cancel downloading?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				LockMutex(DialogMutex)
				DialogResume = True
				DialogNotCanceled = True
				UnlockMutex(DialogMutex)
				Return 0
			Else
				LockMutex(DialogMutex)
				DialogText = "Download canceled by user"
				DialogProgress = 101
				UnlockMutex(DialogMutex)				
				End
			EndIf
			
		EndIf
	Else
		LockMutex(DialogMutex)
		DialogText = Message
		DialogPulse = 1
		NotCanceled = DialogNotCanceled
		UnlockMutex(DialogMutex)
		If NotCanceled = False Then
			MessageBox = New wxMessageDialog.Create(Null, "Are you sure you want to cancel downloading?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				LockMutex(DialogMutex)
				DialogResume = True
				DialogNotCanceled = True
				UnlockMutex(DialogMutex)
				Return 0
			Else
				LockMutex(DialogMutex)
				DialogText = "Download canceled by user"
				DialogProgress = 101
				UnlockMutex(DialogMutex)				
				End
			EndIf
		EndIf 
	EndIf
	Return 0
End Function

Function LoadGlobalSettings()	
	ReadSettings:SettingsType = New SettingsType
	ReadSettings.ParseFile(SETTINGSFOLDER + "GeneralSettings.xml" , "GeneralSettings")		
	If ReadSettings.GetSetting("DebugLogEnabled") <> "" Then		
		If Int(ReadSettings.GetSetting("DebugLogEnabled") ) = 1 Then
			DebugLogEnabled = 1
		EndIf
	EndIf					
	ReadSettings.CloseFile()
End Function

?Win32
Extern "win32"
	Function WinExec(lpCmdLine$z , nCmdShow)
End Extern
?

Include "Includes\General\General.bmx"
Include "Includes\General\SplashApp.bmx"

