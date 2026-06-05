## 1. Create scripts/preflight.sh

- [x] 1.1 Create `scripts/preflight.sh` as an executable bash script with `set -euo pipefail` and the same `refresh_path_for_global_bins` helper copied from `setup-openspec-skills-global.sh`
- [x] 1.2 Implement error-collection pattern: accumulate failures in a bash array; print all at once and exit non-zero if any failed; print "Environment preflight passed." and exit 0 on success
- [x] 1.3 Add Node.js presence check — skip when `openspec` is already on PATH
- [x] 1.4 Add Node.js version check (≥ 20.19, pure-bash major/minor comparison) — skip when `openspec` is already on PATH
- [x] 1.5 Add npm presence check — skip when `openspec` is already on PATH
- [x] 1.6 Add curl presence check — skip when `skillshare` is already on PATH
- [x] 1.7 `chmod +x scripts/preflight.sh`

## 2. Create Makefile

- [x] 2.1 Create `Makefile` at project root with a `preflight` target that runs `./scripts/preflight.sh`
- [x] 2.2 Add `install` target that depends on `preflight` and then runs `./scripts/setup-openspec-skills-global.sh`
- [x] 2.3 Mark both targets as `.PHONY`

## 3. Verification

- [x] 3.1 Run `make preflight` with Node.js below 20.19 (or mock `node --version`): confirm clear version error, no install side effects
- [x] 3.2 Run `make preflight` with `openspec` already installed: confirm Node.js/npm checks are skipped
- [x] 3.3 Run `make preflight` with `skillshare` already installed: confirm curl check is skipped
- [x] 3.4 Run `make preflight` with multiple missing prerequisites: confirm all errors appear in one output block
- [x] 3.5 Run `make install` in a valid environment: confirm preflight passes then setup runs to completion
- [x] 3.6 Run `make install` with a failing preflight: confirm setup script does not execute
