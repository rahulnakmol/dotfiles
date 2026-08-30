# Clipboard for native Linux (Wayland, then X11). WSL defines its own
# pbcopy/pbpaste in 10-wsl.zsh, which sorts before this file and wins there —
# this file's guard just avoids redefining them with tools that don't exist
# on WSL anyway.
[[ -z "$DOTFILES_WSL" ]] || return 0

if command -v wl-copy &>/dev/null; then
  pbcopy() { wl-copy; }
  pbpaste() { wl-paste; }
elif command -v xclip &>/dev/null; then
  pbcopy() { xclip -selection clipboard; }
  pbpaste() { xclip -selection clipboard -o; }
elif command -v xsel &>/dev/null; then
  pbcopy() { xsel --clipboard --input; }
  pbpaste() { xsel --clipboard --output; }
fi
