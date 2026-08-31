# opencode

OpenCode AI coding assistant with Zen provider, custom agents, and a model update script.

## Key Files

| File | Purpose |
|------|---------|
| `.config/opencode/opencode.json` | Main config: models, agents, provider settings |
| `.config/opencode/tui.json` | TUI theme and scroll settings |
| `.config/opencode/update-models.sh` | Script to fetch latest Zen model IDs and update config |

## Default Models

| Role | Model |
|------|-------|
| Primary | `opencode/claude-sonnet-4-6` |
| Small (summarization) | `opencode/gpt-5-nano` |

Provider: `opencode` (Zen). Auto-update is disabled.

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `quick` | `opencode/minimax-m2.5` | Fast queries with cheap/free models |
| `pro` | `opencode/claude-opus-4-6` | Complex architecture, debugging, deep analysis |
| `ui` | `opencode/gemini-3.1-pro` | Frontend/UI work with multimodal support |

Each agent has a custom system prompt tailored to its role.

## TUI Settings

| Setting | Value |
|---------|-------|
| Theme | catppuccin |
| Scroll acceleration | enabled |

## Alternative: Azure AI Foundry

The default `opencode` (Zen) provider stays untouched by this. To add an Azure AI Foundry endpoint
as an **additional**, opt-in provider:

```bash
./scripts/setup-model-provider.sh --opencode-azure --resource-name=my-resource --deployment=gpt-5
opencode run -m azure/gpt-5 "reply OK"   # use it
```

This merges a marker-guarded `provider.azure` block into `opencode.json` using the
`@ai-sdk/azure` package and OpenCode's own `{env:AZURE_OPENAI_API_KEY}` templating — the committed
file only ever holds that reference, never the literal key. The script resolves the key the same
way as the Codex flow above (already-exported env var → 1Password → hidden prompt, never a CLI
flag), persisting it only to `~/.zshrc.local` if it has to ask. Re-running is idempotent, and a
pre-existing unmanaged `provider.azure` entry is left alone rather than overwritten. See
`scripts/setup-model-provider.sh --help` and `docs/modules/codex.md` for the full safety design,
which is shared across both tools.

## Model Update Script

`update-models.sh` fetches the latest model catalog from `https://opencode.ai/zen/v1/models` and updates `opencode.json` agent model IDs using version-sorted selection.

| Flag | Behavior |
|------|----------|
| (none) | Updates config in-place |
| `--dry-run` | Shows resolved models without writing |

Shell aliases: `ocum` (update), `ocumd` (dry-run).

The script also prints tmux keybinding hints when model IDs change, since those are hardcoded in `tmux.conf`.

## Dependencies

opencode CLI, curl, jq, bash.
