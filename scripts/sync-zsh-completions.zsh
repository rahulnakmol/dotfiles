#!/usr/bin/env zsh
set -euo pipefail

BREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"
TARGET="$HOME/.local/share/zsh/site-functions"
PLUGIN_TARGET="$HOME/.local/share/zsh/plugins"

install -d -m 0755 "$TARGET" "$PLUGIN_TARGET"

for source_dir in \
  "$BREW_PREFIX/share/zsh/site-functions" \
  "$BREW_PREFIX/share/zsh-completions"; do
  [[ -d "$source_dir" ]] || continue
  for completion in "$source_dir"/_*(N); do
    cp -L -- "$completion" "$TARGET/${completion:t}"
    chmod 0644 "$TARGET/${completion:t}"
  done
done

for plugin in zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting; do
  source_dir="$BREW_PREFIX/share/$plugin"
  [[ -d "$source_dir" ]] || continue
  rm -rf "${PLUGIN_TARGET:?}/$plugin"
  cp -aL -- "$source_dir" "$PLUGIN_TARGET/$plugin"
  chmod -R u+rwX,go-w "$PLUGIN_TARGET/$plugin"
done

rm -f "$HOME/.zcompdump" "$HOME/.zcompdump.zwc"
echo "Synchronized trusted Zsh completions and plugins into $HOME/.local/share/zsh"
