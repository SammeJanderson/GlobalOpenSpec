## Why

The setup script currently embeds environment assumptions inside installation steps, so a missing prerequisite causes confusing mid-install failures. The fix should be a standalone, reusable preflight script that can be called independently — and a Makefile that makes the install flow explicit: check the environment first, then run the setup.

## What Changes

- Add `scripts/preflight.sh` — a standalone script that validates all environment prerequisites (Node.js ≥ 20.19, npm, curl, write access). Exits with a full error list if anything fails; exits 0 with a "passed" message if all checks pass.
- Add `Makefile` with an `install` target that runs `scripts/preflight.sh` then `scripts/setup-openspec-skills-global.sh`. Also expose `preflight` as its own Make target for dry-run validation.
- Remove preflight logic from `scripts/setup-openspec-skills-global.sh` — it delegates this concern to the standalone script when invoked via Make, keeping the setup script focused on its install steps.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `openspec-skillshare-setup`: adds a Makefile as the primary install entry point and a separate preflight script; the Makefile chains preflight → install so the environment is always validated before side effects begin.

## Impact

- New file: `scripts/preflight.sh`
- New file: `Makefile`
- Minor simplification to `scripts/setup-openspec-skills-global.sh` (drop any inline prerequisite guards that are now covered by preflight)
