# The focus-freeze fix — use Borderless, not exclusive Fullscreen

**Symptom:** You're playing fine, then the game "loses focus" (you alt-tabbed, a
notification stole focus, you opened a tool like Recolor) and the game goes
**stuck** — it stops accepting keyboard/mouse input, and **Cmd+Tabbing back does
not recover it.** Often the only way out is force-quitting.

**One-line fix:** Set **Options → Graphics → Display Mode → "Fullscreen Window"**
(borderless). Do **not** use exclusive **Fullscreen**.

## Why exclusive fullscreen wedges

CS2's input comes through **Windows.Gaming.Input**, which only delivers events
while the window holds foreground focus. Under Wine/D3DMetal, exclusive fullscreen
creates a special display surface that is **not a normal, AX-accessible macOS
window**:

```
$ osascript -e 'tell application "System Events" to perform action "AXRaise" \
    of (first window of (first process whose name is "wine64"))'
→ "Can't get window 1 of process 1 ... Invalid index."   # no window to raise
```

So when macOS shifts focus away and you try to come back, the activate event
never reaches the game, Windows.Gaming.Input never re-arms, and input stays dead.
Because there's no AX window, **even forcing the process frontmost from macOS
can't hand focus back** — the freeze is unrecoverable without killing the game.

Borderless ("Fullscreen Window") is a **real window**: focus changes round-trip
normally, Cmd+Tab works, and the freeze is gone. It looks identical to fullscreen
(covers the whole screen, no title bar), so you lose nothing visually.

## Setting it in the file (optional)

The in-game dropdown is the reliable way. If you must edit the settings file, it
lives at:

```
<bottle>/drive_c/users/<user>/AppData/LocalLow/Colossal Order/Cities Skylines II/Settings.coc
```

and the key is:

```json
"displayMode": "FullscreenWindow",
```

### ⚠️ The value is `FullscreenWindow`, NOT `Borderless`

The valid `displayMode` enum members in this build (from `Game.dll`) are exactly:

```
Fullscreen        FullscreenWindow        windowed
```

Writing `"Borderless"` is **rejected** — the game logs:

```
[FileSystem] [WARN]  Error decoding: Borderless
System.ArgumentException: Requested value 'Borderless' was not found.
```

…and silently falls back to a default (often right back into exclusive
fullscreen). If you edit the file, use `FullscreenWindow`. Also note the game
**rewrites `Settings.coc` on exit**, so edit it only while the game is closed, or
just use the in-game dropdown (which the game then persists for you).

## If you're already frozen

1. Try Cmd+Tab out and back, and clicking the game window body. (Works in
   borderless; usually *won't* in exclusive fullscreen.)
2. If truly wedged, force-quit `Cities2.exe`. CS2 **autosaves every ~5 minutes**
   to `Saves/<steamid>/<DD-Month-HH-MM-SS>.cok`, so you lose at most a few minutes.
3. Relaunch, load the latest autosave, and switch the display mode to Fullscreen
   Window so it doesn't happen again.
