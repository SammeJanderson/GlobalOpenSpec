## Why

Today, `openspec init` writes skills and opsx commands into each project (`.claude/`, `.cursor/`, etc.). That duplicates artifacts across repos, drifts when versions differ, and does not help developers who use multiple AI CLIs. The intended model is: **OpenSpec CLI materializes workflow skills once on the machine**; **[skillshare](https://github.com/runkids/skillshare) syncs that single source to every agent** so OpenSpec works in **any project** without checking skills into git.

## What Changes

- Add a setup script that:
  1. Ensures `openspec` and `skillshare` are available
  2. Runs `openspec init` / `openspec update` against a **global agent home** (e.g. `~/.config/openspec/agent-home/`) with all desired tools—not against each application repo
  3. Registers that home with **global** skillshare (`~/.config/skillshare/`) and runs `skillshare sync` to propagate skills to Cursor, Claude Code, Codex, and other configured targets
- Document the split: **per-project** `openspec init --tools none` (specs/changes only) vs **one-time global** skill install + sync
- **Remove** checked-in OpenSpec skills and opsx commands from this repo (`.claude/skills/`, `.cursor/skills/`, and matching `commands/` trees)—they are generated artifacts, not source
- Do **not** commit `.skillshare/` project config; global skillshare is the integration surface

## Capabilities

### New Capabilities

- `openspec-skillshare-setup`: Global OpenSpec agent home, skillshare global sync script, and documentation for machine-wide OpenSpec skills usable in all projects.

### Modified Capabilities

<!-- None: no existing openspec/specs/ capabilities yet -->

## Impact

- New: `scripts/setup-openspec-skills-global.sh` (or similar), docs for global workflow
- **BREAKING** for this repo: deletes `.claude/skills/`, `.cursor/skills/`, and opsx command files; projects rely on globally synced skills instead
- Depends on `@fission-ai/openspec` CLI and [skillshare](https://github.com/runkids/skillshare)
- Developer machines: `~/.config/openspec/agent-home/` (OpenSpec-generated) and `~/.config/skillshare/` + agent skill directories (skillshare-synced)
- Per-project `openspec/` folders unchanged in purpose; only agent instruction files move off-repo
