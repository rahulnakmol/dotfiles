# Debian/Ubuntu's global zshrc calls compinit before user configuration can
# select a trusted completion path. Initialize it explicitly from .zshrc instead.
skip_global_compinit=1
