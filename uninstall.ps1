# ==========================================
# Camoufox MCP Server - Windows Uninstaller
# ==========================================
$ErrorActionPreference = "Stop"

Write-Host "=== Camoufox MCP Server Uninstaller ===" -ForegroundColor Cyan

$InstallDir = Join-Path $env:USERPROFILE ".config\opencode\mcp-servers\camoufox-mcp"

if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
    Write-Host "[+] Removed Camoufox MCP server files." -ForegroundColor Green
} else {
    Write-Host "[*] Camoufox MCP server not found or already removed." -ForegroundColor Yellow
}

Write-Host "[SUCCESS] Uninstallation complete." -ForegroundColor Green
