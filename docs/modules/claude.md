# claude

Claude Code CLI configuration, status line, and keybindings.

## Key Files

| File | Purpose |
|------|---------|
| `.claude/settings.json` | Status line config and enabled plugins |
| `.claude/statusline.sh` | Custom Catppuccin Macchiato status bar script |
| `.claude/keybindings.json` | Full keybinding overrides for all contexts |

## Permissions

| Setting | Value | Effect |
|---------|-------|--------|
| `permissions.defaultMode` | `auto` | Per-action classifier decides whether to prompt |
| `skipAutoPermissionPrompt` | `true` | Suppress the auto-mode confirmation dialog |
| `skipDangerousModePermissionPrompt` | `true` | Suppress the dangerous-mode confirmation dialog |

## Status Line

A bash script (`set -euo pipefail`) that reads JSON from stdin and renders a Catppuccin-colored status bar showing:

- Model name (`.model.display_name`, falls back to `.model.id`)
- Current directory (`.workspace.current_dir`, basename if > 40 chars)
- Git branch with dirty indicator (peach + `·` if dirty, green if clean)
- Vim mode (N/I)
- Context window usage (color-coded: green > 50%, peach > 20%, red < 20%) using
  `total_input_tokens + total_output_tokens` against `context_window_size`

## Enabled Plugins

| Plugin | Category |
|--------|----------|
| superpowers | Workflow |
| feature-dev | Workflow |
| code-review | Workflow |
| code-simplifier | Workflow |
| commit-commands | Git |
| pr-review-toolkit | Git |
| claude-code-setup | Setup |
| claude-md-management | Setup |
| plugin-dev | Development |
| skill-creator | Development |
| agent-sdk-dev | Development |
| mcp-server-dev | Development |
| playground | Development |
| frontend-design | UI |
| chrome-devtools-mcp | UI |
| ralph-loop | Automation |
| caveman (`@caveman`) | Automation |
| remember | Utility |
| explanatory-output-style | Utility |
| liquid-skills | Utility |
| typescript-lsp, pyright-lsp, gopls-lsp, csharp-lsp, lua-lsp, rust-analyzer-lsp | Language servers |
| playwright | Testing |
| semgrep | Security |
| firebase, azure | Cloud |
| huggingface-skills, pydantic-ai | AI/ML |
| data-engineering, data, dataverse, pinecone, goodmem | Data |
| firecrawl | Web scraping |
| terraform | Infrastructure |
| atomic-agents | Agents |

## Notable Keybindings

| Context | Key | Action |
|---------|-----|--------|
| Global | `Ctrl+t` | Toggle todos |
| Global | `Ctrl+o` | Toggle transcript |
| Chat | `Meta+p` | Model picker |
| Chat | `Meta+o` | Fast mode |
| Chat | `Meta+t` | Thinking toggle |
| Chat | `Ctrl+s` | Stash |
| Chat | `Space` | Push-to-talk |

## Dependencies

Claude Code CLI, jq, git, bash.
