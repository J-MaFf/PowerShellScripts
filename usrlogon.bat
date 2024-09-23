@echo off

echo Script started successfully on %date% at %time% > U:\logfile.txt
:: Define the server variable
set server=\\JLAS2BDC01

:: Define the userShare variable using the server and username variables
set userShare=%server%\%username%$

:: Map the network drive to U:
:: net use U: %userShare%

:: Run the PowerShell script using the mapped drive
powershell -File U:\addNetworkPrinters.ps1

:: Pause the script to keep the command prompt window open
:: pause