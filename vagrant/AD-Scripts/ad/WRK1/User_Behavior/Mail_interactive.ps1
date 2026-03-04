# --- WRK1: 9-5 Stochastic Traffic Engine ---
$TargetName = "SVR1.fyp.lab"

# ALL YOUR AD USERS
$UserList = @("a.khan", "b.moore", "c.taylor", "d.thomas", "e.jones", "finance01", "g.walker", "h.wilson", "j.smith", "k.anderson", "l.brown", "m.ali", "n.martin", "o.lee", "p.evans", "r.miller", "s.admin", "s.sales1", "s.sales2", "svc_backup", "svc_files", "svc_iis", "svc-mail", "t.dev")

Write-Host "--- 9-5 Enterprise Simulation Active ---" -ForegroundColor Cyan

while($true) {
    $Now = Get-Date
    
    # 1. THE 9-5 TIME GATE
    if ($Now.Hour -ge 9 -and $Now.Hour -lt 17) {
        
        # 2. PICK RANDOM USER
        $CurrentUser = $UserList | Get-Random
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Task initiated by $CurrentUser" -ForegroundColor Green

        try {
            # 3. DNS RESOLUTION (Port 53)
            $IPAddress = [System.Net.Dns]::GetHostAddresses($TargetName)[0].IPAddressToString
            
            # 4. SMTP TRANSACTION (Port 25)
            $TcpClient = New-Object System.Net.Sockets.TcpClient($IPAddress, 25)
            $Stream = $TcpClient.GetStream()
            $Writer = New-Object System.IO.StreamWriter($Stream)
            $Writer.AutoFlush = $true

            $Writer.WriteLine("HELO wrk1.fyp.lab")
            $Writer.WriteLine("MAIL FROM:<$CurrentUser@fyp.lab>")
            $Writer.WriteLine("QUIT")

            $TcpClient.Close()
            Write-Host "   > Success: Packet routed via Switch to SVR1." -ForegroundColor Gray
        }
        catch {
            Write-Host "   > [!] Error: Target SVR1 unreachable." -ForegroundColor Red
        }

        # 5. RANDOMIZED DELAY (The 'Human' Element)
        # Random wait between 30 seconds and 5 minutes
        $Delay = Get-Random -Minimum 30 -Maximum 300
        Write-Host "Next activity in $Delay seconds..."
    } 
    else {
        # OUTSIDE OFFICE HOURS
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Outside 9-5 hours. Simulation Idling..." -ForegroundColor Yellow
        Start-Sleep -Seconds 600 # Check again in 10 minutes
        continue
    }

    Start-Sleep -Seconds $Delay
}