@echo off
cls
echo [*] Removing the old SMX file ...
del compiled\l4d_graves.smx

echo [*] Compiling ...
"%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead\left4dead\addons\sourcemod\scripting\compile.exe" l4d_graves.sp

echo.
echo [*] Copying the new SMX file to the Plugins directory ...
copy /y /b compiled\l4d_graves.smx "%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead\left4dead\addons\sourcemod\plugins\smx"
copy /y /b compiled\l4d_graves.smx "%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead 2\left4dead2\addons\sourcemod\plugins\smx"

echo.
pause