# OMacKey — Architecture

How OMacKey is built and why: its goal, the decisions behind it, how the code
is laid out and loaded, and how to add a key, an app or a relocation.

Related documents:

- [TESTING.md](TESTING.md): the snapshot harness, handler tests, physical tests
  and recovery.
- [FINDINGS.md](FINDINGS.md): facts learned about Hyprland, Omarchy and the
  apps (F0–F26).
- [LIMITATIONS.md](LIMITATIONS.md): what is not mapped, and why.
- [ROADMAP.md](ROADMAP.md): what is left to build.

Notation:

- ⌘ = `SUPER`, ⌥ = `ALT`, ⌃ = `CTRL`, ⇧ = `SHIFT`, ⌫ = BackSpace,
  ⌦ = Delete, ⏎ = Return.
- Mac glyphs are written in Apple's order (⌃⌥⇧⌘, so `⇧⌘[`).
- Hyprland key strings are written as in the Lua config:
  `"SUPER + SHIFT + LEFT"`.

Contents:

1. Goal
2. Modifier model and the arrow rule
3. Decisions
4. Repository layout
5. Loading
6. Shortcuts, apps and actions
7. Relocations
8. Settings and the Mac-mode toggle
9. Introspection and the catalog
10. Invariants
11. How to add things
12. References
13. History

---

## 1. Goal

Make Omarchy respond to the macOS shortcuts people use every day, so moving
between a work Mac and an Omarchy machine needs no mental remapping.

- It is implemented only in Hyprland's Lua config. It is layered on top of
  Omarchy's defaults and installed into `~/.config/hypr`.
- The shortcut-help menu (Omarchy's `SUPER + K`, moved to ⌘?) keeps showing
  the live bindings.
- Every Omarchy binding that has to move gets a new key. Anything that can't
  move is listed in LIMITATIONS.md.

**Non-goals**

- 100% macOS fidelity. The target is the common shortcuts in common apps.
- External remappers or daemons (keyd, xremap, kinto). If a Mac behaviour
  needs more than a small Lua function, it is documented as a limitation
  instead.
- Mac Option-key special characters (Omarchy's Compose key covers them) and
  Mac Home/End semantics.
- Any change under `/usr/share/omarchy` or `/usr/share/hypr`.

## 2. Modifier model and the arrow rule

| Mac key | Linux mod | Role in OMacKey |
| --- | --- | --- |
| ⌘ | `SUPER` | App shortcuts, translated to Ctrl (Ctrl+Shift or Insert variants in terminals). Text navigation (⌘ arrows, ⌘⌫). A few Mac system shortcuts: ⌘Space, ⌘Tab, ⌘\`, ⌘Q, ⇧⌘3/4/5, ⌘? |
| ⌥ | `ALT` | Word navigation and deletion (⌥←/→, ⌥⇧←/→, ⌥⌫, ⌥⌦). Everything else passes through, so Meta keeps working in bash, tmux and nvim. No Mac special characters |
| ⌃ | `CTRL` | Passes through to apps (⌃C in terminals, ⌃Tab, ⌃G in VS Code), except ⌃ + arrows (focus window), ⌃⇧ + arrows (swap window), ⌃1–0 / ⌃⇧1–0 (go to / move to workspace N, as macOS ⌃1–9), and the opt-in Emacs keys (`emacs_keys`, on by default) |
| ⌃⌥ | `CTRL + ALT` | Window management, Rectangle/Magnet style: resize, float, fullscreen variants, groups, scratchpad, layout toggle, close; ⌃⌥-drag moves and ⌃⌥-right-drag resizes a window. One level up from ⌃: ⌃⌥ + arrows switch workspace, ⌃⌥⇧ + arrows take the window along |
| ⌃⌘ | `SUPER + CTRL` | Omarchy system utilities, panels and toggles (mostly unchanged), plus the Mac ⌃⌘ shortcuts: ⌃⌘F full screen, ⌃⌘Q lock, ⌃⌘Space emoji |
| ⌃⌥⌘ | `SUPER + CTRL + ALT` | App launchers, keeping Omarchy's letters (B browser, F files, N editor …); ⌃⌥⇧⌘ holds the variants that were `SUPER + SHIFT + ALT` |
| ⌃⇧⌘ | `SUPER + CTRL + SHIFT` | Omarchy's info popups that collided with launcher letters (battery, weather, calendar, time), Omarchy's own ⌃⇧⌘ binds (theme menu, agent, reminders), and the Mac-mode toggle ⌃⇧⌘M |

**The arrow rule** (user's decision, 2026-10-02):

- ⌃ + arrows move focus between windows, and ⌃⇧ + arrows take the window along
  within the workspace. Focus is the most frequent tiling action, so it gets
  one modifier. In the scrolling layout ⌃→ slides to the next column, which
  looks like a Mac Space switch.
- ⌥ steps up a level: ⌃⌥ + arrows switch to the previous / next workspace
  (←/↑ previous, →/↓ next), and ⌃⌥⇧ + arrows take the window there.
- Numbers only mean workspaces, so they stay on ⌃ as on macOS: ⌃1–0 go to
  workspace N, ⌃⇧1–0 move the window there, ⌃⌥⇧1–0 move it silently.
- Deviation from macOS: ⌃←/→ switch windows, not Spaces, and Mission Control
  / App Exposé (⌃↑ / ⌃↓) are not mapped.

## 3. Decisions

Confirmed with the user. Don't change them without asking.

**D1 — Modifier model.** As in §2.

**D2 — Keyboard.** SUPER is ⌘ logically. The user's NuPhy Air75 V2 in Mac mode
puts ⌘ (Super) next to the space bar. A PC-keyboard Alt/Super swap was
considered and skipped (the user does not need it).

**D3 — Curated first, catch-all after.** Named shortcuts are mapped one by
one, each with a readable description in the help menu. A catch-all then sends
any ⌘ / ⇧⌘ + key that nothing claimed as Ctrl / Ctrl+Shift + the same key.

**D4 — Synthetic keys are sent by physical keycode.** Every key goes out as
`code:N` from `lib/keys.lua`, so it still works while a non-Latin layout
(Persian) is active. Binds are written in the canonical form (§6), which uses
key names except for digits and the punctuation keys Omarchy binds by keycode.

**D5 — Terminals.** They are detected by Omarchy's `terminal` window tag.
⌘C / ⌘V send Ctrl+Insert / Shift+Insert, as Omarchy does. ⌘Z and ⌘X are never
sent as Ctrl+Z (SIGTSTP) or Ctrl+X. Any ⌘ chord without a terminal action is
consumed, as on macOS, where ⌘ never reaches the shell.

**D6 — One global bind per key.** At press time the bind works out the active
window's app and runs that app's action. An action can return `{ ok = false }`
and, with `auto_consuming = true`, the raw key then passes through. Nothing is
bound or unbound on focus changes.

**D7 — Help menu.** Every OMacKey bind and every relocated Omarchy bind has a
`description`, so the help menu lists the live mapping. The help menu itself
moved from `SUPER + K` to ⌘? (`SUPER + SHIFT + slash`), because apps need ⌘K.

**D8 — Install.** `install.sh` symlinks the repo's `omackey/` to
`~/.config/hypr/omackey` and adds two marker-delimited loader lines to
`~/.config/hypr/hyprland.lua`; `uninstall.sh` removes both. OMacKey loads after
Omarchy's defaults and before the user's `hypr.bindings`, so the user's own
overrides still win.

**D9 — Only colliding binds move.** An Omarchy bind moves only if it collides
with a Mac shortcut, or with a key another relocation needs. The rest stay
where they are, which keeps Omarchy muscle memory and the diff small.

**D10 — App scope.**

- Terminals: foot, Ghostty and kitty get their own entries; Alacritty,
  wezterm and Omarchy's TUI windows get the generic terminal rules.
- Browsers: Brave, Brave Origin, Chromium and Google Chrome; Firefox
  best-effort.
- VS Code, Nautilus, Obsidian and LibreOffice.

**D11 — Persian (deferred by the user).** Keys are sent by keycode (D4) so
non-Latin layouts are likely to work, but Persian is not tested until the user
asks (ROADMAP.md).

**D12 — Customization.**

- A user opts *out* of an OMacKey default by unbinding it in
  `~/.config/hypr/bindings.lua`, which loads after OMacKey:
  `hl.unbind("SUPER + CTRL + UP")`. The key then reaches apps again.
- Options are only for opt-*in* extras or tuning (`settings.lua`, §8). There
  are no options for removing defaults.
- So the docs must show the exact key string of every bind: `hl.unbind`
  matches the original string exactly, including case. The canonical form
  (§6) makes that string predictable.

**D13 — No minimize or hide.** ⌘M, ⌘H, ⌥⌘H (hide others) and ⌥⌘M (minimize
all) are not mapped; the catch-all consumes ⌘M and ⌘H.

- Neither Omarchy nor Hyprland has minimize or hide (FINDINGS.md F7).
- There is no dock or taskbar to bring a hidden window back, so it is easy to
  lose, and tiling layouts re-flow around it.
- Omarchy's scratchpad is the native equivalent: ⌃⌥⇧S moves a window there and
  ⌃⌥S shows it.

**RD1 — Apps are overlays.** The shortcut file declares each Mac shortcut once,
with its behaviour in a generic app (`default`). Everything app-specific
(match rules, families, per-app actions) lives in one file per app under
`apps/`. xremap, keyd's application mapper and Toshy/Kinto layer per-app rules
over global ones the same way. Hyprland still sees one bind per key (D6).

**RD2 — OMacKey keeps its own ⌘C / ⌘V / ⌘X.** Omarchy's universal copy / paste
send Ctrl+C / Ctrl+V to VS Code, which breaks its integrated terminal (F12),
and its universal cut sends Ctrl+X to terminals. All three Omarchy binds are
dropped (`drop = true` in `relocations.lua`).

**RD3 — Optional user settings file.** Defaults live in the repo
(`omackey/settings.lua`). A user file overrides them only if it exists;
nothing creates it.

**RD4 — Documentation.** This file plus TESTING, FINDINGS, LIMITATIONS and
ROADMAP. Per-key tables are generated from the code (`docs/KEYBINDINGS.md`, by
`scripts/gen-docs.lua`), not written by hand.

**RD5 — Specific apps override their family.** An app's entry wins over its
family's, which wins over `default`: Firefox over the generic browser entry,
Ghostty / kitty / foot over the generic terminal entry.

**RD6 — One written form for keys, derived glyphs.** Every OMacKey key string
and relocation target is written in the canonical form (§6), and the Mac glyph
is derived from it.

## 4. Repository layout

```text
OMacKey/
├── CLAUDE.md              guide for coding agents (AGENTS.md is a symlink to it)
├── README.md              user-facing introduction
├── install.sh             symlink + marker-delimited loader lines in ~/.config/hypr/hyprland.lua, then scripts/check.sh
├── uninstall.sh           removes both (backs up hyprland.lua first)
├── .luarc.json            LuaLS: Lua 5.5, Hyprland stubs, globals hl, o, omackey
├── docs/                  this file, TESTING, FINDINGS, LIMITATIONS, ROADMAP, and the generated KEYBINDINGS.md
├── omackey/               → symlinked to ~/.config/hypr/omackey (Lua module prefix hypr.omackey)
│   ├── load.lua           entry points pre() / init() (install.sh writes these names into hyprland.lua)
│   ├── init.lua           the manifest: MODULES (shortcuts) and APPS (in match order); declares them
│   ├── settings.lua       user options: defaults, checks, docs; merged with the optional user file
│   ├── relocations.lua    every displaced Omarchy bind: moved (`to`) or dropped (`drop`)
│   ├── shortcuts.lua      every Mac shortcut, declared once, generic behaviour only, one group per Mac meaning
│   ├── apps/              one file per app or family: match rules, family, per-app actions by key id
│   │     ghostty kitty foot terminal firefox browser vscode libreoffice obsidian nautilus no-tabs
│   └── lib/
│       ├── keys.lua       the key table (name ↔ keycode ↔ glyph), normalize(), canonical(), glyph()
│       ├── action.lua     self-describing actions: does(), PASS, CONSUME
│       ├── send.lua       tap(), seq(), button(), after(): synthetic keys with retained timers
│       ├── bind.lua       mac{}, group(), catchall{}; build() validates and expands; apply() binds; registry
│       ├── profiles.lua   app{}; match index and chains, built once at load
│       ├── relocate.lua   the hl.bind hook: moved and dropped Omarchy binds, claimed keys
│       ├── windows.lua    window queries shared by ⌘Q, ⌘` and ⌘Tab
│       ├── switcher.lua   ⌘Tab app switching by recency
│       ├── click.lua      ⌘-click as Ctrl-click
│       ├── ctrl_hold.lua  ⌘-scroll as Ctrl-scroll (wtype)
│       ├── mode.lua       Mac mode on/off (state file) and its ⌃⇧⌘M toggle
│       ├── catalog.lua    the data model for docs and introspection
│       └── introspect.lua omackey.status / fired / trigger / explain
├── scripts/
│   ├── check.sh           reload, configerrors, omackey.status(), duplicate binds, help-menu search
│   ├── snapshot.sh        behaviour snapshot under a fake Hyprland (TESTING.md)
│   ├── lint.sh            syntax, unknown globals, print at load, shell syntax (luacheck / shellcheck if installed)
│   ├── drift.sh           what `omarchy update` changed in Omarchy's binds, and which sit on OMacKey keys
│   ├── gen-docs.lua       renders docs/KEYBINDINGS.md from lib/catalog.lua under the same fake Hyprland
│   ├── omackey-mode       on / off / toggle / status from a terminal
│   └── keylog.py          GTK4 key-event logger used as the test app
└── tests/snapshot/        the snapshot harness: mock, fixtures, scenarios, render, expected output
```

**Layering rules**

1. `lib/` holds mechanics and knows no keys or apps (`lib/mode.lua` declares
   its one toggle key).
2. `shortcuts.lua` declares every shortcut and says what it does in a generic
   GUI app (`default`), never in a specific one. A key that only means
   something in some apps has no `default`, so the raw key passes through
   elsewhere.
3. `apps/` owns app knowledge. An app file adds actions to existing keys by id.
   Each app file names where its shortcuts were read from (FINDINGS.md).
4. The catch-all covers only chords nobody claimed and never changes another
   key's actions.

## 5. Loading

`~/.config/hypr/hyprland.lua` after `install.sh`:

```lua
-- >>> OMacKey pre (managed by OMacKey install.sh)
do local ok, loader = pcall(require, "hypr.omackey.load"); if ok then loader.pre() end end
-- <<< OMacKey pre
require("default.hypr.omarchy")
-- >>> OMacKey (managed by OMacKey install.sh)
do local ok, loader = pcall(require, "hypr.omackey.load"); if ok then loader.init() end end
-- <<< OMacKey
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")   -- the user's own binds still win
```

Load order:

1. Omarchy's `bootstrap.lua`.
2. `load.pre()`: `lib/relocate.lua` wraps `hl.bind`.
3. `default.hypr.omarchy`: Omarchy's defaults register, already on their
   relocated keys (§7).
4. `load.init()`:
   1. unwrap `hl.bind`;
   2. **declare**: `init.lua` loads `shortcuts.lua` and the `apps/` files in
      manifest order, and `lib/mode.lua` declares the toggle. They only fill
      tables; nothing reaches Hyprland;
   3. **build** (`bind.build()`), on the complete set: validate every spec and
      app, decide what is enabled, expand the catch-all against every claimed
      chord, overlay the apps' actions, build the match index and chains;
   4. **bind** (`bind.apply()`): one loop calls `hl.bind` for every valid,
      enabled spec. Nothing changes the table afterwards;
   5. `switcher.start()` subscribes ⌘Tab's recency list to focus changes.
5. The user's `hypr.*` files.

With OMacKey off (§8), `pre()` does nothing and `init()` declares and binds
only the toggle.

**Guarding.**

- If the repo or symlink is missing, `pcall(require)` makes the loader lines
  a silent no-op.
- Each loader stage runs under `pcall`. An error becomes a Hyprland
  notification and an entry in `omackey.status()`; Omarchy's defaults and the
  user's files still load. These errors don't show in `hyprctl configerrors`.
- A module that fails to load, and a spec or app that fails validation, is
  reported the same way and skipped; the rest still loads.

**Module paths and reloads.**

- `bootstrap.lua` adds `~/.config/?.lua` to `package.path`, with no
  `?/init.lua` entry, so modules are required by full name
  (`"hypr.omackey.lib.send"`).
- Every reload starts a fresh Lua state: globals are gone and `hl` is a new
  table (F1).
- Edits behind the symlink may not trigger Hyprland's auto-reload, so run
  `scripts/check.sh` or `hyprctl reload`.

## 6. Shortcuts, apps and actions

**A key spec** (`shortcuts.lua`):

```lua
group("Find", {
  mac({
    id = "find-next",
    keys = "SUPER + G",
    desc = "Find next",
    repeating = true,
    actions = { default = tap("", "F3") },  -- apps/*.lua add their own by id
  }),
})

group("Windows and apps", {
  mac({
    id = "close-window",
    keys = "SUPER + SHIFT + W",
    desc = "Close window",
    action = does("Close the window", hl.dsp.window.close()),  -- same in every app
  }),
})
```

- `id` is stable: it is the test hook (`omackey.trigger`) and the docs anchor.
- `desc` is what the help menu shows. Avoid commas, because the help menu cuts
  the description there.
- The category is the `group()` the spec sits in. The file is recorded for
  the docs.
- `action` (the same in every app; apps can't override it) or `actions` (per
  app), never both. A dispatcher `action` is bound natively. A function is
  bound with `auto_consuming` and the press counter.
- Flags: `repeating`, `release`, `plain = true` (bind a function without
  `auto_consuming`, so its key is always consumed).
- Conditions: `enabled = <bool>`, `setting = "<option>"` (a boolean user
  option) or `requires = "<command>"` (on PATH). A spec with a condition is
  declared either way, so validation and the docs know it, but it is bound
  only when the condition holds. Conditions are evaluated at load.

**Canonical key strings** (`keys.canonical()` in `lib/keys.lua`):

- modifiers in the order `SUPER + CTRL + ALT + SHIFT`;
- letters and named keys upper-case, as Omarchy writes them (`A`, `RETURN`,
  `LEFT`, `F5`);
- punctuation by its lower-case xkb name (`comma`, `slash`, `bracketleft`):
  upper-case `COMMA` does not match;
- digits by keycode (`code:10` = 1 … `code:19` = 0), as Omarchy binds them;
- a punctuation key written as a keycode stays one. Omarchy binds − = [ ] by
  keycode, and a keycode stays on the same physical key in any first layout
  (F25);
- keys outside the table (`mouse:272`, `mouse_down`, `XF86VoiceCommand`) stay
  as written.

`build()` reports any other spelling. The Mac glyph is derived from the key
string (`keys.glyph()`, Apple's order: `⇧⌘[`). Only a key with no glyph spells
it out: `mac = "⌘-click"`, `mac = "F5 (release)"`.

`keys.normalize()` is for comparing chords however they are written: it
ignores modifier order and case, and treats a keycode and its key name as the
same key. With `input:resolve_binds_by_sym` off (the default here), a keysym
bind and its keycode bind are the same physical key on a US-first layout.

**Actions** (`lib/action.lua`). An action is:

- a function: it may return `{ ok = false }` to pass the raw key through;
- a Hyprland dispatcher;
- `PASS` (the raw key reaches the app) or `CONSUME` (nothing happens).

Every action carries a text saying what it does:

- `send.tap` / `send.seq` make their own ("Ctrl+Shift+F", "Ctrl+F, then
  Return, then Esc").
- Anything else is wrapped: `does("Close every window of the app",
  windows.quit_app)`.
- `PASS` and `CONSUME` have standard texts.

Hyprland's dispatchers are opaque, so a bare dispatcher has no text. `build()`
rejects an action without one.

**App overlays** (`apps/*.lua`, `lib/profiles.lua`):

```lua
app({
  name = "foot",
  family = "terminal",                         -- tried after foot's own entries
  classes = { "foot", "org.codeberg.dnkl.foot" },
  actions = {
    ["find"] = tap("CTRL + SHIFT", "R"),
  },
})
```

- Match rules: `classes` (exact window classes) and `tags` (Omarchy's window
  tags; dynamic tags carry a trailing `*`). Use Omarchy's tags where they
  exist: `terminal`, `chromium-based-browser`, `firefox-based-browser`. Brave
  Origin (`brave-origin`) is not covered by Omarchy's browser tag, so it is
  listed by class.
- Apps are matched in the order of `APPS` in `init.lua`: the first app whose
  classes or tags match the active window wins, so specific apps come before
  their family.
- A window's chain is its app, then the app's family, then `default`. The
  first with an action on the key decides; none means the raw key passes
  through.
- `catchall = <action>` applies to every key the catch-all generated
  (`apps/terminal.lua`: `CONSUME`, D5).
- The app is resolved at press time. Omarchy web apps (`chrome-…__-Default`)
  deliberately stay on `default`.
- `apps/no-tabs.lua` reads its classes from the `close_window_classes`
  setting: ⌘W closes the window there instead of sending Ctrl+W.

**The catch-all** (`catchall{}` at the end of `shortcuts.lua`):

- It covers ⌘ and ⇧⌘ + every letter, `` ` - = [ ] \ ; ' , . / `` and ⏎.
- Every covered chord that no spec and no Omarchy key claims becomes a spec
  sending Ctrl / Ctrl+Shift + the same key, by keycode. Its ids are
  `catchall-⌘E`, `catchall-⌘⇧P`, with descriptions such as "⌘E sent as
  Ctrl+E".
- Its `consumed` list (⌘H, ⌘M, ⇧⌘Q, ⇧⌘I, ⇧⌘U, ⇧⌘H) does nothing, with the
  description "not mapped".
- ⌘ digits are claimed by the tab keys; ⇧⌘ digits are not covered (⇧⌘3/4/5
  are screenshots).
- "Claimed" is known at build time from the registry and from
  `relocate.claimed`, every key Omarchy registered. `hl` has no call that
  lists binds at load (F14). A key the user rebinds in `bindings.lua` still
  wins, because that loads later.

**Validation** (`build()`). Each problem below is reported and the faulty item
is left out:

- a missing field, or a duplicate id;
- two OMacKey binds on the same chord and release flag;
- a chord Omarchy still holds;
- `action` and `actions` both given;
- a key string or relocation target that isn't canonical (a relocation is
  still applied);
- an invalid action, or an action without a text;
- in an app: an unknown key id or profile, an entry on an `action =` spec, the
  same key set twice, an app declared twice, an unknown family.

**Sending keys** (`lib/send.lua`):

- `send_key_state` sends the key down, and a timer sends it up after
  `release_ms`. `send.seq` spaces its chords `release_ms + 5` apart.
- Never `hl.dsp.send_shortcut`: it leaves keys stuck or repeating
  (Hyprland discussion #14099).
- Timer handles stay referenced in a table until they fire. A
  garbage-collected timer never fires, and the key then repeats forever.
- Keys go out by keycode (D4; XKB keycode = evdev + 8). Explicit `mods`
  replace the physically held modifiers, locked ones included, for that event
  (F22).
- No `window` is given, so layer-shell surfaces (Omarchy's menus) receive the
  keys too.
- `send.button` sends a pointer button the same way (`key = "mouse:272"`,
  F21).

## 7. Relocations

`omackey/relocations.lua` is the data, and `lib/relocate.lua` the mechanism.

```lua
{ from = "SUPER + W", to = "CTRL + ALT + W" },             -- moved
{ from = "SUPER + C", drop = true },                       -- replaced by OMacKey's ⌘C
{ from = "SUPER + SHIFT + M", to = "SUPER + CTRL + ALT + M", optional = true }, -- Music
```

- `load.pre()` wraps `hl.bind` before Omarchy's defaults load. Every Omarchy
  `o.bind` call is looked up by normalized key:
  - a `to` row registers Omarchy's own dispatcher, description, flags and
    conditions on the new key;
  - a `drop` row registers nothing;
  - every key Omarchy registers is recorded in `relocate.claimed`.
- `load.init()` restores the native `hl.bind`.
- `from` is Omarchy's key as written in its bindings files (matching ignores
  modifier order and case, and a keycode matches its name). `to` is canonical
  and keeps Omarchy's keycodes.
- `optional = true` marks a bind Omarchy registers only under a condition
  (`o.preinstalled_bindings_enabled()`, `o.cmd_present(…)`), so its absence is
  not reported.
- `omackey.status()` reports `unused_relocations`: rows whose Omarchy key was
  never registered, meaning Omarchy changed it.
- Omarchy's help-menu replay defines its own `hl.bind`, which is wrapped the
  same way, so the help menu shows the relocated keys too.
- Why not `hl.unbind` and redeclare: about 100 Omarchy actions would be
  duplicated and would drift silently when Omarchy changes them.

The relocated groups, in file order:

- dropped ⌘C / ⌘V / ⌘X (RD2);
- window management → ⌃⌥;
- focus and swap → ⌃ / ⌃⇧ arrows;
- workspaces → ⌃ digits and ⌃⌥ arrows;
- launchers → ⌃⌥⌘ + Omarchy's letter;
- info popups → ⌃⇧⌘;
- help → ⌘?;
- the Omarchy utilities that sat on Mac keys;
- mouse → ⌃⌥.

Omarchy's ±25 px resize (⌥⌘-/=), group keys, notification keys, PRINT, media
and power keys don't collide and stay (D9).

## 8. Settings and the Mac-mode toggle

**Settings** (`omackey/settings.lua`). Each option has a default, a check and
a doc string:

| Option | Default | Meaning |
| --- | --- | --- |
| `emacs_keys` | `true` | Emacs-style ⌃ keys in text fields (⌃A / ⌃E, ⌃F / ⌃B / ⌃N / ⌃P, ⌃D / ⌃H, ⌃K). Terminals keep the raw key, and so does ⌃D in VS Code |
| `release_ms` | `20` | how long a synthetic key stays down |
| `close_window_classes` | `{}` | GUI apps where ⌘W closes the window instead of sending Ctrl+W |

- `${XDG_CONFIG_HOME:-~/.config}/omackey/settings.lua`, if it exists, returns a
  table of options to change.
- It is loaded as data, with `loadfile` and an empty environment, so it can't
  call `hl`.
- An unknown option or a wrong type is reported in `omackey.status()` and
  ignored, and a file that fails to load leaves the defaults.
- Nothing creates or removes the file: neither `install.sh` nor
  `uninstall.sh`. Read options with `require("hypr.omackey.settings").<name>`.

**Mac mode** (`lib/mode.lua`):

- The switch is the state file `${XDG_STATE_HOME:-~/.local/state}/omackey/off`,
  read once per load.
- While it exists, `load.lua` skips the relocations and every shortcut, so
  Omarchy's defaults load as they ship. Only the toggle is declared and bound.
- The toggle ⌃⇧⌘M (`mac-mode`, bound in both modes) runs one external command:
  create or remove the file, `notify-send`, `hyprctl reload`. No file or
  process calls happen inside the callback.
- `scripts/omackey-mode on|off|toggle|status` does the same from a terminal.
- `omackey.status()` says "off …" and `scripts/check.sh` flags it, so a
  forgotten switch-off shows.

## 9. Introspection and the catalog

`lib/introspect.lua` installs these on the global `omackey`, for
`hyprctl repl`:

- `omackey.status()`: `bindings=N relocated=N`, plus `unused_relocations=` and
  `errors=` when there are any.
- `omackey.fired(id)`: real presses since the last reload. Native dispatcher
  binds are not counted (-1).
- `omackey.trigger(id)`: runs a bind's handler as if pressed.
- `omackey.explain(id)`: the key's default action and every app's action, as
  text.

`lib/catalog.lua` is the data model that the docs generator, `explain()` and
the snapshot's metadata read. It reads tables only, with no Hyprland calls, so
it loads under the snapshot mock and the help-menu replay.

- `catalog.keys()`: per key: id, exact key string, glyph, description,
  category, file, flags, condition, whether bound, default and per-app action
  texts.
- `catalog.apps()`: name, family, match rules, catch-all rule.
- `catalog.relocations()`: Omarchy key, new key or dropped, Omarchy's
  description, `optional`.
- `catalog.settings()`: name, default, doc.
- `catalog.find(id)`: one key.

## 10. Invariants

- **No stdout at load.** Omarchy's help menu replays `hyprland.lua` under
  system `lua` 5.5 and parses stdout, so never `print` from OMacKey at load
  time.
- **The help-menu replay.** In its mock `hl`, only `bind`, `dsp` and
  `get_config` are real; everything else is a callable no-op. OMacKey modules
  must load cleanly under it: no top-level side effects that need the real
  runtime.
- **Bind callbacks never block.** They run on the compositor's event loop: no
  `io.popen`, `os.execute`, sleeps or clipboard tools, or the desktop freezes.
  External commands go through `hl.dsp.exec_cmd`. Shell-quoted text passed to
  it must not contain `'` (F18).
- **Conditions are evaluated at press time** for per-app behaviour. Anything
  evaluated at load time is frozen until the next reload.
- **Every bind has a description**, or the help menu and the docs can't show
  it.
- **Several binds on one key all fire**, top to bottom, so run the
  duplicate check (`scripts/check.sh`).
- **`hl.unbind` matches the exact string** (case-sensitive) and removes every
  earlier bind of that key.
- **Lua 5.5** (Hyprland's embedded Lua and the system `lua`). For-loop
  variables are read-only. Patterns are not regex: no `|`, and `.`, `-`, `%`
  are special.
- **Scrolling layout.** Layout operations go through `hl.dsp.layout("focus
  l")`, `"colresize +conf"`, `"swapcol r"` and so on. With a fullscreen window
  focused, `hl.dsp.focus({direction})` jumps monitors instead (F0).

## 11. How to add things

**Before binding a key**

1. Check what is bound live: `omarchy menu keybindings --print` and
   `hyprctl binds`.
2. Check `relocations.lua`.
3. If the key displaces an Omarchy bind, that bind needs a new key (a `to`
   row) or an entry in LIMITATIONS.md. Never drop one silently.
4. Check the real Mac behaviour (Apple's shortcut page, the app's own Mac
   keymap) and the app's Linux keymap.
5. For a key whose Linux counterpart is doubtful, ask whether to map it at
   all.

**A Mac shortcut**

1. Add one `mac{}` block to the fitting `group()` in `shortcuts.lua`: a unique
   id, the canonical `keys`, a `desc`, and the generic action. One explicit
   block per key; no loops or shared helper closures.
2. Per-app behaviour goes into the app files (next item), not the spec.
3. Validate and test as in TESTING.md.

**A per-app action**

1. Add `["<id>"] = <action>` to the app's `actions` in `apps/<app>.lua`.
2. Wrap anything that is not a `tap` / `seq` in `does("…", …)`.
3. Name the source of the app's shortcut in a comment (FINDINGS.md).

**A new app**

1. Add `apps/<name>.lua` with one `app{}`: `name`, `classes` and / or `tags`,
   an optional `family`, `actions`.
2. Add it to `APPS` in `init.lua`, before its family and before any app whose
   rules would match its windows first.

**A relocation**

1. Add a row to `relocations.lua`: `from` as Omarchy writes it, and `to` in
   the canonical form or `drop = true`.
2. Add `optional = true` if Omarchy registers that bind under a condition.

**A setting**

1. Add an entry to `OPTIONS` in `settings.lua` with `name`, `default`,
   `check` and `doc`.
2. Settings are for opt-in extras and tuning only (D12).

**Stateful features** (⌘Tab, ⌘-click, ⌘-scroll) go in a `lib/` module with
one state table and an explicit start or entry point, never in loose closures
in `shortcuts.lua`.

## 12. References

| Reference | Use it for |
| --- | --- |
| `/usr/share/omarchy/default/hypr/bindings/*.lua` | Omarchy's defaults, the source of every relocation `from`. Helpers: `default/hypr/helpers.lua` (`o.*`); app tags: `default/hypr/apps/*.lua`; `bootstrap.lua`; the help menu: `$(which omarchy-menu-keybindings)` |
| Omarchy hotkeys manual: <https://omarchy.org/manual/hotkeys/> | human-readable defaults |
| `/usr/share/hypr/stubs/hl.meta.lua` | the Hyprland Lua API for the installed version: function, option and event names |
| Hyprland wiki, raw markdown: `https://raw.githubusercontent.com/hyprwm/hyprland-wiki/main/content/configuring/` + `core/binds/_index.md`, `core/binds/flags.md`, `core/binds/submaps.md`, `core/binds/keyboard-layouts.md`, `core/dispatchers.md`, `layouts/scrolling-layout.md`, `layouts/dwindle-layout.md`, `core/advanced-configuration/lua-utilities.md` | bind syntax and flags. WebFetch truncates the rendered wiki pages |
| <https://github.com/hyprwm/Hyprland/discussions/14099> | why keys are sent down and up by timer instead of `send_shortcut` |
| Apple keyboard shortcuts: <https://support.apple.com/en-au/102650> | the Mac behaviour being mimicked |
| Kinto: <https://github.com/rbreaves/kinto/blob/master/linux/kinto.py> | per-app tables (browsers, file managers, VS Code Alt hack, terminal conversions). Maximalist; borrow ideas only |
| xremap macOS config: <https://github.com/petrstepanov/gnome-macos-remap-wayland/blob/main/config.yml> | Nautilus mappings, terminal handling |
| Omarchy + keyd discussion: <https://github.com/omacom/omarchy/discussions/175> | the minimal "must work" set; terminal copy/paste pitfalls |
| r/omarchy "macOS like bindings": <https://www.reddit.com/r/omarchy/comments/1vyvd41/macos_like_bindings/> | keycodes, timer retention, Ctrl forwarding. Unreachable for agents; summarized in F0 |
| Omarchy's Compose key | Caps Lock (`compose:caps` in `/usr/share/omarchy/default/hypr/input.lua`); Omarchy's sequences in `/usr/share/omarchy/default/xcompose`, the user's in `~/.XCompose` (apply with `omarchy-restart-xcompose`), the system table in `/usr/share/X11/locale/en_US.UTF-8/Compose`. The manual mentions it once, under Troubleshooting: <https://learn.omacom.io/2/the-omarchy-manual/88/troubleshooting> |

## 13. History

- **Phases 0–7 (2026-10-01 to 2026-10-05)** built OMacKey one key and one
  group at a time, each with the user's physical tests:
  - Phase 0: foundation and spikes;
  - Phase 1: relocating Omarchy's binds;
  - Phase 2: text navigation;
  - Phase 3: core editing;
  - Phase 4: windows and tabs;
  - Phase 5: OS controls;
  - Phase 6: per-app work for terminals, browsers, VS Code, Nautilus,
    Obsidian and LibreOffice;
  - Phase 7: the catch-all, ⌘., Emacs keys, the Mac-mode toggle and the
    mouse.

  The plan, the per-phase key tables and the session log lived in `PLAN.md`;
  read it in git history.
- **The refactor R0–R8 (2026-10-06 to 2026-10-07)** restructured that code
  without changing behaviour. It started from `dc3b0a9`, the last commit
  before the refactor; the plan was `REFACTOR.md` (`3182380`).
  - R0: the snapshot harness;
  - R1: library consolidation;
  - R2: declare, build, bind, with validation;
  - R3: apps as overlays;
  - R4: settings;
  - R5: one shortcut file;
  - R6: self-describing actions, the catalog and introspection;
  - R7: canonical key strings and derived glyphs;
  - R8: these documents.

  Every phase was proven against the snapshot; `scripts/snapshot.sh
  --against dc3b0a9` compares the pre-refactor tree. Two fixes found during
  the refactor changed behaviour on purpose: VS Code ⌘0 (F22) and
  LibreOffice ⌘G / ⇧⌘G (F23).
- **Phase 8 (2026-10-07)** finished the project's tooling: the generated key
  docs (`docs/KEYBINDINGS.md`), the README, the drift check after
  `omarchy update` (`scripts/drift.sh`) and the lint pass (`scripts/lint.sh`).
