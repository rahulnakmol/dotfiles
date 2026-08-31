# ssh

SSH client configuration for 1Password agent integration, on native Linux and WSL alike.

## Key Files

| File | Purpose |
|------|---------|
| `.ssh/config` | SSH client config, agent claimed only when actually running |
| `.ssh/allowed_signers` | Maps email to public key(s) for git signature verification |

## Agent Configuration

```
Match host * exec "test -S %d/.1password/agent.sock"
    IdentityAgent ~/.1password/agent.sock
```

`%d` is OpenSSH's token for the local user's home directory. This claims the socket **only** when
it actually exists — an unconditional `IdentityAgent` broke SSH outright on any box where
1Password wasn't running (or, on WSL, where the socket hadn't been bridged from Windows yet). Works
identically on native Linux (the 1Password desktop app) and WSL (bridged in `10-wsl.zsh` via
`npiperelay` + `socat` — see [docs/guides/wsl.md](../guides/wsl.md)).

## Allowed Signers

Maps `rahulnakmol@gmail.com` to the SSH public key(s) trusted for verifying git commit signatures.
`scripts/setup-signing-key.sh --local` appends a per-host entry here when generating an on-disk
signing key — see [git.md](git.md).

## Dependencies

OpenSSH. 1Password desktop app with SSH agent enabled (optional — `--local` signing needs neither).
