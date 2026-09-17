# Herdr

Agent-aware persistent terminal workspaces with a tmux-familiar keymap.

## Deploy

```bash
stow herdr
herdr config check
```

Install the integrations for the agents available on the machine:

```bash
herdr integration install claude
herdr integration install codex
herdr integration install opencode
herdr integration install cursor  # when Cursor Agent CLI is installed
herdr integration status
```

Install Herdr's release-matched agent-control skill globally:

```bash
npx skills add herdrdev/herdr --skill herdr -g
```

## Keybindings

The prefix is `C-a`, matching this repository's tmux module.

### Daily muscle memory

| Key | Action |
| --- | --- |
| `C-a ?` | Show all active keybindings |
| `C-a q` | Detach while panes keep running |
| `C-a w` | Open the workspace picker |
| `C-a g` | Open the session navigator |
| `C-a Shift-G` | Create a Git worktree workspace |
| `C-a Shift-1..9` | Jump to workspace 1–9 |
| `C-a Alt-1..9` | Jump to agent 1–9 |
| `M-Shift-Up` / `M-Shift-Down` | Previous / next agent |
| `C-a c` | New tab |
| `C-a '` | Split below |
| `C-a \` | Split right |
| `M-arrows` | Move between panes |
| `M-H` / `M-L` | Previous / next tab |
| `C-a x` | Close pane |
| `C-a z` | Toggle pane zoom |
| `C-a [` | Copy mode |
| `C-a r` | Reload configuration |
| `C-a Shift-C` | Claude Code popup |
| `C-a Shift-O` | OpenCode popup |
| `C-a Shift-D` | Codex popup |
| `C-a Shift-U` | Cursor Agent popup |

Herdr is mouse-capable, but the keyboard-first loop is: jump to an agent, inspect or answer it,
then move to the next agent requiring attention. The Agents sidebar sorts blocked and newly completed
work first.

Agent names also have stable Catppuccin colors while state icons retain their semantic urgency color:

| Agent | Name color |
| --- | --- |
| Claude | Peach |
| Codex | Green |
| OpenCode | Blue |
| Cursor | Mauve |
| Amp | Yellow |

The Attention Inbox plugin will use `C-a i` after it is published and installed. Until then, that
shortcut is intentionally unbound.

### Agent control from a pane

Agents with Herdr's release-matched skill can coordinate the current session:

```bash
herdr agent list
herdr pane split --current --direction right --cwd "$PWD" --no-focus
herdr agent start reviewer --kind codex --pane <pane-id>
herdr agent prompt reviewer "Review the current diff." --wait
herdr agent attach reviewer
```

Use `herdr agent attach <name>` for a focused, low-bandwidth view of one agent, especially from a
phone or Mosh session.

## Remote use

Run Herdr after connecting normally:

```bash
ssh user@host
herdr
```

The same workflow works through Mosh:

```bash
mosh user@host
herdr
```

For an SSH thin client that renders locally and bridges local image clipboard paste:

```bash
herdr --remote host
```

`herdr --remote` uses SSH, not Mosh.

## Persistence and security

- Detaching leaves shells, agents, servers, and tests running.
- After a Herdr server or host restart, workspace/tab/pane layout returns.
- Current official integrations can resume supported agent conversations.
- Pane screen-history persistence is explicitly disabled because pane output can contain secrets.
- Do not run tmux inside Herdr when agent detection matters; Herdr sees tmux rather than the nested
  foreground agent.
