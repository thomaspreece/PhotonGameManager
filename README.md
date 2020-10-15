# Photon GameManager

## About

Photon is an advanced game launcher and the product of many years hard work by Thomas Preece. It focuses on making your game collection look amazing and is designed to automate the process of downloading game art, game info, official patches, cheats, manuals and walkthroughs. It also has many gaming related features to make your life easier and to get the most out of your games.

Photon has 3 main parts. The first is a advanced configuration app that manages your game collection and features automated game searching and automatic Steam and Game Explorer import functions. The second is an immersive full-screen interface that really makes your game collection look beautiful. The final part is a windowed interface that was designed as a replacement for Windows Games Explorer but ended up being vastly superior to Games Explorer and equally as stunning as the full-screen interface.

## Releases
The latest releases can be found on [photongamemanager.com](https://photongamemanager.com/).

## Building
BlitzMax is a pain in the backside to get compiled (particularly with all the modules which require specific versions of MinGW). I've provided instructions below for an old but mostly working setup, please be careful to follow the specific commit numbers, not doing so will almost certainly result in a broken install.

These instructions were tested with Windows 7 x64. Your mileage may vary on newer versions of Windows. Theoretically it should also compile on Linux but that hasn't been done for many years so is currently unknown. A warning before you start, getting setup will take a fair amount of time as a huge number of dependencies have to be compiled.

1. Download and install BlitzMax150_win32x86.exe from [here](https://nitrologic.itch.io/blitzmax)  to `C:\BlitzMax`
2. Download MinGW 4.7.1 from [here](https://sourceforge.net/projects/tdm-gcc/files/TDM-GCC%20Installer/Previous/1.1006.0/tdm-gcc-4.7.1-2.exe/download)
3. Install MinGW 4.7.1 to `C:\BlitzMax\MinGW32`
4. Setup Environment variables for BlitzMax. First go to: Control Panel -> System -> Advanced System Settings -> Environment Variables -> System Variables. Next Add/Update the following:
  - Create `MinGW` Variable and set to `C:\BlitzMax\MinGW32`
  - Create `BMK_LD_OPTS` Variable and set to `-lmsvcrt -lgcc`
  - Update `Path` variable and append `;C:\BlitzMax\MinGW32\bin`
5. Check the above variables are setup correctly by loading BlitzMax. Then going Help -> About MaxIDE. GCC Version should be 4.7.1 and the MinGW Path should be `C:\BlitzMax\MinGW32`.
6. Close BlitzMax and run the `FixBlitzMaxLibs.bat` file in this repo to fix the bundled BlitzMax libs and executables. (Thanks to Brucy for this file, see [here](https://mojolabs.nz/posts.php?topic=95220)). Note: If you have changed the install locations above, you'll need to change the bat file.
7. Clone [bmk](https://github.com/bmx-ng/bmk) to `C:\BlitzMax\bmk` and checkout commit **8e264b2d1266cd999c2f6ac74da362a7a458db46**. Open `C:\BlitzMax\bmk\bmk.bmx` in BlitzMax. Set the following Program->Build Options: Quick Build: OFF, Debug Build: OFF, Threaded Build: ON, Build GUI App: OFF. Now click build. Copy `bmk.mt.exe`, `make.bmk` and `core.bmk` from `C:\BlitzMax\bmk\` to `C:\BlitzMax\bin`. Rename `C:\BlitzMax\bin\bmk.exe` to `C:\BlitzMax\bin\bmk_old.exe` and then rename `C:\BlitzMax\bin\bmk.mt.exe` to `C:\BlitzMax\bin\bmk.exe`.
8. Clone [bah.mod](https://github.com/maxmods/bah.mod) and checkout commit **f75fbbe7e51455c8aa70c02602b8f5f19cdf6d08**. Now copy over the following modules to `C:\BlitzMax\mods\bah.mod\`:
  - freeimage.mod
  - libarchive.mod
  - libcurl.mod
  - libcurlssl.mod
  - libiconv.mod
  - libssh2.mod
  - libxml.mod
  - regex.mod
  - sstream.mod
  - volumes.mod
  - xz.mod
9. Clone [wx.mod](https://github.com/maxmods/wx.mod) and checkout commit **ce9cd40edfb4d7c1808331aa9f4f75608349dd91**. Copy over the contents of the repo to `C:\BlitzMax\mods\wx.mod\`.
10. Download [lugi.mod](https://github.com/nilium/lugi.mod). At time of writing that was at commit **208ca3df56ef12a713344fdd433540fb3ae79c0a**. Copy over the contents of repo to `C:\BlitzMax\mods\lugi.mod\`.
11. Download [PhotonGameManager-Modules](https://github.com/thomaspreece/PhotonGameManager-Modules). At time of writing this was at commit **e724ca772fb8d6b257ff09f45b430948e0821ae2**.
  - Copy the `sidesign.mod` folder to `C:\BlitzMax\mods\`
  - Copy the `zeke.mod` folder to `C:\BlitzMax\mods\`
  - Copy the `pub.mod\freeprocess.mod` folder to `C:\BlitzMax\mods\pub.mod` overwriting existing `freeprocess.mod`
12. Load up BlitMax and set the following Program->Build Options: Quick Build: OFF, Debug Build: OFF, Threaded Build: ON, Build GUI App: ON
13. Click Program -> Rebuild All Modules

If everything completed successfully, then you are now ready to compile the Photon GameManager code. Instead the Code folder you'll find the main applications:

- PhotonExplorer.bmx
- PhotonFrontend.bmx
- PhotonManager.bmx
- PhotonRunner.bmx
- PhotonUpdater.bmx

You should be able to compile each on of these. To run them correctly, you'll also need to the copy the Mounters, Plugins and Resources folder to the Code folder.

Currently there are still issues with compiling via the above:
- Lua code doesn't seem to be working correctly
- Had to remove libarchive as it crashes application so Patch Lua code cannot decompress (See Includes/General/Compress.bmx)


Credits: some of the steps above were taken from https://mojolabs.nz/posts.php?topic=105834

### BlitzMax 1.52 & MinGW 5.1
Another route I tried to get it compiling correctly was upgrading to MinGW 5.1. The dependencies compiled but resulted in other errors when running the code as detailed below. I'd recommend focusing on either getting it working with 4.7.1 as detailed above or upgrading the code for BlitzMaxNG as described below. These instructions are left here for reference only.

1. Download [Blitzmax sourcecode](https://github.com/blitz-research/blitzmax) to `C:\BlitzMax`
2. Download [BlitzMax_win32_0.87.3.16](https://github.com/bmx-ng/bmx-ng/releases/download/v0.87.3.16.win32/BlitzMax_win32_0.87.3.16.7z) and extract. Copy MinGW32 folder to `C:\Blitzmax\MinGW32`
3. Setup Environment variables for BlitzMax. First go to: Control Panel -> System -> Advanced System Settings -> Environment Variables -> System Variables. Next Add/Update the following:
  - Create `MinGW` Variable and set to `C:\BlitzMax\MinGW32`
  - Create `BMK_LD_OPTS` Variable and set to `-lmsvcrt -lgcc`
  - Update `Path` variable and append `;C:\BlitzMax\MinGW32\bin`
4. Install BlitzMax source code as detailed [here](https://github.com/blitz-research/blitzmax)
7. Clone [bmk](https://github.com/bmx-ng/bmk) to `C:\BlitzMax\bmk` and checkout commit **8e264b2d1266cd999c2f6ac74da362a7a458db46**. Open `C:\BlitzMax\bmk\bmk.bmx` in BlitzMax. Set the following Program->Build Options: Quick Build: OFF, Debug Build: OFF, Threaded Build: ON, Build GUI App: OFF. Now click build. Copy `bmk.mt.exe`, `make.bmk` and `core.bmk` from `C:\BlitzMax\bmk\` to
6. Clone [wx.mod](https://github.com/maxmods/wx.mod) and (important!) checkout commit d9ebf987df1723ed21fe1e566291a3c8b74be430. Copy over the contents of the repo to `BlitzMaxFolder/mods/wx.mod/` except for `wxrarinputstream.mod`.
8. Clone [bah.mod](https://github.com/maxmods/bah.mod) and (important!) checkout commit 00275741bc0ef370ff41a874d55087e821691571. Now copy over the following modules to `C:/BlitzMax/mods/bah.mod/`:
  - freeimage.mod
  - libarchive.mod
  - libcurl.mod
  - libiconv.mod
  - libxml.mod
  - regex.mod
  - sstream.mod
  - volumes.mod
  - xz.mod
8. Clone [bah.mod](https://github.com/maxmods/bah.mod) and (important!) checkout commit 84c682847378a81df73ff05319587a7f5d396857. Now copy over the following modules to `C:/BlitzMax/mods/bah.mod/`:
  - libcurlssl.mod
  - libssh2.mod
10. Download [lugi.mod](https://github.com/nilium/lugi.mod). At time of writing that was at commit 208ca3df56ef12a713344fdd433540fb3ae79c0a. Copy over the contents of repo to `BlitzMaxFolder/mods/lugi.mod/`.
11. Download [PhotonGameManager-Modules](https://github.com/thomaspreece/PhotonGameManager-Modules). At time of writing this was at commit e724ca772fb8d6b257ff09f45b430948e0821ae2.
  - Copy the `sidesign.mod` folder to `BlitzMaxFolder/mods/`
  - Copy the `zeke.mod` folder to `BlitzMaxFolder/mods/`
  - Copy the `pub.mod\freeprocess.mod` folder to `BlitzMaxFolder/mods/pub.mod` overwriting existing `freeprocess.mod`
12. Load up BlitMax and set the following Program->Build Options: Quick Build: OFF, Debug Build: OFF, Threaded Build: ON, Build GUI App: ON
13. Click Program -> Rebuild All Modules

The program compiles but there are several issues that cause it to break:
- libarchive silently fails
- regex cannot handle [^something] syntax any more so crashes all applications

### BlitzMax-NG

Photon GameManager doesn't currently support BlitzMax-NG as the NG compiler requires 'Strict' or 'Super-Strict' BlitzMax language to be used and this repo was originally written without 'Strict'. Updating the source code to 'Strict' shouldn't be too tricky but is likely to take a fair amount of time. PR's are welcome for this feature and that will unlock support for many other platforms along with x64 support (as long as the dependencies are also updated to handle x64). Below I've detailed where I got to getting the dependencies installed and compiled.

To get dependencies installed on BlitzMax-NG follow the below steps:
1. Download BlitzMax-NG. At time of writing that was [BlitzMax_win32_0.120.3.41.7z with MinGW-w64 8.1.0-rev0 distributions](https://github.com/bmx-ng/bmx-ng/releases/download/v0.120.3.41.win32/BlitzMax_win32_0.120.3.41.7z).
2. Download [bah.mod](https://github.com/maxmods/bah.mod). At time of writing that was at commit 1279a6c5de8646cb9941ea7a463b472f58d5536c. You'll only need to copy over the following modules to `BlitzMaxFolder/mods/bah.mod/`:
  - freeimage.mod
  - libarchive.mod
  - libcurl.mod
  - libiconv.mod
  - libssh2.mod
  - libxml.mod
  - mbedtls.mod
  - regex.mod
  - sstream.mod
  - volumes.mod
  - xz.mod
  - zstd.mod
3. Download [wx.mod](https://github.com/maxmods/wx.mod). At time of writing that was at commit 1ed381eda490b4428a891d4c2b196b618c9593d2. Copy over the contents of repo to `BlitzMaxFolder/mods/wx.mod/`
4. Download [zeke.mod](https://github.com/bmx-ng/zeke.mod). At time of writing that was at commit fe0b9ddd02ffbba4351a9c174fbbef558c4e4da8. Copy over the contents of repo to `BlitzMaxFolder/mods/zeke.mod/`.
5. Download [lugi.mod](https://github.com/nilium/lugi.mod). At time of writing that was at commit 208ca3df56ef12a713344fdd433540fb3ae79c0a. Copy over the contents of repo to `BlitzMaxFolder/mods/lugi.mod/`.
6. Download [PhotonGameManager-Modules](https://github.com/thomaspreece/PhotonGameManager-Modules). At time of writing that was at commit e724ca772fb8d6b257ff09f45b430948e0821ae2. Copy the sidesign.mod folder to `BlitzMaxFolder/mods/sidesign.mod/`
7. Load up BlitzMax and build all modules.
8. Replace all mentions of `libcurlssl.mod` in code to `libcurl.mod`
9. Profit?
