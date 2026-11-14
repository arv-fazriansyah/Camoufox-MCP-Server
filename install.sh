#!/usr/bin/env bash
# ==========================================
# Camoufox MCP Server - Unix Installer
# ==========================================
set -e

echo "=== Camoufox MCP Server Installer ==="

# Ask user if browser should be shown (Headed vs Headless)
read -p "Apakah browser ingin ditampilkan di layar (Headed Mode)? [y/N] " show_browser
headless=true
if [[ "$show_browser" == "y" || "$show_browser" == "Y" ]]; then
    headless=false
    echo "[*] Mode: Headed (Browser akan terbuka di layar)"
else
    echo "[*] Mode: Headless (Berjalan di background)"
fi

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
INSTALL_DIR="$CONFIG_DIR/mcp-servers/camoufox-mcp"

echo "[*] Target directory: $INSTALL_DIR"

mkdir -p "$INSTALL_DIR"

# Copy files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/index.js" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/package.json" "$INSTALL_DIR/"

# Save configuration
echo "{\"headless\": $headless}" > "$INSTALL_DIR/config.json"

echo "[*] Installing Node dependencies..."
cd "$INSTALL_DIR"
npm install --production --prefer-offline > /dev/null 2>&1 || npm install --production

echo "[SUCCESS] Camoufox MCP Server installed successfully!"
echo "[READY] Configure OpenCode to point to: node $INSTALL_DIR/index.js"
