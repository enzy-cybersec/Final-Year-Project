#Import AD modules 
Import-Module ActiveDirectory

#Discover the domain DN
$DomainDN = (Get-ADDomain).DistinguishedName
$CorpUsersOU = "OU=CorpUsers,$DomainDN"

# Safety check 
if (-not (Get-ADOrganizationalUnit -Identity $CorpUsersOU -ErrorAction SilentlyContinue)) {
    Write-Error "CorpUsers OU does not exist. Run A1 first."
    exit 1
}

$Departments = @(
    "IT"
    "HR"
    "Finance"
    "Engineering"
    "Sales"
    "Operations"
)

foreach ($dept in $Departments) {

    $existingOU = Get-ADOrganizationalUnit `
        -Filter "Name -eq '$dept'" `
        -SearchBase $CorpUsersOU `
        -SearchScope OneLevel `
        -ErrorAction SilentlyContinue

    if ($existingOU) {
        Write-Host "Department OU already exists: $dept"
        continue
    }

    New-ADOrganizationalUnit `
        -Name $dept `
        -Path $CorpUsersOU `
        -ProtectedFromAccidentalDeletion $true `
        -ErrorAction Stop

    Write-Host "Created Department OU: $dept"
}

#verification 
Get-ADOrganizationalUnit `
  -SearchBase "OU=CorpUsers,DC=fyp,DC=lab" `
  -SearchScope OneLevel `
  -Filter * | Select Name, DistinguishedName

