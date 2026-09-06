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
tar -xzf "$TMP/$ARCHIVE" -C "$TMP"

mkdir -p "$INSTALL_DIR"
cp "$TMP/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "✓ Installed to $INSTALL_DIR/$BINARY_NAME"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "  Add to PATH: export PATH=\"\$PATH:$INSTALL_DIR\"" ;;
esac
