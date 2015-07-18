'TODO: Remove Mounter delay and that detect iso mounted
'TODO: Keep PhotonRunner Loaded for several hours to see if it leaks memory

Framework wx.wxapp
Import wx.wximage
Import wx.wxFrame
Import wx.wxButton
Import wx.wxPanel
Import wx.wxStaticText
Import wx.wxTextCtrl
Import wx.wxTimer
Import wx.wxMessageDialog
Import wx.wxtreeListctrl
Import wx.wxlistctrl

Import brl.retro
Import BRL.OpenALAudio
Import BRL.DirectSoundAudio
Import BRL.FreeAudioAudio
Import BRL.WAVLoader
Import pub.freeprocess

Import BRL.JPGLoader
Import bah.FreeImage

Import Bah.Volumes
Import bah.libxml
Import bah.regex
Import bah.libcurlssl

Import brl.threads

?Win32
Import "..\Icons\PhotonRunner.o"
?

AppTitle = "PhotonRunner"

?Not Win32
Global FolderSlash:String = "/"

?Win32
Global FolderSlash:String = "\"
?

Include "Includes\General\StartupOverrideCheck.bmx"
Local TempFolderPath:String = OverrideCheck(FolderSlash)

Include "Includes\General\GlobalConsts.bmx"
Include "Includes\Runner\GlobalConsts.bmx"

' Revision Version Generation Code
' @bmk include Includes/General/Increment.bmk
' @bmk doOverallVersionFiles Version/OverallVersion.txt
?Win32
' @bmk doIncrement Version/PR-Version.txt 1
?Mac
' @bmk doIncrement Version/PR-Version.txt 2
?Linux
' @bmk doIncrement Version/PR-Version.txt 3
?
Incbin "Version/PR-Version.txt"
Incbin "Version/OverallVersion.txt"

SubVersion = ExtractSubVersion(LoadText("incbin::Version/PR-Version.txt"), 1)
OSubVersion = ExtractSubVersion(LoadText("incbin::Version/OverallVersion.txt"), 1)

Print "Version = " + CurrentVersion
Print "SubVersion = " + SubVersion
Print "OSubVersion = " + OSubVersion


DebugCheck()
FolderCheck()

LogName = "Log-Explorer-PhotonRunner" + CurrentDate() + " " + Replace(CurrentTime(), ":", "-") + ".txt"
CreateFile(LOGFOLDER + LogName)

Local ArguemntNo:int = 0
Local RunnerEXENumber:int
Local RunnerGameName:String

LoadGlobalSettings()

Local PastArgument:String
For Argument$ = EachIn AppArgs$
	Select PastArgument
		Case "-Cabinate", "Cabinate"
			CmdLineCabinate = int(Argument)
			PastArgument = ""
		Case "-GameName", "GameName"
			RunnerGameName = Argument
			PastArgument = ""		
		Case "-EXENum", "EXENum"
			RunnerEXENumber = int(Argument)
			PastArgument = ""
		Case "-Debug", "Debug"
			If int(Argument) = 1 then
				DebugLogEnabled = True
			EndIf 
			PastArgument = ""
		Default
			Select Argument
				Case "-Debug" , "-GameName" , "-EXENum" , "-Cabinate", "Debug" , "GameName" , "EXENum" , "Cabinate"
					PastArgument = Argument
			End Select
	End Select
Next

If AppArgs.length = 1 then
	Notify "This program handles running your games and other options. It is automatically called by PhotonExplorer and PhotonFrontend when you click to start a game, and as such there is no reason for you to run this program manually. PhotonRunner will now exit."
	End
EndIf

If DebugLogEnabled = False then
	DeleteFile(LOGFOLDER + LogName)
EndIf

WindowsCheck()
SetupPlatforms()
OldPlatformListChecks()

LoadInExclusionList()

If FileType(GAMEDATAFOLDER + RunnerGameName) <> 2 then
	Notify "Invalid Game"
	End
EndIf
PhotonRunnerApp = New PhotonRunner
PhotonRunnerApp.SetGame(RunnerGameName , RunnerEXENumber)
PhotonRunnerApp.Run()


Print "Close"
End


Type PhotonRunner Extends wxApp
	Field Runner:RunnerWindow
	Field GameNode:String
	Field EXENum:int
	
	Method OnInit:Int()		
		wxImage.AddHandler( New wxICOHandler)
		Runner = RunnerWindow(New RunnerWindow.Create(Null , wxID_ANY , "PhotonRunner" , - 1 , - 1 , 300 , 300) )
		Runner.SetGame(GameNode, EXENum)
		
		Return True
	End Method
	
	Method SetGame(GN:String , EN:Int)
		PrintF(GN + " " + EN)
		Self.GameNode = GN
		Self.EXENum = EN
	End Method
End Type


Function LoadGlobalSettings()
	ReadSettings:SettingsType = New SettingsType
	ReadSettings.ParseFile(SETTINGSFOLDER + "GeneralSettings.xml" , "GeneralSettings")
	If ReadSettings.GetSetting("Country")<>"" Then 
		Country = ReadSettings.GetSetting("Country")
	EndIf
	If ReadSettings.GetSetting("PGMOff")<>"" Then 
		PerminantPGMOff = Int(ReadSettings.GetSetting("PGMOff") )
	EndIf	
	If ReadSettings.GetSetting("SilentRunOff") <> "" Then	
		SilentRunnerEnabled = Int(ReadSettings.GetSetting("SilentRunOff"))
	EndIf 
	If ReadSettings.GetSetting("Cabinate") <> "" Then	
		CabinateEnable = Int(ReadSettings.GetSetting("Cabinate"))
	EndIf
	If ReadSettings.GetSetting("RunnerButtonCloseOnly") <> "" Then	
		RunnerButtonCloseOnly = Int(ReadSettings.GetSetting("RunnerButtonCloseOnly"))
	EndIf 
	If ReadSettings.GetSetting("OriginWaitEnabled") <> "" Then	
		OriginWaitEnabled = Int(ReadSettings.GetSetting("OriginWaitEnabled"))
	EndIf 			
	If ReadSettings.GetSetting("DebugLogEnabled") <> "" then		
		If Int(ReadSettings.GetSetting("DebugLogEnabled") ) = 1 then
			DebugLogEnabled = 1
		EndIf
	EndIf			
	If ReadSettings.GetSetting("ProcessQueryDelay") <> "" then		
		ProcessQueryDelay = Int(ReadSettings.GetSetting("ProcessQueryDelay") )
	EndIf		
	If ReadSettings.GetSetting("PluginQueryDelay") <> "" then		
		PluginQueryDelay = Int(ReadSettings.GetSetting("PluginQueryDelay") )
	EndIf		
	
	ReadSettings.CloseFile()
End Function

Function WindowsCheck()
	?Win32
	WinDir = GetEnv("WINDIR")
	PrintF("Windows Folder: " + WinDir)
	
	If wxIsPlatform64Bit() = 1 then
		PrintF("Detected 64bit")
		WinBit = 64
	Else
		PrintF("Detected 32bit")
		WinBit = 32
	EndIf

	Local OSMajor:Int
	Local OSMinor:int
	wxGetOsVersion(OSMajor, OSMinor)

	PrintF("Detected Win Version: "+OSMajor+"."+OSMinor)

	If OSMajor => 6 Then
		WinExplorer = True
	Else
		WinExplorer = False
	EndIf
	?Not Win32
		WinExplorer = False
	?
	
End Function

Include "Includes\Runner\PhotonRunner.bmx"
Include "Includes\Runner\NewProcessManager.bmx"
Include "Includes\General\ValidationFunctions.bmx"
Include "Includes\General\General.bmx"