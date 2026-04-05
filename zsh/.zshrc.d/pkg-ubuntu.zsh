# Package manager aliases for Ubuntu/Debian (apt + Homebrew)
[[ "$DOTFILES_DISTRO" == "ubuntu" ]] || return 0

# apt
alias ai='sudo apt install'
alias au='sudo apt remove'
alias aup='sudo apt update'
alias aug='sudo apt upgrade'
alias auu='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias as='apt search'
alias al='apt list --installed'
alias ainf='apt show'
alias ac='sudo apt autoclean'
alias aar='sudo apt autoremove'
alias apur='sudo apt purge'

# Homebrew (primary package manager on Ubuntu for dev tools)
if [[ -n "$DOTFILES_BREW_PREFIX" ]]; then
  alias bi='brew install'
  alias bu='brew uninstall'
  alias bl='brew list'
  alias bs='brew search'
  alias bc='brew cleanup'
  alias bup='brew update'
  alias bug='brew upgrade'
  alias buu='brew update && brew upgrade && brew cleanup'
  alias binf='brew info'
fi
