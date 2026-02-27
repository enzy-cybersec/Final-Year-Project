
$ScriptPath = "\\VBOXSVR\vagrant\sharedscripts\ad\WRK01\Background_Noise"

Write-Host "--- Launching 24/7 System Background Noise ---" -ForegroundColor Black -BackgroundColor Gray

$SystemTasks = @(
    "GPO_Refresh.ps1",
    "Machine_Auth.ps1",
    "Periodic_AD_Queries.ps1"
)

foreach ($Script in $SystemTasks) {
    Write-Host "[+] Initialising $Script..." -ForegroundColor Cyan
    Start-Job -FilePath "$ScriptPath\$Script"
}

Write-Host "--- System Noise is now running in the background. ---" -ForegroundColor Green
Write-Host "Use 'Get-Job' to monitor or 'Stop-Job' to terminate." -ForegroundColor Yellow