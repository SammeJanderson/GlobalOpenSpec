## ADDED Requirements

### Requirement: A standalone preflight script validates the environment

The repository SHALL provide `scripts/preflight.sh` as an executable script that checks all environment prerequisites needed before installation. The script SHALL collect every failing check and report them together in a single output block, then exit with a non-zero status if any failed. It SHALL print "Environment preflight passed." and exit 0 if all checks pass.

#### Scenario: All prerequisites satisfied

- **WHEN** Node.js ≥ 20.19 is available, npm is available, curl is available, and relevant directories are writable
- **THEN** the script prints "Environment preflight passed." and exits 0

#### Scenario: Node.js version below minimum

- **WHEN** `openspec` is not already on PATH and the installed Node.js version is below 20.19
- **THEN** the script includes a "node version below required 20.19" error in the combined failure report and exits non-zero

#### Scenario: Node.js not found

- **WHEN** `openspec` is not already on PATH and `node` is not found on PATH
- **THEN** the script includes a "node not found" error in the failure report and exits non-zero

#### Scenario: npm not found

- **WHEN** `openspec` is not already on PATH and `npm` is not on PATH
- **THEN** the script includes an "npm not found" error in the failure report and exits non-zero

#### Scenario: curl not found

- **WHEN** `skillshare` is not already on PATH and `curl` is not available
- **THEN** the script includes a "curl not found" error in the failure report and exits non-zero

#### Scenario: Multiple prerequisite failures reported together

- **WHEN** more than one prerequisite check fails
- **THEN** the script reports all failures in a single output block before exiting non-zero

#### Scenario: openspec already installed — Node.js and npm checks skipped

- **WHEN** `openspec` is already on PATH when preflight runs
- **THEN** the Node.js version check and npm check are skipped

#### Scenario: skillshare already installed — curl check skipped

- **WHEN** `skillshare` is already on PATH when preflight runs
- **THEN** the curl availability check is skipped

### Requirement: A Makefile provides install and preflight targets

The repository SHALL provide a `Makefile` at the project root. The `install` target SHALL run the preflight check then the setup script, in that order. The `preflight` target SHALL run only the preflight check without proceeding to installation.

#### Scenario: Running make install

- **WHEN** the user runs `make install`
- **THEN** `scripts/preflight.sh` runs first; if it exits 0, `scripts/setup-openspec-skills-global.sh` runs next; if preflight fails, the setup script does not run

#### Scenario: Running make preflight as a dry-run

- **WHEN** the user runs `make preflight`
- **THEN** only `scripts/preflight.sh` runs and its exit code is the Make target's exit code; no installation occurs
