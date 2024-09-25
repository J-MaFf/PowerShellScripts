# Start the transcript to capture all output and errors
$transcriptPath = Join-Path -Path $PSScriptRoot -ChildPath "addNetworkPrinters_Transcript.txt"
Start-Transcript -Path $transcriptPath

# Define the path to the text file containing printer names in the same folder as the script
$printerFilePath = Join-Path -Path $PSScriptRoot -ChildPath "printerNames.txt"

# Check if the printer file exists
if (-Not (Test-Path -Path $printerFilePath)) {
    Write-Host "Printer file not found: $printerFilePath"
    Stop-Transcript
    exit
}

# Read the printer names from the file
$printers = Get-Content -Path $printerFilePath

# Define the path to the marker file in the user's profile
$markerFilePath = "$env:USERPROFILE\printers_added.txt"

# Check if the marker file exists
if (-Not (Test-Path -Path $markerFilePath)) {
    # Add the network printers
    foreach ($printer in $printers) {
        try {
            Write-Host "Adding printer: $printer"
            Add-Printer -ConnectionName $printer
            Write-Host "Successfully added printer: $printer"
        } catch {
            Write-Host "Failed to add printer: $printer. Error: $_"
            Write-Host "Error details: $($_.Exception.Message)"
        }
    }

    # Create the marker file to indicate that the printers have been added
    # The marker file is used to prevent adding the printers multiple times
    New-Item -Path $markerFilePath -ItemType File -Force
} else {
    Write-Host "Printers have already been added. Skipping..."
}

# Stop the transcript
Stop-Transcript

# End of script