
$SVR = "SVR1.fyp.lab"
$Sites = @("www.google.com", "www.bbc.co.uk", "www.wikipedia.org", "www.microsoft.com")
$internals = @("HR", "IT", "Finance", "Sales")

$AllUsers = @(
    @{Name="a.khan"; Dept="IT"}, @{Name="j.smith"; Dept="IT"}, @{Name="m.ali"; Dept="IT"},
    @{Name="s.admin"; Dept="IT"}, @{Name="t.dev"; Dept="IT"},
    @{Name="c.taylor"; Dept="Finance"}, @{Name="p.evans"; Dept="Finance"}, @{Name="r.miller"; Dept="Finance"},
    @{Name="e.jones"; Dept="HR"}, @{Name="h.wilson"; Dept="HR"}, @{Name="l.brown"; Dept="HR"},
    @{Name="s.sales1"; Dept="Sales"}, @{Name="s.sales2"; Dept="Sales"}, @{Name="g.walker"; Dept="Sales"},
    @{Name="b.moore"; Dept="Finance"}, @{Name="d.thomas"; Dept="HR"}, @{Name="k.anderson"; Dept="Sales"},
    @{Name="n.martin"; Dept="Finance"}, @{Name="o.lee"; Dept="HR"}
)

Write-Host "--- Starting Web & DNS Activity (Target: SVR1) ---" -ForegroundColor White -BackgroundColor Cyan

# Shuffle users for realism
$RandomUsers = $AllUsers | Get-Random -Count $AllUsers.Count

foreach ($U in $RandomUsers) {
    $User = $U.Name
    
    # Random delay between users
    $Delay = Get-Random -Minimum 5 -Maximum 16
    Write-Host "[...] $User is opening their browser in $Delay seconds..." -ForegroundColor Gray
    Start-Sleep -Seconds $Delay

    Write-Host "[!] $User is active on the network..." -ForegroundColor Cyan

    # Simulate Intranet Access (HTTP to SVR1)
    Foreach ($i in $internals){
        Invoke-WebRequest -Uri "http://$SVR/$i" -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
        Write-Host "   [+] Successfully reached http://$SVR/$i" -ForegroundColor Green
    }

    # Simulate External Browsing (DNS + TCP Attempt)
    $TargetSite = $Sites | Get-Random
    Write-Host "   [+] DNS Lookup and connection attempt to $TargetSite..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "http://$TargetSite" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue | Out-Null
}

Write-Host "--- Web Activity Phase Complete ---" -ForegroundColor White -BackgroundColor Cyan