
Write-Host "--- WRK01: Triggering Group Policy Refresh ---" -ForegroundColor Cyan

# Force the update (This creates the NIDS traffic)
gpupdate /force

Write-Host "`n[*] Verifying last GP update time..." -ForegroundColor Gray

# Use 'gpresult' which is built into every Windows machine
$LastUpdate = gpresult /r | Select-String "Last time policy was applied"

if ($LastUpdate) {
    Write-Host "[OK] $LastUpdate" -ForegroundColor Green
    Write-Host "[OK] Traffic successfully generated to DC01." -ForegroundColor Green
}