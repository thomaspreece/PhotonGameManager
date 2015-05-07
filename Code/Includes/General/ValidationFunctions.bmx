Function GetDateFromCorrectFormat:String(Date:String)
	PrintF("GetDateFromCorrectFormat")
	PrintF("Input: "+Date)
	Local Dash1 = - 1
	Local Dash2 = - 1
	For a = 1 To Len(Date)
		If Mid(Date , a , 1) = "/" Then
			If Dash1 = -1 Then
				Dash1 = a
			ElseIf Dash2 = - 1 Then
				Dash2 = a
			Else
				'Bad Date
			EndIf	
		EndIf
	Next
	Year:String = Left(Date , Dash1 - 1)
	Month:String = Mid(Date , Dash1 + 1 , Dash2 - Dash1 - 1)
	Days:String = Right(Date , Len(Date) - Dash2)
	
	Return OutputLocalFormat(Days,Month,Year)
End Function

Function OutputCorrectWriteFormat:String(Days:Int , Month:Int , Year:Int)
	Local DayString:String
	Local MonthString:String
	Local YearString:String
	
	If Days < 10 Then 
		DayString = "0" + Days
	Else
		DayString = Days
	EndIf
	If Month < 10 Then 
		MonthString = "0" + Month
	Else
		MonthString = Month
	EndIf	
	YearString = String(Year)
	PrintF("Output: "+YearString+"/"+MonthString+"/"+DayString)
	Return YearString+"/"+MonthString+"/"+DayString
End Function

Function ValidateDate:Int(GDays:String , GMonth:String , GYear:String)
	PrintF("Validating...")
	If Len(GDays) > 2 Or Len(GMonth) > 2 Or Len(GYear) > 4 Then
		InvalidDate = True
		PrintF("Invalid: Length")
	EndIf
	If Int(GDays) > 0 And Int(GDays) < 32 Then
	
	Else
		InvalidDate = True
		PrintF("Invalid: Days")
	EndIf
	If Int(GMonth) > 0 And Int(GMonth) < 13 Then
	
	Else
		InvalidDate = True
		PrintF("Invalid: Month")
	EndIf		
	If Int(GYear) > 1000 And Int(GYear) < Int(Right(CurrentDate(),4))+1 Then
	
	Else
		InvalidDate = True
		PrintF("Invalid: Year")
	EndIf		
	If Len(GDays) = Len(String(Int(GDays) ) ) Then
	
	Else
		If Left(GDays , 1) = "0" Then
		
		Else
			InvalidDate = True
			PrintF("Invalid: day zeros")
		EndIf
	EndIf
	If Len(GMonth) = Len(String(Int(GMonth) ) ) Then
	
	Else
		If Left(GMonth , 1) = "0" Then
			
		Else			
			InvalidDate = True
			PrintF("Invalid: month zeros")
		EndIf
	EndIf
	If Len(GYear) = Len(String(Int(GYear) ) ) Then
	
	Else
		InvalidDate = True
		PrintF("Invalid: Year Text")
	EndIf		
	If InvalidDate = True Then
		Return False
	Else
		PrintF("Valid Date")
		Return True
	EndIf
End Function

Function GetDateFromLocalFormat:String(Date:String , OverrideCountry:String = Null)
	If OverrideCountry = "UK" Or OverrideCountry = "US" Or OverrideCountry = "EU" then
	
	else
		OverrideCountry = Country
	endif
	PrintF("GetDateFromLocalFormat")
	Local Dash1 = - 1
	Local Dash2 = - 1
	Local Days:String , Month:String, Year:String
	For a = 1 To Len(Date)
		If Mid(Date , a , 1) = "/" Then
			If Dash1 = -1 Then
				Dash1 = a
			ElseIf Dash2 = - 1 Then
				Dash2 = a
			Else
				'Bad Date
			EndIf	
		EndIf
	Next

	Data1:String = Left(Date , Dash1 - 1)
	Data2:String = Mid(Date , Dash1 + 1 , Dash2 - Dash1 - 1)
	Data3:String = Right(Date , Len(Date) - Dash2)
	
		
	Select OverrideCountry
		Case "UK"
			Days = Data1
			Month = Data2
			Year = Data3
		Case "US"
			Month = Data1
			Days = Data2
			Year = Data3
		Case "EU"
			Year = Data1
			Month = Data2
			Days = Data3
		Default
			CustomRuntimeError("Error 28: Invalid Country") 'MARK: Error 28
	End Select
	
	If ValidateDate(Days , Month , Year) = 0 Then
		Return "-1"
	Else
		Return OutputCorrectWriteFormat(Int(Days) , Int(Month) , Int(Year))
	EndIf
	
End Function

Function OutputLocalFormat:String(Days:String , Month:String , Year:String)
	If ValidateDate(Days , Month , Year) = 0 Then
		PrintF("Output: blank (Invalid Date)")
		Return ""
	EndIf
	Select Country
		Case "UK"
			PrintF("Output: "+Days + "/" + Month + "/" + Year)
			Return Days + "/" + Month + "/" + Year
		Case "US"
			PrintF("Output: "+Month + "/" + Days + "/" + Year)
			Return Month + "/" + Days + "/" + Year
		Case "EU"
			PrintF("Output: "+Year + "/" + Month + "/" + Days)
			Return Year + "/" + Month + "/" + Days
		Default
			CustomRuntimeError("Error 27: Invalid Country") 'MARK: Error 27
	End Select
End Function

