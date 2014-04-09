
Detach = 1


Command:String=Chr(34)+"/Volumes/VMware Shared Folders/GameManagerV4/testmacprocess2.app/Contents/MacOS/testmacprocess2"+Chr(34)+" "+"mode-end "+" exe poo "+Chr(34)+"cool party bro"+Chr(34)


Local Process:TProcess = CreateProcess(Command)
If Process=Null Then
	Print("Invalid Command: "+Command)
Else
	Print ProcessStatus(Process)'If Detach = 1 Then ProcessDetach(Process)
EndIf 


Delay 2000
Print ProcessStatus(Process)

WaitKey()
