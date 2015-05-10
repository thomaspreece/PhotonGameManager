Function URLEncode:String(Text:String)
	Text = Replace(Text, " ", "%20")
	Return Text
End Function

Function GameSearchSanitizer$(Name$)
	Rem
	Function:	Removes Illegal Characters from SearchName and returns result
	Input:	Name - SearchName to be Sanitized
	Return:	The Sanitized SearchName
	SubCalls:	None
	EndRem
	Repeat
	For a=1 To Len(Name)
		If Mid(Name,a,1)=Chr(226) Then
			Name=Left(Name,a-1)+"-"+Right(Name,Len(Name)-a-2)
			Exit			
		EndIf	
		If Mid(Name,a,1)="&" Then
			Name = Left(Name , a - 1) + "and" + Right(Name , Len(Name) - a)
			Exit
		EndIf
		If Mid(Name , a , 1) = " " Then
			Name = Left(Name , a - 1) + "%20" + Right(Name , Len(Name) - a)
			Exit			
		EndIf
	Next
	If a=>Len(Name) Then 
		Return Name
	EndIf
	Forever
End Function

Function SanitiseForInternet:String(Text:String)
	Local RepeatLoop:Int
	Local CharCode:String
	Repeat
		RepeatLoop = False
		For a = 1 To Len(Text)
			
			Select Mid(Text , a , 1)
				Case " " , "&" , "." , "," , "!" , "$" , "'"
					Select Mid(Text , a , 1)
						Case " "
							CharCode = "%20"
						Case "&"
							CharCode = "%26"
						Case ","
							CharCode = "%2C"
						Case "!"
							CharCode = "%21"	
						Case "."
							CharCode = "%2E"	
						Case "$"
							CharCode = "%24"
						Case "'"
							CharCode = "%27"
											
					End Select
					Text = Left(Text , a - 1) + CharCode + Right(Text , Len(Text) - a)
					RepeatLoop = True
					Exit									
			End Select
		Next
		If RepeatLoop = False Then Exit
	Forever
	Return Text
End Function
