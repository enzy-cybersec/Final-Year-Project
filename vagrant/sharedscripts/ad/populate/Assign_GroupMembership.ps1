Import-Module ActiveDirectory

# Base OU where users exist
$BaseOU = "OU=CorpUsers,DC=fyp,DC=lab"

# Mapping of Departments to Groups
$DeptToGroupMap = @{
    "IT"       = "IT_Admins"
    "HR"       = "HR_Staff"
    "Finance"  = "Finance_Staff"
    "Sales"    = "Sales_Staff"
    "Marketing"= "Marketing_Staff"
}

# Loop through each department
foreach ($dept in $DeptToGroupMap.Keys) {

    # Construct OU path
    $DeptOU = "OU=$dept,$BaseOU"

    # Get users in the department
    $Users = Get-ADUser -Filter * -SearchBase $DeptOU

    # Get target group
    $GroupName = $DeptToGroupMap[$dept]

    # Ensure the group exists
    if (-not (Get-ADGroup -Filter "Name -eq '$GroupName'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $GroupName -GroupScope Global -Path $BaseOU -Description "$dept Department Group"
        Write-Host "Created group: $GroupName"
    }

    # Add each user to the group
    foreach ($user in $Users) {
        Add-ADGroupMember -Identity $GroupName -Members $user.SamAccountName -ErrorAction SilentlyContinue
        Write-Host "Added user $($user.SamAccountName) to group $GroupName"
    }
}

# Verify group membership
Write-Host "`nGroup Memberships:"
foreach ($group in $DeptToGroupMap.Values) {
    $members = Get-ADGroupMember -Identity $group | Select-Object -ExpandProperty SamAccountName
    Write-Host "${group}:`n $($members -join ', ')`n"
}