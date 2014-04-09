ModuleInfo "Version: 1.03"
ModuleInfo "Framework: FreeProcess multi platform external process control"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "Modserver: BRL"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Changed fork() to vfork() and exit() to _exit() to fix more hangs."
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Fixed a Linux hang when fork() is called."
ModuleInfo "History: Added SIGCHLD handling and fdReapZombies function."
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Inserts /Contents/MacOS/ into process path for Apple app packages"
import brl.blitz
import brl.stream
import brl.linkedlist
import brl.filesystem
fdClose%(fd%)="fdClose"
fdRead%(fd%,buffer@*,count%)="fdRead"
fdWrite%(fd%,buffer@*,count%)="fdWrite"
fdFlush%(fd%)="fdFlush"
fdAvail%(fd%)="fdAvail"
fdProcess%(exe$,in_fd%*,out_fd%*,err_fd%*,flags%)="fdProcess"
fdProcessStatus%(processhandle%)="fdProcessStatus"
fdTerminateProcess%(processhandle%)="fdTerminateProcess"
HIDECONSOLE%=1
TPipeStream^TStream{
.readbuffer@&[]&
.bufferpos%&
.readhandle%&
.writehandle%&
-New%()="_pub_freeprocess_TPipeStream_New"
-Close%()="_pub_freeprocess_TPipeStream_Close"
-Read%(buf@*,count%)="_pub_freeprocess_TPipeStream_Read"
-Write%(buf@*,count%)="_pub_freeprocess_TPipeStream_Write"
-Flush%()="_pub_freeprocess_TPipeStream_Flush"
-ReadAvail%()="_pub_freeprocess_TPipeStream_ReadAvail"
-ReadPipe@&[]()="_pub_freeprocess_TPipeStream_ReadPipe"
-ReadLine$()="_pub_freeprocess_TPipeStream_ReadLine"
+Create:TPipeStream(in%,out%)="_pub_freeprocess_TPipeStream_Create"
}="pub_freeprocess_TPipeStream"
TProcess^Object{
ProcessList:TList&=mem:p("_pub_freeprocess_TProcess_ProcessList")
.name$&
.handle%&
.pipe:TPipeStream&
.err:TPipeStream&
.detached%&
-New%()="_pub_freeprocess_TProcess_New"
-Detach%()="_pub_freeprocess_TProcess_Detach"
-Attach%()="_pub_freeprocess_TProcess_Attach"
-Status%()="_pub_freeprocess_TProcess_Status"
-Close%()="_pub_freeprocess_TProcess_Close"
-Terminate%()="_pub_freeprocess_TProcess_Terminate"
+Create:TProcess(name$,flags%)="_pub_freeprocess_TProcess_Create"
+FlushZombies%()="_pub_freeprocess_TProcess_FlushZombies"
+TerminateAll%()="_pub_freeprocess_TProcess_TerminateAll"
}="pub_freeprocess_TProcess"
CreateProcess:TProcess(cmd$,flags%=0)="pub_freeprocess_CreateProcess"
ProcessStatus%(process:TProcess)="pub_freeprocess_ProcessStatus"
ProcessDetach%(process:TProcess)="pub_freeprocess_ProcessDetach"
ProcessAttach%(process:TProcess)="pub_freeprocess_ProcessAttach"
TerminateProcess%(process:TProcess)="pub_freeprocess_TerminateProcess"
