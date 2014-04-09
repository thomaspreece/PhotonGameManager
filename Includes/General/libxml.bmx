Rem
Global CurrentSearchLine:String 
Gamedoc:TxmlDoc = TxmlDoc.parseFile("Z:\GameManagerV4\Games\alien swarm---pc\info.xml")
RootNode:TxmlNode = Gamedoc.getRootElement()
Local Node:TxmlNode
'Print RootNode.getName()
Local ChildrenList:TList = RootNode.getChildren()
'For node = EachIn ChildrenList
'	Print node.getText()
'Next
'Gamedoc.saveFormatFile("h",False)
endrem

Type TxmlDoc
	Field RootNode:TxmlNode 
	
	Function parseFile:TxmlDoc(File:String)
		Local Doc:TxmlDoc = New TxmlDoc 
		Local ReadXml = ReadFile(File)
		Repeat
			CurrentSearchLine=CurrentSearchLine+ReadLine(ReadXml)
			If Eof(ReadXml) Then Exit
		Forever
		CloseFile(ReadXml)	
		
		Local TopTag:String = TxmlDoc.ReturnTagInfo(CurrentSearchLine , "<?" , "?>")
		If Left(TopTag , Len("xml") ) <> "xml" Then
			PrintF("Invalid TogTag")
			Return Null 
		EndIf
		
		Doc.RootNode = TxmlNode.parseXML(CurrentSearchLine)
		
		Return Doc
	End Function
	
	Method saveFormatFile:Int(FilePath:String , UnUsed:Int)
		Line:String = ""
		Line = "<?xml version="+Chr(34)+"1.0"+Chr(34)+"?>" + Self.RootNode.Save(Line)
		WriteXML = WriteFile(FilePath)
		WriteLine(WriteXML,Line)
		CloseFile(WriteXML)
	End Method
	
	Method getRootElement:TxmlNode()
		Return Self.RootNode
	End Method
	
	Method free()
		
	End Method
	
	Function ReturnTagInfo$(SearchLine$,Tag$,EndTag$,Debug=False)
		Rem
		Function:	Finds first instance of Tag and EndTag in SearchLine and returns the characters inbetween
				Sets CurrentSearchLine to the rest of SearchLine(Bit not containing Tag/EndTag)
		Input:	SearchLine - The String to search within
				Tag - The start term
				EndTag - The end term
		Return:	The string containing the characters between tags
		SubCalls:	None
		EndRem
		If Debug Then
			Print SearchLine
			Print Tag
			Print EndTag
		EndIf
		StartPos=0
		EndPos=0
		Found=False
		For a=1 To Len(SearchLine)
			If Mid(SearchLine,a,Len(Tag))=Tag$ Then
				StartPos=a+Len(Tag)
				If Debug Then Print StartPos
				Found=True
				Exit
			EndIf
		Next
		If Found=True Then
			For a=0 To Len(SearchLine)-StartPos
				If Mid(SearchLine,a+StartPos,Len(EndTag))=EndTag$ Then
					EndPos=a+StartPos
					If Debug Then Print EndPos
					CurrentSearchLine=Right(SearchLine,Len(SearchLine)-EndPos - Len(EndTag) + 1)
					Exit			
				EndIf
			Next	
		EndIf
		Return Mid(SearchLine,StartPos,EndPos-StartPos)
	End Function
	
End Type

Type TxmlNode
	Field Name:String
	Field Text:String
	Field Attributes:String
	Field Children:TList = CreateList()
	
	Method Save:String(Line:String)
		Local Node:TxmlNode
		If Self.Attributes="" Then 
		'	Print "<" + Self.Name + ">"
			Line = Line + "<" + Self.Name + ">"
		else
		'	Print "<" + Self.Name + " " + Self.Attributes + ">"
			Line = Line + "<" + Self.Name + " " + Self.Attributes + ">"
		EndIf 
		'Print Self.Text
		Line = Line + Self.Text
		
		For Node = EachIn Self.Children
			Line = Node.Save(Line)
		Next
		'Print "</" + Self.Name + ">"
		Line = Line + "</" + Self.Name + ">"
		Return Line
	End Method 
	
	Method getName:String()
		Return Self.Name
	End Method
	
	Method getText:String()
		Return Self.Text
	End Method
	
	Method setContent(Value:String)
		Self.Text = Value
	End Method
	
	Method addAttribute(ID:String , Value:String )
		Local temp:String
		temp = Self.getAttribute(ID)
		If temp <> "" Then
			Replace(Self.Attributes , ID + "=" + Chr(34) + temp + Chr(34) , ID + "=" + Chr(34) + Value + Chr(34) )
		Else
			Self.Attributes = Self.Attributes + " "+ID+"="+Chr(34)+Value+Chr(34)
		EndIf 
	End Method 
	
	Method getAttribute:String(att:String)
		Local temp:String
		For a = 1 To Len(Self.Attributes)
			If Mid(Self.Attributes , a , Len(att + "=") ) = att + "=" Then
				temp = Right(Self.Attributes , Len(Self.Attributes) - a)
				Exit 
			EndIf
		Next
		Return ReturnTagInfo(temp,Chr(34),Chr(34))
	End Method
	
	Method getChildren:TList()
		Return Self.Children
	End Method
	
	Method addTextChild:TxmlNode(ID:String , UnUsed:String , Value:String)
		Local Child:TxmlNode = New TxmlNode
		Child.Name = ID
		Child.Text = Value
		ListAddLast(Self.Children , Child)
		Return Child
	End Method 
	
	Function parseXML:TxmlNode(Text:String)
	
		Local a:Int 
		Local Node:TxmlNode = New TxmlNode
		Local temp:String
		Local ChildNode:TxmlNode
		Local Start:Int = - 1 , Finish:Int = - 1
		
		For a = 1 To Len(Text)
			If Start = -1 Then 
				If Mid(Text , a , 1) = "<" Then
					Start = a + 1
				EndIf
			Else
				If Mid(Text , a , 1) = ">" Then
					Finish = a
					Exit 
				EndIf 
			EndIf 
		Next
		temp = Mid(Text , Start , Finish - Start)
		For a = 1 To Len(temp)
			If Mid(temp , a , 1) = " " Then
				Node.Name = Left(temp , a - 1)
				Node.Attributes = Right(temp , Len(temp) - a)
				Exit 
			EndIf 
		Next
		If a => Len(temp) Then
			Node.Name = temp
			Node.Attributes = ""
		EndIf
		CurrentSearchLine = TxmlNode.ReturnTagInfo(Text , "<" + temp + ">" , "</" + Node.Name + ">" )
		For a = 1 To Len(CurrentSearchLine)
			If Mid(CurrentSearchLine , a , 1) = "<" Then
				Node.Text = Left(CurrentSearchLine , a - 1)
				Exit
			EndIf
		Next
		If a => Len(CurrentSearchLine) Then
			Node.Text = CurrentSearchLine
		EndIf 
		
		Local TagName:String , StartTag:String 
		Local ChildNodeXML:String
		Local tempCurrentSearchLine:String
		
		Repeat
			Start = - 1
			Finish = -1
			For a = 1 To Len(CurrentSearchLine)
				If Start = -1 Then 
					If Mid(CurrentSearchLine , a , 1) = "<" Then
						Start = a + 1
					EndIf
				Else
					If Mid(CurrentSearchLine , a , 1) = ">" Then
						Finish = a
						Exit 
					EndIf 
				EndIf 
			Next
			If Start = - 1 Or Finish = - 1 Then Exit
			
			StartTag = Mid(CurrentSearchLine , Start , Finish - Start)
			If Right(StartTag,1) <> "/" Then 
				For a = 1 To Len(StartTag)
					If Mid(StartTag , a , 1) = " " Then
						TagName = Left(StartTag , a - 1)
						Exit 
					EndIf 
				Next
				If a => Len(StartTag) Then
					TagName = StartTag
				EndIf		
				
				'Print TagName
				'Print StartTag
				'Print TagName
				ChildNodeXML = TxmlNode.ReturnTagInfo(CurrentSearchLine , "<" + StartTag + ">" , "</" + TagName + ">")
				ChildNodeXML = "<"+StartTag+">"+ChildNodeXML+"</"+TagName+">"
				tempCurrentSearchLine = CurrentSearchLine
				ChildNode = TxmlNode.parseXML(ChildNodeXML)
				CurrentSearchLine = tempCurrentSearchLine
				ListAddLast(Node.Children,ChildNode)
			Else
				tempCurrentSearchLine = CurrentSearchLine
				ChildNode = TxmlNode.parseXML("<" + Left(StartTag , Len(StartTag) - 1) + "></" + Left(StartTag , Len(StartTag) - 1) + ">" )	
				ListAddLast(Node.Children,ChildNode)
				CurrentSearchLine = tempCurrentSearchLine
				CurrentSearchLine = Right(CurrentSearchLine , Len(CurrentSearchLine) - Len(StartTag) - 2 )
			EndIf 
		Forever

		Return Node
	End Function	

	
	Function ReturnTagInfo$(SearchLine$,Tag$,EndTag$,Debug=False)
		Rem
		Function:	Finds first instance of Tag and EndTag in SearchLine and returns the characters inbetween
				Sets CurrentSearchLine to the rest of SearchLine(Bit not containing Tag/EndTag)
		Input:	SearchLine - The String to search within
				Tag - The start term
				EndTag - The end term
		Return:	The string containing the characters between tags
		SubCalls:	None
		EndRem
		If Debug Then
			Print SearchLine
			Print Tag
			Print EndTag
		EndIf
		StartPos=0
		EndPos=0
		Found=False
		For a=1 To Len(SearchLine)
			If Mid(SearchLine,a,Len(Tag))=Tag$ Then
				StartPos=a+Len(Tag)
				If Debug Then Print StartPos
				Found=True
				Exit
			EndIf
		Next
		If Found=True Then
			For a=0 To Len(SearchLine)-StartPos
				If Mid(SearchLine,a+StartPos,Len(EndTag))=EndTag$ Then
					EndPos=a+StartPos
					If Debug Then Print EndPos
					CurrentSearchLine=Right(SearchLine,Len(SearchLine)-EndPos - Len(EndTag) + 1)
					Exit			
				EndIf
			Next	
		EndIf
		Return Mid(SearchLine,StartPos,EndPos-StartPos)
	End Function	
End Type

Rem
Function PrintF(Tex:String)
	Print(Tex)
End Function
End Rem