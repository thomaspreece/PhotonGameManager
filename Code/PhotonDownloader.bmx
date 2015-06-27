Framework wx.wxApp
Import wx.wxFrame
Import wx.wxStaticText
Import wx.wxProgressDialog
Import wx.wxTimer
Import wx.wxMessageDialog

Import BRL.StandardIO
Import BRL.FileSystem
Import BRL.Stream
Import BRL.System
Import BRL.Retro

Import Pub.FreeProcess

Import BaH.libcurlssl
Import Bah.Volumes


?Not Win32
Global FolderSlash:String ="/"

?Win32
Import "Icons\PhotonDownloader.o"
Global FolderSlash:String ="\"
?

Local TempFolderPath:String
If FileType("SaveLocationOverride.txt") = 1 Then 
	ReadLocationOverride = ReadFile("SaveLocationOverride.txt")
	TempFolderPath = ReadLine(ReadLocationOverride)
	CloseFile(ReadLocationOverride)
	If Right(TempFolderPath,1)=FolderSlash Then 
	
	Else
		TempFolderPath = TempFolderPath + FolderSlash
	EndIf 
Else
	If FileType(GetUserDocumentsDir()+FolderSlash+"GameManagerV4") <> 2 Then 
		CreateFolder(GetUserDocumentsDir()+FolderSlash+"GameManagerV4")
	EndIf 
	TempFolderPath = GetUserDocumentsDir()+FolderSlash+"GameManagerV4"+FolderSlash
EndIf 


Include "Includes\General\GlobalConsts.bmx"

' Revision Version Generation Code
' @bmk include Includes/General/Increment.bmk
' @bmk doOverallVersionFiles Version/OverallVersion.txt
?Win32
' @bmk doIncrement Version/PD-Version.txt 1
?Mac
' @bmk doIncrement Version/PD-Version.txt 2
?Linux
' @bmk doIncrement Version/PD-Version.txt 3
?
Incbin "Version/PD-Version.txt"
Incbin "Version/OverallVersion.txt"

Global SubVersion:String = ExtractSubVersion(LoadText("incbin::Version/PD-Version.txt"), 1)
Global OSubVersion:String = ExtractSubVersion(LoadText("incbin::Version/OverallVersion.txt"), 1)

Print "Version = " + CurrentVersion
Print "SubVersion = " + SubVersion
Print "OSubVersion = " + OSubVersion


If FileType("DebugLog.txt")=1 Then 
	DebugLogEnabled = True
EndIf 

LogName = "Log-Downloader"+CurrentDate()+" "+Replace(CurrentTime(),":","-")+".txt"
CreateFile(LOGFOLDER+LogName)

AppTitle = "PhotonDownloader"
Global PROGRAMICON:String = RESFOLDER+"Internet.ico"

Global DownloaderApp:DownloaderShell
Global Message:String = ""
Global CurrentSearchLine:String = ""
Global DownloadSpeedTimer:Int = MilliSecs()
Global Downloaded:Int = 0
Global DownloadSpeed:Int = 0

Global DownloadGame:String = ""
Global DownloadFile:String = ""
Global DownloadType:String = ""
Global DownloadName:String = ""

Global DownloadPath:String = ""

Global FeedbackTimer:Int = 0

Local ArguemntNo:Int = 0

Local PastArgument:String 
For Argument$ = EachIn AppArgs$
	Select PastArgument
		Case "-DownloadGame","DownloadGame"
			DownloadGame = Argument
			PastArgument = ""	
		Case "-DownloadFile","DownloadFile"
			DownloadFile = Argument
			PastArgument = ""		
		Case "-Mode","Mode"			
			ProgramMode = Int(Argument)
			PastArgument = ""
		Case "-DownloadName","DownloadName"
			DownloadName = Argument
			PastArgument = ""
		Case "-DownloadType","DownloadType"
			DownloadType = Argument
			PastArgument = ""
		Case "-DownloadPath","DownloadPath"
			DownloadPath = Argument
			PastArgument = "" 
		Case "-Debug","Debug"
			If Int(Argument) = 1 Then 
				DebugLogEnabled = True
			EndIf 
			PastArgument = ""
		Default
			Select Argument
				Case "Mode" , "Debug" , "DownloadGame" , "DownloadFile" , "DownloadName" , "DownloadType" , "DownloadPath", "-Mode" , "-Debug" , "-DownloadGame" , "-DownloadFile" , "-DownloadName" , "-DownloadType" , "-DownloadPath"
					PastArgument = Argument
			End Select
	End Select
Next

If DebugLogEnabled=False Then 
	DeleteFile(LOGFOLDER+LogName)
EndIf 

Select ProgramMode

	Case 1
		PrintF("Mode 1")
		If FileType(ExtractDir(SevenZipPath)) <> 2 Or FileType(SevenZipPath) <> 1 Then
			CustomRuntimeError("Error 202: 7zip plugin missing, please reinstall GameManager") 'Mark: Error 202
			End
		EndIf 
		
		'If ArgumentNo < 6 Then
		If DownloadGame = "" Or DownloadFile = "" Or DownloadType = "" Or DownloadName = "" Then 
			CustomRuntimeError("Error 203: Too few arguments") 'MARK: Error 203
			End 
		EndIf
		If FileType(GAMEDATAFOLDER + DownloadGame) <> 2 Then
			CustomRuntimeError("Error 204: Invalid Game @ Argument #1") 'MARK: Error 204
			End 	
		EndIf 
		
		
		DownloaderApp = New DownloaderShell
		DownloaderApp.Run()
		
	Case 2
		PrintF("Mode 2")
		'If ArgumentNo < 6 Then
		If DownloadFile = "" Or DownloadPath = "" Or DownloadName = "" Then 
			CustomRuntimeError("Error 203: Too few arguments") 'MARK: Error 203
			End 
		EndIf
		
		?Win32
		If FileType("DownloadFilesSub.exe") = 1 Then 
			WinExec("DownloadFilesSub.exe "+Chr(34)+DownloadFile+Chr(34)+" "+Chr(34)+DownloadPath+Chr(34)+" "+Chr(34)+DownloadName+Chr(34) , 1 , 1)
			End 
		EndIf 
		?		
				
		Local curl:TCurlEasy	
		CreateDir(DownloadPath,1)

		Local TFile:TStream = WriteFile(DownloadPath+FolderSlash+DownloadName)
		curl = TCurlEasy.Create()
		'curl.setOptString(CURLOPT_POSTFIELDS, "")
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
		curl.setProgressCallback(cmdLineCallback,DownloadName) 		
		curl.setOptInt(CURLOPT_HEADER, 0)
		curl.setWriteStream(TFile)
		curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
		curl.setOptString(CURLOPT_URL, DownloadFile)
		FeedbackTimer = MilliSecs()
		
		Error = curl.perform()
		CloseFile(TFile) 
		If Error>0 Then 
			Notify "Failed to download: "+DownloadFile
		EndIf	
		
	Default
		PrintF("Default Mode")
		CustomRuntimeError("PhotonDownloader is used by the other programs in this application suite To download items such as artwork, patches, cheats And manuals. If you are seeing this, you either are trying To execute PhotonDownloader directly, Or there is a problem with the particular app you are using.")
End Select

Function cmdLineCallback:Int(data:Object , dltotal:Double , dlnow:Double , ultotal:Double , ulnow:Double)
	Local Name:String = String(data)
	If MilliSecs()-FeedbackTimer>1000 Then
		Print(Name+": "+Int(dlnow/1000)+"/"+Int(dltotal/1000))
		FeedbackTimer = MilliSecs()
	EndIf
	Return 0
End Function


Type DownloaderShell Extends wxApp 
	Field Dialog:DownloaderDialog
	Field Timer:wxTimer 
	
	Method OnInit:Int()	

		wxImage.AddHandler( New wxICOHandler)		
		Local a:Int
		Local Success:String 
		Dialog = DownloaderDialog(New DownloaderDialog.Create("Downloading: "+DownloadName, "", 101, Null, wxPD_APP_MODAL | wxPD_ELAPSED_TIME | wxPD_ESTIMATED_TIME | wxPD_SMOOTH | wxPD_CAN_ABORT))
		Dialog.SetDimensions(0,0,600,200)
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Dialog.SetIcon( Icon )	
		Dialog.Update()

		
		Timer = New wxTimer.Create(Self)
		ConnectAny(wxEVT_TIMER, OnTick)
		Timer.Start(10)
		
		Select DownloadType
			Case "PScrolls"
				Success = Download_PScrolls(DownloadFile)
			Case "RDocs"
				Success = Download_RDocs(DownloadFile)
			Case "GFAQs"
				Success = Download_GFAQs(DownloadFile)
			Case "GFAQs-Cheat"
				Success = Download_GFAQs_Cheat(DownloadFile)
			Default
				CustomRuntimeError("Error 205: Invalid Type @ Argument #3") 'MARK: Error 205
				End 				
		End Select
		If Success <> "1" Then
			Message = "Download Failed: "+Success
			Dialog.UpdateProgress(101 , Message , a)
		Else
			Message = "Download Completed Successfully"
			Dialog.UpdateProgress(101 , Message , a)			
		EndIf
		Return True

	End Method
	
	Function OnTick(event:wxEvent)
		Local Main:DownloaderShell = DownloaderShell(event.Parent)
		If Main.Dialog.IsShown() = 0 Then
			End
		EndIf 
	End Function
	
End Type

Type DownloaderDialog Extends wxProgressDialog
	Method OnInit()
	
	End Method
End Type

Function progressCallback:Int(data:Object , dltotal:Double , dlnow:Double , ultotal:Double , ulnow:Double)
	Local Dialog:DownloaderDialog = DownloaderApp.Dialog
	Local MessageBox:wxMessageDialog
	Local a:Int
	If dltotal <> 0 Then 
		If MilliSecs()-DownloadSpeedTimer>1000 Then
			DownloadSpeed=(dlnow/1000-Downloaded)/(Float(MilliSecs()-DownloadSpeedTimer)/1000)
			DownloadSpeedTimer=MilliSecs()
			Downloaded=dlnow/1000
		EndIf
		
		PrintF(dlnow + "/" + dltotal)
		Local Value:Float = 100 * (Float(dlnow) / dltotal)
		If Dialog.UpdateProgress(Value , Message+" "+Int(dlnow/1000)+" / "+Int(dltotal/1000)+" KB @ "+DownloadSpeed+" KB/s" , a) = 0 Then
			MessageBox = New wxMessageDialog.Create(Null, "Are you sure you want to cancel downloading?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				Dialog.Resume()
				Return 0
			EndIf
			Return 1
		EndIf
	Else
		If Dialog.Pulse(Message , a) = 0 Then
			MessageBox = New wxMessageDialog.Create(Null, "Are you sure you want to cancel downloading?" , "Warning", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_NO Then
				Dialog.Resume()
				Return 0
			EndIf		
			Return 1
		EndIf 
	EndIf 
	DownloaderApp.Yield()
	Return 0
End Function

Function Download_GFAQs_Cheat:String(File:String)
	Local curl:TCurlEasy
	Local ResultNum:Int = 0
	Local GuideList:TList = CreateList()
	
	File = Replace(Replace(File , " " , "%20") , "&" , "and")


	TFile = WriteFile(TEMPFOLDER + "PatchHTML.txt")
	curl = TCurlEasy.Create()
	'curl.setOptString(CURLOPT_POSTFIELDS, "")
	curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
	curl.setOptInt(CURLOPT_HEADER, 0)
	curl.setWriteStream(TFile)
	curl.setProgressCallback(progressCallback) 
	curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
	curl.setOptString(CURLOPT_URL, "http://www.gamefaqs.com"+File)
	Error = curl.perform()
	CloseFile(TFile) 
	If Error>0 Then 
		Return "failed to download filelist"
	EndIf	
	
	ReadHTML=ReadFile(TEMPFOLDER+"PatchHTML.txt")
	CurrentSearchLine=""
	Repeat
		CurrentSearchLine=CurrentSearchLine+ReadLine(ReadHTML)+" "
		If Eof(ReadHTML) Then Exit
	Forever
	CloseFile(ReadHTML)
	
	ReturnTagInfo(CurrentSearchLine , "<div class="+Chr(34)+"pod"+Chr(34)+">" , "</div>")

	CurrentSearchLine = ReturnTagInfo(CurrentSearchLine , "<div class="+Chr(34)+"pod"+Chr(34)+">" , "<script")
	CurrentSearchLine = Replace(CurrentSearchLine , "</h3>" , "---"+Chr(11) )
	CurrentSearchLine = Replace(CurrentSearchLine , "<h3>" , Chr(11)+"---" )
	
	CurrentSearchLine = Replace(CurrentSearchLine , "<h2 class="+Chr(34)+"title"+Chr(34)+">" , Chr(11) + Chr(11) + "------" )
	CurrentSearchLine = Replace(CurrentSearchLine , "</h2>" , "------"+Chr(11))
	CurrentSearchLine = Replace(CurrentSearchLine , "<p>" , Chr(11) )
	CurrentSearchLine = Replace(CurrentSearchLine , "</p>" , Chr(11) )
	CurrentSearchLine = Replace(CurrentSearchLine , "<table>" , Chr(11) )
	CurrentSearchLine = Replace(CurrentSearchLine , "</table>" , Chr(11) )
	CurrentSearchLine = Replace(CurrentSearchLine , "</tr>" , Chr(11) )
	CurrentSearchLine = Replace(CurrentSearchLine , "<tr>" , "" )
	CurrentSearchLine = Replace(CurrentSearchLine , "</td><td>" , ": " )
	CurrentSearchLine = Replace(CurrentSearchLine , "</th><th>" , ": " )
	
	CurrentSearchLine = RemoveTags(CurrentSearchLine)

	
	Local RawWalkHTML:String
	Local tempCurrentSearchLine:String
	Local WalkURL:String
	Local WalkName:String

	If FileType(GAMEDATAFOLDER + DownloadGame + FolderSlash+"Cheats") <> 2 Then
		PrintF("Creating Folder")
		CreateDir(GAMEDATAFOLDER + DownloadGame + FolderSlash+"Cheats")
	EndIf

	DownloadName = SanitiseFileName(DownloadName)
	Local NextLine:String = ""
	
	Writetemp = WriteFile(GAMEDATAFOLDER + DownloadGame + FolderSlash +"Cheats" + FolderSlash + DownloadName + ".txt")
	b:Int = 1
	For a = 1 To Len(CurrentSearchLine)
		If Mid(CurrentSearchLine , a , 1) = Chr(11) Then
			If NextLine = "Skip"
				NextLine = ""
				WriteLine(Writetemp , "" )
			Else
				If b=1 Then 
					WriteLine(Writetemp , "Codes Provided by http://www.gamefaqs.com "+Mid(CurrentSearchLine , b , a - b) )
				Else
					WriteLine(Writetemp , Mid(CurrentSearchLine , b , a - b) )

				EndIf
			EndIf
			If Left(Mid(CurrentSearchLine , b , a - b) , Len("Contributed By") ) = "Contributed By" Then
				NextLine = "Skip"
			EndIf
			b = a+1
		EndIf
	Next
	If NextLine = "Skip"
		NextLine = ""
	Else
		WriteLine(Writetemp , Mid(CurrentSearchLine , b , a - b) )
	EndIf 
	CloseFile(Writetemp)
	
	Return "1"
End Function 

Function Download_GFAQs:String(File:String)
	
	Local curl:TCurlEasy
	Local ResultNum:Int = 0
	Local GuideList:TList = CreateList()
	Local TFile:TStream
	
	File = Replace(Replace(File , " " , "%20") , "&" , "and")

	Message = "Getting File List..."
	
	TFile=WriteFile(TEMPFOLDER+"PatchHTML.txt")
	curl = TCurlEasy.Create()
	'curl.setOptString(CURLOPT_POSTFIELDS, "")
	curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
	curl.setProgressCallback(progressCallback) 
	curl.setOptInt(CURLOPT_HEADER, 0)
	curl.setWriteStream(TFile)
	curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
	curl.setOptString(CURLOPT_URL, "http://www.gamefaqs.com"+File)
	Error = curl.perform()
	CloseFile(TFile) 
	If Error>0 Then 
		Return "failed to download filelist"
	EndIf		
	ReadHTML=ReadFile(TEMPFOLDER+"PatchHTML.txt")
	CurrentSearchLine=""
	Repeat
		CurrentSearchLine=CurrentSearchLine+ReadLine(ReadHTML)
		If Eof(ReadHTML) Then Exit
	Forever
	CloseFile(ReadHTML)

	CurrentSearchLine = ReturnTagInfo(CurrentSearchLine , "General FAQs" , "Want to Write Your Own FAQ?")
	
	Local RawWalkHTML:String
	Local tempCurrentSearchLine:String
	Local WalkURL:String
	Local WalkName:String
	Local Guide:DownloadListObject
	Local Line:String
	Local StartWrite:Int = 0
	
	Repeat
		RawWalkHTML = ReturnTagInfo(CurrentSearchLine , "<tr" , "</tr>")

		'Print RawWalkHTML
		If RawWalkHTML = "" Then Exit
		tempCurrentSearchLine = CurrentSearchLine
		
		RawWalkHTML = ReturnTagInfo(RawWalkHTML , "<a" , "</a>")
		
		WalkURL = ReturnTagInfo(RawWalkHTML , "href="+Chr(34) , Chr(34))
		WalkName = ReturnTagInfo(RawWalkHTML , ">" , "adshfdvgdjtfidufhdf")
		
		PrintF(WalkURL)
		PrintF(WalkName)
		
		Guide = New DownloadListObject
		Guide.URL = "http://www.gamefaqs.com"+WalkURL
		Guide.Name = WalkName
		Guide.Name = SanitiseFileName(Guide.Name)
		
		If Instr(WalkName , "GameSpot") Then
		
		Else
			ListAddLast(GuideList , Guide)
		EndIf

		CurrentSearchLine = tempCurrentSearchLine
	Forever
	DownloadName = SanitiseFileName(DownloadName)
	
	DeleteCreateFolder(TEMPFOLDER + DownloadName)
	DeleteCreateFolder(GAMEDATAFOLDER + DownloadGame + FolderSlash +"Guides" +FolderSlash + DownloadName)
	
	GuideNum = GuideList.Count()
	CurrentGuideNum = 1
	For Guide = EachIn GuideList
		StartWrite = 0
		Line = ""
		Message = "Downloading Guide "+CurrentGuideNum+"/"+GuideNum+": "+Guide.Name+"..."
		TFile=WriteFile(TEMPFOLDER + DownloadName+FolderSlash+Guide.Name+".txt")
		curl = TCurlEasy.Create()
		'curl.setOptString(CURLOPT_POSTFIELDS, "")
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
		curl.setOptInt(CURLOPT_HEADER, 0)
		curl.setWriteStream(TFile)
		curl.setProgressCallback(progressCallback) 
		curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 
		curl.setOptString(CURLOPT_URL, Guide.URL)
		Error = curl.perform()
		CloseFile(TFile) 	
		If Error>0 Then 
			Return "failed to download file: "+Guide.Name
		EndIf	
		CurrentGuideNum = CurrentGuideNum + 1	
		
		ReadGuide = ReadFile(TEMPFOLDER + DownloadName + FolderSlash + Guide.Name + ".txt")
		WriteGuide = WriteFile(GAMEDATAFOLDER + DownloadGame + FolderSlash+"Guides"+FolderSlash + DownloadName + FolderSlash + Guide.Name + ".txt")
		Repeat
			Line = ReadLine(ReadGuide)
			If StartWrite = 1 Then
				If Instr(Line , "</pre>") > 0 Then
					Exit
				EndIf 
				WriteLine(WriteGuide,Line)
			Else
				If Instr(Line , "<pre>") > 0 Then
					StartWrite = 1
				EndIf 
			EndIf
		Forever
		CloseFile(WriteGuide)
		CloseFile(ReadGuide)
	Next
	
	DeleteDir(TEMPFOLDER + DownloadName,1)
	Return "1"
End Function


Function Download_RDocs:String(File:String)
	Local Dialog:DownloaderDialog = DownloaderApp.Dialog	
	Local TFile:TStream
	Local curl:TCurlEasy
	Local Code:String
	
	For a = Len(File) To 1 Step - 1
		If Mid(File , a , 1) = "." Then
			Code = Right(File,Len(File)-a)
			Exit
		EndIf
	Next
	If Code = Null Or Code = "" Then
		Return "failed to extract manual code"
	EndIf 

	DownloadName = SanitiseFileName(DownloadName)
	
	Message = "Downloading File: "+DownloadName+".pdf"
	curl = TCurlEasy.Create()
	TFile=WriteFile(TEMPFOLDER+DownloadName+".pdf")
	curl.setOptString(CURLOPT_URL, "http://www.replacementdocs.com/request.php?"+Code)
	curl.setWriteStream(TFile)
	curl.setProgressCallback(progressCallback) 
	Error=curl.perform()
	PrintF( Error)
	CloseFile(TFile)
	If Error>0 Then 
		Return "failed to download file"
	EndIf	

	If FileType(GAMEDATAFOLDER + DownloadGame + FolderSlash+"Manuals") <> 2 Then
		PrintF( "Creating Folder")
		CreateDir(GAMEDATAFOLDER + DownloadGame + FolderSlash+"Manuals")
	EndIf

	RenameFile(TEMPFOLDER+DownloadName+".pdf" , GAMEDATAFOLDER + DownloadGame + FolderSlash+"Manuals"+FolderSlash+DownloadName+".pdf")

	Return "1"
End Function 

Function Download_PScrolls:String(File$)
	Local Dialog:DownloaderDialog = DownloaderApp.Dialog	
	Local TFile:TStream
	Local curl:TCurlEasy
	
	Message = "Aquiring Download Page..."
	
	curl = TCurlEasy.Create()
	TFile=WriteFile(TEMPFOLDER+"PatchHTML.txt")
	curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
	curl.setOptInt(CURLOPT_HEADER, 0)	
	curl.setWriteStream(TFile)
	curl.setProgressCallback(progressCallback)	
	curl.setOptString(CURLOPT_URL, "http://dlh.net/cgi-bin/dlp.cgi?"+File)
	Error=curl.perform()

	CloseFile(TFile)
	If Error>0 Then 				
		Return "failed to aquire download page"
	EndIf

	
	TFile = ReadFile(TEMPFOLDER+"PatchHTML.txt")
	CurrentSearchLine=""
	While Not TFile.Eof()
		CurrentSearchLine=CurrentSearchLine+TFile.ReadLine()
	Wend
	CloseFile(TFile)

	File=ReturnTagInfo(CurrentSearchLine,"><script language="+Chr(34)+"javascript"+Chr(34)+" src="+Chr(34)+"http://dlh.net/js_dl.php?",Chr(34)+"></script>")
	PrintF( "First File: "+File)


		
	Message = "Aquiring Download Links..."
	TFile=WriteFile(TEMPFOLDER+"PatchHTML.txt")
	curl.setWriteStream(TFile)
	curl.setOptString(CURLOPT_URL, "http://dlh.net/js_dl.php?"+File)
	curl.setProgressCallback(progressCallback)
	Error=curl.perform()

	CloseFile(TFile)
	If Error>0 Then 			
		Return "failed to aquire download link"
	EndIf	
	TFile = ReadFile(TEMPFOLDER+"PatchHTML.txt")
	CurrentSearchLine=""
	While Not TFile.Eof()

		CurrentSearchLine=CurrentSearchLine+TFile.ReadLine()
	Wend
	CloseFile(TFile)

	Local FTPMirror:String
	Local FileFrontMirror:String	
	
	Repeat
	
		File=ReturnTagInfo(CurrentSearchLine,"<a class=a href="+Chr(34),Chr(34)+">")
		If File="" Then Exit

		ReturnTagInfo(CurrentSearchLine,"<td align=center>","</td>")
		DownloadType$=ReturnTagInfo(CurrentSearchLine,"<td align=center>","</td>")
		If DownloadType$="&nbsp;-&nbsp;" Then
			FTPMirror=File
		ElseIf DownloadType$="&nbsp;<a href="+Chr(34)+"http://www.filefront.com/"+Chr(34)+">FileFront</A>&nbsp;"
			FileFrontMirror=File		
		EndIf	
		
	Forever
	
	PrintF( "FF: "+FileFrontMirror)
	PrintF( "FTP: "+FTPMirror)
	If FileFrontMirror="" Then
		If FTPMirror="" Then
			CustomRuntimeError("Error 206: It apears that there is no download links for this game. If this keeps happening then the website has been updated and needs a update of PatchDownloader before this feature will work") 'MARK: Error 206
		Else
			DownloadPath:String=FTPMirror
			DownloadFile:String=GetFileNameFTP(DownloadPath)
			Message = "Loading FTP Link..."
			
		EndIf
	Else
		File=FileFrontMirror
		Message = "Filtering Raw HTML..."
		TFile=WriteFile(TEMPFOLDER+"PatchHTML.txt")
		curl.setWriteStream(TFile)
		curl.setOptString(CURLOPT_COOKIEFILE, TEMPFOLDER+"cookie.txt") 	
		curl.setOptString(CURLOPT_URL, File)
		curl.setProgressCallback(progressCallback)	
		Error=curl.perform()
		PrintF( Error)
		CloseFile(TFile)
		If Error>0 Then 						
			Return "failed to filter raw HTML"
		EndIf	
		TFile = ReadFile(TEMPFOLDER+"PatchHTML.txt")
		CurrentSearchLine=""
		While Not TFile.Eof()
			CurrentSearchLine=CurrentSearchLine+TFile.ReadLine()
		Wend
		CloseFile(TFile)	
		File=ReturnTagInfo(CurrentSearchLine,"<div class="+Chr(34)+"action"+Chr(34)+">											<a href="+Chr(34),Chr(34)+" class=")
		PrintF( "Third File: "+File)
		
		Message = "Loading FileFront Link..."
		TFile=WriteFile(TEMPFOLDER+"PatchHTML.txt")
		curl.setWriteStream(TFile)
		curl.setOptString(CURLOPT_URL, File)
		curl.setOptInt(CURLOPT_HEADER, 0)	
		curl.setProgressCallback(progressCallback)		
		Error=curl.perform()
		PrintF( Error)
		CloseFile(TFile)
		If Error>0 Then 	
			Return "failed to load FileFront link"
		EndIf	
		TFile = ReadFile(TEMPFOLDER+"PatchHTML.txt")
		CurrentSearchLine=""
		While Not TFile.Eof()
			CurrentSearchLine=CurrentSearchLine+TFile.ReadLine()
		Wend
		CloseFile(TFile)
		DownloadPath:String=ReturnTagInfo(CurrentSearchLine,"If it does not, <a href="+Chr(34),Chr(34)+">click here</a>")
		DownloadFile:String=GetFileName$(DownloadPath)
	EndIf
		
	'Replace(,"/","\")
	'SavePath:String=FixSlashs(PatchFilePath+GameName+"/")+DownloadFile
	SavePath:String = TEMPFOLDER+DownloadFile
	PrintF( "DownloadPath: "+DownloadPath)
	PrintF( "DownloadFile: "+DownloadFile)
	PrintF( "SavePath: "+SavePath)
	
	'SetGadgetText(FileLabel,"Downloading File: "+DownloadFile)
	Message = "Downloading File: "+DownloadFile

	DownloadSpeedTimer=MilliSecs()
	Downloaded = 0	
	
	TFile=WriteFile(SavePath)
	curl.setOptString(CURLOPT_URL, DownloadPath)
	curl.setWriteStream(TFile)
	curl.setProgressCallback(progressCallback) 
	Error=curl.perform()
	PrintF( Error)
	CloseFile(TFile)
	If Error>0 Then 
		DeleteFile(SavePath)
		Return "failed to download file"
	EndIf	
	PrintF( GAMEDATAFOLDER + DownloadGame + FolderSlash+"Patches")
	If FileType(GAMEDATAFOLDER + DownloadGame + FolderSlash+"Patches") <> 2 Then
		PrintF( "Creating Folder")
		CreateDir(GAMEDATAFOLDER + DownloadGame + FolderSlash +"Patches")
	EndIf
	PrintF( "Moveing")
	PrintF( SavePath)
	PrintF( GAMEDATAFOLDER + DownloadGame + FolderSlash +"Patches"+FolderSlash+DownloadFile)

	If FileType(GAMEDATAFOLDER + DownloadGame + FolderSlash+"Patches"+FolderSlash + StripExt(DownloadFile) ) <> 2 Then
		DeleteCreateFolder(GAMEDATAFOLDER + DownloadGame + FolderSlash+"Patches"+FolderSlash + StripExt(DownloadFile))
	EndIf 	
	
	If ExtractExt(SavePath) = ".exe" Then
		RenameFile(SavePath , GAMEDATAFOLDER + DownloadGame + FolderSlash+"Patches"+FolderSlash+StripExt(DownloadFile)+FolderSlash+DownloadFile)
	Else
		Message = "Extracting Patch..."
		Local zipProc:TProcess=TProcess.Create(SevenZipPath+" e -aoa -y -o"+Chr(34)+GAMEDATAFOLDER + DownloadGame + FolderSlash+"Patches"+FolderSlash+StripExt(DownloadFile)+Chr(34)+" "+Chr(34)+SavePath+Chr(34),0)
		PrintF( "EXTRACT: "+SevenZipPath+" e -aoa -y -o"+Chr(34)+GAMEDATAFOLDER + DownloadGame + FolderSlash+"Patches"+FolderSlash+StripExt(DownloadFile)+Chr(34)+" "+Chr(34)+SavePath+Chr(34))
		
		Local s:String 
		Repeat 
			Dialog.Pulse(Message , a)
			DownloaderApp.Yield()
			If ProcessStatus(zipProc)=0 Then
				Exit
			EndIf
			While zipProc.pipe.readavail()
				s=zipProc.pipe.ReadLine().Trim()
				PrintF( s)
			Wend		
	
		Forever
		While zipProc.pipe.readavail()
			s=zipProc.pipe.ReadLine().Trim()
			PrintF( s)
		Wend			
	EndIf
	
	DeleteFile(SavePath)
	Return "1"
End Function

Type SettingsType
	'Dummy Type
	
End Type

Type DownloadListObject
	Field URL:String
	Field Name:String
End Type


Function ReturnTagInfo$(SearchLine$,Tag$,EndTag$,Debug=False)
	Rem
	Function:	Finds first instance of Tag and EndTag in SearchLine and returns the characters inbetween
			Sets CurrentSearchLine to the rest of SearchLine(Bit not containing Tag/EndTag)
	Input:	SearchLine - The String to search within
			Tag - The start term
			EndTag - The end term
	Return:	The string containing the characters between tags
	SubCalls:	None
	EndRem
	If Debug Then
		Print SearchLine
		Print Tag
		Print EndTag
	EndIf
	StartPos=0
	EndPos=0
	Found=False
	For a=1 To Len(SearchLine)-Len(Tag)
		If Mid(SearchLine,a,Len(Tag))=Tag$ Then
			StartPos=a+Len(Tag)
			If Debug Then Print StartPos
			Found=True
			Exit
		EndIf
	Next
	If Found=True Then
	For a=1 To Len(SearchLine)-Len(Tag)-StartPos
		If Mid(SearchLine,a+StartPos,Len(EndTag))=EndTag$ Then
			EndPos=a+StartPos
			If Debug Then Print EndPos
			CurrentSearchLine=Right(SearchLine,Len(SearchLine)-EndPos)
			Exit			
		EndIf
	Next	
	EndIf
	Return Mid(SearchLine,StartPos,EndPos-StartPos)
End Function

Function GetFileNameFTP$(TheFile:String)
	For b=Len(TheFile) To 1 Step -1 
		If Mid(TheFile,b,1)="/" Then
			TheFile=Right(TheFile,Len(TheFile)-b)
			Exit
		EndIf
	Next
	Return TheFile
End Function

Function GetFileName$(TheFile:String)
	For a=1 To Len(TheFile)
		If Mid(TheFile,a,1)="?" Then
			TheFile=Left(TheFile,a-1)
			Exit
		EndIf
	Next 
	For b=Len(TheFile) To 1 Step -1 
		If Mid(TheFile,b,1)="/" Then
			TheFile=Right(TheFile,Len(TheFile)-b)
			Exit
		EndIf
	Next
	Return TheFile
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
		CustomRuntimeError("Error 207: Cannot Delete Folder "+Folder) 'MARK: Error 207
	EndIf
	For a = 1 To 20
		If FileType(Folder)=0 Then
			CreateDir(Folder,1)
			Delay 100
		Else
			Exit
		EndIf
	Next	
	PrintF("CreateDir Loop "+a)
	If FileType(Folder) = 0 Then
		CustomRuntimeError("Error 208: Cannot Create Folder "+Folder) 'MARK: Error 208
	EndIf
End Function

Function PrintF(Tex:String)
	If Debug = True Then
		Print Tex
	Else
		If DebugLogEnabled = True Then 
			WriteLog = OpenFile(LOGFOLDER + LogName)
			SeekStream(WriteLog,StreamSize(WriteLog))
			WriteLog.WriteLine(Tex)
			CloseFile(WriteLog)
		EndIf
	EndIf
End Function

Function CustomRuntimeError(ERROR:String)
	PrintF(ERROR)
	'DebugStop()
	If Debug = True Then
		RuntimeError ERROR
	Else
		Notify Error
	EndIf 
	End
End Function

Function SanitiseFileName:String(File:String)
	File = Replace(File , ":" , "")
	File = Replace(File , "/" , "-")
	File = Replace(File , "\" , "-")
	File = Replace(File , "&#039;" , "'")
	Return File
End Function

Function RemoveTags:String(Tex:String)
	Repeat
	Start = - 1
	Finish = - 1
	
		For a = 1 To Len(Tex)
			If Mid(Tex , a , 1) = "<" Then
				Start = a
			EndIf
			If Mid(Tex , a , 1) = ">" Then
				Finish = a
			EndIf 	
			If Start <> - 1 And Finish <> - 1 Then
				Tex = Replace(Tex , Mid(tex , Start , Finish - Start + 1) , "")

				Exit
			EndIf 	
		Next
		If Start = - 1 And Finish = - 1 Then
			Exit
		EndIf
	Forever
	Return Tex
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
	PrintF("CreateDir Loop "+a)
	If FileType(Folder) = 0 Then
		CustomRuntimeError("Error 11: Cannot Create Folder "+Folder) 'MARK: Error 11
	EndIf
End Function


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
?