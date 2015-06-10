Private

'---- DownloadWindow

Function lugi_glue_DownloadWindow_Finish_WRCkn0:Int( lua_vm:Byte Ptr )
	Local obj:DownloadWindow = DownloadWindow(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.Finish() )

	Return 1

End Function


Function lugi_glue_DownloadWindow_OnInit_SHNiZ6:Int( lua_vm:Byte Ptr )
	Local obj:DownloadWindow = DownloadWindow(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.OnInit() )

	Return 1

End Function


Function lugi_glue_DownloadWindow_SetSubGauge_2SXZoB:Int( lua_vm:Byte Ptr )
	Local obj:DownloadWindow = DownloadWindow(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:Int = 0
	If 2 <= lua_gettop(lua_vm) Then
		Select lua_type(lua_vm, 2)
			Case LUA_TBOOLEAN
				_arg_1 = lua_toboolean(lua_vm, 2)
			Default
				_arg_1 = lua_tointeger(lua_vm, 2)
		End Select
	EndIf

	lua_pushinteger( lua_vm, obj.SetSubGauge(_arg_1) )

	Return 1

End Function


Function lugi_glue_DownloadWindow_PulseSubGauge_JaQYSr:Int( lua_vm:Byte Ptr )
	Local obj:DownloadWindow = DownloadWindow(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.PulseSubGauge() )

	Return 1

End Function


Function lugi_glue_DownloadWindow_SetGauge_TG7iMD:Int( lua_vm:Byte Ptr )
	Local obj:DownloadWindow = DownloadWindow(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:Int = 0
	If 2 <= lua_gettop(lua_vm) Then
		Select lua_type(lua_vm, 2)
			Case LUA_TBOOLEAN
				_arg_1 = lua_toboolean(lua_vm, 2)
			Default
				_arg_1 = lua_tointeger(lua_vm, 2)
		End Select
	EndIf

	lua_pushinteger( lua_vm, obj.SetGauge(_arg_1) )

	Return 1

End Function


Function lugi_glue_DownloadWindow_PulseGauge_LaT2Il:Int( lua_vm:Byte Ptr )
	Local obj:DownloadWindow = DownloadWindow(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.PulseGauge() )

	Return 1

End Function


Function lugi_glue_DownloadWindow_AddText_UmcWMk:Int( lua_vm:Byte Ptr )
	Local obj:DownloadWindow = DownloadWindow(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:String = ""
	If 2 <= lua_gettop(lua_vm) Then
		_arg_1 = lua_tostring(lua_vm, 2)
	EndIf

	lua_pushinteger( lua_vm, obj.AddText(_arg_1) )

	Return 1

End Function

'---- GameReadType

Function lugi_glue_GameReadType_GetEXEPart_0U8nhO:Int( lua_vm:Byte Ptr )
	Local obj:GameReadType = GameReadType(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:Int = 0
	If 2 <= lua_gettop(lua_vm) Then
		Select lua_type(lua_vm, 2)
			Case LUA_TBOOLEAN
				_arg_1 = lua_toboolean(lua_vm, 2)
			Default
				_arg_1 = lua_tointeger(lua_vm, 2)
		End Select
	EndIf

	lua_pushstring( lua_vm, obj.GetEXEPart(_arg_1) )

	Return 1

End Function


Function lugi_glue_GameReadType_NewGame_EA6zMx:Int( lua_vm:Byte Ptr )
	Local obj:GameReadType = GameReadType(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.NewGame() )

	Return 1

End Function


Function lugi_glue_GameReadType_IntialiseFanartLists_NbXYxA:Int( lua_vm:Byte Ptr )
	Local obj:GameReadType = GameReadType(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.IntialiseFanartLists() )

	Return 1

End Function


Function lugi_glue_GameReadType_DeleteGame_bU30SN:Int( lua_vm:Byte Ptr )
	Local obj:GameReadType = GameReadType(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.DeleteGame() )

	Return 1

End Function


Function lugi_glue_GameReadType_AddToList_v9qflr:Int( lua_vm:Byte Ptr )
	Local obj:GameReadType = GameReadType(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:TList = Null
	Local _arg_2:String = ""
	' Get arguments off stack
	Select lua_gettop(lua_vm)
		Case 1
			' no arguments provided

		Case 2
			_arg_1 = TList(lua_tobmaxobject(lua_vm, 2))

		Default
			_arg_1 = TList(lua_tobmaxobject(lua_vm, 2))
			_arg_2 = lua_tostring(lua_vm, 3)
	End Select ' Arguments retrieved from stack

	lua_pushinteger( lua_vm, obj.AddToList(_arg_1, _arg_2) )

	Return 1

End Function


Function lugi_glue_GameReadType_GetGame_0A4AdF:Int( lua_vm:Byte Ptr )
	Local obj:GameReadType = GameReadType(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:String = ""
	If 2 <= lua_gettop(lua_vm) Then
		_arg_1 = lua_tostring(lua_vm, 2)
	EndIf

	lua_pushinteger( lua_vm, obj.GetGame(_arg_1) )

	Return 1

End Function


Function lugi_glue_GameReadType_WriteUserData_Oo6SkC:Int( lua_vm:Byte Ptr )
	Local obj:GameReadType = GameReadType(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.WriteUserData() )

	Return 1

End Function

'---- LuaInternetType

Function lugi_glue_LuaInternetType_Create_u3y8BR:Int( lua_vm:Byte Ptr )
	Local obj:LuaInternetType = LuaInternetType(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:wxWindow = Null
	If 2 <= lua_gettop(lua_vm) Then
		_arg_1 = wxWindow(lua_tobmaxobject(lua_vm, 2))
	EndIf

	lua_pushbmaxobject( lua_vm, obj.Create(_arg_1) )

	Return 1

End Function


Function lugi_glue_LuaInternetType_Encode_tGDA6b:Int( lua_vm:Byte Ptr )
	Local obj:LuaInternetType = LuaInternetType(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:String = ""
	If 2 <= lua_gettop(lua_vm) Then
		_arg_1 = lua_tostring(lua_vm, 2)
	EndIf

	lua_pushstring( lua_vm, obj.Encode(_arg_1) )

	Return 1

End Function


Function lugi_glue_LuaInternetType_Destroy_5vvaLJ:Int( lua_vm:Byte Ptr )
	Local obj:LuaInternetType = LuaInternetType(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.Destroy() )

	Return 1

End Function


Function lugi_glue_LuaInternetType_Reset_mv0INi:Int( lua_vm:Byte Ptr )
	Local obj:LuaInternetType = LuaInternetType(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.Reset() )

	Return 1

End Function


Function lugi_glue_LuaInternetType_GET_RmGaHz:Int( lua_vm:Byte Ptr )
	Local obj:LuaInternetType = LuaInternetType(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:String = ""
	Local _arg_2:String = ""
	Local _arg_3:String = ""
	' Get arguments off stack
	Select lua_gettop(lua_vm)
		Case 1
			' no arguments provided

		Case 2
			_arg_1 = lua_tostring(lua_vm, 2)

		Case 3
			_arg_1 = lua_tostring(lua_vm, 2)
			_arg_2 = lua_tostring(lua_vm, 3)

		Default
			_arg_1 = lua_tostring(lua_vm, 2)
			_arg_2 = lua_tostring(lua_vm, 3)
			_arg_3 = lua_tostring(lua_vm, 4)
	End Select ' Arguments retrieved from stack

	lua_pushstring( lua_vm, obj.GET(_arg_1, _arg_2, _arg_3) )

	Return 1

End Function


Function lugi_glue_LuaInternetType_POST_ChH8lu:Int( lua_vm:Byte Ptr )
	Local obj:LuaInternetType = LuaInternetType(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:String = ""
	Local _arg_2:String = ""
	Local _arg_3:String = ""
	Local _arg_4:String = ""
	' Get arguments off stack
	Select lua_gettop(lua_vm)
		Case 1
			' no arguments provided

		Case 2
			_arg_1 = lua_tostring(lua_vm, 2)

		Case 3
			_arg_1 = lua_tostring(lua_vm, 2)
			_arg_2 = lua_tostring(lua_vm, 3)

		Case 4
			_arg_1 = lua_tostring(lua_vm, 2)
			_arg_2 = lua_tostring(lua_vm, 3)
			_arg_3 = lua_tostring(lua_vm, 4)

		Default
			_arg_1 = lua_tostring(lua_vm, 2)
			_arg_2 = lua_tostring(lua_vm, 3)
			_arg_3 = lua_tostring(lua_vm, 4)
			_arg_4 = lua_tostring(lua_vm, 5)
	End Select ' Arguments retrieved from stack

	lua_pushstring( lua_vm, obj.POST(_arg_1, _arg_2, _arg_3, _arg_4) )

	Return 1

End Function

'---- LuaListType

Function lugi_glue_LuaListType_Create_sl4lOq:Int( lua_vm:Byte Ptr )
	Local obj:LuaListType = LuaListType(lua_tobmaxobject(lua_vm, 1))

	lua_pushbmaxobject( lua_vm, obj.Create() )

	Return 1

End Function


Function lugi_glue_LuaListType_LuaListAddLast_R79bMb:Int( lua_vm:Byte Ptr )
	Local obj:LuaListType = LuaListType(lua_tobmaxobject(lua_vm, 1))
	Local _arg_1:String = ""
	Local _arg_2:String = ""
	' Get arguments off stack
	Select lua_gettop(lua_vm)
		Case 1
			' no arguments provided

		Case 2
			_arg_1 = lua_tostring(lua_vm, 2)

		Default
			_arg_1 = lua_tostring(lua_vm, 2)
			_arg_2 = lua_tostring(lua_vm, 3)
	End Select ' Arguments retrieved from stack

	lua_pushinteger( lua_vm, obj.LuaListAddLast(_arg_1, _arg_2) )

	Return 1

End Function


Function lugi_glue_LuaListType_ClearList_mB4DbS:Int( lua_vm:Byte Ptr )
	Local obj:LuaListType = LuaListType(lua_tobmaxobject(lua_vm, 1))

	lua_pushinteger( lua_vm, obj.ClearList() )

	Return 1

End Function

Function lugi_p_lugi_initpre_k5YLbjdnLnr8oQS7(lua_vm:Byte Ptr, register_field(off%, typ%, name$, class@ Ptr), register_method(luafn:Int(state:Byte Ptr), name$, class@ Ptr))
	' Register instance method DownloadWindow#Finish
	register_method( lugi_glue_DownloadWindow_Finish_WRCkn0, "Finish", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	' Register instance method DownloadWindow#OnInit
	register_method( lugi_glue_DownloadWindow_OnInit_SHNiZ6, "OnInit", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	' Register instance method DownloadWindow#SetSubGauge
	register_method( lugi_glue_DownloadWindow_SetSubGauge_2SXZoB, "SetSubGauge", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	' Register instance method DownloadWindow#PulseSubGauge
	register_method( lugi_glue_DownloadWindow_PulseSubGauge_JaQYSr, "PulseSubGauge", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	' Register instance method DownloadWindow#SetGauge
	register_method( lugi_glue_DownloadWindow_SetGauge_TG7iMD, "SetGauge", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	' Register instance method DownloadWindow#PulseGauge
	register_method( lugi_glue_DownloadWindow_PulseGauge_LaT2Il, "PulseGauge", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	' Register instance method DownloadWindow#AddText
	register_method( lugi_glue_DownloadWindow_AddText_UmcWMk, "AddText", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	register_field( 32, LUGI_OBJECTFIELD, "LogBox", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	register_field( 36, LUGI_INTFIELD, "LogClosed", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	register_field( 40, LUGI_INTFIELD, "DownloadFinished", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	register_field( 44, LUGI_OBJECTFIELD, "SubProgress", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	register_field( 48, LUGI_OBJECTFIELD, "Progress", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	register_field( 52, LUGI_STRINGFIELD, "ClientData", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	register_field( 56, LUGI_STRINGFIELD, "LuaFile", Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )

	' Register instance method GameReadType#GetEXEPart
	register_method( lugi_glue_GameReadType_GetEXEPart_0U8nhO, "GetEXEPart", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	' Register instance method GameReadType#NewGame
	register_method( lugi_glue_GameReadType_NewGame_EA6zMx, "NewGame", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	' Register instance method GameReadType#IntialiseFanartLists
	register_method( lugi_glue_GameReadType_IntialiseFanartLists_NbXYxA, "IntialiseFanartLists", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	' Register instance method GameReadType#DeleteGame
	register_method( lugi_glue_GameReadType_DeleteGame_bU30SN, "DeleteGame", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	' Register instance method GameReadType#AddToList
	register_method( lugi_glue_GameReadType_AddToList_v9qflr, "AddToList", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	' Register instance method GameReadType#GetGame
	register_method( lugi_glue_GameReadType_GetGame_0A4AdF, "GetGame", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	' Register instance method GameReadType#WriteUserData
	register_method( lugi_glue_GameReadType_WriteUserData_Oo6SkC, "WriteUserData", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 8, LUGI_STRINGFIELD, "OrginalName", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 12, LUGI_STRINGFIELD, "Name", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 16, LUGI_STRINGFIELD, "Desc", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 20, LUGI_STRINGFIELD, "ROM", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 24, LUGI_STRINGFIELD, "ExtraCMD", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 28, LUGI_STRINGFIELD, "RunEXE", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 32, LUGI_OBJECTFIELD, "OEXEs", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 36, LUGI_OBJECTFIELD, "OEXEsName", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 40, LUGI_STRINGFIELD, "ReleaseDate", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 44, LUGI_STRINGFIELD, "Cert", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 48, LUGI_STRINGFIELD, "Dev", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 52, LUGI_STRINGFIELD, "Pub", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 56, LUGI_STRINGFIELD, "Trailer", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 60, LUGI_OBJECTFIELD, "Genres", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 64, LUGI_STRINGFIELD, "LuaFile", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 68, LUGI_STRINGFIELD, "LuaIDData", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 72, LUGI_INTFIELD, "ID", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 76, LUGI_STRINGFIELD, "Rating", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 80, LUGI_STRINGFIELD, "Plat", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 84, LUGI_INTFIELD, "PlatformNum", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 88, LUGI_STRINGFIELD, "EmuOverride", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 92, LUGI_STRINGFIELD, "Coop", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 96, LUGI_STRINGFIELD, "Players", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 100, LUGI_INTFIELD, "Completed", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 104, LUGI_OBJECTFIELD, "Fanart", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 108, LUGI_OBJECTFIELD, "FanartThumbs", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 112, LUGI_OBJECTFIELD, "ScreenShots", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 116, LUGI_OBJECTFIELD, "ScreenShotThumbs", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 120, LUGI_OBJECTFIELD, "FrontBoxArt", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 124, LUGI_OBJECTFIELD, "BackBoxArt", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 128, LUGI_OBJECTFIELD, "BannerArt", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 132, LUGI_OBJECTFIELD, "IconArt", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 136, LUGI_STRINGFIELD, "Mounter", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 140, LUGI_STRINGFIELD, "VDriveNum", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 144, LUGI_STRINGFIELD, "UnMount", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 148, LUGI_STRINGFIELD, "DiscImage", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 152, LUGI_STRINGFIELD, "PreBF", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 156, LUGI_INTFIELD, "PreBFWait", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 160, LUGI_STRINGFIELD, "PostBF", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 164, LUGI_INTFIELD, "PostBFWait", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 168, LUGI_INTFIELD, "GameRunnerAlwaysOn", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 172, LUGI_INTFIELD, "StartWaitEnabled", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 176, LUGI_OBJECTFIELD, "WatchEXEs", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 180, LUGI_INTFIELD, "OverideArtwork", Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	register_field( 184, LUGI_INTFIELD, "ScreenShotsAvailable", Byte Ptr(TTypeID.ForName("GameReadType")._class) )

	' Register instance method LuaInternetType#Create
	register_method( lugi_glue_LuaInternetType_Create_u3y8BR, "Create", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	' Register instance method LuaInternetType#Encode
	register_method( lugi_glue_LuaInternetType_Encode_tGDA6b, "Encode", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	' Register instance method LuaInternetType#Destroy
	register_method( lugi_glue_LuaInternetType_Destroy_5vvaLJ, "Destroy", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	' Register instance method LuaInternetType#Reset
	register_method( lugi_glue_LuaInternetType_Reset_mv0INi, "Reset", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	' Register instance method LuaInternetType#GET
	register_method( lugi_glue_LuaInternetType_GET_RmGaHz, "GET", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	' Register instance method LuaInternetType#POST
	register_method( lugi_glue_LuaInternetType_POST_ChH8lu, "POST", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	register_field( 8, LUGI_OBJECTFIELD, "curl", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	register_field( 12, LUGI_STRINGFIELD, "LastError", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	register_field( 16, LUGI_INTFIELD, "Time", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	register_field( 20, LUGI_INTFIELD, "Timeout", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	register_field( 24, LUGI_DOUBLEFIELD, "Currentdl", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	register_field( 32, LUGI_OBJECTFIELD, "Window", Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )

	' Register instance method LuaListType#Create
	register_method( lugi_glue_LuaListType_Create_sl4lOq, "Create", Byte Ptr(TTypeID.ForName("LuaListType")._class) )
	' Register instance method LuaListType#LuaListAddLast
	register_method( lugi_glue_LuaListType_LuaListAddLast_R79bMb, "LuaListAddLast", Byte Ptr(TTypeID.ForName("LuaListType")._class) )
	' Register instance method LuaListType#ClearList
	register_method( lugi_glue_LuaListType_ClearList_mB4DbS, "ClearList", Byte Ptr(TTypeID.ForName("LuaListType")._class) )
	register_field( 8, LUGI_OBJECTFIELD, "List", Byte Ptr(TTypeID.ForName("LuaListType")._class) )

End Function
New LuGIInitFunction.PreInit(lugi_p_lugi_initpre_k5YLbjdnLnr8oQS7, False)


Function lugi_p_lugi_initpost_tOkio74uV9rhgSJy(lua_vm:Byte Ptr, constructor:Int(state:Byte Ptr))
	' Register constructor for DownloadWindow
	lua_pushlightuserdata( lua_vm, Byte Ptr(TTypeID.ForName("DownloadWindow")._class) )
	lua_pushcclosure( lua_vm, constructor, 1 )
	lua_setfield( lua_vm, LUA_GLOBALSINDEX, "" )
	' Register constructor for GameReadType
	lua_pushlightuserdata( lua_vm, Byte Ptr(TTypeID.ForName("GameReadType")._class) )
	lua_pushcclosure( lua_vm, constructor, 1 )
	lua_setfield( lua_vm, LUA_GLOBALSINDEX, "NewGameReadType" )
	' Register constructor for LuaInternetType
	lua_pushlightuserdata( lua_vm, Byte Ptr(TTypeID.ForName("LuaInternetType")._class) )
	lua_pushcclosure( lua_vm, constructor, 1 )
	lua_setfield( lua_vm, LUA_GLOBALSINDEX, "" )
	' Register constructor for LuaListType
	lua_pushlightuserdata( lua_vm, Byte Ptr(TTypeID.ForName("LuaListType")._class) )
	lua_pushcclosure( lua_vm, constructor, 1 )
	lua_setfield( lua_vm, LUA_GLOBALSINDEX, "" )
End Function
New LuGIInitFunction.PostInit(lugi_p_lugi_initpost_tOkio74uV9rhgSJy)



Public

