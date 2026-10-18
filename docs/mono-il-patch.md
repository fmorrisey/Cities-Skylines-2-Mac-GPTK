# Startup crash / black screen — the `Colossal.IO` directory-enumeration throw

**Symptom:** The game launches, you hear/see it start, and it lands on a **black
screen** (or crashes during load) before the main menu. The Player.log shows an
`IOException` coming out of `Colossal.IO` while it's enumerating directories.

**Root cause:** CS2's `Colossal.IO.dll` walks directories with a Windows long-path
enumerator (`LongDirectory.MoveNext`). Under Wine, a `GetExceptionFromWin32Error`
path throws an `IOException` that doesn't happen on real Windows, and the engine
doesn't recover from it during the mod/asset remap step at startup.

**Fix:** Patch the offending throw out of the managed assembly with the upstream
**cs2-macos-patcher** (a Mono.Cecil IL patcher). It NOPs the throw in
`Colossal.IO` and also enables Paradox Mods, so one pass covers both.

> This repo does **not** vendor cs2-macos-patcher — it's someone else's tool, with
> its own license. We document invoking it and link to it. Search for
> **"cs2-macos-patcher"** (the Mono.Cecil IL patcher for CS2 on macOS) to get the
> current source; the invocation below matches that tool's CLI.

## Applying it

Requires the .NET SDK (`brew install dotnet`), then point it at the game's
`Managed` folder:

```bash
MANAGED="<bottle>/drive_c/Program Files (x86)/Steam/steamapps/common/Cities Skylines II/Cities2_Data/Managed"

# From a checkout of cs2-macos-patcher:
dotnet run --project cs2patcher -- "$MANAGED" --apply
```

A successful run reports patched assemblies and writes `.bak` backups alongside
each. On the build this was developed against it patched, among others:

```
Backtrace.Unity.dll           : 1
Colossal.IO.dll               : 3     <- the GameLaunchCrash fix (the black screen)
Colossal.IO.AssetDatabase.dll : 1
Game.dll                      : 5
PDX.SDK.dll                   : 33    <- Paradox Mods
```

## Reverting

Each patched DLL has a `.bak` next to it; restore those to undo. A Steam
"Verify integrity of game files" will also restore the originals (and you'd then
re-apply after any game update).

> Re-run the patcher after every CS2 update — an update replaces the managed
> assemblies with fresh, unpatched ones.
