#!/usr/bin/env bash
# ==========================================
# Camoufox MCP Server - Unix Installer
# ==========================================
set -e

echo "=== Camoufox MCP Server Installer ==="

# Ask user if browser should be shown (Headed vs Headless)
read -p "Show the browser window on screen (Headed Mode)? [Y/N] " show_browser
headless=true
if [[ "$show_browser" == "y" || "$show_browser" == "Y" ]]; then
    headless=false
    echo "[*] Mode: Headed (the browser window will be visible)"
else
    echo "[*] Mode: Headless (runs in the background)"
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
npm install --omit=dev --prefer-offline > /dev/null 2>&1 || npm install --omit=dev

# Automatically register MCP server in opencode.json using environment variables
echo "[*] Registering Camoufox MCP Server in OpenCode config..."
export OPENCODE_CONFIG_PATH="$OPENCODE_CONFIG"
export CAMOUFOX_SERVER_PATH="$INSTALL_DIR/index.js"
export CAMOUFOX_NODE_PATH="$(command -v node || echo node)"

node -e "
const fs = require('fs');
const configPath = process.env.OPENCODE_CONFIG_PATH;
const serverPath = process.env.CAMOUFOX_SERVER_PATH;
const nodePath = process.env.CAMOUFOX_NODE_PATH;

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
  command: ['node', serverPath]
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
"

echo "[SUCCESS] Camoufox MCP Server installed and registered successfully!"
echo "[READY] Restart OpenCode to apply changes."
