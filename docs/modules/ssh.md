# ssh

SSH client configuration for 1Password agent integration on macOS and Linux.

## Key Files

| File | Purpose |
|------|---------|
| `.ssh/config` | SSH client config with 1Password agent sockets |
| `.ssh/allowed_signers` | Maps email to public key for git signature verification |

## Agent Configuration

Two `Host *` blocks provide 1Password SSH agent support across platforms:

| Platform | Socket Path |
|----------|-------------|
| macOS | `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` |
| Linux | `~/.1password/agent.sock` |

SSH will try both paths; the one that exists on the current system is used.

## Allowed Signers

Maps `rahulnakmol@gmail.com` to an ed25519 public key for verifying git commit signatures.

## Dependencies

1Password desktop app with SSH agent enabled, OpenSSH.
