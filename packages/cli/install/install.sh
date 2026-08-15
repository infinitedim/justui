#!/usr/bin/env sh
set -e

REPO="infinitedim/justui"
BINARY_NAME="justui"
INSTALL_DIR="${JUSTUI_INSTALL_DIR:-$HOME/.local/bin}"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64)  ARCH="x86_64" ;;
  aarch64|arm64) ARCH="aarch64" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

case "$OS" in
  linux)  TARGET="${ARCH}-unknown-linux-gnu" ;;
  darwin) TARGET="${ARCH}-apple-darwin" ;;
  *) echo "Unsupported OS: $OS. Use install.ps1 on Windows."; exit 1 ;;
esac

VERSION="${JUSTUI_VERSION:-latest}"
if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
fi

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
