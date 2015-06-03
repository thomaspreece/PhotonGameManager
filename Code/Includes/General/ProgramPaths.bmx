
?Win32
Global FRONTENDPROGRAM:String = "PhotonFrontend.exe"
Global MANAGERPROGRAM:String = "PhotonManager.exe"
Global EXPLORERPROGRAM:String = "PhotonExplorer.exe"
Global DOWNLOADERPROGRAM:String = "PhotonDownloader.exe"
Global UPDATEPROGRAM:String = "PhotonUpdate.exe"
?Linux
Global FRONTENDPROGRAM:String = Chr(34) + RealPath("PhotonFrontend") + Chr(34)
Global MANAGERPROGRAM:String = Chr(34)+RealPath("PhotonManager")+Chr(34)
Global EXPLORERPROGRAM:String = Chr(34)+RealPath("PhotonExplorer")+Chr(34)
Global DOWNLOADERPROGRAM:String = Chr(34)+RealPath("PhotonDownloader")+Chr(34)
Global UPDATEPROGRAM:String = Chr(34)+RealPath("PhotonUpdate")+Chr(34)
?MacOS
Global FRONTENDPROGRAM:String = Chr(34)+RealPath("PhotonFrontend.app")+"/Contents/MacOS/PhotonFrontend"+Chr(34)
Global MANAGERPROGRAM:String = Chr(34)+RealPath("PhotonManager.app")+"/Contents/MacOS/PhotonManager"+Chr(34)
Global EXPLORERPROGRAM:String = Chr(34) + RealPath("PhotonExplorer.app") + "/Contents/MacOS/PhotonExplorer" + Chr(34)
Global DOWNLOADERPROGRAM:String = Chr(34)+RealPath("PhotonDownloader.app")+"/Contents/MacOS/PhotonDownloader"+Chr(34)
Global UPDATEPROGRAM:String = Chr(34)+RealPath("PhotonUpdate.app")+"/Contents/MacOS/PhotonUpdate"+Chr(34)
?

Global GAMEDATAFOLDER:String = TempFolderPath + "Games" + FolderSlash
Global SETTINGSFOLDER:String = TempFolderPath + "Settings" + FolderSlash
Global TEMPFOLDER:String = TempFolderPath + "Temp" + FolderSlash
Global LOGFOLDER:String = TempFolderPath + "Log" + FolderSlash

Global MOUNTERFOLDER:String = "Mounters" + FolderSlash
Global RESFOLDER:String = "Resources" + FolderSlash
Global APPFOLDER:String = "Plugins" + FolderSlash
Global LUAFOLDER:String = "Lua" + FolderSlash

?Win32
Global SevenZipPath:String = APPFOLDER + "critical\7zip\7z.exe"
?Not Win32
Global SevenZipPath:String = APPFOLDER + "critical/7zip/7z"
?
Global ResourceExtractPath:String = APPFOLDER + "critical\ResourcesExtract\ResourcesExtract.exe"