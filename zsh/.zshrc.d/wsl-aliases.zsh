# WSL-specific aliases
[[ "$DOTFILES_WSL" == "1" ]] || return 0

# Windows integration
alias explorer='explorer.exe'
alias open='explorer.exe'
alias here='explorer.exe .'
alias clip='clip.exe'
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command "Get-Clipboard"'

# Navigation — project files live on Windows filesystem
[[ -n "$WSL_HOME" ]] && alias winhome='cd "$WSL_HOME"'
[[ -n "$WSL_HOME" ]] && alias prj='cd "$WSL_HOME/Developer"'
[[ -n "$WSL_HOME" ]] && alias ghr='cd "$WSL_HOME/Developer/Github"'
