@ECHO OFF
TITLE [L4D] Invisible Wall - Plugin Setup v0.1.0
CLS
ECHO --==<(   [L4D] Invisible Wall - Plugin Setup v0.1.0 -- by Dartz8901   )>==--

SET plugin_name=l4d_invisible_wall
SET plugin_src=%plugin_name%.sp
SET plugin_bin=compiled\%plugin_name%.smx
SET sm_plugins_path="%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead\left4dead\addons\sourcemod\plugins\smx"
SET sm_cfg_file="%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead\left4dead\cfg\sourcemod\%plugin_name%.cfg"
SET compiler="%ProgramFiles(x86)%\Steam\steamapps\common\left 4 dead\left4dead\addons\sourcemod\scripting\compile.exe"

ECHO.
:: Creates the "compiled" directory if it does not exist.
IF NOT EXIST compiled (
    ECHO [*] Creating the "compiled" directory ...
    MKDIR compiled
    SLEEP 3
) ELSE (
    :: If the directory exists, delete the last compiled SourcePawn file, if it exists.
    ECHO [*] Deleting old SMX file ...
    IF EXIST %plugin_bin% (
        ECHO [*] OK ... done.
        DEL %plugin_bin%
    ) ELSE (
        ECHO [*] SMX file not found.
    )
)

ECHO.
:: If the compiler exists ...
ECHO [*] Compiling...
IF EXIST %compiler% (
    :: And the source code file exists ...
    IF EXIST %plugin_src% (
        ECHO [*] OK ... done.
        ECHO.
        :: Compiles the SourcePawn file.
        %compiler% %plugin_src%
    ) ELSE (
        ECHO [*] Source code not found.
    )
) ELSE (
    ECHO [*] Compiler not found.
)

ECHO.
ECHO [*] Copying the new SMX file to the Plugins directory ...
:: If the SMX file exists ...
IF EXIST %plugin_bin% (

    :: And the SourceMod plugins directory exists ...
    IF EXIST %sm_plugins_path% (

        ECHO [*] OK ... done.
        :: Copy the SMX file to plugins directory.
        COPY /y /b %plugin_bin% %sm_plugins_path%

        :: If the CFG exists, delete it.
        ECHO [*] Deleting old CFG file ...
        IF EXIST %sm_cfg_file% (
            ECHO [*] OK ... done.
            DEL %sm_cfg_file%
        ) ELSE (
            ECHO [*] CFG file not found.
        )

    ) ELSE (
        ECHO [*] SourceMod plugins directory not found.
    )
) ELSE (
    ECHO [*] SMX file not found.
)

ECHO.
PAUSE