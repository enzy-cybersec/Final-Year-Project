#Importing AD modules
Import-Module ActiveDirectory

#define domain paths
$DomainDN = (Get-ADDomain).DistinguishedName
$UsersOU = (Get-ADOrganizationalUnit -Filter "Name -eq 'Users'").DistinguishedName


#define department structure
$Departments = @(
    "IT",
    "HR",
    "Finance",
    "Sales",
    "Marketing"
)

#ensure department OUs exist
foreach ($dept in $Departments) {

    $DeptOU = "OU=$dept,$UsersOU"

    $ExistingDept = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$DeptOU'" -ErrorAction SilentlyContinue

    if (-not $ExistingDept) {
        New-ADOrganizationalUnit -Name $dept -Path $UsersOU
        Write-Host "Created OU: $dept"
    } else {
        Write-Host "OU already exists: $dept"
    }
}

#define users 
$Users = @{
    IT = @("j.smith","a.khan","m.ali","s.admin","t.dev")
    HR = @("l.brown","e.jones","h.wilson")
    Finance = @("r.miller","c.taylor","p.evans")
    Sales = @("d.thomas","k.anderson","b.moore","s.sales1","s.sales2")
    Marketing = @("n.martin","o.lee","g.walker")
}

#define placeholder password
$Password = ConvertTo-SecureString "TempP@ssw0rd!" -AsPlainText -Force

#create users
foreach ($dept in $Users.Keys) {

    $DeptOU = "OU=$dept,$UsersOU"

    foreach ($username in $Users[$dept]) {

        if (Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue) {
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
            -Path $DeptOU

        Write-Host "Created user: $username ($dept)"
    }
}

#validation
Get-ADUser -SearchBase "OU=Users,DC=fyp,DC=lab" -Filter *

