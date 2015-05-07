@echo off
REM the line above turns off all the commands being printed to the commandline
REM PhotonExplorer has a problem being executed from PhotonRunner directly so this bat file is used as an intermediate instead
REM If you are worried about this file, either contact PhotonGameManager team for more info, or remove all the lines below (This will also stop Cabinate mode for PhotonExplorer)
REM the line below tells users that PhotonExplorer.exe is being executed
echo Running PhotonExplorer.exe
REM the line below is the easiest way to delay the execution of script by 3000 ms = 3 secs
@ping 1.1.1.100 -n 1 -w 3000 > nul
REM the line below starts PhotonExplorer
@Start PhotonExplorer.exe
