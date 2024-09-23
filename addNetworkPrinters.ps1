# Define the path to the text file containing printer names
$printerFilePath = "printerNames.txt"

# Check if the printer file exists
if (-Not (Test-Path -Path $printerFilePath)) {
    Write-Host "Printer file not found: $printerFilePath"
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
        }
    }

    # Create the marker file to indicate that the printers have been added
    New-Item -Path $markerFilePath -ItemType File -Force
    Write-Host "Created marker file: $markerFilePath"
} else {
    Write-Host "Printers have already been added for this user."
}