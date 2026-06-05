## Context

`scripts/setup-openspec-skills-global.sh` installs and wires up OpenSpec + skillshare on a machine. Currently, prerequisite checks are embedded inside each install function, so a bad environment is discovered mid-run — sometimes after partial side effects. The Node.js minimum is 20.19 (required by `@fission-ai/openspec` static-class syntax), which is not currently enforced.

The new design introduces a dedicated `scripts/preflight.sh` and a `Makefile` that sequences `preflight → install`. This keeps the setup script focused on installation logic and makes preflight independently invokable.

## Goals / Non-Goals

**Goals:**
- Dedicated `scripts/preflight.sh` that validates all prerequisites and exits with a combined error list on failure
- `Makefile` with `install` target (`preflight` → `setup-openspec-skills-global.sh`) and a standalone `preflight` target
- Preflight checks conditioned on whether each CLI is already installed (avoid false positives)

**Non-Goals:**
- Auto-remediating environment issues (e.g., upgrading Node.js automatically)
- Checking optional or nice-to-have dependencies
- Validating network connectivity
- Replacing the raw `./scripts/setup-openspec-skills-global.sh` invocation path (direct invocation still works; Makefile is the recommended path)

## Decisions

**Separate script, not an embedded function**
`scripts/preflight.sh` is a standalone executable. This makes it independently testable (`./scripts/preflight.sh` or `make preflight`), reusable by CI, and composable with other tooling — none of which would be possible if it were a private function inside the setup script.

**Makefile as the primary user-facing entry point**
`make install` is the documented install command. The Makefile chains `preflight` → `install` targets with a hard dependency so the sequence is guaranteed and self-documenting. `make preflight` alone allows a dry-run check.

**Collect all errors before failing**
`preflight.sh` accumulates failures into an array and reports them all before exiting. This avoids the "fix one thing, re-run, discover the next" cycle.

**Condition checks on whether CLI is already installed**
If `openspec` is on PATH, skip Node.js/npm checks (working openspec proves a compatible runtime). If `skillshare` is on PATH, skip curl check.

**Run `refresh_path_for_global_bins` at the top of preflight.sh**
The same path-expansion logic from `setup-openspec-skills-global.sh` runs first in preflight so checks see the same PATH the install script will use. This avoids false "not found" results caused by npm global bin being off PATH.

**Version comparison in pure bash**
Split `node --version` output into major/minor integers and compare with `[[ ]]` arithmetic. No `awk`, `python`, or `semver` tool needed — keeps scripts self-contained.

## Risks / Trade-offs

- **nvm shims**: `node --version` via nvm may report a version that differs from what openspec resolves to at runtime. Mitigated: check is skipped when `openspec` is already installed.
- **Direct script invocation bypasses preflight**: Users invoking `./scripts/setup-openspec-skills-global.sh` directly skip the preflight. Mitigated: docs point to `make install`; the setup script's own inline guards (npm/curl checks) still catch the most critical cases.
- **Makefile availability**: `make` is not installed on all systems (rare on macOS/Linux, possible on some CI). Mitigated: direct script invocation remains supported; Makefile is convenience, not the only path.
