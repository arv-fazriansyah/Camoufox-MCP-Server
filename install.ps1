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
$ConfigDir = Join-Path $env:USERPROFILE ".config\opencode"
$OpenCodeConfig = Join-Path $ConfigDir "opencode.json"

Write-Host "[*] Target directory: $InstallDir" -ForegroundColor Yellow

if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Write-Host "[+] Created installation directory." -ForegroundColor Green
}

# Determine source directory correctly when running via `irm ... | iex`
$SourceDir = $PSScriptRoot
if (!$SourceDir -or !(Test-Path (Join-Path $SourceDir "index.js"))) {
    $TempRepoDir = Join-Path $env:TEMP "camoufox-mcp-repo"
    if (Test-Path $TempRepoDir) {
        Remove-Item -Recurse -Force $TempRepoDir -ErrorAction SilentlyContinue
    }
    Write-Host "[*] Downloading repository files from GitHub..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $TempRepoDir | Out-Null
    
    $ZipPath = Join-Path $TempRepoDir "main.zip"
    Invoke-WebRequest -Uri "https://github.com/arv-fazriansyah/Camoufox-MCP-Server/archive/refs/heads/main.zip" -OutFile $ZipPath
    Expand-Archive -Path $ZipPath -DestinationPath $TempRepoDir -Force
    
    $SourceDir = Join-Path $TempRepoDir "Camoufox-MCP-Server-main"
}

if (!(Test-Path (Join-Path $SourceDir "index.js"))) {
    throw "Could not find index.js in source directory: $SourceDir"
}

Write-Host "[*] Copying server files from $SourceDir..." -ForegroundColor Yellow
Copy-Item (Join-Path $SourceDir "index.js") (Join-Path $InstallDir "index.js") -Force
Copy-Item (Join-Path $SourceDir "package.json") (Join-Path $InstallDir "package.json") -Force

# Save configuration
$Config = @{
    headless = $headless
} | ConvertTo-Json
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $InstallDir "config.json"), $Config, $Utf8NoBomEncoding)

Write-Host "[*] Installing Node dependencies..." -ForegroundColor Yellow
Set-Location $InstallDir
npm install --omit=dev --cache (Join-Path $env:TEMP "npm-cache") --prefer-offline | Out-Null

# Automatically register MCP server in opencode.json using correct OpenCode format
Write-Host "[*] Registering Camoufox MCP Server in OpenCode config..." -ForegroundColor Yellow
if (!(Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
}

$ServerPath = Join-Path $InstallDir "index.js"
$NodePath = (Get-Command node -ErrorAction SilentlyContinue).Source
if (!$NodePath) { $NodePath = "node" }

$NodeScript = @"
const fs = require('fs');
const configPath = process.argv[1];
const serverPath = process.argv[2];
const nodePath = process.argv[3];

let config = {};
try {
  const raw = fs.readFileSync(configPath, 'utf8').replace(/^\uFEFF/, '');
  if (raw.trim()) {
    config = JSON.parse(raw);
  }
} catch (e) {}

if (!config.mcp) {
  config.mcp = {};
}
if (!config.mcp.servers) {
  config.mcp.servers = {};
}

config.mcp.servers['camoufox-mcp'] = {
  type: 'local',
  command: [nodePath, serverPath]
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
"@

$TempNodeScript = Join-Path $env:TEMP "register_mcp.js"
[System.IO.File]::WriteAllText($TempNodeScript, $NodeScript, $Utf8NoBomEncoding)
node $TempNodeScript $OpenCodeConfig $ServerPath $NodePath
Remove-Item $TempNodeScript -Force -ErrorAction SilentlyContinue

Write-Host "[SUCCESS] Camoufox MCP Server installed successfully!" -ForegroundColor Green
Write-Host "[READY] MCP Server registered in OpenCode. Restart OpenCode to apply changes." -ForegroundColor Cyan
