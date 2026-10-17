# codex

OpenAI Codex CLI configuration. Codex runs only through the private AI gateway — no ChatGPT plan,
no OpenAI API key, no other provider.

## Private AI gateway

Run `./scripts/setup-private-ai-gateway.sh` once as the interactive user. It stores the endpoint and
one user-specific key under `~/.config/private-ai-gateway/` (mode 0600), writes an isolated Codex
configuration there, and creates `~/.local/bin/codex` as the gateway-backed command. The same
protected key is used by that user's Claude Code and OpenCode launchers; keys are never shared
between OS users or committed here.

**Gateway-only.** The private AI gateway is the only model route. The launcher
refuses to start without the user's `~/.config/private-ai-gateway/client.key` (mode 0600), refuses
subscription and account login subcommands, and strips provider overrides, so nothing falls back
to a vendor endpoint or a cached session. The shared stowed config also fails closed when the
vendor binary is run directly.

## Key Files

| File | Purpose |
|------|---------|
| `.codex/config.toml` | Model, auth, sandbox policy, MCP servers |
| `.codex/{code,codex,plan,review,quick}.config.toml` | One file per profile |

Each profile is its own file, not a `[profiles.<name>]` table in `config.toml` — confirmed against
the real, currently-published codex-cli: `--profile <name>` layers
`$CODEX_HOME/<name>.config.toml` on top of `config.toml`, and refuses to run at all if a matching
`[profiles.<name>]` table also exists in `config.toml` ("legacy" config, per its own error).

## Authentication

Only the gateway key. The generated `~/.config/private-ai-gateway/codex/config.toml` sets
`model_provider = "private_gateway"` with an auth command that reads `client.key`,
`forced_login_method = "api"`, and points `openai_base_url` and `chatgpt_base_url` at the gateway
too, so even a built-in provider cannot reach `api.openai.com` or `chatgpt.com`. The launcher
refuses `codex login`, `codex logout`, `codex cloud`, `--oss`, `--profile`, and `-c` overrides of
provider, endpoint, or login keys.

The stowed `~/.codex/config.toml` is only read when the vendor binary runs directly. It names the
undefined `private_gateway` provider and points the built-in endpoints at a closed local port, so
that path fails instead of using a ChatGPT session or an API key.

## Defaults

| Setting | Value |
|---------|-------|
| Model | gateway default from `~/.config/private-ai-gateway/default-model` |
| Sandbox mode | workspace-write |
| Approval policy | on-request |
| `sandbox_workspace_write.network_access` | `false` |
| `[shell_environment_policy].exclude` | generated from `agent-policy/catalog.json` |

The model must be one the gateway advertises at `/v1/models`; the setup script checks this.

## Profiles — mirroring Claude and OpenCode

These profile files apply only to the stowed `~/.codex`, which fails closed. The gateway launcher
uses its own `CODEX_HOME` and refuses `--profile`, so run the gateway with `-m`, `-s`, and `-a`
instead.

| Profile | Mirrors | Sandbox | Approval | Reasoning |
|---------|---------|---------|----------|-----------|
| `code` | Claude `cco` / OpenCode `pro` | workspace-write | on-request | xhigh |
| `codex` | daily driver | workspace-write | on-request | medium |
| `plan` | Claude `ccpl` | read-only | on-request | high |
| `review` | code review, own `review_model` | read-only | on-request | — |
| `quick` | OpenCode `quick` | read-only | on-request | minimal, no web search |

`approval_policy` is down to two values on the current CLI — `on-request` and `never` — the old
`untrusted` errors as no longer supported. `sandbox_mode = "read-only"` is what actually blocks
writes on `plan`/`review`/`quick`; `on-request` is the closer of the two remaining values to the
original "ask before anything" intent.

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
