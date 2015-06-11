Function LuaInternetPulse(Win:wxWindow)
	If Win = Null then
	
	Else
		Local DownloadBox:DownloadWindow = DownloadWindow(Win)
		DownloadBox.PulseSubGauge()
	EndIf
End Function

Function LuaInternetSetProgress(value:Int, Win:wxWindow)
	If Win = Null then
	
	Else
		Local DownloadBox:DownloadWindow = DownloadWindow(Win)
		DownloadBox.SetSubGauge(value)
	EndIf
End Function
