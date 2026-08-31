# Fresh Machine Setup

Step-by-step guide to deploying this dotfiles repo on a new Linux machine.

---

## 1. Install prerequisites

See [dependencies.md](dependencies.md) for the full list with per-distro install commands. The quick version:

```bash
# openSUSE Tumbleweed
sudo zypper install git stow zsh tmux neovim eza bat fd ripgrep fzf zoxide starship curl jq gh

# Fedora
sudo dnf install git stow zsh tmux neovim eza bat fd-find ripgrep fzf zoxide starship curl jq gh

# Ubuntu / Debian
sudo apt install git stow zsh tmux curl jq gh
brew install eza bat fd ripgrep fzf zoxide starship neovim
```

Install [Mononoki Nerd Font](https://www.nerdfonts.com/font-downloads) and configure your terminal to use it.

## 2. Set zsh as default shell

```bash
chsh -s $(which zsh)
```

Log out and back in for the change to take effect.

## 3. Clone the repo

```bash
git clone https://github.com/rahulnakmol/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## 4. Deploy modules with stow

Stow creates symlinks from each module directory into `$HOME`. Deploy in this order to satisfy dependencies:

```bash
# Step 1: Shell foundation
stow zsh

# Step 2: Core tools
stow git ssh starship bat

# Step 3: Terminal and editor — ghostty on native Linux, wezterm on WSL
# (Ghostty has no Windows build; see docs/guides/wsl.md for the extra
# symlink step WezTerm needs)
stow tmux nvim
stow ghostty   # native Linux
stow wezterm   # WSL only

# Step 4: Dev tools
stow gh

# Step 5: AI coding tools
stow claude cursor opencode codex

# Step 6: Credentials (if using 1Password)
stow 1password
```

To preview what stow will do before committing:

```bash
stow -n zsh    # dry-run, shows what symlinks would be created
```

To deploy everything at once (native Linux — swap `ghostty` for `wezterm` on WSL):

```bash
stow zsh git ssh starship bat tmux ghostty nvim gh claude cursor opencode codex 1password
```

### Renaming an existing machine's `00-distro.zsh`

If you deployed this repo before `00-distro.zsh` was renamed to `00-platform.zsh`, re-stow zsh so
the stale symlink is cleaned up rather than left pointing at a file that no longer exists:

```bash
stow -D zsh && stow zsh
```

## 5. Post-install steps

### Tmux plugins

TPM (Tmux Plugin Manager) bootstraps automatically on first tmux launch. If plugins are missing:

1. Start tmux: `tmux`
2. Press `C-a I` (capital I) to install plugins
3. Press `C-a r` to reload config

### Neovim plugins

LazyVim will auto-install plugins on first launch:

```bash
nvim
```

Wait for Lazy to finish, then quit and reopen. Run `:checkhealth` to verify everything is working.

### 1Password SSH agent

If using 1Password for SSH keys:

1. Install 1Password and the 1Password CLI
2. Enable the SSH agent in 1Password settings
3. Deploy the module: `stow 1password`
4. SSH picks it up automatically — `ssh/.ssh/config` only claims the agent socket when it
   actually exists, so this is safe to do in any order
5. For commit signing specifically, also run `./scripts/setup-signing-key.sh --1password` (see
   below) — the agent alone isn't enough, since signing is configured per machine, not implied by
   the agent being present

### Commit signing

Signing is on by default in the committed git config, and an unconfigured machine refuses to
commit — deliberately, so you find out immediately rather than pushing unsigned work. Configure
this machine once:

```bash
./scripts/setup-signing-key.sh --local       # on-disk key, no 1Password needed
# or
./scripts/setup-signing-key.sh --1password   # use the 1Password SSH agent
```

See [docs/modules/git.md](../modules/git.md) for what each mode does, and
[docs/guides/wsl.md](wsl.md#commit-signing-on-wsl) for the WSL-specific paths.

### GitHub CLI

```bash
gh auth login
```

### Starship prompt

Starship initializes automatically from `.zshrc`. No extra setup needed after `stow starship`.

## 6. Multi-distro and WSL notes

The shell config detects your distro automatically via `/etc/os-release` and sets `$DOTFILES_DISTRO`:

| `$DOTFILES_DISTRO` | Detected from |
|---------------------|---------------|
| `ubuntu` | Ubuntu, Debian, Pop!_OS, Linux Mint |
| `fedora` | Fedora, RHEL, CentOS, Rocky, Alma |
| `opensuse` | openSUSE Tumbleweed/Leap, SLES |

Distro-specific alias files (`pkg-ubuntu.zsh`, `pkg-fedora.zsh`, `pkg-opensuse.zsh`) self-guard -- they return immediately on the wrong distro. No manual configuration needed.

On Ubuntu, Homebrew is auto-detected and `brew` aliases are loaded when available.

Running inside WSL is detected the same way (`$DOTFILES_WSL`, split into `1`/`2`) alongside the
distro. See [docs/guides/wsl.md](wsl.md) for everything WSL-specific: the 1Password agent bridge,
clipboard, WezTerm instead of Ghostty, and commit signing.

## 7. Keeping things updated

After pulling changes from the repo:

```bash
cd ~/.dotfiles
git pull
stow zsh tmux git   # re-stow any modules that changed
```

Stow is idempotent -- re-running it on an already-deployed module is safe.

## 8. Local overrides

For machine-specific config that should not be committed:

- Shell: create `~/.zshrc.local` (sourced at the end of `.zshrc`)
- Git: use `~/.gitconfig.local` with `includeIf` directives
