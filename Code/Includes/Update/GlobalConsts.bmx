Global PROGRAMICON:String = RESFOLDER + "Updater.ico"
Global DownloaderApp:DownloaderShell
Global Message:String = ""
Global CurrentSearchLine:String = ""
Global DownloadSpeedTimer:Int = MilliSecs()
Global Downloaded:Int = 0
Global DownloadSpeed:Int = 0

Const DS_T1:Int = 1
Const DS_T2:Int = 2
Const DS_T3:Int = 3

?Threaded
Global DialogMutex:TMutex = CreateMutex()
?
Global DialogText:String = ""
Global DialogProgress:Int = - 1
Global DialogPulse:Int = - 1
Global DialogNotCanceled:Int = 1
Global DialogResume:Int = - 1
