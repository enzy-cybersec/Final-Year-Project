param(
    [string]$DCIP = "192.168.56.10"
)

if (!$DCIP) {
	$DCIP = "192.168.56.10"
}

$domainName      = "fyp.lab"
$netbiosName     = "FYP"
$safeModePwdPlain = "P@ssw0rd123!!"
$adminPwdPlain    = "P@ssw0rd123!"

$plainToSecure = {
    param($s)
    $ss = ConvertTo-SecureString $s -AsPlainText -Force
    return $ss
}

Write-Host "Setting static IP & DNS on DC01..."

New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress $DCIP -PrefixLength 24 -DefaultGateway $null -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses $DCIP

Write-Host "Installing AD-Domain-Services & DNS..."
Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools

#changing the admin user pass manually (it is just needed)
net user Administrator $adminPwdPlain

$smPwd   = & $plainToSecure $safeModePwdPlain
$adminPwd = & $plainToSecure $adminPwdPlain

net user Administrator $safeModePwdPlain

Write-Host "Promoting server to new forest: $domainName..."

Install-ADDSForest `
    -DomainName $domainName `
    -DomainNetbiosName $netbiosName `
    -SafeModeAdministratorPassword $smPwd `
    -InstallDns `
    -Force
