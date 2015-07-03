
Type PlatformReader
	Field PlatformList:TList = CreateList()

	Method GetPlatformNameList:String[]()
		Local PlatformNameArray:String[CountList(PlatformList)]
		Local a:Int = 0
		For Platform:PlatformType = EachIn PlatformList
			PlatformNameArray[a] = Platform.Name
			a = a + 1
		Next
		PlatformNameArray.Sort()
		Return PlatformNameArray
	End Method

	Method GetPlatformByID:PlatformType(PID:Int)
		For Platform:PlatformType = EachIn PlatformList
			If Platform.ID = PID Then 
				Return Platform
			EndIf 
		Next
		Local NullPlatform:PlatformType = PlatformType.Init(0, "", "", "")
		Return NullPlatform
	End Method
	
	Method GetPlatformByName:PlatformType(PName:String)
		For Platform:PlatformType = EachIn PlatformList
			If Platform.Name = PName Then 
				Return Platform
			EndIf
		Next
		Local NullPlatform:PlatformType = PlatformType.Init(0, "", "", "")
		Return NullPlatform
	End Method	

	Method ReadInPlatforms(PlatformFile:String = Null)
		If PlatformFile = Null then
			PlatformFile = SETTINGSFOLDER + "Platforms.xml"
		EndIf
		
		PlatformList = CreateList()
		Local Platdoc:TxmlDoc		
		Local RootNode:TxmlNode , PlatformNode:TxmlNode , TextNode:TxmlNode
			
		Platdoc = TxmlDoc.parseFile(PlatformFile)
	
		If Platdoc = Null Then
			CustomRuntimeError( "Error 36-2: XML Document not parsed successfully, ReadInPlatforms") 'MARK: Error 36-2
		End If
		
		RootNode = Platdoc.getRootElement()
		
		If RootNode = Null Then
			Platdoc.free()
			Platdoc = Null 
			CustomRuntimeError( "Error 37-2: Empty document, ReadInPlatforms") 'MARK: Error 37-2
		End If		

		If RootNode.getName() <> "Platforms" Then
			Platdoc.free()
			Platdoc = Null 
			CustomRuntimeError( "Error 38-2: Document of the wrong type, root node <> Platforms, ReadInPlatforms") 'MARK: Error 38-2
		End If
		
		PrintF("Retrieved Child List")
		Local ChildrenList:TList = RootNode.getChildren()
		If ChildrenList = Null Or ChildrenList.IsEmpty() Then
			Platdoc.free()
			Platdoc = Null 
			CustomRuntimeError( "Error 45: Document error, no data contained within, ReadInPlatforms") 'MARK: Error 45-2			
		EndIf

		Local values:Int = 0
		Local ID:Int
		Local Name:String
		Local PlatType:String 
		Local Emulator:String
		Local Platform:PlatformType

		For PlatformNode = EachIn ChildrenList
			If PlatformNode.getName() = "Platform" Then
				values = 0
				Local TextChildrenList:TList = PlatformNode.getChildren()
				If TextChildrenList = Null Or TextChildrenList.IsEmpty() Then
					Platdoc.free()
					Platdoc = Null 
					CustomRuntimeError( "Error 45: Document error, no data contained within <Platform>, ReadInPlatforms") 'MARK: Error 45-2			
				EndIf				
				
				For TextNode = EachIn TextChildrenList
					If TextNode.getName() = "ID"
						values = values + 1
						ID = Int(TextNode.getText())
					else If TextNode.getName() = "Name"
						values = values + 1
						Name = TextNode.getText()
					Else If TextNode.getName() = "Type"
						values = values + 1
						PlatType = TextNode.getText()
					Else If TextNode.getName() = "Emulator"
						values = values + 1
						Emulator = TextNode.getText()
					EndIf
				Next
				If values = 4 Then 
					Platform = PlatformType.Init(ID, Name, PlatType, Emulator)
					ListAddLast(PlatformList, Platform)
				EndIf 
			EndIf
		Next

		
	End Method 

	Function PopulateDefaultPlatforms(PlatformFile:String = Null)
		If PlatformFile = Null then
			PlatformFile = SETTINGSFOLDER + "Platforms.xml"
		EndIf	
		
		Local Platdoc:TxmlDoc		
		Local RootNode:TxmlNode , PlatformNode:TxmlNode 

		PlatformReader.CreateEmptyXMLPlatform(PlatformFile)
			
		Platdoc = TxmlDoc.parseFile(PlatformFile)
	
		If Platdoc = Null Then
			CustomRuntimeError( "Error 36-2: XML Document not parsed successfully, PopulateDefaultPlatforms") 'MARK: Error 36-2
		End If
		
		RootNode = Platdoc.getRootElement()
		
		If RootNode = Null Then
			Platdoc.free()
			Platdoc = Null 
			CustomRuntimeError( "Error 37-2: Empty document, PopulateDefaultPlatforms") 'MARK: Error 37-2
		End If		

		If RootNode.getName() <> "Platforms" Then
			Platdoc.free()
			Platdoc = Null 
			CustomRuntimeError( "Error 38-2: Document of the wrong type, root node <> Platforms") 'MARK: Error 38-2
		End If

		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "1")
		PlatformNode.addTextChild("Name" , Null , "3DO")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "2")
		PlatformNode.addTextChild("Name" , Null , "Arcade")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "3")
		PlatformNode.addTextChild("Name" , Null , "Atari 2600")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "4")
		PlatformNode.addTextChild("Name" , Null , "Atari 5200")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "5")
		PlatformNode.addTextChild("Name" , Null , "Atari 7800")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "6")
		PlatformNode.addTextChild("Name" , Null , "Atari Jaguar")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "7")
		PlatformNode.addTextChild("Name" , Null , "Atari Jaguar CD")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "8")
		PlatformNode.addTextChild("Name" , Null , "Atari XE")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "9")
		PlatformNode.addTextChild("Name" , Null , "Colecovision")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "10")
		PlatformNode.addTextChild("Name" , Null , "Commodore 64")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "11")
		PlatformNode.addTextChild("Name" , Null , "Intellivision")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "12")
		PlatformNode.addTextChild("Name" , Null , "Mac OS")
		PlatformNode.addTextChild("Type" , Null , "Folder")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "13")
		PlatformNode.addTextChild("Name" , Null , "Microsoft Xbox")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "14")
		PlatformNode.addTextChild("Name" , Null , "Microsoft Xbox 360")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "15")
		PlatformNode.addTextChild("Name" , Null , "NeoGeo")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "16")
		PlatformNode.addTextChild("Name" , Null , "Nintendo 64")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "17")
		PlatformNode.addTextChild("Name" , Null , "Nintendo DS")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "18")
		PlatformNode.addTextChild("Name" , Null , "Nintendo Entertainment System (NES)")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "19")
		PlatformNode.addTextChild("Name" , Null , "Nintendo Gameboy")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "20")
		PlatformNode.addTextChild("Name" , Null , "Nintendo Gameboy Advance")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "21")
		PlatformNode.addTextChild("Name" , Null , "Nintendo GameCube")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "22")
		PlatformNode.addTextChild("Name" , Null , "Nintendo Wii")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "23")
		PlatformNode.addTextChild("Name" , Null , "Nintendo Wii U")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "24")
		PlatformNode.addTextChild("Name" , Null , "PC")
		PlatformNode.addTextChild("Type" , Null , "Folder")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "25")
		PlatformNode.addTextChild("Name" , Null , "Sega 32X")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "26")
		PlatformNode.addTextChild("Name" , Null , "Sega CD")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "27")
		PlatformNode.addTextChild("Name" , Null , "Sega Dreamcast")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "28")
		PlatformNode.addTextChild("Name" , Null , "Sega Game Gear")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "29")
		PlatformNode.addTextChild("Name" , Null , "Sega Genesis")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "30")
		PlatformNode.addTextChild("Name" , Null , "Sega Master System")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "31")
		PlatformNode.addTextChild("Name" , Null , "Sega Mega Drive")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "32")
		PlatformNode.addTextChild("Name" , Null , "Sega Saturn")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "33")
		PlatformNode.addTextChild("Name" , Null , "Sony Playstation")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "34")
		PlatformNode.addTextChild("Name" , Null , "Sony Playstation 2")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "35")
		PlatformNode.addTextChild("Name" , Null , "Sony Playstation 3")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "36")
		PlatformNode.addTextChild("Name" , Null , "Sony Playstation Vita")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "37")
		PlatformNode.addTextChild("Name" , Null , "Sony PSP")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "38")
		PlatformNode.addTextChild("Name" , Null , "Super Nintendo (SNES)")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "39")
		PlatformNode.addTextChild("Name" , Null , "TurboGrafx 16")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "40")
		PlatformNode.addTextChild("Name" , Null , "Linux")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "41")
		PlatformNode.addTextChild("Name" , Null , "Amiga")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "42")
		PlatformNode.addTextChild("Name" , Null , "Amstrad CPC")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "43")
		PlatformNode.addTextChild("Name" , Null , "Android")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "44")
		PlatformNode.addTextChild("Name" , Null , "Atari Lynx")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "45")
		PlatformNode.addTextChild("Name" , Null , "Fairchild Channel F")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "46")
		PlatformNode.addTextChild("Name" , Null , "iOS")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "47")
		PlatformNode.addTextChild("Name" , Null , "Magnavox Odyssey 2")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "48")
		PlatformNode.addTextChild("Name" , Null , "Microsoft Xbox One")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "49")
		PlatformNode.addTextChild("Name" , Null , "MSX")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "50")
		PlatformNode.addTextChild("Name" , Null , "Neo Geo Pocket")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "51")
		PlatformNode.addTextChild("Name" , Null , "Neo Geo Pocket Color")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "52")
		PlatformNode.addTextChild("Name" , Null , "Nintendo 3DS")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "53")
		PlatformNode.addTextChild("Name" , Null , "Nintendo Game Boy Color")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "54")
		PlatformNode.addTextChild("Name" , Null , "Nintendo Virtual Boy")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "55")
		PlatformNode.addTextChild("Name" , Null , "Ouya")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "56")
		PlatformNode.addTextChild("Name" , Null , "Philips CD-i")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "57")
		PlatformNode.addTextChild("Name" , Null , "Sinclair ZX Spectrum")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "58")
		PlatformNode.addTextChild("Name" , Null , "Sony Playstation 4")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "59")
		PlatformNode.addTextChild("Name" , Null , "Sony Playstation Vita")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "60")
		PlatformNode.addTextChild("Name" , Null , "WonderSwan")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
		PlatformNode = RootNode.addTextChild("Platform" , Null , "")
		PlatformNode.addTextChild("ID" , Null , "61")
		PlatformNode.addTextChild("Name" , Null , "WonderSwan Color")
		PlatformNode.addTextChild("Type" , Null , "File")
		PlatformNode.addTextChild("Emulator" , Null , "")
	
		
		For b = 1 To 10
			SaveStatus = Platdoc.saveFormatFile(PlatformFile , False)
			PrintF("SaveXML Try: "+b+" Status: "+SaveStatus)
			If SaveStatus <> - 1 then Exit
			Delay 100
		Next
		If b = 10 Then
			CustomRuntimeError("Error 44-2: Could Not Write XML File") 'MARK: Error 44-2
		EndIf
		Platdoc.free()
		Platdoc = Null 		
			
	End Function

	Function CreateEmptyXMLPlatform(PlatformFile:String = Null)
		If PlatformFile = Null then
			PlatformFile = SETTINGSFOLDER + "Platforms.xml"
		EndIf	
		Local WriteXML:TStream = WriteFile(PlatformFile)
		WriteLine(WriteXML , "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?><Platforms></Platforms>")
		CloseFile(WriteXML)
	End Function
	
	
	Method SavePlatforms(PlatformFile:String = Null)
		If PlatformFile = Null then
			PlatformFile = SETTINGSFOLDER + "Platforms.xml"
		EndIf	
		Local Platdoc:TxmlDoc		
		Local RootNode:TxmlNode , PlatformNode:TxmlNode 
		Local Platform:PlatformType

		PlatformReader.CreateEmptyXMLPlatform(PlatformFile)
			
		Platdoc = TxmlDoc.parseFile(PlatformFile)
	
		If Platdoc = Null Then
			CustomRuntimeError( "Error 36-3: XML Document not parsed successfully, SavePlatforms") 'MARK: Error 36-3
		End If
		
		RootNode = Platdoc.getRootElement()
		
		If RootNode = Null Then
			Platdoc.free()
			Platdoc = Null 
			CustomRuntimeError( "Error 37-3: Empty document, SavePlatforms") 'MARK: Error 37-3
		End If		

		If RootNode.getName() <> "Platforms" Then
			Platdoc.free()
			Platdoc = Null 
			CustomRuntimeError( "Error 38-3: Document of the wrong type, root node <> Platforms, SavePlatforms") 'MARK: Error 38-3
		End If

		For Platform = EachIn PlatformList
			If Platform.ID > 0 then
				PlatformNode = RootNode.addTextChild("Platform" , Null , "")
				PlatformNode.addTextChild("ID" , Null , Platform.ID)
				PlatformNode.addTextChild("Name" , Null , Platform.Name)
				PlatformNode.addTextChild("Type" , Null , Platform.PlatType)
				PlatformNode.addTextChild("Emulator" , Null , Platform.Emulator)
			EndIf 
		Next
		
		For b = 1 To 10
			SaveStatus = Platdoc.saveFormatFile(PlatformFile , False)
			PrintF("SaveXML Try: " + b + " Status: " + SaveStatus)
			If SaveStatus <> - 1 then Exit
			Delay 100
		Next
		If b = 10 Then
			CustomRuntimeError("Error 44-2: Could Not Write XML File") 'MARK: Error 44-2
		EndIf
		Platdoc.free()
		Platdoc = Null 		
			
	End Method
	
	
	
End Type

Type PlatformType
	Field ID:Int
	Field Name:String
	Field PlatType:String
	Field Emulator:String
	
	Function Init:PlatformType(PID:Int, PName:String, PPlatType:String, PEmulator:String)
		PT:PlatformType = New PlatformType
		PT.ID = PID
		PT.Name = PName
		PT.PlatType = PPlatType
		PT.Emulator = PEmulator
		Return PT
	End Function	
	
End Type