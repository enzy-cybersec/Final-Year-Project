# --- 1. CONFIGURATION ---
$HoneyTokenName = "j.smith" 
$TargetSPN = "MSSQLSvc/SVR1.fyp.lab:1433"
$AuditorName = "t.dev"

Write-Host "--- Starting AD Hardening: Zero-Visibility Mode ---" -ForegroundColor White

# --- 2. OBJECT CHECK & SPN ASSIGNMENT ---
$UserObj = Get-ADUser -Filter "SamAccountName -eq '$HoneyTokenName'"
if ($null -eq $UserObj) {
    Write-Host "[!] Target user $HoneyTokenName not found. Please ensure the user exists." -ForegroundColor Red
    return
}

Write-Host "[*] Assigning SPN: $TargetSPN to $HoneyTokenName..." -ForegroundColor Cyan
# This makes the user Kerberoastable
Set-ADUser -Identity $HoneyTokenName -ServicePrincipalNames @{Add=$TargetSPN}

# --- 3. THE LOCKDOWN ---
Write-Host "[*] Stripping all inherited permissions from $HoneyTokenName..." -ForegroundColor Cyan
$UserPath = "AD:\$($UserObj.DistinguishedName)"
$ACL = Get-Acl -Path $UserPath

# SEVER INHERITANCE: $true = protect (keep manual), $false = discard (delete inherited)
# This removes 'Authenticated Users' and 'Domain Users' visibility.
$ACL.SetAccessRuleProtection($true, $false)

# Clear any existing manual rules to start from a 'Default Deny' state
$ACL.Access | ForEach-Object { $ACL.RemoveAccessRule($_) }

# A. Add SYSTEM (Full Control - Essential for OS stability)
$SID_Sys = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
$RuleSys = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($SID_Sys, "GenericAll", "Allow")
$ACL.AddAccessRule($RuleSys)

# B. Add Domain Admins (Full Control - So you don't lock yourself out!)
$DA_Group = (Get-ADGroup "Domain Admins").SID
$RuleDA = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($DA_Group, "GenericAll", "Allow")
$ACL.AddAccessRule($RuleDA)

# C. Add t.dev (ReadProperty ONLY - This allows ONLY them to see the SPN)
$SID_Dev = (Get-ADUser $AuditorName).SID
$RuleDev = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($SID_Dev, "ReadProperty", "Allow")
$ACL.AddAccessRule($RuleDev)

# Apply the hardened ACL to the Active Directory Object
Set-Acl -Path $UserPath -AclObject $ACL

Write-Host "[SUCCESS] DACL has been fully restricted for $HoneyTokenName." -ForegroundColor Green
Write-Host "[*] Only SYSTEM, Domain Admins, and $AuditorName can now see this SPN." -ForegroundColor Yellow