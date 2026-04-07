# ssh

SSH client configuration for 1Password agent integration on Linux.

## Key Files

| File | Purpose |
|------|---------|
| `.ssh/config` | SSH client config with 1Password agent sockets |
| `.ssh/allowed_signers` | Maps email to public key for git signature verification |

## Agent Configuration

A single `Host *` block points to the 1Password SSH agent socket:

| Setting | Value |
|---------|-------|
| `IdentityAgent` | `~/.1password/agent.sock` |

## Allowed Signers

Maps `rahulnakmol@gmail.com` to an ed25519 public key for verifying git commit signatures.

## Dependencies

1Password desktop app with SSH agent enabled, OpenSSH.
