# WSL environment: 1Password agent bridge, clipboard, Windows PATH hygiene.
# Self-guards on $DOTFILES_WSL (set by 00-platform.zsh) like the pkg-*.zsh
# files self-guard on $DOTFILES_DISTRO.
[[ -n "$DOTFILES_WSL" ]] || return 0

# ── 1Password SSH agent bridge ───────────────────────────────────────────────
# 1Password for Windows exposes the agent as a named pipe, not a Unix socket.
# npiperelay + socat bridge that pipe to a real socket WSL tools can use.
# ssh/.ssh/config already only claims this socket when it exists (Match host
# * exec "test -S ..."), so nothing here is required for SSH to keep working
# when the bridge isn't set up — it's an enhancement, not a dependency.
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
if [[ ! -S "$SSH_AUTH_SOCK" ]] \
    && command -v socat &>/dev/null \
    && command -v npiperelay.exe &>/dev/null; then
  mkdir -p "$(dirname "$SSH_AUTH_SOCK")"
  ( setsid socat "UNIX-LISTEN:$SSH_AUTH_SOCK,fork" \
      "EXEC:npiperelay.exe -ei -s //./pipe/openssh-ssh-agent,nofork" \
      &>/dev/null & disown ) 2>/dev/null
fi

# ── Clipboard ─────────────────────────────────────────────────────────────
# 11-clipboard.zsh (loaded after this file) defines the same pbcopy/pbpaste
# names for native Linux; these run first and win here because this file
# sorts before it (10- < 11-).
pbcopy() { clip.exe; }
pbpaste() { powershell.exe -NoProfile -Command Get-Clipboard; }

# ── Windows interop ───────────────────────────────────────────────────────
alias open='explorer.exe .'
alias explore='explorer.exe .'
[[ -n "$DOTFILES_WIN_HOME" ]] && alias winhome="cd '$DOTFILES_WIN_HOME'"
wpath() { wslpath -w "${1:-.}"; }
lpath() { wslpath -u "$1"; }

# ── Windows PATH hygiene ──────────────────────────────────────────────────
# WSL appends the entire Windows PATH by default, which slows completion and
# lets Windows binaries shadow Linux ones. Interop is required here (clip.exe,
# npiperelay.exe, explorer.exe, and 1Password's op-ssh-sign on WSL), so this
# does NOT disable it via /etc/wsl.conf's appendWindowsPath=false — that would
# break the tools above. Instead it's opt-in: set DOTFILES_WSL_PRUNE_PATH=1 in
# ~/.zshrc.local to filter /mnt/c/* down to an allowlist. Left off by default.
if [[ "${DOTFILES_WSL_PRUNE_PATH:-0}" == "1" ]]; then
  typeset -a _pruned
  local _allow='(System32|WindowsPowerShell|1Password|Microsoft VS Code)'
  for _p in "${(s.:.)PATH}"; do
    if [[ "$_p" == /mnt/c/* && ! "$_p" =~ $_allow ]]; then
      continue
    fi
    _pruned+=("$_p")
  done
  PATH="${(j.:.)_pruned}"
  unset _pruned _allow _p
fi
