#Define service accounts
$ServiceAccounts = @("svc_iis","svc_files","svc_backup")

#define domain ND
$DomainDN = "DC=fyp,DC=lab"

#for loop for login with cridentials
foreach ($acct in $ServiceAccounts) {

    $Password = "P@ssw0rd123!"
    $CredUser = "$acct@fyp.lab"

    try {
        $ldap = New-Object System.DirectoryServices.DirectoryEntry(
            "LDAP://$DomainDN",
            $CredUser,
            $Password
        )
        $ldap.RefreshCache()
        Write-Host "Auth SUCCESS: $acct"
    }
    catch {
        Write-Host "Auth FAILED: $acct"
    }

    Start-Sleep -Seconds 15
}
