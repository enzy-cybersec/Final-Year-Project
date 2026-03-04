$GranteeUser = "s.admin"
$TargetUser = "t.dev"

# Fetch the Target User object
$UserObj = Get-ADUser $TargetUser
$UserDN = "AD:\$($UserObj.DistinguishedName)"
$ACL = Get-Acl -Path $UserDN

# Setup the Reset Password ACE
$Guid = [Guid]"00299570-246d-11d0-a768-00aa006e0529"
$UserSID = (Get-ADUser $GranteeUser).SID
$Rights = [System.DirectoryServices.ActiveDirectoryRights]"ExtendedRight"
$Type = [System.Security.AccessControl.AccessControlType]"Allow"

$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($UserSID, $Rights, $Type, $Guid)

# Apply it
$ACL.AddAccessRule($ACE)
Set-Acl -Path $UserDN -AclObject $ACL

Write-Host "SUCCESS: s.admin can now specifically target $TargetUser" -ForegroundColor Green