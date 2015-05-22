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
	print(PlatformID)
	ReturnPlatform = ""
	List:LuaListAddLast("3DO","3DO")
	if PlatformID == 1 then
		ReturnPlatform = "3DO"
	end
	List:LuaListAddLast("Arcade","Arcade")
	if PlatformID == 2 then
		ReturnPlatform = "Arcade"
	end
	List:LuaListAddLast("Atari 2600","Atari 2600")
	if PlatformID == 3 then
		ReturnPlatform = "Atari 2600"
	end
	List:LuaListAddLast("Atari 5200","Atari 5200")
	if PlatformID == 4 then
		ReturnPlatform = "Atari 5200"
	end
	List:LuaListAddLast("Atari 7800","Atari 7800")
	if PlatformID == 5 then
		ReturnPlatform = "Atari 7800"
	end
	List:LuaListAddLast("Atari Jaguar","Atari Jaguar")
	if PlatformID == 6 then
		ReturnPlatform = "Atari Jaguar"
	end
	List:LuaListAddLast("Atari Jaguar CD","Atari Jaguar CD")
	if PlatformID == 7 then
		ReturnPlatform = "Atari Jaguar CD"
	end
	List:LuaListAddLast("Atari XE","Atari XE")
	if PlatformID == 8 then
		ReturnPlatform = "Atari XE"
	end
	List:LuaListAddLast("Colecovision","Colecovision")
	if PlatformID == 9 then
		ReturnPlatform = "Colecovision"
	end
	List:LuaListAddLast("Commodore 64","Commodore 64")
	if PlatformID == 10 then
		ReturnPlatform = "Commodore 64"
	end
	List:LuaListAddLast("Intellivision","Intellivision")
	if PlatformID == 11 then
		ReturnPlatform = "Intellivision"
	end
	List:LuaListAddLast("Mac OS","Mac OS")
	if PlatformID == 12 then
		ReturnPlatform = "Mac OS"
	end
	List:LuaListAddLast("Microsoft Xbox","Microsoft Xbox")
	if PlatformID == 13 then
		ReturnPlatform = "Microsoft Xbox"
	end
	List:LuaListAddLast("Microsoft Xbox 360","Microsoft Xbox 360")
	if PlatformID == 14 then
		ReturnPlatform = "Microsoft Xbox 360"
	end
	List:LuaListAddLast("NeoGeo","NeoGeo")
	if PlatformID == 15 then
		ReturnPlatform = "NeoGeo"
	end
	List:LuaListAddLast("Nintendo 64","Nintendo 64")
	if PlatformID == 16 then
		ReturnPlatform = "Nintendo 64"
	end
	List:LuaListAddLast("Nintendo DS","Nintendo DS")
	if PlatformID == 17 then
		ReturnPlatform = "Nintendo DS"
	end
	List:LuaListAddLast("Nintendo Entertainment System (NES)","Nintendo Entertainment System (NES)")
	if PlatformID == 18 then
		ReturnPlatform = "Nintendo Entertainment System (NES)"
	end
	List:LuaListAddLast("Nintendo Gameboy","Nintendo Gameboy")
	if PlatformID == 19 then
		ReturnPlatform = "Nintendo Gameboy"
	end
	List:LuaListAddLast("Nintendo Gameboy Advance","Nintendo Gameboy Advance")
	if PlatformID == 20 then
		ReturnPlatform = "Nintendo Gameboy Advance"
	end
	List:LuaListAddLast("Nintendo GameCube","Nintendo GameCube")
	if PlatformID == 21 then
		ReturnPlatform = "Nintendo GameCube"
	end
	List:LuaListAddLast("Nintendo Wii","Nintendo Wii")
	if PlatformID == 22 then
		ReturnPlatform = "Nintendo Wii"
	end
	List:LuaListAddLast("Nintendo Wii U","Nintendo Wii U")
	if PlatformID == 23 then
		ReturnPlatform = "Nintendo Wii U"
	end
	List:LuaListAddLast("PC","PC")
	if PlatformID == 24 then
		ReturnPlatform = "PC"
	end
	List:LuaListAddLast("Sega 32X","Sega 32X")
	if PlatformID == 25 then
		ReturnPlatform = "Sega 32X"
	end
	List:LuaListAddLast("Sega CD","Sega CD")
	if PlatformID == 26 then
		ReturnPlatform = "Sega CD"
	end
	List:LuaListAddLast("Sega Dreamcast","Sega Dreamcast")
	if PlatformID == 27 then
		ReturnPlatform = "Sega Dreamcast"
	end
	List:LuaListAddLast("Sega Game Gear","Sega Game Gear")
	if PlatformID == 28 then
		ReturnPlatform = "Sega Game Gear"
	end
	List:LuaListAddLast("Sega Genesis","Sega Genesis")
	if PlatformID == 29 then
		ReturnPlatform = "Sega Genesis"
	end
	List:LuaListAddLast("Sega Master System","Sega Master System")
	if PlatformID == 30 then
		ReturnPlatform = "Sega Master System"
	end
	List:LuaListAddLast("Sega Mega Drive","Sega Mega Drive")
	if PlatformID == 31 then
		ReturnPlatform = "Sega Mega Drive"
	end
	List:LuaListAddLast("Sega Saturn","Sega Saturn")
	if PlatformID == 32 then
		ReturnPlatform = "Sega Saturn"
	end
	List:LuaListAddLast("Sony Playstation","Sony Playstation")
	if PlatformID == 33 then
		ReturnPlatform = "Sony Playstation"
	end
	List:LuaListAddLast("Sony Playstation 2","Sony Playstation 2")
	if PlatformID == 34 then
		ReturnPlatform = "Sony Playstation 2"
	end
	List:LuaListAddLast("Sony Playstation 3","Sony Playstation 3")
	if PlatformID == 35 then
		ReturnPlatform = "Sony Playstation 3"
	end
	List:LuaListAddLast("Sony Playstation Vita","Sony Playstation Vita")
	if PlatformID == 36 then
		ReturnPlatform = "Sony Playstation Vita"
	end
	List:LuaListAddLast("Sony PSP","Sony PSP")
	if PlatformID == 37 then
		ReturnPlatform = "Sony PSP"
	end
	List:LuaListAddLast("Super Nintendo (SNES)","Super Nintendo (SNES)")
	if PlatformID == 38 then
		ReturnPlatform = "Super Nintendo (SNES)"
	end
	List:LuaListAddLast("TurboGrafx 16","TurboGrafx 16")
	if PlatformID == 39 then
		ReturnPlatform = "TurboGrafx 16"
	end
	List:LuaListAddLast("Amiga","Amiga")
	if PlatformID == 41 then
		ReturnPlatform = "Amiga"
	end
	List:LuaListAddLast("Amstrad CPC","Amstrad CPC")
	if PlatformID == 42 then
		ReturnPlatform = "Amstrad CPC"
	end
	List:LuaListAddLast("Android","Android")
	if PlatformID == 43 then
		ReturnPlatform = "Android"
	end
	List:LuaListAddLast("Atari Lynx","Atari Lynx")
	if PlatformID == 44 then
		ReturnPlatform = "Atari Lynx"
	end
	List:LuaListAddLast("Fairchild Channel F","Fairchild Channel F")
	if PlatformID == 45 then
		ReturnPlatform = "Fairchild Channel F"
	end
	List:LuaListAddLast("iOS","iOS")
	if PlatformID == 46 then
		ReturnPlatform = "iOS"
	end
	List:LuaListAddLast("Magnavox Odyssey 2","Magnavox Odyssey 2")
	if PlatformID == 47 then
		ReturnPlatform = "Magnavox Odyssey 2"
	end
	List:LuaListAddLast("Microsoft Xbox One","Microsoft Xbox One")
	if PlatformID == 48 then
		ReturnPlatform = "Microsoft Xbox One"
	end
	List:LuaListAddLast("MSX","MSX")
	if PlatformID == 49 then
		ReturnPlatform = "MSX"
	end
	List:LuaListAddLast("Neo Geo Pocket","Neo Geo Pocket")
	if PlatformID == 50 then
		ReturnPlatform = "Neo Geo Pocket"
	end
	List:LuaListAddLast("Neo Geo Pocket Color","Neo Geo Pocket Color")
	if PlatformID == 51 then
		ReturnPlatform = "Neo Geo Pocket Color"
	end
	List:LuaListAddLast("Nintendo 3DS","Nintendo 3DS")
	if PlatformID == 52 then
		ReturnPlatform = "Nintendo 3DS"
	end
	List:LuaListAddLast("Nintendo Game Boy Color","Nintendo Game Boy Color")
	if PlatformID == 53 then
		ReturnPlatform = "Nintendo Game Boy Color"
	end
	List:LuaListAddLast("Nintendo Virtual Boy","Nintendo Virtual Boy")
	if PlatformID == 54 then
		ReturnPlatform = "Nintendo Virtual Boy"
	end
	List:LuaListAddLast("Ouya","Ouya")
	if PlatformID == 55 then
		ReturnPlatform = "Ouya"
	end
	List:LuaListAddLast("Philips CD-i","Philips CD-i")
	if PlatformID == 56 then
		ReturnPlatform = "Philips CD-i"
	end
	List:LuaListAddLast("Sinclair ZX Spectrum","Sinclair ZX Spectrum")
	if PlatformID == 57 then
		ReturnPlatform = "Sinclair ZX Spectrum"
	end
	List:LuaListAddLast("Sony Playstation 4","Sony Playstation 4")
	if PlatformID == 58 then
		ReturnPlatform = "Sony Playstation 4"
	end
	List:LuaListAddLast("Sony Playstation Vita","Sony Playstation Vita")
	if PlatformID == 59 then
		ReturnPlatform = "Sony Playstation Vita"
	end
	List:LuaListAddLast("WonderSwan","WonderSwan")
	if PlatformID == 60 then
		ReturnPlatform = "WonderSwan"
	end
	List:LuaListAddLast("WonderSwan Color","WonderSwan Color")
	if PlatformID == 61 then
		ReturnPlatform = "WonderSwan Color"
	end
	
	return 0,"",ReturnPlatform,List
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
	
	wordList = {}
	gameList = {}
	for word in SearchText:gmatch("%w+") do 
		wordList[word] = true 
	end
	
	
	ListDepth = tonumber(ListDepth)
	if ListDepth==1 then 
		ReturnedFile = Internet:GET("http://thegamesdb.net/api/GetGamesList.php?name="..Internet:Encode(SearchText).."&platform="..Internet:Encode(Platform),"SearchGame.xml"
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
					table.insert(gameList, {name,id,0,0,0})
				end 
			end 
		end
		
		--v[3] is number of matches of whole words of search term
		--v[4] is number of words that don't match
		--v[5] is largest match of characters
		
		for k,v in pairs(gameList) do
			for word in v[1]:gmatch("%w+") do
				if wordList[word] == true then 
					v[3] = v[3] + 1
				else
					v[4] = v[4] + 1
				end 
			end 
			v[5] = lcs(v[1],SearchText)
		end 
		
		table.sort(gameList, SearchGameCompare)
		
		for k,v in pairs(gameList) do
			List:LuaListAddLast(v[1],v[2])
		end
		
		
		return 0,"",0,List
	else
		--Error
		return 1,"Invalid List Depth",0,List
	end
end

function lcs(xstr, sstr)
	sstr = sstr:gsub("%s+", "")
	xstr = xstr:gsub("%s+", "")
	
	maxlen = 0
--	itemname = ""
	
    for i = 1, #xstr do
		local x = xstr:sub(i,i)
		for j = 1, #sstr do
			local s = sstr:sub(j,j)
			if x == s then 
				for k=0, math.min(#xstr-i,#sstr-j) do
					if sstr:sub(j,j+k) == xstr:sub(i,i+k) then 
						if maxlen < k+1 then 
--							itemname = sstr:sub(j,j+k)
							maxlen = k+1
						end
					else
						break
					end
				end 
			end 
		end
	end
	
	return maxlen
end

function SearchGameCompare(a,b)
	-- Match by matching words first
	if a[3] > b[3] then 
		return true 
	elseif a[3] < b[3] then 
		return false
	else
		-- Then Match by longest subset of search string
		if a[5] > b[5] then 
			return true 
		elseif a[5] < b[5] then 
			return false
		else
			-- Finally match by number of extra words
			return a[4] < b[4]
		end
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

