Global LuaInternet:LuaInternetType = LuaInternetType(New LuaInternetType.Create() )

Function StartupLuaVM()
	LuaVM = luaL_newstate()
	InitLuGI(LuaVM)
	luaL_openlibs(LuaVM)
End Function

Function EndLuaVM()
	lua_close(LuaVM)
End Function


Function GetLuaList:TList(LuaCat:Int)
	Local LuaList:TList = CreateList()
	Local LuaFile:String
	
	Local ReadLuaFiles:Int
	Select LuaCat
		Case 1
			ReadLuaFiles = ReadDir(LUAFOLDER + "Game")
		Case 2
			ReadLuaFiles = ReadDir(LUAFOLDER + "Cheat")
		Case 3
			ReadLuaFiles = ReadDir(LUAFOLDER + "Walkthrough")
		Case 4
			ReadLuaFiles = ReadDir(LUAFOLDER + "Patch")
		Case 5
			ReadLuaFiles = ReadDir(LUAFOLDER + "Manual")
		Default
			CustomRuntimeError("GetLuaList - Select Error")
	End Select 	
	
	If ReadLuaFiles = Null then CustomRuntimeError("GetLuaList - ReadDir Error")
	
	Repeat
		LuaFile = NextFile(ReadLuaFiles)
		If LuaFile = "." Or LuaFile = ".." then Continue
		If LuaFile = "" then Exit
		If Right(LuaFile, 4) = ".lua" then ListAddLast(LuaList, Left(LuaFile, Len(LuaFile) - 4) )
	Forever
	CloseDir(ReadLuaFiles)
	
	SortList(LuaList)
	
	Return LuaList
	
End Function

Type LuaInternetType {expose disablenew}
	Field curl:TCurlEasy
	Field LastError:String
	Field Time:int
	Field Timeout:Int = 10000
	Field Currentdl:Double

	Function progressCallback:Int(data:Object, dltotal:Double, dlnow:Double, ultotal:Double, ulnow:Double) {hidden}
		Local LuaInternet:LuaInternetType = LuaInternetType(data)
		If dlnow = 0 then
			LuaInternetPulse()
		Else
			LuaInternetSetProgress( (100 * dlnow) / dltotal)
		EndIf
		
		If LuaInternet.Currentdl - dlnow = 0 then
			If MilliSecs() - LuaInternet.Time > LuaInternet.Timeout then
				PrintF("Internet Timeout!")
				Return 1
			EndIf
		Else
			LuaInternet.Currentdl = dlnow
			LuaInternet.Time = MilliSecs()
		EndIf
		
		PrintF( " ++++ " + dlnow + " bytes")
		Return 0	
	End Function

	Method Create:LuaInternetType()
		curl = TCurlEasy.Create()
		Return Self
	End Method
	
	Method Encode:String(value:String)
		Return WebEncode(value)
	End Method
	
	Method Destroy()
		curl.cleanup()
	End Method
	
	Method Reset()
		LuaMutexLock()
		curl.cleanup()
		curl = TCurlEasy.Create()
		LuaMutexUnlock()
	End Method
	
	Method GET:String(URL:String, filename:String)
		'strip any bad path
		filename = StripDir(filename)
		
		Self.Time = - 1
		Self.Currentdl = - 1
		
		Local TFile:TStream = WriteFile(TEMPFOLDER + filename)

		URL = URLEncode(URL)

		curl.setOptString(CURLOPT_URL, URL)
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
		curl.setProgressCallback(Self.progressCallback, Object(Self) )
		curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
		curl.setWriteStream(TFile)
		
		Local res:Int = curl.perform()
		
		CloseFile(TFile)

		If res then
			PrintF("LuaInternet GET Error: " + URL + "  " + CurlError(res) )
			Self.LastError = CurlError(res)
			Return "-1"
		else
			Self.LastError = ""
			Return TEMPFOLDER + filename 'FullPathToFile
		EndIf
	End Method
	
	Method POST:String(URL:String, filename:String, data:String)
		'strip any bad path
		filename = StripDir(filename)
		
		URL = URLEncode(URL)
		
		Self.Time = - 1
		Self.Currentdl = - 1
		
		Local TFile:TStream = WriteFile(TEMPFOLDER + filename)

		curl.setOptString(CURLOPT_URL, URL)
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)
		curl.setProgressCallback(Self.progressCallback, Object(Self) )
		curl.setOptString(CURLOPT_POSTFIELDS, data)		
		curl.setOptString(CURLOPT_CAINFO, CERTIFICATEBUNDLE)
		curl.setWriteStream(TFile)
		
		Local res:Int = curl.perform()
		
		CloseFile(TFile)

		If res then
			PrintF("LuaInternet POST Error: " + URL + "  " + CurlError(res) )
			Self.LastError = CurlError(res)
			Return "-1"
		Else
			Self.LastError = ""
			Return TEMPFOLDER + filename 'FullPathToFile
		EndIf 
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
		LualistItem.ItemName = Text
		LualistItem.ClientData = Text2
		ListAddLast(Self.List, LualistItem)
	End Method
	
	Method ClearList()
		Self.List.Clear()
	End Method
End Type

Function LuaHelper_GetDefault:String(LuaCat:Int)
	'Return default game lua file (without .lua extention)
	PrintF("Getting Default Lua for cat: " + LuaCat)
	Select LuaCat
		Case 1
			If FileType(LUAFOLDER + "Game" + FolderSlash + PMDefaultGameLua + ".lua") = 1 then
				Return PMDefaultGameLua
			EndIf
		Case 2
			
		Case 3
		
		Case 4
		
		Case 5
			
		Default
			CustomRuntimeError("LuaHelper_GetDefault - Select Error")
	End Select
	
	Local LuaList:TList = GetLuaList(LuaCat)
	If CountList(LuaList) > 0 then
		PrintF(String(LuaList.First() ) )
		Return String(LuaList.First() )
	Else
		Return "oh"
	EndIf
	
End Function

Function LuaHelper_GetDefaultGame:String()
	'Return default game lua file (without .lua extention)
	PrintF("Getting Default Game Lua")
	If FileType(LUAFOLDER + "Game" + FolderSlash + PMDefaultGameLua + ".lua") = 1 then
		Return PMDefaultGameLua
	Else
		Local LuaList:TList = GetLuaList(1)
		If CountList(LuaList) > 0 then
			PrintF(String(LuaList.First() ))
			Return String(LuaList.First() )
		Else
			Return "oh"
		EndIf
	EndIf
End Function

Function LuaHelper_FunctionError:Int(Lua:Byte Ptr, Error:Int, ErrorMessage:String)
	Local MessageBox:wxMessageDialog
	If ErrorMessage = "Operation was aborted by an application callback" then ErrorMessage = "Internet operation timeout"
	If Error <> 0 then
		PrintF("Lua function returned error code: " + Error + " with message: " + ErrorMessage)
		MessageBox = New wxMessageDialog.Create(Null , "Error: " + ErrorMessage + "~nError Code: " + Error , "Error" , wxOK | wxICON_EXCLAMATION)
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
	
	Method Create:LuaThread_pcall_Type(Lua:Byte Ptr, Inputs:Int, Outputs:Int, ReturnName:String)
		Self.Lua = Lua
		Self.Inputs = Inputs
		Self.Outputs = Outputs
		Self.ReturnName = ReturnName
		
		Return Self
	End Method
End Type


Function LuaThread_pcall_Funct:Object(nobject:Object)
	Local LuaThread_pcall:LuaThread_pcall_Type = LuaThread_pcall_Type(nobject)
	Local MessageBox:wxMessageDialog
	Local ErrorMessage:String
	
	LuaMutexLock()
	Result = lua_pcall(LuaThread_pcall.Lua, LuaThread_pcall.Inputs, LuaThread_pcall.Outputs, 0)
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
		Return
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
	
	'Clean out Lua Stack First
	LuaHelper_CleanStack(LuaVM)
	
	Local Result:Int
	Local MessageBox:wxMessageDialog
	
	If File <> Null then
		Local line:String
		Source = ""
		Local LuaSourceFile:TStream = ReadFile(File)
		If LuaSourceFile = Null then
			PrintF("Lua File Error: ~n" + "Could not open Lua file for reading (" + File + ")")
			MessageBox = New wxMessageDialog.Create(Null , "Lua File Error: ~n" + "Could not open Lua file for reading (" + File + ")" , "Error" , wxOK | wxICON_EXCLAMATION)
			MessageBox.ShowModal()
			MessageBox.Free()		
			Return 1
		EndIf
		Repeat
			line = ReadLine(LuaSourceFile)
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
