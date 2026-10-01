# CLAUDE.md — OMacKey

OMacKey adds macOS-style keyboard shortcuts to Omarchy (Arch + Hyprland, Lua
config). It is plain Hyprland Lua, layered on top of Omarchy's default
bindings and installed into `~/.config/hypr`. It's for people who switch
daily between a work Mac and an Omarchy machine.

**`PLAN.md` is the source of truth.** It holds the decisions (D1–D12), the
architecture, the per-phase key tables, the Omarchy relocation table (§6), the
unmapped list (§7), the test protocol (§8), findings (§9), references (§10)
and the session log (§11). Read the relevant parts before changing anything.

## Session workflow

The user works in small sessions: one key first, then one group of related
keys. Don't run ahead into later phases.

1. Read PLAN.md: the Status board, the last Session log entry, §9 Findings,
   and the phase you are working on.
2. Confirm the scope of the session with the user if it's ambiguous: which
   key(s), which phase item.
3. Implement, then validate the config (below).
4. Test what you can yourself (see "Testing without pressing keys"). Then give
   the user the §8.2 steps for the exact keys you changed and wait for their
   results. Only physical presses prove that a bind fires and that held
   modifiers don't leak.
5. Update PLAN.md:
   - tick the items;
   - add facts to §9;
   - add anything unmappable to §7;
   - adjust §6 if a relocation changed;
   - append a §11 entry (date, what changed, test results, next step).
6. Commit only when the user asks.

## Environment (user's machine, as of 2026-10-01)

- **Software:** Omarchy 4.0.4, Hyprland 0.56.2 with Lua config. The default
  layout is **scrolling**; dwindle must work too.
- **Hardware:** NuPhy Air75 V2 keyboard in Mac mode (⌘ = Super, next to the
  space bar), Logitech G305 mouse. Desktop PC: no trackpad, no lid.
- **Input:** xkb layout `us`, fcitx5 running (`hl-virtual-keyboard-fcitx5`).
  The user sometimes types Persian. Keys are still sent by keycode, but
  Persian testing is deferred until the user asks (D11).
- **Apps:**
  - foot (default terminal, bash) and Brave Origin (default browser, class
    `brave-origin`);
  - Chromium, VS Code (class `code`), Obsidian, Nautilus, LibreOffice;
  - Ghostty and Google Chrome must be supported too, but may need installing
    for testing.
- **Lua:** Hyprland embeds Lua 5.5, and system `lua` (used by the help-menu
  replay) is 5.5.1. `luac5.5 -p file.lua` checks syntax.
- **OMacKey is installed live:** `~/.config/hypr/omackey` →
  `~/Work/OMacKey/omackey`. Edits in the repo apply on the next reload.
- **Not installed:** `wev`. Use `scripts/keylog.py` instead.

## Hard rules

- **Never edit** anything under `/usr/share/omarchy/` or `/usr/share/hypr/`.
  Reading them is encouraged; they're the real reference for the defaults and
  the API.
- **The user's `~/.config/hypr`** is touched only by `install.sh` /
  `uninstall.sh`: marker-delimited lines in `hyprland.lua` plus the
  `~/.config/hypr/omackey` symlink.
  - Ask before editing any other user config: `input.lua`, `bindings.lua`,
    terminal configs, VS Code or Firefox settings.
  - Load the `omarchy` skill before touching anything in `~/.config/hypr`.
- **Before binding a key:**
  - Check what is bound live: `omarchy menu keybindings --print` and
    `hyprctl binds`.
  - Check PLAN §6.
  - If the key displaces an Omarchy bind, that bind needs a new home in §6, or
    an entry in §7. Never silently drop one.
- **Every bind needs a `description`.** Without one it's invisible in the help
  menu, and the doc generator skips it.
- **Keep it simple.** No daemons, no external remappers, no blocking calls. If
  a Mac behaviour needs more than a small Lua function, document it in §7
  instead.
- **Decisions D1–D12 are confirmed.** Raise concerns with the user rather than
  quietly deviating.

## Validate after every change

```bash
for f in $(find omackey -name '*.lua'); do luac5.5 -p "$f"; done  # syntax first
scripts/check.sh                       # reload, configerrors, omackey.status(), duplicate binds
scripts/check.sh "line start"          # … plus a help-menu (omarchy menu keybindings) search
hyprctl binds | grep -B8 -A4 'description: Line start'   # flags: e=repeat a=auto_consuming d=desc
```

`check.sh` must print three ✓ lines. `omackey.status()` reports load errors
and `unused_relocations`: Omarchy keys in `relocations.lua` that no longer
exist. Files behind the symlink may not trigger Hyprland's auto-reload, and
`check.sh` reloads.

For risky changes to the loader or relocation, dry-run first in a scratch HOME:
copy `~/.config/hypr`, run `HOME=<scratch> ./install.sh --no-reload`, then
replay the config the way the help menu does. Extract the Lua heredoc from
`$(which omarchy-menu-keybindings)` and run it with `HOME=<scratch> lua5.5`.

## Testing without pressing keys

- `hyprctl repl '<lua>'` runs Lua in the live config state and prints the
  results. Helpers:
  - `omackey.status()`
  - `omackey.trigger("<id>")` runs a binding's handler as if pressed
  - `omackey.fired("<id>")` counts real presses since the last reload
  - `require("hypr.omackey.lib.bind").by_id`
- **Handler test:**
  1. Start `scripts/keylog.py --log <scratchpad>/keylog.txt` in the
     background.
  2. Focus it: `hyprctl dispatch 'hl.dsp.focus({ window = "class:omackey.keylog" })'`.
  3. Run `omackey.trigger`, then read the log. It shows the keysym, keycode,
     modifiers and cursor position the app saw.
  4. Close it with `kill <pid>`. Not `pkill -f keylog.py`: that matches and
     kills your own shell.
- **Check focus in the same command, right before injecting.** Focus jumps
  back to VS Code between tool calls, and stray keys would land in the user's
  editor.
- **`wtype` input never triggers Hyprland binds**, and it uses its own keymap,
  so it can't replace physical tests.

## How it works — read before writing binds

- **Load order** (after install):
  1. Omarchy `bootstrap.lua`
  2. `load.pre()`: `lib/relocate.lua` wraps `hl.bind`
  3. `default.hypr.omarchy` (Omarchy defaults, registered on relocated keys)
  4. `load.init()`: unwrap `hl.bind`, then `init.lua` loads `config.modules`
     (the Mac binds)
  5. the user's `hypr.*` files, so the user's `bindings.lua` overrides still
     win.
- **Errors.** Both loader stages are `pcall`-guarded. An error becomes a
  Hyprland notification plus an entry in `omackey.status()`; it does not show
  up in `hyprctl configerrors`.
- **No stdout at load.** Omarchy's help menu replays this config and parses
  stdout, so never `print` from OMacKey at load time.
- **Module paths:** `bootstrap.lua` adds `~/.config/?.lua`, with no `?/init.lua`
  entry, so require full names like `"hypr.omackey.lib.send"`. Every reload
  starts a fresh Lua state.
- **Moving an Omarchy bind:** add a row to `omackey/relocations.lua`, with
  `from` exactly as written in Omarchy's file (matching ignores modifier order
  and case). Don't `hl.unbind` and redeclare it. Add `optional = true` when
  Omarchy only registers that bind under a condition, such as
  `if o.preinstalled_bindings_enabled()` or `o.cmd_present(...)`.
- **Omarchy helpers aren't limiting.** `o.bind(keys, desc, dispatcher, opts)`
  is a thin wrapper over `hl.bind(keys, dispatcher, opts)` that sets
  `opts.description`.
  - Every `hl.bind` flag passes through.
  - Strings become `exec_cmd`; `{ launch = … }` / `{ webapp = … }` tables
    become Omarchy launcher commands.
  - Use OMacKey's helpers in `lib/bind.lua`. Both handle descriptions and the
    docs registry:
    - `mac{}` for keys whose behaviour depends on the app (synthetic chords,
      per-profile actions);
    - `action{}` for plain Hyprland actions that are the same everywhere
      (workspaces, windows).
  - Users opt out of a default with `hl.unbind` in their own `bindings.lua`.
    Don't add config flags for that; flags are for opt-in extras only (D12).
- **Sending keys:**
  - Only through `lib/send.lua`: `send_key_state` down, then a timer sends up.
  - Never use `hl.dsp.send_shortcut` (Hyprland #14099: stuck or repeating
    keys).
  - **Keep timer handles referenced.** A garbage-collected timer never fires,
    and the key repeats forever.
  - Explicit `mods` replace the physically held SUPER/ALT for the synthetic
    event.
  - Send by keycode (`lib/keys.lua`, XKB code = evdev + 8) so Persian layouts
    don't break the chord.
- **Per-app behaviour:**
  - One bind per key. Inside the function, resolve the active window's profile
    (`lib/apps.lua`) **at press time**. Conditions evaluated at load time are
    frozen until the next reload.
  - Use Omarchy's tags where they exist (`terminal`, `chromium-based-browser`,
    `firefox-based-browser`). Dynamic tags have a trailing `*`.
  - To pass the raw key to the app: bind with `auto_consuming = true` and
    `return { ok = false }`.
- **Binding gotchas:**
  - `hl.unbind("…")` must match the original string exactly (case-sensitive)
    and removes *all* earlier binds of that key.
  - Omarchy writes modifiers in inconsistent order (`SUPER + SHIFT + ALT` vs
    `SUPER + ALT + SHIFT`), so normalize before comparing.
  - Several binds on the same key all fire, top to bottom, so always run the
    duplicate check.
  - Keysym names are lowercase xkbcommon names for punctuation: `comma`,
    `period`, `slash`, `bracketleft`, `minus`, `equal`, `grave`. Omarchy
    binds digits by keycode (`code:10` = 1 … `code:19` = 0).
- **Help menu (`omarchy-menu-keybindings`):**
  - It reads live `hyprctl binds`.
  - It also replays `hyprland.lua` under system `lua` 5.5 with a fake `hl`.
    Only `bind`, `dsp` and `get_config` are real there; everything else is a
    callable no-op.
  - So OMacKey modules must load cleanly under that mock: no top-level
    side effects that depend on the real runtime.
- **Lua constraints:**
  - Lua patterns are **not regex**: no `|`, and `.`, `-`, `%` are special.
  - Keep code 5.4/5.5-compatible. In 5.5, for-loop variables are read-only.
  - Bind callbacks run on the compositor's event loop. **No `io.popen`,
    `os.execute`, sleeps or clipboard tools inside them**, or the desktop
    freezes. Use `hl.dsp.exec_cmd` for external commands.
- **Scrolling layout:** layout ops go through `hl.dsp.layout("focus l")`,
  `"colresize +conf"`, `"swapcol r"` and so on. With a fullscreen window
  focused, `hl.dsp.focus({direction})` jumps monitors instead. See §9.

## Notation

- ⌘ = `SUPER`, ⌥ = `ALT`, ⌃ = `CTRL`, ⇧ = `SHIFT`.
- Mac glyphs are used in tables and descriptions; Hyprland strings in code,
  e.g. `"CTRL + ALT + LEFT"`.
- Modifier roles (D1):
  - ⌘ = app shortcuts and text navigation;
  - ⌥ = word navigation;
  - ⌃ = passthrough, except ⌃ + arrows (focus), ⌃⇧ + arrows (swap window)
    and ⌃1–0 / ⌃⇧1–0 (workspace N);
  - ⌃⌥ = window management; ⌃⌥ + arrows switch workspace, ⌃⌥⇧ + arrows take
    the window along (arrow rule, PLAN §6.2);
  - ⌃⌘ = Omarchy utilities;
  - ⌃⌥⌘ = launchers.

## Recovery

- **Stuck or repeating key:** press and release that key, then
  `hyprctl reload`.
- **Bad config:** `hyprctl configerrors`. A Lua error in a required module
  stops the rest of `hyprland.lua` from loading, including the user's
  bindings.
- **Disable OMacKey:** `./uninstall.sh`, or remove the marker lines from
  `~/.config/hypr/hyprland.lua` and run `hyprctl reload`. Fall back to a TTY
  (Ctrl+Alt+F3) if needed.
- **Stuck in a submap:** `hyprctl dispatch 'hl.dsp.submap("reset")'`.
- **`omarchy refresh hyprland`:** it resets the user's Hyprland config with a
  backup. Ask the user first. It removes OMacKey's lines, so re-run
  `install.sh` afterwards.

## Reference shortcuts

- **Omarchy defaults:** `/usr/share/omarchy/default/hypr/bindings/*.lua`.
  Helpers: `default/hypr/helpers.lua`. App tags: `default/hypr/apps/*.lua`.
- **Hyprland API:** `/usr/share/hypr/stubs/hl.meta.lua`.
- **Hyprland wiki:** WebFetch truncates the rendered pages, so fetch raw
  markdown from
  `https://raw.githubusercontent.com/hyprwm/hyprland-wiki/main/content/configuring/…`
  (paths in PLAN §10).
- **Reddit** is unreachable for agents; the relevant snippet is summarized in
  PLAN §9 F0.
