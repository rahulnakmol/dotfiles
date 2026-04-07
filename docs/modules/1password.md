# 1password

1Password desktop app settings and SSH agent configuration.

## Key Files

| File | Purpose |
|------|---------|
| `.config/1Password/settings/settings.json` | App preferences and security settings |
| `.config/1Password/ssh/agent.toml` | SSH agent key vault configuration |

## App Settings

| Setting | Value |
|---------|-------|
| Browser extension | enabled |
| Auto-lock | 60 minutes |
| Authenticated unlock | enabled |
| Interface density | compact |
| Block sleep | enabled |
| Hold to reveal | enabled |
| HIBP check | enabled |
| CLI shared lock state | enabled |
| SDK shared lock state | enabled |
| Developer experience | enabled |

## SSH Agent

| Setting | Value |
|---------|-------|
| Agent enabled | true |
| Store key titles | true |
| Vault | `Developer` |

The SSH agent serves keys from the "Developer" vault. Other modules (ssh, git) connect to this agent for authentication and commit signing.

## Dependencies

1Password desktop app.
