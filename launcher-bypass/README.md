# Launcher bypass — skip the Paradox launcher

On Steam, Cities: Skylines II launches `Launcher\dowser.exe`, which starts the
**Paradox launcher** UI before the game. Under Wine/D3DMetal the Paradox launcher
is unreliable, and the usual Steam launch-option "skip launcher" flag doesn't help
because **Steam invokes `dowser.exe` directly**, not the game.

The fix: replace `dowser.exe` with a tiny stub that just starts `..\Cities2.exe`
(and gives its window a foreground nudge at startup). Paradox Mods still works —
it's served through the in-game menu via the PDX SDK, not the launcher.

## Build

```bash
brew install mingw-w64     # one-time
./build.sh                 # produces dowser.exe
```

## Install

> Do this with the game **not** running.

```bash
# Path to the game inside your bottle (adjust to your wrapper):
GAME="/Applications/Ported Games/<Your Wrapper>.app/Contents/SharedSupport/prefix/drive_c/Program Files (x86)/Steam/steamapps/common/Cities Skylines II"

# 1. Back up the real Paradox launcher (keep it — do not delete):
mv "$GAME/Launcher/dowser.exe" "$GAME/Launcher/dowser.exe.off"

# 2. Drop the stub in its place:
cp dowser.exe "$GAME/Launcher/dowser.exe"
```

Launch from Steam as normal; it now goes straight to the game.

## Uninstall / revert

```bash
mv "$GAME/Launcher/dowser.exe.off" "$GAME/Launcher/dowser.exe"
```

## How the stub works

See the header comment in [`dowser-passthrough.c`](dowser-passthrough.c). In short:

1. Resolves `..\Cities2.exe` relative to its own location and starts it.
2. For ~25 s, repeatedly pushes the game's largest visible top-level window to the
   foreground (`AllowSetForegroundWindow` → `ShowWindow` → `BringWindowToTop` →
   `SetForegroundWindow` → `SetActiveWindow` → `SetFocus`).
3. Waits for the game to exit and returns its exit code, so Steam tracks
   "running" / "stopped" correctly.

> The foreground nudge is a **startup** convenience only. The real cure for the
> recurring focus-loss freeze is running in **borderless** display mode — see
> [`../docs/focus-freeze-fix.md`](../docs/focus-freeze-fix.md). Exclusive
> fullscreen will still wedge even with this stub.
