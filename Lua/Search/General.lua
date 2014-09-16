-- Description
-- Takes 	1. ID of the GM platform
--		 	2: Takes List to add platforms to
-- Returns 	1. Return status of function: 0 for success, 1 for visible error, 2 for invisible error
--			2. The Source platform that matches the GM platform
--			3. The input List
--			Auto returns List to program
function GetPlatforms(PlatformID,List)
	--Add to list the name to show in GM list and data to be passed to SearchGame as platform
	List:LuaListAddLast("GNewPlat","")
	List:LuaListAddLast("GNewPlat2","")
	List:LuaListAddLast("GNewPlat3","")

	return 0,"GNewPlat3",List


end 

-- Description
-- Takes no arguments
-- Returns	1. Return status of function: 0 for success
--			2. The text to be displayed at bottom of search window
--			3. The text URL link
function GetText()
	return 0,"",""
end

-- Description
-- Takes	1. Text to search for
--			2. Text from client data of previous list selection
--			3. The data that was passed from GetPlatforms
--			4. This function may require the user to select a item from lists that go multiple selections deep, this is the current depth of user (1-inf)
--			5. Internet type to get data from net
--			6. The list to populate with results
-- Returns	1. Return status of function: 0 for success
--			2. The next depth to provide SearchGame or 0 for finished selecting
--			3. The List
function SearchGame(SearchText,PreviousClientData,Platform,ListDepth,Internet,List)

	return 0,1
end



-- Description
-- Takes	1. GameType to write game data to
--			2. Internet type to get data from net
--			3. ID data to identify which game to get
-- Returns	1. Return status of function: 0 for success
--			2. The GameContainer with data in it
function GetGame(GameContainer,Internet,LuaIDData)

	return 0,GameContainer
end