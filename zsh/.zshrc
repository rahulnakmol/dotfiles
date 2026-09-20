# PATH — build dynamically, deduplicate
typeset -U PATH
PATH="$HOME/.local/bin:$GOPATH/bin:$CARGO_HOME/bin:$PATH"
[[ -d "$HOME/.opencode/bin" ]] && PATH="$HOME/.opencode/bin:$PATH"

# Homebrew — only eval if .zprofile didn't already set it (non-login shells)
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Homebrew prepends its bin directory. Restore user-owned launchers to the
# front so machine-local wrappers such as the Akmol gateway clients win while
# their *-direct commands can still invoke the absolute vendor binaries.
PATH="$HOME/.local/bin:$PATH"

# User-owned completions avoid compinit rejecting a shared, package-manager-
# writable Homebrew tree. Provisioning populates this directory for VPS users.
if [[ -d "$HOME/.local/share/zsh/site-functions" ]]; then
  fpath=("$HOME/.local/share/zsh/site-functions" ${fpath:#/home/linuxbrew/.linuxbrew/share/zsh/site-functions})
fi

# Rustup — resolve from brew or system (MACHTYPE avoids uname subshell)
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/rustup/bin" ]]; then
  PATH="$HOMEBREW_PREFIX/opt/rustup/bin:$PATH"
elif [[ -d "$HOME/.rustup/toolchains/stable-${MACHTYPE}-unknown-linux-gnu/bin" ]]; then
  PATH="$HOME/.rustup/toolchains/stable-${MACHTYPE}-unknown-linux-gnu/bin:$PATH"
fi

# Services and remote commands need the toolchain PATH, not prompt, completion,
# alias, or ZLE initialization. Keep non-interactive shells quiet and deterministic.
[[ -o interactive ]] || return

# zsh-autocomplete owns compinit and must load before compdef, custom widgets,
# autosuggestions, and syntax highlighting.
for plugin in \
  "$HOME/.local/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh" \
  "${HOMEBREW_PREFIX:-/nonexistent}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" \
  "/usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"; do
  if [[ -f "$plugin" ]]; then
    source "$plugin"
    break
  fi
done
unset plugin

# Source modular configs (00-distro.zsh loads first due to sort order)
for rcfile in "$HOME"/.zshrc.d/*.{zsh,sh}(N.); do
  source "$rcfile"
done
unset rcfile

# Shell integrations
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

# fzf — cache generated config for faster startup
_fzf_cache="$HOME/.cache/fzf-zsh.zsh"
if [[ ! -s "$_fzf_cache" || "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
  mkdir -p "$HOME/.cache"
  fzf --zsh > "$_fzf_cache" 2>/dev/null
fi
[[ -f "$_fzf_cache" ]] && source "$_fzf_cache"
unset _fzf_cache

# Local overrides (machine-specific, not committed)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ZSH line-editor plugins. Autosuggestions loads after Autocomplete; syntax
# highlighting must be last so it observes every widget and redraw hook.
() {
  local dirs=("$HOME/.local/share/zsh/plugins" "${HOMEBREW_PREFIX:-/nonexistent}/share" "/usr/share")
  local plugins=(
    "zsh-autosuggestions/zsh-autosuggestions.zsh"
    "zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  )
  local plugin dir
  for plugin in "${plugins[@]}"; do
    for dir in "${dirs[@]}"; do
      [[ -f "$dir/$plugin" ]] && source "$dir/$plugin" && break
    done
  done
}
