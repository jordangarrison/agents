/**
 * Shared types for agents
 */

export interface McpServerConfig {
  transport: string;
  url?: string;
}

export interface AgentConfig {
  name: string;
  description: string;
  mcpConfig: Record<string, McpServerConfig>;
  systemPrompt: string;
}
