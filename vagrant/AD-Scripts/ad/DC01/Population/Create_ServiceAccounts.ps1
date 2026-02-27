# Load the Active Directory module
Import-Module ActiveDirectory

# Define domain context
$DomainDN = (Get-ADDomain).DistinguishedName
$ServiceOU = "OU=ServiceAccounts,$DomainDN"

# Ensure the ServiceAccounts OU exists
$OU = Get-ADOrganizationalUnit -Filter "Name -eq 'ServiceAccounts'" -ErrorAction SilentlyContinue
if (-not $OU) {
    $OU = New-ADOrganizationalUnit -Name "ServiceAccounts" -Path $DomainDN
    Write-Host "Created OU: ServiceAccounts"
} else {
    Write-Host "Base OU 'ServiceAccounts' found."
}

# Define service accounts
$ServiceAccounts = @(
    @{ Name="svc_iis"; Description="IIS Web Service Account"; Password="P@ssw0rd123!" },
    @{ Name="svc_files"; Description="File Server Service Account"; Password="P@ssw0rd123!" },
    @{ Name="svc_backup"; Description="Backup and Scheduled Tasks Account"; Password="P@ssw0rd123!" }
)

# Create accounts
foreach ($acct in $ServiceAccounts) {
    $Existing = Get-ADUser -Filter "SamAccountName -eq '$($acct.Name)'" -ErrorAction SilentlyContinue
    if ($Existing) {
        Write-Host "Service account already exists: $($acct.Name)"
        continue
    }

    $SecurePassword = ConvertTo-SecureString $acct.Password -AsPlainText -Force

    try {
        New-ADUser `
            -Name $acct.Name `
            -SamAccountName $acct.Name `
            -AccountPassword $SecurePassword `
            -Description $acct.Description `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -CannotChangePassword $true `
            -Path $ServiceOU `
            -ErrorAction Stop

        Write-Host "Created service account: $($acct.Name)"
    }
    catch {
        Write-Host "FAILED to create: $($acct.Name)"
        Write-Host $_
    }
}

# Validation
Write-Host "`nService accounts in '$ServiceOU':"
Get-ADUser -SearchBase $ServiceOU -Filter * | Select-Object Name, SamAccountName, Enabled
