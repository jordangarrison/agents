/**
 * Shared types for agents
 */

export interface AgentResult<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
}

export interface AgentConfig {
  name: string;
  description: string;
}
