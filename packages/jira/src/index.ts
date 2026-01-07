import { jiraAgent } from "./agent";

export { jiraAgent };

// CLI entry point for standalone usage
if (import.meta.main) {
  console.log("Jira agent ready");
  console.log("Agent:", jiraAgent.name);
  console.log("Description:", jiraAgent.description);
  console.log("\nMCP Config:");
  console.log(JSON.stringify(jiraAgent.mcpConfig, null, 2));
  console.log("\nSystem Prompt:");
  console.log(jiraAgent.systemPrompt);
}
