@echo off

REM Redirect all output to a log file
(
    echo Script started successfully on %date% at %time%
    REM Run the PowerShell script using the mapped drive and ignore the execution policy
    REM Check if the script exists on U: drive
    if exist U:\printerSetup\addNetworkPrinters.ps1 (
        powershell -ExecutionPolicy Bypass -File U:\printerSetup\addNetworkPrinters.ps1
    ) else (
        echo Script not found on U: drive
    )
) > U:\printerSetup\logfile.txt 2>&1