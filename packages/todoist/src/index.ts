import { todoistAgent } from "./agent";

export { todoistAgent };

// CLI entry point
if (import.meta.main) {
  console.log("Todoist agent ready");
  console.log("Agent:", todoistAgent.name);
  console.log("Description:", todoistAgent.description);
  console.log("\nMCP Config:");
  console.log(JSON.stringify(todoistAgent.mcpConfig, null, 2));
  console.log("\nSystem Prompt:");
  console.log(todoistAgent.systemPrompt);
}
