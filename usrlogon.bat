@echo off

:: Define the server variable
set server=\\JLAS2BDC01

:: Define the userShare variable using the server and username variables
set userShare=%server%\%username%$

:: Check if the Q: drive is already mapped
net use Q: >nul 2>&1
if %errorlevel% equ 0 (
    echo Drive Q: is already mapped.
    echo Unmapping the existing Q: drive.
    net use Q: /delete >nul 2>&1
    if %errorlevel% neq 0 (
        echo Failed to unmap the existing Q: drive.
        pause
        exit /b %errorlevel%
    )
)

:: Map the network drive to Q:
net use Q: %userShare%

:: Check if the mapping was successful
if %errorlevel% neq 0 (
    echo Failed to map network drive.
    pause
    exit /b %errorlevel%
)

:: Run the PowerShell script using the mapped drive and keep the window open as administrator
powershell -NoProfile -ExecutionPolicy Bypass -NoExit -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File Q:\addNetworkPrinters.ps1' -Verb RunAs"

:: Unmap the network drive
net use Q: /delete

:: Pause the script to keep the command prompt window open
pause