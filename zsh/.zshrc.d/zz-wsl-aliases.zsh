# WSL aliases that must load AFTER aliases.zsh, to override rather than be
# overridden by it.
#
# Named zz- rather than numbered: digits sort BEFORE letters in ASCII, so a
# numeric prefix — 50-, even 99- — still sorts before any letter-led file,
# including aliases.zsh itself. That would have loaded this file first and
# had aliases.zsh silently win. zz- is the actual convention for "load last".
[[ -n "$DOTFILES_WSL" ]] || return 0

# On WSL, projects commonly live on the Windows filesystem (better tooling
# integration, no cross-filesystem performance cliff for editors that expect
# NTFS) rather than under the WSL home aliases.zsh points at.
if [[ -n "$DOTFILES_WIN_HOME" ]]; then
  alias prj="cd '$DOTFILES_WIN_HOME/Developer/Projects'"
  alias ghr="cd '$DOTFILES_WIN_HOME/Developer/Github'"
fi
