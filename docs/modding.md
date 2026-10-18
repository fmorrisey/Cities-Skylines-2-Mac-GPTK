# Modding — Paradox Mods, playsets, and gotchas

Good news: **Paradox Mods works** under Wine/D3DMetal, served through the in-game
menu by the PDX SDK (no launcher needed). A full suite of code mods — RoadBuilder,
Move It, Find It, Anarchy, Traffic + Traffic Lights Enhancement, Node Controller,
Tree Controller, Skyve, and more — loads and runs for multi-hour sessions.

Prerequisite: the startup IL patch must be applied (it enables the PDX SDK). See
[`mono-il-patch.md`](mono-il-patch.md).

## Gotchas that will bite you

**Mods load only at startup.** Subscribing to a mod or switching the active
playset **while the game is running does nothing** until you fully quit and
relaunch. There is no hot-reload.

- The active playset is stored in
  `…/Cities Skylines II/.cache/Mods/playset_config.json` (`activePlaysetId`).
- What actually loaded this session is in `…/Logs/Modding.log` under
  `======= Active Playset =======`.
- A healthy code-mod load ends with something like `Mods initialized in ~8ms`
  and per-mod `Loaded <Mod> ... via Harmony` lines. If you see `~0.3ms`, nothing
  really loaded — restart.

**Don't use content that depends on paid Creator Packs.** Some maps/playsets
(e.g. community beach maps) hard-depend on paid Creator Packs; without them the
save won't load correctly. Stick to a free playset.

**Stuck/half-downloaded mods.** If mods fail mid-download (often from low disk
space), they get stranded in:

```
…/Cities Skylines II/.cache/Mods/pdx_mods/.downloading/<id>/…
```

and spam the log with:

```
[PdxSdk] [ERROR] FileIntegrityVerifier ... System.IO.FileNotFoundException: ... .cpatch ... .zip
```

Safe to delete the stuck `<id>` directories — the game re-downloads them next
launch. Delete with guarded variables so an empty var can't expand to a bad path:

```bash
DL="…/Cities Skylines II/.cache/Mods/pdx_mods/.downloading"
rm -rf "${DL:?}/${id:?}"
```

The **underlying cause is usually low disk space** — a modded CS2 install plus the
bottle is large. Free space before re-subscribing.

## Saves / autosaves

CS2 autosaves every ~5 minutes to:

```
…/Cities Skylines II/Saves/<steamid>/<DD-Month-HH-MM-SS>.cok
```

so a force-quit (e.g. recovering from the focus freeze) costs at most a few
minutes. Manual saves get the name you give them.
