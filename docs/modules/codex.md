# codex

OpenAI Codex CLI configuration with Azure OpenAI backend and multiple profiles.

## Key Files

| File | Purpose |
|------|---------|
| `.codex/config.toml` | Model settings, profiles, MCP servers, project trust |

## Default Settings

| Setting | Value |
|---------|-------|
| Model | `gpt-5-codex` |
| Provider | Azure OpenAI |
| Reasoning effort | medium |
| Reasoning summary | detailed |
| Sandbox mode | workspace-write |

## Azure Provider

| Setting | Value |
|---------|-------|
| Base URL | `https://azai-eus2-connected-auto-dev-01.openai.azure.com/openai/v1` |
| Auth env var | `AZURE_OPENAI_API_KEY` |
| Wire API | responses |

## Profiles

| Profile | Model | Reasoning | Sandbox | Approval |
|---------|-------|-----------|---------|----------|
| `code` | gpt-5 | high | workspace-write | on-request |
| `codex` | gpt-5-codex | high | workspace-write | on-request |
| `plan` | gpt-5-codex | medium | read-only | on-failure |
| `planpro` | gpt-5-pro | medium | read-only | on-failure |
| `review` | gpt-5 | medium | read-only | on-failure |

## MCP Servers

| Server | Transport |
|--------|-----------|
| context7 | npx (`@upstash/context7-mcp`) |
| figma | URL (`https://mcp.figma.com/mcp`) |
| gcloud | npx (`@google-cloud/gcloud-mcp`) |
| playwright | npx (`@playwright/mcp@latest`) |
| sequential-thinking | npx (`@modelcontextprotocol/server-sequential-thinking`) |
| github | URL (`https://api.githubcopilot.com/mcp/`) |
| azure | npx (`@azure/mcp@latest`) |

## Trusted Projects

`/home/rahulnakmol/.dotfiles`

## Dependencies

Codex CLI, Azure OpenAI API key, Node.js (for npx-based MCP servers).
