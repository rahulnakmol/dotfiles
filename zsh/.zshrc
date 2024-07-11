# Load plugins and dependencies
source <(fzf --zsh)

# Initialize starship for zsh
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
