Local Version:String = "1"
Local SubVersion:String = "1"
Local SubSubVersion:String = "0"

Local RCStream:TStream 
RCStream = WriteFile("PhotonDownloader.rc")
WriteLine(RCStream,"101 ICON "+Chr(34)+"Internet.ico"+Chr(34)+"")
WriteLine(RCStream,"")
WriteLine(RCStream,"1 VERSIONINFO ")
WriteLine(RCStream,"FILEVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"PRODUCTVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"FILEOS 0x40004")
WriteLine(RCStream,"FILETYPE 0x1")
WriteLine(RCStream,"{ ")
WriteLine(RCStream,"BLOCK "+Chr(34)+"StringFileInfo"+Chr(34)+" ")
WriteLine(RCStream,"{ ")
WriteLine(RCStream," BLOCK "+Chr(34)+"040904b0"+Chr(34)+" ")
WriteLine(RCStream," { ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Comments"+Chr(34)+", "+Chr(34)+"CommandLine tool for PhotonExplorer and PhotonFrontEnd"+Chr(34)+"")
WriteLine(RCStream,"  VALUE "+Chr(34)+"CompanyName"+Chr(34)+", "+Chr(34)+"Photon Software"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileDescription"+Chr(34)+", "+Chr(34)+"PhotonDownloader"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"InternalName"+Chr(34)+", "+Chr(34)+"PhotonDownloader"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalCopyright"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalTrademarks"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"OriginalFilename"+Chr(34)+", "+Chr(34)+"PhotonDownloader.exe"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductName"+Chr(34)+", "+Chr(34)+"Photon GameManager"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream," } ")
WriteLine(RCStream,"}")
WriteLine(RCStream,"BLOCK "+Chr(34)+"VarFileInfo"+Chr(34)+"")
WriteLine(RCStream,"{")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Translation"+Chr(34)+", 0x0409, 0")
WriteLine(RCStream,"}")
WriteLine(RCStream,"}")
CloseFile(RCStream)


RCStream = WriteFile("PhotonExplorer.rc")
WriteLine(RCStream,"101 ICON "+Chr(34)+"Controller.ico"+Chr(34)+"")
WriteLine(RCStream,"")
WriteLine(RCStream,"1 VERSIONINFO ")
WriteLine(RCStream,"FILEVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"PRODUCTVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"FILEOS 0x40004")
WriteLine(RCStream,"FILETYPE 0x1")
WriteLine(RCStream,"{ ")
WriteLine(RCStream,"BLOCK "+Chr(34)+"StringFileInfo"+Chr(34)+" ")
WriteLine(RCStream,"{ ")
WriteLine(RCStream," BLOCK "+Chr(34)+"040904b0"+Chr(34)+" ")
WriteLine(RCStream," { ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Comments"+Chr(34)+", "+Chr(34)+"Photon Explorer allows you to view, update and play your games from a friendly windowed interface. It is part of the Photon GameManager Suite."+Chr(34)+"")
WriteLine(RCStream,"  VALUE "+Chr(34)+"CompanyName"+Chr(34)+", "+Chr(34)+"Photon Software"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileDescription"+Chr(34)+", "+Chr(34)+"PhotonExplorer"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"InternalName"+Chr(34)+", "+Chr(34)+"PhotonExplorer"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalCopyright"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalTrademarks"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"OriginalFilename"+Chr(34)+", "+Chr(34)+"PhotonExplorer.exe"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductName"+Chr(34)+", "+Chr(34)+"Photon GameManager"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream," } ")
WriteLine(RCStream,"}")
WriteLine(RCStream,"BLOCK "+Chr(34)+"VarFileInfo"+Chr(34)+"")
WriteLine(RCStream,"{")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Translation"+Chr(34)+", 0x0409, 0")
WriteLine(RCStream,"}")
WriteLine(RCStream,"}")
CloseFile(RCStream)

RCStream = WriteFile("PhotonFrontEnd.rc")
WriteLine(RCStream,"101 ICON "+Chr(34)+"GamesCab.ico"+Chr(34)+"")
WriteLine(RCStream,"")
WriteLine(RCStream,"1 VERSIONINFO ")
WriteLine(RCStream,"FILEVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"PRODUCTVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"FILEOS 0x40004")
WriteLine(RCStream,"FILETYPE 0x1")
WriteLine(RCStream,"{ ")
WriteLine(RCStream,"BLOCK "+Chr(34)+"StringFileInfo"+Chr(34)+" ")
WriteLine(RCStream,"{ ")
WriteLine(RCStream," BLOCK "+Chr(34)+"040904b0"+Chr(34)+" ")
WriteLine(RCStream," { ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Comments"+Chr(34)+", "+Chr(34)+"Photon FrontEnd allows you to view, update and play your games from a friendly fullscreen interface. It is part of the Photon GameManager Suite."+Chr(34)+"")
WriteLine(RCStream,"  VALUE "+Chr(34)+"CompanyName"+Chr(34)+", "+Chr(34)+"Photon Software"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileDescription"+Chr(34)+", "+Chr(34)+"PhotonFrontEnd"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"InternalName"+Chr(34)+", "+Chr(34)+"PhotonFrontEnd"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalCopyright"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalTrademarks"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"OriginalFilename"+Chr(34)+", "+Chr(34)+"PhotonFrontEnd.exe"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductName"+Chr(34)+", "+Chr(34)+"Photon GameManager"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream," } ")
WriteLine(RCStream,"}")
WriteLine(RCStream,"BLOCK "+Chr(34)+"VarFileInfo"+Chr(34)+"")
WriteLine(RCStream,"{")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Translation"+Chr(34)+", 0x0409, 0")
WriteLine(RCStream,"}")
WriteLine(RCStream,"}")
CloseFile(RCStream)

RCStream = WriteFile("PhotonManager.rc")
WriteLine(RCStream,"101 ICON "+Chr(34)+"Database.ico"+Chr(34)+"")
WriteLine(RCStream,"")
WriteLine(RCStream,"1 VERSIONINFO ")
WriteLine(RCStream,"FILEVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"PRODUCTVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"FILEOS 0x40004")
WriteLine(RCStream,"FILETYPE 0x1")
WriteLine(RCStream,"{ ")
WriteLine(RCStream,"BLOCK "+Chr(34)+"StringFileInfo"+Chr(34)+" ")
WriteLine(RCStream,"{ ")
WriteLine(RCStream," BLOCK "+Chr(34)+"040904b0"+Chr(34)+" ")
WriteLine(RCStream," { ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Comments"+Chr(34)+", "+Chr(34)+"Use PhotonManager to add games to GameManagers database. It is part of the Photon GameManager Suite."+Chr(34)+"")
WriteLine(RCStream,"  VALUE "+Chr(34)+"CompanyName"+Chr(34)+", "+Chr(34)+"Photon Software"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileDescription"+Chr(34)+", "+Chr(34)+"PhotonManager"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"InternalName"+Chr(34)+", "+Chr(34)+"PhotonManager"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalCopyright"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalTrademarks"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"OriginalFilename"+Chr(34)+", "+Chr(34)+"PhotonManager.exe"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductName"+Chr(34)+", "+Chr(34)+"Photon GameManager"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream," } ")
WriteLine(RCStream,"}")
WriteLine(RCStream,"BLOCK "+Chr(34)+"VarFileInfo"+Chr(34)+"")
WriteLine(RCStream,"{")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Translation"+Chr(34)+", 0x0409, 0")
WriteLine(RCStream,"}")
WriteLine(RCStream,"}")
CloseFile(RCStream)

RCStream = WriteFile("PhotonUpdater.rc")
WriteLine(RCStream,"101 ICON "+Chr(34)+"Internet.ico"+Chr(34)+"")
WriteLine(RCStream,"")
WriteLine(RCStream,"1 VERSIONINFO ")
WriteLine(RCStream,"FILEVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"PRODUCTVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream,"FILEOS 0x40004")
WriteLine(RCStream,"FILETYPE 0x1")
WriteLine(RCStream,"{ ")
WriteLine(RCStream,"BLOCK "+Chr(34)+"StringFileInfo"+Chr(34)+" ")
WriteLine(RCStream,"{ ")
WriteLine(RCStream," BLOCK "+Chr(34)+"040904b0"+Chr(34)+" ")
WriteLine(RCStream," { ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Comments"+Chr(34)+", "+Chr(34)+"Updates Photon GameManager"+Chr(34)+"")
WriteLine(RCStream,"  VALUE "+Chr(34)+"CompanyName"+Chr(34)+", "+Chr(34)+"Photon Software"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileDescription"+Chr(34)+", "+Chr(34)+"PhotonUpdater"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"InternalName"+Chr(34)+", "+Chr(34)+"PhotonUpdater"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalCopyright"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalTrademarks"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"OriginalFilename"+Chr(34)+", "+Chr(34)+"PhotonUpdater.exe"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductName"+Chr(34)+", "+Chr(34)+"Photon GameManager"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream," } ")
WriteLine(RCStream,"}")
WriteLine(RCStream,"BLOCK "+Chr(34)+"VarFileInfo"+Chr(34)+"")
WriteLine(RCStream,"{")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Translation"+Chr(34)+", 0x0409, 0")
WriteLine(RCStream,"}")
WriteLine(RCStream,"}")
CloseFile(RCStream)


Local Proc:Tprocess = CreateProcess("CreateO.bat")
Repeat 
	If ProcessStatus(Proc)=0 Then Exit
	If Proc.pipe.ReadAvail() Then
		pipedata:String = Proc.pipe.ReadLine().Trim()
		If pipedata <> "" Then
			Print pipedata
		EndIf
	EndIf 
	Delay 100
Forever
End 
