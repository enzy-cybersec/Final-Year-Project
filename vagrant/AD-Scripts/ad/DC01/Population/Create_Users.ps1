# Import AD module
Import-Module ActiveDirectory

# Get domain distinguished name
$DomainDN = (Get-ADDomain).DistinguishedName

# Get the base OU 'CorpUsers'
$UsersOUObj = Get-ADOrganizationalUnit -Filter "Name -eq 'CorpUsers'" -SearchBase $DomainDN -ErrorAction SilentlyContinue
$UsersOU = $UsersOUObj.DistinguishedName

# Define users per department
$Users = @{
    IT = @("j.smith","a.khan","m.ali","s.admin","t.dev")
    HR = @("l.brown","e.jones","h.wilson")
    Finance = @("r.miller","c.taylor","p.evans")
    Sales = @("d.thomas","k.anderson","b.moore","s.sales1","s.sales2")
    Marketing = @("n.martin","o.lee","g.walker")
}

# Set a placeholder password
$Password = ConvertTo-SecureString "TempP@ssw0rd!" -AsPlainText -Force

# Create users
foreach ($dept in $Users.Keys) {
    foreach ($username in $Users[$dept]) {
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue
        if ($existingUser) {
            Write-Host "User exists: $username"
            continue
        }

        New-ADUser `
            -Name $username `
            -SamAccountName $username `
            -UserPrincipalName "$username@fyp.lab" `
            -AccountPassword $Password `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -Path $DeptOUs[$dept]

        Write-Host "Created user: $username ($dept)"
    }
}

# Validation: list all users under CorpUsers
Write-Host "`nUsers in 'CorpUsers' OU:"
Get-ADUser -SearchBase $UsersOU -Filter * | Select Name, SamAccountName, DistinguishedName
