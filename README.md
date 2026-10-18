# Cities-Skylines-2-Mac-GPTK

Scripts and field notes for running **Cities: Skylines II** (Unity, DirectX 11)
on **Apple Silicon** through a Porting Kit / Wineskin wrapper with Apple's
**Game Porting Toolkit (D3DMetal)**.

Unlike many translated titles, CS2 renders *fine* under D3DMetal — the hard
parts are everything around it: the Paradox launcher, a Wine-specific crash on
startup, the keyboard/focus freeze, and getting Paradox Mods to load. This repo
collects the fixes that got it to a smooth, modded, multi-hour session on an
M-series Mac.

> ### ⚠️ No Apple binaries here
> Apple's GPTK license does not permit redistributing D3DMetal. This repo ships
> **scripts, source, and documentation only**; the graft scripts operate on a
> redist *you* download from Apple with your own developer account. A pre-commit
> hook blocks binaries from ever being committed.

> ### ⚠️ Unsupported, and it edits a game you own
> This bypasses a game launcher, replaces the graphics translation layer with
> **beta** libraries, and patches game assemblies. Not supported by Apple,
> CodeWeavers, Porting Kit, Paradox, or Colossal Order. Back up first — the
> scripts insist on it.

## What's here

| Area | What it fixes | Where |
|---|---|---|
| **Launcher bypass** | Steam launches the Paradox launcher (`dowser.exe`), which is unreliable under Wine | [`launcher-bypass/`](launcher-bypass/) |
| **Focus-freeze fix** | Exclusive fullscreen hard-locks on focus loss; input dies, Cmd+Tab can't recover | [`docs/focus-freeze-fix.md`](docs/focus-freeze-fix.md) |
| **Startup crash** | `Colossal.IO` throws an `IOException` enumerating directories under Wine → black screen | [`docs/mono-il-patch.md`](docs/mono-il-patch.md) |
| **Modding** | Paradox Mods, playsets, and which errors are safe to ignore | [`docs/modding.md`](docs/modding.md) |
| **D3DMetal graft** | Only needed for a *fresh* bottle — overlay a newer GPTK into the wrapper | [`scripts/`](scripts/) + [Halo repo notes](#the-graft) |
| **Log noise** | The flood of benign errors so a crash watcher doesn't cry wolf | [`docs/benign-log-noise.md`](docs/benign-log-noise.md) |

**Start here:** [`docs/README.md`](docs/README.md) — the full setup in order.

## Quick start (assuming a working Wine/GPTK bottle)

```bash
# 1. Bypass the Paradox launcher
#    (build the stub, back up the original, drop the stub in)
cd launcher-bypass && ./build.sh          # produces dowser.exe
#    see launcher-bypass/README.md for the install step

# 2. Tell Steam we own the game without its launcher
cp config/steam_appid.txt "<...>/steamapps/common/Cities Skylines II/steam_appid.txt"

# 3. Patch the startup IOException (uses the upstream cs2-macos-patcher tool)
#    see docs/mono-il-patch.md

# 4. In-game: Options -> Graphics -> Display Mode -> "Fullscreen Window"
#    (NOT exclusive Fullscreen — see docs/focus-freeze-fix.md)
```

## The graft

If you're putting CS2 in its **own** bottle (rather than reusing an already-grafted
one), you may need a newer GPTK D3DMetal than the wrapper ships. The scripts here
(`backup-wrapper.sh`, `overlay-gptk.sh`, `restore-*.sh`) are the same ones proven
in the companion repo and are parameterized by `WRAPPER_APP` / `GPTK_VOLUME`:

```bash
export WRAPPER_APP="/Applications/Ported Games/Cities Skylines 2.app"
export GPTK_VOLUME="/Volumes/Evaluation environment for Windows games 4.0 beta 2"
./scripts/backup-wrapper.sh
./scripts/overlay-gptk.sh --dry-run
./scripts/overlay-gptk.sh --execute
```

Roll back with `./scripts/restore-d3dmetal-v2.1.sh`. Every destructive script
dry-runs first, refuses to touch a running wrapper, and verifies backups before
writing.

## Enable the safety hook after cloning

```bash
git config core.hooksPath .githooks
```

## Credits

- The startup `IOException` fix uses the upstream **cs2-macos-patcher** IL patcher
  (see [`docs/mono-il-patch.md`](docs/mono-il-patch.md) for the link) — we invoke
  it, we don't re-host it.
- Apple **Game Porting Toolkit** / D3DMetal — downloaded by you from Apple; never
  bundled here.

## License

MIT for the scripts, source, and docs — see [LICENSE](LICENSE). See [NOTICE](NOTICE)
for the Apple-software boundary and other third-party software referenced.
