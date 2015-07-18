#!/bin/bash

BmaxBin="C:/BlitzMax/bin" 

function BuildWin(){
	echo ""
	echo ""
	echo --------Building $buildFile--------
	echo ""
	case $buildFile in
	"Download")
		$BmaxBin/bmk.exe makeapp $buildDebug $buildRun -t gui -o Releases/$platform/PhotonDownloader.exe Code/PhotonDownloader.bmx
		;;
	"Explorer")
		$BmaxBin/bmk.exe makeapp $buildDebug $buildRun -t gui -h -o Releases/$platform/PhotonExplorer.exe Code/PhotonExplorer.bmx 
		./Other/Win32_Manifest/mt -manifest "Other/Win32_Manifest/manifest.txt" -outputresource:"Releases/Windows/PhotonExplorer.exe"
		;;
	"Frontend")
		$BmaxBin/bmk.exe makeapp $buildDebug $buildRun -t gui -h -o Releases/$platform/PhotonFrontend.exe Code/PhotonFrontend.bmx 
		./Other/Win32_Manifest/mt -manifest "Other/Win32_Manifest/manifest.txt" -outputresource:"Releases/Windows/PhotonFrontend.exe"
		;;
	"Manager")
		$BmaxBin/bmk.exe makeapp $buildDebug $buildRun -t gui -h -o Releases/$platform/PhotonManager.exe Code/PhotonManager.bmx 
		./Other/Win32_Manifest/mt -manifest "Other/Win32_Manifest/manifest.txt" -outputresource:"Releases/Windows/PhotonManager.exe"
		;;
	"Updater")
		$BmaxBin/bmk.exe makeapp $buildDebug $buildRun -t gui -h -o Releases/$platform/PhotonUpdater.exe Code/PhotonUpdater.bmx
		./Other/Win32_Manifest/mt -manifest "Other/Win32_Manifest/manifest.txt" -outputresource:"Releases/Windows/PhotonUpdater.exe"		
		;;
	"Runner")
		$BmaxBin/bmk.exe makeapp $buildDebug $buildRun -t gui -h -o Releases/$platform/PhotonRunner.exe Code/PhotonRunner.bmx 
		./Other/Win32_Manifest/mt -manifest "Other/Win32_Manifest/manifest.txt" -outputresource:"Releases/Windows/PhotonRunner.exe"
		;;		
	*)
		echo "Invalid forth argument. Run BuildExecutable.sh to see argument descriptions."
		exit 1
		;;
	esac
}

if [ $# -ne 4 ]; then
	echo "Program handles building of Photon Executables"
	echo "Takes two arguments: BuildExecutable.sh [1|2|3] [0|1] [0|1] [Download|Explorer|Frontend|Manager|Updater|all]"
	echo "Argument 1:"
	echo "1 - Windows, 2 - Mac, 3 - Linux"
	echo "Argument 2:"
	echo "Debug Build? 0: No, 1: Yes"
	echo "Argument 3:"
	echo "Run Build? 0: No, 1: Yes"
	echo "Argument 3:"
	echo "File to build or 'all' to build all"	
	exit 0
fi


if [ $1 -eq 1 ]; then
	platform="Windows"
elif [ $1 -eq 2 ]; then
	platform="MacOSX"
elif [ $1 -eq 3 ]; then
	platform="Linux"
else
	echo "Invalid first argument. Run BuildExecutable.sh to see argument descriptions."
	exit 1
fi

if [ $2 -eq 0 ]; then 
	buildDebug="-r"
elif [ $2 -eq 1 ]; then
	buildDebug="-d"
else
	echo "Invalid second argument. Run BuildExecutable.sh to see argument descriptions."
	exit 1
fi

if [ $3 -eq 0 ]; then 
	buildRun=""
elif [ $3 -eq 1 ]; then
	buildRun="-x"
else
	echo "Invalid third argument. Run BuildExecutable.sh to see argument descriptions."
	exit 1
fi

buildFile=$4

if [ $platform != "Windows" ]; then
	echo "Not supported yet"
	exit 1
fi


case $platform in
"Windows")
	if [ ! -d Releases/$platform ]; then
		echo "Making Releases/Windows"
		mkdir Releases/$platform
	fi

	if [ $buildFile == "all" ]; then
		buildRun=""
		
		./Icons/GenerateFiles.exe

		buildFile="Explorer"
		BuildWin
		buildFile="Frontend"
		BuildWin
		buildFile="Manager"
		BuildWin
		buildFile="Updater"
		BuildWin		
		buildFile="Runner"
		BuildWin	
	else
		BuildWin
	fi
	;;
*)
	echo "Error"
	exit 1
	;;
esac
