# OMacKey — Roadmap

What is left to build, in the order it is planned. Work goes in small
sessions: one key or one item first, then a group of related ones.

## 8 — Docs generator, README, maintenance

**8.1 Generated key documentation.** `scripts/gen-docs.lua` loads the config
under the snapshot's fake Hyprland (`tests/snapshot/mock.lua`) and renders
`docs/KEYBINDINGS.md` from `lib/catalog.lua` (ARCHITECTURE.md §9). The output:

- **Shortcuts:** a table per category with the Mac glyph, the exact key string
  (for `hl.unbind`, D12), the description, and the default action text.
- **Per-app actions:** a table per app, listing the keys that act differently
  there.
- **Relocated Omarchy binds:** the Omarchy key, its new key or "dropped", and
  Omarchy's description.
- **Opt-in keys:** keys behind a setting or a required command.
- **Settings:** each option with its default and doc string.
- A pointer to LIMITATIONS.md.

The catalog already holds all of this. Until 8.1 exists,
`tests/snapshot/expected/metadata-main.txt` and `behaviour-main.txt` are the
reference for what every key does.

**8.2 README.** It covers:

- what OMacKey is, and the modifier model (ARCHITECTURE.md §2);
- install and uninstall, and that `omarchy refresh hyprland` removes the
  loader lines, so re-run `./install.sh` afterwards;
- the Mac-mode toggle (⌃⇧⌘M, `scripts/omackey-mode`);
- the settings file and its options (`emacs_keys`, `release_ms`,
  `close_window_classes`);
- the opt-out recipe: `hl.unbind("<exact key string>")` in
  `~/.config/hypr/bindings.lua`;
- `wtype` for ⌘-scroll and `voxtype` for the F5 dictation keys;
- troubleshooting (TESTING.md, Recovery), and links to the generated docs.

**8.3 Drift check after `omarchy update`.** It warns when Omarchy's bindings
change and shows what changed:

- Already in place:
  - `omackey.status()` reports relocation rows whose Omarchy key is gone
    (`unused_relocations`);
  - `scripts/snapshot.sh` stops when its hash of Omarchy's files
    (`tests/snapshot/expected/omarchy.sha256`) no longer matches;
  - `scripts/check.sh` finds duplicate binds.
- To add: list the Omarchy binds that are new since the last snapshot,
  especially ones on keys OMacKey uses. For example, the online manual lists
  `Super + Grave` for the scratchpad, which would collide with ⌘\` (F7).

**8.4 Lint (optional).** A syntax and lint pass over every module under the
mock, plus `luacheck` if it is installed.

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
