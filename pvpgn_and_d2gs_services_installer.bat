:: Copyright 2011 Naki (naki@pvpgn.pl). All rights reserved.
:: License: FreeBSD
:: http://www.opensource.org/licenses/bsd-license.php

@echo off
set TITLE="PvPGN ^& D2GS Windows services installer v0.1, Naki-BoT ^(http://naki.info/^)"

::
:: Configuration
::

:: Executable paths
:: Set all variables within double quotes (")
:: If You don't want to install service then set it path to ""
:: You can also add here additional parameters like "--config=FILE" (separated by spaces)

set PVPGN_PATH="D:\Server\PvPGN\PvPGN.exe"
set PVPGN_PARAMETERS="--service"

set D2CS_PATH="D:\Server\PvPGN\d2cs.exe"
set D2CS_PARAMETERS="--service"

set D2DBS_PATH="D:\Server\PvPGN\d2dbs.exe"
set D2DBS_PARAMETERS="--service"

set D2GS_PATH="D:\Server\D2GS\D2GSSVC.exe"
set D2GS_PARAMETERS=""

:: Service start: "auto" - automatic, "demand" - manual
set SERVICE_START="auto"

::
:: Do not edit anything below
::

:: Before start

cls
title %TITLE:"=%
setlocal enabledelayedexpansion

:: Variables

set PVPGN_SERVICE="PvPGN"
set PVPGN_DESCRIPTION="Player vs. Player Gaming Network - Server"

set D2CS_SERVICE="PvPGN - D2CS"
set D2CS_DESCRIPTION="Diablo II - Closed Character Server"

set D2DBS_SERVICE="PvPGN - D2DBS"
set D2DBS_DESCRIPTION="Diablo II - DataBase Server"

set D2GS_SERVICE="PvPGN - D2GS"
set D2GS_DESCRIPTION="Diablo II - Game Server"

set STEPS_COUNT=4
set CURRENT_STEP=1
set REMOVE=0
set CLEANUP=0

:: Credits

echo *******************************************************************************
echo *                                                                             *
echo * %TITLE:"=%  *
echo *                                                                             *
echo *******************************************************************************
echo.

:: Start

goto PvPGN

:PvPGN
set CURRENT_SERVICE=%PVPGN_SERVICE%
set CURRENT_DESCRIPTION=%PVPGN_DESCRIPTION%
set CURRENT_PATH=%PVPGN_PATH%
set CURRENT_PARAMETERS=%PVPGN_PARAMETERS%
set GOTO=D2CS
goto execute_action

:D2CS
set CURRENT_SERVICE=%D2CS_SERVICE%
set CURRENT_DESCRIPTION=%D2CS_DESCRIPTION%
set CURRENT_PATH=%D2CS_PATH%
set CURRENT_PARAMETERS=%D2CS_PARAMETERS%
set GOTO=D2DBS
goto execute_action

:D2DBS
set CURRENT_SERVICE=%D2DBS_SERVICE%
set CURRENT_DESCRIPTION=%D2DBS_DESCRIPTION%
set CURRENT_PATH=%D2DBS_PATH%
set CURRENT_PARAMETERS=%D2DBS_PARAMETERS%
set GOTO=D2GS
goto execute_action

:D2GS
set CURRENT_SERVICE=%D2GS_SERVICE%
set CURRENT_DESCRIPTION=%D2GS_DESCRIPTION%
set CURRENT_PATH=%D2GS_PATH%
set CURRENT_PARAMETERS=%D2GS_PARAMETERS%
set GOTO=result_ok
goto execute_action

:execute_action
:: Install service
if %REMOVE% == 0 (
	goto install_service
)
:: End script after this action
if %GOTO% == result_ok (
	set GOTO=end
)
goto remove_service

:install_service
echo Step %CURRENT_STEP%/%STEPS_COUNT%:
if not defined CURRENT_PATH (
	goto skip
) else if %CURRENT_PATH% == "" (
	goto skip
)
if not exist %CURRENT_PATH% (
	goto error_not_found
)
set PARAMETERS=binPath= "%CURRENT_PATH:"=% %CURRENT_PARAMETERS:"=%" start= %SERVICE_START%
sc create %CURRENT_SERVICE% %PARAMETERS% > nul
set ERROR_CODE=%ERRORLEVEL%
if %ERROR_CODE% == 5 ( 
    goto error_permissions 
) else if %ERROR_CODE% == 1072 (
    goto error_running
) else if %ERROR_CODE% == 1073 (
    goto error_already_exists 
) else if not %ERROR_CODE% == 0 (
    goto error_unknown
)
sc description %CURRENT_SERVICE% %CURRENT_DESCRIPTION% > nul
echo  + Service installed: %CURRENT_SERVICE%.
set /a CURRENT_STEP=(%CURRENT_STEP% + 1)
echo.
goto %GOTO%

:remove_service
if not defined CURRENT_PATH (
	echo  - %CURRENT_SERVICE%: path not specified, skipping...
) else if %CURRENT_PATH% == "" (
	echo  - %CURRENT_SERVICE%: path not specified, skipping...
) else (
	sc delete %CURRENT_SERVICE% > nul
	if !ERRORLEVEL! == 0 (
		echo  - %CURRENT_SERVICE%: removed
	) else if !ERRORLEVEL! == 1060 (
		echo  - %CURRENT_SERVICE%: not found, skipping...
	) else if !ERRORLEVEL! == 1072 (
		echo  - %CURRENT_SERVICE%: marked for deletion ^(currently running?^)
	) else (
		echo  - %CURRENT_SERVICE%: NOT removed ^(error code: !ERRORLEVEL!^)
	)
)
goto %GOTO%

:clean_services
:: Check administrator privileges
if not !ERROR_CODE! == 5 (
	if !CLEANUP! == 0 (
		goto get_clean_up_info
	)
	if /i !CLEANUP! == "y" (
		set REMOVE=1
		goto PvPGN
	)
)
goto end

:get_clean_up_info
echo.
set /p CLEANUP="Cleanup: Do You want to remove all existing PvPGN & D2GS services ? [Y/N]: "
set CLEANUP="%CLEANUP:~0,1%"
if /i !CLEANUP! == "y" (
	goto clean_services
)
if /i !CLEANUP! == "n" (
	goto clean_services
)
goto get_clean_up_info

:error_not_found
echo  - Service NOT installed: %CURRENT_SERVICE%.
echo    ^(Path not found: %CURRENT_PATH%^)
goto result_error

:error_permissions
echo  - Service NOT installed: %CURRENT_SERVICE%.
echo    ^(Permissions error, run script as Administrator user^)
goto result_error

:error_running
echo  - Service NOT installed: %CURRENT_SERVICE%.
echo    ^(Already exists and running^)
goto result_error

:error_already_exists
echo  - Service NOT installed: %CURRENT_SERVICE%.
echo    ^(Already exists^)
goto result_error

:error_unknown
echo  - Service NOT installed: %CURRENT_SERVICE%.
echo    ^(Error code: %ERROR_CODE%^)
goto result_error

:skip
echo  - Service NOT installed: %CURRENT_SERVICE%.
echo    ^(Path not specified, skipping^)
echo.
goto %GOTO%

:result_error
echo.
echo Result:
echo  - An error occurred, instalation failed ^^^!
goto clean_services

:result_ok
echo Result:
echo  + Installation successful ^^^!
goto end

:end
endlocal
echo.
echo Bye ^!
echo.
pause