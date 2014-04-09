

Type PhotonTray Extends wxApp
	Field TaskBarIcon:MyTaskBarIcon
	
	Method OnInit:Int()
		wxImage.AddHandler( New wxICOHandler)	
		TaskBarIcon = MyTaskBarIcon(New MyTaskBarIcon.Create())
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON3,wxBITMAP_TYPE_ICO)
		TaskBarIcon.SetIcon(Icon,"Photon GameManager")
		Return True
	End Method
	
End Type

Type MyTaskBarIcon Extends wxTaskBarIcon
	Method CreatePopupMenu:wxMenu()
		Local Menu:wxMenu = New wxMenu.Create()
		Menu.Append(PM_I1 , "PhotonExplorer")
		Menu.Append(PM_I2 , "PhotonFrontEnd")
		Menu.Append(PM_I3 , "PhotonManager")
		Menu.Append(PM_I4 , "PhotonUpdate")
		Menu.Append(PM_I5 , "Exit")
		Connect(PM_I1 , wxEVT_COMMAND_MENU_SELECTED , MenuFun , "1")
		Connect(PM_I2 , wxEVT_COMMAND_MENU_SELECTED , MenuFun , "2")
		Connect(PM_I3 , wxEVT_COMMAND_MENU_SELECTED , MenuFun , "3")
		Connect(PM_I4 , wxEVT_COMMAND_MENU_SELECTED , MenuFun , "4")
		Connect(PM_I5 , wxEVT_COMMAND_MENU_SELECTED , MenuFun , "5")
		Return Menu
	End Method	
	
	Function MenuFun(event:wxEvent)
		MyTaskBar:MyTaskBarIcon = MyTaskBarIcon(event.parent)
		Local data:Object = event.userData
		Select String(data)
			Case "1"
				PrintF(EXPLORERPROGRAM)
				RunProcess(EXPLORERPROGRAM,1)
			Case "2"
				PrintF(FRONTENDPROGRAM)
				RunProcess(FRONTENDPROGRAM,1)
			Case "3"
				PrintF(MANAGERPROGRAM)
				RunProcess(MANAGERPROGRAM,1)
			Case "4"
				PrintF(UPDATEPROGRAM)
				RunProcess(UPDATEPROGRAM,1)
			Case "5"
				MyTaskBar.RemoveIcon()
				MyTaskBar.Free()
				End 
			Default
				CustomRuntimeError( "Error 301: Invalid Menu Item") 'MARK: Error 301
				 'MARK: Error 301
		End Select

	End Function
End Type 