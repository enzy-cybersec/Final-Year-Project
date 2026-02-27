
$SVR = "SVR1.fyp.lab"
$Pass = 'P@ssw0rd123!'

$AllUsers = @(
    @{Name="a.khan"; Dept="IT"}, @{Name="j.smith"; Dept="IT"}, @{Name="m.ali"; Dept="IT"},
    @{Name="s.admin"; Dept="IT"}, @{Name="t.dev"; Dept="IT"},
    @{Name="c.taylor"; Dept="Finance"}, @{Name="p.evans"; Dept="Finance"}, @{Name="r.miller"; Dept="Finance"},
    @{Name="e.jones"; Dept="HR"}, @{Name="h.wilson"; Dept="HR"}, @{Name="l.brown"; Dept="HR"},
    @{Name="s.sales1"; Dept="Sales"}, @{Name="s.sales2"; Dept="Sales"}, @{Name="g.walker"; Dept="Sales"},
    @{Name="b.moore"; Dept="Finance"}, @{Name="d.thomas"; Dept="HR"}, @{Name="k.anderson"; Dept="Sales"},
    @{Name="n.martin"; Dept="Finance"}, @{Name="o.lee"; Dept="HR"}
)

Write-Host "--- Starting Realistic SMB Workday Simulation ---" -ForegroundColor White -BackgroundColor DarkGreen

# Shuffle users so they don't start in the same order
$RandomUsers = $AllUsers | Get-Random -Count $AllUsers.Count

foreach ($U in $RandomUsers) {
    $User = $U.Name
    $Dept = $U.Dept
    
    # RANDOM DELAY: Wait between 10 to 60 seconds before the next user starts
    # This creates the 'Human Jitter' needed for realistic model training.
    $Delay = Get-Random -Minimum 10 -Maximum 61
    Write-Host "[...] Waiting $Delay seconds for next user..." -ForegroundColor Gray
    Start-Sleep -Seconds $Delay

    Write-Host "[!] $User ($Dept) has started a file task." -ForegroundColor Yellow
    
    net use W: \\$SVR\Public $Pass /USER:$User@fyp.lab /persistent:no >$null
    
    if ($LASTEXITCODE -eq 0) {
        $WorkPath = "W:\$Dept"
        if (Test-Path $WorkPath) {
            $FileName = "Memo_$($User)_$(Get-Random).txt"
            "Official Memo content..." | Out-File "$WorkPath\$FileName"
            
            # Simulate 'Thinking' time (User typing)
            Start-Sleep -Seconds (Get-Random -Minimum 2 -Maximum 5)
            
            "Additional update to memo." | Out-File "$WorkPath\$FileName" -Append
            Rename-Item -Path "$WorkPath\$FileName" -NewName "Final_$FileName"
            
            Write-Host "   [OK] $User completed their task." -ForegroundColor Green
        }
        net use W: /delete /y >$null
    }
}

Write-Host "--- Workday Batch Complete ---" -ForegroundColor White -BackgroundColor DarkGreen