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

Guided, either mode: `./scripts/setup-model-provider.sh --codex-chatgpt` runs `codex login` for
you — the script itself never sees the OAuth credential, the same way `claude setup-token` keeps
its own browser flow self-contained. See "Alternative: Azure AI Foundry" below for the other mode.

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

## Alternative: Azure AI Foundry

ChatGPT Pro auth is the default and stays untouched by this. To add an Azure AI Foundry endpoint
as an **additional**, opt-in profile — the `code`/`codex`/`plan`/`review`/`quick` profiles keep
using ChatGPT auth either way:

```bash
./scripts/setup-model-provider.sh --codex-azure --resource-name=my-resource --deployment=gpt-5
codex --profile azure exec "reply OK"   # use it
```

This writes a marker-guarded `[model_providers.azure]` + `[profiles.azure]` block into
`~/.codex/config.toml` — never into anything this repo tracks. The key itself is never written to
that file: only `env_key = "AZURE_OPENAI_API_KEY"`, the variable *name*, following Codex's own
documented mechanism for keeping secrets out of config. The script resolves the actual key from an
already-exported `AZURE_OPENAI_API_KEY`, a 1Password read, or a hidden prompt — never a CLI flag —
and, if it has to ask, persists it only to `~/.zshrc.local` (gitignored, per-machine). Re-running
the command is safe: the managed block is replaced in place, not duplicated, and a pre-existing
*unmanaged* `[model_providers.azure]` block is left alone with an explanatory error rather than
corrupted. `./scripts/setup-model-provider.sh --status` reports what's configured without ever
printing the key. See `scripts/setup-model-provider.sh --help` for the full safety rationale.

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
