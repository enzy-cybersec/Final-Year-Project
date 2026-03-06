$AdminUser = "s.admin"
$Domain = "fyp.lab"

Write-Host "--- Granting Restricted WinRM Access to SVR1 for $AdminUser ---" -ForegroundColor White

# 1. Add the admin to the local 'Remote Management Users' group on SVR1
Write-Host "[*] Adding $AdminUser to SVR1 local Remote Management group..." -ForegroundColor Cyan
Add-LocalGroupMember -Group "Remote Management Users" -Member "$Domain\$AdminUser"

# 2. Ensure the WinRM listener is strictly listening on the correct interface
Write-Host "[*] Verifying WinRM Listener..." -ForegroundColor Cyan
winrm quickconfig -quiet

# 3. Explicitly set the WinRM SDDL (Security Descriptor) 
Write-Host "[*] Hardening WinRM Security Descriptor..." -ForegroundColor Cyan
winrm configSDDL default