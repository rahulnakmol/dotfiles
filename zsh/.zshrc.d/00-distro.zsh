# Detect distro and set environment for conditional loading
# Exports: DOTFILES_DISTRO (ubuntu|fedora|opensuse|unknown)
#          DOTFILES_BREW_PREFIX (set only when Homebrew is present)

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

# Homebrew prefix (Ubuntu uses linuxbrew, macOS uses /opt/homebrew)
if command -v brew &>/dev/null; then
  export DOTFILES_BREW_PREFIX="$(brew --prefix)"
fi
