Function DirNameFilter:String(Text:String, StripSpaces:Int)
	Local TextFixed:String
	Local CharCode:String = ""
	Local Char:String = ""
	Local Offset:Int
	Local match:TRegExMatch	
	
	'Decode any markup we have in text first
	Offset = 0
	Local RegDecodefilter:TRegEx = New TRegEx.Create("%([0-9]+)#")
	TextFixed = Text
	Try
		match = RegDecodefilter.Find(Text)	
		While match
			If match.SubCount() = 2 then
				Char = Chr(int(match.SubExp(1) ) )

				TextFixed = Left(TextFixed, match.SubStart() + Offset ) + Char + Right(TextFixed, Len(TextFixed) - Offset - match.SubStart() - Len(match.SubExp(0) ) )
				Offset = Offset - Len(match.SubExp(0) ) + 1
			Else
				CustomRuntimeError("DirNameFilter1: Match subcount <> 2")
			EndIf
		
			match = RegDecodefilter.Find()
			
		Wend
	Catch e:TRegExException
		CustomRuntimeError("DirNameFilter1: " + e.ToString() )		
	End Try	
	Text = TextFixed

	'Encode everything again
	Offset = 0
	Local Regfilter:TRegEx = New TRegEx.Create("&(amp;|)")
	Local Regfilter2:TRegEx = New TRegEx.Create("[^0-9a-zA-Z\.\- _]")
	Local Regfilter3:TRegEx = New TRegEx.Create(" ")
	'Replace &/&amp with 'and'
	Text = Regfilter.ReplaceAll(Text, "and")
	
	'Replace any character in Regfilter2 and replace with character code %xxx
	TextFixed = Text
	Try
		match = Regfilter2.Find(Text)	
		While match
			If match.SubCount() = 1 then
				CharCode = Asc(match.SubExp(0) )
				TextFixed = Left(TextFixed, match.SubStart() + Offset ) + "%" + CharCode + "#" + Right(TextFixed, Len(TextFixed) - Offset - match.SubStart() - 1)
				Offset = Offset + Len(CharCode + "#" )
			Else
				CustomRuntimeError("DirNameFilter2: Match subcount <> 1")
			EndIf
				
			match = Regfilter2.Find()
		Wend
	Catch e:TRegExException
		CustomRuntimeError("DirNameFilter2: " + e.ToString() )		
	End Try	
	Text = TextFixed
	
	'Replace spaces with underscores
	If StripSpaces = True then
		Text = Regfilter3.ReplaceAll(Text, "_")
	EndIf
	
	Regfilter = Null
	Regfilter2 = Null
	Regfilter3 = Null	

	'Cut down to 250 characters if too long (NTFS limit is 255)
	If Len(Text) > 250 then
		Text = Left(Text, 250)
	EndIf
	
	Return Text
End Function

Function FileNameFilter:String(Text:String, StripSpaces:Int)
	Local TextFixed:String
	Local CharCode:String = ""
	Local Char:String = ""
	Local Offset:Int = 0
	Local match:TRegExMatch

	'Decode any markup we have in text first
	Offset = 0
	Local RegDecodefilter:TRegEx = New TRegEx.Create("%([0-9]+)#")
	TextFixed = Text
	Try
		match = RegDecodefilter.Find(Text)	
		While match
			If match.SubCount() = 2 then
				Char = Chr(int(match.SubExp(1) ) )

				TextFixed = Left(TextFixed, match.SubStart() + Offset ) + Char + Right(TextFixed, Len(TextFixed) - Offset - match.SubStart() - Len(match.SubExp(0) ) )
				Offset = Offset - Len(match.SubExp(0) ) + 1
			Else
				CustomRuntimeError("DirNameFilter1: Match subcount <> 2")
			EndIf
		
			match = RegDecodefilter.Find()
			
		Wend
	Catch e:TRegExException
		CustomRuntimeError("DirNameFilter1: " + e.ToString() )		
	End Try	
	Text = TextFixed

	Local Regfilter:TRegEx = New TRegEx.Create("&(amp;|)")
	Local Regfilter2:TRegEx = New TRegEx.Create("[^0-9a-zA-Z\.\- _()\[\]]")
	Local Regfilter3:TRegEx = New TRegEx.Create(" ")

	Text = Regfilter.ReplaceAll(Text, "and")

	'Replace any character in MyRegfilter2 and replace with character code %xxx
	Offset = 0
	TextFixed = Text
	Try
		match = Regfilter2.Find(Text)	
		While match
			If match.SubCount() = 1 then
				CharCode = Asc(match.SubExp(0) )
				TextFixed = Left(TextFixed, match.SubStart() + Offset ) + "%" + CharCode + Right(TextFixed, Len(TextFixed) - Offset - match.SubStart() - 1)
				Offset = Offset + Len(CharCode)
			Else
				CustomRuntimeError("DirNameFilter: Match subcount <> 1")
			EndIf
				
			match = Regfilter2.Find()
		Wend
	Catch e:TRegExException
		CustomRuntimeError("DirNameFilter: " + e.ToString() )		
	End Try	
	Text = TextFixed

	If StripSpaces = True Then
		Text = Regfilter3.ReplaceAll(Text, "_")
	EndIf

	'Cut down to 250 characters if too long (NTFS limit is 255)
	If Len(Text) > 250 then
		Text = Left(Text, 250)
	EndIf

	Return Text
End Function

Function URLEncode:String(value:String)
	'Encodes URLs
	value = Replace(value, " ", "%20")
	Return value
End Function

Function WebEncode:String(value:String)
	'Encodes all characters for sending over the internet. (Do not use for encoding URLs)
	Local EncodeUnreserved:Int = False
	Local UsePlusForSpace:Int = True
	Local ReservedChars:String = "!*'();:@&=+$,/?%#[]~r~n"  'added space, newline and carriage returns
	Local rc:Int
	Local urc:Int
	Local s:Int
	Local result:String

	For s = 0 To value.length - 1
		If ReservedChars.Find(value[s..s + 1]) > -1 Then
			result:+ "%"+ IntToHexString(Asc(value[s..s + 1]))
			Continue
		ElseIf value[s..s+1] = " " Then
			If UsePlusForSpace Then result:+"+" Else result:+"%20"
			Continue
		ElseIf EncodeUnreserved Then
				result:+ "%" + IntToHexString(Asc(value[s..s + 1]))
			Continue
		EndIf
		result:+ value[s..s + 1]
	Next

	Return result
End Function

Function IntToHexString:String(val:Int, chars:Int = 2)
	Local Result:String = Hex(val)
	Return result[result.length-chars..]
End Function


Function StandardiseSlashes:String(Text:String)
	For a = 1 To Len(Text)
		If Mid(Text , a , 1) = "/" Or Mid(Text , a , 1) = "\" Then
			Text = Left(Text, a - 1) + FolderSlash + Right(Text, Len(Text) - a)
		EndIf
	Next
	Return Text
End Function
