#!/usr/bin/env bash
# setup-model-provider.sh — add Azure AI Foundry as a model provider for Codex
# and/or OpenCode, or point Codex at your ChatGPT plan instead. Guided,
# non-interactive-safe, and designed so a raw secret never has to touch a
# committed file, a CLI argument, shell history, or this script's own stdout.
#
# Why this exists, and the rules that make it safe:
#
#   1. There is deliberately NO --api-key flag. A secret passed as a CLI
#      argument sits in shell history and is visible to every other process
#      on the box for the life of this one (`ps aux` shows argv). The key
#      only ever enters this script through an environment variable already
#      set before it runs, a 1Password read, or a silent (echo-off) prompt.
#   2. The key is never printed — not full, not truncated, not "for
#      confirmation". --status reports whether one is set and how long it
#      is, nothing else.
#   3. Committed config (codex/.codex/config.toml, opencode.json) NEVER
#      receives the literal key — only the NAME of the environment variable
#      that holds it (env_key for Codex, {env:...} for OpenCode). That is
#      each tool's own documented mechanism for exactly this, not something
#      invented here.
#   4. If the key needs to persist on this machine at all, it goes into
#      ~/.zshrc.local — already gitignored, already this repo's established
#      per-machine override file — never into anything stow symlinks from
#      the repo itself.
#   5. Every file this script writes is idempotent and marker-guarded, the
#      same lesson learned the hard way with apply-agent-policy.mjs's own
#      codex adapter: an unmarked block gets duplicated (and the TOML
#      corrupted) on a second run. Re-run this as many times as you like.
#
# Usage:
#   ./scripts/setup-model-provider.sh MODE [OPTIONS]
#
# Modes (no default on purpose — this touches two different tools with
# different consequences; unlike setup-signing-key.sh, it should not
# silently no-op if you didn't say which one)
#   --status            Report what's configured for Codex and OpenCode.
#                       Never prints a secret value. Changes nothing.
#   --codex-chatgpt     Guide `codex login` (ChatGPT Plus/Pro/Team/Enterprise).
#   --codex-azure       Add/update an `azure` profile for Codex, ADDITIVE to
#                       the existing ChatGPT-based default profiles — run
#                       `codex --profile azure` to use it, `codex` (plain)
#                       keeps using ChatGPT.
#   --opencode-azure    Add/update an `azure` provider for OpenCode.
#
# Options
#   --resource-name NAME  Azure OpenAI/AI Foundry resource name (not secret —
#                         identifies which endpoint, not who you are).
#                         Prompted if omitted and the shell is interactive.
#   --deployment NAME    Azure deployment name to use as the default model.
#                         Prompted if omitted and the shell is interactive.
#   --dry-run            Print what would happen; change nothing.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_CONFIG="$CODEX_HOME/config.toml"
CODEX_AZURE_PROFILE="$CODEX_HOME/azure.config.toml"
OPENCODE_CONFIG="$ROOT/opencode/.config/opencode/opencode.json"
ZSHRC_LOCAL="$HOME/.zshrc.local"

AZURE_BEGIN="# BEGIN azure-provider (managed by setup-model-provider.sh)"
AZURE_END="# END azure-provider"
AZURE_PROFILE_MARKER="# managed by setup-model-provider.sh — safe to delete, will be regenerated"

MODE=""
DRY_RUN=0
RESOURCE_NAME=""
DEPLOYMENT=""

for arg in "$@"; do
  case "$arg" in
    --status)          MODE="status" ;;
    --codex-chatgpt)   MODE="codex-chatgpt" ;;
    --codex-azure)     MODE="codex-azure" ;;
    --opencode-azure)  MODE="opencode-azure" ;;
    --dry-run)         DRY_RUN=1 ;;
    --resource-name=*) RESOURCE_NAME="${arg#*=}" ;;
    --deployment=*)    DEPLOYMENT="${arg#*=}" ;;
    -h|--help)
      sed -n '2,40p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *)
      echo "Unknown argument: $arg (secrets are never passed as flags — see --help)" >&2
      exit 2 ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Pick a mode: --status, --codex-chatgpt, --codex-azure, or --opencode-azure" >&2
  echo "Run with --help for details." >&2
  exit 2
fi

log()  { printf '%s\n' "$*"; }
step() { printf '\n→ %s\n' "$*"; }
run()  {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '  [dry-run] would run: %s\n' "$*"
  else
    "$@"
  fi
}

# ── Resolve the Azure API key without ever putting it in an argument,
#    a log line, or this script's own output. Tries, in order: an
#    already-exported env var, 1Password (if signed in), then a silent
#    prompt. Echoes nothing back except a length.
resolve_azure_key() {
  if [[ -n "${AZURE_OPENAI_API_KEY:-}" ]]; then
    log "  using AZURE_OPENAI_API_KEY already set in this shell (${#AZURE_OPENAI_API_KEY} chars)" >&2
    printf '%s' "$AZURE_OPENAI_API_KEY"
    return
  fi

  if command -v op &>/dev/null && op whoami &>/dev/null; then
    log "  1Password CLI is signed in." >&2
    read -r -p "  1Password item reference (op://vault/item/field), or blank to type the key: " op_ref
    if [[ -n "$op_ref" ]]; then
      local val
      val="$(op read "$op_ref" 2>/dev/null || true)"
      if [[ -n "$val" ]]; then
        log "  read from 1Password (${#val} chars)" >&2
        printf '%s' "$val"
        return
      fi
      log "  could not read that item — falling back to a direct prompt" >&2
    fi
  fi

  if [[ ! -t 0 ]]; then
    echo "  No AZURE_OPENAI_API_KEY set and this isn't an interactive shell to prompt in." >&2
    echo "  Export AZURE_OPENAI_API_KEY before running this non-interactively." >&2
    return 1
  fi

  local key
  read -r -s -p "  Azure API key (input hidden, never logged): " key
  echo >&2
  [[ -n "$key" ]] || { echo "  empty key — aborting" >&2; return 1; }
  printf '%s' "$key"
}

# ── Persist a non-secret setting or an env-var export to ~/.zshrc.local —
#    gitignored, per-machine, never anything stow symlinks from the repo.
persist_local_export() {
  local line="$1"
  mkdir -p "$(dirname "$ZSHRC_LOCAL")"
  touch "$ZSHRC_LOCAL"
  chmod 600 "$ZSHRC_LOCAL" 2>/dev/null || true
  if grep -qF "$line" "$ZSHRC_LOCAL" 2>/dev/null; then
    log "  already present in $ZSHRC_LOCAL"
    return
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    log "  [dry-run] would append to $ZSHRC_LOCAL: $line"
  else
    printf '%s\n' "$line" >> "$ZSHRC_LOCAL"
    log "  appended to $ZSHRC_LOCAL"
  fi
}

prompt_resource_and_deployment() {
  if [[ -z "$RESOURCE_NAME" ]]; then
    if [[ -t 0 ]]; then
      read -r -p "  Azure OpenAI/AI Foundry resource name (e.g. my-resource, not a URL): " RESOURCE_NAME
    else
      echo "  --resource-name is required in a non-interactive shell" >&2
      exit 1
    fi
  fi
  if [[ -z "$DEPLOYMENT" ]]; then
    if [[ -t 0 ]]; then
      read -r -p "  Deployment/model name in Azure AI Foundry (e.g. gpt-5): " DEPLOYMENT
    else
      echo "  --deployment is required in a non-interactive shell" >&2
      exit 1
    fi
  fi
}

mode_codex_chatgpt() {
  step "Codex — sign in with your ChatGPT plan"
  log "  This runs Codex's own browser-gated OAuth flow — this script never"
  log "  sees or handles that credential, the same way \`claude setup-token\`"
  log "  keeps Claude's OAuth flow entirely inside Claude Code's own command."
  run codex login
  log "  Default profiles (code/codex/plan/review/quick) already use ChatGPT"
  log "  auth — see codex/.codex/config.toml. Nothing else to configure."
}

mode_codex_azure() {
  step "Codex — add an Azure AI Foundry profile (additive, not a replacement)"
  prompt_resource_and_deployment

  local key
  key="$(resolve_azure_key)" || { echo "No key resolved — aborting." >&2; exit 1; }

  if [[ -z "${AZURE_OPENAI_API_KEY:-}" ]]; then
    step "Persisting AZURE_OPENAI_API_KEY for future shells"
    log "  The key itself is never written to codex/.codex/config.toml — only the"
    log "  variable name is. This just makes sure the variable exists next time"
    log "  you open a shell, so Codex can actually read it at runtime."
    persist_local_export "export AZURE_OPENAI_API_KEY='$key'"
  fi

  if [[ ! -f "$CODEX_CONFIG" ]]; then
    echo "  $CODEX_CONFIG doesn't exist yet — run \`codex login\` or \`codex\` once first." >&2
    exit 1
  fi

  step "Writing the azure model provider into $CODEX_CONFIG"
  local block
  if grep -qF "$AZURE_BEGIN" "$CODEX_CONFIG" 2>/dev/null; then
    log "  replacing the existing managed block (idempotent)"
  elif grep -qE '^\[model_providers\.azure\]' "$CODEX_CONFIG" 2>/dev/null; then
    echo "  $CODEX_CONFIG already has an unmanaged [model_providers.azure]" >&2
    echo "  block — not touching it. Remove it, or add $AZURE_BEGIN / $AZURE_END" >&2
    echo "  around it by hand, then re-run." >&2
    exit 1
  fi

  block=$(cat <<EOF
$AZURE_BEGIN
[model_providers.azure]
name = "Azure AI Foundry"
base_url = "https://${RESOURCE_NAME}.openai.azure.com/openai"
env_key = "AZURE_OPENAI_API_KEY"
query_params = { api-version = "2025-04-01-preview" }
$AZURE_END
EOF
)

  if [[ "$DRY_RUN" == "1" ]]; then
    printf '%s\n' "$block" | sed 's/^/  [dry-run] /'
  else
    if grep -qF "$AZURE_BEGIN" "$CODEX_CONFIG"; then
      python3 - "$CODEX_CONFIG" "$AZURE_BEGIN" "$AZURE_END" "$block" <<'PYEOF'
import sys
path, begin, end, block = sys.argv[1:5]
lines = open(path, encoding="utf-8").read().split("\n")
start = lines.index(begin)
stop = lines.index(end)
new_lines = lines[:start] + block.split("\n") + lines[stop+1:]
open(path, "w", encoding="utf-8").write("\n".join(new_lines))
PYEOF
    else
      printf '\n%s\n' "$block" >> "$CODEX_CONFIG"
    fi
    log "  written"
  fi

  step "Writing the azure profile into $CODEX_AZURE_PROFILE"
  log "  Codex layers \`--profile <name>\` from its own \$CODEX_HOME/<name>.config.toml"
  log "  file, not a [profiles.<name>] table in config.toml — a [profiles.azure]"
  log "  table there is rejected as legacy config by the current CLI."
  if [[ -f "$CODEX_AZURE_PROFILE" ]] && ! head -1 "$CODEX_AZURE_PROFILE" | grep -qF "$AZURE_PROFILE_MARKER"; then
    echo "  $CODEX_AZURE_PROFILE already exists and wasn't written by this" >&2
    echo "  script — not touching it. Remove it or add the marker line" >&2
    echo "  '$AZURE_PROFILE_MARKER' as its first line, then re-run." >&2
    exit 1
  fi
  local profile_block
  profile_block=$(cat <<EOF
$AZURE_PROFILE_MARKER
model = "${DEPLOYMENT}"
model_provider = "azure"
sandbox_mode = "workspace-write"
approval_policy = "on-request"
EOF
)
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '%s\n' "$profile_block" | sed 's/^/  [dry-run] /'
  else
    printf '%s\n' "$profile_block" > "$CODEX_AZURE_PROFILE"
    log "  written"
  fi

  step "Verifying"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "  [dry-run] would run: codex --profile azure exec \"reply OK\""
  elif command -v codex &>/dev/null; then
    # exec reads stdin if it's left open, which hangs forever with no
    # controlling TTY (cron, CI, an agent invocation); < /dev/null plus a
    # bounded timeout keep this call from ever blocking indefinitely.
    if AZURE_OPENAI_API_KEY="$key" timeout 30 codex --profile azure exec "reply OK" \
        </dev/null &>/tmp/codex-azure-verify.log; then
      log "  PASS — codex --profile azure answered"
    else
      log "  FAIL — see /tmp/codex-azure-verify.log (key value itself is never in that log)"
    fi
  else
    log "  codex CLI not found — skipping live verification"
  fi
  log "  Use it with: codex --profile azure"
}

mode_opencode_azure() {
  step "OpenCode — add an azure provider (additive to the existing opencode.json)"
  prompt_resource_and_deployment

  local key
  key="$(resolve_azure_key)" || { echo "No key resolved — aborting." >&2; exit 1; }

  # OpenCode treats "azure" as its own built-in, Models.dev-backed provider
  # (npm/options overrides on a custom provider.azure entry are ignored for
  # this reserved id — confirmed against the real opencode-ai CLI). It reads
  # the key and resource name straight from AZURE_API_KEY / AZURE_RESOURCE_NAME
  # in the environment, not from anything in opencode.json — a different
  # variable name than Codex's env_key = "AZURE_OPENAI_API_KEY", same secret.
  step "Persisting AZURE_API_KEY and AZURE_RESOURCE_NAME for future shells"
  log "  OpenCode's built-in azure provider reads these two env vars directly;"
  log "  nothing in opencode.json ever holds the key itself."
  if [[ -z "${AZURE_API_KEY:-}" ]]; then
    persist_local_export "export AZURE_API_KEY='$key'"
  fi
  persist_local_export "export AZURE_RESOURCE_NAME='$RESOURCE_NAME'"

  step "Registering the ${DEPLOYMENT} deployment in $OPENCODE_CONFIG"
  log "  Only the deployment name is written here — never a key. This just"
  log "  tells OpenCode that '${DEPLOYMENT}' is a valid model under azure/."
  if ! python3 -c "
import json, sys
d = json.load(open('$OPENCODE_CONFIG'))
azure = d.get('provider', {}).get('azure')
# Safe to write when there's no existing entry, or the existing one is ours.
sys.exit(0 if azure is None or '_managed_by' in azure else 1)
"; then
    echo "  $OPENCODE_CONFIG already has an unmanaged provider.azure entry —" >&2
    echo "  not touching it. Remove it, or add \"_managed_by\": \"setup-model-provider.sh\"" >&2
    echo "  to it by hand, then re-run." >&2
    exit 1
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    log "  [dry-run] would merge provider.azure.models.${DEPLOYMENT} into opencode.json"
  else
    RESOURCE_NAME="$RESOURCE_NAME" DEPLOYMENT="$DEPLOYMENT" \
      node - "$OPENCODE_CONFIG" <<'NODEEOF'
const fs = require("node:fs");
const path = process.argv[2];
const cfg = JSON.parse(fs.readFileSync(path, "utf8"));
cfg.provider = cfg.provider || {};
cfg.provider.azure = {
  _managed_by: "setup-model-provider.sh",
  models: {
    [process.env.DEPLOYMENT]: { name: `${process.env.DEPLOYMENT} (Azure)` },
  },
};
fs.writeFileSync(path, JSON.stringify(cfg, null, 2) + "\n");
console.log("  written");
NODEEOF
  fi

  step "Verifying"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "  [dry-run] would run: opencode run -m azure/$DEPLOYMENT \"reply OK\""
  elif command -v opencode &>/dev/null; then
    if AZURE_API_KEY="$key" AZURE_RESOURCE_NAME="$RESOURCE_NAME" \
        timeout 30 opencode run -m "azure/$DEPLOYMENT" "reply OK" \
        </dev/null &>/tmp/opencode-azure-verify.log; then
      log "  PASS — opencode answered via the azure provider"
    else
      log "  FAIL — see /tmp/opencode-azure-verify.log (key value itself is never in that log)"
    fi
  else
    log "  opencode CLI not found — skipping live verification"
  fi
  log "  Use it with: opencode run -m azure/$DEPLOYMENT, or set it as the default model."
}

mode_status() {
  step "Codex"
  if [[ -f "$CODEX_CONFIG" ]]; then
    if grep -qF "$AZURE_BEGIN" "$CODEX_CONFIG" && [[ -f "$CODEX_AZURE_PROFILE" ]]; then
      log "  azure profile:       configured (codex --profile azure)"
    else
      log "  azure profile:       not configured"
    fi
    grep -q 'preferred_auth_method = "chatgpt"' "$CODEX_CONFIG" \
      && log "  chatgpt auth:        preferred_auth_method = chatgpt"
  else
    log "  $CODEX_CONFIG not found — run --codex-chatgpt or --codex-azure first"
  fi

  step "OpenCode"
  if [[ -f "$OPENCODE_CONFIG" ]] && grep -q '"azure"' "$OPENCODE_CONFIG" 2>/dev/null; then
    log "  azure provider:      configured in opencode.json"
  else
    log "  azure provider:      not configured"
  fi

  step "Environment (values never shown — only whether they're set)"
  if [[ -n "${AZURE_OPENAI_API_KEY:-}" ]]; then
    log "  AZURE_OPENAI_API_KEY: set (${#AZURE_OPENAI_API_KEY} chars) — Codex's env_key"
  else
    log "  AZURE_OPENAI_API_KEY: not set in this shell"
  fi
  if [[ -n "${AZURE_API_KEY:-}" ]]; then
    log "  AZURE_API_KEY:        set (${#AZURE_API_KEY} chars) — OpenCode's built-in azure provider"
  else
    log "  AZURE_API_KEY:        not set in this shell"
  fi
  log "  AZURE_RESOURCE_NAME:  ${AZURE_RESOURCE_NAME:-not set in this shell}"
}

case "$MODE" in
  status)         mode_status ;;
  codex-chatgpt)  mode_codex_chatgpt ;;
  codex-azure)    mode_codex_azure ;;
  opencode-azure) mode_opencode_azure ;;
esac
