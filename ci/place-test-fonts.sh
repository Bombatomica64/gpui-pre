#!/usr/bin/env bash
# svg_renderer tests include IBM Plex Sans and Lilex at the Zed monorepo path
# crates/gpui/src/../../../assets/fonts/. This snapshot sits at the repo root,
# so that path is three directories above src/, outside the checkout.
# Download the two faces from the zed rev this snapshot was cut from.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
rev=$(sed -n 's/^zed-rev = "\(.*\)"/\1/p' "$root/Cargo.toml")
if [[ -z "$rev" ]]; then
  echo "place-test-fonts: zed-rev not found in Cargo.toml" >&2
  exit 1
fi

dest=$(cd "$root/src" && cd ../../.. && pwd)/assets/fonts
mkdir -p "$dest/ibm-plex-sans" "$dest/lilex"

base="https://raw.githubusercontent.com/zed-industries/zed/${rev}/assets/fonts"

fetch() {
  local url=$1 destfile=$2 sha=$3
  if [[ -f "$destfile" ]] && echo "${sha}  ${destfile}" | sha256sum -c --status; then
    return 0
  fi
  curl -fsSL "$url" -o "$destfile"
  echo "${sha}  ${destfile}" | sha256sum -c --status
}

fetch "${base}/ibm-plex-sans/IBMPlexSans-Regular.ttf" \
  "$dest/ibm-plex-sans/IBMPlexSans-Regular.ttf" \
  "975dcda37d80f038dcd143c22e33ca2d97a0cc5a929aace1c749153b0fe1afa5"
fetch "${base}/lilex/Lilex-Regular.ttf" \
  "$dest/lilex/Lilex-Regular.ttf" \
  "8a467ad5a1941dc7c9cebaee34e3ed9364a73b48393034e363e4b528bd711d04"

echo "place-test-fonts: $dest"
