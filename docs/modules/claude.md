# claude

Claude Code CLI configuration, status line, and keybindings.

## Key Files

| File | Purpose |
|------|---------|
| `.claude/settings.json` | Status line config and enabled plugins |
| `.claude/statusline.sh` | Custom Catppuccin Macchiato status bar script |
| `.claude/keybindings.json` | Full keybinding overrides for all contexts |

## Status Line

A bash script that reads JSON from stdin and renders a Catppuccin-colored status bar showing:

- Model name (extracted from model ID)
- Session name
- Current directory
- Git branch with dirty indicator
- Vim mode (N/I)
- Context window usage (color-coded: green > 50%, peach > 20%, red < 20%)

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
| plugin-dev | Development |
| skill-creator | Development |
| agent-sdk-dev | Development |
| mcp-server-dev | Development |
| playground | Development |
| frontend-design | UI |
| chrome-devtools-mcp | UI |
| ralph-loop | Automation |
| remember | Utility |
| explanatory-output-style | Utility |
| typescript-lsp, pyright-lsp, gopls-lsp, csharp-lsp, lua-lsp | Language servers |
| playwright | Testing |
| firebase | Cloud |
| huggingface-skills | AI/ML |
| data-engineering, data | Data |
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
