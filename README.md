# global_open_spec

OpenSpec planning template with **global** agent skills (not vendored in this repo).

## Quick start

**Machine (once):** requires Node.js 20.19+ and `curl`. The script installs `openspec` and `skillshare` if needed.

```bash
./scripts/setup-openspec-skills-global.sh
```

**This repo (specs only):**

```bash
openspec init --tools none   # if not already initialized
```

See [docs/openspec-skills-global.md](docs/openspec-skills-global.md) for architecture, refresh, and troubleshooting.

## OpenSpec workflow

- Propose: `/opsx:propose` or `openspec new change "<name>"`
- Apply: `/opsx:apply`
- Archive: `/opsx:archive`
