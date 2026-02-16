# Import AD module
Import-Module ActiveDirectory

# Define the Groups OU
$GroupsOU = "OU=Groups,DC=fyp,DC=lab"

# Ensure the Groups OU exists
if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$GroupsOU'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Groups" -Path (Get-ADDomain).DistinguishedName
    Write-Host "Created base OU: Groups"
} else {
    Write-Host "Base OU 'Groups' found."
}

# Define groups
$Groups = @(
    "IT_Admins",
    "HR_Staff",
    "Finance_Staff",
    "Sales_Staff",
    "Marketing_Staff",
    "All_Employees"
)

# Create groups
foreach ($group in $Groups) {
    if (-not (Get-ADGroup -Filter "SamAccountName -eq '$group'" -SearchBase $GroupsOU -ErrorAction SilentlyContinue)) {
        New-ADGroup `
            -Name $group `
            -SamAccountName $group `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $GroupsOU

        Write-Host "Created group: $group"
    } else {
        Write-Host "Group already exists: $group"
    }
}

