#!/usr/bin/env bash
# update-models.sh — Fetch latest Zen models and update opencode.json agent model IDs
# Usage: oc-update-models [--dry-run]
set -euo pipefail

ZEN_API="https://opencode.ai/zen/v1/models"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.json"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# ── Dependency check ──────────────────────────────────────────────────────────
for cmd in curl jq; do
  command -v "$cmd" &>/dev/null || { echo "error: $cmd is required"; exit 1; }
done

[[ -f "$CONFIG" ]] || { echo "error: $CONFIG not found"; exit 1; }

# ── Fetch models ──────────────────────────────────────────────────────────────
echo "Fetching models from Zen API..."
MODELS=$(curl -sf "$ZEN_API") || { echo "error: failed to fetch $ZEN_API"; exit 1; }

# Extract all model IDs
IDS=$(echo "$MODELS" | jq -r '.data[].id')

# ── Helper: pick the latest model matching a pattern ──────────────────────────
# Uses version sort to find the highest-versioned model ID
pick_latest() {
  local pattern="$1"
  echo "$IDS" | grep -E "$pattern" | sort -V | tail -1
}

# ── Resolve latest model for each agent role ──────────────────────────────────
# build (default): latest claude-sonnet (not plain "claude-sonnet-4" without minor)
NEW_DEFAULT=$(pick_latest '^claude-sonnet-[0-9]+-[0-9]+$')
# Fallback: if no minor version pattern, try any claude-sonnet
[[ -z "$NEW_DEFAULT" ]] && NEW_DEFAULT=$(pick_latest '^claude-sonnet-')

# pro: latest claude-opus
NEW_PRO=$(pick_latest '^claude-opus-[0-9]')

# ui: latest gemini pro
NEW_UI=$(pick_latest '^gemini-.*pro$')

# quick: stays minimax-m2.5 (cheapest paid), but grab latest minimax
NEW_QUICK=$(pick_latest '^minimax-m[0-9]' | grep -v 'free' | tail -1)
[[ -z "$NEW_QUICK" ]] && NEW_QUICK="minimax-m2.5"

# small_model: gpt nano (free)
NEW_SMALL=$(pick_latest '^gpt-.*nano$')

# tmux shortcuts: latest gpt codex, gemini pro (reuse NEW_UI)
NEW_CODEX=$(pick_latest '^gpt-.*codex$' | grep -v 'mini\|max\|spark' | tail -1)
[[ -z "$NEW_CODEX" ]] && NEW_CODEX=$(pick_latest '^gpt-.*codex$')

# ── Report ────────────────────────────────────────────────────────────────────
# Read current values
CUR_DEFAULT=$(jq -r '.model // ""' "$CONFIG" | sed 's|opencode/||')
CUR_PRO=$(jq -r '.agent.pro.model // ""' "$CONFIG" | sed 's|opencode/||')
CUR_UI=$(jq -r '.agent.ui.model // ""' "$CONFIG" | sed 's|opencode/||')
CUR_QUICK=$(jq -r '.agent.quick.model // ""' "$CONFIG" | sed 's|opencode/||')
CUR_SMALL=$(jq -r '.small_model // ""' "$CONFIG" | sed 's|opencode/||')

echo ""
echo "Model resolution:"
printf "  %-14s %-28s -> %s\n" "build" "opencode/$CUR_DEFAULT" "opencode/$NEW_DEFAULT"
printf "  %-14s %-28s -> %s\n" "pro" "opencode/$CUR_PRO" "opencode/$NEW_PRO"
printf "  %-14s %-28s -> %s\n" "ui" "opencode/$CUR_UI" "opencode/$NEW_UI"
printf "  %-14s %-28s -> %s\n" "quick" "opencode/$CUR_QUICK" "opencode/$NEW_QUICK"
printf "  %-14s %-28s -> %s\n" "small" "opencode/$CUR_SMALL" "opencode/$NEW_SMALL"
echo ""
echo "Tmux model shortcuts (informational):"
printf "  %-14s %s\n" "codex" "opencode/$NEW_CODEX"
printf "  %-14s %s\n" "gemini-pro" "opencode/$NEW_UI"
printf "  %-14s %s\n" "opus" "opencode/$NEW_PRO"
echo ""

if $DRY_RUN; then
  echo "[dry-run] No changes written."
  exit 0
fi

# ── Check for changes ─────────────────────────────────────────────────────────
CHANGED=false
[[ "$CUR_DEFAULT" != "$NEW_DEFAULT" ]] && CHANGED=true
[[ "$CUR_PRO" != "$NEW_PRO" ]] && CHANGED=true
[[ "$CUR_UI" != "$NEW_UI" ]] && CHANGED=true
[[ "$CUR_QUICK" != "$NEW_QUICK" ]] && CHANGED=true
[[ "$CUR_SMALL" != "$NEW_SMALL" ]] && CHANGED=true

if ! $CHANGED; then
  echo "All models are already up to date."
  exit 0
fi

# ── Update config ─────────────────────────────────────────────────────────────
TMPFILE=$(mktemp)
jq \
  --arg def   "opencode/$NEW_DEFAULT" \
  --arg pro   "opencode/$NEW_PRO" \
  --arg ui    "opencode/$NEW_UI" \
  --arg quick "opencode/$NEW_QUICK" \
  --arg small "opencode/$NEW_SMALL" \
  '.model = $def |
   .small_model = $small |
   .agent.pro.model = $pro |
   .agent.ui.model = $ui |
   .agent.quick.model = $quick' \
  "$CONFIG" > "$TMPFILE"

mv "$TMPFILE" "$CONFIG"
echo "Updated $CONFIG"

# ── Print tmux hint ───────────────────────────────────────────────────────────
echo ""
echo "Note: tmux keybindings use -m flags with hardcoded model IDs."
echo "If models changed, update tmux.conf manually or re-run stow:"
echo "  M-f  ->  opencode/$NEW_QUICK"
echo "  M-g  ->  opencode/$NEW_UI"
echo "  M-a  ->  opencode/$NEW_PRO"
echo "  M-x  ->  opencode/$NEW_CODEX"
