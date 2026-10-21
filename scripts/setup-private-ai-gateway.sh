#!/usr/bin/env bash
# Configure one per-user private AI gateway for Claude Code, Codex, and
# OpenCode, and make it the only route: the ~/.local/bin launchers refuse to run
# without ~/.config/private-ai-gateway/client.key (mode 0600), refuse
# subscription/account login subcommands, and strip provider overrides, so no
# request falls back to Anthropic, OpenAI, OpenCode Zen, or a cached session.
# The HTTPS endpoint and key are read from protected local files or
# interactive prompts; neither is accepted as a CLI argument or written here.
# Cursor desktop is independent; Cursor CLI is not part of this setup.
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
    sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
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
jq_bin="$(command -v jq)" || { echo "jq not found" >&2; exit 1; }

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

q_key_file=$(printf '%q' "$KEY_FILE")

# ── Codex: gateway-only. The built-in "openai" provider and the ChatGPT
# backend are also pointed at the gateway, so a provider override cannot fall
# back to api.openai.com or chatgpt.com.
cat > "$CODEX_HOME/config.toml" <<EOF
# Generated by setup-private-ai-gateway.sh — gateway-only Codex. Do not edit.
model_provider = "private_gateway"
model = $default_model_json
forced_login_method = "api"
openai_base_url = "$gateway_url/v1"
chatgpt_base_url = "$gateway_url/v1"
check_for_update_on_startup = false

[analytics]
enabled = false

[feedback]
enabled = false

# ChatGPT apps/connectors and in-app self-update need an OpenAI account.
[features]
apps = false
in_app_updates = false

[model_providers.private_gateway]
name = "Private AI gateway ($USER_NAME)"
base_url = "$gateway_url/v1"
wire_api = "responses"
requires_openai_auth = false
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

# ── OpenCode 2.0: the launcher passes this file as inline config
# (OPENCODE_CONFIG_CONTENT), the highest user-writable layer, so a project
# config cannot redirect the provider's endpoint or key. The provider
# allowlist is not taken from this layer: OpenCode uses enabled_providers from
# the global config, so the launcher requires the stowed global config to
# allow exactly private_gateway.
jq -n \
  --arg base "$gateway_url/v1" \
  --arg key_file "$KEY_FILE" \
  --arg user "$USER_NAME" \
  --arg default_model "$default_model" \
  --argjson models "$provider_models" \
  '{
    "$schema":"https://opencode.ai/config.json",
    share:"disabled",
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

# ── Wrappers. Each one fails closed: no key file, no run, and no subscription
# or account login subcommand. The key is read at exec time, never stored in
# the wrapper.
write_gateway_wrapper() {
  local path="$1" tool="$2"
  {
    printf '#!/usr/bin/env bash\n'
    printf '# Generated by setup-private-ai-gateway.sh — gateway-only %s. Do not edit.\n' "$tool"
    printf 'set -euo pipefail\n'
    printf 'key_file=%s\n' "$q_key_file"
    cat <<'EOF'
refuse() { echo "${0##*/}: $*; this host uses only the private AI gateway." >&2; exit 64; }
mode=$(stat -c '%a' "$key_file" 2>/dev/null || stat -f '%Lp' "$key_file" 2>/dev/null || true)
if [[ -L $key_file || ! -s $key_file || $mode != 600 ]]; then
  echo "${0##*/}: gateway key $key_file is missing, empty, a symlink, or not mode 0600; refusing to run (no fallback provider)." >&2
  exit 78
fi
EOF
    cat
  } > "$path"
  chmod 0700 "$path"
}

write_gateway_wrapper "$BIN_DIR/claude" "Claude Code" <<EOF
case "\${1:-}" in
  auth|setup-token) refuse "'claude \$1' (Claude subscription/Console login) is disabled" ;;
esac
# Drop every credential and provider switch that could bypass the gateway.
while IFS= read -r name; do
  case \$name in
    ANTHROPIC_API_KEY|ANTHROPIC_PROFILE|ANTHROPIC_FEDERATION_RULE_ID|ANTHROPIC_ORGANIZATION_ID|\\
    ANTHROPIC_WORKSPACE_ID|ANTHROPIC_BEDROCK_*|ANTHROPIC_VERTEX_*|ANTHROPIC_FOUNDRY_*|ANTHROPIC_AWS_*|\\
    CLAUDE_CODE_USE_*|CLAUDE_CODE_OAUTH_*|CLAUDE_CODE_SKIP_*AUTH|AWS_BEARER_TOKEN_BEDROCK) unset "\$name" ;;
  esac
done < <(compgen -e)
export ANTHROPIC_BASE_URL='$gateway_url'
export CLAUDE_CONFIG_DIR=$(printf '%q' "$CLAUDE_HOME")
# The wrapper owns routing: settings files (user, project, --settings) cannot
# change the endpoint or credential, and nothing else is sent to Anthropic.
export CLAUDE_CODE_PROVIDER_MANAGED_BY_HOST=1
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 DISABLE_AUTOUPDATER=1 ENABLE_CLAUDEAI_MCP_SERVERS=false
ANTHROPIC_AUTH_TOKEN=\$(<"\$key_file")
export ANTHROPIC_AUTH_TOKEN
exec $(printf '%q' "$claude_bin") "\$@"
EOF

write_gateway_wrapper "$BIN_DIR/codex" "Codex" <<EOF
check_override() {
  case "\${1%%=*}" in
    model_provider|model_providers*|openai_base_url|chatgpt_base_url|forced_login_method|\\
    forced_chatgpt_workspace_id|cli_auth_credentials_store|oss_provider|profile|profiles*)
      refuse "config override '\${1%%=*}' could bypass the gateway and is disabled" ;;
  esac
}
expect="" sub=""
for arg in "\$@"; do
  if [[ -n \$expect ]]; then
    [[ \$expect == config ]] && check_override "\$arg"
    expect=""; continue
  fi
  case \$arg in
    --) break ;;
    --oss|--local-provider|--local-provider=*|-p|--profile|--profile=*) refuse "'\$arg' selects a non-gateway provider or profile" ;;
    -c|--config) expect=config ;;
    --config=*) check_override "\${arg#--config=}" ;;
    -c?*) check_override "\${arg#-c}" ;;
    -m|--model|-s|--sandbox|-a|--ask-for-approval|-C|--cd|-i|--image|--add-dir|--enable|--disable|\\
    --color|-o|--output-last-message|--output-schema) expect=value ;;
    -*) ;;
    *) [[ -z \$sub ]] && sub=\$arg ;;
  esac
done
case \$sub in
  login|logout) refuse "'codex \$sub' (ChatGPT/OpenAI account login) is disabled" ;;
  cloud) refuse "'codex cloud' needs a ChatGPT account and is disabled" ;;
esac
unset OPENAI_API_KEY OPENAI_BASE_URL OPENAI_ORG_ID OPENAI_PROJECT_ID CODEX_API_KEY AZURE_OPENAI_API_KEY
export CODEX_HOME=$(printf '%q' "$CODEX_HOME")
exec $(printf '%q' "$codex_bin") "\$@"
EOF

write_gateway_wrapper "$BIN_DIR/opencode" "OpenCode" <<EOF
[[ \${1:-} == auth ]] && refuse "'opencode auth' (provider credentials) is disabled"
global_config=\${XDG_CONFIG_HOME:-\$HOME/.config}/opencode/opencode.json
if ! $(printf '%q' "$jq_bin") -e '.enabled_providers == ["private_gateway"]' "\$global_config" >/dev/null 2>&1; then
  echo "\${0##*/}: \$global_config must set enabled_providers to exactly [\"private_gateway\"] (stow the opencode module); refusing to run." >&2
  exit 78
fi
# OPENCODE_CONFIG_DIR replaces the global config, including that allowlist.
unset OPENCODE_CONFIG_DIR
OPENCODE_CONFIG_CONTENT=\$(<$(printf '%q' "$OPENCODE_CONFIG"))
# The gateway catalog is inline, so skip the models.dev/api.opencode.ai fetch.
export OPENCODE_CONFIG_CONTENT OPENCODE_DISABLE_AUTOUPDATE=1 OPENCODE_DISABLE_MODELS_FETCH=1
# OpenCode 2.0.30 ignores an agent's configured model for \`run --agent NAME\`
# (anomalyco/opencode#42561) and uses the default model. Pass the agent's
# model and variant explicitly unless the command already chooses one.
if [[ \${1:-} == run ]]; then
  agent="" model_set=0 prev=""
  for arg in "\$@"; do
    [[ \$prev == --agent ]] && agent=\$arg
    case \$arg in
      -m|--model|--model=*|-m?*) model_set=1 ;;
      --agent=*) agent=\${arg#--agent=} ;;
    esac
    prev=\$arg
  done
  if [[ -n \$agent && \$model_set == 0 ]]; then
    agent_model=\$($(printf '%q' "$jq_bin") -r --arg a "\$agent" '.agents[\$a].model // empty' "\$global_config")
    [[ -n \$agent_model ]] && set -- run --model "\$agent_model" "\${@:2}"
  fi
fi
exec $(printf '%q' "$opencode_bin") "\$@"
EOF

# Older revisions created direct-provider bypass commands. Remove them so the
# gateway-backed clients are the only managed entry points.
rm -f \
  "$BIN_DIR/claude-direct" "$BIN_DIR/codex-direct" "$BIN_DIR/opencode-direct"

if command -v herdr >/dev/null 2>&1; then
  CLAUDE_CONFIG_DIR="$CLAUDE_HOME" herdr integration install claude >/dev/null
fi

# OpenCode's background service listens on one fixed default port, so a second
# OS user's service could not start. Give each user its own port, kept in the
# local, git-ignored ~/.config/opencode/service.json. The running service keeps
# the config it started with, so stop it; the next command restarts it through
# the launcher with the new inline config.
if ! "$opencode_bin" service get 2>/dev/null | jq -e '.port' >/dev/null; then
  "$opencode_bin" service set port "$((49384 + $(id -u) % 1000))" >/dev/null
fi
"$BIN_DIR/opencode" service stop >/dev/null 2>&1 || true

echo "Configured Claude Code, Codex, and OpenCode to use only $gateway_url for $USER_NAME."
echo "OpenCode catalog: $model_count gateway models."
status
