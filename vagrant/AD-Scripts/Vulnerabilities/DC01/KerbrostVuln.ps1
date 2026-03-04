# --- 1. CONFIGURATION ---
$TargetSPN = "MSSQLSvc/SVR1.fyp.lab:1433"
$HoneyTokenName = "sql_svc_audit" 
$AuditorName = "t.dev"
$PasswordRaw = "P@ssw0rd123!" 
$SecurePassword = ConvertTo-SecureString $PasswordRaw -AsPlainText -Force

Write-Host "--- Starting AD Hardening: Zero-Visibility Mode ---" -ForegroundColor White

# --- 2. OBJECT CHECK ---
$UserObj = Get-ADUser -Filter "SamAccountName -eq '$HoneyTokenName'"
if ($null -eq $UserObj) {
    Write-Host "[!] Target user not found. Please ensure the user exists first." -ForegroundColor Red
    return
}

# --- 3. THE LOCKDOWN ---
Write-Host "[*] Stripping all inherited permissions from $HoneyTokenName..." -ForegroundColor Cyan
$UserPath = "AD:\$($UserObj.DistinguishedName)"
$ACL = Get-Acl -Path $UserPath

# SEVER INHERITANCE: $true = protect (keep manual), $false = discard (delete inherited)
# This is the crucial step that removes 'Authenticated Users' access.
$ACL.SetAccessRuleProtection($true, $false)

# Clear any existing manual rules to start from zero
$ACL.Access | ForEach-Object { $ACL.RemoveAccessRule($_) }

# A. Add SYSTEM (Full Control - Essential)
$SID_Sys = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
$RuleSys = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($SID_Sys, "GenericAll", "Allow")
$ACL.AddAccessRule($RuleSys)

# B. Add Domain Admins (Full Control)
$DA_Group = (Get-ADGroup "Domain Admins").SID
$RuleDA = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($DA_Group, "GenericAll", "Allow")
$ACL.AddAccessRule($RuleDA)

# C. Add t.dev (Read ONLY - This allows ONLY them to see the SPN)
$SID_Dev = (Get-ADUser $AuditorName).SID
$RuleDev = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($SID_Dev, "ReadProperty", "Allow")
$ACL.AddAccessRule($RuleDev)

# Apply the hardened ACL
Set-Acl -Path $UserPath -AclObject $ACL

Write-Host "[SUCCESS] DACL has been fully restricted." -ForegroundColor Green
Write-Host "Checking result for t.dev..." -ForegroundColor Gray