#!/usr/bin/env bash
# ==========================================
# Camoufox MCP Server - Unix Uninstaller
# ==========================================
set -e

echo "=== Camoufox MCP Server Uninstaller ==="

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
INSTALL_DIR="$CONFIG_DIR/mcp-servers/camoufox-mcp"

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "[+] Removed Camoufox MCP server files."
else
    echo "[*] Camoufox MCP server not found or already removed."
fi

echo "[SUCCESS] Uninstallation complete."
