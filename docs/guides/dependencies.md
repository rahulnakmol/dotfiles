# Dependencies

Every tool this repo references, grouped by tier and with install commands for each supported distro family.

---

## Tier 1 — Required

These must be installed for core dotfiles functionality.

| Tool | Purpose |
|------|---------|
| `git` | Version control, plugin bootstrapping |
| `stow` | Symlink dotfiles into `$HOME` |
| `zsh` | Shell |
| `tmux` | Terminal multiplexer |
| `neovim` | Editor (0.10+, LazyVim) |
| `eza` | Modern `ls` (aliased as `ls`, `ll`, `la`) |
| `bat` | Syntax-highlighted `cat` |
| `fd` | Fast file finder |
| `ripgrep` | Fast grep (`rg`) |
| `fzf` | Fuzzy finder, shell completion |
| `zoxide` | Smart directory jumper (replaces `cd`) |
| `starship` | Cross-shell prompt |
| `curl` | HTTP requests (scripts, plugin bootstrap) |
| `jq` | JSON processing (statusline, model updater) |

### Install

```bash
# openSUSE Tumbleweed
sudo zypper install git stow zsh tmux neovim eza bat fd ripgrep fzf zoxide starship curl jq

# Fedora
sudo dnf install git stow zsh tmux neovim eza bat fd-find ripgrep fzf zoxide starship curl jq

# Ubuntu / Debian (Homebrew recommended for latest versions of dev tools)
sudo apt install git stow zsh tmux curl jq
brew install eza bat fd ripgrep fzf zoxide starship neovim
```

> **Note:** On Ubuntu, `neovim` from apt is often too old for LazyVim. Homebrew or the Neovim PPA is recommended.

---

## Tier 2 — Recommended

Most workflows and aliases depend on these.

| Tool | Purpose | Used by |
|------|---------|---------|
| `gh` | GitHub CLI (PRs, issues, repo sync) | `g*` aliases, `gh` module |
| `ghostty` | GPU-accelerated terminal | `ghostty` module |
| `1password` | SSH agent, commit signing | `git`, `ssh`, `1password` modules |
| `op` | 1Password CLI | Git commit signing (`op-ssh-sign`); optional key source for `scripts/setup-model-provider.sh` |
| `Mononoki Nerd Font` | Glyphs for prompt, editor, tmux | `ghostty`, `starship`, `nvim` |

### Install

```bash
# GitHub CLI
# openSUSE
sudo zypper install gh
# Fedora
sudo dnf install gh
# Ubuntu
sudo apt install gh
# or: brew install gh

# Ghostty — https://ghostty.org/download
# Follow the platform-specific instructions on the site.

# 1Password — https://1password.com/downloads/linux
# openSUSE
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo zypper addrepo https://downloads.1password.com/linux/rpm/stable/x86_64 1password
sudo zypper install 1password 1password-cli
# Fedora
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo dnf config-manager --add-repo https://downloads.1password.com/linux/rpm/stable/x86_64
sudo dnf install 1password 1password-cli
# Ubuntu
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update && sudo apt install 1password 1password-cli

# Mononoki Nerd Font — https://www.nerdfonts.com/font-downloads
# Download and extract to ~/.local/share/fonts, then:
fc-cache -fv
```

---

## Tier 3 — AI Coding Tools

The tmux config and shell aliases integrate heavily with these tools.

| Tool | Purpose | Used by |
|------|---------|---------|
| `claude` | Claude Code (Anthropic) | `cc*` aliases, tmux `C-a c` key table |
| `opencode` | OpenCode (Zen provider) | `oc*` aliases, tmux `C-a o` key table |
| `codex` | Codex (Azure OpenAI) | `codex` module, `gcx*` aliases |

### Install

```bash
# Claude Code
npm install -g @anthropic-ai/claude-code

# OpenCode — https://opencode.ai
# Follow the install instructions on the site.

# Codex — https://github.com/openai/codex
npm install -g @openai/codex
```

---

## Tier 4 — Optional

Only needed for specific workflows. Aliases exist but won't break anything if the tool is absent.

### Containers

| Tool | Purpose | Used by |
|------|---------|---------|
| `podman` | Container engine (aliased as `docker`) | `d*` aliases |
| `podman-compose` | Compose support | `dc*` aliases |

```bash
# openSUSE
sudo zypper install podman podman-compose
# Fedora
sudo dnf install podman podman-compose
# Ubuntu
sudo apt install podman podman-compose
```

### Cloud

| Tool | Purpose | Used by |
|------|---------|---------|
| `az` | Azure CLI | `az*` aliases |
| `azd` | Azure Developer CLI | `azd*` aliases |

```bash
# Azure CLI — https://learn.microsoft.com/cli/azure/install-azure-cli-linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash     # Ubuntu/Debian
sudo dnf install azure-cli                                   # Fedora
sudo zypper install azure-cli                                # openSUSE

# Azure Developer CLI — https://aka.ms/azd
curl -fsSL https://aka.ms/install-azd.sh | bash
```

### Node.js / npm

| Tool | Purpose | Used by |
|------|---------|---------|
| `node` | JavaScript runtime | AI tools, MCP servers |
| `npm` | Package manager | `n*` aliases, AI tool install |

```bash
# openSUSE
sudo zypper install nodejs-default npm
# Fedora
sudo dnf install nodejs npm
# Ubuntu
brew install node
# or: sudo apt install nodejs npm
```

### Languages (for Neovim LSP extras)

| Tool | Purpose | Used by |
|------|---------|---------|
| `go` | Go language support | `nvim` extras, `GOPATH` in `.zprofile` |
| `rustup` / `cargo` | Rust toolchain | `nvim` extras, `CARGO_HOME` in `.zprofile` |
| `python3` | Python support | `nvim` extras |
| `dotnet` | C# / .NET support | `nvim` extras |
| `stylua` | Lua formatter | `nvim` (stylua.toml) |

```bash
# Go
# openSUSE
sudo zypper install go
# Fedora
sudo dnf install golang
# Ubuntu
brew install go

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Python
# openSUSE
sudo zypper install python3
# Fedora
sudo dnf install python3
# Ubuntu
sudo apt install python3

# .NET — https://dotnet.microsoft.com/download
# openSUSE
sudo zypper install dotnet-sdk-8.0
# Fedora
sudo dnf install dotnet-sdk-8.0
# Ubuntu
sudo apt install dotnet-sdk-8.0

# stylua
brew install stylua
# or: cargo install stylua
```

### SSH

| Tool | Purpose | Used by |
|------|---------|---------|
| `openssh` | SSH client/keygen | `s*` aliases, `snew`, `spub` functions |

```bash
# Usually pre-installed. If not:
# openSUSE
sudo zypper install openssh
# Fedora
sudo dnf install openssh-clients
# Ubuntu
sudo apt install openssh-client
```

### Homebrew (on Linux)

Recommended on Ubuntu where system packages lag behind. Optional on Fedora/openSUSE where repos are more current.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

The shell config auto-detects Homebrew at `/home/linuxbrew/.linuxbrew` or `/opt/homebrew` and loads it.

---

## WSL-specific

Beyond everything above (install inside the WSL distro, same as native Linux), WSL needs a few
extra pieces for the interop this repo wires up:

| Tool | Purpose |
|------|---------|
| `socat` | Bridges the 1Password Windows agent's named pipe to a Unix socket |
| [`npiperelay`](https://github.com/jstarks/npiperelay) | The Windows-side half of that bridge — install on Windows, put it on `PATH` |
| [WezTerm](https://wezfurlong.org/wezterm/) | Terminal — installed on **Windows**, not inside WSL; Ghostty has no Windows build |
| [Mononoki Nerd Font](https://www.nerdfonts.com/font-downloads) | Install on Windows too, for WezTerm |

```bash
# Inside WSL (Ubuntu example)
sudo apt install socat
```

Full setup: [docs/guides/wsl.md](wsl.md).

---

## Quick reference

One-liner to install all Tier 1 + Tier 2 tools:

```bash
# openSUSE Tumbleweed
sudo zypper install git stow zsh tmux neovim eza bat fd ripgrep fzf zoxide starship curl jq gh openssh podman

# Fedora
sudo dnf install git stow zsh tmux neovim eza bat fd-find ripgrep fzf zoxide starship curl jq gh openssh-clients podman

# Ubuntu / Debian
sudo apt install git stow zsh tmux curl jq gh openssh-client podman
brew install eza bat fd ripgrep fzf zoxide starship neovim
```
