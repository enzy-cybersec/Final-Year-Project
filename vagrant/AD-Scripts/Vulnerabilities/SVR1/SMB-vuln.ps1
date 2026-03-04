# Create the 'Public_Exchange' folder
$Path = "C:\Public_Exchange"
New-Item -Path $Path -ItemType Directory -Force

# Grant 'Full Control' to Everyone
$Acl = Get-Acl $Path
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","Allow")
$Acl.SetAccessRule($Ar)
Set-Acl $Path $Acl

# Create the SMB Share with 'Guest' access allowed
New-SmbShare -Name "Exchange" -Path $Path -FullAccess "Everyone"
Write-Host "VULNERABILITY ACTIVE: SVR1 now allows anonymous uploads to \\SVR1\Exchange" -ForegroundColor Red

# Allow Insecure Guest Logons
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "AllowInsecureGuestAuth" -Value 1

# Specifically allow the 'Guest' account to access the share
net user guest /active:yes
net user guest "" 

# Re-verify the share allows Guest
Set-SmbShare -Name "Exchange" -FullAccess "Everyone", "Guest", "ANONYMOUS LOGON"

#Add the share folder to the Defender Exclusion list
Add-MpPreference -ExclusionPath "C:\Exchange"
# Disable "Automatic Remediation" so it only alerts 
Set-MpPreference -DisableRoutinelyTakingAction $true