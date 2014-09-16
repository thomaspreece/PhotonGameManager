Type LuaInternetType {expose disablenew}
	Field curl:TCurlEasy
	Field LastError:String

	Function progressCallback:Int(data:Object, dltotal:Double, dlnow:Double, ultotal:Double, ulnow:Double) {hidden}
		PrintF( " ++++ " + dlnow + " bytes")
		Return 0	
	End Function

	Method Create:LuaInternetType()
		curl = TCurlEasy.Create()
		Return Self
	End Method
	
	Method GET:String(URL:String, filename:String)
		'strip any bad path
		filename = StripDir(filename)
		
		Local TFile:TStream = WriteFile(TEMPFOLDER + filename)

		curl.setOptString(CURLOPT_URL, URL)
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
		curl.setProgressCallback(Self.progressCallback)
		curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
		curl.setWriteStream(TFile)
		
		Local res:Int = curl.perform()
		
		CloseFile(TFile)

		If res then
			Self.LastError = CurlError(res)
			Return "-1"
		else
			Self.LastError = ""
			Return TEMPFOLDER + filename 'FullPathToFile
		EndIf
	End Method
	
	Method POST:String(URL:String,filename:String,data:String)
		'strip any bad path
		filename = StripDir(filename)
		
		Local TFile:TStream = WriteFile(TEMPFOLDER + filename)

		curl.setOptString(CURLOPT_URL, URL)
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
		curl.setProgressCallback(Self.progressCallback)
		curl.setOptString(CURLOPT_POSTFIELDS, data)		
		curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
		curl.setWriteStream(TFile)
		
		Local res:Int = curl.perform()
		
		CloseFile(TFile)

		Return TEMPFOLDER + filename 'FullPathToFile
	End Method	
End Type

Type LuaListItemType
	Field ItemName:String
	Field ClientData:String
End Type

Type LuaListType {expose disablenew}
	Field List:TList
	
	Method Create:LuaListType()
		'Local LuaList:LuaListType = New LuaList
		Self.List = CreateList()
		Return Self
		'Return LuaList
	End Method
	
	Method LuaListAddLast(Text:String, Text2:String)
		Local LualistItem:LuaListItemType = New LuaListItemType
		LuaListItem.ItemName = Text
		LuaListItem.ClientData = Text2
		ListAddLast(Self.List, LualistItem)
	End Method
	
	Method ClearList()
		Self.List.Clear()
	End Method
End Type

Function LuaHelper_FunctionError:Int(Lua:Byte Ptr, Error:Int)
	Local MessageBox:wxMessageDialog
	
	If Error <> 0 then
		PrintF("Lua function returned error code: " + Error)
		MessageBox = New wxMessageDialog.Create(Null , "Lua function returned error code: " + Error , "Error" , wxOK | wxICON_EXCLAMATION)
		MessageBox.ShowModal()
		MessageBox.Free()				
	EndIf
	LuaHelper_CleanStack(Lua)
End Function

Function LuaHelper_CleanStack:Int(Lua:Byte Ptr)
	Local PopNum:Int = lua_gettop(Lua)
	If PopNum > 0 then
		lua_pop(Lua, PopNum)
	EndIf
	Return 0
End Function

Function LuaMutexLock(OnlyTryToLock:Int = 0, NotifyUser:Int = 0)
	?Threaded
	Local MessageBox:wxMessageDialog
	Local TryStatus:Int
	If OnlyTryToLock = 0 then
		LockMutex(LuaMutex)
	ElseIf OnlyTryToLock = 1 then
		TryStatus = TryLockMutex(LuaMutex)
		If NotifyUser = 1 And TryStatus = 0 then
			MessageBox = New wxMessageDialog.Create(Null , "Lua Machine already in use please wait.", "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()
		EndIf
		Return TryStatus
	EndIf
	?
End Function

Function LuaMutexUnlock()
	?Threaded
	UnlockMutex(LuaMutex)
	?
End Function

?Threaded
Type LuaThread_pcall_Type
	Field Lua:Byte Ptr
	Field Inputs:Int
	Field Outputs:Int
	Field ReturnName:String
	Field Window:wxWindow
	
	Method Create:LuaThread_pcall_Type(Lua:Byte Ptr, Inputs:Int, Outputs:Int, ReturnName:String, Window:wxWindow)
		Self.Lua = Lua
		Self.Inputs = Inputs
		Self.Outputs = Outputs
		Self.ReturnName = ReturnName
		Self.Window = Window
		
		Return Self
	End Method
End Type


Function LuaThread_pcall_Funct:Object(nobject:Object)
	Local LuaThread_pcall:LuaThread_pcall_Type = LuaThread_pcall_Type(nobject)
	Local MessageBox:wxMessageDialog
	Local ErrorMessage:String
	
	LuaMutexLock()
	LuaThread_pcall.Window.Disable()
	Result = lua_pcall(LuaThread_pcall.Lua, LuaThread_pcall.Inputs, LuaThread_pcall.Outputs, 0)
	LuaThread_pcall.Window.Enable()
	LuaMutexUnlock()
	
	If (Result <> 0) then
		LuaMutexLock()
		ErrorMessage = luaL_checkstring(LuaThread_pcall.Lua, - 1)
		LuaHelper_CleanStack(LuaThread_pcall.Lua)
		LuaMutexUnlock()
		
		PrintF("Lua Runtime Error: ~n" + ErrorMessage)
		MessageBox = New wxMessageDialog.Create(Null , "Lua Runtime Error: ~n" + ErrorMessage, "Error" , wxOK | wxICON_EXCLAMATION)
		MessageBox.ShowModal()
		MessageBox.Free()
	EndIf
	
	LockMutex(LuaEventMutex)
	LuaEvent = LuaThread_pcall.ReturnName
	UnlockMutex(LuaEventMutex)
End Function
?

Function LuaHelper_pcall:Int(Lua:Byte Ptr, Inputs:Int, Outputs:Int)

	Local Result:Int
	Local MessageBox:wxMessageDialog
	Result = lua_pcall(Lua, Inputs, Outputs, 0)
	If (Result <> 0) then
		PrintF("Lua Runtime Error: ~n" + luaL_checkstring(Lua, - 1) )
		MessageBox = New wxMessageDialog.Create(Null , "Lua Runtime Error: ~n" + luaL_checkstring(Lua, - 1) , "Error" , wxOK | wxICON_EXCLAMATION)
		MessageBox.ShowModal()
		MessageBox.Free()
		LuaHelper_CleanStack(Lua)
		Return 1		
	EndIf
	
	Return 0
End Function


Function LuaHelper_LoadString:Int(Lua:Byte Ptr, Source:String , File:String = Null)
	'Takes LuaVM, Text Source and optional File path. If optional file path provided, Source is ignored and file is read into Source
	
	Local Result:Int
	Local MessageBox:wxMessageDialog
	
	If File <> Null then
		Local line:String
		Source = ""
		Local LuaSourceFile:TStream = ReadFile(File)
		If LuaSourceFile = Null then
			PrintF("Lua File Error: ~n" + "Could not open Lua file for reading")
			MessageBox = New wxMessageDialog.Create(Null , "Lua File Error: ~n" + "Could not open Lua file for reading" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()		
			Return 1
		EndIf
		Repeat
			Line = ReadLine(LuaSourceFile)
			Source = Source + line + "~n~r"
			If Eof(LuaSourceFile) then Exit 	
		Forever
		CloseFile(LuaSourceFile)
	EndIf
	
	Result = luaL_loadstring(Lua, Source)
	If (Result <> 0) then
		PrintF("Lua Compile Error: ~n" + luaL_checkstring(Lua, - 1) )
		MessageBox = New wxMessageDialog.Create(Null , "Lua Compile Error: ~n" + luaL_checkstring(Lua, - 1) , "Error" , wxOK | wxICON_EXCLAMATION)
		MessageBox.ShowModal()
		MessageBox.Free()
		LuaHelper_CleanStack(Lua)
		Return 1
	End If
	
	lua_pcall(Lua, 1, - 1, - 1)
	
	Return 0
End Function
