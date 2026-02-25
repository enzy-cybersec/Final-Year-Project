
$Users = @(
    "a.khan", "b.moore", "c.taylor", "d.thomas", 
    "e.jones", "g.walker", "h.wilson",           
    "j.smith", "k.anderson", "l.brown",           
    "m.ali", "n.martin", "o.lee", "p.evans",     
    "r.miller", "s.sales1", "s.sales2", "t.dev"
)
$Pass = 'P@ssw0rd123!'
$DomainName = "fyp.lab"
$DC_Name = "DC01.$DomainName"

Write-Host "--- WRK01: Morning Logons ---" -ForegroundColor Cyan
# Login process per user.
foreach ($U in $Users) {
    Write-Host "[*] Resolving and Authenticating $U..." -ForegroundColor Yellow
    
    # Envolving DNS
    net use \\$DC_Name\IPC$ $Pass /USER:$U@$DomainName /persistent:no
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] $U authenticated." -ForegroundColor Green
        net use \\$DC_Name\IPC$ /delete /y >$null
    } else {
        Write-Warning "  [!] $U failed. Error: $LASTEXITCODE. Is the DC reachable by name?"
    }
    
    # Human-like delay
    Start-Sleep -Milliseconds (Get-Random -Minimum 500 -Maximum 1500)
}