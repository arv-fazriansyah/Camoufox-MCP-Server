# ==========================================
# Camoufox MCP Server - Windows Installer
# ==========================================
$ErrorActionPreference = "Stop"

Write-Host "=== Camoufox MCP Server Installer ===" -ForegroundColor Cyan

# Ask user if browser should be shown (Headed vs Headless)
$showBrowser = Read-Host "Apakah browser ingin ditampilkan di layar (Headed Mode)? [y/N]"
$headless = $true
if ($showBrowser -eq 'y' -or $showBrowser -eq 'Y') {
    $headless = $false
    Write-Host "[*] Mode: Headed (Browser akan terbuka di layar)" -ForegroundColor Green
} else {
    Write-Host "[*] Mode: Headless (Berjalan di background)" -ForegroundColor Yellow
}

$InstallDir = Join-Path $env:USERPROFILE ".config\opencode\mcp-servers\camoufox-mcp"
Write-Host "[*] Target directory: $InstallDir" -ForegroundColor Yellow

if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Write-Host "[+] Created installation directory." -ForegroundColor Green
}

# Copy files
$SourceDir = $PSScriptRoot
if (!$SourceDir) {
    $SourceDir = Get-Location
}

Write-Host "[*] Copying server files..." -ForegroundColor Yellow
Copy-Item (Join-Path $SourceDir "index.js") (Join-Path $InstallDir "index.js") -Force
Copy-Item (Join-Path $SourceDir "package.json") (Join-Path $InstallDir "package.json") -Force

# Save configuration
$Config = @{
    headless = $headless
} | ConvertTo-Json
Set-Content -Path (Join-Path $InstallDir "config.json") -Value $Config

Write-Host "[*] Installing Node dependencies..." -ForegroundColor Yellow
Set-Location $InstallDir
npm install --production --cache (Join-Path $env:TEMP "npm-cache") --prefer-offline | Out-Null

Write-Host "[SUCCESS] Camoufox MCP Server installed successfully!" -ForegroundColor Green
Write-Host "[READY] Configure OpenCode to point to: node $InstallDir\index.js" -ForegroundColor Cyan
