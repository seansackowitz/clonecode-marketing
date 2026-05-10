#!/bin/sh
# clonecode installer.
#
# Usage:
#     curl -fsSL https://clonecode.io/install.sh | sh
#
# Environment variables:
#     CLONECODE_VERSION       version tag to install (default: latest)
#     CLONECODE_INSTALL_DIR   install dir (default: $HOME/.local/bin)
#     CLONECODE_REPO          GH repo override (default: seansackowitz/clonecode)

set -eu

REPO="${CLONECODE_REPO:-seansackowitz/clonecode}"
INSTALL_DIR="${CLONECODE_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${CLONECODE_VERSION:-latest}"

err()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m→\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33mwarning:\033[0m %s\n' "$*"; }

need() { command -v "$1" >/dev/null 2>&1 || err "missing required command: $1"; }
need curl
need tar
need uname

detect_target() {
  os=$(uname -s)
  arch=$(uname -m)
  case "$os" in
    Darwin)
      case "$arch" in
        arm64)  echo "aarch64-apple-darwin" ;;
        x86_64) echo "x86_64-apple-darwin" ;;
        *)      err "unsupported macOS arch: $arch" ;;
      esac
      ;;
    Linux)
      case "$arch" in
        x86_64)         echo "x86_64-unknown-linux-gnu" ;;
        aarch64|arm64)  echo "aarch64-unknown-linux-gnu" ;;
        *)              err "unsupported Linux arch: $arch" ;;
      esac
      ;;
    *)
      err "unsupported OS: $os (only macOS and Linux are released; build from source via cargo)"
      ;;
  esac
}

target=$(detect_target)

if [ "$VERSION" = "latest" ]; then
  info "resolving latest version"
  VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
  [ -n "$VERSION" ] || err "could not resolve latest version from GitHub"
fi

asset="clonecode-$target.tar.gz"
url="https://github.com/$REPO/releases/download/$VERSION/$asset"

info "downloading $url"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

curl -fsSL "$url" -o "$tmp/$asset" || err "download failed for $url"

# Best-effort checksum verification when shasum is present.
if command -v shasum >/dev/null 2>&1; then
  if curl -fsSL "$url.sha256" -o "$tmp/$asset.sha256" 2>/dev/null; then
    ( cd "$tmp" && shasum -a 256 -c "$asset.sha256" >/dev/null ) || err "checksum mismatch for $asset"
    ok "checksum verified"
  fi
fi

tar -xzf "$tmp/$asset" -C "$tmp"
[ -f "$tmp/clonecode" ] || err "tarball did not contain clonecode binary"

mkdir -p "$INSTALL_DIR"
mv "$tmp/clonecode" "$INSTALL_DIR/clonecode"
chmod +x "$INSTALL_DIR/clonecode"

ok "installed clonecode $VERSION to $INSTALL_DIR/clonecode"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    warn "$INSTALL_DIR is not on your PATH."
    printf '\n  Add this to your shell profile:\n    export PATH="%s:$PATH"\n\n' "$INSTALL_DIR"
    ;;
esac

# Smoke test, but don't fail the install on it.
"$INSTALL_DIR/clonecode" --version 2>/dev/null || true
