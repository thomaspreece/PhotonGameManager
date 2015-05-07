START "mt" /B /WAIT "mt.exe" -manifest "C:\GameManagerV4\manifest.txt" -outputresource:"C:\GameManagerV4\PhotonManager.exe";#1
START "mt" /B /WAIT "mt.exe" -manifest "C:\GameManagerV4\manifest.txt" -outputresource:"C:\GameManagerV4\PhotonUpdater.exe";#1
START "mt" /B /WAIT "mt.exe" -manifest "C:\GameManagerV4\manifest.txt" -outputresource:"C:\GameManagerV4\PhotonDownloader.exe";#1
START "mt" /B /WAIT "C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin\mt.exe" -manifest "F:\GameManagerV4\manifest.txt" -outputresource:"F:\GameManagerV4\PhotonFrontend.exe";#1