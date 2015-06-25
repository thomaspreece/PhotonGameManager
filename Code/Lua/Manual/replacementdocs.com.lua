-- Description
-- Takes 	1. ID of the Photon platform
--		 	2: Takes List to add platforms to
-- Returns 	1. Return status of function: 0 for success, 1 for visible error, 2 for invisible error
--			2. Error Text
--			3. The script platform that matches the Photon platform
--			4. The input List
--			Auto returns List to program
function GetPlatforms(PlatformID,List)
	--Add to list the name to show in GM list and data to be passed to SearchGame as platform
	List:LuaListAddLast("All categories","all")
	List:LuaListAddLast("PC (DOS/Windows)","2")
	List:LuaListAddLast("Amiga","4")
	List:LuaListAddLast("Apple II","5")
	List:LuaListAddLast("Atari 2600","6")
	List:LuaListAddLast("Dreamcast","7")
	List:LuaListAddLast("Game Boy Advance","8")
	List:LuaListAddLast("GameCube","9")
	List:LuaListAddLast("Genesis (Mega Drive)","10")
	List:LuaListAddLast("NES (Famicom)","11")
	List:LuaListAddLast("Nintendo 64","12")
	List:LuaListAddLast("PlayStation","14")
	List:LuaListAddLast("PlayStation 2","15")
	List:LuaListAddLast("Super NES (Super Famicom)","16")
	List:LuaListAddLast("Tiger LCD","17")
	List:LuaListAddLast("TurboGrafx 16 (PC Engine)","18")
	List:LuaListAddLast("Xbox","19")
	List:LuaListAddLast("CD-i","20")
	List:LuaListAddLast("Game Boy","21")
	List:LuaListAddLast("Jaguar","22")
	List:LuaListAddLast("Lynx","23")
	List:LuaListAddLast("Nintendo DS","24")
	List:LuaListAddLast("PSP","25")
	List:LuaListAddLast("Saturn","26")
	List:LuaListAddLast("Sega Master System","27")
	List:LuaListAddLast("Commodore 64","28")
	List:LuaListAddLast("3DO","29")
	List:LuaListAddLast("Atari ST","30")
	List:LuaListAddLast("Neo Geo","31")
	List:LuaListAddLast("ZX Spectrum","32")
	List:LuaListAddLast("VIC-20","33")
	List:LuaListAddLast("Game & Watch","34")
	List:LuaListAddLast("Game Boy Color","35")
	List:LuaListAddLast("N-Gage","36")
	List:LuaListAddLast("Intellivision","37")
	List:LuaListAddLast("Amstrad CPC","38")
	List:LuaListAddLast("Sega CD (Mega CD)","39")
	List:LuaListAddLast("Sega 32x","40")
	List:LuaListAddLast("Macintosh","41")
	List:LuaListAddLast("Atari 5200","42")
	List:LuaListAddLast("Atari 7800","43")
	List:LuaListAddLast("Xbox 360","44")
	List:LuaListAddLast("Game Gear","45")
	List:LuaListAddLast("Virtual Boy","46")
	List:LuaListAddLast("PlayStation 3","47")
	List:LuaListAddLast("Wii","48")
	List:LuaListAddLast("Magnavox Odyssey","49")
	List:LuaListAddLast("RCA Studio II","50")
	List:LuaListAddLast("Fairchild Channel F","51")
	List:LuaListAddLast("ColecoVision","52")
	List:LuaListAddLast("Dragon 32/64","53")
	List:LuaListAddLast("TI-99","54")
	List:LuaListAddLast("TRS-80","55")
	List:LuaListAddLast("MSX","56")
	List:LuaListAddLast("BBC Micro","57")
	List:LuaListAddLast("Aquarius","58")
	List:LuaListAddLast("PS Vita","59")
	List:LuaListAddLast("Nintendo 3DS","60")
	List:LuaListAddLast("Wii U","61")
	List:LuaListAddLast("PlayStation 4","62")
	List:LuaListAddLast("Xbox One","63")
	
	return 0,"","All categories",List
end 

-- Description
-- Takes no arguments
-- Returns	1. Return status of function: 0 for success
--			2. The text to be displayed at bottom of search window
--			3. The text URL link
function GetText()
	return 0,"Content provided by replacementdocs.com","http://replacementdocs.com"
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
function Search(SearchText,PreviousClientData,Platform,ListDepth,Internet,List)
	ListDepth = tonumber(ListDepth)
	local ReturnedFile = ""
	
	if ListDepth==1 then 
		ReturnedFile = Internet:GET("http://replacementdocs.com/search.php?q="..Internet:Encode(SearchText).."&r=0&s=Search&in=&ex=&ep=&be=&t=downloads&adv=0&cat="..Platform.."&on=New&time=any&author=&match=0","Manual.html")

		--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Manual.html"
		local htmlread = io.open(ReturnedFile)
		local htmlfile = htmlread:read('*all')
		local results = ""
		a = 1
		for line in htmlfile:gmatch("<table cellspacing='0' width='100%%' class='tableborder'>(.-)</table>") do
			if a == 2 then 
				results = line
				
				break
			end 
			a = a + 1
		end
		htmlread:close()
		
		for href,name,itemtype in results:gmatch("<a class='visit' href='(.-)'>(.-)</a>.-</div>(.-)<br />") do 
			if name then 
				name = name:match("| (.+)")
				name = name:gsub("<span class='searchhighlight'>","")
				name = name:gsub("</span>","")
			end 
			List:LuaListAddLast(name.." ("..itemtype..")",href)
		end 
		
		return 0,"",0,List
	else
		--Error
		return 1,"",0,List
	end
	
	return 2,"",0,List
end



-- Description
-- Takes	1. List to add downloaded files to
--			2. Internet type to get data from net
--			3. ID data to identify which file to get
-- Returns	1. Return status of function: 0 for success
--			2. Error Text
--			3. List to add downloaded files to
function Get(FileList,Internet,LuaIDData,DownloadWindow)
	local ReturnedFile = ""
	
	DownloadWindow:AddText("Getting manual link")
	--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Manual2.html"
	ReturnedFile = Internet:GET("http://replacementdocs.com/"..LuaIDData,"Manual2.html")
	
	
	local htmlread = io.open(ReturnedFile)
	local htmlfile = htmlread:read('*all')
	
	local link = htmlfile:match("<td style='width:80%%' class='forumheader3'><a href='(.-)'> <img src='e107_images/generic/lite/download.png' alt='' style='border:0' />")
	DownloadWindow:AddText(link)
	a = 1
	local name = ""
	local itemtype = ""
	for row in htmlfile:gmatch("<td style='width:75%%' class='forumheader3'>(.-)</td>") do 
		if a == 1 then
			name = row
		elseif a == 2 then 
			itemtype = row
			itemtype = itemtype:gsub("<(.-)>","")
			break 
		end 
		a = a + 1
	end
	
	htmlread:close()

	DownloadWindow:SetGauge(50)
	DownloadWindow:AddText("Downloading: "..name.." ("..itemtype..")")
	ReturnedFile = Internet:GET("http://replacementdocs.com/"..link,"Manual.pdf")
	FileList:LuaListAddLast(ReturnedFile,name.." ["..itemtype.."].pdf")
	DownloadWindow:SetGauge(100)
	return 0,"",FileList
end