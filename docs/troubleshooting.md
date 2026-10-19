# Troubleshooting (plain English)

Common problems and the quick fix. Nothing here can break your game — the setup
makes backups of everything it changes.

### macOS says "unidentified developer" when I double-click a `.command`
That's normal for files from the internet. **Right-click** the file → **Open** →
**Open**. You only do this once per file.

### The setup can't find my game
It looks in the usual places. If it can't find it, it asks you to **drag the game
folder** into the window. That's the folder that contains **`Cities2.exe`** —
usually something like:
```
…/<Your Wrapper>.app/Contents/SharedSupport/prefix/drive_c/Program Files (x86)/Steam/steamapps/common/Cities Skylines II
```
Tip: in your wrapper app, you can often "Browse C: Drive" to reach it.

### The game opens a black screen and never reaches the menu
You haven't run the mod/startup fix yet. Double-click **`Enable Mods.command`**
(or run `./get-mods-working.sh`) and choose **Patch**. This is the #1 cause.

### The game freezes when I switch to another app (and won't come back)
You're in exclusive fullscreen. In the game: **Options → Graphics → Display Mode →
"Fullscreen Window"** → Apply. That ends the freezes for good.

If it's frozen **right now**: try pressing **Cmd+Tab** away and back. If it's truly
stuck, quit the game (Force Quit if needed) — the game autosaves every ~5 minutes,
so you lose almost nothing — then relaunch and change the display mode.

### Steam still shows the Paradox launcher
The launcher bypass didn't install. Re-run **`Setup — Start Here.command`**. If it
says it couldn't get the launcher file, publish/download `dowser.exe` from this
project's **Releases** page into the `launcher-bypass` folder and run setup again.

### My mods don't show up in-game
Mods load **only when the game starts**. If you subscribed or changed your mod
playset while playing, **fully quit and relaunch** — there's no live reload.

### A mod won't download / "insufficient disk space" errors
A modded install is big. **Free up disk space**, then in Paradox Mods remove and
re-add the stuck mod. (Half-finished downloads get stranded and keep erroring
until cleared.)

### Lots of red "ERROR" lines in the logs — is it crashing?
Probably not. Many are harmless under Wine (Mono startup probes, a blocked
crash-reporter, some UI binding hiccups). See
[benign-log-noise.md](benign-log-noise.md) for the full "safe to ignore" list and
what a *real* crash looks like.

### I want to undo everything
- **Launcher:** rename `Launcher/dowser.exe.off` back to `Launcher/dowser.exe`.
- **Mods/startup patch:** re-run **`Enable Mods.command`** and choose
  **Restore original files** (or use the `.bak` files it made).
- **Display mode:** change it back in-game, or restore `Settings.coc.bak`.
- Or in Steam: **Verify integrity of game files** resets the game's own files.
