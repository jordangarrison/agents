import { describe, expect, it } from "bun:test";
import { jiraAgent } from "./agent";

describe("jiraAgent", () => {
  it("should have correct name", () => {
    expect(jiraAgent.name).toBe("jira");
  });

  it("should have a description", () => {
    expect(jiraAgent.description).toBeTruthy();
    expect(jiraAgent.description).toContain("Jira");
  });

  it("should have MCP config for atlassian", () => {
    expect(jiraAgent.mcpConfig).toBeDefined();
    expect(jiraAgent.mcpConfig.atlassian).toBeDefined();
  });

  it("should have a system prompt with JQL guidance", () => {
    expect(jiraAgent.systemPrompt).toBeTruthy();
    expect(jiraAgent.systemPrompt).toContain("JQL");
  });

  it("should include issue type guidance", () => {
    expect(jiraAgent.systemPrompt).toContain("Epic");
    expect(jiraAgent.systemPrompt).toContain("Story");
    expect(jiraAgent.systemPrompt).toContain("Bug");
  });

  it("should include workflow guidance", () => {
    expect(jiraAgent.systemPrompt).toContain("transition");
  });
});
