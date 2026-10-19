#!/usr/bin/env bash
# Double-click this file to turn on mods and fix the black-screen startup.
# (First time: right-click → Open if macOS warns about an unidentified developer.)
cd "$(dirname "$0")" || exit 1
chmod +x get-mods-working.sh 2>/dev/null
./get-mods-working.sh
echo
echo "You can close this window now."
