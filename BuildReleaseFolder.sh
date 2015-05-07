#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Program handles building of Photon"
	echo "Takes one arguments: BuildReleaseFolder.sh [1|2|3]"
	echo "Argument 1:"
	echo "1 - Windows, 2 - Mac, 3 - Linux"
	exit 0
fi

if [ $1 -eq 1 ]; then
	platform="Windows"
elif [ $1 -eq 2 ]; then
	platform="MacOSX"
elif [ $1 -eq 3 ]; then
	platform="Linux"
else
	echo "Invalid first argument. Run BuildReleaseFolder.sh to see argument descriptions."
	exit 0
fi

if [ $platform != "Windows" ]; then
	echo "Not supported yet"
	exit 0
fi


case $platform in
"Windows")
	#Make release platform folder if not already existing
	if [ ! -d Releases/$platform ]; then
		echo "Making Releases/Windows"
		mkdir Releases/$platform
	fi


	#Make Plugins Folder if not already existing
	if [ ! -d Releases/$platform/Lua ]; then
		echo "Making Releases/Windows/Lua"
		mkdir Releases/$platform/Lua
	fi	

	#Copy Lua
	echo "Copying Lua"
	cp -v -u -r Code/Lua/* Releases/$platform/Lua
	
	
	#Make Mounters Folder if not already existing
	if [ ! -d Releases/$platform/Mounters ]; then
		echo "Making Releases/Windows/Mounters"
		mkdir Releases/$platform/Mounters
	fi	

	#Copy Mounters
	echo "Copying Mounters"
	cp -v -u Mounters/* Releases/$platform/Mounters
	
	#Make Plugins Folder if not already existing
	if [ ! -d Releases/$platform/Plugins ]; then
		echo "Making Releases/Windows/Plugins"
		mkdir Releases/$platform/Plugins
	fi	

	#Copy Plugins
	echo "Copying Plugins"
	cp -v -u -r Plugins/* Releases/$platform/Plugins	
	
	#Make Resources Folder if not already existing
	if [ ! -d Releases/$platform/Resources ]; then
		echo "Making Releases/Windows/Resources"
		mkdir Releases/$platform/Resources
	fi		
	
	echo "Copying Resources"
	#Copy Icons
	cp -v -u Icons/*.ico Releases/$platform/Resources
	
	#Copy Resources
	cp -v -u -r Resources/* Releases/$platform/Resources
	
	#Copy Version
	cp -v -u Other/General/Version.txt Releases/$platform/
	
	#Copy Licence
	cp -v -u InstallationFiles/Licence.txt Releases/$platform/
	
	echo "Copying Win32 Dependencies"
	#Copy Win32 Files
	cp -v -u Other/Win32/* Releases/$platform/
	
	echo "Finished"
	;;
"Mac")
	echo "Error"
	;;
"Linux")
	echo "Error"
	;;
esac 
