# Aliases Cheatsheet

All aliases are defined in `zsh/.zshrc.d/aliases.zsh` unless noted otherwise.
Distro-specific aliases load conditionally based on `$DOTFILES_DISTRO`.

---

## Navigation

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `prj` | `cd $HOME/Developer/Projects` | Jump to projects directory |
| `ghr` | `cd $HOME/Developer/Github` | Jump to GitHub repos directory |
| `dotfiles` | `cd $HOME/.dotfiles` | Jump to dotfiles repo |
| `zl` | `zoxide query -l -s \| fzf ...` | Fuzzy-pick from zoxide frecency list with bat preview |

## Files and Listing

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `ls` | `eza -l --color=auto` | Long listing with eza |
| `l` | `eza -F --color=auto` | Compact listing with type indicators |
| `ll` | `ls -alF --color=auto` | All files, long format |
| `la` | `ls -A --color=auto` | All files except `.` and `..` |
| `lar` | `ls -laRt changed` | Recursive listing sorted by change time |
| `cat` | `bat` | Syntax-highlighted file viewer |
| `catt` | `bat --theme="Catppuccin Macchiato" --style="header,grid,numbers"` | Themed bat with line numbers |

## Color Support

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `dir` | `dir --color=auto` | Colorized dir |
| `vdir` | `vdir --color=auto` | Colorized vdir |
| `grep` | `grep --color=auto` | Colorized grep |
| `fgrep` | `fgrep --color=auto` | Colorized fixed-string grep |
| `egrep` | `egrep --color=auto` | Colorized extended grep |

## Git

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `gs` | `git status` | Show working tree status |
| `ga` | `git add` | Stage files |
| `gc` | `git commit -m` | Commit with inline message |
| `gp` | `git push` | Push to remote |
| `gpl` | `git pull` | Pull from remote |
| `gco` | `git checkout` | Switch branches or restore files |
| `gb` | `git branch -a` | List all branches |
| `gf` | `git fetch` | Fetch remote changes |
| `gcl` | `gh repo clone` | Clone a GitHub repo |
| `gb!` | `git blame` | Show line-by-line blame |
| `glog` | `git log --oneline --decorate --all --graph` | Visual commit graph |
| `gdiff` | `git diff` | Show unstaged changes |
| `gdiffs` | `git diff --staged` | Show staged changes |

## GitHub CLI

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `ghl` | `gh auth login --hostname github.com` | Log in to GitHub |
| `ghs` | `gh auth status --hostname github.com` | Check auth status |
| `gsync` | `gh repo sync` | Sync fork with upstream |
| `gpc` | `gh pr create --fill --web` | Create PR and open in browser |
| `gpv` | `gh pr view --web` | View PR in browser |
| `gprs` | `gh pr list` | List open PRs |
| `gpx` | `gh pr checkout` | Checkout a PR locally |
| `gic` | `gh issue create --web` | Create issue in browser |
| `gil` | `gh issue list` | List issues |
| `grls` | `gh release list` | List releases |

### Codex-aware GitHub helpers

These target the repo in `$CODEX_GH_REPO` (defaults to `rahulnakmol/opencode`).

| Function | Description |
|----------|-------------|
| `gcx` | Open the codex repo in browser |
| `gcxprs` | List PRs for the codex repo |
| `gcxsync` | Sync the codex repo |

## Tmux

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `t` | `tmux` | Launch tmux |
| `ta` | `tmux attach -t` | Attach to named session |
| `tl` | `tmux ls` | List sessions |
| `tk` | `tmux kill-session -t` | Kill a named session |
| `tn` | `tmux new -s` | New named session |
| `ts` | `tmux switch -t` | Switch to named session |
| `tks` | `tmux kill-session -a` | Kill all sessions except current |

## npm

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `ni` | `npm install` | Install dependencies |
| `nis` | `npm install --save` | Install and save to dependencies |
| `nid` | `npm install --save-dev` | Install as dev dependency |
| `nig` | `npm install -g` | Install globally |
| `nu` | `npm uninstall` | Uninstall package |
| `nug` | `npm uninstall -g` | Uninstall global package |
| `nr` | `npm run` | Run a script |
| `ns` | `npm start` | Start the project |
| `nt` | `npm test` | Run tests |
| `nb` | `npm run build` | Build the project |
| `nd` | `npm run dev` | Start dev server |
| `nl` | `npm list --depth=0` | List top-level local packages |
| `nlg` | `npm list -g --depth=0` | List top-level global packages |
| `nup` | `npm update` | Update packages |
| `no` | `npm outdated` | Check for outdated packages |
| `nci` | `npm ci` | Clean install from lockfile |
| `na` | `npm audit` | Run security audit |
| `naf` | `npm audit fix` | Auto-fix audit issues |
| `np` | `npm publish` | Publish package |
| `ninit` | `npm init -y` | Initialize package.json |
| `nx` | `npx` | Run a package binary |

### Node.js helpers

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `node-versions` | `ls -1 $HOME/.nvm/versions/node` | List installed Node versions |
| `nv` | `node --version` | Print Node version |
| `npmv` | `npm --version` | Print npm version |

## Docker / Podman

All `docker` commands are aliased to `podman` as a drop-in replacement.

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `d` | `podman` | Podman shorthand |
| `dps` | `podman ps` | List running containers |
| `dpsa` | `podman ps -a` | List all containers |
| `di` | `podman images` | List images |
| `drm` | `podman rm` | Remove container |
| `drmi` | `podman rmi` | Remove image |
| `drun` | `podman run` | Run a container |
| `dex` | `podman exec -it` | Exec into running container |
| `dlogs` | `podman logs` | View container logs |
| `dlogsf` | `podman logs -f` | Follow container logs |
| `dstop` | `podman stop` | Stop container |
| `dstart` | `podman start` | Start container |
| `drestart` | `podman restart` | Restart container |
| `dpull` | `podman pull` | Pull an image |
| `dbuild` | `podman build` | Build an image |
| `dcp` | `podman cp` | Copy files to/from container |
| `dinsp` | `podman inspect` | Inspect container or image |
| `dvol` | `podman volume ls` | List volumes |
| `dnet` | `podman network ls` | List networks |
| `dprune` | `podman system prune -af` | Remove all unused data |
| `dgpu` | `podman run --device nvidia.com/gpu=all --security-opt=label=disable` | Run with GPU passthrough |
| `dc` | `podman compose` | Compose shorthand |
| `dcu` | `podman compose up -d` | Compose up (detached) |
| `dcd` | `podman compose down` | Compose down |
| `dcl` | `podman compose logs -f` | Follow compose logs |
| `dcps` | `podman compose ps` | List compose services |

## SSH

| Alias / Function | Expands to | Description |
|------------------|-----------|-------------|
| `s` | `ssh` | SSH shorthand |
| `sa` | `ssh -A` | SSH with agent forwarding |
| `sc` | `nvim ~/.ssh/config` | Edit SSH config |
| `sk` | `ls ~/.ssh` | List SSH directory contents |
| `sr` | `ssh-add -D && ssh-add` | Reset and re-add SSH keys |
| `sh` / `ssh_host()` | awk + fzf | Fuzzy-pick a host from `~/.ssh/config` and connect |
| `sp` / `spub()` | `ssh-keygen -y -f <key>` | Print public key from private key (default: `id_ed25519`) |
| `snew()` | `ssh-keygen -t ed25519 -C ...` | Generate new ed25519 key pair |

## Azure CLI (az)

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `azl` | `az login` | Log in to Azure |
| `azld` | `az login --use-device-code` | Log in with device code flow |
| `azlo` | `az logout` | Log out |
| `azs` | `az account show` | Show active subscription |
| `azal` | `az account list -o table` | List all subscriptions |
| `azas` | `az account set -s` | Switch subscription |
| `azrgl` | `az group list -o table` | List resource groups |
| `azrgc` | `az group create -n` | Create resource group |
| `azrgd` | `az group delete -n` | Delete resource group |
| `azrl` | `az resource list -o table` | List resources |
| `azvml` | `az vm list -o table` | List VMs |
| `azvms` | `az vm start -n` | Start VM |
| `azvmx` | `az vm stop -n` | Stop VM |
| `azvmd` | `az vm deallocate -n` | Deallocate VM |
| `azaksl` | `az aks list -o table` | List AKS clusters |
| `azaksc` | `az aks get-credentials -n` | Get AKS credentials |
| `azacrl` | `az acr list -o table` | List container registries |
| `azwal` | `az webapp list -o table` | List web apps |
| `azsal` | `az storage account list -o table` | List storage accounts |
| `azup` | `az upgrade` | Upgrade Azure CLI |
| `azv` | `az version` | Show CLI version |
| `azwho` | `az ad signed-in-user show` | Show signed-in user |
| `azfind` | `az find` | Search Azure CLI commands |

## Azure Developer CLI (azd)

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `azdl` | `azd auth login` | Log in |
| `azdlo` | `azd auth logout` | Log out |
| `azdi` | `azd init` | Initialize a project |
| `azdu` | `azd up` | Provision and deploy |
| `azdd` | `azd down` | Tear down resources |
| `azdp` | `azd provision` | Provision infrastructure |
| `azddp` | `azd deploy` | Deploy application |
| `azdm` | `azd monitor` | Open monitoring dashboard |
| `azde` | `azd env list` | List environments |
| `azdes` | `azd env select` | Select environment |
| `azdt` | `azd template list` | List templates |

## Claude Code

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `cc` | `claude` | Interactive session (Sonnet default) |
| `ccc` | `claude -c` | Continue last conversation |
| `ccp` | `claude -p` | Non-interactive print mode |
| `ccr` | `claude --resume` | Resume a specific session |
| `ccs` | `claude --model sonnet --permission-mode acceptEdits` | Sonnet with edit permissions |
| `cco` | `claude --model opus --permission-mode acceptEdits` | Opus with edit permissions |
| `cch` | `claude --model haiku` | Haiku for quick answers |
| `ccpl` | `claude --model opus --permission-mode plan` | Opus in read-only plan mode |
| `cc!` | `claude --model sonnet --dangerously-skip-permissions` | Sonnet autopilot (full agentic) |
| `cco!` | `claude --model opus --dangerously-skip-permissions` | Opus autopilot (full agentic) |

## OpenCode

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `oc` | `opencode` | Launch TUI |
| `occ` | `opencode -c` | Continue last session |
| `ocr` | `opencode run` | Headless non-interactive run |
| `ocrc` | `opencode run -c` | Continue last session headless |
| `ocm` | `opencode -m` | Launch with specific model |
| `ocw` | `opencode web` | Open web interface |
| `ocpr` | `opencode pr` | Checkout and review a GitHub PR |
| `ocsl` | `opencode session list` | List sessions |
| `ocse` | `opencode export` | Export session as JSON |
| `ocsi` | `opencode import` | Import session from JSON or share URL |
| `ocml` | `opencode models` | List available models |
| `ocli` | `opencode providers login` | Login to provider |
| `ocst` | `opencode stats` | Show usage statistics |
| `ocp` | `opencode --pure` | Launch without plugins |
| `ocum` | `~/.config/opencode/update-models.sh` | Update agent models to latest Zen versions |
| `ocumd` | `~/.config/opencode/update-models.sh --dry-run` | Dry-run model update (preview only) |

## Editors

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `v` | `nvim` | Neovim |
| `vi` | `nvim` | Neovim |
| `vim` | `nvim` | Neovim |

## fzf

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `fzp` | `fzf --preview 'bat ...' --preview-window=right:70%` | Fuzzy finder with bat preview |

## Shell Utilities

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `src` | `source $HOME/.zshrc` | Reload shell config |
| `cls` | `clear` | Clear terminal |

---

## Distro-Specific Package Managers

These load conditionally based on `$DOTFILES_DISTRO` (detected by `00-distro.zsh`).

### Ubuntu / Debian (pkg-ubuntu.zsh)

**APT**

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `ai` | `sudo apt install` | Install package |
| `au` | `sudo apt remove` | Remove package |
| `aup` | `sudo apt update` | Update package lists |
| `aug` | `sudo apt upgrade` | Upgrade packages |
| `auu` | `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y` | Full update + cleanup |
| `as` | `apt search` | Search packages |
| `al` | `apt list --installed` | List installed packages |
| `ainf` | `apt show` | Show package info |
| `ac` | `sudo apt autoclean` | Clean package cache |
| `aar` | `sudo apt autoremove` | Remove unused dependencies |
| `apur` | `sudo apt purge` | Purge package and config |

**Homebrew** (available when Homebrew is installed)

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `bi` | `brew install` | Install package |
| `bu` | `brew uninstall` | Uninstall package |
| `bl` | `brew list` | List installed packages |
| `bs` | `brew search` | Search packages |
| `bc` | `brew cleanup` | Clean old versions |
| `bup` | `brew update` | Update Homebrew |
| `bug` | `brew upgrade` | Upgrade packages |
| `buu` | `brew update && brew upgrade && brew cleanup` | Full update + cleanup |
| `binf` | `brew info` | Show package info |

### Fedora / RHEL (pkg-fedora.zsh)

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `dni` | `sudo dnf install` | Install package |
| `dnu` | `sudo dnf remove` | Remove package |
| `dnup` | `sudo dnf check-update` | Check for updates |
| `dnug` | `sudo dnf upgrade` | Upgrade packages |
| `dnuu` | `sudo dnf upgrade --refresh -y && sudo dnf autoremove -y` | Full upgrade + cleanup |
| `dns` | `dnf search` | Search packages |
| `dnl` | `dnf list installed` | List installed packages |
| `dnls` | `dnf list installed \| rg` | Search installed packages with ripgrep |
| `dninf` | `dnf info` | Show package info |
| `dnc` | `sudo dnf clean all` | Clean package cache |
| `dnar` | `sudo dnf autoremove` | Remove unused dependencies |
| `dnrp` | `dnf repolist` | List enabled repos |
| `dnh` | `dnf history` | Show transaction history |
| `dnhu` | `sudo dnf history undo` | Undo a transaction |
| `dnprov` | `dnf provides` | Find which package provides a file |

### openSUSE (pkg-opensuse.zsh)

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `zyi` | `sudo zypper install` | Install package |
| `zyu` | `sudo zypper remove` | Remove package |
| `zyup` | `sudo zypper refresh` | Refresh repositories |
| `zyug` | `sudo zypper update` | Update packages |
| `zyuu` | `sudo zypper refresh && sudo zypper update -y` | Full update |
| `zydup` | `sudo zypper dist-upgrade` | Distribution upgrade |
| `zys` | `zypper search` | Search packages |
| `zyl` | `zypper packages --installed-only` | List installed packages |
| `zyls` | `zypper search --installed-only` | Search installed packages |
| `zyinf` | `zypper info` | Show package info |
| `zyc` | `sudo zypper clean --all` | Clean all caches |
| `zyrp` | `zypper repos` | List repositories |
| `zyra` | `sudo zypper addrepo` | Add a repository |
| `zyrd` | `sudo zypper removerepo` | Remove a repository |
| `zypa` | `zypper patches` | List available patches |
| `zyve` | `zypper verify` | Verify installed packages |
