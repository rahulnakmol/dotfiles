# Load plugins and dependencies
source <(fzf --zsh)

# Initialize starship for zsh
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/opt/homebrew/opt/node/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node/include"
eval "$(zoxide init zsh)"
export BAT_THEME="Catppuccin Macchiato"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

