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

function GetPlatforms(PlatformID,List)
	List:LuaListAddLast("PC","PC")
	List:LuaListAddLast("Sega Genesis","Sega Genesis")
	--sleep(10)
	--abc = 1
	--abc = abc + "a"
	return 0,"PC",List
end

function GetText()
	return 0,"Content provided kindly by thegamesdb.net","http://thegamesdb.net"
end

function SearchGame(SearchText,PreviousClientData,Platform,ListDepth,Internet,List)
	ListDepth = tonumber(ListDepth)
	if ListDepth==1 then 
		ReturnedFile = Internet:GET("http://thegamesdb.net/api/GetGamesList.php?name="..SearchText.."&platform="..Platform,"SearchGame.xml")
		if ReturnedFile == "-1" then 
			return 1,0,List
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
		
		
		return 0,0,List
	else
		--Error
		return 1,0,List
	end
end


function GetGame(GameContainer,Internet,LuaIDData)
	ReturnedFile = Internet:GET("http://thegamesdb.net/api/GetGame.php?id="..LuaIDData,"GetGame.xml")
	if ReturnedFile == "-1" then 
		print(Internet.LastError)
		return 1,GameContainer
	end
	print("oh")
	local myxml = io.open(ReturnedFile):read('*all')
	local SLAXML = require 'Lua\\Includes\\slaxdom' -- also requires slaxml.lua; be sure to copy both files
	local doc = SLAXML:dom(myxml)
	
	local TrailerString
	local BaseURL
	-- print(doc.root.name)

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

	return 0,GameContainer
end
