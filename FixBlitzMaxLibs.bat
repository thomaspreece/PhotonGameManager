@echo off
@set dirMinGW=C:\BlitzMax\MinGW32
@set minGWVersionString=4.7.1
@set dirBlitzmax=C:\Blitzmax

copy %dirMinGW%\bin\ar.exe %dirBlitzmax%\bin /Y
copy %dirMinGW%\bin\ld.exe %dirBlitzmax%\bin /Y

for /f "delims=" %%i in ('dir %dirBlitzmax%\lib /b') do (
copy "%dirMinGW%\lib\%%i" "%dirBlitzmax%\lib\%%i" /z /y
copy "%dirMinGW%\lib\gcc\mingw32\%minGWVersionString%\%%i" "%dirBlitzmax%\lib\%%i" /z /y
)
