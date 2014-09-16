local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

function GetPlatforms(PlatformID,List)
	List:LuaListAddLast("NewPlat","")
	List:LuaListAddLast("NewPlat2","")
	List:LuaListAddLast("NewPlat3","")
	--sleep(10)
	--abc = 1
	--abc = abc + "a"
	return 0,"NewPlat2",List
end

function GetText()
	return 0,"Content provided kindly by thegamesdb.net","http://thegamesdb.net"
end

function SearchGame(SearchText,PreviousClientData,Platform,ListDepth,Internet,List)
	ListDepth = tonumber(ListDepth)
	if ListDepth==1 then 
		List:LuaListAddLast("Item1","Client1")
		List:LuaListAddLast("Item2","Client2")
		return 0,2,List
	elseif ListDepth==2 then 
		List:LuaListAddLast("Item3","Client3")
		List:LuaListAddLast("Item4","Client4")
		return 0,0,List
	else
		--Error
		return 1,0,List
	end
end


function GetGame(GameContainer,Internet,LuaIDData)

	return 0,GameContainer
end

