@echo off

:: Redirect all output to a log file
(
    echo Script started successfully on %date% at %time%
    
    :: Run the PowerShell script using the mapped drive and ignore the execution policy
    powershell -ExecutionPolicy Bypass -File U:\addNetworkPrinters.ps1
) > U:\logfile.txt 2>&1