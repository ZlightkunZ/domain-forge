<#
.SYNOPSIS
Automates the installation and configuration of Sysmon across the Active Directory lab using the SwiftOnSecurity baseline.

.DESCRIPTION
This script checks for Administrative privileges, downloads the latest Sysmon binary from Microsoft, 
downloads the highly-regarded SwiftOnSecurity configuration XML, and silently installs/updates the service.

.NOTES
Author: ZlightkunZ
Target: Windows 10/11 Endpoints and Windows Server 2022 (Domain Controllers)
#>

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator."
    exit
}

$SysmonZip = "$env:TEMP\Sysmon.zip"
$SysmonFolder = "$env:TEMP\Sysmon"
$ConfigFile = "$env:TEMP\sysmonconfig-export.xml"

Write-Host "[*] Downloading Sysmon from Microsoft Sysinternals..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile $SysmonZip

Write-Host "[*] Extracting Sysmon..." -ForegroundColor Cyan
Expand-Archive -Path $SysmonZip -DestinationPath $SysmonFolder -Force

Write-Host "[*] Downloading SwiftOnSecurity Baseline Configuration..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile $ConfigFile

Write-Host "[*] Installing/Updating Sysmon with Configuration..." -ForegroundColor Cyan
# Determine architecture
if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $ExePath = Join-Path $SysmonFolder "Sysmon64.exe"
} else {
    $ExePath = Join-Path $SysmonFolder "Sysmon.exe"
}

# Install silently, accept EULA, apply config
Start-Process -FilePath $ExePath -ArgumentList "-accepteula -i $ConfigFile" -Wait -NoNewWindow

Write-Host "[+] Sysmon installation complete. Service is running." -ForegroundColor Green
Write-Host "[+] Telemetry is now logging to Microsoft-Windows-Sysmon/Operational." -ForegroundColor Green

# Cleanup
Remove-Item -Path $SysmonZip -Force
Remove-Item -Path $SysmonFolder -Recurse -Force
Remove-Item -Path $ConfigFile -Force
