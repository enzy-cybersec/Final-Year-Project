$TargetMachines = "SVR1" #, "WRK1"

Invoke-Command -ComputerName $TargetMachines -ScriptBlock {
    Write-Host "Resetting Evaluation Timer on $env:COMPUTERNAME..." -ForegroundColor Green
    & slmgr.vbs /rearm
    Restart-Computer -Force
}