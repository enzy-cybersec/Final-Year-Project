
$ServiceAccounts = @("svc_iis", "svc_files", "svc_backup")
$DomainDN = "DC=fyp,DC=lab"
$Password = "P@ssw0rd123!"

Write-Host "--- Starting Persistent Service Account Authentication ---" -ForegroundColor White -BackgroundColor DarkRed

# Persistent loop to ensure this runs throughout the 9-5 period
while($true) {
    foreach ($acct in $ServiceAccounts) {
        $CredUser = "$acct@fyp.lab"
        
        try {
            # Creating a DirectoryEntry object and refreshing the cache 
            # forces an LDAP bind (TCP 389) to the Domain Controller.
            $ldap = New-Object System.DirectoryServices.DirectoryEntry(
                "LDAP://$DomainDN",
                $CredUser,
                $Password
            )
            $ldap.RefreshCache() 
            Write-Host "[$(Get-Date -Format HH:mm:ss)] Auth SUCCESS: $acct" -ForegroundColor Green
        }
        catch {
            Write-Warning "[$(Get-Date -Format HH:mm:ss)] Auth FAILED: $acct - Check account status."
        }

        # Human-like stagger between different service account authentications
        Start-Sleep -Seconds (Get-Random -Minimum 10 -Maximum 20)
    }

    # Longer delay before the next round of service checks
    # Real services don't re-authenticate every minute; we'll wait 15-30 minutes.
    $LongWait = Get-Random -Minimum 900 -Maximum 1800
    Write-Host "[...] Cycle complete. Next service auth in $($LongWait/60) minutes." -ForegroundColor Gray
    Start-Sleep -Seconds $LongWait
}