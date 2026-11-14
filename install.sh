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
OPENCODE_CONFIG="$CONFIG_DIR/opencode.json"

echo "[*] Target directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Determine source directory (handle curl | bash remote execution)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/index.js" ]; then
    echo "[*] Downloading repository files from GitHub..."
    TEMP_DIR="$(mktemp -d)"
    curl -sL "https://github.com/arv-fazriansyah/Camoufox-MCP-Server/archive/refs/heads/main.zip" -o "$TEMP_DIR/main.zip"
    unzip -q "$TEMP_DIR/main.zip" -d "$TEMP_DIR"
    SCRIPT_DIR="$TEMP_DIR/Camoufox-MCP-Server-main"
fi

if [ ! -f "$SCRIPT_DIR/index.js" ]; then
    echo "[ERROR] Could not find index.js in source directory."
    exit 1
fi

echo "[*] Copying server files..."
cp "$SCRIPT_DIR/index.js" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/package.json" "$INSTALL_DIR/"

# Save configuration
echo "{\"headless\": $headless}" > "$INSTALL_DIR/config.json"

echo "[*] Installing Node dependencies..."
cd "$INSTALL_DIR"
npm install --production --prefer-offline > /dev/null 2>&1 || npm install --production

# Automatically register MCP server in opencode.json using node script
echo "[*] Registering Camoufox MCP Server in OpenCode config..."
node -e "
const fs = require('fs');
const path = require('path');
const configPath = process.argv[1];
const serverPath = process.argv[2];

let config = {};
try {
  config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
} catch (e) {}

if (!config.mcp) {
  config.mcp = {};
}

config.mcp['camoufox-mcp'] = {
  command: ['node', serverPath],
  enabled: true
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
" "$OPENCODE_CONFIG" "$INSTALL_DIR/index.js"

echo "[SUCCESS] Camoufox MCP Server installed and registered successfully!"
echo "[READY] Restart OpenCode to apply changes."
