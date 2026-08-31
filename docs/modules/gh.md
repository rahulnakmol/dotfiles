# gh

GitHub CLI configuration.

## Key Files

| File | Purpose |
|------|---------|
| `.config/gh/config.yml` | Global settings, aliases |
| `.config/gh/hosts.yml` | Authenticated hosts |

## Settings

| Setting | Value |
|---------|-------|
| Git protocol | `https` |
| Prompt | `enabled` |
| Editor-based prompt | `disabled` |
| Spinner | `enabled` |
| Color labels | `enabled` |

## Aliases

| Alias | Expands To |
|-------|------------|
| `co` | `pr checkout` |
| `prc` | `pr create --fill` |
| `prv` | `pr view --web` |
| `prs` | `pr status` |
| `prm` | `pr merge --squash --delete-branch` |
| `prl` | `pr list --state open` |
| `prla` | `pr list --state all` |
| `mypr` | `pr list --author @me` |
| `prnew` | `pr create --fill --web` |
| `review` | `pr view --web` |
| `done` | `pr merge --squash --delete-branch --auto` |
| `rv` | `repo view --web` |
| `rc` | `repo clone` |
| `rf` | `repo fork --clone` |
| `repos` | `repo list --limit 30` |
| `ic` | `issue create` |
| `iv` | `issue view --web` |
| `il` | `issue list` |
| `myi` | `issue list --assignee @me` |
| `wv` | `workflow view` |
| `wr` | `workflow run` |
| `wl` | `run list --limit 5` |
| `ws` | `run watch` |
| `runs` | `run list --limit 10` |
| `dash` | `pr status && issue list --assignee @me` |
| `review-me` | `search prs --review-requested=@me --state=open` |
| `gist-new` | `gist create` |

## Authenticated Host

`github.com` with user `rahulnakmol` via OAuth token.

## Dependencies

gh (GitHub CLI).
