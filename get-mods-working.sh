#!/usr/bin/env bash
#
# get-mods-working.sh — turn on mods and fix the black-screen startup crash.
#
# This uses the excellent upstream tool "cs2-macos-patcher" by alien-agent. We
# don't ship it; this helper downloads it and runs its guided patcher, pointed
# at your game. The patcher installs anything it needs (like .NET) by itself and
# makes its own backups. It's always safe to re-run.
#
# In Terminal, from this folder, run:   ./get-mods-working.sh
#
set -uo pipefail
cd "$(dirname "$0")"

GRN=$'\033[32m'; YEL=$'\033[33m'; RED=$'\033[31m'; BLU=$'\033[34m'; B=$'\033[1m'; R=$'\033[0m'
[ -t 1 ] || { GRN=""; YEL=""; RED=""; BLU=""; B=""; R=""; }
say() { printf '%s\n' "$*"; }
good(){ printf '  %s✓%s %s\n' "$GRN" "$R" "$*"; }
warn(){ printf '  %s!%s %s\n' "$YEL" "$R" "$*"; }
bad() { printf '  %s✗%s %s\n' "$RED" "$R" "$*"; }

PATCHER_REPO="https://github.com/alien-agent/cs2-macos-patcher"
TOOLS="$HOME/.cache/cs2-mac-setup"
PATCHER="$TOOLS/cs2-macos-patcher"

say "${B}Cities: Skylines II — enable mods / fix the black screen${R}"

# --- 1. Need git (ships with Xcode command line tools on macOS) ------------
if ! command -v git >/dev/null 2>&1; then
  bad "'git' isn't installed. Run this once to get it, then try again:"
  say "    xcode-select --install"
  exit 1
fi

# --- 2. Find the game's Managed folder (so it works on Porting Kit too) -----
REL="Contents/SharedSupport/prefix/drive_c/Program Files (x86)/Steam/steamapps/common/Cities Skylines II"
CS2="${CS2_DIR:-}"
if [ -z "$CS2" ]; then
  IFS=$'\n' matches=( $(find \
      "/Applications/Ported Games" "$HOME/Applications/Ported Games" \
      "/Applications" "$HOME/Applications" \
      -maxdepth 1 -name "*.app" 2>/dev/null) )
  for app in "${matches[@]}"; do [ -d "$app/$REL" ] && CS2="$app/$REL" && break; done
fi
MANAGED=""
[ -n "$CS2" ] && [ -d "$CS2/Cities2_Data/Managed" ] && MANAGED="$CS2/Cities2_Data/Managed"

# --- 3. Download (or update) the patcher -----------------------------------
mkdir -p "$TOOLS"
if [ -d "$PATCHER/.git" ]; then
  say "Updating the patcher…"; git -C "$PATCHER" pull --ff-only -q || true
else
  say "Downloading the patcher from alien-agent/cs2-macos-patcher…"
  git clone -q "$PATCHER_REPO" "$PATCHER" || { bad "Download failed — check your internet."; exit 1; }
fi
good "Patcher ready at: $PATCHER"

# --- 4. Run it. It's interactive; just follow the menu (choose Patch). ------
say ""
say "${B}Now follow the patcher's menu — choose “Patch”.${R}"
say "If it asks to install .NET via Homebrew, say yes. To undo later, re-run"
say "this and choose “Restore original files”."
say ""
if [ -n "$MANAGED" ]; then
  good "Pointing it straight at your game:"
  say  "    $MANAGED"
  exec "$PATCHER/patch.py" "$MANAGED"
else
  warn "Couldn't auto-locate your game folder — the patcher will search for it,"
  warn "or you can paste the path when asked."
  exec "$PATCHER/patch.py"
fi
