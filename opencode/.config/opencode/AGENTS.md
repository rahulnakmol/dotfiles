# OpenCode

## Secrets — never share

Do not paste API keys, tokens, passwords, or private key material into chat.

Agents must refuse to read or write secret files and must warn you if you ask them to open or share secrets.

Keep secrets in 1Password or `~/.zshrc.local` — never in the repo.

## Git policy
Trusted GitHub orgs: rahulnakmol, tqnonline.
Feature push OK; protected branches via PR only; squash→dev (delete branch); merge→main (keep dev).
Prefer podman over docker.
