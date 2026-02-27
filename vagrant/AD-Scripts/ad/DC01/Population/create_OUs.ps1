#Import AD modules 
Import-Module ActiveDirectory

#Discover Domain DN
$DomainDN = (Get-ADDomain).DistinguishedName

#Define the OU names
$TopLevelOUs = @(
    "CorpUsers"
    "Groups"
    "Servers"
    "Workstations"
    "ServiceAccounts"
)

#Loop and create OUs
foreach ($ou in $TopLevelOUs) {

    $existingOU = Get-ADOrganizationalUnit `
        -Filter "Name -eq '$ou'" `
        -SearchBase $DomainDN `
        -SearchScope OneLevel `
        -ErrorAction SilentlyContinue

#Conditional creation of OUs
    if ($existingOU) {
        Write-Host "OU already exists: $ou"
        continue
    }

    try {
        New-ADOrganizationalUnit `
            -Name $ou `
            -Path $DomainDN `
            -ProtectedFromAccidentalDeletion $true `
            -ErrorAction Stop

        Write-Host "Created OU: $ou"
    }
    catch {
        Write-Host "FAILED to create OU: $ou"
        Write-Host $_.Exception.Message
    }
}

#Validation
Get-ADOrganizationalUnit -Filter * | Select Name, DistinguishedName