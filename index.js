import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { Camoufox } from "camoufox";
import fs from "fs/promises";
import path from "path";
import os from "os";

const server = new Server(
  {
    name: "camoufox-mcp-server",
    version: "2.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Active browser sessions storage
const sessions = new Map();

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "camoufox_navigate",
        description: "Open a URL using Camoufox anti-detect browser and return page text, title, and session ID for further actions.",
        inputSchema: {
          type: "object",
          properties: {
            url: { type: "string", description: "The URL to navigate to" },
            headless: { type: "boolean", description: "Run headless (default: true)" },
            proxy: { type: "string", description: "Optional proxy server (e.g. http://ip:port or socks5://ip:port)" },
            screenshot: { type: "boolean", description: "Take a screenshot (default: false)" }
          },
          required: ["url"],
        },
      },
      {
        name: "camoufox_click",
        description: "Click an element on the active page using a CSS selector.",
        inputSchema: {
          type: "object",
          properties: {
            sessionId: { type: "string", description: "Active session ID" },
            selector: { type: "string", description: "CSS selector to click" }
          },
          required: ["sessionId", "selector"],
        },
      },
      {
        name: "camoufox_type",
        description: "Type text into an input element using a CSS selector.",
        inputSchema: {
          type: "object",
          properties: {
            sessionId: { type: "string", description: "Active session ID" },
            selector: { type: "string", description: "CSS selector of the input" },
            text: { type: "string", description: "Text to type" }
          },
          required: ["sessionId", "selector", "text"],
        },
      },
      {
        name: "camoufox_eval",
        description: "Execute JavaScript code on the active page and return the result.",
        inputSchema: {
          type: "object",
          properties: {
            sessionId: { type: "string", description: "Active session ID" },
            script: { type: "string", description: "JavaScript code to execute" }
          },
          required: ["sessionId", "script"],
        },
      },
      {
        name: "camoufox_screenshot",
        description: "Take a screenshot of the active session page.",
        inputSchema: {
          type: "object",
          properties: {
            sessionId: { type: "string", description: "Active session ID" }
          },
          required: ["sessionId"],
        },
      },
      {
        name: "camoufox_close",
        description: "Close an active browser session and release resources.",
        inputSchema: {
          type: "object",
          properties: {
            sessionId: { type: "string", description: "Active session ID to close" }
          },
          required: ["sessionId"],
        },
      }
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === "camoufox_navigate") {
      const url = args.url;
      const headless = args.headless !== false;
      const proxy = args.proxy;
      const takeScreenshot = args.screenshot === true;

      const launchOpts = { headless };
      if (proxy) {
        launchOpts.proxy = { server: proxy };
      }

      const browser = await Camoufox(launchOpts);
      const page = await browser.newPage();
      
      await page.goto(url, { waitUntil: "networkidle", timeout: 45000 });
      
      const title = await page.title();
      const content = await page.evaluate(() => document.body.innerText);

      let screenshotPath = "";
      if (takeScreenshot) {
        const tempDir = path.join(os.tmpdir(), "opencode", "camoufox");
        await fs.mkdir(tempDir, { recursive: true });
        screenshotPath = path.join(tempDir, `screenshot-${Date.now()}.png`);
        await page.screenshot({ path: screenshotPath, fullPage: true });
      }

      const sessionId = `session_${Date.now()}`;
      sessions.set(sessionId, { browser, page });

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              success: true,
              sessionId,
              url,
              title,
              content: content.slice(0, 15000),
              screenshot: screenshotPath || null
            }, null, 2),
          },
        ],
      };
    }

    if (name === "camoufox_click") {
      const { sessionId, selector } = args;
      const session = sessions.get(sessionId);
      if (!session) throw new Error(`Session ${sessionId} not found.`);

      await session.page.click(selector, { timeout: 10000 });
      await session.page.waitForLoadState("networkidle", { timeout: 10000 }).catch(() => {});

      const content = await session.page.evaluate(() => document.body.innerText);

      return {
        content: [{ type: "text", text: JSON.stringify({ success: true, message: `Clicked ${selector}`, content: content.slice(0, 10000) }, null, 2) }]
      };
    }

    if (name === "camoufox_type") {
      const { sessionId, selector, text } = args;
      const session = sessions.get(sessionId);
      if (!session) throw new Error(`Session ${sessionId} not found.`);

      await session.page.fill(selector, text, { timeout: 10000 });

      return {
        content: [{ type: "text", text: JSON.stringify({ success: true, message: `Typed into ${selector}` }, null, 2) }]
      };
    }

    if (name === "camoufox_eval") {
      const { sessionId, script } = args;
      const session = sessions.get(sessionId);
      if (!session) throw new Error(`Session ${sessionId} not found.`);

      const result = await session.page.evaluate(script);

      return {
        content: [{ type: "text", text: JSON.stringify({ success: true, result }, null, 2) }]
      };
    }

    if (name === "camoufox_screenshot") {
      const { sessionId } = args;
      const session = sessions.get(sessionId);
      if (!session) throw new Error(`Session ${sessionId} not found.`);

      const tempDir = path.join(os.tmpdir(), "opencode", "camoufox");
      await fs.mkdir(tempDir, { recursive: true });
      const screenshotPath = path.join(tempDir, `screenshot-${Date.now()}.png`);
      await session.page.screenshot({ path: screenshotPath, fullPage: true });

      return {
        content: [{ type: "text", text: JSON.stringify({ success: true, screenshot: screenshotPath }, null, 2) }]
      };
    }

    if (name === "camoufox_close") {
      const { sessionId } = args;
      const session = sessions.get(sessionId);
      if (session) {
        await session.browser.close();
        sessions.delete(sessionId);
      }

      return {
        content: [{ type: "text", text: JSON.stringify({ success: true, message: `Session ${sessionId} closed.` }, null, 2) }]
      };
    }

    throw new Error(`Unknown tool: ${name}`);
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify({
            success: false,
            error: error.message,
          }, null, 2),
        },
      ],
      isError: true,
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
console.error("Powerful Camoufox MCP Server v2.0 running on stdio");
