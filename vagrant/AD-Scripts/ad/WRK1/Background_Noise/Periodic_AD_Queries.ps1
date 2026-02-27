
$DC = "DC01.fyp.lab"

Write-Host "--- Starting AD Background Noise Simulation ---" -ForegroundColor White -BackgroundColor Magenta

# This loop runs periodically to simulate background system tasks
while($true) {
    Write-Host "[*] Sending periodic AD synchronization queries..." -ForegroundColor Gray
    
    # DNS Service Discovery (SRV records)
    nslookup -type=srv _kerberos._tcp.fyp.lab >$null
    nslookup -type=srv _ldap._tcp.fyp.lab >$null

    # Time Synchronization (NTP)
    w32tm /query /status >$null
    
    # Group Policy Check (GPUpdate)
    gpupdate /force /target:computer >$null
    
    # Netlogon/NetBIOS Noise
    nbtstat -A $DC >$null
    
    Write-Host "   [+] Heartbeat complete. Sleeping for 5 minutes..." -ForegroundColor Green
    Start-Sleep -Seconds 300
}