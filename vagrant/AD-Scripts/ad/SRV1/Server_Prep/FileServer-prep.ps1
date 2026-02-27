# Import AD modules
Import-Module ActiveDirectory

# Configuration Variables
$BasePath = "C:\Shares"
$Departments = @("HR","IT","Finance","Sales")
$Domain = "FYP" # Ensure this matches your NetBIOS name

# Ensure the base storage path exists
try {
    if (!(Test-Path $BasePath)) {
        New-Item -Path $BasePath -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host "[+] Created base path: $BasePath" -ForegroundColor Green
    }
} catch {
    Write-Error "CRITICAL: Could not create $BasePath. Check disk permissions."
    exit
}

# Iterate through departments to build shares
foreach ($dept in $Departments) {
foreach ($dept in $Departments) {
    $Folder = Join-Path $BasePath $dept
    $ShareName = "$dept`_Data"

    Write-Host "`n[Matching Group for: $dept]" -ForegroundColor Yellow

    # Dynamic Matching: Try -Users, _Staff, or -Admins
    $ADGroup = Get-ADGroup -Filter "SamAccountName -like '$dept*'" | 
               Sort-Object { $_.SamAccountName -like "*-Users" }, { $_.SamAccountName -like "*_Staff" } -Descending | 
               Select-Object -First 1

    if ($null -eq $ADGroup) {
        Write-Warning "  [!] No group found for $dept. Skipping."
        continue
    }

    $TargetGroup = "$Domain\$($ADGroup.SamAccountName)"
    Write-Host "  [OK] Using Group: $TargetGroup" -ForegroundColor Cyan

    # Folder Creation
    if (!(Test-Path $Folder)) { New-Item $Folder -ItemType Directory -Force | Out-Null }

    # SMB Share
    if (!(Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $ShareName -Path $Folder -FullAccess $TargetGroup -ReadAccess "Everyone"
        Write-Host "  [OK] Share '$ShareName' Created." -ForegroundColor Green
    }

    # NTFS Permissions
    $acl = Get-Acl $Folder
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($TargetGroup, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl $Folder $acl
    Write-Host "  [OK] ACL applied for $TargetGroup." -ForegroundColor Gray
}

Write-Host "`n[!] Phase F1: File Server preparation complete." -ForegroundColor Cyan

# Test Directory Replication/AD Connectivity
Write-Host "`n[Testing AD Integration]" -ForegroundColor Yellow
try {
    $DomainCheck = Get-ADDomain -ErrorAction Stop
    Write-Host "  [OK] Connected to Domain: $($DomainCheck.DNSRoot)" -ForegroundColor Green
} catch {
    Write-Error "  [FAIL] SVR01 cannot communicate with the Domain Controller."
}
