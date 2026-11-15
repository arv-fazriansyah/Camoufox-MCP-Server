# Camoufox MCP Server 🦊🛡️

[![GitHub Release](https://img.shields.io/github/v/release/arv-fazriansyah/Camoufox-MCP-Server?include_prereleases&style=flat-square)](https://github.com/arv-fazriansyah/Camoufox-MCP-Server/releases)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)
[![Model Context Protocol](https://img.shields.io/badge/MCP-Standard-blue.svg)](https://modelcontextprotocol.io)

**Camoufox MCP Server** is a powerful, production-ready **Model Context Protocol (MCP)** server powered by **Camoufox**—the privacy-hardened, anti-detect browser built on Firefox. 

Designed for AI agents and LLMs (OpenCode, Claude Desktop, Cursor, and any MCP-compatible client), this server enables automated web navigation, scraping, interaction, and testing without triggering bot protections or reCAPTCHAs.

---

## ✨ Key Features

- **Anti-Detect by Design**: Leverages Camoufox's C++ level fingerprint injection, zero JS trace overrides, and realistic device coherence (navigator, WebGL, fonts, audio, WebRTC).
- **Universal AI Agent Support**: Compliant with the standard Model Context Protocol (`stdio` transport) making it plug-and-play for OpenCode, Claude Desktop, and other AI systems.
- **Advanced Control Options**:
  - **GeoIP Synchronization**: Automatically match timezone, locale, geolocation, and WebRTC IP with proxy exit nodes (`geoip=true`).
  - **Canvas & Graphics Noise**: Protect identity across operating systems with configurable noise levels (`canvas_noise`).
  - **Target OS Spoofing**: Mimic Windows, macOS, or Linux device profiles (`os`).
- **Interactive Headless / Headed Modes**: Choose during installation whether the browser runs invisibly in the background or pops up on your screen.
- **Session Management**: Persistent multi-step sessions supporting navigation, CSS-based clicking, natural typing, JS evaluation, and automated screenshots.

---

## 🚀 Quick Installation

### Windows (PowerShell)
Run the automated installer in your PowerShell terminal:
```powershell
irm https://raw.githubusercontent.com/arv-fazriansyah/Camoufox-MCP-Server/main/install.ps1 | iex
```
*(During installation, you will be prompted: `Show the browser window on screen (Headed Mode)? [y/N]`)*

### Unix / Linux / macOS (Bash)
Run the automated installer in your terminal:
```bash
curl -sSL https://raw.githubusercontent.com/arv-fazriansyah/Camoufox-MCP-Server/main/install.sh | bash
```

---

## ⚙️ MCP Client Configuration

To connect the Camoufox MCP Server to your AI Agent or MCP client (such as OpenCode or Claude Desktop), add the following entry to your MCP configuration file:

### Windows (PowerShell / Command Prompt)
```json
{
  "mcpServers": {
    "camoufox-mcp": {
      "command": "node",
      "args": [
        "C:/Users/%USERNAME%/.config/opencode/mcp-servers/camoufox-mcp/index.js"
      ]
    }
  }
}
```

### macOS / Linux / Unix
```json
{
  "mcpServers": {
    "camoufox-mcp": {
      "command": "node",
      "args": [
        "~/.config/opencode/mcp-servers/camoufox-mcp/index.js"
      ]
    }
  }
}
```

---

## 🛠️ Available MCP Tools

Once connected, your AI agent has access to the following tools:

1. **`camoufox_navigate`**
   - **Description**: Open a URL using Camoufox anti-detect browser.
   - **Parameters**: 
     - `url` (string, required): The target web address.
     - `headless` (boolean): Run in background or show browser.
     - `proxy` (string): Optional proxy (`http://ip:port` or `socks5://ip:port`).
     - `geoip` (boolean): Sync time/locale/WebRTC with proxy IP.
     - `canvas_noise` (boolean): Enable canvas readback protection.
     - `os` (string): Target OS fingerprint (`windows`, `macos`, `linux`).
     - `screenshot` (boolean): Take a screenshot immediately.

2. **`camoufox_click`**
   - **Description**: Click an element on the active page using a CSS selector.
   - **Parameters**: `sessionId` (string), `selector` (string).

3. **`camoufox_type`**
   - **Description**: Type text naturally into an input element.
   - **Parameters**: `sessionId` (string), `selector` (string), `text` (string).

4. **`camoufox_eval`**
   - **Description**: Execute custom JavaScript code on the active page and return results.
   - **Parameters**: `sessionId` (string), `script` (string).

5. **`camoufox_screenshot`**
   - **Description**: Capture a full-page screenshot of the current session.
   - **Parameters**: `sessionId` (string).

6. **`camoufox_close`**
   - **Description**: Safely close an active browser session and release resources.
   - **Parameters**: `sessionId` (string).

---

## 🗑️ Uninstallation

If you wish to remove the server:
- **Windows**: Run `uninstall.ps1` from the repository.
- **Unix**: Run `uninstall.sh` from the repository.

---

## 📜 License

Distributed under the **MPL-2.0 License**. See [LICENSE](LICENSE) for more information.

---
*Built with ❤️ for AI Agents and Autonomous Web Automation.*
