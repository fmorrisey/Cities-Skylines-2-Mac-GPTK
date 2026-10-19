#!/usr/bin/env bash
# Double-click this file to set up Cities: Skylines II.
# (The first time, macOS may say "unidentified developer" — right-click this
#  file, choose Open, then click Open in the dialog. You only do that once.)
cd "$(dirname "$0")" || exit 1
chmod +x easy-setup.sh 2>/dev/null
./easy-setup.sh
echo
echo "You can close this window now."
