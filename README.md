# Camoufox MCP Server (v2.0 - Powerful & Feature-Rich)

> A Model Context Protocol (MCP) server for OpenCode powered by Camoufox anti-detect browser with interactive automation capabilities.

## ✨ Powerful Features
- **Anti-Detect Browsing**: Bypass Cloudflare, Akamai, and advanced anti-bot protections seamlessly.
- **Session Management**: Maintain state across multi-step interactions using session IDs.
- **Interactive Automation**:
  - `camoufox_navigate`: Open URL with optional proxy and headless configuration.
  - `camoufox_click`: Click buttons or elements by CSS selector.
  - `camoufox_type`: Fill input fields and forms.
  - `camoufox_eval`: Execute custom JavaScript in the page context.
  - `camoufox_screenshot`: Capture full-page snapshots on demand.
  - `camoufox_close`: Terminate active browser sessions cleanly.

---

## 🚀 Quick Install

### Windows (PowerShell)
```powershell
iex (iwr -useb https://raw.githubusercontent.com/arv-fazriansyah/Camoufox-MCP-Server/main/install.ps1).Content
```

### Linux / macOS (Bash)
```bash
curl -fsSL https://raw.githubusercontent.com/arv-fazriansyah/Camoufox-MCP-Server/main/install.sh | bash
```

---

## License
MIT
