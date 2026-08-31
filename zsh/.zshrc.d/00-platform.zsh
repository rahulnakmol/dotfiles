# Detect distro, WSL, and Windows identity for conditional loading further
# down the .zshrc.d chain (pkg-*.zsh, 10-wsl.zsh, 50-wsl-aliases.zsh).
# Exports:
#   DOTFILES_DISTRO      ubuntu|fedora|opensuse|unknown
#   DOTFILES_PLATFORM    linux|wsl
#   DOTFILES_WSL         unset outside WSL; 1 (WSL1) or 2 (WSL2) inside it
#   DOTFILES_WIN_USER    Windows username, WSL only
#   DOTFILES_WIN_HOME    /mnt/c/Users/<DOTFILES_WIN_USER>, WSL only
#   DOTFILES_BREW_PREFIX set only when Homebrew is present

if [[ -f /etc/os-release ]]; then
  _distro_id=$(. /etc/os-release && echo "${ID}")
else
  _distro_id="unknown"
fi

case "$_distro_id" in
  ubuntu|debian|pop|linuxmint) export DOTFILES_DISTRO="ubuntu" ;;
  fedora|rhel|centos|rocky|alma) export DOTFILES_DISTRO="fedora" ;;
  opensuse*|sles) export DOTFILES_DISTRO="opensuse" ;;
  *) export DOTFILES_DISTRO="unknown" ;;
esac
unset _distro_id

# WSL detection, WSL1 vs WSL2. $WSL_DISTRO_NAME / $WSL_INTEROP are the fast
# path (present whenever we're inside WSL at all); the kernel release string
# is what actually distinguishes the version — WSL1's kernel identifies as
# "...Microsoft", WSL2's as "...microsoft-standard-WSL2" or similar. The
# split matters: WSL1 has no $WSL_INTEROP and different filesystem behavior
# under /mnt, so code downstream that only checks a boolean gets it wrong.
if [[ -n "$WSL_DISTRO_NAME" || -n "$WSL_INTEROP" ]] \
    || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
  _osrelease="$(cat /proc/sys/kernel/osrelease 2>/dev/null)"
  case "$_osrelease" in
    *WSL2*|*microsoft-standard*) export DOTFILES_WSL=2 ;;
    *[Mm]icrosoft*)              export DOTFILES_WSL=1 ;;
    *)                           export DOTFILES_WSL=2 ;;  # WSL_INTEROP present; assume the common case
  esac
  unset _osrelease
fi

export DOTFILES_PLATFORM="${DOTFILES_WSL:+wsl}"
[[ -z "$DOTFILES_PLATFORM" ]] && export DOTFILES_PLATFORM="linux"

# Windows identity, WSL only. Asking cmd.exe is authoritative; listing
# /mnt/c/Users and taking the first entry is not — it returns whatever sorts
# first alphabetically (often "Administrator" or "Default"), not the logged
# -in user. Cached to disk so this isn't a subprocess on every shell start.
if [[ -n "$DOTFILES_WSL" ]]; then
  _win_cache="$HOME/.cache/dotfiles-winuser"
  if [[ -r "$_win_cache" ]]; then
    DOTFILES_WIN_USER="$(<"$_win_cache")"
  elif command -v cmd.exe &>/dev/null; then
    DOTFILES_WIN_USER="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"
    if [[ -n "$DOTFILES_WIN_USER" ]]; then
      mkdir -p "$HOME/.cache"
      printf '%s' "$DOTFILES_WIN_USER" > "$_win_cache" 2>/dev/null
    fi
  fi
  if [[ -n "$DOTFILES_WIN_USER" ]]; then
    export DOTFILES_WIN_USER
    export DOTFILES_WIN_HOME="/mnt/c/Users/$DOTFILES_WIN_USER"
  fi
  unset _win_cache
fi

# Homebrew prefix (Ubuntu/WSL use linuxbrew, macOS uses /opt/homebrew)
if command -v brew &>/dev/null; then
  export DOTFILES_BREW_PREFIX="$(brew --prefix)"
fi
