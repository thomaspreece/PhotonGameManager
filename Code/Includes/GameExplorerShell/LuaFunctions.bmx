Function LuaInternetPulse(Win:wxWindow)
	If Win = Null then
	
	Else
		Local DownloadBox:DownloadWindow = DownloadWindow(Win)
		If DownloadBox.LogClosed = True then
			Return 1
		EndIf
		DownloadBox.PulseSubGauge()
	EndIf
	Return 0
End Function

Function LuaInternetSetProgress(value:Int, Win:wxWindow)
	If Win = Null then
	
	Else
		Local DownloadBox:DownloadWindow = DownloadWindow(Win)
		If DownloadBox.LogClosed = True then
			Return 1
		EndIf		
		DownloadBox.SetSubGauge(value)
	EndIf
	Return 0
End Function
