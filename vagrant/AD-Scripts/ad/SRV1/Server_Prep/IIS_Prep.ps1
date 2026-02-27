# Import WebAdmin module
Import-Module WebAdministration

# Configuration
$VagrantSource = "\\VBOXSVR\vagrant\sharedscripts\ad\SRV01\Server_Prep\WebServer-dependencies"
$LocalWebRoot  = "C:\inetpub\wwwroot"
$Departments   = @("HR","IT","Finance","Sales")

Write-Host "--- SVR01: Provisioning IIS Infrastructure ---" -ForegroundColor Cyan

# Create Infrastructure
# Ensure IIS is installed first to create the C:\inetpub folder
if (!(Get-WindowsFeature Web-Server).Installed) {
    Write-Host "[*] Installing IIS Role..." -ForegroundColor Gray
    Install-WindowsFeature Web-Server -IncludeManagementTools | Out-Null
}

# Create departmental sub-folders in Web Root
foreach ($dept in $Departments) {
    $Path = Join-Path $LocalWebRoot $dept
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Host "  [+] Created Folder: $Path" -ForegroundColor Gray
    }
}

# Content Deployment
Write-Host "`n--- Importing Files from Vagrant Share ---" -ForegroundColor Yellow

# Copy Main Portal
if (Test-Path "$VagrantSource\index.html") {
    Copy-Item -Path "$VagrantSource\index.html" -Destination "$LocalWebRoot\index.html" -Force
    Write-Host "  [OK] Main portal file imported." -ForegroundColor Green
}

# Copy and Customise Departmental Templates
foreach ($dept in $Departments) {
    $DestPath = "$LocalWebRoot\$dept\index.html"
    
    if (Test-Path "$VagrantSource\dept_template.html") {
        # Import template, replace placeholder, and save to local web root
        $TemplateContent = Get-Content "$VagrantSource\dept_template.html"
        $TemplateContent = $TemplateContent -replace "Secure Departmental Area", "$dept Secure Area"
        Set-Content -Path $DestPath -Value $TemplateContent
        Write-Host "  [OK] Deployed $dept site content." -ForegroundColor Green
    }
}

# IIS Configuration
Write-Host "`n--- Finalizing IIS Configuration ---" -ForegroundColor Yellow

foreach ($dept in $Departments) {
    if (!(Get-WebVirtualDirectory -Site "Default Web Site" -Name $dept -ErrorAction SilentlyContinue)) {
        New-WebVirtualDirectory -Site "Default Web Site" -Name $dept -PhysicalPath "$LocalWebRoot\$dept" | Out-Null
        Write-Host "  [OK] IIS Virtual Directory /$dept is now active." -ForegroundColor Cyan
    }
}

# Restart to apply all changes
Restart-Service W3SVC
Write-Host "`nPhase F2 Success: Web Server Infrastructure is Live." -ForegroundColor Cyan

# Varification
Write-Host "--- Testing Local Web Endpoints ---" -ForegroundColor Yellow

$Endpoints = @("http://localhost/index.html", "http://localhost/HR/", "http://localhost/IT/")

foreach ($url in $Endpoints) {
    try {
        $Response = Invoke-WebRequest -Uri $url -UseBasicParsing
        Write-Host "[OK] $url returned $($Response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Warning "[FAIL] $url is unreachable."
    }
}