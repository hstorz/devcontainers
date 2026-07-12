# Agent Dev Container

Dev container with Homebrew, opencode (AI agent), pi (AI agent), and dotfiles
from `h1st0ry3D/dotfiles`, hardened for running AI agents that execute arbitrary
shell commands.

## How It Works

1. **Base image** — `mcr.microsoft.com/devcontainers/base:2.1.6-bookworm`
   (Debian 12, non-root `vscode` user at UID 1000). Tag is pinned for
   reproducibility.
2. **Homebrew** — official installer, then tools from a **vendored, Linux-only
   `Brewfile`** (`COPY`'d into the image — no remote fetch at build time).
3. **Dotfiles** — applied via chezmoi from a **pinned commit** at container
   creation (never a floating branch).

## Quick Start

Open in VS Code → `Ctrl+Shift+P` → **"Dev Containers: Reopen in Container"**

```bash
opencode  # OpenCode AI agent (homebrew/core)
pi        # Pi AI agent
zsh       # Default shell
```

## Secrets / API keys

Tokens are forwarded from your host environment via `remoteEnv` (not baked into
the image). Export them on the host before launching the container:

```bash
export ANTHROPIC_API_KEY=...
export OPENAI_API_KEY=...
export OPENROUTER_API_KEY=...
# or: export CLAUDE_CODE_OAUTH_TOKEN=...
```

Only `remoteEnv` is used (never `containerEnv`/`ENV`) so secrets do not end up
in inspectable image metadata and are only present for attached processes.

## Agent config and state (kept inside the container)

`pi` and `opencode` configuration is **not** bind-mounted from the host.
Instead, `postCreateCommand` runs `chezmoi apply` from the pinned dotfiles
commit, which provisions the shared config into the container:

- `~/.config/opencode/opencode.json`
- `~/.pi/agent/settings.json`, `models.json`, `keybindings.json`, `extensions/`

Agent **state** (sessions, npm plugin installs) lives entirely inside the
container's writable home and is ephemeral — it does not survive a rebuild and
is not coupled to the host. This keeps the host ↔ container boundary clean and
avoids exposing host credentials.

**Secrets are never on disk in the container:** `~/.pi/agent/auth.json` is not
provisioned by chezmoi and not mounted, so API keys come only from `remoteEnv`
(see above). Re-authenticate in the container if a tool needs a persisted token.

## Security hardening

- **No passwordless sudo** — the base image's NOPASSWD `vscode` sudoers entry is
  removed; agents cannot trivially escalate to root.
- **Dropped Linux capabilities** — `NET_ADMIN`, `SYS_ADMIN`, `SYS_MODULE`,
  `DAC_READ_SEARCH`, `AUDIT_WRITE` are dropped. `SYS_PTRACE` is intentionally
  **retained** so agents can run native debuggers (gdb, lldb, strace) when
  needed for general coding tasks. `no-new-privileges` still blocks any
  privilege escalation to root.
- **`no-new-privileges`** is set via `runArgs` (also blocks `sudo` from
  escalating to root).
- **`--userns=keep-id:uid=1000,gid=1000`** (Podman only) explicitly maps the
  host user to container uid 1000 (`vscode`) so the non-root user owns the
  bind-mounted workspace and can write to it under rootless Podman. Without
  the `:uid=1000,gid=1000` qualifier, `keep-id` maps the host user to the
  container's *default* user, which in this devcontainer's `-uid` setup
  variant is root — leaving `/workspace` root-owned and unwritable by
  `vscode`. **Remove this line if you switch to Docker** / GitHub Codespaces
  — Docker does not support it (see
  [containers.dev – runArgs](https://containers.dev/implementors/json_reference/)).
- **Read-only `.devcontainer`** — mounted read-only into the container so an
  agent cannot edit its own `Dockerfile`/`devcontainer.json` to widen access on
  the next rebuild.
- **`tmpfs` on `/tmp`** with `nosuid,nodev`.
- **Pinned inputs** — base image tag, Brewfile contents, and dotfiles revision
  are all pinned (no floating `main` fetches at build/start time).
- **`~/.local/bin` on `PATH`** — prepended in the image `ENV` so tools installed
  by `uv tool install` (e.g. LLM benchmark CLIs) are reachable by agents and
  their subprocesses, not just interactive login shells.
- **Tap trust preserved** — `HOMEBREW_NO_REQUIRE_TAP_TRUST` is NOT set; taps
  must be trusted explicitly.

## Performance

- **BuildKit cache mount** for `~/.cache/Homebrew` speeds up rebuilds.
- **Vendored Brewfile** avoids a network round-trip every build.
- **`init: true`** runs an init process for correct signal/zombie handling.
- **Persistent `.vscode-server` volume** survives rebuilds so VS Code extensions
  are not reinstalled each time.

## Files

```
agent/
├── .devcontainer/
│   ├── Brewfile               # vendored, Linux-only tool list
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── postCreateCommand.sh
├── .dockerignore
└── README.md
```

## Troubleshooting

```bash
# Homebrew not found
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Re-run dotfiles (uses the pinned rev in postCreateCommand.sh)
chezmoi apply

# Re-install Brewfile packages
brew bundle install --file=.devcontainer/Brewfile

# sudo no longer works passwordless by design. If you need root tooling,
# run a rootful command from the host:
#   docker exec -u root agent <cmd>
```

## Notes

- `opencode` is installed from the trusted `homebrew/core` tap, so no
  third-party tap or explicit `brew trust` step is required.
