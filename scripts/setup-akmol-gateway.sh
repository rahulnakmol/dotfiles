#!/usr/bin/env bash
# Configure one per-user Akmol AI gateway key for Claude Code, Codex, and
# OpenCode. The key is read from an existing mode-0600 file or a silent prompt;
# it is never accepted as a CLI argument, printed, or written into this repo.
set -euo pipefail

GATEWAY_URL="${AKMOL_GATEWAY_URL:-https://aigateway.akmols.host}"
CONFIG_DIR="$HOME/.config/akmol-gateway"
KEY_FILE="$CONFIG_DIR/client.key"
CODEX_HOME="$CONFIG_DIR/codex"
CLAUDE_HOME="$CONFIG_DIR/claude"
OPENCODE_CONFIG="$CONFIG_DIR/opencode.json"
BIN_DIR="$HOME/.local/bin"
MODE="setup"
USER_NAME="$(id -un)"

case "${1:-}" in
  "") ;;
  --status) MODE="status" ;;
  -h|--help)
    sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "Usage: $0 [--status]" >&2
    echo "The gateway key is intentionally never accepted as an argument." >&2
    exit 2
    ;;
esac

find_vendor_binary() {
  local name="$1" candidate path_without_local
  for candidate in \
    "/home/linuxbrew/.linuxbrew/bin/$name" \
    "/opt/homebrew/bin/$name" \
    "/usr/local/bin/$name" \
    "/usr/bin/$name"; do
    [[ -x "$candidate" ]] && { printf '%s\n' "$candidate"; return; }
  done

  path_without_local="$(printf '%s' "$PATH" | tr ':' '\n' | grep -vxF "$BIN_DIR" | paste -sd: -)"
  candidate="$(PATH="$path_without_local" command -v "$name" 2>/dev/null || true)"
  [[ -n "$candidate" && -x "$candidate" ]] || return 1
  printf '%s\n' "$candidate"
}

status() {
  local failed=0 file
  if [[ -s "$KEY_FILE" ]]; then
    printf 'gateway key: present (%s, mode %s)\n' "$KEY_FILE" "$(stat -c '%a' "$KEY_FILE" 2>/dev/null || stat -f '%Lp' "$KEY_FILE")"
  else
    echo "gateway key: absent"
    failed=1
  fi
  for file in claude codex opencode; do
    if [[ -x "$BIN_DIR/$file" ]]; then
      printf '%-16s configured\n' "$file"
    else
      printf '%-16s absent\n' "$file"
      failed=1
    fi
  done
  return "$failed"
}

if [[ "$MODE" == "status" ]]; then
  status
  exit
fi

claude_bin="$(find_vendor_binary claude)" || { echo "Claude Code CLI not found" >&2; exit 1; }
codex_bin="$(find_vendor_binary codex)" || { echo "Codex CLI not found" >&2; exit 1; }
opencode_bin="$(find_vendor_binary opencode)" || { echo "OpenCode CLI not found" >&2; exit 1; }

install -d -m 0700 "$CONFIG_DIR" "$CODEX_HOME" "$CLAUDE_HOME" "$BIN_DIR"
umask 077

if [[ -s "$KEY_FILE" ]]; then
  echo "Reusing the existing protected gateway key for $USER_NAME."
else
  [[ -t 0 ]] || {
    echo "No key exists and this is not an interactive terminal." >&2
    exit 1
  }
  IFS= read -r -s -p "Gateway key for $USER_NAME (input hidden): " key
  printf '\n'
  [[ -n "$key" ]] || { echo "Key cannot be empty." >&2; exit 1; }
  case "$key" in
    "sk-$USER_NAME-"*) ;;
    *)
      echo "Expected a high-entropy gateway key prefixed sk-$USER_NAME-." >&2
      unset key
      exit 1
      ;;
  esac
  printf '%s\n' "$key" > "$KEY_FILE"
  unset key
fi
chmod 0600 "$KEY_FILE"

models_json="$({
  printf 'header = "Authorization: Bearer %s"\n' "$(<"$KEY_FILE")"
  printf 'silent\nshow-error\nfail\nmax-time = 30\n'
} | curl --config - "$GATEWAY_URL/v1/models")"
if ! jq -e '.data | type == "array" and length > 0 and all(.[]; .id | type == "string" and length > 0)' \
    >/dev/null <<< "$models_json"; then
  echo "Gateway returned an invalid or empty model catalog." >&2
  exit 1
fi
model_count="$(jq '[.data[].id] | unique | length' <<< "$models_json")"
provider_models="$(jq -c '.data | map(.id) | unique | sort | map({key:., value:{}}) | from_entries' <<< "$models_json")"

cat > "$CODEX_HOME/config.toml" <<EOF
model_provider = "akmol"
model = "gpt-6-astra"

[model_providers.akmol]
name = "Akmol AI gateway ($USER_NAME)"
base_url = "$GATEWAY_URL/v1"
wire_api = "responses"
supports_websockets = false
request_max_retries = 0
stream_max_retries = 0
http_headers = { "User-Agent" = "Akmol-${USER_NAME}-Codex/1.0" }

[model_providers.akmol.auth]
command = "/bin/cat"
args = ["$KEY_FILE"]
cwd = "/"
timeout_ms = 5000
refresh_interval_ms = 300000
EOF

jq -n \
  --arg base "$GATEWAY_URL/v1" \
  --arg key_file "$KEY_FILE" \
  --arg user "$USER_NAME" \
  --argjson models "$provider_models" \
  '{
    "$schema":"https://opencode.ai/config.json",
    enabled_providers:["akmol"],
    provider:{akmol:{
      npm:"@ai-sdk/openai-compatible",
      name:("Akmol AI gateway (" + $user + ")"),
      options:{
        baseURL:$base,
        apiKey:("{file:" + $key_file + "}"),
        headers:{"User-Agent":("Akmol-" + $user + "-OpenCode/1.0")}
      },
      models:$models
    }},
    model:"akmol/gpt-6-astra"
  }' > "$OPENCODE_CONFIG"
chmod 0600 "$CODEX_HOME/config.toml" "$OPENCODE_CONFIG"

write_gateway_wrapper() {
  local path="$1" body="$2"
  printf '#!/usr/bin/env bash\nset -euo pipefail\n%s\n' "$body" > "$path"
  chmod 0700 "$path"
}

printf -v claude_body '%s\n%s\n%s\n%s\n%s' \
  "export ANTHROPIC_BASE_URL='$GATEWAY_URL'" \
  "export CLAUDE_CONFIG_DIR='$CLAUDE_HOME'" \
  'export ANTHROPIC_AUTH_TOKEN' \
  "ANTHROPIC_AUTH_TOKEN=\$(<'$KEY_FILE')" \
  "exec '$claude_bin' \"\$@\""
write_gateway_wrapper "$BIN_DIR/claude" "$claude_body"

printf -v codex_body '%s\n%s' \
  "export CODEX_HOME='$CODEX_HOME'" \
  "exec '$codex_bin' \"\$@\""
write_gateway_wrapper "$BIN_DIR/codex" "$codex_body"

printf -v opencode_body '%s\n%s' \
  "export OPENCODE_CONFIG='$OPENCODE_CONFIG'" \
  "exec '$opencode_bin' \"\$@\""
write_gateway_wrapper "$BIN_DIR/opencode" "$opencode_body"

for name in claude codex opencode; do
  ln -sfn "$BIN_DIR/$name" "$BIN_DIR/$name-akmol"
done

# Older revisions created direct-provider bypass commands. Remove them so the
# gateway-backed clients are the only managed entry points.
rm -f "$BIN_DIR/claude-direct" "$BIN_DIR/codex-direct" "$BIN_DIR/opencode-direct"

if command -v herdr >/dev/null 2>&1; then
  CLAUDE_CONFIG_DIR="$CLAUDE_HOME" herdr integration install claude >/dev/null
fi

echo "Configured Claude Code, Codex, and OpenCode to use $GATEWAY_URL for $USER_NAME."
echo "OpenCode catalog: $model_count gateway models."
status
