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
	return 0,"Hello","http://blob.com"
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
		--ReturnedFile = Internet:GET("http://www.patches-scrolls.de/","Patch.html")

		ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Patch.html"
		local htmlread = io.open(ReturnedFile)
		local htmlfile = htmlread:read('*all')
		
		local formcontent = htmlfile:match("<form action=\"/\"  accept%-charset=\"UTF%-8\" method=\"post\" id=\"search%-block%-form\">(.-)</form>")
		htmlread:close()
		
		local data = "search_block_form="..Internet:Encode(SearchText).."&op="
		
		for name,value in formcontent:gmatch("<input type=\"hidden\" name=\"(.-)\" id=\".-\" value=\"(.-)\".-/>") do 
			data = data.."&"..name.."="..value
		end 
		
		--ReturnedFile = Internet:POST("http://www.patches-scrolls.de/","Patch2.html",data)
		ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Patch2.html"
		
		local htmlread = io.open(ReturnedFile)
		local htmlfile = htmlread:read('*all')		
		
		for item in htmlfile:gmatch("<table class=\"game%-listing%-table\" style=\"height: auto;\" width=\"100%%\">(.-)</table>") do 
			href,name = item:match("<a href=\"(.-)\">(.-)</a>")
			href = "http://www.patches-scrolls.de/patch/"..href:match("/game/(.+)$")
			List:LuaListAddLast(name,href)
		end 
		
		return 0,"",2,List
	elseif ListDepth==2 then 
	
	
	
	
	
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
	ReturnedFile = "C:\\Users\\tom\\Documents\\GameManagerV4\\Temp\\Manual2.html"
	--ReturnedFile = Internet:GET("http://replacementdocs.com/"..LuaIDData,"Manual2.html")
	
	
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
			break 
		end 
		a = a + 1
	end
	
	htmlread:close()

	DownloadWindow:SetGauge(50)
	DownloadWindow:AddText("Downloading: "..name.." ("..itemtype..")")
	ReturnedFile = Internet:GET("http://replacementdocs.com/"..link,"Manual.pdf")
	FileList:LuaListAddLast(ReturnedFile,name.." ("..itemtype..").pdf")
	DownloadWindow:SetGauge(100)
	return 0,"",FileList
end