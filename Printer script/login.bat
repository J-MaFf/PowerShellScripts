@echo off
set scriptPath=\\KFWS9BDC01\USER\%USERNAME%\printerSetup\addNetworkPrinters.ps1

if exist "%scriptPath%" (
    PowerShell -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%"
) else (
    echo Script not found: %scriptPath%
    exit /b 1
)