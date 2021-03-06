

Local ReadVersion:TStream = ReadFile("../Code/Version/OverallVersion.txt")
Local VersionRead:String = ReadLine(ReadVersion)
CloseFile(ReadVersion)

Local Version:String
Local SubVersion:String
If Len(VersionRead) > 1 then
	Version = Left(VersionRead, 1)
	SubVersion = Right(VersionRead,1)
Else If Len(VersionRead) = 1 then
	Version = "0"
	SubVersion = Right(VersionRead, 1)
Else
	Notify "Incorrect Version File"
EndIf

Local SubSubVersion:String = "0"
Local BlitzFolder:String = "C:/BlitzMax/mod/wx.mod/"
Local MinGW:String = "C:\MinGW32\bin"
Local IconPath:String = CurrentDir() + "/"

Local RCStream:TStream
Local BatStream:TStream

'-------------------------------------------------PHOTON-DOWNLOADER------------------------------------------------
RCStream = WriteFile("PhotonDownloader.rc")
WriteLine(RCStream, "101 ICON " + Chr(34) + "Internet.ico" + Chr(34) + "")
WriteLine(RCStream,"")
WriteLine(RCStream,"1 VERSIONINFO ")
WriteLine(RCStream, "FILEVERSION 4," + Version + "," + SubVersion + "," + SubSubVersion + " ")
WriteLine(RCStream,"PRODUCTVERSION 4,"+Version+","+SubVersion+","+SubSubVersion+" ")
WriteLine(RCStream, "FILEOS 0x40004")
WriteLine(RCStream,"FILETYPE 0x1")
WriteLine(RCStream,"{ ")
WriteLine(RCStream,"BLOCK "+Chr(34)+"StringFileInfo"+Chr(34)+" ")
WriteLine(RCStream,"{ ")
WriteLine(RCStream," BLOCK "+Chr(34)+"040904b0"+Chr(34)+" ")
WriteLine(RCStream," { ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Comments"+Chr(34)+", "+Chr(34)+"CommandLine tool for PhotonExplorer and PhotonFrontEnd"+Chr(34)+"")
WriteLine(RCStream, "  VALUE " + Chr(34) + "CompanyName" + Chr(34) + ", " + Chr(34) + "Photon Software" + Chr(34) + " ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileDescription"+Chr(34)+", "+Chr(34)+"PhotonDownloader"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"InternalName"+Chr(34)+", "+Chr(34)+"PhotonDownloader"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalCopyright"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalTrademarks"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"OriginalFilename"+Chr(34)+", "+Chr(34)+"PhotonDownloader.exe"+Chr(34)+" ")
WriteLine(RCStream, "  VALUE " + Chr(34) + "ProductName" + Chr(34) + ", " + Chr(34) + "Photon GameManager" + Chr(34) + " ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream," } ")
WriteLine(RCStream,"}")
WriteLine(RCStream,"BLOCK "+Chr(34)+"VarFileInfo"+Chr(34)+"")
WriteLine(RCStream,"{")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Translation"+Chr(34)+", 0x0409, 0")
WriteLine(RCStream,"}")
WriteLine(RCStream,"}")
CloseFile(RCStream)

'-------------------------------------------------PHOTON-EXPLORER------------------------------------------------
RCStream = WriteFile("PhotonExplorer.rc")

WriteLine(RCStream, "#include <windows.h>")
WriteLine(RCStream, "#if defined(_WIN32_WCE)")
WriteLine(RCStream, "    #include " + Chr(34) + BlitzFolder + "include/wx/msw/wince/wince.rc" + Chr(34) )
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#include " + Chr(34) + BlitzFolder + "include/wx/msw/rcdefs.h" + Chr(34) )
WriteLine(RCStream, "wxWindowMenu MENU DISCARDABLE")
WriteLine(RCStream, "BEGIN")
WriteLine(RCStream, "    POPUP " + Chr(34) + "&Window" + Chr(34) + "")
WriteLine(RCStream, "    BEGIN")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Cascade" + Chr(34) + ",                    4002")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "Tile &Horizontally" + Chr(34) + ",          4001")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "Tile &Vertically" + Chr(34) + ",            4005")
WriteLine(RCStream, "	MENUITEM " + Chr(34) + "" + Chr(34) + ", -1")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Arrange Icons" + Chr(34) + ",              4003")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Next" + Chr(34) + ",                       4004")
WriteLine(RCStream, "    END")
WriteLine(RCStream, "END")
WriteLine(RCStream, "WXCURSOR_HAND           CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/hand.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_BULLSEYE       CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/bullseye.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PENCIL         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pencil.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_MAGNIFIER      CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/magnif1.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_ROLLER         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/roller.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PBRUSH         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pbrush.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PLEFT          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pntleft.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PRIGHT         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pntright.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_BLANK          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/blank.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_CROSS          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/cross.cur" + Chr(34) )
WriteLine(RCStream, "wxICON_AAA                      ICON " + Chr(34) + "Explorer.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_CLOSED_FOLDER      ICON " + Chr(34) + BlitzFolder + "include/wx/msw/folder1.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_OPEN_FOLDER        ICON " + Chr(34) + BlitzFolder + "include/wx/msw/folder2.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_FILE               ICON " + Chr(34) + BlitzFolder + "include/wx/msw/file1.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_COMPUTER           ICON " + Chr(34) + BlitzFolder + "include/wx/msw/computer.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_DRIVE              ICON " + Chr(34) + BlitzFolder + "include/wx/msw/drive.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_CDROM              ICON " + Chr(34) + BlitzFolder + "include/wx/msw/cdrom.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_FLOPPY             ICON " + Chr(34) + BlitzFolder + "include/wx/msw/floppy.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_REMOVEABLE         ICON " + Chr(34) + BlitzFolder + "include/wx/msw/removble.ico" + Chr(34) )
WriteLine(RCStream, "csquery                 BITMAP " + Chr(34) + BlitzFolder + "include/wx/msw/csquery.bmp" + Chr(34) )
WriteLine(RCStream, "wxBITMAP_STD_COLOURS    BITMAP " + Chr(34) + BlitzFolder + "include/wx/msw/colours.bmp" + Chr(34) )
WriteLine(RCStream, "#if !defined(wxUSE_NO_MANIFEST) || (wxUSE_NO_MANIFEST == 0)")
WriteLine(RCStream, "#if defined(wxUSE_RC_MANIFEST) && wxUSE_RC_MANIFEST")
WriteLine(RCStream, "#ifdef ISOLATION_AWARE_ENABLED")
WriteLine(RCStream, "#define wxMANIFEST_ID 2")
WriteLine(RCStream, "#else")
WriteLine(RCStream, "#define wxMANIFEST_ID 1")
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#if defined(WX_CPU_AMD64)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/amd64.manifest" + Chr(34) )
WriteLine(RCStream, "#elif defined(WX_CPU_IA64)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/ia64.manifest" + Chr(34) )
WriteLine(RCStream, "#elif defined(WX_CPU_X86)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/wx.manifest" + Chr(34) )
WriteLine(RCStream, "#else")
WriteLine(RCStream, "#error " + Chr(34) + "One of WX_CPU_XXX constants must be defined. See comment above." + Chr(34) )
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#endif")

WriteLine(RCStream, "")
WriteLine(RCStream,"1 VERSIONINFO ")
WriteLine(RCStream, "FILEVERSION 4," + Version + "," + SubVersion + "," + SubSubVersion + " ")
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

'-------------------------------------------------PHOTON-FRONTEND------------------------------------------------
RCStream = WriteFile("PhotonFrontEnd.rc")
WriteLine(RCStream, "101 ICON " + Chr(34) + "FrontEnd.ico" + Chr(34) + "")
WriteLine(RCStream, "")
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
WriteLine(RCStream, "}")
CloseFile(RCStream)


'-------------------------------------------------PHOTON-MANAGER------------------------------------------------
RCStream = WriteFile("PhotonManager.rc")

WriteLine(RCStream, "#include <windows.h>")
WriteLine(RCStream, "#if defined(_WIN32_WCE)")
WriteLine(RCStream, "    #include " + Chr(34) + BlitzFolder + "include/wx/msw/wince/wince.rc" + Chr(34) )
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#include " + Chr(34) + BlitzFolder + "include/wx/msw/rcdefs.h" + Chr(34) )
WriteLine(RCStream, "wxWindowMenu MENU DISCARDABLE")
WriteLine(RCStream, "BEGIN")
WriteLine(RCStream, "    POPUP " + Chr(34) + "&Window" + Chr(34) + "")
WriteLine(RCStream, "    BEGIN")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Cascade" + Chr(34) + ",                    4002")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "Tile &Horizontally" + Chr(34) + ",          4001")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "Tile &Vertically" + Chr(34) + ",            4005")
WriteLine(RCStream, "	MENUITEM " + Chr(34) + "" + Chr(34) + ", -1")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Arrange Icons" + Chr(34) + ",              4003")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Next" + Chr(34) + ",                       4004")
WriteLine(RCStream, "    END")
WriteLine(RCStream, "END")
WriteLine(RCStream, "WXCURSOR_HAND           CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/hand.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_BULLSEYE       CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/bullseye.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PENCIL         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pencil.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_MAGNIFIER      CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/magnif1.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_ROLLER         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/roller.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PBRUSH         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pbrush.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PLEFT          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pntleft.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PRIGHT         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pntright.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_BLANK          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/blank.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_CROSS          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/cross.cur" + Chr(34) )
WriteLine(RCStream, "wxICON_AAA                      ICON " + Chr(34) + "Manager.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_CLOSED_FOLDER      ICON " + Chr(34) + BlitzFolder + "include/wx/msw/folder1.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_OPEN_FOLDER        ICON " + Chr(34) + BlitzFolder + "include/wx/msw/folder2.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_FILE               ICON " + Chr(34) + BlitzFolder + "include/wx/msw/file1.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_COMPUTER           ICON " + Chr(34) + BlitzFolder + "include/wx/msw/computer.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_DRIVE              ICON " + Chr(34) + BlitzFolder + "include/wx/msw/drive.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_CDROM              ICON " + Chr(34) + BlitzFolder + "include/wx/msw/cdrom.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_FLOPPY             ICON " + Chr(34) + BlitzFolder + "include/wx/msw/floppy.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_REMOVEABLE         ICON " + Chr(34) + BlitzFolder + "include/wx/msw/removble.ico" + Chr(34) )
WriteLine(RCStream, "csquery                 BITMAP " + Chr(34) + BlitzFolder + "include/wx/msw/csquery.bmp" + Chr(34) )
WriteLine(RCStream, "wxBITMAP_STD_COLOURS    BITMAP " + Chr(34) + BlitzFolder + "include/wx/msw/colours.bmp" + Chr(34) )
WriteLine(RCStream, "#if !defined(wxUSE_NO_MANIFEST) || (wxUSE_NO_MANIFEST == 0)")
WriteLine(RCStream, "#if defined(wxUSE_RC_MANIFEST) && wxUSE_RC_MANIFEST")
WriteLine(RCStream, "#ifdef ISOLATION_AWARE_ENABLED")
WriteLine(RCStream, "#define wxMANIFEST_ID 2")
WriteLine(RCStream, "#else")
WriteLine(RCStream, "#define wxMANIFEST_ID 1")
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#if defined(WX_CPU_AMD64)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/amd64.manifest" + Chr(34) )
WriteLine(RCStream, "#elif defined(WX_CPU_IA64)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/ia64.manifest" + Chr(34) )
WriteLine(RCStream, "#elif defined(WX_CPU_X86)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/wx.manifest" + Chr(34) )
WriteLine(RCStream, "#else")
WriteLine(RCStream, "#error " + Chr(34) + "One of WX_CPU_XXX constants must be defined. See comment above." + Chr(34) )
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#endif")

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

'-------------------------------------------------PHOTON-UPDATER------------------------------------------------
RCStream = WriteFile("PhotonUpdater.rc")
WriteLine(RCStream, "101 ICON " + Chr(34) + "Updater.ico" + Chr(34) + "")
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
WriteLine(RCStream, " { ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Comments"+Chr(34)+", "+Chr(34)+"Updates Photon GameManager"+Chr(34)+"")
WriteLine(RCStream,"  VALUE "+Chr(34)+"CompanyName"+Chr(34)+", "+Chr(34)+"Photon Software"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileVersion"+Chr(34)+", "+Chr(34)+"4."+Version+"."+SubVersion+"."+SubSubVersion+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"FileDescription"+Chr(34)+", "+Chr(34)+"PhotonUpdater"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"InternalName"+Chr(34)+", "+Chr(34)+"PhotonUpdater"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalCopyright"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"LegalTrademarks"+Chr(34)+", "+Chr(34)+""+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"OriginalFilename"+Chr(34)+", "+Chr(34)+"PhotonUpdater.exe"+Chr(34)+" ")
WriteLine(RCStream,"  VALUE "+Chr(34)+"ProductName"+Chr(34)+", "+Chr(34)+"Photon GameManager"+Chr(34)+" ")
WriteLine(RCStream, "  VALUE " + Chr(34) + "ProductVersion" + Chr(34) + ", " + Chr(34) + "4." + Version + "." + SubVersion + "." + SubSubVersion + "" + Chr(34) + " ")
WriteLine(RCStream," } ")
WriteLine(RCStream,"}")
WriteLine(RCStream,"BLOCK "+Chr(34)+"VarFileInfo"+Chr(34)+"")
WriteLine(RCStream,"{")
WriteLine(RCStream,"  VALUE "+Chr(34)+"Translation"+Chr(34)+", 0x0409, 0")
WriteLine(RCStream,"}")
WriteLine(RCStream,"}")
CloseFile(RCStream)

'-------------------------------------------------PHOTON-RUNNER------------------------------------------------
RCStream = WriteFile("PhotonRunner.rc")

WriteLine(RCStream, "#include <windows.h>")
WriteLine(RCStream, "#if defined(_WIN32_WCE)")
WriteLine(RCStream, "    #include " + Chr(34) + BlitzFolder + "include/wx/msw/wince/wince.rc" + Chr(34) )
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#include " + Chr(34) + BlitzFolder + "include/wx/msw/rcdefs.h" + Chr(34) )
WriteLine(RCStream, "wxWindowMenu MENU DISCARDABLE")
WriteLine(RCStream, "BEGIN")
WriteLine(RCStream, "    POPUP " + Chr(34) + "&Window" + Chr(34) + "")
WriteLine(RCStream, "    BEGIN")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Cascade" + Chr(34) + ",                    4002")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "Tile &Horizontally" + Chr(34) + ",          4001")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "Tile &Vertically" + Chr(34) + ",            4005")
WriteLine(RCStream, "	MENUITEM " + Chr(34) + "" + Chr(34) + ", -1")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Arrange Icons" + Chr(34) + ",              4003")
WriteLine(RCStream, "        MENUITEM " + Chr(34) + "&Next" + Chr(34) + ",                       4004")
WriteLine(RCStream, "    END")
WriteLine(RCStream, "END")
WriteLine(RCStream, "WXCURSOR_HAND           CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/hand.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_BULLSEYE       CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/bullseye.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PENCIL         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pencil.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_MAGNIFIER      CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/magnif1.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_ROLLER         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/roller.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PBRUSH         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pbrush.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PLEFT          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pntleft.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_PRIGHT         CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/pntright.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_BLANK          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/blank.cur" + Chr(34) )
WriteLine(RCStream, "WXCURSOR_CROSS          CURSOR  DISCARDABLE     " + Chr(34) + BlitzFolder + "include/wx/msw/cross.cur" + Chr(34) )
WriteLine(RCStream, "wxICON_AAA                      ICON " + Chr(34) + "Runner2.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_CLOSED_FOLDER      ICON " + Chr(34) + BlitzFolder + "include/wx/msw/folder1.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_OPEN_FOLDER        ICON " + Chr(34) + BlitzFolder + "include/wx/msw/folder2.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_FILE               ICON " + Chr(34) + BlitzFolder + "include/wx/msw/file1.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_COMPUTER           ICON " + Chr(34) + BlitzFolder + "include/wx/msw/computer.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_DRIVE              ICON " + Chr(34) + BlitzFolder + "include/wx/msw/drive.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_CDROM              ICON " + Chr(34) + BlitzFolder + "include/wx/msw/cdrom.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_FLOPPY             ICON " + Chr(34) + BlitzFolder + "include/wx/msw/floppy.ico" + Chr(34) )
WriteLine(RCStream, "wxICON_SMALL_REMOVEABLE         ICON " + Chr(34) + BlitzFolder + "include/wx/msw/removble.ico" + Chr(34) )
WriteLine(RCStream, "csquery                 BITMAP " + Chr(34) + BlitzFolder + "include/wx/msw/csquery.bmp" + Chr(34) )
WriteLine(RCStream, "wxBITMAP_STD_COLOURS    BITMAP " + Chr(34) + BlitzFolder + "include/wx/msw/colours.bmp" + Chr(34) )
WriteLine(RCStream, "#if !defined(wxUSE_NO_MANIFEST) || (wxUSE_NO_MANIFEST == 0)")
WriteLine(RCStream, "#if defined(wxUSE_RC_MANIFEST) && wxUSE_RC_MANIFEST")
WriteLine(RCStream, "#ifdef ISOLATION_AWARE_ENABLED")
WriteLine(RCStream, "#define wxMANIFEST_ID 2")
WriteLine(RCStream, "#else")
WriteLine(RCStream, "#define wxMANIFEST_ID 1")
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#if defined(WX_CPU_AMD64)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/amd64.manifest" + Chr(34) )
WriteLine(RCStream, "#elif defined(WX_CPU_IA64)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/ia64.manifest" + Chr(34) )
WriteLine(RCStream, "#elif defined(WX_CPU_X86)")
WriteLine(RCStream, "wxMANIFEST_ID 24 " + Chr(34) + BlitzFolder + "include/wx/msw/wx.manifest" + Chr(34) )
WriteLine(RCStream, "#else")
WriteLine(RCStream, "#error " + Chr(34) + "One of WX_CPU_XXX constants must be defined. See comment above." + Chr(34) )
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#endif")
WriteLine(RCStream, "#endif")

WriteLine(RCStream, "")
WriteLine(RCStream, "1 VERSIONINFO ")
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
WriteLine(RCStream, "}")
CloseFile(RCStream)




BatStream = WriteFile("CreateO.bat")
WriteLine(BatStream, "cd " + MinGW)
WriteLine(BatStream, "windres -i " + IconPath + "PhotonDownloader.rc -o " + IconPath + "PhotonDownloader.o")
WriteLine(BatStream, "windres -i " + IconPath + "PhotonExplorer.rc -o " + IconPath + "PhotonExplorer.o")
WriteLine(BatStream, "windres -i " + IconPath + "PhotonFrontEnd.rc -o " + IconPath + "PhotonFrontEnd.o")
WriteLine(BatStream, "windres -i " + IconPath + "PhotonManager.rc -o " + IconPath + "PhotonManager.o")
WriteLine(BatStream, "windres -i " + IconPath + "PhotonUpdater.rc -o " + IconPath + "PhotonUpdater.o")
WriteLine(BatStream, "windres -i " + IconPath + "PhotonRunner.rc -o " + IconPath + "PhotonRunner.o")

CloseFile(BatStream)
'-------------------------------------------------GENERATE-Os------------------------------------------------
Local Proc:TProcess = CreateProcess("CreateO.bat")
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
