# ssh

SSH client configuration for 1Password agent integration on macOS and Linux.

## Key Files

| File | Purpose |
|------|---------|
| `.ssh/config` | SSH client config with 1Password agent sockets |
| `.ssh/allowed_signers` | Maps email to public key for git signature verification |

## Agent Configuration

Uses `Match exec` directives to select the correct 1Password agent socket per OS:

| Platform | Match condition | Socket Path |
|----------|----------------|-------------|
| macOS | `uname \| grep -q Darwin` | `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` |
| Linux | `uname \| grep -q Linux` | `~/.1password/agent.sock` |

Only the matching platform block activates — no fallback guessing.

## Allowed Signers

Maps `rahulnakmol@gmail.com` to an ed25519 public key for verifying git commit signatures.

## Dependencies

1Password desktop app with SSH agent enabled, OpenSSH.
