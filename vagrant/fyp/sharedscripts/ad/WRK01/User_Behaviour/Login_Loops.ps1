
$Users = @(
    "a.khan", "b.moore", "c.taylor", "d.thomas", 
    "e.jones", "g.walker", "h.wilson",           
    "j.smith", "k.anderson", "l.brown",           
    "m.ali", "n.martin", "o.lee", "p.evans",     
    "r.miller", "s.sales1", "s.sales2", "t.dev"
)
$Servers = @("DC01.fyp.lab", "SVR1.fyp.lab") # The "targets" for mobility
$Pass = 'P@ssw0rd123!'

Write-Host "--- WRK01: 9-5 Mobility and Re-auth Loop Active ---" -ForegroundColor Cyan

while($true) {
    $U = $Users | Get-Random
    $S = $Servers | Get-Random
    
    Write-Host "[( $(Get-Date -Format HH:mm:ss) )] $U is re-authenticating to access $S..." -ForegroundColor Yellow
    
    # Simulate 'moving' to a new resource
    net use \\$S\IPC$ $Pass /USER:$U@fyp.lab /persistent:no >$null 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Kerberos Ticket (TGS) issued for $S." -ForegroundColor Green
        # Hold the session for a few seconds (simulating a quick task)
        Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 15)
        net use \\$S\IPC$ /delete /y >$null 2>&1
    }

    # The "Away from Desk" Delay
    # This simulates the user being 'idle' or away before the next person does something.
    $IdleTime = Get-Random -Minimum 45 -Maximum 120
    Write-Host "[*] Network idle. Next activity in $IdleTime seconds..." -ForegroundColor Gray
    Start-Sleep -Seconds $IdleTime
}