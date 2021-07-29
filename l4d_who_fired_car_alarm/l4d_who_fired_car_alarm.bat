@echo off
cls
echo [*] Removing the old SMX file ...
del compiled\l4d_who_fired_car_alarm.smx

echo [*] Removing the CFG file ...
del "C:\Program Files (x86)\Steam\steamapps\common\left 4 dead\left4dead\cfg\sourcemod\l4d_who_fired_car_alarm.cfg"

echo [*] Compiling ...
"%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead\left4dead\addons\sourcemod\scripting\compile.exe" l4d_who_fired_car_alarm.sp

echo.
echo [*] Copying the new SMX file to the Plugins directory ...
copy /y /b compiled\l4d_who_fired_car_alarm.smx "%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead\left4dead\addons\sourcemod\plugins\smx"

echo.
pause