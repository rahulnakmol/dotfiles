# Package manager aliases for Fedora/RHEL (dnf)
[[ "$DOTFILES_DISTRO" == "fedora" ]] || return 0

alias dni='sudo dnf install'
alias dnu='sudo dnf remove'
alias dnup='sudo dnf check-update'
alias dnug='sudo dnf upgrade'
alias dnuu='sudo dnf upgrade --refresh -y && sudo dnf autoremove -y'
alias dns='dnf search'
alias dnl='dnf list installed'
alias dnls='dnf list installed | rg'
alias dninf='dnf info'
alias dnc='sudo dnf clean all'
alias dnar='sudo dnf autoremove'
alias dnrp='dnf repolist'
alias dnh='dnf history'
alias dnhu='sudo dnf history undo'
alias dnprov='dnf provides'
