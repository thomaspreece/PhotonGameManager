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
		If Mid(Text , a , 1) = "/" Or Mid(Text , a , 1) = "\" then
			Text = Left(Text, a - 1) + FolderSlash + Right(Text, Len(Text) - a)
		EndIf
	Next
	Return Text
End Function
