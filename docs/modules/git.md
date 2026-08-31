# git

Git configuration with commit signing configured **per machine, on demand** — not hardcoded to
1Password or any other single signer.

## Key Files

| File | Purpose |
|------|---------|
| `.config/git/config` | User identity, signing fallback, includes |
| `.config/git/config-credential` | HTTPS credential helper (`gh`) |
| `.config/git/ignore` | Global gitignore patterns |

`config` includes two files that are **not** part of this repo, both gitignored:

| Include | Written by |
|---------|-----------|
| `~/.config/git/config-credential` | this module (real content, just not committed the same way) |
| `~/.config/git/config.local` | `scripts/setup-signing-key.sh` |

## Commit signing — three modes

`commit.gpgsign`/`tag.gpgsign` are `true` in the committed config, deliberately: an unconfigured
machine refuses to commit rather than silently producing unsigned work. Until
`scripts/setup-signing-key.sh` has run, `gpg.ssh.defaultKeyCommand` points at
`scripts/git-sign-unconfigured`, which turns git's generic
`gpg.ssh.defaultKeyCommand needs to be configured` into the actual fix.

Run one of:

```bash
./scripts/setup-signing-key.sh --status      # what's active on this machine right now
./scripts/setup-signing-key.sh --local       # generate an on-disk signing key, no 1Password
./scripts/setup-signing-key.sh --1password   # use the 1Password SSH agent (native or WSL)
./scripts/setup-signing-key.sh --auto        # 1Password if available, else --local
```

`--local` generates a passphrase-less, signing-only ed25519 key (safe: no passphrase because
nothing else holds it, and it grants no access anywhere — it only signs), registers it with GitHub
as a **signing** key (distinct from an SSH auth key), appends it to `ssh/.ssh/allowed_signers`, and
self-verifies by signing and checking a throwaway commit before reporting success.

`--rotate` replaces an existing on-disk key while keeping the old public key in
`allowed_signers`, so commits already signed with it keep verifying.

## User Configuration

| Setting | Value |
|---------|-------|
| Name | Rahul N Akmol |
| Email | rahulnakmol@gmail.com |
| Signing key | per machine — see `~/.config/git/config.local` |

## Global Ignore

```
**/.claude/settings.local.json
```

## Dependencies

`ssh-keygen` (local signing), `gh` (GitHub signing-key registration, optional), 1Password desktop
app (only for `--1password` mode).
