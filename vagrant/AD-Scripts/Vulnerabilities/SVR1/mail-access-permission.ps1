$Users = @("b.moore", "r.miller")
$BaseMailPath = "C:\MailStore"

foreach ($User in $Users) {
    $UserPath = "$BaseMailPath\$User"
    
    # Create the folder if it doesn't exist
    if (!(Test-Path $UserPath)) { New-Item -ItemType Directory -Path $UserPath }

    $Acl = Get-Acl $UserPath
    
    # Block Inheritance (removes 'Admins' and 'System' inherited rights)
    $Acl.SetAccessRuleProtection($true, $false)

    # Grant the specific user Full Control
    $Identity = "fyp\$User"
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Identity, "FullControl", "Allow")
    $Acl.SetAccessRule($Rule)

    # Grant the SYSTEM account access
    $SysRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "Allow")
    $Acl.SetAccessRule($SysRule)

    # Apply the permissions
    Set-Acl $UserPath $Acl
    Write-Host "[+] Lockdown complete for $User" -ForegroundColor Cyan
}