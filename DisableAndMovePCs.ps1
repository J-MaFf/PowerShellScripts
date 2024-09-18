# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path to the text file containing computer names
$computerNamesFile = "C:\Users\admin-jmaffiola\Desktop\computerNames.txt"

# Read the computer names from the text file
$computerNames = Get-Content -Path $computerNamesFile

# Set the destination OU
$destinationOU = "OU=Not Active (PC),DC=jfc,DC=local"

# Loop through each computer name
foreach ($computerName in $computerNames) {
    try {
        # Get the computer object
        $computer = Get-ADComputer -Identity $computerName -Properties DistinguishedName

        if ($computer) {
            # Disable the computer account
            Set-ADComputer -Identity $computer.DistinguishedName -Enabled $false

            # Move the computer to the destination OU
            Move-ADObject -Identity $computer.DistinguishedName -TargetPath $destinationOU

            Write-Host "Successfully disabled and moved $computerName"
        } else {
            Write-Host "Computer $computerName not found"
        }
    } catch {
        Write-Host "An error occurred: $_"
    }
}