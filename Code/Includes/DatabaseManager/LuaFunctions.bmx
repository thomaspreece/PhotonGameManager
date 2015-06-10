Function LuaInternetPulse(Win:wxWindow = Null)
	Log1.SubProgress.Pulse()
End Function

Function LuaInternetSetProgress(value:Int,Win:wxWindow = null)
	Log1.SubProgress.SetValue(value:Int)
End Function
