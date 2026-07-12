# log2ai

Record terminal sessions and safely copy redacted output to clipboard for use with AI assistants.

## Overview

`log2ai` is a CLI tool that records terminal session input/output to local files, then lets you view or copy the last executed command and its output with secrets automatically masked. Designed for safely passing terminal context to Claude Code, Codex, or other AI tools.

**This is an MVP targeting WSL2 only.**

## Requirements

- WSL2 (Ubuntu)
- Bash
- `script` command (usually pre-installed; part of `bsdutils`)
- `clip.exe` (for clipboard copy; available via WSL interop)

## Installation

```bash
git clone https://github.com/cola-1111/log2ai.git
cd log2ai
bash install.sh
```

This installs `log2ai` to `~/.local/bin/log2ai`. If `~/.local/bin` is not in your PATH, the installer will show instructions to add it.

## Usage

### Start Recording

```bash
# Terminal 1
log2ai start
```

This starts a new recorded shell session. Work normally:

```bash
npm run build
python manage.py migrate
curl https://api.example.com/status
```

Type `exit` or press `Ctrl+D` to stop recording.

### List Sessions

```bash
# Terminal 2 (or after stopping)
log2ai list
```

Output:

```
SESSION ID                  STATUS    STARTED AT
20260712-201530-24873        active    2026-07-12 20:15:30
20260712-201605-25110        stopped   2026-07-12 20:16:05
```

The `*` marker indicates the latest session.

### View Last Command (Redacted)

```bash
log2ai show
log2ai show --session 20260712-201530-24873
```

### View Full Session (Redacted)

```bash
log2ai show --all
log2ai show --session 20260712-201530-24873 --all
```

### Copy to Clipboard (Redacted)

```bash
log2ai copy
log2ai copy --session 20260712-201530-24873
log2ai copy --session 20260712-201530-24873 --all
```

### Multiple Terminals

You can run `log2ai start` in multiple terminals simultaneously. Each gets a unique session ID (timestamp + PID). Use `log2ai list` to see all sessions, and `--session <ID>` to target a specific one.

### Session ID

Session IDs are formatted as `YYYYMMDD-HHMMSS-PID` (e.g., `20260712-201530-24873`). They are generated from the start time and process ID, ensuring uniqueness even when multiple sessions start in the same second.

## Log Storage

Logs are stored at:

```
${XDG_STATE_HOME:-$HOME/.local/state}/log2ai/sessions/
```

Directory permissions: `700`. File permissions: `600`.

**Raw logs may contain secrets.** Only use `log2ai show` or `log2ai copy` for output that has been redacted.

## Secret Masking

The following are masked in `show` and `copy` output:

- Environment variables containing KEY, SECRET, TOKEN, PASS, PASSWORD, PASSWD, DATABASE_URL, ACCESS_TOKEN, CLIENT_SECRET
- Authorization headers (Bearer, Basic)
- OpenAI API keys (`sk-...`)
- Anthropic API keys (`sk-ant-...`)
- GitHub Personal Access Tokens (`ghp_...`)
- GitHub fine-grained tokens (`github_pat_...`)
- AWS Access Key IDs (`AKIA...`)
- JWTs (`eyJ...`)
- npm tokens (`npm_...`)
- Passwords in connection URLs (postgres://, mysql://, redis://)
- PEM private key blocks

### Limitations

- Masking is best-effort. Not all secrets can be detected.
- Custom secret formats are not covered.
- Always review output before sharing with any AI tool or third party.

## Before Sharing with AI

**Always review the output of `log2ai show` or `log2ai copy` before passing it to an AI assistant.** Masking reduces risk but cannot guarantee complete redaction of all sensitive information.

## Uninstall

```bash
rm -f ~/.local/bin/log2ai
rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/log2ai"
```

## Commands

| Command | Description |
|---------|-------------|
| `start` | Start recording a terminal session |
| `list` | List recorded sessions |
| `show` | Show session log (redacted) |
| `copy` | Copy session log to Windows clipboard (redacted) |
| `help` | Show help |
| `version` | Show version |

## Options

| Option | Commands | Description |
|--------|----------|-------------|
| `--session <ID>` | show, copy | Target a specific session |
| `--all` | show, copy | Show/copy entire session instead of last command |

## MVP Constraints

- WSL2 only (no macOS, Linux desktop, or native Windows)
- Bash only (no Zsh-specific support)
- No AI API integration
- No configuration file
- No automatic log rotation or cleanup
- No shell completion
- Command boundary detection uses Bash DEBUG trap; complex multi-line commands or subshells may not be captured perfectly

## License

MIT License. See [LICENSE](LICENSE).
