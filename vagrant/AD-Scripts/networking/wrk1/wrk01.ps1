param(
    [string]$LocalIP = "192.168.56.200",
    [string]$DCIP    = "192.168.56.10"
)

if (!$LocalIP) {
        $DCIP = "192.168.56.10"
        $LocalIP = "192.168.56.200"
}

$domainName  = "fyp.lab"
$joinUser    = "FYP\Administrator"
$joinPwd     = "P@ssw0rd123!" #same as the DC

$pwdSecure = ConvertTo-SecureString $joinPwd -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($joinUser, $pwdSecure)

Write-Host "Configuring static IP on WRS01..."
New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress $LocalIP -PrefixLength 24 -DefaultGateway $null -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses $DCIP

Write-Host "Joining WS01 to domain $domainName..."
Add-Computer -DomainName $domainName -Credential $cred -Force -Restart
