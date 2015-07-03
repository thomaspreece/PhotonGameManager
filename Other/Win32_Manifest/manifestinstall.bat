set "ManifestLocation=Z:\gameManager\GameManagerV4\Other\Win32 Manifest\manifest.txt"
set "ManifestFolder=Z:\gameManager\GameManagerV4\Releases\Windows\"
START "mt" /B /WAIT "mt.exe" -manifest "%ManifestLocation%" -outputresource:"%ManifestFolder%PhotonManager.exe";#1
START "mt" /B /WAIT "mt.exe" -manifest "%ManifestLocation%" -outputresource:"%ManifestFolder%PhotonUpdater.exe";#1
START "mt" /B /WAIT "mt.exe" -manifest "%ManifestLocation%" -outputresource:"%ManifestFolder%PhotonDownloader.exe";#1
START "mt" /B /WAIT "mt.exe" -manifest "%ManifestLocation%" -outputresource:"%ManifestFolder%PhotonExplorer.exe";#1
START "mt" /B /WAIT "mt.exe" -manifest "%ManifestLocation%" -outputresource:"%ManifestFolder%PhotonFrontend.exe";#1
START "mt" /B /WAIT "mt.exe" -manifest "%ManifestLocation%" -outputresource:"%ManifestFolder%PhotonRunner.exe";#1