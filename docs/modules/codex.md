# codex

OpenAI Codex CLI configuration, running on the **ChatGPT Pro plan** — no Azure, no API key, no
provider endpoint.

## Key Files

| File | Purpose |
|------|---------|
| `.codex/config.toml` | Model, auth, sandbox policy, five profiles, MCP servers |

## Authentication

```bash
codex login   # choose "Sign in with ChatGPT"
```

`preferred_auth_method = "chatgpt"` — the documented default, set explicitly because a machine
that previously used an API key would otherwise have that take precedence when both are present.

## Defaults

| Setting | Value |
|---------|-------|
| Model | `gpt-5.1-codex-max` |
| Review model | `gpt-5.1-codex-max` |
| Sandbox mode | workspace-write |
| Approval policy | on-request |
| `sandbox_workspace_write.network_access` | `false` |
| `[shell_environment_policy].exclude` | generated from `agent-policy/catalog.json` |

Model IDs are Codex's own documented default at time of writing, not verified against a live
account — confirm after signing in with `codex --profile <name> exec "reply OK"` per profile, since
plan entitlement decides what's actually reachable.

## Profiles — mirroring Claude and OpenCode

| Profile | Mirrors | Sandbox | Approval | Reasoning |
|---------|---------|---------|----------|-----------|
| `code` | Claude `cco` / OpenCode `pro` | workspace-write | on-request | xhigh |
| `codex` | daily driver | workspace-write | on-request | medium |
| `plan` | Claude `ccpl` | read-only | untrusted | high |
| `review` | code review, own `review_model` | read-only | untrusted | — |
| `quick` | OpenCode `quick` | read-only | untrusted | minimal, no web search |

## MCP Servers

All under `[mcp_servers.*]` — `github` and `azure` used to sit under the non-functional `[mcp.*]`
table and never actually loaded.

| Server | Transport |
|--------|-----------|
| context7 | npx (`@upstash/context7-mcp`), `CONTEXT7_API_KEY` via `env_vars` |
| figma | URL (`https://mcp.figma.com/mcp`) |
| gcloud | npx (`@google-cloud/gcloud-mcp`) |
| playwright | npx (`@playwright/mcp@latest`) |
| sequential-thinking | npx (`@modelcontextprotocol/server-sequential-thinking`) |
| github | URL, `bearer_token_env_var = "GITHUB_PAT"` |
| azure | npx (`@azure/mcp@latest`) — manages Azure *resources* via the `az`/`azd` aliases; unrelated to the model provider above |

## Project trust

Deliberately **not** committed — TOML has no variable expansion, so a portable value like
`$HOME/.dotfiles` would never resolve any better than a hardcoded username does, and Codex has no
per-machine include layer the way git does. Trust this repo locally after `stow codex`, either via
the interactive prompt on first run or by hand-adding:

```toml
[projects."/actual/absolute/path/to/.dotfiles"]
trust_level = "trusted"
```

directly to `~/.codex/config.toml` — don't commit that edit.

## Dependencies

Codex CLI, a ChatGPT Plus/Pro/Team/Edu/Enterprise plan, Node.js (for npx-based MCP servers).
