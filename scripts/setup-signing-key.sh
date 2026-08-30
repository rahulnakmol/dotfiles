#!/usr/bin/env bash
# setup-signing-key.sh — configure git commit signing for this machine,
# without depending on 1Password being installed.
#
# Signing is force-on in the committed git config (commit.gpgsign = true).
# This script is what turns a fresh machine from "refuses to commit, tells
# you why" into "signs every commit" — by writing the signer into
# ~/.config/git/config.local, which git/.config/git/config includes last.
#
# Usage:
#   ./scripts/setup-signing-key.sh [MODE] [OPTIONS]
#
# Modes (default: --status)
#   --status      Report what's active on this machine. Changes nothing.
#   --local       Generate (or reuse) an on-disk signing key for this host,
#                 add it to allowed_signers, and register it with GitHub.
#   --1password   Point this host at the 1Password SSH agent, auto-locating
#                 the signer binary (native Linux or the WSL/Windows path).
#   --auto        Use 1Password if a working agent is found, else --local.
#
# Options
#   --rotate               Replace the existing on-disk key. The old public
#                           key stays in allowed_signers so commits already
#                           signed with it keep verifying.
#   --no-github             Skip GitHub signing-key registration.
#   --no-allowed-signers    Don't touch ~/.ssh/allowed_signers.
#   --dry-run               Print what would happen; change nothing.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY_PATH="$HOME/.ssh/id_ed25519_signing"
CONFIG_LOCAL="$HOME/.config/git/config.local"
ALLOWED_SIGNERS="$HOME/.ssh/allowed_signers"
HOST="$(hostname -s 2>/dev/null || hostname)"
EMAIL="$(git config --global user.email 2>/dev/null || true)"
[[ -n "$EMAIL" ]] || EMAIL="$(git -C "$ROOT" config user.email 2>/dev/null || echo "unknown@example.invalid")"

BEGIN_MARK="# BEGIN dotfiles signing (managed by setup-signing-key.sh — do not hand-edit this block)"
END_MARK="# END dotfiles signing"

MODE=""
DRY_RUN=0
DO_ROTATE=0
DO_GITHUB=1
DO_ALLOWED_SIGNERS=1

for arg in "$@"; do
  case "$arg" in
    --status)              MODE="status" ;;
    --local)                MODE="local" ;;
    --1password)             MODE="1password" ;;
    --auto)                MODE="auto" ;;
    --rotate)               DO_ROTATE=1 ;;
    --no-github)            DO_GITHUB=0 ;;
    --no-allowed-signers)   DO_ALLOWED_SIGNERS=0 ;;
    --dry-run)              DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,27p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2 ;;
  esac
done
[[ -n "$MODE" ]] || MODE="status"

log()  { printf '%s\n' "$*"; }
step() { printf '\n→ %s\n' "$*"; }
run()  {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '  [dry-run] would run: %s\n' "$*"
  else
    "$@"
  fi
}

# ── allowed_signers is very often a stow symlink into this dotfiles repo.
#    Appending to it writes into the working tree — that is intentional
#    (it's how the key gets committed), but the user needs to know.
notice_if_in_repo() {
  local target
  target="$(readlink -f "$ALLOWED_SIGNERS" 2>/dev/null || echo "$ALLOWED_SIGNERS")"
  case "$target" in
    "$ROOT"/*)
      log "  (this is a stow symlink into $ROOT — commit the change there)" ;;
  esac
}

append_allowed_signers() {
  local pubkey_line="$1" comment="$2"
  [[ "$DO_ALLOWED_SIGNERS" == "1" ]] || { log "  (skipping allowed_signers: --no-allowed-signers)"; return; }
  mkdir -p "$(dirname "$ALLOWED_SIGNERS")"
  touch "$ALLOWED_SIGNERS" 2>/dev/null || true
  if [[ -f "$ALLOWED_SIGNERS" ]] && grep -qF "$pubkey_line" "$ALLOWED_SIGNERS" 2>/dev/null; then
    log "  allowed_signers already has this key"
    return
  fi
  step "Adding to $ALLOWED_SIGNERS"
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '  [dry-run] would append: # %s\n  [dry-run] would append: %s\n' "$comment" "$pubkey_line"
  else
    { printf '# %s\n%s\n' "$comment" "$pubkey_line"; } >> "$ALLOWED_SIGNERS"
    log "  appended"
  fi
  notice_if_in_repo
}

# ── Write (or update) the managed block in ~/.config/git/config.local,
#    leaving any hand-added content around it untouched.
write_config_local() {
  local program="$1" signingkey="$2"
  local block
  block="$BEGIN_MARK
[user]
	signingkey = $signingkey"
  # Omit the program key entirely when there's no explicit signer — writing
  # `program = ` (empty) makes git try to execute nothing at all. Omitting it
  # lets git fall back to its own default (ssh-keygen), which is what a
  # locally-generated key needs. Only 1Password mode passes a real program.
  if [[ -n "$program" ]]; then
    block="$block
[gpg \"ssh\"]
	program = $program"
  fi
  block="$block
[commit]
	gpgsign = true
[tag]
	gpgsign = true
$END_MARK"
  step "Writing $CONFIG_LOCAL"
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '%s\n' "$block" | sed 's/^/  [dry-run] /'
    return
  fi
  mkdir -p "$(dirname "$CONFIG_LOCAL")"
  touch "$CONFIG_LOCAL"
  if grep -qF "$BEGIN_MARK" "$CONFIG_LOCAL" 2>/dev/null; then
    # Replace the existing managed block in place, keep everything else.
    local tmp; tmp="$(mktemp)"
    awk -v begin="$BEGIN_MARK" -v end="$END_MARK" '
      $0 == begin { skip=1; next }
      $0 == end   { skip=0; next }
      !skip { print }
    ' "$CONFIG_LOCAL" > "$tmp"
    { cat "$tmp"; [[ -s "$tmp" ]] && echo; printf '%s\n' "$block"; } > "$CONFIG_LOCAL"
    rm -f "$tmp"
  else
    local needs_blank=0
    [[ -s "$CONFIG_LOCAL" ]] && needs_blank=1
    { [[ "$needs_blank" == "1" ]] && echo; printf '%s\n' "$block"; } >> "$CONFIG_LOCAL"
  fi
  log "  done"
}

# ── GitHub signing-key registration. Distinct endpoint/scope from an auth key.
register_github() {
  local pubkey_path="$1" title="$2"
  [[ "$DO_GITHUB" == "1" ]] || { log "  (skipping GitHub: --no-github)"; return; }
  if ! command -v gh &>/dev/null; then
    log "  gh not found — skipping GitHub registration (add manually: github.com/settings/ssh/new, key type 'Signing Key')"
    return
  fi
  step "Registering with GitHub as a signing key"
  if ! gh auth status &>/dev/null; then
    log "  gh is not logged in — run: gh auth login"
    return
  fi
  if ! gh auth status 2>&1 | grep -q 'admin:ssh_signing_key'; then
    log "  Missing the admin:ssh_signing_key scope."
    log "  Run: gh auth refresh -h github.com -s admin:ssh_signing_key"
    log "  Then re-run this script."
    return
  fi
  local fp
  fp="$(ssh-keygen -lf "$pubkey_path" 2>/dev/null | awk '{print $2}')"
  if gh api /user/ssh_signing_keys 2>/dev/null | grep -qF "$fp"; then
    log "  already registered ($fp)"
    return
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    log "  [dry-run] would run: gh ssh-key add $pubkey_path --type signing --title \"$title\""
    return
  fi
  if gh ssh-key add "$pubkey_path" --type signing --title "$title" 2>/dev/null; then
    log "  registered via gh ssh-key add"
  else
    # Older gh without --type signing support.
    local key; key="$(cat "$pubkey_path")"
    if gh api -X POST /user/ssh_signing_keys -f "title=$title" -f "key=$key" &>/dev/null; then
      log "  registered via gh api (gh ssh-key add --type signing unsupported on this gh version)"
    else
      log "  registration failed — add manually: github.com/settings/ssh/new, key type 'Signing Key'"
    fi
  fi
}

# ── Prove the signer actually works, rather than just claiming it does.
self_verify() {
  local program="$1" signingkey="$2"
  step "Verifying: signing a throwaway commit"
  local tmp; tmp="$(mktemp -d)"
  trap '[[ -n "${tmp:-}" ]] && rm -rf "$tmp"' RETURN
  (
    cd "$tmp"
    git init -q .
    git config gpg.format ssh
    [[ -n "$program" ]] && git config gpg.ssh.program "$program"
    git config gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS"
    git config user.email "$EMAIL"
    git config user.name "signing self-test"
    git config user.signingkey "$signingkey"
    git commit -q --allow-empty -S -m "signing self-test"
    git log --show-signature -1 2>&1
  ) > "$tmp/out.log" 2>&1
  if grep -qE 'Good "git" signature' "$tmp/out.log"; then
    log "  PASS — signature verifies"
  else
    log "  FAIL — signature did not verify:"
    sed 's/^/    /' "$tmp/out.log"
    return 1
  fi
}

mode_local() {
  step "Local on-disk signing key for $HOST"
  if [[ -f "$KEY_PATH" && "$DO_ROTATE" == "1" ]]; then
    local backup
    backup="${KEY_PATH}.rotated-$(date +%Y%m%d%H%M%S)"
    step "Rotating: moving existing key to $backup"
    run mv "$KEY_PATH" "$backup"
    run mv "${KEY_PATH}.pub" "${backup}.pub"
  fi
  if [[ ! -f "$KEY_PATH" ]]; then
    step "Generating $KEY_PATH"
    run mkdir -p "$(dirname "$KEY_PATH")"
    [[ "$DRY_RUN" == "1" ]] || chmod 700 "$(dirname "$KEY_PATH")"
    run ssh-keygen -t ed25519 -N "" -C "${EMAIL}-${HOST}-signing" -f "$KEY_PATH"
    [[ "$DRY_RUN" == "1" ]] || chmod 600 "$KEY_PATH"
  else
    log "  reusing existing key ($KEY_PATH)"
  fi

  local pubkey_path
  pubkey_path="${KEY_PATH}.pub"
  if [[ "$DRY_RUN" == "1" && ! -f "$pubkey_path" ]]; then
    log "  (dry-run: no key on disk yet to read/register — steps below are illustrative)"
    return
  fi
  local key_only; key_only="$(awk '{print $1" "$2}' "$pubkey_path")"

  # user.signingkey = the PRIVATE key path — this key has no passphrase and
  # no agent is assumed, so git (via ssh-keygen -Y sign) needs the file
  # directly. allowed_signers and GitHub registration still use the PUBLIC
  # half, which is what those actually check against.
  write_config_local "" "$KEY_PATH"
  append_allowed_signers "$EMAIL $key_only" "${HOST}: signing-only key, on-disk"
  register_github "$pubkey_path" "${HOST} (signing)"
  self_verify "" "$KEY_PATH" || true
}

find_op_ssh_sign() {
  local candidates=(
    "/opt/1Password/op-ssh-sign"
  )
  if [[ -n "${DOTFILES_WSL:-}" ]]; then
    local u
    for u in /mnt/c/Users/*/AppData/Local/1Password/app/*/op-ssh-sign.exe; do
      candidates+=("$u")
    done
  fi
  local c
  for c in "${candidates[@]}"; do
    [[ -x "$c" ]] && { echo "$c"; return 0; }
  done
  return 1
}

mode_1password() {
  step "1Password SSH agent as signer"
  local program
  if ! program="$(find_op_ssh_sign)"; then
    log "  No op-ssh-sign binary found (checked native Linux and, on WSL, the"
    log "  Windows 1Password install). Falling back is your call — run with"
    log "  --local instead if 1Password isn't set up on this machine."
    return 1
  fi
  log "  found: $program"
  if [[ ! -f "$HOME/.ssh/allowed_signers" ]] && [[ "$DO_ALLOWED_SIGNERS" == "1" ]]; then
    log "  note: allowed_signers doesn't exist yet — add your 1Password public"
    log "  key to it manually (this script doesn't know it without the agent)."
  fi
  # We don't generate a key here — 1Password already holds one. We only need
  # its public half to write config.local; ask the agent for it.
  local pubkey_line=""
  if command -v ssh-add &>/dev/null && [[ -S "${SSH_AUTH_SOCK:-}" ]]; then
    pubkey_line="$(ssh-add -L 2>/dev/null | head -1 | awk '{print $1" "$2}')"
  fi
  if [[ -z "$pubkey_line" ]]; then
    log "  Could not read a public key from the running SSH agent (SSH_AUTH_SOCK)."
    log "  Open 1Password, enable the SSH agent, then re-run."
    return 1
  fi
  write_config_local "$program" "$pubkey_line"
  self_verify "$program" "$pubkey_line" || true
}

mode_auto() {
  step "Auto: trying 1Password first"
  if mode_1password; then
    return
  fi
  step "1Password unavailable — falling back to --local"
  mode_local
}

mode_status() {
  step "Signing status for $HOST"
  local cfg_signer cfg_key
  cfg_signer="$(git config --file "$CONFIG_LOCAL" gpg.ssh.program 2>/dev/null || true)"
  cfg_key="$(git config --file "$CONFIG_LOCAL" user.signingkey 2>/dev/null || true)"

  if [[ -z "$cfg_key" ]]; then
    log "  configured signer:   none — commits will fail (see the fallback message)"
    return
  fi

  log "  configured signer:   ${cfg_signer:-ssh-keygen (agent-less: --local mode)}"
  log "  signing key:         $cfg_key"

  # user.signingkey is a private key PATH under --local (agent-less signing)
  # or a public key BLOB under --1password (agent does the signing).
  # allowed_signers, the fingerprint, and GitHub all key off the public half.
  local pub_content=""
  if [[ -f "$cfg_key" ]]; then
    [[ -f "${cfg_key}.pub" ]] && pub_content="$(cat "${cfg_key}.pub")"
  else
    pub_content="$cfg_key"
  fi

  local fp=""
  if [[ -n "$pub_content" ]] && command -v ssh-keygen &>/dev/null; then
    fp="$(ssh-keygen -lf /dev/stdin <<<"$pub_content" 2>/dev/null | awk '{print $2}' || true)"
    [[ -n "$fp" ]] && log "  fingerprint:         $fp"
  fi

  if [[ -n "$pub_content" && -f "$ALLOWED_SIGNERS" ]] \
      && grep -qF "$(awk '{print $1" "$2}' <<<"$pub_content")" "$ALLOWED_SIGNERS" 2>/dev/null; then
    log "  in allowed_signers:  yes"
  else
    log "  in allowed_signers:  no"
  fi

  if command -v gh &>/dev/null && gh auth status &>/dev/null; then
    if [[ -n "$fp" ]] && gh api /user/ssh_signing_keys 2>/dev/null | grep -qF "$fp"; then
      log "  on GitHub:           yes"
    else
      log "  on GitHub:           no (or gh not authorized to check)"
    fi
  else
    log "  on GitHub:           unknown (gh not available or not logged in)"
  fi

  self_verify "$cfg_signer" "$cfg_key" || true
}

case "$MODE" in
  status)     mode_status ;;
  local)      mode_local ;;
  1password)  mode_1password ;;
  auto)       mode_auto ;;
esac
