# Package manager aliases for openSUSE (zypper)
[[ "$DOTFILES_DISTRO" == "opensuse" ]] || return 0

alias zyi='sudo zypper install'
alias zyu='sudo zypper remove'
alias zyup='sudo zypper refresh'
alias zyug='sudo zypper update'
alias zyuu='sudo zypper refresh && sudo zypper update -y'
alias zydup='sudo zypper dist-upgrade'
alias zys='zypper search'
alias zyl='zypper packages --installed-only'
alias zyls='zypper search --installed-only'
alias zyinf='zypper info'
alias zyc='sudo zypper clean --all'
alias zyrp='zypper repos'
alias zyra='sudo zypper addrepo'
alias zyrd='sudo zypper removerepo'
alias zypa='zypper patches'
alias zyve='zypper verify'
