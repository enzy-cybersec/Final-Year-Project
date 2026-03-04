# Infrastructure Setup ---
Write-Host "Setting up AD Objects and Firewall..." -ForegroundColor Cyan

# Install tools if missing
Install-WindowsFeature RSAT-AD-PowerShell, Telnet-Client -ErrorAction SilentlyContinue

# Create the Service Account
$SecurePass = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
if (!(Get-ADUser -Filter "SamAccountName -eq 'svc-mail'")) {
    New-ADUser -Name "Svc-Mail" -SamAccountName "svc-mail" -UserPrincipalName "svc-mail@fyp.lab" -AccountPassword $SecurePass -Enabled $true
}

# Configure Firewall for SMTP and IMAP
$MailPorts = @(25, 587, 143, 993)
foreach ($Port in $MailPorts) {
    if (!(Get-NetFirewallRule -DisplayName "Enterprise-Mail-$Port" -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName "Enterprise-Mail-$Port" -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow
    }
}

# The Functional Listener
Write-Host "Starting SMTP Service Emulator on Port 25..." -ForegroundColor Green
Write-Host "SVR1 is now 'Active' and waiting for WRK1 traffic."

$SmtpListener = [System.Net.Sockets.TcpListener]25
$SmtpListener.Start()

try {
    while($true) {
        if ($SmtpListener.Pending()) {
            $Client = $SmtpListener.AcceptTcpClient()
            $RemoteIP = $Client.Client.RemoteEndPoint
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Connection accepted from $RemoteIP" -ForegroundColor Yellow
            
            # Send the RFC-Compliant SMTP Banner
            $Stream = $Client.GetStream()
            $Writer = New-Object System.IO.StreamWriter($Stream)
            $Writer.AutoFlush = $true
            $Writer.WriteLine("220 svr1.fyp.lab ESMTP Service Ready")
            
            # Close connection after banner to reset for the next '9-5' packet
            $Client.Close()
        }
        Start-Sleep -Milliseconds 100
    }
}
finally {
    $SmtpListener.Stop()
}