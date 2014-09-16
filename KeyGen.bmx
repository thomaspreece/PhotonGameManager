Framework wx.wxApp
Import wx.wxFrame

Import wx.wxButton
Import wx.wxPanel
Import wx.wxStaticText
Import wx.wxTextCtrl

Import BRL.FileSystem
Import BRL.StandardIO
Import BRL.Retro
Import BRL.Blitz

Import Pub.Freeprocess

Local KeyGenApp:KeyGenShell
KeyGenApp = New KeyGenShell
KeyGenApp.Run()


Type KeyGenShell Extends wxApp 
	Field Menu:KeyGenFrame
	Method OnInit:Int()	
		Menu = KeyGenFrame(New KeyGenFrame.Create(Null , wxID_ANY, "KeyGen", -1, -1, 250, 300))
		Return True

	End Method
	
End Type

Type KeyGenFrame Extends wxFrame

	Field UsernameBox:wxTextCtrl
	Field KeyBox:wxTextCtrl 

	Method OnInit()

		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		Local MainPanel:wxPanel = New wxPanel.Create(Self , - 1)
		Local MainPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		
		
		MainPanel.setbackgroundColour(New wxColour.Create(255,255,255))
		
		Local UText:wxStaticText = New wxStaticText.Create(MainPanel , wxID_ANY , "UserName:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		UsernameBox = New wxTextCtrl.Create(MainPanel, wxID_ANY , "" , -1 , -1 , -1 , -1 , 0 )

		Local KText:wxStaticText = New wxStaticText.Create(MainPanel , wxID_ANY , "Key:" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		KeyBox = New wxTextCtrl.Create(MainPanel, wxID_ANY , "" , -1 , -1 , -1 , -1 , 0 )		
		
		Local GetKeyButton:wxButton = New wxButton.Create(MainPanel , 1 , "GetKey")		
		Local GetEmailButton:wxButton = New wxButton.Create(MainPanel , 2 , "GetEmail")		
				
		MainPanelvbox.Add(UText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )		
		MainPanelvbox.Add(UsernameBox , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )		
		MainPanelvbox.Add(KText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )		
		MainPanelvbox.Add(KeyBox , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )				
		MainPanelvbox.Add(GetKeyButton , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 10 )				
		MainPanelvbox.Add(GetEmailButton , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 10 )				
						
		MainPanel.SetSizer(MainPanelvbox)
		vbox.Add(MainPanel , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 0 )		
		Self.SetSizer(vbox)
		
		Self.show()	
		
		Connect(1 , wxEVT_COMMAND_BUTTON_CLICKED , GetKeyFun)
		Connect(2 , wxEVT_COMMAND_BUTTON_CLICKED , GetEmailFun)
			
	End Method
	
	Function GetKeyFun(event:wxEvent)
		Local KeyGenWindow:KeyGenFrame = KeyGenFrame(event.parent)
		If KeyGenWindow.UsernameBox.GetValue()="" Or KeyGenWindow.UsernameBox.GetValue()=" " Then
			Notify "Please Enter Key"
		Else
			KeyGenWindow.KeyBox.ChangeValue(keygen(KeyGenWindow.UsernameBox.GetValue()))
			WriteKey = WriteFile("C:\ProgramKey.txt")
			WriteLine(WriteKey,KeyGenWindow.UsernameBox.GetValue())
			WriteLine(WriteKey,keygen(KeyGenWindow.UsernameBox.GetValue()))			
			CloseFile(WriteKey)
		EndIf 
	End Function	

	Function GetEmailFun(event:wxEvent)
		Local KeyGenWindow:KeyGenFrame = KeyGenFrame(event.parent)
		Local Process:TProcess
		If KeyGenWindow.UsernameBox.GetValue()="" Or KeyGenWindow.UsernameBox.GetValue()=" " Then
			Notify "Please Enter Key"
		Else
			Local Username:String = KeyGenWindow.UsernameBox.GetValue()
			Local Key:String = keygen(KeyGenWindow.UsernameBox.GetValue())
			KeyGenWindow.KeyBox.ChangeValue(Key)
			WriteKey = WriteFile("C:\ProgramKey.txt")
			WriteLine(WriteKey,Username)
			WriteLine(WriteKey,Key)			
			CloseFile(WriteKey)
			
			Local Body:String = "body=Thank you for your purchase of Photon GameManager V4. You license key is below%2c please copy the attached file into the GameManager V4 folder to activate the program.%0d%0aUsername: " + Username + "%0d%0aKey: " + Key + "%0d%0a%0d%0aIf you have any problems or find any bugs please send an email to the below address or visit http://bugs.photongamemanager.com/" + "%0d%0aThanks%0d%0aPhoton GameManager Team%0d%0aCustomerSupport@photongamemanager.com"
			Body = Replace(Body, " ", "%20")
			Local Name:String = Chr(34) + "C:\Program Files (x86)\Mozilla Thunderbird\thunderbird.exe" + Chr(34) + " -compose " + Chr(34) + "to='"+Username+"',subject='GameManager V4 License Key',"+Body+",attachment='file:///C:/ProgramKey.txt'"+Chr(34)
			
			Process = CreateProcess(Name)
			'ProcessDetach(Process)
			
		EndIf 		
	End Function	
	
End Type 

'Print keygen("iamidea@yahoo.com")

Function keygen:String(name:String, v:String = "23456DDE7ES3428HG9ABCDEFGHHUEYSJKLM7J262KNPQRST8U4V3WXKAS2YZ")

'	change v$ to as many or few random or unrandom letters, numbers, characters whatever
'	this is what the key is going to be made out of
'	You can have duplicates all over the place if you want, it's up to you!
'	This is one part that will make your keys unique to other people using this program
'	e.g. v$="I1D9U0AJ5PFWIN1TR3EKLWZID42HU7KL8S6LTBN9VMCXOF6T46GY3JHIE9T7VTLFDEQ3Y38P"

	Local tname:String = name:String

'	make name longer if necessary
'	again adjust this to make your keys unique

	Local namel:Int = 20
	Local temp:String = ""
	Local n:Int 
	
	Repeat
		If Len(tname) <= namel
			temp = ""
			For n = 0 To Len(tname) - 1
				temp = temp + Chr(tname[n] + 1)
			Next
			tname = tname + temp
		EndIf
	Until Len(tname) > namel

	
'	this bit makes sure that you don't get any obvious repetitions over the 20 character key
	For n = 5 To 100 Step 5
		If Len(tname) = n Then tname = tname + "~~"
	Next

'	create encrypt string
	Local encrypt:String = ""
	For n = 0 To 19
		encrypt = encrypt + Chr(1)
	Next
	
	Local ee:Int
	Local nn:Int
'	over load encrypt 30 times
'	change this to make your keys unique further
	Local a:Int
	Local tl:Int
	For Local l:Int = 1 To 30
		For n = 0 To Len(tname) - 1
		
			a = tname[n]
			a = a - 32
			temp = ""

			For nn = 0 To 19
				tl = encrypt[nn]
				If nn = ee Then temp = temp + Chr(tl + a Mod 256)Else temp = temp + Chr(tl)
			Next
			encrypt = temp
			ee = ee + 1
			If ee = 19 Then ee = 0
			
		Next
	Next

'	suck out the key
	Local encrypted:String = ""
	Local e:Int
	For ee = 0 To 19
		e = encrypt[ee] Mod Len(v) - 1
		If e = -1 Then e = 0
		encrypted = encrypted + Chr(v[e])
	Next

'	format the key with -'s
	encrypted = encrypted[..5] + "-" + encrypted[5..10] + "-" + encrypted[10..15] + "-" + encrypted[15..20]

'	return the key
	Return encrypted

End Function
