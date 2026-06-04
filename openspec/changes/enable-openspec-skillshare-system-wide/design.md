## Context

OpenSpec v1.4+ generates workflow skills and slash commands via `openspec init` and `openspec update`, writing under each tool's `skillsDir` (e.g. `.claude/skills/`, `.cursor/skills/`) **relative to a path argument**. Global settings live in `~/.config/openspec/config.json` (profile, delivery, workflows).

[skillshare](https://github.com/runkids/skillshare) maintains a **global** source at `~/.config/skillshare/skills/` (macOS/Linux) and syncs to 60+ agent targets via symlinks or copy mode. It is the right distribution layer after OpenSpec has produced skills in one place.

This repo currently vendors generated skills/commands in git—that contradicts the desired model and will be removed.

## Goals / Non-Goals

**Goals:**

- **Single source of truth on disk**: OpenSpec writes skills once to a global agent home; skillshare syncs to all enabled agents.
- **Works in every project**: After one-time machine setup, any repo with `openspec/` (and `openspec init --tools none`) gets opsx workflows via globally installed skills—no per-repo skill copies.
- **One command** to install/refresh: setup script runs `openspec update` on the global home, then `skillshare sync`.
- **Upgrade path**: `openspec update` + `skillshare sync` refreshes skills after CLI bumps.

**Non-Goals:**

- Committing `.skillshare/` or skill files in application repos.
- Project-mode skillshare (`skillshare init -p`) as the primary integration.
- Changing OpenSpec CLI internals (use existing `init`/`update` with a global path until a dedicated `openspec skills install --global` exists).
- Publishing skills to a public skill registry.

## Decisions

### 1. Global OpenSpec agent home as the generation target

**Choice:** Fixed directory, e.g. `~/.config/openspec/agent-home/`, created on first setup.

**Flow:**

```bash
mkdir -p ~/.config/openspec/agent-home
openspec init ~/.config/openspec/agent-home --tools all   # first time
openspec update ~/.config/openspec/agent-home --force     # refresh
```

OpenSpec writes `.claude/skills/`, `.cursor/skills/`, commands, etc. under that path only.

**Rationale:** Uses shipped CLI behavior today; no fork required.

**Alternatives considered:**

- Per-repo `openspec init` — rejected (user requirement).
- Hand-maintained SKILL.md in skillshare only — rejected (loses `openspec update` template drift protection).

### 2. skillshare global mode, not project mode

**Choice:** `skillshare init` (global) with skills sourced from the OpenSpec agent home.

**Implementation options** (validate during apply):

- Symlink each skill from `~/.config/skillshare/skills/<name>` → `~/.config/openspec/agent-home/.claude/skills/<name>` (or collect once if symlinks unsupported across roots).
- Or configure skillshare to treat a subdirectory of the OpenSpec home as source if supported in v0.20+.

Then `skillshare sync` (or `skillshare sync --all` if commands ship as extras later).

**Rationale:** Global sync matches "all projects"; project `.skillshare/` would reintroduce repo-local coupling.

### 3. Per-project OpenSpec init without agent artifacts

**Choice:** Application repos run:

```bash
openspec init --tools none
```

This creates `openspec/config.yaml` and change workflow structure **without** writing `.claude/skills/` or `.cursor/commands/` into the repo.

**Rationale:** Specs and changes stay project-local; skills stay machine-global.

### 4. Setup script orchestrates the pipeline

**Choice:** `scripts/setup-openspec-skills-global.sh`:

1. Check `openspec` and `skillshare` on PATH; optional `SKILLSHARE_AUTO_INSTALL=1`
2. Ensure `OPENSPEC_AGENT_HOME` (default `~/.config/openspec/agent-home`) exists
3. `openspec init "$OPENSPEC_AGENT_HOME" --tools all` if not initialized; else `openspec update "$OPENSPEC_AGENT_HOME" --force`
4. Wire skillshare global source to OpenSpec output (symlinks or documented collect)
5. `skillshare init` if needed; `skillshare sync`
6. Print verification (list targets, confirm opsx skills visible in Cursor/Claude)

**Rationale:** Single onboarding step; idempotent refresh on re-run.

### 5. Remove repo-persisted skills from global_open_spec

**Choice:** Delete `.claude/skills/`, `.cursor/skills/`, and opsx `commands/` from this template repo; document that consumers run global setup once.

**Rationale:** Git should not track generated agent instructions; avoids drift from `openspec update`.

### 6. Commands (slash) handling

**Choice:** Phase 1 sync **skills** via skillshare; OpenSpec also generates commands under `.claude/commands/` etc. in the global home. Evaluate skillshare **extras** for command sync in phase 2; until then, commands may remain only where skillshare maps them, or agents may rely on skills alone (opsx skills embed workflow steps).

**Rationale:** Skills are the critical path for cross-project use; command path mapping varies by CLI.

## Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│  ~/.config/openspec/agent-home/  (openspec init/update)   │
│    .claude/skills/  .cursor/skills/  … (all tools)         │
└──────────────────────────┬──────────────────────────────────┘
                           │ register / symlink
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  ~/.config/skillshare/skills/  (skillshare global source)    │
└──────────────────────────┬──────────────────────────────────┘
                           │ skillshare sync
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
    ~/.cursor/…      ~/.claude/…        other agents

┌─────────────────────────────────────────────────────────────┐
│  any-project/openspec/  (openspec init --tools none)       │
│    changes, specs — no .claude/skills in repo                │
└─────────────────────────────────────────────────────────────┘
```

## Risks / Trade-offs

- **[Risk] OpenSpec has no first-class `skills install --global`** → Mitigation: document `agent-home` path; script wraps `init`/`update`; revisit if CLI adds native global install.
- **[Risk] skillshare ↔ openspec path bridging** → Mitigation: prefer symlinks; fall back to collect + document `skillshare sync` after `openspec update`.
- **[Risk] Team version skew** → Mitigation: docs say to re-run setup script after `npm i -g @fission-ai/openspec@latest`.
- **[Risk] Symlink failures on Windows/corporate FS** → Document `skillshare target <name> --mode copy`.
- **[Trade-off] Skills not in repo** → New clones need global setup once; acceptable for personal/team machines using OpenSpec.

## Migration Plan

1. Ship setup script + docs.
2. Maintainer runs global setup; verifies opsx in Cursor/Claude on an arbitrary project with `--tools none`.
3. Remove vendored skills/commands from this repo; update README.
4. Existing clones: delete local `.claude/skills` / `.cursor/skills` if present; run global setup.
5. Rollback: re-run `openspec init --tools all` in a project (old model) or restore deleted dirs from git history.

## Open Questions

- Best skillshare mechanism to reference OpenSpec agent-home without copying (schema in v0.20+).
- Whether `openspec init --tools none` skips creating empty `.claude/` dirs or leaves no tool dirs at all.
- Phase 2: skillshare extras for opsx commands vs skills-only delivery (`openspec config set delivery skills`).
