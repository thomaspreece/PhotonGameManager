Camstudio 4 Xnote
=================

This application requires microsoft foundation dll's
If these are not available on your system application shall not run.

Debug version:
 * mfc90d.dll
 * msvcp90d.dll
 * msvcr90d.dll

Release version:
 * mfc90.dll
 * msvcp90.dll
 * msvcr90.dll

Therefore we bundled this release with the required additional dll's.

This build is created using SourceForge Camstudio v2.6 r242 and we applied a few small addon's to be able to use Xnote as trigger system.

Usage:
1) Open Xnote version that broadcast Xnote Windows message (special edition from Xnote)

2) Open Camstudio4 Xnote.
-- Define an area that should be recorded

3) Start Xnote with button or Device connected to RS232 port.
-- Camstudi4Xnote will compensate the delay caused by the recording with 175 milli second. Delayed time is printed in the capture in the Bottom-Left corner.


Updates:

Camstudio v2.6, release 248:
------------------------------
Add Xnote time stamp option to effects. 
This option adds a delayed stopwatch in the capture.
Recordings will shows a stopwatch annotation (in milli seconds). To get displayed stopwatch  time in sync with the image from the camera user can define number of milli seconds that camera is behind real events. 
Although captured time for events as reported by Xnote stopwatch is accurate a small shift due to inaccuracy in estimated delay is always applicable. 
For average user this will be not an mayor issue.

Camstudio recording can be set on pause. If Xnote snap event occurs recording will continue automatically.


Camstudio v2.6, release 250:
------------------------------
Camstudio will show snap times and running time if Xnote timestamp annotation is applicable.

BTW.
Current delaytime can be changed by the user.
With this release we have a small problem with storage of defined Xnote-Timestamp settings.
You can change settings but although saved we have a problem reloaded previously setting.


Camstudio v2.6, release 253:
------------------------------
Add function that will manage if and how long recording will continue if this recording is activated by a Xnote stopwatch event. Changed Effects options dialog to be able to manage the duration of the recording if recording is triggered by means of xnote stopwatch.
Extended menubar with an option to switch recording duration limit on/off during recording. (But if set as options effect this overwite function is only applicable for the recording initiated by the last xnote message. Hence any new event will reset recording duration to inititial settings)
Use Xnote param now to set xnote timestamps. (before Camstudio used the timestamp when the xnote message was coming through)
Changed procedure that drops annotation in the screen capture.
Removed a few warnings as well.

Camstudio v2.6, release 255:
------------------------------
Xnote Camstudio settings are now pushed and pulled to Camstudio.ini file.
Each recording start with an unique named filename that gets a tag that identify when recording is started. Same ccyymmdd-hhmm-ss tag is used to brand the final file if autonaming is applicable.
Changed informational interface when recording. You can see now to which file is used for recording and it also shows info if limited recording is applicable or not.
Use the snaptime send by Xnote now also in Camstudio4Xnote.

Camstudio v2.6, release 258:
------------------------------
Camstudio4Xnoteis prepared to work together with an image motion detector which will start recording if Camstudio is in pause mode. 
Camstudio4Xnoteis now prepared to recognize how recording is started and if this is done manual or automated with a start or finish device, a reporting camera or by hand.

Camstudio v2.6, release 260:
------------------------------
Camstudio4Xnote now writes snaps to a XML formatted logfile.  (tagged .xnote.txt)
Frame refs related with the Xnote snap will be added soon.

BTW. 
The current release of Xnote on www.xnotestopwatch.com is still updated for Camstudio4Xnote but it does not send the Reset message. (I assume that this will be solved as soon as Dmitry returns from holliday). If all works but Camstudio4Xnote does not finalize recording when you use Xnote reset you must use xnsw_1.6.plus-(Camstudio special-05jun20100).exe.
Install XnoteStopwatch and copy xnsw_1.6.plus-(Camstudio special-05jun20100).exe to the XnoteStopwatch directory.  Start xnsw_1.6.plus-(Camstudio special-05jun20100).exe instead of xnsw.exe.

Camstudio v2.6, release 264:
------------------------------
Last release of Xnote (dd July 2010) is ok.
Applied some extra checks to minimize the effects of Xnote in regular CamStudio windows.
Add functionality that demand that Xnote should enabled first. 
If Xnote not enabled the user nearly sees anything of Xnote. (regular Camstudio version)
In the Camstudio4Xnote all relevant Xnote settings are showed to the user.
Changed about box on request of Mick. There is now a link to the Camstudie4Xnote website.

Camstudio v2.6, release 269:
------------------------------
Add manifest files to prevent Microsoft 'Side by side' errors during first usage.
Mostly this can be solved with installing the  "MIcrosoft Visual C++ 2008 Redistriutable package for 32 bits" 
Reports showed that not all issies are solved.
(To be continued.)

Camstudio v2.6, release 270:
------------------------------
Fixed how Camstudio treated 'TimeDelayInMilliSecs'. An postive value now ,means that time is added instead of subtracted.

Camstudio v2.6, release 273:
------------------------------
Fixed a memoryleak that caused Camstudio crashed after 40-50 minutes of recording.
Redesigned the region calculation routines. 
* The same procedure is now applicable for all sizing calculations.
* The area you define in regions is the area that will be recorded. No shift in position or losing rows or columns.
* Size of the region is now displayed correctly in the progress monitoring window.
* Size of the recording is now equal to the size as displayed the progress monitoring window.

Camstudio v2.6, release 294:
------------------------------
Huge step in release number sequence. Caused because many new nice features can be expected soon. 
Nice things like zooming, showing key combinations pressed and/or left,middle and right mouse identification on screen.
This release contains only a few small fixes.
* Region 'Window' and  'Select Screen' in case of multiple screens now calculate the pixels correct either.
* Temporally and final files are now created in the directory you have specified in "Directory for recording"
* Log file ....xnote.txt is renamed to ....txt and shows now besides xnote information also the version and release number of the executable.
* Inside the code 'Playerplus.exe' is now invoked instead of 'Playplus.exe'. So it will startup.
(My personal opinion; Don't use it at all. On can better use player.exe or use local player.)



References:
------------------------------
www.camstudio.org
www.xnotestopwatch.com
www.jahoma.nl/timereg


JanHgm
jan [AT] jahoma [dot] nl