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
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "camoufox_fetch_page",
        description: "Open a URL using Camoufox anti-detect browser, extract text content or take a screenshot.",
        inputSchema: {
          type: "object",
          properties: {
            url: {
              type: "string",
              description: "The URL to navigate to",
            },
            screenshot: {
              type: "boolean",
              description: "Whether to take a screenshot (default: false)",
            },
          },
          required: ["url"],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "camoufox_fetch_page") {
    const url = args?.url;
    const takeScreenshot = args?.screenshot || false;

    if (!url) {
      throw new Error("URL is required");
    }

    let browser;
    try {
      browser = await Camoufox({ headless: true });
      const page = await browser.newPage();
      
      await page.goto(url, { waitUntil: "networkidle", timeout: 30000 });
      
      const title = await page.title();
      const content = await page.evaluate(() => document.body.innerText);

      let screenshotPath = "";
      if (takeScreenshot) {
        const tempDir = path.join(os.tmpdir(), "opencode", "camoufox");
        await fs.mkdir(tempDir, { recursive: true });
        screenshotPath = path.join(tempDir, `screenshot-${Date.now()}.png`);
        await page.screenshot({ path: screenshotPath, fullPage: true });
      }

      await browser.close();

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              success: true,
              url,
              title,
              content: content.slice(0, 10000),
              screenshot: screenshotPath || null,
            }, null, 2),
          },
        ],
      };
    } catch (error) {
      if (browser) {
        try { await browser.close(); } catch {}
      }
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
  }

  throw new Error(`Unknown tool: ${name}`);
});

const transport = new StdioServerTransport();
await server.connect(transport);
console.error("Camoufox MCP Server running on stdio");
