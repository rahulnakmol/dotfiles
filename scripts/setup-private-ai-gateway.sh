#!/usr/bin/env bash
# Configure one per-user private AI gateway for Claude Code, Codex, and
# OpenCode. The HTTPS endpoint and key are read from protected local files or
# interactive prompts; neither is accepted as a CLI argument or written here.
# Cursor CLI is intentionally unsupported: its API key and endpoint configure
# Cursor's proprietary service, not an OpenAI-compatible model provider.
set -euo pipefail

CONFIG_DIR="$HOME/.config/private-ai-gateway"
ENDPOINT_FILE="$CONFIG_DIR/endpoint"
KEY_FILE="$CONFIG_DIR/client.key"
MODEL_FILE="$CONFIG_DIR/default-model"
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
  if [[ -s "$ENDPOINT_FILE" ]]; then
    printf 'gateway endpoint: %s\n' "$(<"$ENDPOINT_FILE")"
  else
    echo "gateway endpoint: absent"
    failed=1
  fi
  if [[ -s "$KEY_FILE" ]]; then
    printf 'gateway key: present (%s, mode %s)\n' "$KEY_FILE" "$(stat -c '%a' "$KEY_FILE" 2>/dev/null || stat -f '%Lp' "$KEY_FILE")"
  else
    echo "gateway key: absent"
    failed=1
  fi
  if [[ -s "$MODEL_FILE" ]]; then
    printf 'default model: %s\n' "$(<"$MODEL_FILE")"
  else
    echo "default model: absent"
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

if [[ -n "${PRIVATE_AI_GATEWAY_URL:-}" ]]; then
  gateway_url="$PRIVATE_AI_GATEWAY_URL"
elif [[ -s "$ENDPOINT_FILE" ]]; then
  gateway_url="$(<"$ENDPOINT_FILE")"
else
  [[ -t 0 ]] || {
    echo "No gateway endpoint exists and this is not an interactive terminal." >&2
    echo "Set PRIVATE_AI_GATEWAY_URL or run interactively." >&2
    exit 1
  }
  IFS= read -r -p "Private AI gateway HTTPS endpoint (without /v1): " gateway_url
fi
gateway_url="${gateway_url%/}"
gateway_url="${gateway_url%/v1}"
[[ "$gateway_url" =~ ^https://[A-Za-z0-9._~%:-]+(/[A-Za-z0-9._~%/+:-]*)?$ ]] || {
  echo "Gateway endpoint must be a plain HTTPS origin or path without query parameters." >&2
  exit 1
}
printf '%s\n' "$gateway_url" > "$ENDPOINT_FILE"
chmod 0600 "$ENDPOINT_FILE"

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
  printf '%s\n' "$key" > "$KEY_FILE"
  unset key
fi
chmod 0600 "$KEY_FILE"

models_json="$({
  printf 'header = "Authorization: Bearer %s"\n' "$(<"$KEY_FILE")"
  printf 'silent\nshow-error\nfail\nmax-time = 30\n'
} | curl --config - "$gateway_url/v1/models")"
if ! jq -e '.data | type == "array" and length > 0 and all(.[]; .id | type == "string" and length > 0)' \
    >/dev/null <<< "$models_json"; then
  echo "Gateway returned an invalid or empty model catalog." >&2
  exit 1
fi
model_count="$(jq '[.data[].id] | unique | length' <<< "$models_json")"
provider_models="$(jq -c '.data | map(.id) | unique | sort | map({key:., value:{}}) | from_entries' <<< "$models_json")"

if [[ -n "${PRIVATE_AI_GATEWAY_MODEL:-}" ]]; then
  default_model="$PRIVATE_AI_GATEWAY_MODEL"
elif [[ -s "$MODEL_FILE" ]]; then
  default_model="$(<"$MODEL_FILE")"
else
  [[ -t 0 ]] || {
    echo "No default model exists and this is not an interactive terminal." >&2
    echo "Set PRIVATE_AI_GATEWAY_MODEL or run interactively." >&2
    exit 1
  }
  echo "Available models:"
  jq -r '.data[].id' <<< "$models_json" | sort -u | sed 's/^/  /'
  IFS= read -r -p "Default model for Codex and OpenCode: " default_model
fi
if ! jq -e --arg model "$default_model" 'any(.data[]; .id == $model)' >/dev/null <<< "$models_json"; then
  echo "Default model '$default_model' is not advertised by the gateway." >&2
  exit 1
fi
default_model_json="$(jq -Rn --arg value "$default_model" '$value')"
printf '%s\n' "$default_model" > "$MODEL_FILE"
chmod 0600 "$MODEL_FILE"

cat > "$CODEX_HOME/config.toml" <<EOF
model_provider = "private_gateway"
model = $default_model_json

[model_providers.private_gateway]
name = "Private AI gateway ($USER_NAME)"
base_url = "$gateway_url/v1"
wire_api = "responses"
supports_websockets = false
request_max_retries = 0
stream_max_retries = 0
http_headers = { "User-Agent" = "PrivateGateway-${USER_NAME}-Codex/1.0" }

[model_providers.private_gateway.auth]
command = "/bin/cat"
args = ["$KEY_FILE"]
cwd = "/"
timeout_ms = 5000
refresh_interval_ms = 300000
EOF

jq -n \
  --arg base "$gateway_url/v1" \
  --arg key_file "$KEY_FILE" \
  --arg user "$USER_NAME" \
  --arg default_model "$default_model" \
  --argjson models "$provider_models" \
  '{
    "$schema":"https://opencode.ai/config.json",
    enabled_providers:["private_gateway"],
    provider:{private_gateway:{
      npm:"@ai-sdk/openai-compatible",
      name:("Private AI gateway (" + $user + ")"),
      options:{
        baseURL:$base,
        apiKey:("{file:" + $key_file + "}"),
        headers:{"User-Agent":("PrivateGateway-" + $user + "-OpenCode/1.0")}
      },
      models:$models
    }},
    model:("private_gateway/" + $default_model)
  }' > "$OPENCODE_CONFIG"
chmod 0600 "$CODEX_HOME/config.toml" "$OPENCODE_CONFIG"

write_gateway_wrapper() {
  local path="$1" body="$2"
  printf '#!/usr/bin/env bash\nset -euo pipefail\n%s\n' "$body" > "$path"
  chmod 0700 "$path"
}

printf -v claude_body '%s\n%s\n%s\n%s\n%s' \
  "export ANTHROPIC_BASE_URL='$gateway_url'" \
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

# Older revisions created direct-provider bypass commands. Remove them so the
# gateway-backed clients are the only managed entry points.
rm -f \
  "$BIN_DIR/claude-direct" "$BIN_DIR/codex-direct" "$BIN_DIR/opencode-direct"

if command -v herdr >/dev/null 2>&1; then
  CLAUDE_CONFIG_DIR="$CLAUDE_HOME" herdr integration install claude >/dev/null
fi

echo "Configured Claude Code, Codex, and OpenCode to use $gateway_url for $USER_NAME."
echo "OpenCode catalog: $model_count gateway models."
status
