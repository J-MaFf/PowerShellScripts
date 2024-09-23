@echo off

:: Define the server variable
set server=\\JLAS2BDC01

:: Define the userShare variable using the server and username variables
set userShare=%server%\%username%$

:: Map the network drive to Q:
net use Q: %userShare%

:: Check if the mapping was successful
if %errorlevel% neq 0 (
    echo Failed to map network drive.
    pause
    exit /b %errorlevel%
)

:: Run the PowerShell script using the mapped drive
powershell -File Q:\addNetworkPrinters.ps1

:: Unmap the network drive
net use Q: /delete

:: Pause the script to keep the command prompt window open
pause