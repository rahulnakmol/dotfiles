# .zprofile — runs once on login shell only
# Interactive shell setup (prompt, aliases, plugins) belongs in .zshrc

# Homebrew (sets PATH, MANPATH, INFOPATH for the login session)
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
