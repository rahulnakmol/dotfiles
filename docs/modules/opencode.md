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
