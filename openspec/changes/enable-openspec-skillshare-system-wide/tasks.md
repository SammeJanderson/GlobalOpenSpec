## 1. Research global pipeline

- [x] 1.1 Run `openspec init ~/.config/openspec/agent-home --tools all` and document the exact directory layout produced
- [x] 1.2 Confirm `openspec init --tools none` in a sample app repo creates only `openspec/` without skill trees
- [x] 1.3 Install skillshare globally and determine how to register skills from the OpenSpec agent home into `~/.config/skillshare/skills/` (symlink vs collect)
- [ ] 1.4 Verify `skillshare sync` delivers opsx skills to Cursor and Claude Code from the global source

## 2. Global setup script

- [x] 2.1 Create `scripts/setup-openspec-skills-global.sh` with checks for `openspec` and `skillshare`
- [x] 2.2 Implement `OPENSPEC_AGENT_HOME` (default `~/.config/openspec/agent-home`) init/update logic
- [x] 2.3 Bridge OpenSpec agent home → skillshare global source and run `skillshare sync`
- [x] 2.4 Add optional `SKILLSHARE_AUTO_INSTALL=1` and clear error reporting; make script executable

## 3. Remove repo-persisted agent artifacts

- [x] 3.1 Delete `.claude/skills/`, `.cursor/skills/`, and opsx command files from this repo
- [x] 3.2 Re-init this repo with `openspec init --tools none` if needed so only `openspec/` remains
- [x] 3.3 Add `.gitignore` entries if OpenSpec tools ever recreate local skill dirs unintentionally

## 4. Documentation

- [x] 4.1 Add `docs/openspec-skills-global.md` explaining global home + skillshare vs per-project `openspec init --tools none`
- [x] 4.2 Document refresh workflow: `npm i -g @fission-ai/openspec@latest` then re-run setup script
- [x] 4.3 Document copy-mode workaround and link to [skillshare](https://github.com/runkids/skillshare)

## 5. Verification

- [ ] 5.1 On a clean machine profile, run setup script and confirm opsx skills work in a second repo with no local skills directory
- [ ] 5.2 Run `openspec update` on agent home and `skillshare sync`; confirm agents pick up template changes
- [x] 5.3 Note platform-specific behavior (macOS, Linux, Windows) in docs

## 6. Commands / extras (optional)

- [x] 6.1 Evaluate syncing opsx slash commands from global agent home via skillshare extras
- [x] 6.2 If deferred, document that skills-only global delivery is sufficient for v1
