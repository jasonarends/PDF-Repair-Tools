@ECHO OFF
setlocal EnableDelayedExpansion
%~d0
cd %~p0

color 0f
echo Starting Lacerte PDF Printer Repair Tool...
echo Ending Lacerte Processes in the background...
PING -n 1 127.0.0.1 >NUL

for /f "tokens=1" %%i in ('tasklist /nh /fi "imagename eq w*"') do echo %%i | find "tax.exe" && taskkill /f /fi "imagename eq %%i"

echo Ending DMS Processes...
taskkill /f /fi "imagename eq dms*"

PING -n 10 127.0.0.1 >NUL
echo Ending hung spooler services...
TASKKILL /F /IM splwow64.exe 2>NUL
TASKKILL /F /IM spoolsv.exe 2>NUL

Echo Stopping Print Spooler Service...
PING -n 3 127.0.0.1 >NUL
NET STOP "Spooler" 2>NUL
echo Clearing Temporary Printer Files...
PING -n 1 127.0.0.1 >NUL
del %systemroot%\system32\spool\printers\*.shd 2>NUL
del %systemroot%\system32\spool\printers\*.spl 2>NUL


echo Removing nul Port... 
call regedit.exe /s removenul.reg
PING -n 1 127.0.0.1 >NUL
echo Adding NUL Port...
call regedit.exe /s addports.reg
PING -n 1 127.0.0.1 >NUL
echo Starting Print Spooler Service...
net start "Spooler"
PING -n 1 127.0.0.1 >NUL
echo Installing Lacerte PDF Printer...
call .\amyuni450\install.exe -s "Lacerte PDF" -n "Intuit Inc." -O "NUL:" -c "07EFCDAB01000100CC84AC581282824C32A0944C3CE5CACA1509E3EDB3B8A8B75CE7ED37B486C9906518B76D6267D666CB1CA1196FBFF0A5D5511E001E4D"
PING -n 1 127.0.0.1 >NUL

echo Installing Lacerte Tax PDF 4.0 Printer
call .\amyuni450\install.exe -s "Lacerte Tax PDF 4.0" -n "Intuit Inc." -O "NUL:" -c "07EFCDAB01000100CC84AC581282824C32A0944C3CE5CACA1509E3EDB3B8A8B75CE7ED37B486C9906518B76D6267D666CB1CA1196FBFF0A5D5511E001E4D"
PING -n 1 127.0.0.1 >NUL

if exist "c:\program files\intuit\dms\dms.exe" (
	goto DMS
) else (
	goto SIXTYFOUR
)

:SIXTYFOUR
if exist "c:\program files (x86)\intuit\dms\dms.exe" (
	goto DMS
) else (
	goto END
)

:DMS
echo DMS Detected... Installing DMS PDF Printer...
call .\amyuni450\install.exe -s "DMS PDF Printer" -n "Intuit Inc." -O "dms" -c "07EFCDAB01000100CC84AC581282824C32A0944C3CE5CACA1509E3EDB3B8A8B75CE7ED37B486C9906518B76D6267D666CB1CA1196FBFF0A5D5511E001E4D"
PING -n 1 127.0.0.1 >NUL

if not exist "c:\users" (
	echo Configuring DMS PDF Printer for XP...
	call regedit.exe /s dmsprinterxp.reg
) else (
	if exist "c:\program files (x86)" (
		echo Configuring DMS PDF Printer for Win-64...
		call regedit.exe /s dmsprinter64.reg
	) else (
		echo Configuring DMS PDF Printer for Win-32...
		call regedit.exe /s dmsprinter.reg
	)
)

:END

ping -n 1 127.0.0.1 >NUL

echo Restarting Print Spooler Service...

NET STOP "Spooler"
PING -n 3 127.0.0.1 >NUL
NET START "Spooler"

echo Lacerte PDF Printer Repair Tool finished...

pause