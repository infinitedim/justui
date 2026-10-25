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
  local root
  root="$(bash scripts/install-flutter.sh "${SDK_PARENT}" "$1" "$2" "$3")"
  # As root (Vercel), tar keeps the archive's owner, so git sees a checkout
  # owned by another user. The exception goes through the environment, so
  # no git config file is written.
  export GIT_CONFIG_COUNT=1
  export GIT_CONFIG_KEY_0="safe.directory"
  export GIT_CONFIG_VALUE_0="${root}"
  export FLUTTER_BIN="${root}/bin/flutter"
  "${FLUTTER_BIN}" --disable-analytics >/dev/null
  "${FLUTTER_BIN}" --version
}

# Vercel picks its own Bun ("Bun >=1.2" for bun.lock) and Corepack does not
# cover Bun, so the deploy fails unless it runs the packageManager pin.
check_bun() {
  local want have
  want="$(bun -e 'const p = await Bun.file("package.json").json(); console.log(String(p.packageManager ?? "").replace(/^bun@/, ""))')"
  have="$(bun --version)"
  log "Bun ${have} (packageManager: bun@${want})"
  if [ -z "${want}" ] || [ "${have}" != "${want}" ]; then
    log "Bun ${have} does not match packageManager bun@${want}"
    exit 1
  fi
}

main() {
  cd "${DOCS_DIR}"
  check_bun
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
