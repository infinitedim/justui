#!/usr/bin/env sh
set -e

REPO="${JUSTUI_REPO:-infinitedim/justui}"
BINARY_NAME="justui"
INSTALL_DIR="${JUSTUI_INSTALL_DIR:-$HOME/.local/bin}"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64)  ARCH="x86_64" ;;
  aarch64|arm64) ARCH="aarch64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

case "$OS" in
  linux)  TARGET="${ARCH}-unknown-linux-gnu" ;;
  darwin) TARGET="${ARCH}-apple-darwin" ;;
  *) echo "Unsupported OS: $OS. Use install.ps1 on Windows." >&2; exit 1 ;;
esac

VERSION="${JUSTUI_VERSION:-}"
if [ -z "$VERSION" ] || [ "$VERSION" = "latest" ]; then
  # 1. Primary: 302 redirect resolution (rate-limit free)
  EFFECTIVE_URL=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
    "https://github.com/$REPO/releases/latest" 2>/dev/null || true)
  case "$EFFECTIVE_URL" in
    */tag/*)
      VERSION=$(printf '%s\n' "$EFFECTIVE_URL" | sed 's#.*/tag/##' | sed 's#[?#].*##' | tr -d '/[:space:]')
      ;;
    *)
      VERSION=""
      ;;
  esac

  # 2. Fallback: Authenticated API if GITHUB_TOKEN is set
  if [ -z "$VERSION" ] && [ -n "$GITHUB_TOKEN" ]; then
    VERSION=$(curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" \
      "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
      | grep '"tag_name"' | sed -n 's/.*"tag_name": *"*\([^",]*\)".*/\1/p' | tr -d '/[:space:]')
  fi

  # 3. Last resort: Unauthenticated API
  if [ -z "$VERSION" ]; then
    VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
      | grep '"tag_name"' | sed -n 's/.*"tag_name": *"*\([^",]*\)".*/\1/p' | tr -d '/[:space:]')
  fi
fi

# Guard assertion: abort if $VERSION is empty or equals "latest"
if [ -z "$VERSION" ] || [ "$VERSION" = "latest" ]; then
  echo "Error: Could not determine latest version for $REPO." >&2
  echo "Please specify a version manually: JUSTUI_VERSION=vX.Y.Z sh install.sh" >&2
  exit 1
fi

case "$VERSION" in
  v*) ;;
  *) VERSION="v$VERSION" ;;
esac

ARCHIVE="justui-${TARGET}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE}"

echo "Installing JustUI CLI ${VERSION} for ${TARGET}..."

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$URL" -o "$TMP/$ARCHIVE"

MANIFEST_URL="https://github.com/${REPO}/releases/download/${VERSION}/SHA256SUMS"
if ! curl -fsSL "$MANIFEST_URL" -o "$TMP/SHA256SUMS"; then
  echo "Error: Failed to download checksum manifest (SHA256SUMS) from $MANIFEST_URL." >&2
  echo "Integrity verification cannot be bypassed. Aborting installation." >&2
  exit 1
fi

EXPECTED_HASH=$(awk -v target="$ARCHIVE" '
  { gsub(/\r/, "") }
  $2 == target || $2 == "*"target || $2 == "./"target || $2 == "*./"target { print $1 }
' "$TMP/SHA256SUMS" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

if [ -z "$EXPECTED_HASH" ]; then
  echo "Error: Archive \"$ARCHIVE\" not found in SHA256SUMS manifest. Aborting installation." >&2
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  ACTUAL_HASH=$(sha256sum "$TMP/$ARCHIVE" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  ACTUAL_HASH=$(shasum -a 256 "$TMP/$ARCHIVE" | awk '{print $1}')
elif command -v openssl >/dev/null 2>&1; then
  ACTUAL_HASH=$(openssl dgst -sha256 "$TMP/$ARCHIVE" | sed -e 's/.*= *//' | awk '{print $1}')
else
  echo "Error: No SHA-256 utility found. Please install sha256sum, shasum, or openssl." >&2
  exit 1
fi
ACTUAL_HASH=$(printf '%s' "$ACTUAL_HASH" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
  echo "Security check failed: Checksum mismatch for downloaded archive \"$ARCHIVE\"." >&2
  echo "  Expected: $EXPECTED_HASH" >&2
  echo "  Got:      $ACTUAL_HASH" >&2
  echo "The download might be corrupted or tampered with. Aborting installation." >&2
  exit 1
fi

tar -xzf "$TMP/$ARCHIVE" -C "$TMP"

mkdir -p "$INSTALL_DIR"
cp "$TMP/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "✓ Installed to $INSTALL_DIR/$BINARY_NAME"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "  Add to PATH: export PATH=\"\$PATH:$INSTALL_DIR\"" ;;
esac
