#!/usr/bin/env bash
# Validate environment prerequisites before running the OpenSpec global skills setup.
# Exit 0 if all checks pass; exit 1 with a full error list if any fail.
set -euo pipefail

# Mirrored from setup-openspec-skills-global.sh so this script is self-contained.
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

check_node() {
  if ! command -v node >/dev/null 2>&1; then
    errors+=("node not found — install Node.js 20.19+ from https://nodejs.org")
    return
  fi
  local node_ver major minor
  node_ver=$(node --version 2>/dev/null | sed 's/^v//')
  major=${node_ver%%.*}
  minor=${node_ver#*.}
  minor=${minor%%.*}
  if [[ "${major}" -lt 20 ]] || { [[ "${major}" -eq 20 ]] && [[ "${minor}" -lt 19 ]]; }; then
    errors+=("node ${node_ver} is below required 20.19 — upgrade Node.js (https://nodejs.org)")
  fi
}

check_npm() {
  if ! command -v npm >/dev/null 2>&1; then
    errors+=("npm not found — ensure npm ships with your Node.js install")
  fi
}

check_curl() {
  if ! command -v curl >/dev/null 2>&1; then
    errors+=("curl not found — install curl or install skillshare manually: https://github.com/runkids/skillshare")
  fi
}

main() {
  refresh_path_for_global_bins

  local errors=()

  if ! command -v openspec >/dev/null 2>&1; then
    check_node
    check_npm
  fi

  if ! command -v skillshare >/dev/null 2>&1; then
    check_curl
  fi

  if [[ ${#errors[@]} -gt 0 ]]; then
    printf 'error: environment preflight failed:\n' >&2
    for err in "${errors[@]}"; do
      printf '  - %s\n' "${err}" >&2
    done
    exit 1
  fi

  printf 'Environment preflight passed.\n'
}

main "$@"
