#!/bin/sh
# Install the agnts CLI on Linux or macOS:
#   curl -fsSL https://agnts.uz/install.sh | sh
# AGNTS_VERSION picks a version (default: latest); AGNTS_INSTALL_DIR the
# directory (default: /usr/local/bin, or ~/.local/bin without sudo).
set -eu

base="${AGNTS_DOWNLOAD_URL:-https://agnts.uz/cli}"
version="${AGNTS_VERSION:-latest}"

case "$(uname -s)" in
  Linux) os=unknown-linux-musl ;;
  Darwin) os=apple-darwin ;;
  *) echo "agnts: unsupported OS $(uname -s); on Windows use install.ps1" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64 | amd64) arch=x86_64 ;;
  arm64 | aarch64) arch=aarch64 ;;
  *) echo "agnts: unsupported CPU $(uname -m)" >&2; exit 1 ;;
esac
target="$arch-$os"
[ "$version" = latest ] || version="v${version#v}"
url="$base/$version/agnts-$target.tar.gz"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
echo "Downloading agnts ($target)…"
curl -fsSL "$url" -o "$tmp/agnts.tar.gz"
curl -fsSL "$url.sha256" -o "$tmp/agnts.sha256"

want=$(cut -d' ' -f1 < "$tmp/agnts.sha256")
if command -v sha256sum >/dev/null 2>&1; then
  got=$(sha256sum "$tmp/agnts.tar.gz" | cut -d' ' -f1)
else
  got=$(shasum -a 256 "$tmp/agnts.tar.gz" | cut -d' ' -f1)
fi
if [ "$want" != "$got" ]; then
  echo "agnts: checksum mismatch, not installing" >&2
  exit 1
fi
tar -xzf "$tmp/agnts.tar.gz" -C "$tmp"

dir="${AGNTS_INSTALL_DIR:-/usr/local/bin}"
if [ -w "$dir" ] || { [ ! -e "$dir" ] && mkdir -p "$dir" 2>/dev/null; }; then
  install -m 0755 "$tmp/agnts" "$dir/agnts"
elif [ -z "${AGNTS_INSTALL_DIR:-}" ] && command -v sudo >/dev/null 2>&1; then
  # sudo asks for the password on the terminal even when piped from curl.
  sudo install -m 0755 "$tmp/agnts" "$dir/agnts"
else
  dir="$HOME/.local/bin"
  mkdir -p "$dir"
  install -m 0755 "$tmp/agnts" "$dir/agnts"
  case ":$PATH:" in *":$dir:"*) ;; *) echo "Add $dir to your PATH." ;; esac
fi

echo "Installed $("$dir/agnts" --version) to $dir/agnts"
echo
echo "Next:"
echo "  agnts install root@your-server --domain agnts.example.com   (from your laptop)"
echo "  sudo agnts install --local --domain agnts.example.com      (on the server)"
