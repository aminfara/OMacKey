# OMacKey — Roadmap

What is left to build, in the order it is planned. Work goes in small
sessions: one key or one item first, then a group of related ones.

## 8 — Docs generator, README, maintenance (all done)

**8.1 Generated key documentation.** Done: `lua5.5 scripts/gen-docs.lua` renders
`docs/KEYBINDINGS.md` from `lib/catalog.lua` under the snapshot's fake Hyprland
(`--check` fails when the file is out of date, `--stdout` prints it). Run it
after changing a shortcut, an app, a relocation or a setting.

**8.2 README.** Done: what it is, the modifier model, install (script and
manual), what it touches and how to remove it, customizing, limits,
troubleshooting, contributing (with agents), acknowledgements and a disclaimer.

**8.3 Drift check after `omarchy update`.** Done: `scripts/drift.sh` renders
Omarchy's defaults alone under the snapshot's fake Hyprland and compares them
with `expected/binds-mode-off.txt`. It lists the Omarchy binds that are new,
changed or gone, and marks the ones on a key OMacKey uses (the case F7 warns
about: a later Omarchy adding `Super + Grave`). Exit 1 means drift.

- Related checks that were already there:
  - `omackey.status()` reports relocation rows whose Omarchy key is gone
    (`unused_relocations`);
  - `scripts/snapshot.sh` stops when its hash of Omarchy's files
    (`tests/snapshot/expected/omarchy.sha256`) no longer matches, and now
    points to `scripts/drift.sh`;
  - `scripts/check.sh` finds duplicate binds.
- It is a manual step after `omarchy update`; no hook runs it.

**8.4 Lint.** Done: `scripts/lint.sh` checks the syntax of every Lua file, flags
unknown globals (typos and missing `local`, via `luac5.5 -l`), forbids `print`
in `omackey/`, runs `bash -n` on the shell scripts, and runs `luacheck` and
`shellcheck` too when they are installed (neither is, here). Loading under the
mock is covered by every `scripts/snapshot.sh` run.

## Optional

**⌘Tab overlay.** A QuickShell indicator that shows the app icons while ⌘ is
held, like the Mac switcher (the user's idea).

- Omarchy's shell is QuickShell 0.3.1 (`/usr/share/omarchy/shell`). Its
  plugins have kinds `overlay`, `panel`, `bar-widget`, `service` and `menu`;
  the emojis, clipboard, image picker and reminders are overlays, so this
  would be one too.
- `~/.config/omarchy/plugins` exists and hasn't been looked into.
- IPC is `omarchy-shell [-q] <target> <method> [args]`, where `-q` is
  best-effort.
- The data is ready:
  - `switcher.snapshot()` gives the ring (app classes), the position and the
    stop;
  - `switcher.step` and `switcher.finish` are the hooks: show or refresh on
    each step, hide at the end.
- Bind callbacks must not block, so call out with `hl.dsp.exec_cmd`.
- Open question: whether spawning a process on every step is fast enough, or
  whether the plugin should read the state another way.
- Icons: map the window class to a desktop entry (QuickShell's
  `DesktopEntries.heuristicLookup`, to verify).
- It adds a plugin to the user's Omarchy shell. Ask before touching
  `~/.config/omarchy`, and make it an opt-in setting (D12).

## Deferred until the user asks

- **Persian (D11).** Test with a Persian layout active:
  - xkb `kb_layout = "us,ir"` with `grp:alts_toggle` in
    `~/.config/hypr/input.lua` (the user's file: ask before editing);
  - or fcitx5's `keyboard-ir`.

  Check that key-name binds fire and that keycode-sent chords arrive
  correctly (TESTING.md, physical protocol step 6).
- **XWayland.** Check that an XWayland client receives the synthetic keys
  once one is in use (spike S9, F1).
