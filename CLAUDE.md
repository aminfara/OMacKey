# CLAUDE.md — OMacKey

OMacKey adds macOS-style keyboard shortcuts to Omarchy (Arch + Hyprland, Lua
config). It is plain Hyprland Lua, layered on top of Omarchy's default
bindings and installed into `~/.config/hypr`. It's for people who switch
daily between a work Mac and an Omarchy machine.

## Documents

- **`docs/ARCHITECTURE.md`**:
  - goal and non-goals;
  - the modifier model and the arrow rule;
  - decisions D1–D13 and RD1–RD6;
  - layout and load order, the spec / app / relocation / settings formats;
  - invariants, how to add a key, an app or a relocation;
  - references and history.
- **`docs/TESTING.md`**: the snapshot harness, live validation, handler tests,
  the physical protocol, test recipes, recovery.
- **`docs/FINDINGS.md`**: facts about Hyprland, Omarchy and the apps (F0–F26).
  Code comments cite them by number.
- **`docs/LIMITATIONS.md`**: what is not mapped, why, and what to use instead.
- **`docs/ROADMAP.md`**: what is left (the optional ⌘Tab overlay and the
  deferred tests).

Read the relevant parts before changing anything. After a context compaction,
re-read this file and ARCHITECTURE.md in full.

## Session workflow

The user works in small sessions: one key first, then one group of related
keys. Don't run ahead into later roadmap items.

1. Read ROADMAP.md and the parts of ARCHITECTURE.md, FINDINGS.md and
   LIMITATIONS.md that the work touches.
2. Confirm the scope of the session with the user if it's ambiguous: which
   key(s), which roadmap item.
3. Implement, then validate (below).
4. Test what you can yourself (TESTING.md §3). Then give the user the physical
   steps (TESTING.md §4) for the exact keys you changed, and wait for their
   results.
5. Update the docs as the change requires:
   - ARCHITECTURE.md for a format, rule or decision;
   - FINDINGS.md for a new fact (next free number);
   - LIMITATIONS.md for anything left unmapped;
   - ROADMAP.md for items done or added.
6. Commit only when the user asks.

## Environment (user's machine, as of 2026-10-07)

- **Software:** Omarchy 4.0.4, Hyprland 0.56.2 with Lua config. The default
  layout is **scrolling**; dwindle must work too.
- **Hardware:** NuPhy Air75 V2 keyboard in Mac mode (⌘ = Super, next to the
  space bar), Logitech G305 mouse. Desktop PC: no trackpad, no lid.
- **Input:**
  - xkb layout `us`, `input:resolve_binds_by_sym` off;
  - fcitx5 running (`hl-virtual-keyboard-fcitx5`);
  - the user sometimes types Persian. Keys are sent by keycode, but Persian
    testing is deferred until the user asks (D11).
- **Apps:**
  - foot (default terminal, bash) and Brave Origin (default browser, class
    `brave-origin`);
  - Chromium, VS Code (class `com.microsoft.VSCode`), Obsidian, Nautilus,
    LibreOffice, Ghostty, kitty, Firefox;
  - Google Chrome must be supported too, but may need installing for testing.
  - `wtype` (⌘-scroll) and `voxtype` (F5 dictation) are installed.
- **Lua:** Hyprland embeds Lua 5.5, and system `lua` (used by the help-menu
  replay and the snapshot) is 5.5.1. `luac5.5 -p file.lua` checks syntax.
- **OMacKey is installed live:** `~/.config/hypr/omackey` →
  `~/Work/OMacKey/omackey`. Edits in the repo apply on the next reload.
- **Not installed:** `wev`. Use `scripts/keylog.py` instead.

## Hard rules

- **Never edit** anything under `/usr/share/omarchy/` or `/usr/share/hypr/`.
  Reading them is encouraged; they're the real reference for the defaults and
  the API.
- **The user's `~/.config/hypr`** is touched only by `install.sh` /
  `uninstall.sh`: marker-delimited loader blocks in `hyprland.lua` plus the
  `~/.config/hypr/omackey` symlink.
  - Ask before editing any other user config: `input.lua`, `bindings.lua`,
    terminal configs, VS Code or Firefox settings, the OMacKey settings file.
  - Load the `omarchy` skill before touching anything in `~/.config/hypr`.
- **Before binding a key**, follow ARCHITECTURE.md §11:
  - check what is bound live (`omarchy menu keybindings --print`,
    `hyprctl binds`) and `relocations.lua`;
  - if the key displaces an Omarchy bind, that bind needs a new key or a
    LIMITATIONS.md row. Never silently drop one;
  - for a key whose Linux counterpart is doubtful, ask whether to map it at
    all.
- **Every bind needs a `description`.** Without one it's invisible in the help
  menu and the docs.
- **Keep it simple.** No daemons, no external remappers, no blocking calls. If
  a Mac behaviour needs more than a small Lua function, document it in
  LIMITATIONS.md instead.
- **Decisions D1–D13 and RD1–RD6 are confirmed.** Raise concerns with the user
  rather than quietly deviating.

## Validate after every change

```bash
scripts/lint.sh                        # syntax, unknown globals, no print at load
scripts/check.sh                       # reload, configerrors, omackey.status(), duplicate binds
scripts/check.sh "line start"          # … plus a help-menu (omarchy menu keybindings) search
scripts/snapshot.sh                    # behaviour snapshot vs tests/snapshot/expected
hyprctl binds | grep -B8 -A4 'description: Line start'   # flags: e=repeat a=auto_consuming d=desc
```

- `check.sh` must print three ✓ lines. It reloads Hyprland, because files
  behind the symlink may not trigger the auto-reload.
- `snapshot.sh` must print its ✓ line. It presses every bind in every test app
  under a fake Hyprland and compares what happens with
  `tests/snapshot/expected/`.
- A deliberate behaviour change is reviewed in its diff and approved by the
  user, then recorded with `scripts/snapshot.sh --update`.
- `tests/snapshot/selftest.sh` checks the harness itself.
- `omackey.status()` reports load and validation errors and
  `unused_relocations` (Omarchy keys in `relocations.lua` that no longer
  exist).
- For risky changes to the loader or relocation, do the scratch-HOME dry run
  first (TESTING.md §2).

## Testing without pressing keys

- `hyprctl repl '<lua>'` runs Lua in the live config state:
  - `omackey.status()`;
  - `omackey.trigger("<id>")` runs a binding's handler as if pressed;
  - `omackey.fired("<id>")` counts real presses since the last reload;
  - `omackey.explain("<id>")` prints the key's actions per app.
- **Handler tests** run in a private keylog copy (TESTING.md §3).
- **Check focus in the same command, right before injecting.** Focus jumps
  back to VS Code between tool calls, and stray keys would land in the user's
  editor.
- Close test windows by pid (`kill <pid>`), never with `pkill -f keylog.py`:
  that matches and kills your own shell. Work only on throwaway windows you
  launched.
- **`wtype` input never triggers Hyprland binds**, and it uses its own keymap,
  so it can't replace physical tests.

## How it works — the essentials

ARCHITECTURE.md §5–§10 has the full picture. What every change must respect:

- **Declare, build, bind.**
  - `shortcuts.lua` (`mac{}` inside `group("<Section>", { … })`) and
    `apps/*.lua` (`app{}`) only declare.
  - `bind.build()` validates everything, expands the catch-all and overlays
    the apps.
  - `bind.apply()` binds in one loop.
  - Nothing is bound before the whole set is known.
- **One explicit `mac{}` block per key**, in the group whose Mac meaning fits;
  no loops. Generic behaviour only:
  - `actions = { default = … }` when apps may differ;
  - `action = …` when it is the same everywhere (a dispatcher is bound
    natively).
- **App knowledge lives in `apps/<name>.lua`**: match rules, `family`, an
  optional `catchall`, and `actions` keyed by key id.
  - The match order is `APPS` in `init.lua`; the chain is app → family →
    `default`.
  - The app is resolved at press time.
  - Use Omarchy's tags where they exist (`terminal`,
    `chromium-based-browser`, `firefox-based-browser`).
- **Every action carries a text.** `send.tap` / `send.seq` make their own;
  wrap anything else with `does("…", fn_or_dispatcher)`. `PASS` / `CONSUME`
  come from `lib/bind.lua`. To pass the raw key from a function, return
  `{ ok = false }`.
- **Canonical key strings** (`keys.canonical()`):
  - modifiers `SUPER + CTRL + ALT + SHIFT`;
  - letters and named keys upper-case;
  - punctuation by lower-case xkb name (`comma`, `bracketleft`);
  - digits by keycode (`code:10`);
  - Omarchy's punctuation keycodes kept in relocation targets.

  `build()` reports any other spelling. The glyph is derived; write
  `mac = "…"` only for mouse buttons and XF86 keys.
- **Moving an Omarchy bind:** a row in `relocations.lua`:
  - `from` exactly as Omarchy writes it;
  - `to` (canonical) or `drop = true`;
  - `optional = true` for a conditional Omarchy bind.

  Don't `hl.unbind` and redeclare.
- **Conditions:** `enabled`, `setting = "<option>"` or
  `requires = "<command>"`. User options live in `omackey/settings.lua`;
  options are for opt-in extras and tuning only. Users opt out of a default
  with `hl.unbind` in their own `bindings.lua` (D12).
- **Sending keys:**
  - only through `lib/send.lua`: `send_key_state` down, then a timer sends up;
  - never `hl.dsp.send_shortcut` (stuck or repeating keys);
  - keep timer handles referenced: a garbage-collected timer never fires, and
    the key repeats forever;
  - send by keycode;
  - explicit `mods` replace the held modifiers, NumLock included (F22).
- **No stdout at load**, and modules must load under Omarchy's help-menu
  replay, where only `hl.bind`, `hl.dsp` and `hl.get_config` are real.
- **Bind callbacks never block:**
  - no `io.popen`, `os.execute`, sleeps or clipboard tools;
  - use `hl.dsp.exec_cmd` for external commands, with no `'` inside
    shell-quoted text.
- **Stateful features** go in a `lib/` module with one state table, never in
  loose closures.
- **Binding gotchas:**
  - `hl.unbind` matches the exact string, case-sensitive, and removes every
    earlier bind of that key;
  - several binds on one key all fire, top to bottom, so run the duplicate
    check;
  - compare chords with `keys.normalize()`.
- **Lua 5.5:**
  - for-loop variables are read-only;
  - patterns are not regex: no `|`, and `.`, `-`, `%` are special;
  - `bootstrap.lua` has no `?/init.lua` path, so require full names
    (`"hypr.omackey.lib.send"`);
  - every reload starts a fresh Lua state.
- **Scrolling layout:** layout operations go through
  `hl.dsp.layout("focus l")` etc. With a fullscreen window focused,
  `hl.dsp.focus({direction})` jumps monitors instead.

## Notation

- ⌘ = `SUPER`, ⌥ = `ALT`, ⌃ = `CTRL`, ⇧ = `SHIFT`.
- Mac glyphs are written in Apple's order (`⇧⌘[`) in docs and descriptions;
  Hyprland strings appear in code, e.g. `"SUPER + CTRL + LEFT"`.
- Modifier roles (D1, ARCHITECTURE.md §2):
  - ⌘ = app shortcuts and text navigation;
  - ⌥ = word navigation;
  - ⌃ = passthrough, except ⌃ + arrows (focus), ⌃⇧ + arrows (swap window),
    ⌃1–0 / ⌃⇧1–0 (workspace N), and the Emacs keys;
  - ⌃⌥ = window management, and ⌃⌥ + arrows switch workspace;
  - ⌃⌘ = Omarchy utilities;
  - ⌃⌥⌘ = launchers.

## Recovery

TESTING.md §6. In short:

- **Stuck key:** press and release it, then `hyprctl reload`.
- **Switch OMacKey off:** ⌃⇧⌘M or `scripts/omackey-mode off`.
- **Remove it:** `./uninstall.sh`.
- **Stuck in a submap:** `hyprctl dispatch 'hl.dsp.submap("reset")'`.
- Ask before `omarchy refresh hyprland`, then re-run `install.sh`.

## Reference shortcuts

- **Omarchy defaults:** `/usr/share/omarchy/default/hypr/bindings/*.lua`.
  Helpers: `default/hypr/helpers.lua`. App tags: `default/hypr/apps/*.lua`.
- **Hyprland API:** `/usr/share/hypr/stubs/hl.meta.lua`.
- **Hyprland wiki:** WebFetch truncates the rendered pages, so fetch raw
  markdown (paths in ARCHITECTURE.md §12).
- **Reddit** is unreachable for agents; the relevant snippet is summarized in
  FINDINGS.md F0.
