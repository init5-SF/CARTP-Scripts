function Find-ADFS {
    param (
        [string]$domain
    )

    $configPartitionPath = "LDAP://CN=Configuration,$((Get-WmiObject Win32_ComputerSystem).Domain)"

    try {
        # Try to bind to the Configuration partition
        $configPartition = [adsi]$configPartitionPath

        # Check if the AD FS container exists in the Configuration partition
        $adfsContainer = $configPartition.Children | Where-Object { $_.SchemaClassName -eq 'FederationService' }

        if ($adfsContainer -ne $null) {
            # Get the server name where AD FS is installed
            $adfsserver = $adfsContainer.Properties["serviceHostName"].Value
            Write-Host "AD FS is installed on server: $adfsserver"
        } else {
            Write-Host "AD FS is not installed in the domain."
        }
    } catch {
        Write-Host "Error: $_"
    }
}

$currentDomain = (Get-WmiObject Win32_ComputerSystem).Domain

Find-ADFS -domain $currentDomain
