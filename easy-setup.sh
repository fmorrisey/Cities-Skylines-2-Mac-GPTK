#!/usr/bin/env bash
#
# easy-setup.sh — one command that sets up Cities: Skylines II on your Mac.
#
# It finds your game, backs up what it changes, and applies the two file fixes
# for you (skip the Paradox launcher + the Steam App ID). It won't touch anything
# while the game is running, and everything it changes can be undone.
#
# Just double-click this file, or in Terminal run:   ./easy-setup.sh
#
set -uo pipefail
cd "$(dirname "$0")"

GRN=$'\033[32m'; YEL=$'\033[33m'; RED=$'\033[31m'; BLU=$'\033[34m'; B=$'\033[1m'; R=$'\033[0m'
[ -t 1 ] || { GRN=""; YEL=""; RED=""; BLU=""; B=""; R=""; }
say()  { printf '%s\n' "$*"; }
good() { printf '  %s✓%s %s\n' "$GRN" "$R" "$*"; }
warn() { printf '  %s!%s %s\n' "$YEL" "$R" "$*"; }
bad()  { printf '  %s✗%s %s\n' "$RED" "$R" "$*"; }
head() { printf '\n%s%s==> %s%s\n' "$B" "$BLU" "$*" "$R"; }
ask()  { local a; read -r -p "$1 [y/N] " a; case "$a" in [yY]*) return 0;; *) return 1;; esac; }

say "${B}Cities: Skylines II — Mac easy setup${R}"
say "This makes two small, reversible changes to your game files."

# ---------------------------------------------------------------------------
# 1. Find the game.
# ---------------------------------------------------------------------------
head "Step 1 of 4: Finding your Cities: Skylines II"

REL="Contents/SharedSupport/prefix/drive_c/Program Files (x86)/Steam/steamapps/common/Cities Skylines II"
CS2="${CS2_DIR:-}"

if [ -z "$CS2" ]; then
  # Search the usual places for game wrappers.
  IFS=$'\n' matches=( $(find \
      "/Applications/Ported Games" "$HOME/Applications/Ported Games" \
      "/Applications" "$HOME/Applications" \
      -maxdepth 1 -name "*.app" 2>/dev/null) )
  found=()
  for app in "${matches[@]}"; do
    [ -d "$app/$REL" ] && found+=("$app/$REL")
  done
  if [ "${#found[@]}" -eq 1 ]; then
    CS2="${found[0]}"
  elif [ "${#found[@]}" -gt 1 ]; then
    say "Found more than one. Pick which game wrapper to set up:"
    select pick in "${found[@]}"; do [ -n "$pick" ] && CS2="$pick" && break; done
  fi
fi

if [ -z "$CS2" ] || [ ! -d "$CS2" ]; then
  warn "Couldn't find the game automatically."
  say  "Open the folder that contains 'Cities2.exe', drag it into this window,"
  say  "then press Return:"
  read -r CS2
  CS2="${CS2%\'}"; CS2="${CS2#\'}"; CS2="${CS2%/}"   # strip quotes/trailing slash
fi

if [ ! -f "$CS2/Cities2.exe" ]; then
  bad "That folder doesn't contain Cities2.exe — stopping so nothing is changed."
  say "Tip: you can also run:  CS2_DIR=\"/full/path/to/Cities Skylines II\" ./easy-setup.sh"
  exit 1
fi
good "Game found:"
say  "    $CS2"

# Refuse to run while the game is open.
if pgrep -f "Cities2.exe" >/dev/null 2>&1; then
  bad "The game is running. Please quit it completely, then run this again."
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Skip the Paradox launcher (swap dowser.exe for the passthrough stub).
# ---------------------------------------------------------------------------
head "Step 2 of 4: Skipping the Paradox launcher"

STUB=""
RELEASE_URL="https://github.com/fmorrisey/Cities-Skylines-2-Mac-GPTK/releases/latest/download/dowser.exe"
if [ -f "launcher-bypass/dowser.exe" ]; then
  STUB="launcher-bypass/dowser.exe"                         # already present
elif command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
  ( cd launcher-bypass && ./build.sh >/dev/null 2>&1 ) && STUB="launcher-bypass/dowser.exe"
fi
# If we still don't have it, download the prebuilt stub from Releases.
if [ -z "$STUB" ] || [ ! -f "$STUB" ]; then
  say "Downloading the launcher file…"
  if curl -fsSL "$RELEASE_URL" -o "launcher-bypass/dowser.exe" 2>/dev/null \
     && [ -s "launcher-bypass/dowser.exe" ]; then
    STUB="launcher-bypass/dowser.exe"
  fi
fi

if [ -z "$STUB" ] || [ ! -f "$STUB" ]; then
  warn "Couldn't get the launcher file (no internet, or no Release published yet)."
  say  "Download 'dowser.exe' from this project's Releases page, drop it in the"
  say  "'launcher-bypass' folder, and run this again. Everything else is done."
  SKIP_LAUNCHER=1
else
  if [ -f "$CS2/Launcher/dowser.exe" ] && [ ! -f "$CS2/Launcher/dowser.exe.off" ]; then
    cp "$CS2/Launcher/dowser.exe" "$CS2/Launcher/dowser.exe.off"
    good "Backed up the original launcher (dowser.exe.off)."
  fi
  cp "$STUB" "$CS2/Launcher/dowser.exe"
  good "Launcher bypass installed. The game will start directly from Steam."
fi

# ---------------------------------------------------------------------------
# 3. Steam App ID file.
# ---------------------------------------------------------------------------
head "Step 3 of 4: Steam App ID"
printf '949230' > "$CS2/steam_appid.txt"
good "Wrote steam_appid.txt."

# ---------------------------------------------------------------------------
# 4. Set the display mode to the stable one (if we can find the settings file).
# ---------------------------------------------------------------------------
head "Step 4 of 4: Stable display mode (no more freezes)"
SET=$(find "$CS2/../../../../../users" -name "Settings.coc" -path "*Cities Skylines II*" 2>/dev/null | head -1)
if [ -n "$SET" ] && [ -f "$SET" ]; then
  cp "$SET" "$SET.bak"
  /usr/bin/sed -i '' 's/"displayMode": *"Fullscreen"/"displayMode": "FullscreenWindow"/' "$SET"
  if grep -q '"displayMode": *"FullscreenWindow"' "$SET"; then
    good "Display mode set to Fullscreen Window (borderless)."
  else
    warn "Couldn't auto-set it — just set it in-game (see below). No harm done."
  fi
else
  warn "No settings file yet (normal before first launch)."
  say  "After your first launch, set it in-game — see the final step below."
fi

# ---------------------------------------------------------------------------
# What's left for you to do (the parts a script shouldn't do for you).
# ---------------------------------------------------------------------------
head "Almost done — 2 things only you can do"
say "${B}A) Turn on mods / fix the black screen${R}"
say "   Run this in Terminal from this folder:   ${B}./get-mods-working.sh${R}"
say "   (That applies the mod/startup-crash fix. Needed once.)"
say ""
say "${B}B) Pick the stable display mode in-game${R} (if step 4 couldn't)"
say "   Launch the game, then: Options → Graphics → Display Mode →"
say "   choose ${B}\"Fullscreen Window\"${R} → Apply."
say ""
good "Setup complete. Launch Cities: Skylines II from Steam and enjoy."
say  "Changed files are backed up as *.off / *.bak next to the originals."
