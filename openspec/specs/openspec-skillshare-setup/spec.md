## Purpose

Machine-wide OpenSpec workflow skills: a setup script installs or verifies `openspec` and `skillshare`, materializes skills in a global agent home, syncs them to all configured agents via skillshare, and documents the split between one-time global setup and per-project `openspec init --tools none` so application repos keep only `openspec/` planning artifacts.

## Requirements

### Requirement: Setup script installs or verifies skillshare

The repository SHALL provide an executable setup script that checks for the `skillshare` CLI on the user's PATH and, when missing, instructs the user to install it via the official install method (curl install script, Homebrew, or documented equivalent). The script SHALL exit with a non-zero status if skillshare is required but unavailable after install guidance.

#### Scenario: skillshare already installed

- **WHEN** the user runs the setup script and `skillshare` is on PATH
- **THEN** the script proceeds without attempting to install skillshare globally

#### Scenario: skillshare not found

- **WHEN** the user runs the setup script and `skillshare` is not on PATH
- **THEN** the script prints install instructions and exits with a non-zero status unless the user opts into an automated install path documented in the script

### Requirement: Setup script installs or verifies openspec CLI

The setup script SHALL check for the `openspec` CLI on PATH and instruct the user to install `@fission-ai/openspec` globally when missing. The script SHALL exit with a non-zero status if openspec is required but unavailable.

#### Scenario: openspec already installed

- **WHEN** the user runs the setup script and `openspec` is on PATH
- **THEN** the script proceeds to global agent home setup

#### Scenario: openspec not found

- **WHEN** the user runs the setup script and `openspec` is not on PATH
- **THEN** the script prints install instructions and exits with a non-zero status

### Requirement: OpenSpec generates skills in a single global home

The setup script SHALL run `openspec init` or `openspec update` against a configurable global agent home directory (default `~/.config/openspec/agent-home/`) with all supported tools enabled, so OpenSpec workflow skills are materialized in one place on the machine—not inside application repositories.

#### Scenario: First-time global setup

- **WHEN** the global agent home does not exist or has no OpenSpec tool artifacts
- **THEN** the script runs `openspec init <agent-home> --tools all` and skills are created under `<agent-home>/.claude/skills/` (and equivalent paths for other tools)

#### Scenario: Refresh after openspec upgrade

- **WHEN** the user re-runs the setup script after upgrading the openspec package
- **THEN** the script runs `openspec update <agent-home> --force` and skill files in the global home reflect the current OpenSpec version

### Requirement: skillshare syncs global home to all agents

The setup script SHALL configure **global** skillshare (not project `.skillshare/`) so the OpenSpec-generated skills are registered in `~/.config/skillshare/skills/` (or platform equivalent) and SHALL run `skillshare sync` to distribute them to enabled targets.

#### Scenario: Successful global sync

- **WHEN** the user runs the setup script with skillshare initialized and at least one target enabled
- **THEN** the script completes with exit code 0 and OpenSpec skills are available in synced agent directories without files being added to the current git repository

#### Scenario: Sync failure is reported

- **WHEN** `skillshare sync` fails due to configuration or permission errors
- **THEN** the setup script surfaces the skillshare error output and exits with a non-zero status

### Requirement: Application repos do not persist OpenSpec skills

OpenSpec skills and opsx slash-command files SHALL NOT be committed in application repositories as part of this workflow. Per-project initialization SHALL use `openspec init --tools none` (or equivalent) so only `openspec/` planning artifacts exist in the repo.

#### Scenario: New project bootstrap

- **WHEN** a developer initializes OpenSpec in a new application repo following documented workflow
- **THEN** the repo contains `openspec/` structure without `.claude/skills/` or `.cursor/skills/` trees

#### Scenario: Skills available without repo artifacts

- **WHEN** global setup has been completed on the machine
- **THEN** the developer can use OpenSpec workflow skills in that repo via agent-global skill paths without checking skills into git

### Requirement: Setup script validates environment before any install or init

Before attempting to install `openspec`, `skillshare`, or initialize the agent home, the setup script SHALL run a preflight environment check. The check SHALL validate all required prerequisites and, if any fail, report every failure together and exit with a non-zero status without performing any installation or initialization.

#### Scenario: All prerequisites satisfied

- **WHEN** Node.js ≥ 20.19 is available, npm is available, curl is available, and relevant directories are writable
- **THEN** the script prints "Environment preflight passed." and continues to the install/init steps

#### Scenario: Node.js version below minimum

- **WHEN** `openspec` is not already on PATH and the installed Node.js version is below 20.19
- **THEN** the script includes a "node version below required 20.19" error in the preflight failure report and exits before installing anything

#### Scenario: Node.js not found

- **WHEN** `openspec` is not already on PATH and `node` is not found
- **THEN** the script includes a "node not found" error in the preflight failure report and exits before installing anything

#### Scenario: npm not found

- **WHEN** `openspec` is not already on PATH and `npm` is not on PATH after path refresh
- **THEN** the script includes an "npm not found" error in the preflight failure report and exits before installing anything

#### Scenario: curl not found

- **WHEN** `skillshare` is not already on PATH and `curl` is not available
- **THEN** the script includes a "curl not found" error in the preflight failure report and exits before installing anything

#### Scenario: Multiple prerequisite failures reported together

- **WHEN** more than one prerequisite check fails
- **THEN** the script reports all failures in a single output block before exiting, so the user can fix everything at once

#### Scenario: openspec already installed — Node.js check skipped

- **WHEN** `openspec` is already on PATH before the preflight runs
- **THEN** the Node.js version and npm checks are skipped (the installed openspec already proves a compatible runtime)

#### Scenario: skillshare already installed — curl check skipped

- **WHEN** `skillshare` is already on PATH before the preflight runs
- **THEN** the curl availability check is skipped

### Requirement: A Makefile provides install and preflight targets

The repository SHALL provide a `Makefile` at the project root. The `install` target SHALL run the preflight check then the setup script, in that order. The `preflight` target SHALL run only the preflight check without proceeding to installation.

#### Scenario: Running make install

- **WHEN** the user runs `make install`
- **THEN** `scripts/preflight.sh` runs first; if it exits 0, `scripts/setup-openspec-skills-global.sh` runs next; if preflight fails, the setup script does not run

#### Scenario: Running make preflight as a dry-run

- **WHEN** the user runs `make preflight`
- **THEN** only `scripts/preflight.sh` runs and its exit code is the Make target's exit code; no installation occurs

### Requirement: Documentation describes global cross-project workflow

The repository SHALL document: global one-time setup (setup script), per-project `openspec init --tools none`, refreshing after `openspec` or skillshare upgrades, and optional copy-mode workaround when symlinks fail.

#### Scenario: New developer onboarding

- **WHEN** a new developer reads the documented global workflow
- **THEN** they can enable OpenSpec skills for all projects on their machine without copying skills into each repository
