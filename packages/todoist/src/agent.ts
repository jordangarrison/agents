/**
 * Todoist micro agent
 *
 * Single responsibility: Todoist task operations
 * Uses the official Doist/todoist-ai MCP server (hosted at https://ai.todoist.net/mcp)
 *
 * Setup:
 *   claude mcp add --transport http todoist https://ai.todoist.net/mcp
 *   Then run /mcp in Claude to authenticate
 *
 * TODO: Refine system prompt with specific GTD + Redeeming Your Time workflow
 */

export const todoistAgent = {
  name: "todoist",
  description: "Manages Todoist tasks and projects",

  /**
   * MCP server configuration for the Todoist agent
   * Uses the hosted Doist MCP server - authentication handled via OAuth
   */
  mcpConfig: {
    todoist: {
      transport: "http",
      url: "https://ai.todoist.net/mcp",
    },
  },

  /**
   * System prompt for the Todoist agent
   * TODO: Customize for GTD + Redeeming Your Time methodology
   */
  systemPrompt: `You are a Todoist task management agent.

Your capabilities:
- Find tasks by date using findTasksByDate
- Add tasks using addTasks
- Search and fetch tasks

Focus only on Todoist operations. For other systems (Jira, etc.), defer to the appropriate agent.
`,
};
