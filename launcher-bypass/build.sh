#!/usr/bin/env bash
#
# build.sh — compile the dowser passthrough stub into a Windows PE executable.
#
# Requires mingw-w64 (Homebrew):  brew install mingw-w64
# Produces:  dowser.exe  (in this directory)
#
set -euo pipefail
cd "$(dirname "$0")"

CC="${CC:-x86_64-w64-mingw32-gcc}"

if ! command -v "$CC" >/dev/null 2>&1; then
  echo "ERROR: '$CC' not found. Install mingw-w64:  brew install mingw-w64" >&2
  exit 1
fi

# -mwindows => GUI subsystem, so Steam/Wine don't spawn a stray console window.
"$CC" -O2 -mwindows -o dowser.exe dowser-passthrough.c -luser32

echo "OK: built dowser.exe"
file dowser.exe 2>/dev/null || true
echo
echo "Next: see README.md to install it over the game's Launcher/dowser.exe"
