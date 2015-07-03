
Type SplashFrame Extends wxFrame
	Method OnInit()
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local Splash:SplashPanel = SplashPanel(New SplashPanel.Create(Self, wxID_ANY) )
		Splash.SetImage(RESFOLDER + "Splash.png")
		hbox.Add(Splash, 1, wxEXPAND, 0)
		Self.SetSizer(hbox)	
		
		Self.CreateStatusBar(1)
		Self.SetStatusText("Starting...")		
		Self.Center()
		Self.Show(1)
		
	End Method
	
End Type



Type SplashPanel Extends wxPanel
	Field ImageURL:String = ""

	Method OnInit()
		ConnectAny(wxEVT_PAINT , OnPaint)
	End Method
	
	Method SetImage(Path:String)
		Self.ImageURL = Path
	End Method
	
	Function OnPaint(event:wxEvent)
		Local canvas:SplashPanel = SplashPanel(event.parent)
		
		canvas.Refresh()
		
		Local dc:wxPaintDC = New wxPaintDC.Create(canvas)
		canvas.PrepareDC(dc)
		Local x:Int, x2:Int, x3:Int
		Local y:Int , y2:Int , y3:Int
		Local HWratio:Float
		Local WHratio:Float
		dc.Clear()
		canvas.GetClientSize(x, y)
		Local NoLen:Int, ArtworkLen:Int, FoundLen:Int
		
		Local ImageImg:wxImage
		Local ImageBit:wxBitmap
		Local ImagePix:TPixmap
		Local BlackBit:wxBitmap
		Local Drawx:Int
		Local Drawy:Int
		

		ImagePix = LoadPixmap(canvas.ImageURL)
		ImagePix = MaskPixmap(ImagePix , - 1 , - 1 , - 1)
		If ImagePix = Null then
			CustomRuntimeError("Slash Image Missing(" + canvas.ImageURL + "). Please Reinstall Photon")
		EndIf
		x3 = PixmapWidth(ImagePix)
		y3 = PixmapHeight(ImagePix)		
		
		HWratio = Float(y3) / x3
		WHratio = Float(x3) / y3
		
		If HWratio * x < y then
			ImagePix = ResizePixmap(ImagePix , x , HWratio * x)	
			BlackBit = New wxBitmap.CreateEmpty(x , HWratio * x)
			BlackBit.Colourize(New wxColour.Create(0 , 0 , 0) )
			Drawx = 0
			Drawy = (y - (HWratio * x) ) / 2
		Else
			ImagePix = ResizePixmap(ImagePix , WHratio * y , y)	
			BlackBit = New wxBitmap.CreateEmpty(WHratio * y , y)
			BlackBit.Colourize(New wxColour.Create(0 , 0 , 0) )	
			Drawx = (x - (WHratio * y) ) / 2
			Drawy = 0
		EndIf		
		
		ImageBit = New wxBitmap.CreateBitmapFromPixmap(ImagePix)
		ImageBit.SetMask(New wxMask.Create(BlackBit, New wxColour.Create(255, 255, 255, 255) ) )
		dc.DrawBitmap(BlackBit , Drawx , Drawy , False)
		

		
		dc.DrawBitmap(ImageBit, Drawx, Drawy, False)		

		dc.Free()
	End Function
	
End Type
