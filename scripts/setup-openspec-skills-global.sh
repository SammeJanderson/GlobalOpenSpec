#!/usr/bin/env bash
# Install OpenSpec workflow skills globally: one OpenSpec agent home + skillshare sync.
# Per-project repos should use: openspec init --tools none
set -euo pipefail

OPENSPEC_AGENT_HOME="${OPENSPEC_AGENT_HOME:-${HOME}/.config/openspec/agent-home}"
SKILLSHARE_CONFIG_DIR="${SKILLSHARE_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/skillshare}"
SKILLSHARE_SKILLS_DIR="${SKILLSHARE_SKILLS_DIR:-${SKILLSHARE_CONFIG_DIR}/skills}"
OPENSPEC_SKILLS_SOURCE="${OPENSPEC_SKILLS_SOURCE:-${OPENSPEC_AGENT_HOME}/.claude/skills}"

info() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# Ensure npm global bin is on PATH (common after fresh Node install).
refresh_path_for_global_bins() {
  if command -v npm >/dev/null 2>&1; then
    local npm_bin
    npm_bin=$(npm prefix -g 2>/dev/null)/bin
    if [[ -d "${npm_bin}" ]]; then
      case ":${PATH}:" in
        *":${npm_bin}:"*) ;;
        *) export PATH="${npm_bin}:${PATH}" ;;
      esac
    fi
  fi
  local local_bin="${SKILLSHARE_INSTALL_DIR:-${HOME}/.local/bin}"
  if [[ -d "${local_bin}" ]]; then
    case ":${PATH}:" in
      *":${local_bin}:"*) ;;
      *) export PATH="${local_bin}:${PATH}" ;;
    esac
  fi
}

ensure_openspec() {
  refresh_path_for_global_bins
  if command -v openspec >/dev/null 2>&1; then
    info "openspec: $(command -v openspec) ($(openspec --version 2>/dev/null || echo unknown version))"
    return 0
  fi
  if [[ "${SKIP_CLI_INSTALL:-0}" == "1" ]]; then
    die "openspec not found. Install: npm install -g @fission-ai/openspec@latest"
  fi
  command -v npm >/dev/null 2>&1 \
    || die "npm not found. Install Node.js 20.19+ (https://nodejs.org) before running this script."
  info "Installing openspec (@fission-ai/openspec)..."
  npm install -g @fission-ai/openspec@latest
  refresh_path_for_global_bins
  command -v openspec >/dev/null 2>&1 \
    || die "openspec install finished but openspec is not on PATH. Add $(npm prefix -g)/bin to PATH."
  info "openspec: $(command -v openspec) ($(openspec --version))"
}

install_skillshare() {
  # Upstream install.sh defaults to /usr/local/bin, which often does not exist on macOS.
  local install_dir="${SKILLSHARE_INSTALL_DIR:-${HOME}/.local/bin}"
  mkdir -p "${install_dir}"
  export INSTALL_DIR="${install_dir}"
  info "Installing skillshare to ${INSTALL_DIR}..."
  curl -fsSL https://raw.githubusercontent.com/runkids/skillshare/main/install.sh | sh
}

ensure_skillshare() {
  refresh_path_for_global_bins
  if command -v skillshare >/dev/null 2>&1; then
    info "skillshare: $(command -v skillshare)"
    return 0
  fi
  if [[ "${SKIP_CLI_INSTALL:-0}" == "1" ]]; then
    die "skillshare not found. Install: https://github.com/runkids/skillshare"
  fi
  command -v curl >/dev/null 2>&1 \
    || die "curl not found. Install curl or install skillshare manually."
  install_skillshare
  refresh_path_for_global_bins
  command -v skillshare >/dev/null 2>&1 \
    || die "skillshare install finished but skillshare is not on PATH. Add ${SKILLSHARE_INSTALL_DIR:-${HOME}/.local/bin} to PATH."
  info "skillshare: $(command -v skillshare)"
}

agent_home_has_skills() {
  [[ -d "${OPENSPEC_SKILLS_SOURCE}/openspec-propose" ]] \
    || [[ -d "${OPENSPEC_SKILLS_SOURCE}/openspec-apply-change" ]]
}

setup_openspec_agent_home() {
  mkdir -p "${OPENSPEC_AGENT_HOME}"
  if agent_home_has_skills; then
    info "Updating OpenSpec agent home at ${OPENSPEC_AGENT_HOME}..."
    openspec update "${OPENSPEC_AGENT_HOME}" --force
  else
    info "Initializing OpenSpec agent home at ${OPENSPEC_AGENT_HOME} (all tools)..."
    openspec init "${OPENSPEC_AGENT_HOME}" --tools all --force
  fi
  [[ -d "${OPENSPEC_SKILLS_SOURCE}" ]] \
    || die "Expected skills under ${OPENSPEC_SKILLS_SOURCE} after openspec init/update"
}

setup_skillshare_global() {
  if [[ ! -d "${SKILLSHARE_CONFIG_DIR}" ]] \
    || { [[ ! -f "${SKILLSHARE_CONFIG_DIR}/config.yaml" ]] \
      && [[ ! -f "${SKILLSHARE_CONFIG_DIR}/config.yml" ]]; }; then
    info "Initializing global skillshare at ${SKILLSHARE_CONFIG_DIR}..."
    skillshare init
  fi
  mkdir -p "${SKILLSHARE_SKILLS_DIR}"
}

bridge_openspec_skills_to_skillshare() {
  info "Linking OpenSpec skills into skillshare source (${SKILLSHARE_SKILLS_DIR})..."
  local skill_path name target
  for skill_path in "${OPENSPEC_SKILLS_SOURCE}"/*/; do
    [[ -d "${skill_path}" ]] || continue
    name=$(basename "${skill_path}")
    target="${SKILLSHARE_SKILLS_DIR}/${name}"
    # Absolute symlink so skillshare and agents resolve reliably
    ln -sfn "$(cd "${skill_path}" && pwd)" "${target}"
    info "  ${name} -> ${target}"
  done
}

sync_agents() {
  info "Syncing to configured agent targets..."
  if skillshare sync --help 2>/dev/null | grep -q '\-\-all'; then
    skillshare sync --all 2>/dev/null || skillshare sync
  else
    skillshare sync
  fi
}

print_next_steps() {
  info ""
  info "OpenSpec global skills setup complete."
  info "  Agent home:     ${OPENSPEC_AGENT_HOME}"
  info "  Skillshare src: ${SKILLSHARE_SKILLS_DIR}"
  info ""
  info "Per application repo (specs only, no skills in git):"
  info "  openspec init --tools none"
  info ""
  info "After upgrading openspec: re-run this script."
  info "If symlinks fail on a target: skillshare target <name> --mode copy && skillshare sync"
}

main() {
  ensure_openspec
  ensure_skillshare
  setup_openspec_agent_home
  setup_skillshare_global
  bridge_openspec_skills_to_skillshare
  sync_agents
  print_next_steps
}

main "$@"
