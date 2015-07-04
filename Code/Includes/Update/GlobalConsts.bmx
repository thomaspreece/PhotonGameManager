Global PROGRAMICON:String = RESFOLDER + "Updater.ico"
Global DownloaderApp:DownloaderShell
Global Message:String = ""
Global CurrentSearchLine:String = ""
Global DownloadSpeedTimer:Int = MilliSecs()
Global Downloaded:Int = 0
Global DownloadSpeed:int = 0

Const DS_T1:int = 1
Const DS_T2:int = 2
Const DS_T3:int = 3

Global DialogMutex:TMutex = CreateMutex()
Global DialogText:String = ""
Global DialogProgress:int = - 1
Global DialogPulse:int = - 1
Global DialogNotCanceled:int = 1
Global DialogResume:int = - 1
