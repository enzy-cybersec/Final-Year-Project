
$ScriptPath = "\\VBOXSVR\vagrant\sharedscripts\ad\WRK01"

Write-Host "--- Starting 9-5 Enterprise Simulation: $(Get-Date) ---" -ForegroundColor White -BackgroundColor DarkBlue

# Start the Background Noise IMMEDIATELY (This runs forever)
Write-Host "[!] Starting Phase E: Periodic AD Heartbeat..." -ForegroundColor Magenta
Start-Job -FilePath "$ScriptPath\Background_Noise\Periodic_AD_Queries.ps1"

while($true) {
    $CurrentHour = (Get-Date).Hour

    # Logic: Only run active user scripts between 09:00 and 17:00
    if ($CurrentHour -ge 9 -and $CurrentHour -lt 17) {
        
        # LUNCH BREAK LOGIC: 12:00 to 13:00 (Reduced activity)
        if ($CurrentHour -eq 12) {
            Write-Host "Lunch hour detected. Reducing traffic volume..." -ForegroundColor Gray
            # Only run Web Requests (people browsing news at lunch)
            & "$ScriptPath\Work_Activity\Web_Requests.ps1"
            Start-Sleep -Seconds 600 # Long wait
        }
        else {
            Write-Host "[>] Standard Working Hours: Generating Active Traffic..." -ForegroundColor Green
            
            # Run the three main behaviour scripts in parallel
            $Job1 = Start-Job -FilePath "$ScriptPath\User_Behaviour\Interactive_Use.ps1"
            $Job2 = Start-Job -FilePath "$ScriptPath\Work_Activity\SMB_Usage.ps1"
            $Job3 = Start-Job -FilePath "$ScriptPath\Work_Activity\Web_Requests.ps1"

            Write-Host "[*] Interactive, SMB, and Web sessions are live." -ForegroundColor Cyan
            
            # Wait for the batch to finish before starting the next wave
            Wait-Job $Job1, $Job2, $Job3 | Out-Null
            Receive-Job $Job1, $Job2, $Job3 # This shows you the output in the console
            Remove-Job $Job1, $Job2, $Job3
            
            # Gap between "waves" of office work
            $Gap = Get-Random -Minimum 120 -Maximum 300
            Write-Host "[...] Wave complete. Next wave in $($Gap/60) minutes." -ForegroundColor Gray
            Start-Sleep -Seconds $Gap
        }
    }
    else {
        Write-Host "[Zzz] Outside of 9-5 hours. Only Background Noise is running." -ForegroundColor Yellow
        Start-Sleep -Seconds 600
    }
}