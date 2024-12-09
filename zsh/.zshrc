# Global Variables
export CLICOLOR=1                                                                                           # Enable colorized output
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"                                                            # Add Rustup to PATH
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'                      # Colorize GCC output
export MANPAGER="sh -c 'col -bx | bat -l man -p'"                                                           # Use bat as manpager
export BAT_THEME="Catpuccin Macchiatto"                                                                     # Set bat theme
export MAMBA_EXE='/opt/homebrew/opt/micromamba/bin/mamba';                                                  # Set mamba executable
export MAMBA_ROOT_PREFIX='/Users/rahulnakmol/.mamba';                                                       # Set mamba root prefix
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters              # Set zsh-syntax-highlighting highlighters directory

if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases                                                                                        # Load aliases from a separate file
fi

# Shell Hooks
eval "$(starship init zsh)"                                                                                 # Initialize Starship prompt
eval "$(zoxide init --cmd cd zsh)"                                                                                   # Initialize zoxide
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"           # iTerm2 shell integration

# >>> mamba initialize >>>
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"                                                                                # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
