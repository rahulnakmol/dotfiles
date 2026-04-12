# .zprofile — runs once on login shell only
# Interactive shell setup (prompt, aliases, plugins) belongs in .zshrc

# WSL detection (also set in 00-distro.zsh for non-login shells)
if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  export DOTFILES_WSL=1
fi

# Environment variables (set once per session)
export CLICOLOR=1
export GOPATH="$HOME/Developer/go"
export RUSTUP_HOME="$HOME/Developer/.rustup"
export CARGO_HOME="$HOME/Developer/.cargo"
export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME="Catppuccin Macchiato"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export CGO_ENABLED=1
export DISABLE_AUTOUPDATER=1
export AZURE_DEV_COLLECT_TELEMETRY="no"

# Homebrew (sets PATH, MANPATH, INFOPATH for the login session)
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
