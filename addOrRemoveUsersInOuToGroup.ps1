# Check if script is run with administrative privileges
function Test-AdminPrivileges {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Please run this script as an administrator."
        exit
    }
}

# Define the output folder and file path
function Initialize-OutputFolder {
    $outputFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "Output"
    $outputFilePath = Join-Path -Path $outputFolderPath -ChildPath "addOrRemoveUsersInOuToGroup_Output.txt"

    # Create the output folder if it doesn't exist
    if (-not (Test-Path -Path $outputFolderPath)) {
        New-Item -ItemType Directory -Path $outputFolderPath | Out-Null
    }

    Start-Transcript -Path $outputFilePath
    return $outputFilePath
}

# Get and validate the domain
function Get-Domain {
    $domain = Read-Host "Please enter the domain (e.g., 'jfc.local')"

    # Split the domain and format it
    $domainParts = $domain.Split('.')
    $formattedDomain = ""
    foreach ($part in $domainParts) {
        $formattedDomain += "DC=$part,"
    }
    $formattedDomain = $formattedDomain.TrimEnd(',')
    Write-Host "Formatted domain: $formattedDomain"

    # Verify the domain is valid
    try {
        $domainInfo = Get-ADDomain -Identity $domain
        Write-Host "The domain '$domain' is valid and accessible."
    } catch {
        Write-Host "The domain '$domain' is not valid or accessible."
        Write-Host "$domainInfo"
        Stop-Transcript
        exit
    }

    return $formattedDomain
}

# Get and validate OUs and Containers
function Get-OUsAndContainers($formattedDomain) {
    $ous = @()

    while ($true) {
        $ouName = Read-Host "Please enter an OU or container name (or press Enter to finish)"
        if ([string]::IsNullOrWhiteSpace($ouName)) {
            break
        }
        $ou = "OU=$ouName,$formattedDomain"
        $container = "CN=$ouName,$formattedDomain"

        # Verify the OU or Container exists
        try {
            $ouExists = Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ou)"
            $containerExists = Get-ADObject -LDAPFilter "(distinguishedName=$container)"
            if (-not $ouExists -and -not $containerExists) {
                Write-Host "The OU or container '$ouName' does not exist in the domain."
                continue
            } else {
                if ($ouExists) {
                    Write-Host "The OU '$ouName' exists and will be processed."
                    $ous += $ou
                } elseif ($containerExists) {
                    Write-Host "The container '$ouName' exists and will be processed."
                    $ous += $container
                }
            }
        } catch {
            Write-Host "An error occurred while verifying the OU or container: $_"
        }
    }

    return $ous
}

# Verify the group exists
function Test-Group($groupName) {
    $group = Get-ADGroup -Filter { Name -eq $groupName }
    if (-not $group) {
        Write-Host "The group '$groupName' does not exist in the domain."
        Stop-Transcript
        exit
    }
    return $group
}

# Add users to the group
function Add-UsersToGroup($ous, $group) {
    Write-Host "Adding users to group: $($group.Name)"
    foreach ($ou in $ous) {
        Write-Host "Processing OU: $ou"

        # Get all users in the specified OU
        $users = Get-ADUser -Filter * -SearchBase $ou

        # Loop through each user
        foreach ($user in $users) {
            try {
                Write-Host "Processing user: $($user.Name)"

                # Add the user to the group
                Add-ADGroupMember -Identity $group.DistinguishedName -Members $user.DistinguishedName
                Write-Host "Added $($user.Name) to $($group.Name)"

            } catch {
                Write-Host "An error occurred while processing $($user.Name): $_"
            }
        }
    }
}

# Remove users from the group
function Remove-UsersFromGroup($ous, $group) {
    foreach ($ou in $ous) {
        Write-Host "Processing OU: $ou"

        # Get all users in the specified OU
        $users = Get-ADUser -Filter * -SearchBase $ou

        # Loop through each user
        foreach ($user in $users) {
            try {
                Write-Host "Processing user: $($user.Name)"

                # Remove the user from the group
                Remove-ADGroupMember -Identity $group.DistinguishedName -Members $user.DistinguishedName -Confirm:$false
                Write-Host "Removed $($user.Name) from $($group.Name)"

            } catch {
                Write-Host "An error occurred while processing $($user.Name): $_"
            }
        }
    }
}

# Prompt user for action and execute
function Invoke-Action($ous, $group) {
    $action = Read-Host "Do you want to add or remove users from the group? (Enter 'add' or 'remove')"

    if ($action -eq 'add') {
        Add-UsersToGroup $ous $group
    } elseif ($action -eq 'remove') {
        Remove-UsersFromGroup $ous $group
    } else {
        Write-Host "Invalid action. Please enter 'add' or 'remove'."
    }
}

# Main script execution
Test-AdminPrivileges
$outputFilePath = Initialize-OutputFolder
$formattedDomain = Get-Domain
$ous = Get-OUsAndContainers $formattedDomain

# Prompt user for group name
$groupName = Read-Host "Please enter the group name"
$group = Test-Group $groupName

# Execute the action based on user input
Invoke-Action $ous $group

# Stop capturing the console output
Stop-Transcript