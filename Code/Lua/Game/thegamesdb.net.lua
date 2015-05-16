local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

function elementText(el)
  local pieces = {}
  for _,n in ipairs(el.kids) do
    if n.type=='element' then pieces[#pieces+1] = elementText(n)
    elseif n.type=='text' then pieces[#pieces+1] = n.value
    end
  end
  return table.concat(pieces)
end

-- Description
-- Takes 	1. ID of the GM platform
--		 	2: Takes List to add platforms to
-- Returns 	1. Return status of function: 0 for success, 1 for visible error, 2 for invisible error
--			2. Error Text
--			3. The Source platform that matches the GM platform
--			4. The input List
--			Auto returns List to program
function GetPlatforms(PlatformID,List)
	List:LuaListAddLast("PC","PC")
	List:LuaListAddLast("Sega Genesis","Sega Genesis")
	return 0,"","PC",List
end

-- Description
-- Takes no arguments
-- Returns	1. Return status of function: 0 for success
--			2. The text to be displayed at bottom of search window
--			3. The text URL link
function GetText()
	return 0,"Content provided kindly by thegamesdb.net","http://thegamesdb.net"
end

-- Description
-- Takes	1. Text to search for
--			2. Text from client data of previous list selection
--			3. The data that was passed from GetPlatforms
--			4. This function may require the user to select a item from lists that go multiple selections deep, this is the current depth of user (1-inf)
--			5. Internet type to get data from net
--			6. The list to populate with results
-- Returns	1. Return status of function: 0 for success
--			2. Error text
--			3. The next depth to provide SearchGame or 0 for finished selecting
--			4. The List
function SearchGame(SearchText,PreviousClientData,Platform,ListDepth,Internet,List)

--       items = {    {1004, "foo"},    {1234, "bar"},    {3188, "baz"},    {7007, "quux"}}
--		 function compare(a,b)
-- 		 	return a[1] < b[1]
--		 end

--		 table.sort(items, compare)   -- Sorts the second pair so by foo,bar,baz,quux
--		 items = {  }
--		items[0] = {id=1004, name="oh dear", rank="foo"}
--		items[1] = {id=1204, name="oh dear 2", rank="doo"}
-- 
-- Add to end of table
-- table.insert(t, 123)
-- t[#t+1] = 456
-- #t gets highest index of table t

	ListDepth = tonumber(ListDepth)
	if ListDepth==1 then 
		ReturnedFile = Internet:GET("http://thegamesdb.net/api/GetGamesList.php?name="..SearchText.."&platform="..Platform,"SearchGame.xml")
		if ReturnedFile == "-1" then 
			return 1,Internet.LastError,0,List
		end
		local myxml = io.open(ReturnedFile):read('*all')
		local SLAXML = require 'Lua\\Includes\\slaxdom' -- also requires slaxml.lua; be sure to copy both files
		local doc = SLAXML:dom(myxml)
		
		local name
		local id
		
		for i, v in ipairs(doc.root.kids) do
			name = nil
			id = nil 
			
			if v.name == "Game" then
				for i2, v2 in ipairs(v.kids) do
					if v2.name == "id" then
						id = elementText(v2)
					end 
					if v2.name == "GameTitle" then
						name = elementText(v2)
					end 
				end 
				if id ~= nil and name ~= nil then
					List:LuaListAddLast(name,id)
				end 
			end 
		end
		
		
		return 0,"",0,List
	else
		--Error
		return 1,"Invalid List Depth",0,List
	end
end

-- Description
-- Takes	1. GameType to write game data to
--			2. Internet type to get data from net
--			3. ID data to identify which game to get
-- Returns	1. Return status of function: 0 for success
--			2. Error Text
--			3. The GameContainer with data in it
function GetGame(GameContainer,Internet,LuaIDData)
	ReturnedFile = Internet:GET("http://thegamesdb.net/api/GetGame.php?id="..LuaIDData,"GetGame.xml")
	if ReturnedFile == "-1" then 
		return 1,Internet.LastError,GameContainer
	end
	local myxml = io.open(ReturnedFile):read('*all')
	local SLAXML = require 'Lua\\Includes\\slaxdom' -- also requires slaxml.lua; be sure to copy both files
	local doc = SLAXML:dom(myxml)
	
	local TrailerString
	local BaseURL

	for i, v in ipairs(doc.root.kids) do
		if v.name == "baseImgUrl" then
			BaseURL = elementText(v)
		end
		if v.name == "Game" then
			for i2, v2 in ipairs(v.kids) do
				if v2.name == "Youtube" then
					TrailerString = elementText(v2)
				elseif v2.name == "GameTitle" then 
					GameContainer.Name = elementText(v2)
				elseif v2.name == "Overview" then 
					GameContainer.Desc = elementText(v2)
				elseif v2.name == "ReleaseDate" then 
					GameContainer.ReleaseDate = elementText(v2)
				elseif v2.name == "ESRB" then 
					GameContainer.Cert = elementText(v2)
				elseif v2.name == "Developer" then 
					GameContainer.Dev = elementText(v2)
				elseif v2.name == "Publisher" then 
					GameContainer.Pub = elementText(v2)
				elseif v2.name == "Genres" then 
					for i3, v3 in ipairs(v2.kids) do
						if v3.name == "genre" then
							GameContainer:AddToList(GameContainer.Genres,elementText(v3))
						end
					end
				elseif v2.name == "Co-op" then 
					GameContainer.Coop = elementText(v2)
				elseif v2.name == "Players" then 
					GameContainer.Players = elementText(v2)
				elseif v2.name == "Images" then 
					for i3, v3 in ipairs(v2.kids) do
						if v3.name == "fanart" then
							for i4, v4 in ipairs(v3.kids) do
								if v4.name == "original" then
									GameContainer:AddToList(GameContainer.Fanart,BaseURL..elementText(v4))
								elseif v4.name == "thumb" then
									GameContainer:AddToList(GameContainer.FanartThumbs,BaseURL..elementText(v4))
								end 
							end 
						elseif v3.name == "boxart" then
							if v3.attr['side'] == "back" then
								GameContainer:AddToList(GameContainer.BackBoxArt,BaseURL..elementText(v3))
							elseif v3.attr['side'] == "front" then
								GameContainer:AddToList(GameContainer.FrontBoxArt,BaseURL..elementText(v3))
							end
						elseif v3.name == "banner" then
							GameContainer:AddToList(GameContainer.BannerArt,BaseURL..elementText(v3))
						elseif v3.name == "screenshot" then
							for i4, v4 in ipairs(v3.kids) do
								if v4.name == "original" then
									GameContainer:AddToList(GameContainer.ScreenShots,BaseURL..elementText(v4))
								elseif v4.name == "thumb" then
									GameContainer:AddToList(GameContainer.ScreenShotThumbs,BaseURL..elementText(v4))
								end 	
							end
						end
					end
				elseif v2.name == "Rating" then 
					GameContainer.Rating = elementText(v2)			
				end
				
			end
		end
	end

	return 0,"",GameContainer
end

