Rem - Removed, Not used in code any more

?Win32
'MARK: Core Count
Type SYSTEM_INFO
	Field wProcessorArchitecture:Short
	Field wReserved:Short
	Field dwPageSize:Int
	Field lpMinimumApplicationAddress:Byte Ptr
	Field lpMaximumApplicationAddress:Byte Ptr
	Field dwActiveProcessorMask:Int
	Field dwNumberOfProcessors:Int
	Field dwProcessorType:Int
	Field dwAllocationGranularity:Int
	Field wProcessorLevel:Short
	Field wProcessorRevision:Short
End Type

Extern "win32"
	Function GetSystemInfo (si:Byte Ptr)
End Extern

Function CpuCount:Int()
	Local info:SYSTEM_INFO=New SYSTEM_INFO
	GetSystemInfo(info)
	Return info.dwNumberOfProcessors
End Function
?

endrem 

'MARK: MAIN CORE - Texture Operations
Function FrameLimiter()
		
	ProcessGraphicsQueue(1)'NEW
	
	While MilliSecs() + OverProcessTime - FrameTimer < 1000 / (FRAMERATE+1)
	'	ProcessGraphicsQueue(1)
	'	RendersWithoutProcess = RendersWithoutProcess - 1
	'Delay 1'NEW
	Wend	
	'OverProcessTime = (MilliSecs() + OverProcessTime - FrameTimer) - (1000 / FRAMERATE)
	'RendersWithoutProcess = RendersWithoutProcess + 1
	'If RendersWithoutProcess < 0 Then RendersWithoutProcess = 0
	FrameTimer = MilliSecs()
	'If RendersWithoutProcess > FRAMERATE Then
	'	ProcessGraphicsQueue(0)
	'	RendersWithoutProcess = 0
	'EndIf	

End Function

Function RenderLimiter()
	RenderFrameNumber = RenderFrameNumber + RENDERRATE
	If RenderFrameNumber>1 Then 
		RenderFrameNumber = RenderFrameNumber - 1
		RenderLoop = True 
	Else
		RenderLoop = False 
	EndIf 
End Function 

Function MemoryLimiter()
	LockMutex(TTexture.Mutex_UsedSpace)
	If Int(TTexture.UsedSpace)/1000000 > 999 Then 
		If LowMemory = True And TempLowMemoryControl = False Then 
		
		Else		
			LowMemory = True 
			LockMutex(Mutex_UpdateStackThreadResources)
			USTR_LM = LowMemory
			UnlockMutex(Mutex_UpdateStackThreadResources)			
			TempLowMemoryControl = True 
		EndIf 
	Else
		If TempLowMemoryControl = True Then
			LowMemory = False 
			LockMutex(Mutex_UpdateStackThreadResources)
			USTR_LM = LowMemory
			UnlockMutex(Mutex_UpdateStackThreadResources)
		EndIf 
	EndIf 
	UnlockMutex(TTexture.Mutex_UsedSpace)
End Function 

Function ProcessGraphicsQueue(Num:Int)
	
	Local Tex:TPixmapTexture
	Local Tex2:TTexture
	If Num = 0 Then Num = 30
	For a = 1 To Num
		If(TryLockMutex(Mutex_TextureQueue) ) Then
			If TextureQueue.Count() < 1 Then
				UnlockMutex(Mutex_TextureQueue)
				Exit
			EndIf
			Tex = TPixmapTexture(TextureQueue.RemoveFirst())
			UnlockMutex(Mutex_TextureQueue)
			Tex2 = LoadTextureFromPixmap(Tex)
			LockMutex(TTexture.Mutex_tex_list)
			If Tex2 <> Null Then
				If ListContains(ProcessedTextures , Tex2.file) <> True Then
					ListAddLast(ProcessedTextures , Tex2.file)			
				EndIf
			EndIf
			UnlockMutex(TTexture.Mutex_tex_list)
		Else
			Exit
		EndIf
	Next
End Function 

'MARK: 2ND CORE - Main Texture Thread
Function MainTextureLoadThread:Object(in:Object)
	Local RepeatStack:Int = 0
	Local StackItem:String
	PrintF("SubThread: Posting Signal and Waiting",LogName2)
	PostSemaphore(WaitingThread)
	
	Repeat
		WaitSemaphore(StartupThread)
		LockMutex(Mutex_ThreadStatus)
		ThreadStatus = 1
		UnlockMutex(Mutex_ThreadStatus)
		StartThreadTime = MilliSecs()
		Repeat
			LockMutex(Mutex_ProcessStack)
			StackItem = String(ProcessStack.RemoveFirst())
			UnlockMutex(Mutex_ProcessStack)
			If StackItem = Null Then Exit
			?Debug
				s = MilliSecs()
				PrintF("SubThread: Begin Loading "+StackItem,LogName2)
			?
			tempTPT:TPixmapTexture = LoadTexturePixmap(StackItem)
			?Debug
				PrintF("SubThread: Finished Loading",LogName2)
				e = MilliSecs()
				PrintF("SubThread: Time " + String(e - s) + " Core "+String(in) ,LogName2)
			?
			If tempTPT = Null Then
			Else
				PrintF("SubThread: Adding to Stack",LogName2)
				LockMutex(Mutex_TextureQueue)
				ListAddLast(TextureQueue , tempTPT)
				UnlockMutex(Mutex_TextureQueue)
			EndIf
			LockMutex(Mutex_ResetTextureThread)
			If ResetTextureThread = 1 Then
				PrintF("SubThread: Reset Triggered",LogName2)
				ResetTextureThread = 0
				UnlockMutex(Mutex_ResetTextureThread)
				Exit
			EndIf
			UnlockMutex(Mutex_ResetTextureThread)
		Forever
		LockMutex(Mutex_ThreadStatus)
		ThreadStatus = 0
		UnlockMutex(Mutex_ThreadStatus)		
		
		LockMutex(Mutex_CloseTextureThread)
		If CloseTextureThread = 1 Then Exit
		UnlockMutex(Mutex_CloseTextureThread)
	Forever
End Function

Function UpdateStackThread:Object(in:Object) 'UpdateStack()
	Local GAL:Int
	Local GA:String[]
	Local CGP:Int
	Local CIN:Int
	
	PostSemaphore(WaitingThread2)
	Repeat
		WaitSemaphore(StartupThread2)
		LockMutex(Mutex_UpdateStackThreadResources)
		CGP = USTR_CGP
		CIN = USTR_CIN	
		If USTR_UGA = True Then
			GA = USTR_GA
			GAL = GA.length
			USTR_UGA = False
		EndIf 
		UnlockMutex(Mutex_UpdateStackThreadResources)
	 
		Select CIN
			Case 6 'CoverWall
				CoverWallUpdateStack(CGP,GAL,GA,USTR_GCL,USTR_LM,1,1,0,0)
			Case 5 'BannerFlow
				BannerFlowUpdateStack(CGP,GAL,GA,USTR_GCL,USTR_LM,1,1,1,1)
			Case 4 'ListView
				GeneralUpdateStack(CGP,GAL,GA,USTR_GCL,USTR_LM,1,1,1,0)
			Case 3 'InfoView Banner
				BannerFlowUpdateStack(CGP,GAL,GA,USTR_GCL,USTR_LM,0,0,1,1)
			Case 2 'InfoView
				CoverFlowUpdateStack(CGP,GAL,GA,USTR_GCL,USTR_LM,1,1,1,0)
			Case 1 'CoverFlow
				CoverFlowUpdateStack(CGP,GAL,GA,USTR_GCL,USTR_LM,1,1,0,0)
			Default 
		End Select 
	Forever	
	
End Function

Function BannerFlowUpdateStack(CGP:Int,GAL:Int,GA:String[],GCL:Int,LM:Int,LoadFront:Int,LoadBack:Int,LoadScreen:Int,LoadBanner:Int)
		Local FrontList:TList = CreateList()
		Local BackList:TList = CreateList()
		Local FrontList2:TList = CreateList()
		Local BackList2:TList = CreateList()
					
		Local GameStack:TList = CreateList()
		Local GameStack2:TList = CreateList()		
		Local TextureStack:TList = CreateList()
		Local TextureStack2:TList = CreateList()
		Local a:Int , b:Int , c:Int 
		Local Tex:TTexture
		Local File:String
		Local BannerCount:Int = 0

		c = 0
		For a = CGP To CGP + (GAL / 2) - 1

			If a > GAL - 1 Then
				b = a - GAL
			Else
				b = a
			EndIf
			
			If c > Ceil(Float(GCL) / 2) - 1 Then
				ListAddLast(FrontList2 , GA[b])
			Else
				ListAddLast(FrontList , GA[b])
			EndIf 
			c = c + 1
		Next 
		
		c = 0
		For a = CGP + GAL - 1 To CGP + GAL / 2 Step - 1

			If a > GAL - 1 Then
				b = a - GAL
			Else
				b = a
			EndIf
			
			If c > Floor(Float(GCL) / 2) - 1 Then
				ListAddLast(BackList2 , GA[b])
			Else
				ListAddLast(BackList , GA[b])	
			EndIf 
			c = c + 1
		Next 
		
		Local List1String:String , List2String:String
		Repeat
			List1String = String(FrontList.RemoveFirst())
			If List1String = Null Then
			
			Else
				ListAddLast(GameStack , List1String)
			EndIf
			List2String = String(BackList.RemoveFirst())
			If List2String = Null Then
			
			Else
				ListAddLast(GameStack , List2String)
			EndIf	
			
			If List1String = Null And List2String = Null Then Exit
		Forever
		
		Repeat
			List1String = String(FrontList2.RemoveFirst())
			If List1String = Null Then
			
			Else
				ListAddLast(GameStack2 , List1String)
			EndIf
			List2String = String(BackList2.RemoveFirst())
			If List2String = Null Then
			
			Else
				ListAddLast(GameStack2 , List2String)
			EndIf	
			If List1String = Null And List2String = Null Then Exit
		Forever
				
		FrontList = Null
		BackList = Null
		FrontList2 = Null
		BackList2 = Null		
		a = Null
		b = Null
		'Load First Cover
		File = String(GameStack.First())
		If FileType(GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg") = 1 And LoadFront = 1 Then
			ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg")
		EndIf	

		'Load intial 10 games Banners			
		For File = EachIn GameStack
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg") = 1 And LoadBanner = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg")
				BannerCount = BannerCount + 1
			EndIf
		Next
		
		'Load First Back and Screen
		File = String(GameStack.First())
		If FileType(GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg") = 1 And LoadScreen = 1 Then
			ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg")
		EndIf
		If FileType(GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg") = 1 And LoadBack = 1 Then
			ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg")
		EndIf			
		
		'Load intial 10 games remaining resources
		For File = EachIn GameStack
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg") = 1 And LoadFront = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg")
			EndIf
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg") = 1 And LoadBack = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg")
			EndIf		
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg") = 1 And LoadScreen = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg")
			EndIf				
		Next
		
		'Load all other banners
		If LM = False Then 
			For File = EachIn GameStack2
				If FileType(GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg") = 1 And LoadBanner = 1 Then
					If BannerCount < MaxFrontCovers Then
						ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg")
						BannerCount = BannerCount + 1
					Else
						Exit 
					EndIf
				EndIf
			Next 
		EndIf 		

		
		'PrintF("Clearing Unused Textures")
		LockMutex(TTexture.Mutex_tex_list)
		For Tex = EachIn TTexture.tex_list
			File = Tex.file
			If Left(File , Len(GAMEDATAFOLDER) ) = GAMEDATAFOLDER Then
				If ListContains(TextureStack , File) Or ListContains(InUseTextures,File) Then
				
				Else
					ListRemove(TTexture.tex_list , Tex)
					ListRemove(ProcessedTextures , File)
					PrintF("Freed: "+File)
					FreeTexture(Tex)
					Tex = Null		
				EndIf
			EndIf
		Next
		UnlockMutex(TTexture.Mutex_tex_list)
	
		'PrintF("Final Filter")
		For File = EachIn TextureStack
			If ListContains(ProcessedTextures , File) <> True And ListContains(TextureStack2 , File) <> True Then
				ListAddLast(TextureStack2 , File)
				?Debug
				PrintF("STACK: "+File)
				?
			EndIf
		Next		
		'PrintF("TextureStack Finish")	
		'Return TextureStack2
		
		LockMutex(Mutex_ProcessStack)
		ProcessStack = TextureStack2
		UnlockMutex(Mutex_ProcessStack)	
End Function

Function CoverWallUpdateStack(CGP:Int,GAL:Int,GA:String[],GCL:Int,LM:Int,LoadFront:Int,LoadBack:Int,LoadScreen:Int,LoadBanner:Int)

		Local FrontList:TList = CreateList()
		Local BackList:TList = CreateList()
		Local FrontList2:TList = CreateList()
		Local BackList2:TList = CreateList()
		
		Local Row1FList:TList = CreateList() 'Row 1
		Local Row1BList:TList = CreateList()
		Local RowM1FList:TList = CreateList() 'Row -1
		Local RowM1BList:TList = CreateList()
				
		Local GameStack:TList = CreateList()
		Local GameStack2:TList = CreateList()		
		Local TextureStack:TList = CreateList()
		Local TextureStack2:TList = CreateList()
		Local a:Int , b:Int , c:Int , d:Int
		Local Tex:TTexture
		Local File:String
		Local itemsPerRow:Int = Max(Ceil(Float(GAL) / 5) , 5)
		Local FrontCoverCount:Int = 0

		c = 0
		For a = CGP To CGP + (GAL / 2) - 1

			If a > GAL - 1 Then
				b = a - GAL
			Else
				b = a
			EndIf
			
			If c > Ceil(Float(GCL) / 2) - 1 Then
				ListAddLast(FrontList2 , GA[b])
			Else
				ListAddLast(FrontList , GA[b])
			EndIf 
			c = c + 1
		Next 
		
		c = 0
		For a = CGP + GAL - 1 To CGP + GAL / 2 Step - 1

			If a > GAL - 1 Then
				b = a - GAL
			Else
				b = a
			EndIf
			
			If c > Floor(Float(GCL) / 2) - 1 Then
				ListAddLast(BackList2 , GA[b])
			Else
				ListAddLast(BackList , GA[b])	
			EndIf 
			c = c + 1
		Next 

		c = 0
		For a = CGP + itemsPerRow To CGP + Ceil(Float(GCL) / 2) - 1 + itemsPerRow

			b=a
			
			While b<0
				b=b+GAL
			Wend

			If b>GAL-1 Then 
			
			Else
				
				If c < Ceil(Float(GCL) / 2) - 1 Then 
					ListAddLast(Row1FList , GA[b])
				EndIf 
			EndIf 
			c = c + 1
		Next 
		
		c=0
		For a = CGP + itemsPerRow + GAL - 1 To CGP + itemsPerRow + Ceil(Float(GCL) / 2) Step - 1

			b=a
			
			While b > GAL-1
				b=b-GAL
			Wend
			
			If b>GAL-1 Then 
				
			Else	
				
				If c < Floor(Float(GCL) / 2) - 1 Then			
					ListAddLast(Row1BList , GA[b])	
				EndIf 
			EndIf 
			c = c + 1
		Next 

		c=0
		For a = CGP - itemsPerRow To CGP + Ceil(Float(GCL) / 2) - 1 - itemsPerRow
			
			b=a
			
			While b > GAL-1
				b=b-GAL
			Wend
			
			If b<0 Then 
			
			Else
				If c < Ceil(Float(GCL) / 2) - 1 Then 
					ListAddLast(RowM1FList , GA[b])
				EndIf 
			EndIf 
			c = c + 1
		Next 
		
		c=0
		For a = CGP - itemsPerRow + GAL - 1 To CGP - itemsPerRow + Ceil(Float(GCL) / 2) Step - 1

			b=a

			While b > GAL-1
				b=b-GAL
			Wend
			
			If b<0 Then 
			
			Else
				If c < Floor(Float(GCL) / 2) - 1 Then
					ListAddLast(RowM1BList , GA[b])	
				EndIf 
			EndIf 
			c = c + 1
		Next 			

		Local List1String:String , List2String:String , List3String:String , List4String:String, List5String:String, List6String:String
		Repeat
			List1String = String(FrontList.RemoveFirst())
			If List1String = Null Then
			
			Else
				ListAddLast(GameStack , List1String)
			EndIf
			List2String = String(BackList.RemoveFirst())
			If List2String = Null Then
			
			Else
				ListAddLast(GameStack , List2String)
			EndIf	
			
			List3String = String(Row1FList.RemoveFirst())
			If List3String = Null Then
			
			Else
				ListAddLast(GameStack , List3String)
			EndIf	
			List4String = String(Row1BList.RemoveFirst())
			If List4String = Null Then
			
			Else
				ListAddLast(GameStack , List4String)
			EndIf					
			
			List5String = String(RowM1FList.RemoveFirst())
			If List5String = Null Then
			
			Else
				ListAddLast(GameStack , List5String)
			EndIf	
			List6String = String(RowM1BList.RemoveFirst())
			If List6String = Null Then
			
			Else

				ListAddLast(GameStack , List6String)
			EndIf							
			If List1String = Null And List2String = Null And List3String = Null And List4String = Null And List5String = Null And List6String = Null Then Exit
		Forever

		Repeat
			List1String = String(FrontList2.RemoveFirst())
			If List1String = Null Then
			
			Else
				ListAddLast(GameStack2 , List1String)
			EndIf
			List2String = String(BackList2.RemoveFirst())
			If List2String = Null Then
			
			Else
				ListAddLast(GameStack2 , List2String)
			EndIf	
			If List1String = Null And List2String = Null Then Exit
		Forever
		
		FrontList = Null
		BackList = Null
		FrontList2 = Null
		BackList2 = Null		
		a = Null
		b = Null
		For File = EachIn GameStack
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg") = 1 And LoadFront = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg")
				FrontCoverCount = FrontCoverCount + 1
			EndIf
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg") = 1 And LoadBack = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg")
			EndIf		
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg") = 1 And LoadScreen = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg")
			EndIf		
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg") = 1 And LoadBanner = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg")
			EndIf		
									
		Next
		
		If LM = False Then 
			For File = EachIn GameStack2
				If FileType(GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg") = 1 And LoadFront = 1 Then
					If FrontCoverCount < MaxFrontCovers Then
						ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg")
						FrontCoverCount = FrontCoverCount + 1
					Else
						
						Exit 
					EndIf
				EndIf
			Next 
		EndIf 		
		
		'PrintF("Clearing Unused Textures")
		LockMutex(TTexture.Mutex_tex_list)
		For Tex = EachIn TTexture.tex_list
			File = Tex.file
			If Left(File , Len(GAMEDATAFOLDER) ) = GAMEDATAFOLDER Then
				If ListContains(TextureStack , File) Or ListContains(InUseTextures,File) Then
				
				Else
					ListRemove(TTexture.tex_list , Tex)
					ListRemove(ProcessedTextures , File)
					PrintF("Freed: "+File)
					FreeTexture(Tex)
					Tex = Null		
				EndIf
			EndIf
		Next
		UnlockMutex(TTexture.Mutex_tex_list)
	
		'PrintF("Final Filter")
		For File = EachIn TextureStack
			If ListContains(ProcessedTextures , File) <> True Then
				ListAddLast(TextureStack2 , File)
				?Debug
				PrintF("STACK: "+File)
				?
			EndIf
		Next		
		'PrintF("TextureStack Finish")	
		'Return TextureStack2
		
		LockMutex(Mutex_ProcessStack)
		ProcessStack = TextureStack2
		UnlockMutex(Mutex_ProcessStack)	
	
End Function

Function CoverFlowUpdateStack(CGP:Int,GAL:Int,GA:String[],GCL:Int,LM:Int,LoadFront:Int,LoadBack:Int,LoadScreen:Int,LoadBanner:Int)
		
		Local FrontList:TList = CreateList()
		Local BackList:TList = CreateList()
		Local FrontList2:TList = CreateList()
		Local BackList2:TList = CreateList()
				
		Local GameStack:TList = CreateList()
		Local GameStack2:TList = CreateList()		
		Local TextureStack:TList = CreateList()
		Local TextureStack2:TList = CreateList()
		Local a:Int , b:Int , c:Int , d:Int
		Local Tex:TTexture
		Local File:String
		Local FrontCoverCount:Int = 0

		c = 0
		For a = CGP To CGP + (GAL / 2) - 1

			If a > GAL - 1 Then
				b = a - GAL
			Else
				b = a
			EndIf
			
			If c > Ceil(Float(GCL) / 2) - 1 Then
				ListAddLast(FrontList2 , GA[b])
			Else
				ListAddLast(FrontList , GA[b])
			EndIf 
			c = c + 1
		Next 
		
		c = 0
		For a = CGP + GAL - 1 To CGP + GAL / 2 Step - 1

			If a > GAL - 1 Then
				b = a - GAL
			Else
				b = a
			EndIf
			
			If c > Floor(Float(GCL) / 2) - 1 Then
				ListAddLast(BackList2 , GA[b])
			Else
				ListAddLast(BackList , GA[b])	
			EndIf 
			c = c + 1
		Next 
		
	
		
		Local List1String:String , List2String:String 
		Repeat
			List1String = String(FrontList.RemoveFirst())
			If List1String = Null Then
			
			Else
				ListAddLast(GameStack , List1String)
			EndIf
			List2String = String(BackList.RemoveFirst())
			If List2String = Null Then
			
			Else
				ListAddLast(GameStack , List2String)
			EndIf	
			
			
			If List1String = Null And List2String = Null Then Exit
		Forever
		
		Repeat
			List1String = String(FrontList2.RemoveFirst())
			If List1String = Null Then
			
			Else
				ListAddLast(GameStack2 , List1String)
			EndIf
			List2String = String(BackList2.RemoveFirst())
			If List2String = Null Then
			
			Else
				ListAddLast(GameStack2 , List2String)
			EndIf	
			If List1String = Null And List2String = Null Then Exit
		Forever
				
		FrontList = Null
		BackList = Null
		FrontList2 = Null
		BackList2 = Null		
		a = Null
		b = Null
		
		For File = EachIn GameStack
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg") = 1 And LoadFront = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg")
				FrontCoverCount = FrontCoverCount + 1
			EndIf
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg") = 1 And LoadBack = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg")
			EndIf		
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg") = 1 And LoadScreen = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg")
			EndIf		
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg") = 1 And LoadBanner = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg")
			EndIf										
		Next
		
		If LM = False Then 
			For File = EachIn GameStack2
				If FileType(GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg") = 1 And LoadFront = 1 Then
					If FrontCoverCount < MaxFrontCovers Then
						ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg")
						FrontCoverCount = FrontCoverCount + 1
					Else
						Exit 
					EndIf
				EndIf
			Next 
		EndIf 		
		
		
		'PrintF("Clearing Unused Textures")
		LockMutex(TTexture.Mutex_tex_list)
		For Tex = EachIn TTexture.tex_list
			File = Tex.file
			If Left(File , Len(GAMEDATAFOLDER) ) = GAMEDATAFOLDER Then
				If ListContains(TextureStack , File) Or ListContains(InUseTextures,File) Then
				
				Else
					ListRemove(TTexture.tex_list , Tex)
					ListRemove(ProcessedTextures , File)
					PrintF("Freed: "+File)
					FreeTexture(Tex)
					Tex = Null		
				EndIf
			EndIf
		Next
		UnlockMutex(TTexture.Mutex_tex_list)
	
		'PrintF("Final Filter")
		For File = EachIn TextureStack
			If ListContains(ProcessedTextures , File) <> True Then
				ListAddLast(TextureStack2 , File)
				?Debug
				PrintF("STACK: "+File)
				?
			EndIf
		Next		
		'PrintF("TextureStack Finish")	
		'Return TextureStack2
		
		LockMutex(Mutex_ProcessStack)
		ProcessStack = TextureStack2
		UnlockMutex(Mutex_ProcessStack)	
End Function

Function GeneralUpdateStack(CGP:Int,GAL:Int,GA:String[],GCL:Int,LM:Int,LoadFront:Int,LoadBack:Int,LoadScreen:Int,LoadBanner:Int)
		
		Local FrontList:TList = CreateList()
		Local BackList:TList = CreateList()
					
		Local GameStack:TList = CreateList()

		Local TextureStack:TList = CreateList()
		Local TextureStack2:TList = CreateList()
		
		Local a:Int , b:Int , c:Int 
		Local Tex:TTexture
		Local File:String

		c = 0
		For a = CGP To CGP + (GAL / 2) - 1

			If a > GAL - 1 Then
				b = a - GAL
			Else
				b = a
			EndIf
			
			If c > Ceil(Float(GCL) / 2) - 1 Then
				Exit
			Else
				ListAddLast(FrontList , GA[b])
			EndIf 
			c = c + 1
		Next 
		
		c = 0
		For a = CGP + GAL - 1 To CGP + GAL / 2 Step - 1

			If a > GAL - 1 Then
				b = a - GAL
			Else
				b = a
			EndIf
			
			If c > Floor(Float(GCL) / 2) - 1 Then
				Exit
			Else
				ListAddLast(BackList , GA[b])	
			EndIf 
			c = c + 1
		Next 
		
		
		
		Local List1String:String , List2String:String 
		Repeat
			List1String = String(FrontList.RemoveFirst())
			If List1String = Null Then
			
			Else
				ListAddLast(GameStack , List1String)
			EndIf
			List2String = String(BackList.RemoveFirst())
			If List2String = Null Then
			
			Else
				ListAddLast(GameStack , List2String)
			EndIf	
				
			If List1String = Null And List2String = Null Then Exit
		Forever
					
		FrontList = Null
		BackList = Null
		a = Null
		b = Null
		For File = EachIn GameStack
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg") = 1 And LoadFront = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Front_OPT.jpg")
			EndIf
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg") = 1 And LoadBack = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Back_OPT.jpg")
			EndIf		
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg") = 1 And LoadScreen = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Screen_OPT.jpg")
			EndIf		
			If FileType(GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg") = 1 And LoadBanner = 1 Then
				ListAddLast(TextureStack , GAMEDATAFOLDER + File + FolderSlash+"Banner_OPT.jpg")
			EndIf										
		Next
				
		'PrintF("Clearing Unused Textures")
		LockMutex(TTexture.Mutex_tex_list)
		For Tex = EachIn TTexture.tex_list
			File = Tex.file
			If Left(File , Len(GAMEDATAFOLDER) ) = GAMEDATAFOLDER Then
				If ListContains(TextureStack , File) Or ListContains(InUseTextures,File) Then
				
				Else
					ListRemove(TTexture.tex_list , Tex)
					ListRemove(ProcessedTextures , File)
					PrintF("Freed: "+File)
					FreeTexture(Tex)
					Tex = Null		
				EndIf
			EndIf
		Next
		UnlockMutex(TTexture.Mutex_tex_list)
	
		'PrintF("Final Filter")
		For File = EachIn TextureStack
			If ListContains(ProcessedTextures , File) <> True Then
				ListAddLast(TextureStack2 , File)
				?Debug
				PrintF("STACK: "+File)
				?
			EndIf
		Next		
		'PrintF("TextureStack Finish")	
		'Return TextureStack2
		
		LockMutex(Mutex_ProcessStack)
		ProcessStack = TextureStack2
		UnlockMutex(Mutex_ProcessStack)	

End Function 
