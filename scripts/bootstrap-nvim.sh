#!/usr/bin/env bash
set -euo pipefail

NVIM_BIN="${NVIM_BIN:-nvim}"
TIMEOUT_SECONDS="${NVIM_BOOTSTRAP_TIMEOUT:-900}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

command -v "$NVIM_BIN" >/dev/null || {
  echo "Neovim is not installed: $NVIM_BIN" >&2
  exit 1
}
command -v rust-analyzer >/dev/null || {
  echo "rust-analyzer is required. With rustup: rustup component add rust-analyzer" >&2
  exit 1
}

timeout "$TIMEOUT_SECONDS" "$NVIM_BIN" --headless "+Lazy! restore" +qa

if ! timeout "$TIMEOUT_SECONDS" "$NVIM_BIN" --headless \
  "+luafile $SCRIPT_DIR/nvim/bootstrap-mason.lua" +qa; then
  echo "Mason bootstrap failed once; retrying missing packages." >&2
  timeout "$TIMEOUT_SECONDS" "$NVIM_BIN" --headless \
    "+luafile $SCRIPT_DIR/nvim/bootstrap-mason.lua" +qa
fi

timeout "$TIMEOUT_SECONDS" "$NVIM_BIN" --headless \
  "+luafile $SCRIPT_DIR/nvim/bootstrap-treesitter.lua" +qa

"$NVIM_BIN" --headless "+lua print('Neovim bootstrap verified')" +qa

echo "Neovim bootstrap complete. Run :checkhealth interactively for terminal-specific checks."
