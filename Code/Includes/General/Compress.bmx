'Requires: BaH.LibArchive (which requires Bah.libiconv, Bah.sstream, Bah.xz, BaH.LibXML)


'Returns 0 for success
'Debug 1 - print extracted Folders
'Debug 2 - print extracted Folders+Files
'Example Use: Extract("bah.mod-master.zip", "NewFolder", 1)
Function Extract:Int(ArchiveFile:String, ExtractPath:String, Debug:Int = 0)
	If Right(ExtractPath, 1) = FolderSlash then
	
	Else
		ExtractPath = ExtractPath + FolderSlash
	EndIf
	If FileType(ExtractPath) = 2 then
	
	Else
		CreateDir(ExtractPath, 1)
	EndIf
	Local Archive:TReadArchive = New TReadArchive.Create()
	Local ArchiveEntry:TArchiveEntry = New TArchiveEntry.Create()
	Archive.SupportFilterAll()
	Archive.SupportFormatAll()
	
	Local Result:Int = Archive.OpenFilename(ArchiveFile)
	If Result <> ARCHIVE_OK then
		Return Result
	End If
	
	Local ExtractingFile:TStream
	Local buff:Byte[100], buffsize:Int = 100, size:Int 
	
	While Archive.ReadNextHeader(ArchiveEntry) = ARCHIVE_OK
		If Right(ArchiveEntry.Pathname(), 1) = "/" Or Right(ArchiveEntry.Pathname(), 1) = "\" then
			CreateDir(ExtractPath + ArchiveEntry.Pathname() , 1)
			If Debug >= 1 then
				PrintF(ExtractPath + ArchiveEntry.Pathname() )
			EndIf
		Else
			ExtractingFile = WriteFile(ExtractPath + ArchiveEntry.Pathname() )
			If Debug = 2 then
				PrintF(ExtractPath + ArchiveEntry.Pathname() )
			EndIf
			Repeat
				size = Archive.Data(buff, buffsize)
				If size < 0 then
					Return 1
				EndIf
				
				If size = 0 then Exit
				
				ExtractingFile.Write(buff, size)
			Forever
			
			CloseFile(ExtractingFile)
		EndIf
	Wend
	
	Result = Archive.Free()
	Return 0
End Function




'Return 0 for success
'Debug 1 - print compressed Folders
'Debug 2 - print compressed Files
'Example Use: Print(Compress("NewArch.tar.gz", "bmk", "C:\BlitzMax\") )
Function Compress:Int(ArchiveFile:String, CompressDir:String, CompressDirContainer:String, Debug:Int = 0)
	If FileType(CompressDirContainer + CompressDir) = 2 then
	
	Else
		PrintF("FileType Error: " + FileType(CompressDirContainer + CompressDir) )
		Return 1
	EndIf
	If Right(CompressDir, 1) = FolderSlash then
	
	Else
		CompressDir = CompressDir + FolderSlash
	EndIf

	Local Archive:TWriteArchive = New TWriteArchive.Create()
	
	Archive.AddFilterGzip() ' gzip
	Archive.SetFormatPaxRestricted() ' tar
	
	Archive.OpenFilename(ArchiveFile)
	

	Local ArchiveEntry:TArchiveEntry = New TArchiveEntry.Create()

	Local DiskFile:TReadDiskArchive = New TReadDiskArchive.Create()
	DiskFile.SetStandardLookup()	
	

	
	Local Directory:Int = ReadDir(CompressDirContainer + CompressDir)
	Local File:String
	Local stream:TSStream
	Local buf:Byte[8192]
	Local bytesRead:Long
	Local Result:Int
	
	Repeat
		File = NextFile(Directory)
		If File = "." Or File = ".." then Continue
		If File = "" then Exit
		
		If FileType(CompressDirContainer + CompressDir + File) = 1 then
			If Debug = 2 then
				PrintF(CompressDir + File)
			EndIf
			ArchiveEntry.Clear()
			ArchiveEntry.SetPathname(CompressDir + File)
			ArchiveEntry.SetSourcePath(CompressDirContainer + CompressDir + File)
			
			' get details about file, and populate TArchiveEntry (timestamps, permissions, etc)
			DiskFile.EntryFromFile(ArchiveEntry)
			
			' write the header
			If Archive.WriteHeader(ArchiveEntry) then
				PrintF(Archive.ErrorString() )
				Return 2
			End If
			
			' load the data for the archive
			stream = BaH.SStream.ReadStream(CompressDirContainer + CompressDir + File)

			bytesRead = stream.Read(buf, 8192)
			
			While bytesRead
				' write into the archive
				Archive.WriteData(buf, bytesRead)
				
				bytesRead = stream.Read(buf, 8192)
			Wend
			
			stream.Close()
		ElseIf FileType(CompressDir + File) = 2 then
			If Debug = 1 then
				PrintF(CompressDir + File)
			EndIf
			Result = CompressSub(ArchiveEntry, DiskFile, Archive, CompressDir + File, CompressDirContainer)
			If Result then
				Return Result
			EndIf
		EndIf
		
	Forever
	
	Archive.Close()
	CloseDir(Directory)
End Function

Function CompressSub:Int(ArchiveEntry:TArchiveEntry, DiskFile:TReadDiskArchive, Archive:TWriteArchive, CompressDir:String, CompressDirContainer:String, Debug:Int = 0 )
	If FileType(CompressDirContainer + CompressDir) = 2 then
	
	Else
		PrintF("FileType Error: " + FileType(CompressDirContainer + CompressDir) )
		Return 1
	EndIf
	If Right(CompressDir, 1) = FolderSlash then
	
	Else
		CompressDir = CompressDir + FolderSlash
	EndIf
	
	Local Directory:Int = ReadDir(CompressDirContainer + CompressDir)
	Local File:String	
	
	Local stream:TSStream
	Local buf:Byte[8192]
	Local bytesRead:Long
	Local Result:Int
	
	Repeat
		File = NextFile(Directory)
		If File = "." Or File = ".." then Continue
		If File = "" then Exit
		
		If FileType(CompressDir + File) = 1 then
			If Debug = 2 then
				PrintF(CompressDir + File)
			EndIf		
			ArchiveEntry.Clear()
			ArchiveEntry.SetPathname(CompressDir + File)
			ArchiveEntry.SetSourcePath(CompressDirContainer + CompressDir + File)
			
			' get details about file, and populate TArchiveEntry (timestamps, permissions, etc)
			DiskFile.EntryFromFile(ArchiveEntry)
			
			' write the header
			If Archive.WriteHeader(ArchiveEntry) then
				PrintF(Archive.ErrorString())
				Return 2
			End If
			
			' load the data for the archive
			stream = BaH.SStream.ReadStream(CompressDirContainer + CompressDir + File)

			bytesRead = stream.Read(buf, 8192)
			
			While bytesRead
				' write into the archive
				Archive.WriteData(buf, bytesRead)
				
				bytesRead = stream.Read(buf, 8192)
			Wend
			
			stream.Close()
		ElseIf FileType(CompressDir + File) = 2 then
			If Debug = 1 then
				PrintF(CompressDir + File)
			EndIf
			Result = CompressSub(ArchiveEntry, DiskFile, Archive, CompressDir + File, CompressDirContainer)
			If Result then
				Return Result
			EndIf
		EndIf
		
	Forever
End Function