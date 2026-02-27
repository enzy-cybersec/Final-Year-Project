<#
B2: Machine_Auth.ps1
Target: WRK01
Purpose: Generate Kerberos machine authentication traffic (WRK01$).
#>

Write-Host "--- WRK01: Generating Machine Authentication Traffic ---" -ForegroundColor Cyan

# Purge existing tickets
# 0x3e7 is the SYSTEM session (the machine itself)
Write-Host "[*] Purging cached machine tickets..." -ForegroundColor Yellow
klist -li 0x3e7 purge | Out-Null

# Verify Secure Channel (Corrected Syntax)
Write-Host "[*] Verifying secure channel with DC01..." -ForegroundColor Yellow
$SecureChannel = Test-ComputerSecureChannel

# Refresh Machine Policy (Forces Kerberos traffic)
Write-Host "[*] Requesting new machine Kerberos tickets..." -ForegroundColor Yellow
gpupdate /target:computer /force | Out-Null

if ($SecureChannel) {
    Write-Host "[OK] Machine Authentication successful." -ForegroundColor Green
}