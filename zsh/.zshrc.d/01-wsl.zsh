# WSL-specific environment setup
[[ "$DOTFILES_WSL" == "1" ]] || return 0

# Auto-detect Windows home directory
if [[ -d "/mnt/c/Users" ]]; then
  _win_user=$(command ls /mnt/c/Users/ 2>/dev/null \
    | grep -vE '^(Public|Default|Default User|All Users|desktop.ini)$' | head -1)
  [[ -n "$_win_user" ]] && export WSL_HOME="/mnt/c/Users/$_win_user"
  unset _win_user
fi

# Ensure starship uses standard XDG path (not old WSL custom path)
unset STARSHIP_CONFIG

# 1Password SSH signing via Windows relay
# The agent socket is relayed to ~/.1password/agent.sock by 1Password for Windows.
# For git signing, use op-ssh-sign-wsl from the Windows 1Password installation.
if [[ ! -x /opt/1Password/op-ssh-sign ]]; then
  # Not native Linux 1Password — look for the Windows WSL bridge binary
  _op_sign=""
  for _candidate in \
    "${WSL_HOME}/AppData/Local/1Password/app/8/op-ssh-sign-wsl" \
    "/mnt/c/Program Files/1Password/app/8/op-ssh-sign-wsl"; do
    if [[ -x "$_candidate" ]]; then
      _op_sign="$_candidate"
      break
    fi
  done

  if [[ -n "$_op_sign" ]]; then
    # Override gpg.ssh.program to point to the Windows WSL bridge
    export GIT_CONFIG_COUNT=1
    export GIT_CONFIG_KEY_0="gpg.ssh.program"
    export GIT_CONFIG_VALUE_0="$_op_sign"
  else
    # No signing binary found — disable signing to avoid errors
    export GIT_CONFIG_COUNT=2
    export GIT_CONFIG_KEY_0="commit.gpgsign"
    export GIT_CONFIG_VALUE_0="false"
    export GIT_CONFIG_KEY_1="tag.gpgsign"
    export GIT_CONFIG_VALUE_1="false"
  fi
  unset _op_sign _candidate
fi
