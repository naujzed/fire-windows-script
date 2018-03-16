@ECHO OFF
setlocal EnableDelayedExpansion
set /p va= "Enter the IP address >> "
adb connect %va%
pause
set pat=%~dp0
:sta
cls
TITLE WORKING ON %va%
echo [1] Install Apk
echo [2] Push Addons
echo [3] Reeboot
echo [4] Change IP
echo [5] Quit
set /p yn=
cls
if %yn%==1 ( CALL :install_apk )
if %yn%==2 ( CALL :addon)
if %yn%==3 ( 
		echo reebooting %va%
		adb reboot %va%
		)
if %yn%==4 (
		set /p va= "Enter new IP Address "
		adb disconnect
		adb connect %va%
		pause
		GOTO :sta
		)
if %yn%==5 ( 
adb disconnect %va%
echo bye
pause
EXIT
		)
GOTO :sta

::___________________________________________________________________________________________________________________________::
:install_apk 
dir  /b > files.txt
findstr ".apk" files.txt > find.txt
del files.txt
set /a n=0
for /F "tokens=*" %%a in (find.txt) do (
		set arr[!n!]=%%a
		set /A n+=1
)
del find.txt
set arr[%n%]=ALL
set /A %g = n
set /A n+=1
set arr[!n!]=NONE
:apk
for /L %%i in (0,1,%n%) do (
   echo [%%i] !arr[%%i]!
)
set /p %d=
cls
if %d%==%n% ( GOTO :sta)
if %d%==%g% (
	CALL :installapk
	GOTO :sta
)
set com=%pat%!arr[%d%]!
echo Installing !arr[%d%]! wait...
adb install %com%
pause
cls
GOTO :apk

EXIT /B 0

::___________________________________________________________________________________________________________________________::
:addon
set /p yn= "Push zips or install direct[z/d]?"
cls
if %yn%==d (
CALL :inst_add
EXIT
)

set /p iyn= "Push to /storage/emulated/0/Download[y/n]?"
cls
echo Pushing ADD-ONS zips wait...

if %iyn%==y (
adb push ./kodiadd/ /storage/emulated/0/Download
) else (
adb push ./kodiadd/ /storage/sdcard0/Download
)
cls
EXIT /B 0

::___________________________________________________________________________________________________________________________::
:inst_add
set npat=%~dp0kodiadd\unzip
dir /b %npat% > files.txt
set /a ixn=0
for /F "tokens=*" %%a in (files.txt) do (
	set iarr[!ixn!]=%%a
	set /A ixn+=1
)
del %pat%files.txt
set iarr[%ixn%]=ALL
set /A %g = ixn
set /A ixn+=1
set iarr[!ixn!]=NONE
:we
cls
for /L %%i in (0,1,%ixn%) do (
	echo [%%i] !iarr[%%i]!
)



set /p %d=
cls
if %d%==%ixn% ( GOTO :sta)
if %d%==%g% (
	CALL :addall
	GOTO :sta
)
set icom=%npat%\!iarr[%d%]!
adb push %icom% /sdcard/Android/data/org.xbmc.kodi/files/.kodi/userdata/addon_data
cls
GOTO :we
EXIT /B 0
::___________________________________________________________________________________________________________________________::
:addall
	set /a gray=%ixn%-2
	for /L %%i in (0,1,%gray%) do (
 	set icom =%npat% !iarr[%%i]!
	echo pushing !icom! wait...
	adb push %icom% /sdcard/Android/data/org.xbmc.kodi/files/.kodi/userdata/addon_data)
cls
EXIT /B 0
::___________________________________________________________________________________________________________________________::
:installapk
	set /a gay=%n%-2
	for /L %%i in (0,1,%gay%) do (
	set com=%pat%!arr[%%i]!
	echo pushing !com! wait...
	adb install !com!
	clr
)
EXIT /B 0
