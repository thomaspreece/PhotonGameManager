file = ReadFile("C:\Users\Tom\Documents\GameManagerV4\Settings\Platforms.txt")
Number = 0
Repeat
	Number = Number + 1
	Local line:String = ReadLine(file)
	If line="" Then Exit
	line = Replace(line,">","")
	Print "PlatformNode = RootNode.addTextChild("+Chr(34)+"Platform"+Chr(34)+" , Null , "+Chr(34)+Chr(34)+")"
	Print "PlatformNode.addTextChild("+Chr(34)+"ID"+Chr(34)+" , Null , "+Chr(34)+Number+Chr(34)+")"
	Print "PlatformNode.addTextChild("+Chr(34)+"Name"+Chr(34)+" , Null , "+Chr(34)+line+Chr(34)+")"
	Print "PlatformNode.addTextChild("+Chr(34)+"Type"+Chr(34)+" , Null , "+Chr(34)+"File"+Chr(34)+")"
	Print "PlatformNode.addTextChild("+Chr(34)+"Emulator"+Chr(34)+" , Null , "+Chr(34)+Chr(34)+")"
Forever

