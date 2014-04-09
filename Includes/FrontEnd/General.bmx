Type GeneralType
	Method Init()
	End Method
	
	Method Update()
	End Method
	
	Method Max2D()
	End Method
	
	Method UpdateKeyboard:Int()
		Return False
	End Method
	
	Method UpdateMouse:Int()
		Return False
	End Method
	
	Method UpdateJoy:Int()
		Return False 
	End Method
	
	Method Clear()
	End Method
End Type

Function Tol:Int(Value1:Float,Value2:Float,Tolerance:Float)
	If Abs(Value1 - Value2) < Tolerance Then
		Return True
	Else
		Return False 
	EndIf 
	
End Function

Type ExitType Extends GeneralType
	Method Init()
		ListAddLast(UpdateTypeList , Self)
	End Method
	
	Method UpdateKeyboard:Int()
		If KeyHit(KEYBOARD_ESC) Then 
			ExitProgramCall = True 
		EndIf 
		Return False
	End Method	
	

End Type

?Win32
Extern "Win32"
	Function CloseHandle(hHandle)
EndExtern
?

Function FlushJoy(port=0)

	Pub.FreeJoy.JoyHit(JOY_BIGCOVER,port)
	Pub.FreeJoy.JoyHit(JOY_FLIPCOVER,port)
	Pub.FreeJoy.JoyHit(JOY_ENTER,port)
	Pub.FreeJoy.JoyHit(JOY_MENU,port)
	Pub.FreeJoy.JoyHit(JOY_FILTER,port)
	Pub.FreeJoy.JoyHit(JOY_CANCEL,port)
	Pub.FreeJoy.JoyHit(JOY_INFO,port)

End Function

Function JoyHit:Int(button,port=0)
  	Local Value:Int = Pub.FreeJoy.JoyHit(button,port) 
	If Value=0 Then 
	
	Else
	 	FlushJoy(port)
	EndIf 
 	Return Value
End Function