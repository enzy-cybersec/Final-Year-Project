#Load AD module
Import-Module ActiveDirectory

#Defining domain context
$DomainDN = (Get-ADDomain).DistinguishedName
$ServiceOU = "OU=ServiceAccounts,$DomainDN"

#Defining Service accounts with the passwords
$ServiceAccounts = @(
    @{
        Name = "svc_iis"
        Description = "IIS Web Service Account"
        Password = "P@ssw0rd123!"
    },
    @{
        Name = "svc_files"
        Description = "File Server Service Account"
        Password = "P@ssw0rd123!"
    },
    @{
        Name = "svc_backup"
        Description = "Backup and Scheduled Tasks Account"
        Password = "P@ssw0rd123!"
    }
)


#Creating accounts
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

#Validation
Get-ADUser -SearchBase "OU=ServiceAccounts,DC=fyp,DC=lab" -Filter *