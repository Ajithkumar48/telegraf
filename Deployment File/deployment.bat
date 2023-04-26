@echo off
color 0E

REM Locate Source Directory Having "Telegraf" in Folder Name
set "SEARCH_DIR=%~dp0"
set "FOLDER_NAME=telegraf"

for /f "delims=" %%d in ('dir /b /a:d "%SEARCH_DIR%*%FOLDER_NAME%*"') do (
  set "SOURCE_DIR=%SEARCH_DIR%%%d"
  goto FOUND
)

echo "No folder found matching the folder pattern: %SEARCH_DIR%*%FOLDER_NAME%*"
exit /b 1

:FOUND
echo Source folder: %SOURCE_DIR%

REM Destination Directory
set DEST_DIR=/home/%%b/telegraf

REM Loop through each row in the CSV file
for /f "usebackq tokens=1-4 delims=," %%a in ("%~dp0servers.csv") do (
    
	REM SERVER=%%a SSH_USER=%%b SSH_PASS=%%c SSH_PORT=%%d

    REM Set the default port to 22 if no input was provided
    if "%%d" == "" set SSH_PORT=22
    echo.
	echo ------------------------------------------------------------------------
	echo [STARTED] telegraf.service initiated on server: %%a
	echo ------------------------------------------------------------------------
	echo.
    echo Copying files to %%a...
	echo.
    plink -batch -ssh -P %%d -l %%b -pw %%c %%a "mkdir -p %DEST_DIR%" > nul
    pscp -C -r -P %%d -pw %%c %SOURCE_DIR%\* %%b@%%a:%DEST_DIR%
    plink -batch -ssh -P %%d -l %%b -pw %%c %%a "sudo chmod -R 777 %DEST_DIR% && cd %DEST_DIR% && sudo ./telegraf_start.sh" > nul
	echo.
	echo [Status] & plink -batch -ssh -P %%d -l %%b -pw %%c %%a "sudo systemctl status telegraf | grep Active:"
    echo.
)

REM Pause the script to allow the user to read the output
pause