# opencode

OpenCode AI coding assistant with custom agents. It uses only the private AI gateway provider.

## Private AI gateway

Run `./scripts/setup-private-ai-gateway.sh` once as the interactive user. It stores the endpoint and
one user-specific key under `~/.config/private-ai-gateway/` (mode 0600), writes an isolated OpenCode
configuration there, and creates
`~/.local/bin/opencode` as the gateway-backed command. The same protected key is used by that
user's Claude Code and Codex launchers; keys are never shared between OS users or committed here.
The setup reads the authenticated gateway `/v1/models` endpoint on every run, so `opencode models
private_gateway` shows the full current gateway catalog rather than a hardcoded subset.

**Gateway-only.** The private AI gateway is the only model route. The launcher
refuses to start without the user's `~/.config/private-ai-gateway/client.key` (mode 0600) and
refuses `opencode auth`. It passes the gateway config inline, the highest-precedence layer, so a
project `opencode.json` cannot re-enable another provider or redirect the gateway one, and it
turns off the models.dev catalog fetch. The shared stowed config also fails closed when the vendor
binary is run directly.

## Key Files

| File | Purpose |
|------|---------|
| `.config/opencode/opencode.json` | Main config: models, agents, provider settings |
| `.config/opencode/tui.json` | TUI theme and scroll settings |

## Models and agents

The stowed `opencode.json` enables only `private_gateway` and sets no model, so the vendor binary
run without the launcher has no usable provider. The launcher's generated config defines that
provider from the live gateway catalog and sets the default model chosen during setup. The
built-in `opencode` (Zen) provider and any credentials in `opencode auth` are never enabled.

| Agent | Purpose |
|-------|---------|
| `quick` | Fast, concise answers |
| `pro` | Complex architecture, debugging, deep analysis |
| `ui` | Frontend/UI work |

Each agent has a custom system prompt tailored to its role and uses the gateway default model.

## TUI Settings

| Setting | Value |
|---------|-------|
| Theme | catppuccin |
| Scroll acceleration | enabled |

## Dependencies

opencode CLI, curl, jq, bash.
