#!/usr/bin/env bash
# Vercel build for apps/docs: the Flutter bridge bundle, then Next.js.
#
# Vercel has no Flutter SDK. The SDK release comes from .fvmrc ("stable" or
# an exact version) resolved through Flutter's official releases_linux.json
# (scripts/flutter-release.ts), which also lists the archive's SHA-256. The
# script reuses a cached bundle when the release and the bundle inputs did
# not change (scripts/flutter-cache-key.ts); otherwise it downloads the
# archive, checks its SHA-256, builds apps/showcase into public/flutter/
# and stores the result in the build cache. Any failure fails the deploy
# (owner decision): a deploy never ships silently without the bundle.
# Red zone: see .agents/rules/security.md.
set -euo pipefail

DOCS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_DIR="${DOCS_DIR}/public/flutter"
# Vercel restores .next/cache between builds of the same project.
CACHE_ROOT="${DOCS_DIR}/.next/cache/flutter-bundle"
SDK_PARENT="${TMPDIR:-/tmp}/justui-flutter-sdk"

log() { printf 'vercel-build: %s\n' "$*"; }

ensure_tools() {
  local missing=()
  for tool in curl tar xz git unzip sha256sum; do
    command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    if command -v dnf >/dev/null 2>&1; then
      log "installing ${missing[*]}"
      dnf install -y "${missing[@]}"
    else
      log "missing tools: ${missing[*]}"
      exit 1
    fi
  fi
}

# install_sdk <version> <url> <sha256>
install_sdk() {
  local archive="${SDK_PARENT}/flutter.tar.xz"
  rm -rf "${SDK_PARENT}"
  mkdir -p "${SDK_PARENT}"
  log "downloading Flutter $1"
  curl --proto '=https' --tlsv1.2 -fsSL "$2" -o "${archive}"
  echo "$3  ${archive}" | sha256sum -c -
  tar -xJf "${archive}" -C "${SDK_PARENT}"
  rm "${archive}"
  # The archive is a git checkout owned by another user id. The exception
  # goes through the environment, so no git config file is written.
  export GIT_CONFIG_COUNT=1
  export GIT_CONFIG_KEY_0="safe.directory"
  export GIT_CONFIG_VALUE_0="${SDK_PARENT}/flutter"
  export FLUTTER_BIN="${SDK_PARENT}/flutter/bin/flutter"
  "${FLUTTER_BIN}" --disable-analytics >/dev/null
  "${FLUTTER_BIN}" --version
}

main() {
  cd "${DOCS_DIR}"
  local version url sha key
  local release
  release="$(bun scripts/flutter-release.ts)"
  read -r version url sha <<<"${release}"
  if [ -z "${sha:-}" ]; then
    log "could not resolve the Flutter release"
    exit 1
  fi
  log "Flutter ${version} (from .fvmrc via releases_linux.json)"
  key="$(bun scripts/flutter-cache-key.ts "${version}")"
  local cached="${CACHE_ROOT}/${key}"
  if [ -f "${cached}/bundle.json" ]; then
    log "cache hit ${key}"
    rm -rf "${BUNDLE_DIR}"
    mkdir -p "$(dirname "${BUNDLE_DIR}")"
    cp -R "${cached}" "${BUNDLE_DIR}"
  else
    log "cache miss ${key}"
    ensure_tools
    install_sdk "${version}" "${url}" "${sha}"
    bun scripts/build-flutter.ts
    rm -rf "${CACHE_ROOT}"
    mkdir -p "${CACHE_ROOT}"
    cp -R "${BUNDLE_DIR}" "${cached}"
  fi
  # Checks the file list, every SHA-256 against bundle.json and the budget,
  # so a corrupted cache entry fails the build too.
  bun scripts/check-flutter-budget.ts
  bun run build
}

main "$@"
