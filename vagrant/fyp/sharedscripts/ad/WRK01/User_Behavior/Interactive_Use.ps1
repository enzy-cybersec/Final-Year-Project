
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

# Use an infinite loop to keep gathering packets for your model
while($true) {
    Write-Host "--- Starting Shift Rotation: $(Get-Date) ---" -ForegroundColor White -BackgroundColor Blue

    # Shuffle the users so they don't always log in in the same order (Realistic!)
    $ShuffledUsers = $AllUsers | Get-Random -Count $AllUsers.Count

    foreach ($U in $ShuffledUsers) {
        $User = $U.Name
        $Dept = $U.Dept
        
        Write-Host "[*] $User ($Dept) is active..." -ForegroundColor Yellow
        
        net use P: \\$SVR\Public $Pass /USER:$User@fyp.lab /persistent:no >$null
        
        if ($LASTEXITCODE -eq 0) {
            $TargetFolders = if ($Dept -eq "IT") { @("Finance", "HR", "IT", "Sales") } else { @($Dept, "Sales") }

            foreach ($Folder in $TargetFolders) {
                $FullPath = "P:\$Folder"
                if (Test-Path $FullPath) {
                    $Files = Get-ChildItem -Path $FullPath -Recurse | Select-Object -First 10
                    foreach ($File in $Files) {
                        if (-not $File.PSIsContainer) {
                            Get-Content $File.FullName -ErrorAction SilentlyContinue | Out-Null
                        }
                    }
                }
            }
            net use P: /delete /y >$null
        }

        # REALISM: Wait between 2 to 10 seconds before the next user logs in
        $Wait = Get-Random -Minimum 2 -Maximum 11
        Start-Sleep -Seconds $Wait
    }
    
    Write-Host "--- Rotation Finished. Resting for 30 seconds before next shift ---" -ForegroundColor Gray
    Start-Sleep -Seconds 30
}