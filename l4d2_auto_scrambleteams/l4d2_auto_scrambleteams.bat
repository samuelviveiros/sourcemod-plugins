@echo off
cls
echo [*] Removing the old SMX file ...
del compiled\l4d2_auto_scrambleteams.smx

echo [*] Removing the CFG file ...
del "C:\Program Files (x86)\Steam\steamapps\common\left 4 dead 2\left4dead2\cfg\sourcemod\l4d2_auto_scrambleteams.cfg"

echo [*] Compiling ...
"%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead 2\left4dead2\addons\sourcemod\scripting\compile.exe" l4d2_auto_scrambleteams.sp

echo.
echo [*] Copying the new SMX file to the Plugins directory ...
copy /y /b compiled\l4d2_auto_scrambleteams.smx "%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead 2\left4dead2\addons\sourcemod\plugins\smx"

echo.
pause