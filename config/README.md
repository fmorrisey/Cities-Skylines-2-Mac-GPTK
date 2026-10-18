# config/

Small configuration artifacts referenced by the setup.

## `steam_appid.txt`

Contains the single line `949230` (CS2's Steam App ID). Place it next to
`Cities2.exe` in the game directory so the game initializes Steamworks directly
without the Paradox/Steam launcher handing it the App ID:

```
<bottle>/drive_c/Program Files (x86)/Steam/steamapps/common/Cities Skylines II/steam_appid.txt
```

## Display mode (reference)

The one setting that matters most for stability lives in the game's `Settings.coc`:

```json
"displayMode": "FullscreenWindow"
```

Set it via **Options → Graphics → Display Mode → "Fullscreen Window"** in-game —
don't hand-edit unless the game is closed, and never write `"Borderless"` (invalid;
the game rejects it). See [`../docs/focus-freeze-fix.md`](../docs/focus-freeze-fix.md).
