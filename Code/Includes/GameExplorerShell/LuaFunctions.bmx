Function LuaInternetPulse(Win:wxWindow)
	Local DownloadBox:DownloadWindow = DownloadWindow(Win)
	DownloadBox.PulseSubGauge()
End Function

Function LuaInternetSetProgress(value:Int, Win:wxWindow)
	Local DownloadBox:DownloadWindow = DownloadWindow(Win)
	DownloadBox.SetSubGauge(value)
End Function
