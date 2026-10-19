# Cities: Skylines II on a Mac 🏙️

Play **Cities: Skylines II** on an **Apple Silicon Mac** (M1/M2/M3/M4…), with
mods, smoothly. This project gives you a couple of double-click setup helpers and
plain-English instructions.

> You still buy and download the game yourself (through Steam, inside a Mac game
> wrapper like **Porting Kit** or **Whisky/CrossOver**). This project just applies
> the handful of fixes that make it run well on a Mac. It changes files in a copy
> of the game *you own*, and everything it changes is backed up and reversible.

---

## ⭐ Easy setup (for players)

**What you need first:** Cities: Skylines II installed through Steam inside a Mac
game wrapper that uses Apple's Game Porting Toolkit (Porting Kit is the common
one). If the game already launches but misbehaves, you're in the right place.

**Then just do this:**

1. **Get this project.** Click the green **Code** button above → **Download ZIP**.
   Double-click the ZIP to unzip it, and open the folder.
2. **Double-click `Setup — Start Here.command`.**
   - The first time, macOS may say *"unidentified developer."* Right-click the
     file → **Open** → **Open**. (You only do this once.)
   - A window opens and does everything automatically: it finds your game, skips
     the clunky Paradox launcher, and sets the stable display mode. It backs up
     anything it touches.
3. **Double-click `Enable Mods.command`.**
   - This turns on mods and fixes the black-screen-on-startup problem. Follow the
     simple on-screen menu and choose **Patch**. If it offers to install something
     it needs, say yes.
4. **Launch Cities: Skylines II from Steam** and play.
   - If the game ever freezes when you switch apps: in the game go to
     **Options → Graphics → Display Mode → "Fullscreen Window"** and click Apply.
     (The setup tries to set this for you, but doing it in-game makes it stick.)

That's it. Mods are in the in-game **Paradox Mods** menu.

**Something not working?** See [Troubleshooting](docs/troubleshooting.md).

---

## What each helper does (plain version)

| You double-click… | …and it |
|---|---|
| **Setup — Start Here.command** | Finds your game, swaps the Paradox launcher for a tiny "just start the game" file, writes the Steam ID file, and sets the no-freeze display mode. All backed up. |
| **Enable Mods.command** | Downloads the trusted community patcher and runs its guided menu to turn on mods + fix the startup crash. |

Prefer the command line or want the details? Everything the helpers do is also
written out step-by-step in **[docs/README.md](docs/README.md)**.

---

## The fixes, briefly

- **Skip the Paradox launcher** — Steam starts the launcher, which is flaky on
  Mac; we replace it with a tiny pass-through so the game starts directly.
  ([details](launcher-bypass/README.md))
- **Black screen / startup crash** — a Mac/Wine-only error in the game's file
  code; fixed by the community patcher. ([details](docs/mono-il-patch.md))
- **The freeze when you switch apps** — caused by exclusive fullscreen; fixed by
  using **Fullscreen Window** (borderless). ([details](docs/focus-freeze-fix.md))
- **Mods** — tips, and which scary-looking log messages are actually harmless.
  ([mods](docs/modding.md) · [log noise](docs/benign-log-noise.md))

---

## For tinkerers

- Building the launcher stub yourself, the D3DMetal "graft" scripts for a fresh
  wrapper, and all the technical notes live in [docs/README.md](docs/README.md)
  and [scripts/](scripts/).
- After cloning with `git`, enable the safety hook: `git config core.hooksPath .githooks`

> ### ⚠️ No Apple binaries here
> Apple's Game Porting Toolkit can't be redistributed. This project ships
> **only** scripts, source, and docs — never any Apple file. A pre-commit hook
> enforces that. You download the Game Porting Toolkit from Apple yourself.

> ### ⚠️ Unsupported
> This bypasses a launcher, patches game files, and (optionally) swaps in beta
> graphics libraries. Not supported by Apple, Paradox, Colossal Order, or the
> wrapper makers. It makes backups, but use it at your own risk.

## License & credits

MIT for the scripts, source, and docs — see [LICENSE](LICENSE) and [NOTICE](NOTICE).
The mod/startup fix is powered by the upstream
**[cs2-macos-patcher](https://github.com/alien-agent/cs2-macos-patcher)** by
alien-agent (downloaded by the helper, not bundled here). Thanks to the Porting
Kit, Wine, and Cities: Skylines modding communities.
