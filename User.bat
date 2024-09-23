@echo off

:: echo Script started successfully on %date% at %time% > U:\logfile.txt
:: Define the server variable
set server=\\JLAS2BDC01

:: Define the userShare variable using the server and username variables
set userShare=%server%\%username%$

:: Run the PowerShell script using the mapped drive
powershell -File U:\addNetworkPrinters.ps1