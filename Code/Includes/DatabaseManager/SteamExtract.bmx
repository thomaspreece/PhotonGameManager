Function OutputSteam(Online:Int)
	PrintF("----------------------------OutputSteam----------------------------")
	'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Outputting Steam Games" , , , 300 , 400) )
	Log1.Show(1)
	Local MessageBox:wxMessageDialog
	?Threaded
	Local RawSteamThread:TThread
	?
	If FileType(TEMPFOLDER + "Steam") = 2 then
		MessageBox = New wxMessageDialog.Create(Null, "Refresh Local Steam Data? (Only needed if new games have been added to Steam since last import)" , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
		If MessageBox.ShowModal() = wxID_YES then
			If Online = True then
				?Threaded
				RawSteamThread = CreateThread(Thread_GetRawSteamOnline, Null)
				While RawSteamThread.Running()
					DatabaseApp.Yield()
					Delay 100
				Wend
				?Not Threaded
				Thread_GetRawSteamOnline(Null)
				?
			Else	
				'GetRawSteam(Log1)	
				CustomRuntimeError("Error: Offline steam extract not possible")
			EndIf 
		EndIf
	else
		If Online=True Then 
			?Threaded
			RawSteamThread = CreateThread(Thread_GetRawSteamOnline, Null)
			While RawSteamThread.Running()
				DatabaseApp.Yield()
				Delay 100
			Wend
			?Not Threaded
			Thread_GetRawSteamOnline(Null)
			?
		Else	
			CustomRuntimeError("Error: Offline steam extract not possible")
		EndIf 
	EndIf
	'EndIf
	PrintF("Finish Steam Output")
	'Log1.Destroy()	
	Log1.Show(0)
End Function


Function ExtractSteamIcons(SteamFolder:String , FullSearch:Int = False)
	Log1.Show(1)
	Local TempObj:Thread_CopyIconsMain_Object = New Thread_CopyIconsMain_Object
	TempObj.Folder = SteamFolder
	TempObj.FullSearch = FullSearch
	
?Threaded
	Local SteamIconThread:TThread
	SteamIconThread = CreateThread(Thread_CopyIconsMain, TempObj)
	While SteamIconThread.Running()
		DatabaseApp.Yield()
		Delay 100
	Wend
?Not Threaded
	Thread_CopyIconsMain(TempObj)
?
	Log1.Show(0)
End Function

Function Thread_CopyIconsMain:Object(Obj:Object)
	Local Folder:String = Thread_CopyIconsMain_Object(Obj).Folder
	Local FullSearch:Int = Thread_CopyIconsMain_Object(Obj).FullSearch
	
	PrintF("Searching for Icons")
	INum = 0
	DeleteCreateFolder(TEMPFOLDER + "SteamIcons")
	Folder = StandardiseSlashes(Folder)	
	CopyIcons(Folder , FullSearch)
	CopyIcons(TEMPFOLDER + "Icons" , FullSearch)	
	DeleteCreateFolder(TEMPFOLDER + "Icons")
End Function

Type Thread_CopyIconsMain_Object
	Field Folder:String
	Field FullSearch:int = False
End Type

Function CopyIcons(SteamFolder:String, FullSearch:Int)
	If FileType(SteamFolder) = 2 then
		Local Dir:Int = ReadDir(SteamFolder)
		Local File:String, OldFile:String
		Local Num:Int = 0
		Repeat
			File = NextFile(Dir)
			If File = "" then Exit
			If File = "." Or File = ".." then Continue
			If FileType(SteamFolder + FolderSlash + File) = 2 then
				If FullSearch = True Or IconFolderExclude(File) = False then
					CopyIcons(SteamFolder + FolderSlash + File, FullSearch)
				EndIf
			Else
				If Lower(Right(File , 3) ) = "ico" then
					Log1.AddText("Found: " + SteamFolder + FolderSlash + File)
					PrintF("Found: " + SteamFolder + FolderSlash + File)
					OldFile = File
					Num = 0
					Repeat
						If FileType(TEMPFOLDER + "SteamIcons" + FolderSlash + File) = 1 then
							File = Left(OldFile, Len(OldFile) - 4) + "(" + Num + ")" + ".ico"
							Num = Num + 1							
						Else
							Exit
						EndIf
					Forever
					CopyFile(SteamFolder + FolderSlash + OldFile , TEMPFOLDER + "SteamIcons" + FolderSlash + File)
					INum = INum + 1
				EndIf
					
				If Lower(Right(File , 3) ) = "exe" Or (Lower(Right(File , 3) ) = "dll" And FullSearch = True) then
					Local ExtractProcess:TProcess
					
					ExtractProcess = CreateProcess(ResourceExtractPath + " /Source " + Chr(34) + SteamFolder + FolderSlash + File + Chr(34) + " /DestFolder " + Chr(34) + TEMPFOLDER + "Icons" + FolderSlash + Chr(34) + " /OpenDestFolder 0 /ExtractBinary 0 /ExtractTypeLib 0 /ExtractAVI 0 /ExtractAnimatedCursors 0 /ExtractAnimatedIcons 1 /ExtractManifests 0 /ExtractHTML 0 /ExtractBitmaps 0 /ExtractCursors 0 /ExtractIcons 1")
					
					Repeat
						If ExtractProcess = Null then Exit
						If ProcessStatus(ExtractProcess) = 0 then
							Exit
						EndIf
						Delay 10
						If Log1.LogClosed = True then Exit
					Forever

?Not Threaded
					DatabaseApp.Yield()	
?
				EndIf
			
			EndIf
			If Log1.LogClosed = True then Exit
		Forever
	Else
		CustomRuntimeError("Error 32: Cannot find folder - "+SteamFolder) 'MARK: Error 32
	EndIf
End Function

Function IconFolderExclude:Int(Folder:String)
	Select Folder
		Case "Public"
		Case "FaceFX"
		Case "EA Help"
		Default
			Return False
	End Select
	Return True
End Function


Function Thread_GetRawSteamOnline:Object(ob:Object)
	Local MessageBox:wxMessageDialog
	Log1.AddText("Searching for Steam Games")
	SteamFolder = StripSlash(SteamFolder)
	SteamFolder = StandardiseSlashes(SteamFolder)

	?Win32
	If FileType(SteamFolder+"\Steam.exe")=0 Then 
		CustomRuntimeError("SIO-Error-01: Not Steam Folder")
	EndIf
	?Not Win32
	If FileType(SteamFolder+"/steam")=0 Then 
		CustomRuntimeError("SIO-Error-01: Not Steam Folder")
	EndIf	
	?
	If SteamID="" Or SteamID=" " Or Len(SteamID)<>17 Then 
		CustomRuntimeError("SIO-Error-02: Not SteamID")
	EndIf

	DeleteCreateFolder(TEMPFOLDER + "Steam")	
	
	Local curl:TCurlEasy	
	Local TFile:TStream = WriteFile(TEMPFOLDER + "Steam.txt")
	curl = TCurlEasy.Create()
	'curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
	'curl.setOptInt(CURLOPT_HEADER, 0)
	curl.setOptInt(CURLOPT_CONNECTTIMEOUT, 5)
	curl.setWriteStream(TFile)
	'curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
	curl.setOptString(CURLOPT_URL, "http://photongamemanager.com/GameManagerPages/Steam.php?ID="+SteamID)
	Error = curl.perform()
	CloseFile(TFile) 
	If Error>0 Then 
		CustomRuntimeError("SIO-Error-03: Failed to connect to photongamemanager.com")
	EndIf	
	
	Local Steamdoc:TxmlDoc
	Local RootNode:TxmlNode, Mainnode:TxmlNode, Datanode:TxmlNode
	Local ChildrenList:TList, ChildrenChildrenList:TList, DataList:TList
	Local appid:String, name:String
	
	Steamdoc = TxmlDoc.parseFile(TEMPFOLDER+"Steam.txt")
			
	If Steamdoc = Null Then
		CustomRuntimeError( "SIO-Error-04: XML Document not parsed successfully")
	End If
				
	RootNode = Steamdoc.getRootElement()
				
	If RootNode = Null Then
		Steamdoc.free()
		CustomRuntimeError( "SIO-Error-05: Empty document")
	End If		
		
	If RootNode.getName() <> "response" Then
		Steamdoc.free()
		CustomRuntimeError( "SIO-Error-06: Document of the wrong type, root node <> response")
	End If

		
				
	ChildrenList = RootNode.getChildren()
	If ChildrenList = Null Or ChildrenList.IsEmpty() Then
			Steamdoc.free()
			Log1.AddText("Invalid SteamID")	
			PrintF("Invalid SteamID")
			MessageBox = New wxMessageDialog.Create(Null , "SteamID invalid, please check you have entered it correctly AND that your steam profile is publicly viewable" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
			Return 
			'CustomRuntimeError( "SIO-Error-07: Document error, no data contained within")
	EndIf
	For Mainnode = EachIn ChildrenList
		If Mainnode.getName()="games"
			ChildrenChildrenList:TList = Mainnode.getChildren()
			For Mainnode = EachIn ChildrenChildrenList
				If Mainnode.getName()="message"
					DataList:TList = Mainnode.getChildren()	
					appid=""
					name=""
					For Datanode = EachIn DataList
						Select Datanode.getName()
							Case "appid"
								appid = Datanode.getText()
							Case "name"
								name = Datanode.getText()
							Default	
						End Select	
					Next
					If appid="" Or name="" Then 
				
					Else	
						DeleteCreateFolder(TEMPFOLDER + "Steam" + FolderSlash + GameReadType.GameNameDirFilter(name) )
						Log1.AddText("Found: " + name)
						PrintF("Found: " + name)
						If FileType(TEMPFOLDER + "Steam" + FolderSlash + GameReadType.GameNameDirFilter(name))=2 Then 
							WriteGameData = WriteFile(TEMPFOLDER + "Steam" + FolderSlash + GameReadType.GameNameDirFilter(name) + FolderSlash + "Info.txt")
							If WriteGameData = Null Then 
								PrintF("Failed To Write Game Data: " + TEMPFOLDER + "Steam" + FolderSlash + GameReadType.GameNameDirFilter(name) + FolderSlash + "Info.txt")
							Else
								WriteLine(WriteGameData , GameReadType.GameNameFilter(name) )
								?Win32
								WriteLine(WriteGameData , Chr(34)+SteamFolder + FolderSlash +"Steam.exe"+Chr(34)+" -applaunch " + appid )
								?Not Win32
								WriteLine(WriteGameData , Chr(34)+SteamFolder + FolderSlash +"steam"+Chr(34)+" -applaunch " + appid )
								?
								WriteLine(WriteGameData , "Installed")
								CloseFile(WriteGameData)
							EndIf 
						Else
							PrintF("Failed To Create Folder: " + TEMPFOLDER + "Steam" + FolderSlash + GameReadType.GameNameDirFilter(name) )
						EndIf 
					EndIf 
				EndIf 
				If Log1.LogClosed = True Then Exit
			Next
			Exit	
		EndIf 
	Next
	Log1.AddText("Finished")
	?Threaded
	Delay 1000
	?
End Function 

Rem
Function GetRawSteam(Log1:LogWindow)
	Log1.AddText("Searching for Steam Games")
	SteamFolder = StripSlash(SteamFolder)
	SteamFolder = StandardiseSlashes(SteamFolder)
	If FileType(SteamFolder+"\Steam.exe")=0 Then 
		CustomRuntimeError("SI-Error-01: Not Steam Folder")
	EndIf
	If FileType(SteamFolder+"\config\config.vdf")=0 Then
		CustomRuntimeError("SI-Error-02: No Steam config.vdf")
	EndIf
	
	Local ConfigString:String
	ReadConfig=ReadFile(SteamFolder+"\config\config.vdf")
	Repeat
		templine$ = ReadLine(ReadConfig)
		If Eof(ReadConfig) Then Exit
		ConfigString = ConfigString + templine
	Forever	
	CloseFile(ReadConfig)
	ConfigString = StripTabs(ConfigString)
	ConfigString = StripText(ConfigString , Chr(34) + "apps" + Chr(34) + "{" , 2)
	ConfigString = StripText(ConfigString , Chr(34) + "SentryFile" + Chr(34) , 1)
	
	
	Local Temp:String , Path:String, Name:String, DirName:String
	DeleteCreateFolder(TEMPFOLDER + "Steam")
	Repeat
		Save=False
		Number:Int=Int(ExtractQuoteText(ConfigString))
		If Number=0 Then Exit
		Temp = StripText(StripText(ConfigString , "}" , 1) , Chr(34) + "InstallDir" + Chr(34) , 2)
		Path = ExtractQuoteText(Temp)
		For a = 1 To Len(Path)
			If Mid(Path , a , Len("steamapps") ) = "steamapps" Then
				Path = SteamFolder + "\\" + Right(Path , Len(Path) - a + 1)
				Exit
			EndIf
		Next
		
		Path = StandardiseSlashes(Path)
		Path = RemoveDoubleSlashes(Path)
		
		Name = StripDir(Path)
		DirName = GameNameSanitizer(Name)
		
		If Int(Path)=Number Then 
		
		Else
			If FileType(Path)=2 Then
				If ExceptionList(Number)=True Then
					Save = 0
				Else
					Save = 1
				EndIf
			Else
				If DirName = "" Or DirName = " " Then
					Save = 0
				Else
					Save = 2
				EndIf
			EndIf
		EndIf
		
		
		
		If Save = 1 Then
			DeleteCreateFolder(TEMPFOLDER + "Steam\" + DirName)
			Log1.AddText("Found: " + DirName)
			PrintF("Found: " + DirName)
			WriteGameData = WriteFile(TEMPFOLDER + "Steam\" + DirName + "\Info.txt")
			WriteLine(WriteGameData , Name)
			WriteLine(WriteGameData , Chr(34)+SteamFolder + "\Steam.exe"+Chr(34)+" -applaunch " + Number )
			WriteLine(WriteGameData , "Installed")
			CloseFile(WriteGameData)
		ElseIf Save = 2 Then
			DeleteCreateFolder(TEMPFOLDER + "Steam\" + DirName)
			Log1.AddText("Found: " + DirName + "(Uninstalled)")
			PrintF("Found: " + DirName + "(Uninstalled)")
			WriteGameData = WriteFile(TEMPFOLDER + "Steam\" + DirName + "\Info.txt")
			WriteLine(WriteGameData , Name)
			WriteLine(WriteGameData , Chr(34)+SteamFolder + "\Steam.exe" + Chr(34) + " -applaunch " + Number )
			WriteLine(WriteGameData , "UnInstalled")
			CloseFile(WriteGameData)
		Else
			'Do Nothing
		EndIf
		ConfigString=StripText(ConfigString,"}",2)
		If Log1.LogClosed = True Then Exit
	Forever
	Log1.AddText("Finished")
End Function
EndRem

Function ExceptionList:Int(Number:Int)
	Select Number
		Case 7
			Return True
		Case 20
			Return True
		Default
			Return False
	End Select
End Function

Function ExtractQuoteText:String(Tex:String)
	Local StartPos:Int=0
	Local EndPos:Int=0
	Local Pos:Int=1
	
	For a=1 To Len(Tex)
		If Mid(Tex,a,1)=Chr(34) Then
			Select Pos
				Case 1
					StartPos=a				
					Pos=Pos+1
				Case 2
					EndPos=a
					Exit
			End Select
		EndIf	
	Next
	Return Mid(Tex,StartPos+1,EndPos-StartPos-1)
End Function

Function StripText:String(Tex:String , Search:String , Side:Int)
	For a=1 To Len(Tex)-Len(Search)
		If Lower(Mid(Tex,a,Len(Search)))=Lower(Search)
			If Side=1 Then
				Return Left(Tex,a-1)
			ElseIf Side=2 Then
				Return Right(Tex,Len(Tex)-a-Len(Search)+1)
			EndIf
		EndIf
	Next
	Return Tex
End Function

Function StripTabs:String(Tex:String)
Local LenCorrect = 0
For a=1 To Len(Tex)-LenCorrect
	If Mid(Tex,a,1)=Chr(9) Then
		Tex=Left(Tex,a-1)+Right(Tex,Len(Tex)-a)
		LenCorrect=LenCorrect+1
		a=a-1
	EndIf
Next
Return Tex
End Function

Function RemoveDoubleSlashes:String(Text:String)
	Repeat
		For a = 1 To Len(Text)
			ContinueLoop = False
			If Mid(Text , a , 2) = "\\" Then
				Text = Left(Text , a - 1) + Right(Text , Len(Text) - a)
				ContinueLoop = True
				Exit
			EndIf
		Next
		If ContinueLoop = False Exit
	Forever
	Return Text
End Function

Function FindSteamFolderMain()
	If IsntNull(SteamFolder) Then
		Status = 1
	Else
		'Local Log1:LogWindow = LogWindow(New LogWindow.Create(Null , wxID_ANY , "Searching for Steam Folder" , , , 300 , 400) )
		Log1.Show(1)
		Log1.AddText("Searching for Steam Folder")
		Status = FindSteamFolder(Log1)
		Log1.Show(0)
		'Log1.Destroy()
	EndIf
	Return Status
End Function

Function FindSteamFolder(Log1:LogWindow)
	Local SteamFolder2:String
	?Win32
	For a = 65 To 90
		SteamFolder2 = SearchFolderForSteam(Chr(a) + ":" , 1, Log1)
		If SteamFolder2 = "" Then
			
		Else
			Exit
		EndIf
	Next
	If SteamFolder2 = "" Or SteamFolder2 = " " Then
		Return -1
	Else
		SteamFolder = SteamFolder2
		Return 1
	EndIf
	?Not Win32
	If FileType("/usr/bin/steam")=1 Then
		SteamFolder = "/usr/bin"
		Return 1	
	Else
		Return -1
	EndIf 
	?
End Function

Function SearchFolderForSteam:String(Folder:String , Level:Int ,Log1:LogWindow)
	If FileType(Folder) = 0 Or FileType(Folder) = 1 Then Return
	If Level > 3 Then Return
	Local File:String, Search:String
	ReadFolder = ReadDir(Folder)
	Repeat
		File = NextFile(ReadFolder)
		If File = "" Then Exit
		If File="." Or File=".." Then Continue
		If FileType(Folder + "\" + File) = 2 Then
			If Level = 1 Then
				PrintF(File)
				Log1.AddText("Looking in: "+Folder + "\" + File)
			EndIf
			If FileType(Folder + "\" + File + "\Steam.exe") Then
				Return Folder + "\" + File
			EndIf
			If SteamFolderExcluded(File)=False Then
				Search = SearchFolderForSteam(Folder + "\" + File , Level+1 , Log1)
				If Search="" Then
				Else
					Return Search
				EndIf
			EndIf
		EndIf
		If Log1.LogClosed = True Then Exit
	Forever
	Return ""
End Function

Function SteamFolderExcluded(Folder:String)
	Select Lower(Folder)
		Case "windows" , "users"
			Return True
		Default
			Return False
	End Select
End Function
