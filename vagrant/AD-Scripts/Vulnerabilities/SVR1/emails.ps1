# --- 1. CONFIGURATION & EMERGENCY RECOVERY ---
$Users = @("b.moore", "r.miller")
$BaseMailPath = "C:\MailStore"

Write-Host "[*] Resetting root permissions for C:\MailStore..." -ForegroundColor Yellow
if (!(Test-Path $BaseMailPath)) { New-Item -ItemType Directory -Path $BaseMailPath -Force }

# Ensure Administrator has full control before modifying
takeown /f $BaseMailPath /r /d y > $null
icacls $BaseMailPath /reset /t > $null

# --- 2. CONFIGURE THE VISIBLE SMB SHARE ---
# Removing any hidden versions and creating a 'Loud' share
Remove-SmbShare -Name "MailServer" -Force -ErrorAction SilentlyContinue
Remove-SmbShare -Name "MailServer$" -Force -ErrorAction SilentlyContinue

# New-SmbShare without the $ makes it enumeratable in 'net view'
New-SmbShare -Name "MailServer" -Path $BaseMailPath -FullAccess "FYP\Domain Admins", "SYSTEM" -ReadAccess "FYP\Domain Users"

# --- 3. APPLY ROOT ENUMERATION PERMISSIONS (NTFS) ---
$RootAcl = Get-Acl $BaseMailPath
$RootAcl.SetAccessRuleProtection($true, $false) # Block inheritance

# Grant 'ListDirectory' to Domain Users so they can see folder names (b.moore, r.miller)
# We set 'InheritanceFlags' to 'None' so this rule doesn't trickle down into the private files
$EnumRule = New-Object System.Security.AccessControl.FileSystemAccessRule("FYP\Domain Users", "ListDirectory", "None", "None", "Allow")
$RootAcl.AddAccessRule($EnumRule)
Set-Acl $BaseMailPath $RootAcl

# --- 4. INDIVIDUAL USER ISOLATION ---
foreach ($User in $Users) {
    $UserPath = "$BaseMailPath\$User"
    if (!(Test-Path $UserPath)) { New-Item -ItemType Directory -Path $UserPath -Force }

    $Acl = Get-Acl $UserPath
    $Acl.SetAccessRuleProtection($true, $false) # Total isolation from parent rules

    # A. System/Admins Full Access
    $Ar_Sys = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
    $Ar_Adm = New-Object System.Security.AccessControl.FileSystemAccessRule("FYP\Domain Admins", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Ar_Sys)
    $Acl.AddAccessRule($Ar_Adm)

    # B. Grant specific User ONLY
    $Ar_User = New-Object System.Security.AccessControl.FileSystemAccessRule("FYP\$User", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Ar_User)

    Set-Acl $UserPath $Acl
    Write-Host "[+] Isolated: $UserPath" -ForegroundColor Green
}

# --- 5. MAIL DELIVERY SIMULATION (Traffic Generation) ---
$MailData = @(
    @{ To="r.miller"; Body="Robert, credentials for b.moore have been updated. Also the temperory password for local admin account is 'S@feAdmin123!'." },
    @{ To="b.moore"; Body="CONFIDENTIAL: The SQL password is 'S@fePassw0rd!'" }
)

foreach ($Mail in $MailData) {
    $TargetFile = "$BaseMailPath\$($Mail.To)\$($Mail.To).eml"
    $EmlContent = "From: IT-Support@fyp.lab`nTo: $($Mail.To)@fyp.lab`nSubject: Internal Note`n`n$($Mail.Body)"
    $EmlContent | Out-File -FilePath $TargetFile -Encoding utf8 -Force
}

Write-Host "`n[COMPLETED] MailServer is now visible and user folders are enumeratable." -ForegroundColor White