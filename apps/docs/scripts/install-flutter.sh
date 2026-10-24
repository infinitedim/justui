#!/usr/bin/env bash
# Installs the Flutter SDK that .fvmrc names into <dest> and prints the SDK
# root on stdout (progress goes to stderr).
#
#   install-flutter.sh <dest> [<version> <url> <sha256>]
#
# Without a release, it resolves .fvmrc ("stable" or an exact version)
# through Flutter's official releases_linux.json (flutter-release.ts). The
# archive must match the SHA-256 the index lists, or the script fails. Used
# by vercel-build.sh and by CI (third-party setup actions are not usable
# under the repo's full-SHA pinning policy). Red zone: security.md.
set -euo pipefail

DEST="${1:?usage: install-flutter.sh <dest> [<version> <url> <sha256>]}"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf 'install-flutter: %s\n' "$*" >&2; }

if [ "$#" -ge 4 ]; then
  version="$2" url="$3" sha="$4"
else
  release="$(bun "${SCRIPTS_DIR}/flutter-release.ts")"
  read -r version url sha <<<"${release}"
fi
if [ -z "${sha:-}" ]; then
  log "could not resolve the Flutter release"
  exit 1
fi

archive="${DEST}/flutter.tar.xz"
rm -rf "${DEST}"
mkdir -p "${DEST}"
log "downloading Flutter ${version}"
curl --proto '=https' --tlsv1.2 -fsSL "${url}" -o "${archive}"
echo "${sha}  ${archive}" | sha256sum -c - >&2
tar -xJf "${archive}" -C "${DEST}"
rm "${archive}"
printf '%s\n' "${DEST}/flutter"
