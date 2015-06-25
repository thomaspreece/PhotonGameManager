local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

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
	List:LuaListAddLast("All categories","")
	return 0,"","All categories",List
end 

-- Description
-- Takes no arguments
-- Returns	1. Return status of function: 0 for success
--			2. The text to be displayed at bottom of search window
--			3. The text URL link
function GetText()
	return 0,"Content provided by patches-scrolls.de","http://www.patches-scrolls.de"
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
		ReturnedFile = Internet:GET("http://www.patches-scrolls.de/","Patch.html")

		--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Patch.html"
		local htmlread = io.open(ReturnedFile)
		local htmlfile = htmlread:read('*all')
		
		local formcontent = htmlfile:match("<form action=\"/\"  accept%-charset=\"UTF%-8\" method=\"post\" id=\"search%-block%-form\">(.-)</form>")
		htmlread:close()
		
		local data = "search_block_form="..Internet:Encode(SearchText).."&op="
		
		for name,value in formcontent:gmatch("<input type=\"hidden\" name=\"(.-)\" id=\".-\" value=\"(.-)\".-/>") do 
			data = data.."&"..name.."="..value
		end 
		
		ReturnedFile = Internet:POST("http://www.patches-scrolls.de/","Patch2.html",data)
		--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Patch2.html"
		
		local htmlread = io.open(ReturnedFile)
		local htmlfile = htmlread:read('*all')		
		
		for item in htmlfile:gmatch("<table class=\"game%-listing%-table\" style=\"height: auto;\" width=\"100%%\">(.-)</table>") do 
			href,name = item:match("<a href=\"(.-)\">(.-)</a>")
			href = "http://www.patches-scrolls.de/patch/"..href:match("/game/(.+)$")
			List:LuaListAddLast(name,href)
		end 
		
		return 0,"",2,List
	elseif ListDepth==2 then 
		ReturnedFile = Internet:GET(PreviousClientData,"Patch2P0.html")
		--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Patch2P0.html"
		local htmlread = io.open(ReturnedFile)
		local htmlfile = htmlread:read('*all')	

		maxPage = htmlfile:match("<li class=\"pager%-last last\"><a href=\"/patch/.-%?page=(.-)\" title=\"Go to last page\" class=\"active\">last »</a></li>")
		if maxPage then 
			maxPage = tonumber(maxPage)
		else
			maxPage = 0
		end 
		currentPage = 0
		
		while true do 
			noContent = htmlfile:match("<div style=\"text%-align:center;\">No content available</div>(.-)<div class=\"item%-list\">")
			if noContent then 
				break
			else 
				Content = htmlfile:match("<ul class=\"newlistingTable\">(.-)</ul>")
				for href,name in Content:gmatch("<h4><img src=\".-\" style=\".-\" /><a href=\"(.-)\">(.-)</a></h4>") do
					List:LuaListAddLast(name,href)
				end 
				--Extract Content 
			end 
			
			
			currentPage = currentPage + 1
			if currentPage > maxPage then 
				break 
			else
				ReturnedFile = Internet:GET(PreviousClientData.."?page="..currentPage,"Patch2P"..currentPage..".html")
				--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Patch2P"..currentPage..".html"
				htmlread = io.open(ReturnedFile)
				htmlfile = htmlread:read('*all')	
			end 
		end 
		
		return 0,"",3,List
	elseif ListDepth==3 then 
		ReturnedFile = Internet:GET("http://www.patches-scrolls.de"..PreviousClientData,"Patch3.html")
		--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Patch3.html"
		local htmlread = io.open(ReturnedFile)
		local htmlfile = htmlread:read('*all')	

		for patchSet in htmlfile:gmatch("<div class=\"availPatch\">(.-)</ul>.-</div>") do 
			patchPlatform = patchSet:match("<h3>(.-)</h3>")
			
			for patchName,patchLink in patchSet:gmatch("<div class=\"flag\"><img.-src=\"http://www.patches%-scrolls.de/sites/default/files/(.-).png%?.-\" /></div>.-<a href=\"(.-)\">") do 
				List:LuaListAddLast(patchName.." ("..patchPlatform..")",patchLink)
			end 
		
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
	
	DownloadWindow:AddText("Getting patch link")
	--ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Patch4.html"
	ReturnedFile = Internet:GET("http://www.patches-scrolls.de"..LuaIDData,"Patch4.html")
	local htmlread = io.open(ReturnedFile)
	local htmlfile = htmlread:read('*all')		
	
	link = htmlfile:match("<div id=\"game%-downlaod\">.-<div id=\"leftCol\">.-<ul>.-<a href=\"(.-)\".->")
	link = link:gsub("&amp;","&")
	filetype = link:match(".+%.(.-)$")
	title = htmlfile:match("<div id=\"patch%-desp\">.-<h3>(.-)</h3>")
	lang = htmlfile:match("<strong>Language:</strong> <img.-src=\"http://www.patches%-scrolls.de/sites/default/files/(.-).png?.-\"")
	DownloadWindow:AddText("Downloading: "..title.."("..lang..")".."."..filetype)
	ReturnedFile = Internet:GET("http://www.patches-scrolls.de"..link,"Patch5.html")
	
	DownloadWindow:SetGauge(50)
	DownloadWindow:AddText("Waiting 10 seconds for download link")
	for i = 9,1,-1 do 
		sleep(1)
		if DownloadWindow.LogClosed == true then 
			return 3,"",FileList
		end 
		DownloadWindow:AddText(i)
	end 
	
	DownloadWindow:AddText("Downloading...")
	
	
	ReturnedFile = Internet:GET("http://www.patches-scrolls.de/get.php","Patch."..filetype)
	
	FileList:LuaListAddLast(ReturnedFile,title.." ("..lang..")."..filetype)
	DownloadWindow:SetGauge(100)
	return 0,"",FileList
end