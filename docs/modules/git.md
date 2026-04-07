# git

Git configuration with SSH commit signing via 1Password.

## Key Files

| File | Purpose |
|------|---------|
| `.config/git/config` | User identity, GPG/SSH signing settings |
| `.config/git/ignore` | Global gitignore patterns |

## User Configuration

| Setting | Value |
|---------|-------|
| Name | Rahul N Akmol |
| Email | rahulnakmol@gmail.com |
| Signing key | `ssh-ed25519 AAAAC3...NIvD` |

## Commit Signing

All commits and tags are signed using SSH keys managed by 1Password.

| Setting | Value |
|---------|-------|
| `gpg.format` | `ssh` |
| `gpg.ssh.program` | `/opt/1Password/op-ssh-sign` |
| `gpg.ssh.allowedSignersFile` | `~/.ssh/allowed_signers` |
| `commit.gpgsign` | `true` |
| `tag.gpgsign` | `true` |

## Global Ignore

```
**/.claude/settings.local.json
```

## Dependencies

1Password desktop app (provides `op-ssh-sign`), SSH key stored in 1Password vault.
