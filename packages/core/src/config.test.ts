import { describe, expect, test, beforeEach, afterEach } from "bun:test";
import { loadEnv, requireEnv } from "./config";

describe("config", () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = { ...originalEnv };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  describe("loadEnv", () => {
    test("returns empty object when no env vars set", () => {
      delete process.env.TODOIST_API_TOKEN;
      delete process.env.ANTHROPIC_API_KEY;

      const env = loadEnv();

      expect(env.TODOIST_API_TOKEN).toBeUndefined();
      expect(env.ANTHROPIC_API_KEY).toBeUndefined();
    });

    test("returns env vars when set", () => {
      process.env.TODOIST_API_TOKEN = "test-token";
      process.env.ANTHROPIC_API_KEY = "test-key";

      const env = loadEnv();

      expect(env.TODOIST_API_TOKEN).toBe("test-token");
      expect(env.ANTHROPIC_API_KEY).toBe("test-key");
    });
  });

  describe("requireEnv", () => {
    test("returns value when env var is set", () => {
      process.env.TODOIST_API_TOKEN = "test-token";

      const value = requireEnv("TODOIST_API_TOKEN");

      expect(value).toBe("test-token");
    });

    test("throws when env var is not set", () => {
      delete process.env.TODOIST_API_TOKEN;

      expect(() => requireEnv("TODOIST_API_TOKEN")).toThrow(
        "Missing required environment variable: TODOIST_API_TOKEN"
      );
    });
  });
});
