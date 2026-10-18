# Benign log noise — what to ignore

If you tail CS2's logs looking for crashes, the signal is buried in a lot of
harmless noise. These lines look alarming (`ERROR`, `Exception`, "could not load")
but are **normal** under Wine/D3DMetal and do **not** indicate a problem. Filter
them out of any crash watcher so it doesn't cry wolf.

Logs live in:

```
…/Cities Skylines II/Player.log
…/Cities Skylines II/Logs/{Modding,PdxSdk,InputManager,...}.log
```

## Safe to ignore

| Log line | What it actually is |
|---|---|
| `Fallback handler could not load library …MonoBleedingEdge/data-XXXX.dll` | Mono's assembly loader probing fake names at startup. A huge one-time burst — will flood/auto-kill a naive log monitor. |
| `Curl error 7: Failed to connect to submit.backtrace.io` | The crash-telemetry uploader can't reach Backtrace. Harmless — and if it's quiet, nothing's crashing. |
| `toolbar.selectAsset … KeyNotFoundException: The given key 'Any' was not present` | A cohtml/Gameface UI binding hiccup from an asset mod. Non-fatal. |
| `JS Error … Cannot read properties of null (reading 'GroupName')` | Same family — cohtml UI reading an asset group that isn't populated yet. Non-fatal. |
| `FileNotFoundException: … \.pdxsdk\…\cache_telemetry` | First-run cache miss. |
| `FileNotFoundException: … \.cache\Mods\playset_config_lock.json` | First-run cache miss. |
| `Error disposing mod <X> … IOException … \Temp\…` | Normal on **shutdown** — temp-dir cleanup under Wine. Only appears when the game is quitting. |
| `Error decoding: Borderless … ArgumentException` | You wrote an invalid `displayMode`; use `FullscreenWindow` (see [focus-freeze-fix.md](focus-freeze-fix.md)). Not a crash. |

## A log-watcher filter that worked

A `tail -F | grep` watcher that surfaces only real trouble while suppressing the
above. Catches render faults, Harmony failures, NullReference in game code, OOM,
and D3DMetal errors:

```bash
LL="…/Cities Skylines II"
tail -n0 -F "$LL/Player.log" "$LL/Logs/Modding.log" "$LL/Logs/PdxSdk.log" \
  | grep -E --line-buffered \
      "ERROR|Exception|FATAL|RHIThread|abort|Assertion|segfault|SIGSEGV|D3DMetal.*error|OutOfMemory|crash|Harmony.*(fail|error)|NullReference" \
  | grep -viE \
      "submit\.backtrace\.io|Curl error 7|toolbar\.selectAsset|KeyNotFoundException.*'Any'|CustomLogHandler|UnityLogger|RuntimeMethodInfo|Mono JIT Code|GroupName|JS Error|gameui/index\.js|Error disposing mod|Fallback handler could not load library|MonoBleedingEdge|cache_telemetry|playset_config_lock|Error decoding: Borderless"
```

## Actually worth worrying about

- `RHIThread` / `EXCEPTION_ACCESS_VIOLATION` in a crash context → a graphics-layer
  crash (this is the class the D3DMetal graft addresses).
- `NullReferenceException` inside a specific mod's own code during gameplay (not
  the cohtml UI noise above) → that mod is misbehaving; disable it.
- A sudden `Killed` / OOM → disk or memory pressure.
