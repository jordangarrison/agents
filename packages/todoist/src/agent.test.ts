import { describe, expect, test } from "bun:test";
import { todoistAgent } from "./agent";

describe("todoistAgent", () => {
  test("has required properties", () => {
    expect(todoistAgent.name).toBe("todoist");
    expect(todoistAgent.description).toBeDefined();
    expect(todoistAgent.mcpConfig).toBeDefined();
    expect(todoistAgent.systemPrompt).toBeDefined();
  });

  describe("mcpConfig", () => {
    test("uses hosted Doist MCP server", () => {
      expect(todoistAgent.mcpConfig.todoist.transport).toBe("http");
      expect(todoistAgent.mcpConfig.todoist.url).toBe(
        "https://ai.todoist.net/mcp"
      );
    });
  });

  describe("systemPrompt", () => {
    test("mentions Todoist capabilities", () => {
      expect(todoistAgent.systemPrompt).toContain("Todoist");
      expect(todoistAgent.systemPrompt).toContain("findTasksByDate");
      expect(todoistAgent.systemPrompt).toContain("addTasks");
    });

    test("defines single responsibility boundary", () => {
      expect(todoistAgent.systemPrompt).toContain(
        "Focus only on Todoist operations"
      );
    });
  });
});
