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

**Gateway-only.** The private AI gateway is the only model route. The launcher refuses to start
without the user's `~/.config/private-ai-gateway/client.key` (mode 0600) and refuses
`opencode auth`. OpenCode 2.0 splits the enforcement across two layers, and the launcher relies on
both:

- **Allowlist.** OpenCode takes `enabled_providers` from the global config and ignores it in later
  layers, so the stowed `~/.config/opencode/opencode.json` (exactly `["private_gateway"]`) is what
  keeps project configs from enabling other providers. The launcher refuses to run if that file is
  missing or allows anything else, and unsets `OPENCODE_CONFIG_DIR`, which would replace it.
- **Endpoint and key.** The generated gateway config is passed inline (`OPENCODE_CONFIG_CONTENT`),
  the highest user layer, so a project config cannot redirect `private_gateway` or swap its key.

The launcher also turns off the models.dev catalog fetch and update checks. The vendor binary run
without the launcher has no usable provider.

### Background service

OpenCode 2.0 runs commands through a per-user background service (`opencode service status`). It
keeps the config it started with, so setup stops it and the next command restarts it through the
launcher. The default port is shared by every OS user, so setup gives each user its own port
(49384 + UID mod 1000) when none is set. The port and the service password live in
`~/.config/opencode/service.json`, which is git-ignored; never commit it.

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
