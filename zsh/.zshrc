# Global Variables
export CLICOLOR=1                                                                                                       # Enable colorized output
export GOPATH="$HOME/Developer/go"                                                                                      # Go tooling and package path
export RUSTUP_HOME="$HOME/Developer/.rustup"                                                                            # Rustup home
export CARGO_HOME="$HOME/Developer/.cargo"                                                                              # Cargo home
export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"                                  # Colorize GCC output
export MANPAGER="sh -c 'col -bx | bat -l man -p'"                                                                       # Use bat as manpager
export BAT_THEME="Catppuccin Macchiato"                                                                                 # Set bat theme
export DOTNET_CLI_TELEMETRY_OPTOUT=1                                                                                    # Disable .NET CLI telemetry
export CGO_ENABLED=1                                                                                                    # Enable CGO for Go for linking C runtime binding
export DISABLE_AUTOUPDATER=1
export AZURE_DEV_COLLECT_TELEMETRY="no"

# PATH — build dynamically, prefer local bin and dev tools
typeset -U PATH                                                                                                         # Deduplicate PATH entries
PATH="$HOME/.local/bin:$GOPATH/bin:$CARGO_HOME/bin:$PATH"
[[ -d "$HOME/.opencode/bin" ]] && PATH="$HOME/.opencode/bin:$PATH"

# Homebrew (Ubuntu uses linuxbrew, macOS uses /opt/homebrew)
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Rustup — resolve from brew or system
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/rustup/bin" ]]; then
  PATH="$HOMEBREW_PREFIX/opt/rustup/bin:$PATH"
elif [[ -d "$HOME/.rustup" ]]; then
  PATH="$HOME/.rustup/toolchains/stable-$(uname -m)-unknown-linux-gnu/bin:$PATH"
fi

# Source modular configs (00-distro.zsh loads first due to sort order)
if [[ -d ~/.zshrc.d ]]; then
  for rcfile in ~/.zshrc.d/*; do
    [[ -f "$rcfile" ]] && source "$rcfile"
  done
fi
unset rcfile

# Shell integrations
eval "$(starship init zsh)"                                                                                             # Initialize starship prompt
source <(fzf --zsh)                                                                                                     # Set up fzf key bindings and fuzzy completion
test -e "${HOME}/.zshrc.local" && source "${HOME}/.zshrc.local"                                                         # Enable local and secure environment variables

# ZSH plugins — check brew prefix first (Ubuntu), then system paths (Fedora/openSUSE)
_zsh_plugin_dirs=("${HOMEBREW_PREFIX:-/nonexistent}/share" "/usr/share")
for _plugdir in "${_zsh_plugin_dirs[@]}"; do
  [[ -f "$_plugdir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] \
    && source "$_plugdir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && break
done
for _plugdir in "${_zsh_plugin_dirs[@]}"; do
  [[ -f "$_plugdir/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]] \
    && source "$_plugdir/zsh-autocomplete/zsh-autocomplete.plugin.zsh" && break
done
for _plugdir in "${_zsh_plugin_dirs[@]}"; do
  [[ -f "$_plugdir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] \
    && source "$_plugdir/zsh-autosuggestions/zsh-autosuggestions.zsh" && break
done
unset _zsh_plugin_dirs _plugdir
