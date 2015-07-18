-- Description
-- Takes 	1. ID of the Photon platform
--		 	2: Takes List to add platforms to
--			3. Path to Lua Folder
-- Returns 	1. Return status of function: 0 for success, 1 for visible error, 2 for invisible error
--			2. Error Text
--			3. The script platform that matches the Photon platform
--			4. The input List
--			Auto returns List to program
function GetPlatforms(PlatformID,List,LuaFolder)
	--Add to list the name to show in GM list and data to be passed to SearchGame as platform
	List:LuaListAddLast("All Platforms","0")
	List:LuaListAddLast("3DO","61")
	List:LuaListAddLast("3DS","116")
	List:LuaListAddLast("Acorn Archimedes","48")
	List:LuaListAddLast("Adventurevision","32")
	List:LuaListAddLast("Amazon Fire TV","122")
	List:LuaListAddLast("Amiga","39")
	List:LuaListAddLast("Amiga CD32","70")
	List:LuaListAddLast("Amstrad CPC","46")
	List:LuaListAddLast("Android","106")
	List:LuaListAddLast("APF-*1000/IM","12")
	List:LuaListAddLast("Apple II","8")
	List:LuaListAddLast("Arcade Games","2")
	List:LuaListAddLast("Arcadia 2001","28")
	List:LuaListAddLast("Astrocade","7")
	List:LuaListAddLast("Atari 2600","6")
	List:LuaListAddLast("Atari 5200","20")
	List:LuaListAddLast("Atari 7800","51")
	List:LuaListAddLast("Atari 8-bit","13")
	List:LuaListAddLast("Atari ST","38")
	List:LuaListAddLast("Bandai Pippin","81")
	List:LuaListAddLast("BBC Micro","22")
	List:LuaListAddLast("BBS Door","50")
	List:LuaListAddLast("BlackBerry","107")
	List:LuaListAddLast("Casio Loopy","80")
	List:LuaListAddLast("Cassette Vision","26")
	List:LuaListAddLast("CD-I","60")
	List:LuaListAddLast("Channel F","4")
	List:LuaListAddLast("Colecovision","29")
	List:LuaListAddLast("Commodore 64","24")
	List:LuaListAddLast("Commodore PET","15")
	List:LuaListAddLast("CPS Changer","75")
	List:LuaListAddLast("CreatiVision","23")
	List:LuaListAddLast("Dreamcast","67")
	List:LuaListAddLast("DS","108")
	List:LuaListAddLast("DVD Player","87")
	List:LuaListAddLast("e-Reader","101")
	List:LuaListAddLast("EACA Colour Genie 2000","31")
	List:LuaListAddLast("Famicom Disk System","47")
	List:LuaListAddLast("Flash","102")
	List:LuaListAddLast("FM Towns","55")
	List:LuaListAddLast("FM-7","30")
	List:LuaListAddLast("Game Boy","59")
	List:LuaListAddLast("Game Boy Advance","91")
	List:LuaListAddLast("Game Boy Color","57")
	List:LuaListAddLast("Game.com","86")
	List:LuaListAddLast("GameCube","99")
	List:LuaListAddLast("GameGear","62")
	List:LuaListAddLast("Genesis","54")
	List:LuaListAddLast("Gizmondo","110")
	List:LuaListAddLast("GP32","100")
	List:LuaListAddLast("Intellivision","16")
	List:LuaListAddLast("Interton VC4000","10")
	List:LuaListAddLast("iOS (iPhone/iPad)","112")
	List:LuaListAddLast("Jaguar","72")
	List:LuaListAddLast("Jaguar CD","82")
	List:LuaListAddLast("LaserActive","71")
	List:LuaListAddLast("Linux","33")
	List:LuaListAddLast("Lynx","58")
	List:LuaListAddLast("Macintosh","27")
	List:LuaListAddLast("Mattel Aquarius","36")
	List:LuaListAddLast("Microvision","17")
	List:LuaListAddLast("Mobile","85")
	List:LuaListAddLast("MSX","40")
	List:LuaListAddLast("N-Gage","105")
	List:LuaListAddLast("NEC PC88","21")
	List:LuaListAddLast("NEC PC98","42")
	List:LuaListAddLast("Neo-Geo CD","68")
	List:LuaListAddLast("NeoGeo","64")
	List:LuaListAddLast("NeoGeo Pocket Color","89")
	List:LuaListAddLast("NES","41")
	List:LuaListAddLast("Nintendo 64","84")
	List:LuaListAddLast("Nintendo 64DD","92")
	List:LuaListAddLast("Nuon","93")
	List:LuaListAddLast("Odyssey","3")
	List:LuaListAddLast("Odyssey^2","9")
	List:LuaListAddLast("Online/Browser","69")
	List:LuaListAddLast("Oric 1/Atmos","44")
	List:LuaListAddLast("OS/2","73")
	List:LuaListAddLast("Ouya","119")
	List:LuaListAddLast("Palm OS Classic","96")
	List:LuaListAddLast("Palm webOS","97")
	List:LuaListAddLast("PC","19")
	List:LuaListAddLast("PC-FX","79")
	List:LuaListAddLast("Pinball","1")
	List:LuaListAddLast("Playdia","77")
	List:LuaListAddLast("PlayStation","78")
	List:LuaListAddLast("PlayStation 2","94")
	List:LuaListAddLast("PlayStation 3","113")
	List:LuaListAddLast("PlayStation 4","120")
	List:LuaListAddLast("PlayStation Vita","117")
	List:LuaListAddLast("PSP","109")
	List:LuaListAddLast("RCA Studio II","5")
	List:LuaListAddLast("Redemption","104")
	List:LuaListAddLast("Saturn","76")
	List:LuaListAddLast("Sega 32X","74")
	List:LuaListAddLast("Sega CD","65")
	List:LuaListAddLast("Sega Master System","49")
	List:LuaListAddLast("SG-1000","43")
	List:LuaListAddLast("Sharp X1","37")
	List:LuaListAddLast("Sharp X68000","52")
	List:LuaListAddLast("Sinclair ZX81/Spectrum","35")
	List:LuaListAddLast("Sord M5","25")
	List:LuaListAddLast("Super Cassette Vision","45")
	List:LuaListAddLast("Super Nintendo","63")
	List:LuaListAddLast("SuperVision","66")
	List:LuaListAddLast("Tandy Color Computer","18")
	List:LuaListAddLast("TI-99/4A","14")
	List:LuaListAddLast("Turbo CD","56")
	List:LuaListAddLast("TurboGrafx-16","53")
	List:LuaListAddLast("Vectrex","34")
	List:LuaListAddLast("VIC-20","11")
	List:LuaListAddLast("Virtual Boy","83")
	List:LuaListAddLast("Wii","114")
	List:LuaListAddLast("Wii U","118")
	List:LuaListAddLast("Windows Mobile","88")
	List:LuaListAddLast("WonderSwan","90")
	List:LuaListAddLast("WonderSwan Color","95")
	List:LuaListAddLast("Xbox","98")
	List:LuaListAddLast("Xbox 360","111")
	List:LuaListAddLast("Xbox One","121")
	List:LuaListAddLast("Zeebo","115")
	List:LuaListAddLast("Zodiac","103")	
	
	return 0,"","All Platforms",List
end 

-- Description
-- Takes no arguments
-- Returns	1. Return status of function: 0 for success
--			2. The text to be displayed at bottom of search window
--			3. The text URL link
function GetText()
	return 0,"Content provided by gamefaqs.com","http://gamefaqs.com"
end

-- Description
-- Takes	1. Text to search for
--			2. Text from client data of previous list selection
--			3. The data that was passed from GetPlatforms
--			4. This function may require the user to select a item from lists that go multiple selections deep, this is the current depth of user (1-inf)
--			5. Internet type to get data from net
--			6. The list to populate with results
--			7. Path to Lua Folder
-- Returns	1. Return status of function: 0 for success
--			2. Error text
--			3. The next depth to provide SearchGame or 0 for finished selecting
--			4. The List
function Search(SearchText,PreviousClientData,Platform,ListDepth,Internet,List,LuaFolder)
	ListDepth = tonumber(ListDepth)
	local ReturnedFile = ""
	
	if ListDepth==1 then 
		ReturnedFile = Internet:GET("http://www.gamefaqs.com/search/index.html?game="..Internet:Encode(SearchText).."&page=0&platform="..Platform,"Cheat.html")

		--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Cheat.html"
		local htmlfile = io.open(ReturnedFile):read('*all')
		local results = ""
		for word in htmlfile:gmatch("<table class=\"results\">(.-)</table>") do
			results = results..word
		end
		
		local platform=""
		
		for line in results:gmatch("<tr>(.-)</tr>") do
			platform = line:match("<td class=\"rmain\">(.-)</td>")
			platform = platform:gsub("[^%w]","")
			if platform == "nbsp" then 
				platform = previousPlatform
			end 
			previousPlatform = platform
			name = line:match("<td class=\"rtitle\">(.-)</td>")
			name = name:match(">(.+)<")
			
			local ty = ""
			local a = 1
			for line2 in line:gmatch("<td class=\"rmain\">(.-)</td>") do 
				if a == 3 then 
					ty = line2
					break 
				end
				a = a + 1
			end 
			
			if ty ~= "---" then 
				List:LuaListAddLast(name.." ("..platform..")",ty:match("href=\"(.-)\""))
			end 
		end 
		
		return 0,"",0,List
	else
		--Error
		return 1,"",0,List
	end
	
	return 0,"",0,List
end



-- Description
-- Takes	1. List to add downloaded files to
--			2. Internet type to get data from net
--			3. ID data to identify which file to get
--			4. Path to Lua Folder
-- Returns	1. Return status of function: 0 for success
--			2. Error Text
--			3. List to add downloaded files to
function Get(FileList,Internet,LuaIDData,DownloadWindow,LuaFolder)
	local ReturnedFile = ""
	
	DownloadWindow:AddText("Getting cheat file")
	--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Cheat2.html"
	ReturnedFile = Internet:GET("http://www.gamefaqs.com"..LuaIDData,"Cheat2.html")
	DownloadWindow:SetGauge(50)
	
	local htmlread = io.open(ReturnedFile)
	local htmlfile = htmlread:read('*all')

	local CheatFile = ""
	
	DownloadWindow:AddText("Filtering cheats")
	for line in htmlfile:gmatch("<div class=\"pod\"><div class=\"head\">(.-)</ul>") do
		Title = line:match("<h2 class=\"title\">(.-)</h2>")
		CheatFile = CheatFile..">>>>"..Title.."<<<<\n"
		
		for line2 in line:gmatch("<li class=\"cheat.-\">(.-)</li>") do 
			SubTitle = line2:match("<h3>(.-)</h3>")
			Contributed = line2:match("<p class=\"contrib\"><b>.-</b>.-<a href=\".-\">(.-)</a>")
			Content = line2:match("</div>(.-)<div class=\"cheat_inforate\">")
			TextContent = Content:match("<p>(.-)</p>")
			TableContent = Content:match("<table>(.-)</table>")
			if TextContent then 
				TextContent = TextContent:gsub("<br />","\n")
				TextContent = TextContent:gsub("<.->","")
			else 
				TextContent = ""
			end 
			if TableContent then 
				t = {}
				tpadding = {}
				for TableHeader in TableContent:gmatch("<th>(.-)</th>") do 
					table.insert(t,{TableHeader})
				end 
				for TableRow in TableContent:gmatch("<tr>(.-)</tr>") do
					a = 1 
					for TableCell in TableRow:gmatch("<td>(.-)</td>") do
						table.insert(t[a],TableCell)
						a = a + 1
					end 
				end 
				
				for k,v in pairs(t) do 
					maxlen = 0
					for k2,v2 in pairs(v) do 
						maxlen = math.max(v2:len(),maxlen)
					end 
					table.insert(tpadding,maxlen)
				end
				
				-- #t number of columns
				-- #t[1] number of rows
				for i = 1,#t[1] do 
					TextContent = TextContent.."\n"
					for j = 1,#t do 
						if j ~= #t then 
							TextContent = TextContent..string.format("%-"..(tpadding[j]).."s", t[j][i]).."\t\t"
						else
							TextContent = TextContent..t[j][i]
						end 
					end
				end 
				
			end 
			if Contributed then 
				TextContent = TextContent.."\nContributed by "..Contributed
			end 
			
			CheatFile  = CheatFile.."\n--"..SubTitle.."--\n"..TextContent.."\n"
			
		end 
	end 
	htmlread:close()
	
	--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Lua\\Cheat2.html"
	local writefile = io.open(ReturnedFile,"w")
	writefile:write(CheatFile)
	writefile:close()
	
	FileList:LuaListAddLast(ReturnedFile,"Cheats.txt")
	DownloadWindow:SetGauge(100)
	return 0,"",FileList
end