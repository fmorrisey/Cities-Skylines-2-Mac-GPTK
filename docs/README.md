# Running Cities: Skylines II on Apple Silicon — full setup

Do these in order. Steps 1–4 are what you actually need; step 0 (the graft) is
only for a **fresh** bottle.

## 0. A working Wine/GPTK bottle (prerequisite)

You need CS2 installed in a Porting Kit / Wineskin wrapper whose Wine runs under
Apple's Game Porting Toolkit (D3DMetal). CS2 renders fine on D3DMetal; it does
**not** need MoltenVK.

- Easiest path: install CS2 (via Steam) into a bottle you already use for another
  GPTK game. CS2 shares that bottle's already-grafted D3DMetal happily.
- Fresh bottle: if the wrapper's bundled D3DMetal is too old and CS2 (or another
  title in the bottle) crashes on `RHIThread`, graft a newer GPTK in with the
  scripts in [`../scripts/`](../scripts/):

  ```bash
  export WRAPPER_APP="/Applications/Ported Games/Cities Skylines 2.app"
  export GPTK_VOLUME="/Volumes/Evaluation environment for Windows games 4.0 beta 2"
  ./scripts/backup-wrapper.sh
  ./scripts/overlay-gptk.sh --dry-run
  ./scripts/overlay-gptk.sh --execute      # roll back: restore-d3dmetal-v2.1.sh
  ```

Recommended Steam launch option to force the GPTK renderer DLLs:

```
WINEDLLOVERRIDES="*dxgi,*d3d10core,*d3d11,*d3d12=b" %command%
```

## 1. Bypass the Paradox launcher

Steam launches `Launcher\dowser.exe`; the Paradox launcher is unreliable under
Wine. Replace it with the passthrough stub.

```bash
cd launcher-bypass
brew install mingw-w64        # one-time
./build.sh                    # -> dowser.exe
```

Then back up the original and install the stub — see
[`../launcher-bypass/README.md`](../launcher-bypass/README.md).

## 2. steam_appid.txt

Drop a `steam_appid.txt` containing `949230` next to `Cities2.exe` so the game
initializes Steamworks without going through the launcher:

```bash
cp config/steam_appid.txt \
  "<bottle>/drive_c/Program Files (x86)/Steam/steamapps/common/Cities Skylines II/steam_appid.txt"
```

## 3. Patch the startup crash

Without this the game lands on a black screen (a Wine-specific `Colossal.IO`
`IOException`). Apply the upstream **cs2-macos-patcher** IL patch — it also enables
Paradox Mods. Full steps in [`mono-il-patch.md`](mono-il-patch.md).

## 4. Set Borderless display mode

Launch the game, then **Options → Graphics → Display Mode → "Fullscreen Window"**,
Apply. This prevents the unrecoverable focus-loss freeze that exclusive fullscreen
causes under D3DMetal. Details and the why in
[`focus-freeze-fix.md`](focus-freeze-fix.md).

## You're done

The game should launch straight in, render through D3DMetal, accept keyboard/mouse
input reliably, and load Paradox Mods from the in-game menu.

- Modding tips & gotchas: [`modding.md`](modding.md)
- Which log errors are safe to ignore: [`benign-log-noise.md`](benign-log-noise.md)

## Environment this was developed on

Apple Silicon (M-series), macOS 26.x, Porting Kit / Wineskin with stock WineHQ
Wine 10.0 under Apple GPTK D3DMetal 4.0b2, Steam, Cities: Skylines II (Unity
2022.3, DX11). CS2 ran in the same bottle as a UE5 title (see the companion
Halo-CE-2026-Mac-GPTK repo) — the bottle was already grafted to GPTK 4.0b2.
