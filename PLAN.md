# OMacKey — Phased Plan

Living document and single source of truth for scope, decisions, key tables and
progress. Work is done in small sessions (one key, then one group of related
keys). Every session starts by reading `CLAUDE.md`, the **Status board** and the
last **Session log** entry, and ends by updating this file.

Notation: ⌘ = `SUPER`, ⌥ = `ALT`, ⌃ = `CTRL`, ⇧ = `SHIFT`, ⌫ = BackSpace,
⌦ = Delete, ⏎ = Return. Hyprland key strings are written as in Lua config:
`"SUPER + SHIFT + LEFT"`.

Contents:

1. Goal
2. Status board
3. Decisions (confirmed)
4. Architecture
5. Phases 0–8 (tasks and per-key tables)
6. Omarchy relocation table
7. Unmapped & limitations
8. Testing & recovery
9. Findings
10. References
11. Session log

---

## 1. Goal

Make Omarchy respond to the macOS shortcuts people use every day, so moving
between a work Mac and a home Omarchy machine needs no mental remapping.

- Implemented only in Hyprland's Lua config, layered on top of Omarchy's
  defaults, and installable into `~/.config/hypr`.
- The shortcut-help menu (Omarchy's SUPER+K, which moves to ⌘?) keeps showing
  the live bindings.
- Every Omarchy binding that has to move gets a new key. Anything that can't
  move is documented as unmapped.

**Non-goals**

- 100% macOS fidelity. The target is the common shortcuts in common apps.
- External remappers or daemons (keyd, xremap, kinto). If a Mac behaviour needs
  more than a small Lua function, it gets documented as unmapped instead.
- Mac Option-key special characters, Mac Home/End semantics, and ⌘-click (see
  §7).
- Any change under `/usr/share/omarchy` or `/usr/share/hypr`.

---

## 2. Status board

| Phase | Title | Status |
| --- | --- | --- |
| 0 | Foundation & spike (first key: ⌘← → Home) | [x] |
| 1 | Relocate Omarchy bindings: 1a WM → ⌃⌥ · 1b Spaces & arrow rule · 1c Launchers → ⌃⌥⌘ · 1d Utilities & help | [x] |
| 2 | Cursor movement, selection, deletion | [ ] |
| 3 | Core editing (clipboard, undo/redo, select all, find, save) | [ ] |
| 4 | Window & tab controls | [ ] |
| 5 | OS controls (lock, screenshots, help, emoji, force quit) | [ ] |
| 6 | App-specific: 6a terminals · 6b browsers · 6c VS Code · 6d Nautilus · 6e Obsidian · 6f LibreOffice | [ ] |
| 7 | Catch-all ⌘→Ctrl & the rest | [ ] |
| 8 | Docs generator, README, maintenance tooling | [ ] |

**Why this order.** The user's category order is kept, with one change:
workspace controls move up into Phase 1b. Omarchy's workspace keys (SUPER+1–0,
SUPER+TAB) and window-management keys sit on keys macOS needs (⌘1–9 for tabs,
⌘Tab, ⌘arrows, ⌘W…). Relocating all displaced Omarchy bindings first means
every later phase only *adds* Mac bindings into keys that are already free. No
phase has to undo or move another phase's work.

---

## 3. Decisions (confirmed with the user on 2026-10-01)

Do not re-litigate these without asking the user.

**D1 — Modifier model**

| Mac key | Linux mod | Role in OMacKey |
| --- | --- | --- |
| ⌘ | `SUPER` | App shortcuts translated to Ctrl (Ctrl+Shift/Insert variants in terminals). Text navigation (⌘arrows, ⌘⌫). A few Mac system shortcuts: ⌘Space, ⌘Tab, ⌘\`, ⌘Q, ⌘H, ⌘M, ⌘⇧3/4/5, ⌘? |
| ⌥ | `ALT` | Word-wise navigation and deletion (⌥←/→, ⌥⇧←/→, ⌥⌫, ⌥⌦). Everything else passes through, so Meta keeps working in bash/tmux/nvim. No Mac special characters. |
| ⌃ | `CTRL` | Passes through to apps (⌃C in terminals, ⌃Tab, ⌃G in VS Code). Exceptions: ⌃ + arrows focus windows, ⌃⇧ + arrows move windows within the workspace, ⌃1–0 / ⌃⇧1–0 go to / move to workspace N (as macOS ⌃1–9). Changed in Phase 1b, see §6.2 |
| ⌃⌥ | `CTRL + ALT` | Window management, Rectangle/Magnet style: resize, float, fullscreen variants, groups, scratchpad, layout toggle, close. Arrows step up a level: ⌃⌥ + arrows switch workspace, ⌃⌥⇧ + arrows take the window to the previous/next workspace |
| ⌃⌘ | `CTRL + SUPER` | Omarchy system utilities, panels and toggles (mostly unchanged), plus the Mac ⌃⌘ shortcuts: ⌃⌘F fullscreen, ⌃⌘Q lock, ⌃⌘Space emoji |
| ⌃⌥⌘ | `CTRL + ALT + SUPER` | App launchers, keeping Omarchy's letters (B browser, F files, N editor…). ⌃⌥⌘⇧ holds the variants that used SUPER+SHIFT+ALT. |
| ⌃⌘⇧ | `CTRL + SUPER + SHIFT` | Omarchy's info toggles that collided with launcher letters (battery, weather, calendar), plus Omarchy's existing ⌃⌘⇧ binds (theme menu, agent, reminders) |

**D2 — Keyboard.** SUPER is ⌘ logically.
- The user's NuPhy Air75 V2 in Mac mode already puts ⌘ (Super) next to the
  space bar.
- PC-layout keyboards get an opt-in xkb Alt/Super swap, documented in Phase 7.

**D3 — Translation strategy: curated first, catch-all later.**
- Phases 2–6 map named shortcuts one by one, each with a readable description
  in the help menu.
- Phase 7 adds a catch-all: any ⌘+key not claimed yet → Ctrl+key.

**D4 — Synthetic keys are sent by physical keycode.**
- Every key goes out as `code:N` from `omackey/lib/keys.lua`, so it still works
  while a Persian layout is active.
- Binds are written with key names, matching Omarchy's strings. That keeps them
  readable and keeps `hl.unbind` compatible.
- If spike S4 shows that key-name binds fail under Persian, binds switch to
  keycodes through the same table.

**D5 — Terminals.** They are detected by Omarchy's `terminal` window tag
(`default/hypr/apps/terminals.lua`).
- Copy/paste follow Omarchy's own approach: ⌘C → Ctrl+Insert, ⌘V →
  Shift+Insert.
- ⌘Z and ⌘X are never sent as Ctrl+Z (SIGTSTP) or Ctrl+X.
- Any ⌘ chord not mapped for terminals is consumed, which matches macOS where ⌘
  never reaches the shell.

**D6 — Per-app behaviour uses one global bind per key.**
- At press time the bind works out the active window's *profile* and runs that
  profile's action.
- A profile can return `{ ok = false }`; with `auto_consuming = true` the raw key
  then passes through to the app.
- Nothing is bound or unbound on focus changes.

**D7 — Help menu.** Every OMacKey bind and every relocated Omarchy bind has a
`description`, so the help menu lists the live mapping.
- The help menu moves from SUPER+K to **⌘?** (`SUPER + SHIFT + slash`, the Mac
  Help shortcut), because apps need ⌘K (VS Code chords, browser search).

**D8 — Install.**
- The repo's `omackey/` directory is symlinked to `~/.config/hypr/omackey`.
- `install.sh` adds marker-delimited `require` lines to
  `~/.config/hypr/hyprland.lua`; `uninstall.sh` removes the lines and the
  symlink.
- OMacKey loads *after* Omarchy's defaults and *before* the user's
  `hypr.bindings`, so the user's personal overrides still win.

**D9 — Coverage of displaced binds.**
- Every Omarchy bind that collides with a Mac shortcut gets a new key (§6). Ones
  that can't are listed in §7.
- Omarchy binds that don't collide stay where they are. That preserves Omarchy
  muscle memory and keeps the diff small.

**D10 — App tuning scope.**
- Terminals: foot and Ghostty; Alacritty and kitty get the generic terminal
  rules.
- Browsers: Brave, Brave Origin, Chromium and Google Chrome; Firefox
  best-effort.
- VS Code, Nautilus, Obsidian and LibreOffice.

**D11 — Persian (deferred by the user, 2026-10-01).** The user sometimes types
Persian. Sending by keycode (D4) is kept so non-Latin layouts are likely to
work, but Persian test passes (spike S4, §8.2 step 6) are skipped until the
user asks for them.

**D12 — Customization (confirmed with the user, 2026-10-02).**
- Opting *out* of an OMacKey default means unbinding it in the user's
  `~/.config/hypr/bindings.lua`, which loads after OMacKey:
  `hl.unbind("CTRL + UP")`. The key then reaches apps again.
- Config flags are only for opt-*in* extras that add unexpected behaviour,
  e.g. 7c Emacs keys, 7d Mac-mode toggle, 7e Alt/Super swap. There are no
  flags for removing defaults.
- So the docs (8.1, 8.2) must show the exact key string for every binding,
  because `hl.unbind` matches the original string exactly, including case.

---

## 4. Architecture

### 4.1 Repo layout

Files marked (Phase N) are created by that phase.

```text
OMacKey/
├── CLAUDE.md                 agent guide
├── PLAN.md                   this file
├── README.md                 user-facing docs (Phase 8)
├── install.sh                symlink + guarded loader lines in ~/.config/hypr/hyprland.lua, then scripts/check.sh
├── uninstall.sh              removes both (backs up hyprland.lua first)
├── .luarc.json               LuaLS: Hyprland stubs + globals hl, o, omackey
├── omackey/                  → symlinked to ~/.config/hypr/omackey (Lua module prefix: hypr.omackey)
│   ├── load.lua              entry points pre()/init() called from hyprland.lua; pcall-guarded, errors → notification;
│   │                         defines the `omackey` global (status(), fired(id), trigger(id)) for hyprctl repl
│   ├── init.lua              loads the feature modules listed in config.modules
│   ├── config.lua            module list, release_ms, app profiles
│   ├── relocations.lua       §6 as data
│   ├── lib/
│   │   ├── keys.lua          key name → "code:N" (XKB keycode = evdev + 8)
│   │   ├── send.lua          tap() (seq() in Phase 2) with retained timers
│   │   ├── apps.lua          active window → profile chain, e.g. { "terminal", "default" }
│   │   ├── bind.lua          mac{} helper: per-profile dispatch, auto_consuming, registry, press counter
│   │   └── relocate.lua      hl.bind hook/unhook + key normalization (approach A, 4.3)
│   ├── spaces.lua            Phase 1b: ⌃↑/↓ and ⌃⇧ arrows (workspaces), via action{}
│   ├── text.lua              Phase 2 (⌘← added in Phase 0.6)
│   ├── editing.lua           (Phase 3)
│   ├── windows.lua           (Phase 4)
│   ├── system.lua            (Phase 5)
│   ├── apps/                 (Phase 6) profile overrides
│   └── catchall.lua          (Phase 7)
├── scripts/
│   ├── check.sh              reload, configerrors, omackey.status(), duplicate-bind detector, help-menu grep
│   ├── keylog.py             GTK4 key-event logger used as the test app (wev alternative, no install)
│   └── gen-docs.lua          (Phase 8)
└── docs/
    └── KEYBINDINGS.md        (Phase 8, generated)
```

`~/.config/hypr/hyprland.lua` after install:

```lua
-- Load Omarchy defaults.
-- >>> OMacKey pre (managed by OMacKey install.sh)
do local ok, loader = pcall(require, "hypr.omackey.load"); if ok then loader.pre() end end
-- <<< OMacKey pre
require("default.hypr.omarchy")
-- >>> OMacKey (managed by OMacKey install.sh)
do local ok, loader = pcall(require, "hypr.omackey.load"); if ok then loader.init() end end
-- <<< OMacKey
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")   -- user's personal overrides still win
```

Notes:
- **Two layers of guarding.** If the repo or symlink is missing, `pcall(require)`
  makes the loader lines a silent no-op. If OMacKey code throws, `load.lua`
  reports the error as a Hyprland notification and records it in
  `omackey.status()`. Either way, Omarchy's defaults and the user's files still
  load.
- **Module paths.** Omarchy's `bootstrap.lua` adds `~/.config/?.lua` to
  `package.path`, with no `?/init.lua` entry, so modules are required by full
  name.
- **Reloads.** Every reload starts a fresh Lua state: globals are gone and `hl`
  is a new table (§9 F1). Edits behind the symlink may not trigger Hyprland's
  auto-reload, so run `scripts/check.sh` or `hyprctl reload`.

### 4.2 How a translated key works

The pattern below is proven by Omarchy's `default/hypr/bindings/clipboard.lua`
and by the r/omarchy snippet in Findings F0. It sends the target key down with
`send_key_state`, then sends it up from a timer. Hyprland's `send_shortcut`
leaves keys stuck or repeating (Hyprland discussion #14099, still open in
0.56), so it is never used directly.

```lua
-- lib/send.lua (sketch; finalize in Phase 0)
local keys = require("hypr.omackey.lib.keys")
local config = require("hypr.omackey.config")
local M = {}

-- Timer handles MUST stay referenced: a garbage-collected timer never fires,
-- the "up" event is never sent, and the key repeats forever.
local pending, seq = {}, 0

local function key_state(mods, key, state)
  -- Explicit mods replace the physically held SUPER/ALT for this event.
  -- No `window` field: goes to the focused surface (also reaches Omarchy's
  -- layer-shell menus). Spike S3 confirms or changes this.
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = keys.code(key), state = state }))
end

function M.tap(mods, key)
  return function()
    key_state(mods, key, "down")
    seq = seq + 1
    local id = seq
    pending[id] = hl.timer(function()
      key_state(mods, key, "up")
      pending[id] = nil
    end, { timeout = config.release_ms, type = "oneshot" })
  end
end

-- M.seq({ {"SHIFT", "Home"}, {"", "BackSpace"} }) → taps in order, spaced by timers
return M
```

```lua
-- A Mac binding with per-profile behaviour (lib/bind.lua API sketch)
mac({
  category = "Cursor", mac = "⌘←", keys = "SUPER + LEFT", desc = "Line start",
  default  = send.tap("", "Home"),
  terminal = send.tap("", "Home"),
  -- profile = function | "pass" (raw key to app) | "consume" (do nothing)
  repeating = true,
})
```

`mac{}` resolves the profile at press time, using the most specific match
first: class profile, then family (`terminal`, `browser`), then `default`. It
then:
- runs the profile's action, or returns `{ ok = false }` for `"pass"`;
- registers with `auto_consuming = true` and the description;
- records the binding in the **registry** that Phase 8 reads.

Profiles (`lib/apps.lua`):
- They are built on Omarchy's tags where those exist: `terminal`,
  `chromium-based-browser`, `firefox-based-browser`. Dynamic tags carry a
  trailing `*`.
- Class lists cover everything else. Note that **Brave Origin**
  (`brave-origin`, the user's default browser) is *not* matched by Omarchy's
  browser tag regex.
- Omarchy web apps (classes like `chrome-<host>__…-Default`) are deliberately
  left on the default profile.

### 4.3 Relocation mechanism — approach A chosen (spike S7, §9 F1)

Both approaches keep the data in `relocations.lua`. Key strings are normalized
(modifier order and case) because Omarchy writes both
`"SUPER + SHIFT + ALT + …"` and `"SUPER + ALT + SHIFT + …"`.

- **A. Rewrite at registration time — implemented in `lib/relocate.lua`.**
  - How it works: `load.pre()` runs before `require("default.hypr.omarchy")`
    and wraps `hl.bind` with a lookup in `relocations.lua`. Omarchy's own
    `o.bind` calls then register straight onto the new keys. `load.init()`
    restores the original `hl.bind`.
  - `omackey.status()` reports `unused_relocations` when an Omarchy key in the
    table was never registered, i.e. Omarchy changed it.
  - Pros: Omarchy's dispatchers, descriptions and conditions are preserved
    (`omarchy_preinstalled_bindings`, voxtype presence). Relocations follow
    Omarchy updates automatically. The table is pure data, ready for the docs.
  - Cons: it monkey-patches `hl.bind`, and it needs a second marker line in
    `hyprland.lua`.
  - Check: Omarchy's help-menu mock defines its own `hl.bind`, which gets
    wrapped the same way. The help menu should therefore show the relocated
    keys too; verify this in S7.
- **B. Unbind and redeclare (fallback).**
  - How it works: `hl.unbind("<exact Omarchy string>")`, then declare the same
    action again on the new key.
  - Pros: this is Omarchy's documented pattern.
  - Cons: about 100 Omarchy actions get duplicated, and they silently drift
    when Omarchy changes one.

### 4.4 Registry → docs

Every `mac{}` call and every relocation is recorded with: category, Mac glyphs,
hl key string, description, per-profile actions, and the Omarchy key it
relocated. Phase 8's `scripts/gen-docs.lua` loads the modules under a mocked
`hl`, the same trick `omarchy-menu-keybindings` uses, and renders
`docs/KEYBINDINGS.md` from the registry. Design the registry shape in Phase 0
so the docs come almost for free.

---

## 5. Phases

How to read the tables:
- Actions are synthetic chords, e.g. `Ctrl+Shift+Home`.
- `seq(a, b)` means tap a, then b.
- `pass` means the raw key goes to the app.
- `consume` means nothing happens.
- `hl:…` means a Hyprland action.
- "Term" is the generic terminal profile (Omarchy `terminal` tag).
- "verify" marks app defaults that must be checked in the app before
  implementing.

Every phase's acceptance tests are the per-key protocol in §8.2 plus the phase's
own notes.

### Phase 0 — Foundation & spike

**Goal:** one Mac shortcut, ⌘← → Home, working end-to-end through the final
architecture, and the open technical questions answered and recorded in §9.

- [x] 0.1 Scaffold (§4.1). Feature modules are created by their own phase;
  `config.modules` lists the enabled ones.
- [x] 0.2 `install.sh` and `uninstall.sh`:
  - idempotent marker blocks with guarded loader lines;
  - back up `hyprland.lua` and verify the insertion (restoring the backup if
    it failed);
  - refuse to replace a non-symlink `~/.config/hypr/omackey`;
  - tested in a scratch HOME (install, re-install, uninstall gives back an
    identical config), then installed live.
  - Note for the README: `omarchy refresh hyprland` removes the loader lines,
    so re-run `./install.sh` after it.
- [x] 0.3 `scripts/check.sh`:
  - reload, `configerrors`, `omackey.status()`;
  - the duplicate detector (per submap, modmask, key and release flag;
    Omarchy's intentional ALT+TAB doubles are allowed);
  - optional help-menu grep (`scripts/check.sh "line start"`).
- [x] 0.4 `lib/keys.lua`, `lib/send.lua`, `lib/apps.lua`, `lib/bind.lua` (with
  the registry and press counter), `lib/relocate.lua`, `load.lua`.
  - Test tool: `scripts/keylog.py`.
- [x] 0.5 Spikes S1–S11 (results in §9 F1). S4 is deferred (D11), S5 moves to
  Phase 2 (first ⌥ key), and S9 waits for an XWayland app.
- [x] 0.6 First key: ⌘← → `Home`, and `SUPER + LEFT` (focus left) relocated to
  `CTRL + ALT + LEFT`. Passed the user's physical tests in keylog, Brave, VS
  Code and foot; ⌃⌥← focuses left (moved to ⌃← in 1b); the help menu shows
  both.

**Spike checklist**

| # | Question | Status |
| --- | --- | --- |
| S1 | With ⌘ held, does `send_key_state` with `mods = ""` deliver a plain `Home` (no Super) to the client? | ✅ physical ⌘← arrives as `Home`, `mods=-` |
| S2 | Release delay (Omarchy uses 50 ms, Reddit 5 ms) combined with `repeating = true`: does holding the key repeat cleanly? Any stuck keys after rapid presses followed by normal typing? | ✅ 20 ms release: holding repeats and stops on release; rapid taps leave nothing stuck |
| S3 | Should we omit `window` (focused surface) or pass `window = "activewindow"`? Does text navigation work inside Omarchy's launcher/menu search field (layer shell)? | ✅ omitted `window` reaches normal windows. The Omarchy launcher's search field has no cursor movement at all (not even arrows or Home), so it can't show anything; not an OMacKey issue. Retest layer-shell delivery with ⌘C/⌘V in Phase 3 |
| S4 | Persian: (a) xkb `us,ir` with `grp:alts_toggle`; (b) fcitx5 with `keyboard-ir`. Do key-name binds fire, and do keycode-sent chords arrive correctly? | deferred by the user (D11) |
| S5 | ⌥ chords: does releasing ⌥ after ⌥← focus the menu bar in VS Code, Obsidian, LibreOffice or Firefox? | ✅ no workaround needed: in VS Code and LibreOffice ⌥←/→ moves by word without focusing the menu, and Obsidian has no menu to focus (§9 F2). Firefox also fine (tested by the user) |
| S6 | Does `auto_consuming = true` plus `return { ok = false }` pass the raw key through from a function bind? | ✅ the probe on ⌃⌥⌘⇧Y returning `{ ok = false }` passed the raw key through to keylog |
| S7 | Relocation approach A: is `hl` writable, are wrapped binds correct, does `hl.bind` get restored? | ✅ |
| S8 | The help menu shows the new and relocated binds with their descriptions | ✅ |
| S9 | Does an XWayland client receive the synthetic keys? | deferred: no XWayland app running |
| S10 | Embedded Lua version | ✅ Lua 5.5 |
| S11 | Can `wtype` (virtual keyboard) trigger our binds? | ✅ No. Automated tests use `omackey.trigger(id)` instead |

### Phase 1 — Relocate Omarchy bindings

Implement §6 one group per session. After each group:
- `scripts/check.sh` is clean and shows no duplicate binds;
- the help menu shows the new keys with Omarchy's original descriptions;
- the user lives with the new keys for a day before the next group.

- [x] **1a — Window management → ⌃⌥** (§6.1). 43 relocations; tested by the
  user on `dwindle` and `scrolling`, and the help menu shows the new keys.
- [x] **1b — Spaces and the arrow rule** (§6.2). Tested by the user on
  scrolling and dwindle. This is the user's
  "workspace controls" category, following the arrow rule in §6.2:
  - ⌃ + arrows focus windows, and ⌃⇧ + arrows swap windows. These replace
    1a's ⌃⌥ / ⌃⌥⇧ arrows.
  - ⌃⌥←/↑ and ⌃⌥→/↓ go to the previous/next existing workspace. Omarchy's
    ⌘ + scroll-down is "next", which matches the vertical pair.
  - ⌃⌥⇧ + arrows (new) move the window to the previous/next existing
    workspace, the same target as ⌃⌥ + arrows.
  - ⌃1–0 jumps to workspace N; ⌃⇧1–0 moves the window there; ⌃⌥⇧1–0 moves it
    silently.
  - Mission Control and App Exposé are unmapped (§7).
  - The new binds live in `omackey/spaces.lua` (the `action{}` helper);
    Omarchy's own binds move via `relocations.lua`.

  Test on dwindle and scrolling, and with two monitors if available.
- [x] **1c — Launchers → ⌃⌥⌘** (§6.3). The info popups time, battery,
  weather and calendar moved to ⌃⌘⇧ T/B/W/D. Tested by the user.
- [x] **1d — Utilities & help** (§6.4). Help moved to ⌘?; dismiss last
  notification to ⌃⌘⇧,; calculator to ⌃⌥⌘Q; background switcher to
  ⌃⌥⌘Space. Tested by the user.

After Phase 1, the only SUPER, SUPER+SHIFT and SUPER+ALT binds left are
Mac-compatible:
- ⌘Space, ⌘⌥Space, ⌘⇧Space, ⌘Esc
- ⌘C/V/X (Omarchy's universal clipboard until Phase 3)
- ⌘Home and ⌘⌥Home
- ⌘⇧, ⌘⌥, ⌘⇧⌥, (notifications), ⌘⌥Tab, ⌘⌥1–5 (groups), ⌘⌥-/= and
  ⌘⌥⇧-/= (±25 px resize)
- mouse binds and PRINT variants

### Phase 2 — Cursor movement, selection, deletion

Applies to all GUI apps. Navigation and deletion binds are `repeating`.
Implement key by key in this order.

| ✓ | Mac | Meaning | GUI apps | Term | Notes |
| --- | --- | --- | --- | --- | --- |
| [x] | ⌘← | line start | `Home` | `Home` | Phase 0.6 |
| [x] | ⌘→ | line end | `End` | `End` | |
| [x] | ⌘⇧← | select to line start | `Shift+Home` | consume | |
| [x] | ⌘⇧→ | select to line end | `Shift+End` | consume | |
| [x] | ⌥← | word left | `Ctrl+Left` | `Ctrl+Left` | `/etc/inputrc` maps `\e[1;5D` to backward-word; nvim uses `<C-Left>` |
| [x] | ⌥→ | word right | `Ctrl+Right` | `Ctrl+Right` | |
| [x] | ⌥⇧← | select word left | `Ctrl+Shift+Left` | consume | |
| [x] | ⌥⇧→ | select word right | `Ctrl+Shift+Right` | consume | |
| [ ] | ⌘↑ | document start | `Ctrl+Home` | consume | 6a may map scrollback |
| [ ] | ⌘↓ | document end | `Ctrl+End` | consume | |
| [ ] | ⌘⇧↑ | select to doc start | `Ctrl+Shift+Home` | consume | |
| [ ] | ⌘⇧↓ | select to doc end | `Ctrl+Shift+End` | consume | |
| [ ] | ⌥⌫ | delete word left | `Ctrl+BackSpace` | pass | Alt+BackSpace is readline backward-kill-word |
| [ ] | ⌥⌦ | delete word right | `Ctrl+Delete` | `Alt+d` | |
| [ ] | ⌘⌫ | delete to line start | `seq(Shift+Home, BackSpace)` | `Ctrl+U` | Nautilus overrides this in 6d |
| [ ] | ⌘⌦ | delete to line end | `seq(Shift+End, Delete)` | `Ctrl+K` | |

- ⌥↑/↓ deliberately **pass**, because VS Code uses Alt+Up/Down to move a line,
  just like on the Mac.
- Spike S5 is answered (§9 F2): ⌥←/→ need no menu-bar workaround in VS Code,
  LibreOffice, Obsidian or Firefox. If a later app does focus its menu, the
  options are an app setting such as VS Code
  `"window.customMenuBarAltFocus": false` or Firefox
  `ui.key.menuAccessKeyFocuses=false`, or sending a dummy key first (Kinto's
  Alt+F19 trick).

### Phase 3 — Core editing

| ✓ | Mac | Meaning | GUI apps | Term | Notes |
| --- | --- | --- | --- | --- | --- |
| [ ] | ⌘C | copy | `Ctrl+C` | `Ctrl+Insert` | replaces Omarchy's universal copy (unbind `SUPER + C`); fixes the dropped timer handle |
| [ ] | ⌘V | paste | `Ctrl+V` | `Shift+Insert` | replaces Omarchy's universal paste |
| [ ] | ⌘X | cut | `Ctrl+X` | consume | Omarchy currently sends Ctrl+X to terminals as well |
| [ ] | ⌘⇧V | paste plain | `Ctrl+Shift+V` | `Shift+Insert` | LibreOffice override in 6f |
| [ ] | ⌘Z | undo | `Ctrl+Z` | consume | never send Ctrl+Z to a terminal |
| [ ] | ⌘⇧Z | redo | `Ctrl+Shift+Z` | consume | LibreOffice → `Ctrl+Y` (6f) |
| [ ] | ⌘A | select all | `Ctrl+A` | consume | Ghostty select-all in 6a |
| [ ] | ⌘F | find | `Ctrl+F` | consume | terminal search in 6a |
| [ ] | ⌘G | find next | `F3` | consume | F3 works in Chromium, Firefox, VS Code and GTK. LibreOffice: F3 is AutoText, so override in 6f |
| [ ] | ⌘⇧G | find previous | `Shift+F3` | consume | Nautilus: go to location (6d) |
| [ ] | ⌘S | save | `Ctrl+S` | consume | |
| [ ] | ⌘⇧S | save as | `Ctrl+Shift+S` | consume | |
| [ ] | ⌘B / ⌘I / ⌘U | bold / italic / underline | `Ctrl+B/I/U` | consume | |
| [ ] | ⌘/ | toggle comment | `Ctrl+/` | consume | |

Acceptance extra: ⌘C/⌘V also work inside Omarchy's menus (layer shell, see
S3) and the clipboard manager (⌃⌘V) is unaffected.

### Phase 4 — Window & tab controls

| ✓ | Mac | Meaning | GUI apps | Term | Notes |
| --- | --- | --- | --- | --- | --- |
| [ ] | ⌘W | close tab / window | `Ctrl+W` | foot/Alacritty: `hl:close`; Ghostty/kitty: `Ctrl+Shift+W` | keep a "no-tabs" class list where ⌘W → `hl:close` (grow it from Findings) |
| [ ] | ⌘⇧W | close window | browsers/VS Code: `Ctrl+Shift+W`; default `hl:close` | `hl:close` | |
| [ ] | ⌘Q | quit app | close every window of the active class (`hl.get_windows`, then close each) | same | Mac semantics: all windows of the app |
| [ ] | ⌘N | new window | `Ctrl+N` | `Ctrl+Shift+N` | |
| [ ] | ⌘⇧N | new folder / private window | `Ctrl+Shift+N` | consume | Firefox → `Ctrl+Shift+P` (6b) |
| [ ] | ⌘T | new tab | `Ctrl+T` | Ghostty/kitty `Ctrl+Shift+T`; foot `Ctrl+Shift+N` | |
| [ ] | ⌘⇧T | reopen closed tab | `Ctrl+Shift+T` | consume | |
| [ ] | ⌘O / ⌘P / ⌘R / ⌘L | open / print or quick-open / reload / location | `Ctrl+O/P/R/L` | consume | |
| [ ] | ⌘1–⌘9 | tab N | `Ctrl+1–9` | Ghostty `Alt+1–9` (6a); else consume | |
| [ ] | ⌘= ⌘+ ⌘- ⌘0 | zoom in / in / out / reset | `Ctrl+equal`, `Ctrl+equal`, `Ctrl+minus`, `Ctrl+0` | same (foot font size) | bind both `SUPER + equal` and `SUPER + SHIFT + equal` |
| [ ] | ⌘[ / ⌘] | back / forward (browser, files); outdent / indent (editors) | default `Ctrl+[` / `Ctrl+]`; browser & Nautilus profiles `Alt+Left/Right` | consume | |
| [ ] | ⌘⇧[ / ⌘⇧] | previous / next tab | `Ctrl+Page_Up` / `Ctrl+Page_Down` | per terminal (6a) | |
| [ ] | ⌘⌥← / ⌘⌥→ | previous / next tab | `Ctrl+Page_Up` / `Ctrl+Page_Down` | per terminal (6a) | Obsidian: back/forward (6e) |
| [ ] | ⌘Tab / ⌘⇧Tab | switch window | `hl:cycle_next` plus `bring_to_top` (same as Omarchy's ⌥Tab) | — | not MRU app switching (§7) |
| [ ] | ⌘\` / ⌘⇧\` | cycle the active app's windows | Lua: windows of the active class, ordered by `stable_id`, focus next | — | |
| [ ] | ⌘M | minimize | move the window to `special:minimized` (silent) | same | ⌃⌥M shows/hides minimized windows. Restore design: decide with the user at the start of this phase |
| [ ] | ⌘H | hide app | proposal: all windows of the class → `special:minimized` | same | ⌘⌥H "hide others" is unmapped |
| [ ] | ⌘, | preferences | `Ctrl+comma` | Ghostty `Ctrl+comma` (open config); else consume | browsers/LibreOffice in 6b/6f |

### Phase 5 — OS controls

| ✓ | Mac | Meaning | Action | Notes |
| --- | --- | --- | --- | --- |
| [ ] | ⌘Space | Spotlight | Omarchy launcher, `SUPER + SPACE` (unchanged) | already Mac-like, verify only |
| [ ] | ⌘⌥Space | Finder search | Omarchy apps menu (unchanged) | |
| [ ] | ⌃⌘Q | lock screen | `omarchy-system-lock` | the calculator moved off ⌃⌘Q in 1d; ⌃⌘L still locks too |
| [ ] | ⌘⇧Q | log out | `omarchy-menu toggle system` (a menu, not an instant logout) | Ctrl+Shift+Q quits Chrome on Linux, so the catch-all must never send it |
| [ ] | ⌘⌥Esc | force quit | `hl.dsp.window.kill()` on the active window | Mac shows a dialog; this kills directly. Confirm with the user |
| [ ] | ⌘⇧3 | screenshot of screen to file | `omarchy-capture-screenshot fullscreen save` | verify the argument semantics. Relies on 1b having moved ⌘⇧1–0 |
| [ ] | ⌃⌘⇧3 | screen to clipboard | `omarchy-capture-screenshot fullscreen copy` | |
| [ ] | ⌘⇧4 | region to file | `omarchy-capture-screenshot region save` | Omarchy's picker: ⏎ captures the window under the cursor, ≈ Mac's Space |
| [ ] | ⌃⌘⇧4 | region to clipboard | `omarchy-capture-screenshot region copy` | |
| [ ] | ⌘⇧5 | capture menu | `omarchy-menu toggle capture` | also covers screen recording |
| [ ] | ⌘? (⌘⇧/) | help | `omarchy-menu-keybindings` | added in 1d, verify here |
| [ ] | ⌃⌘Space | emoji & symbols | `omarchy-shell shell toggle omarchy.emojis` | the background switcher moved off ⌃⌘Space in 1d |
| [ ] | ⌥⌘D | show/hide Dock | `omarchy-toggle-bar` (top bar) | ⌘⇧Space still works |
| [ ] | ⌃⌘F | full screen | moved in 1a, verify only | |
| [ ] | F-row in Mac mode | brightness / volume / media | Omarchy's XF86 binds (unchanged) | check with `wev` which keysyms the NuPhy sends in Mac mode (e.g. Mission Control and Launchpad keys) |

### Phase 6 — App-specific

One sub-phase per session. Every value marked "verify" must be checked against
the app's own Linux keybindings before implementing. Record app quirks in §9.

**6a — Terminals** (foot, Ghostty; Alacritty and kitty use the generic rules)

| Mac | foot | Ghostty (verify with `ghostty +list-keybinds --default`) |
| --- | --- | --- |
| ⌘T | `Ctrl+Shift+N` (no tabs: new window) | `Ctrl+Shift+T` |
| ⌘N | `Ctrl+Shift+N` | `Ctrl+Shift+N` |
| ⌘W | `hl:close` | `Ctrl+Shift+W` |
| ⌘1–9 | consume | `Alt+1–9` |
| ⌘⇧[ ⌘⇧] / ⌘⌥← ⌘⌥→ | consume | `Ctrl+Page_Up/Page_Down` (verify) |
| ⌘F | `Ctrl+Shift+R` (scrollback search) | verify (`Ctrl+Shift+F` in 1.2+?) |
| ⌘A | consume (no select-all in foot) | `Ctrl+Shift+A` |
| ⌘K (clear) | `Ctrl+L` (approximation) | `Ctrl+L`, or document a `clear_screen` keybind |
| ⌘D / ⌘⇧D (split) | consume | `Ctrl+Shift+O` / `Ctrl+Shift+E` (verify) |
| ⌘↑ / ⌘↓ (scroll) | `Shift+Page_Up` / `Shift+Page_Down` (verify) | verify |
| ⌘, | consume | `Ctrl+comma` |
| ⌘. (interrupt) | `Ctrl+C` (Phase 7b) | `Ctrl+C` |

Open question for the user: tmux. Hyprland can't tell that tmux is running, so
the default is to treat tmux as a plain terminal.

**6b — Browsers** (Brave, Brave Origin `brave-origin`, Chromium, Google Chrome;
Firefox best-effort)

| Mac | Action | Notes |
| --- | --- | --- |
| ⌘[ / ⌘] | `Alt+Left` / `Alt+Right` | back / forward |
| ⌘⌥I / ⌘⌥J / ⌘⌥C | `Ctrl+Shift+I` / `J` / `C` | devtools / console / inspect |
| ⌘⌥U | `Ctrl+U` | view source |
| ⌘Y | `Ctrl+H` | history |
| ⌘⇧J | `Ctrl+J` | downloads (Firefox: `Ctrl+Shift+Y`) |
| ⌘⌥B | `Ctrl+Shift+O` | bookmark manager |
| ⌘⇧N | Firefox: `Ctrl+Shift+P` | private window |
| ⌘, | investigate (open `brave://settings` / `chrome://settings`?) or unmapped | |
| ⌘←/→ outside text fields | not emulated (Mac: back/forward) | §7 |

**6c — VS Code** (class `code`; also `code-oss` / `Code`). Linux VS Code
defaults mostly mirror the Mac ones with Ctrl in place of ⌘, so the generic
rules cover most of it.

| Mac | Action | Notes |
| --- | --- | --- |
| ⌘⌥↑ / ⌘⌥↓ | `Ctrl+Shift+Up/Down` | add cursor above/below |
| ⌘⌥[ / ⌘⌥] | `Ctrl+Shift+[` / `Ctrl+Shift+]` | fold / unfold. Webcam keys moved in 1a |
| ⌘⇧⌥ arrows | `Ctrl+Shift+Alt+arrows` | column select. Monitor moves relocated in 1a |
| ⌘⌥F | `Ctrl+H` | replace |
| ⌃⇧⌘← / → | `Shift+Alt+Left/Right` | shrink/expand selection |
| ⌘. | `Ctrl+period` | quick fix (overrides the 7b ⌘. → Esc rule) |
| physical ⌃- / ⌃⇧- | `Ctrl+Alt+minus` / `Ctrl+Shift+minus` | navigate back/forward. Optional, since it intercepts physical Ctrl in one app |
| ⌘K chords, ⌘P, ⌘⇧P, ⌘D, ⌘⇧L, ⌘⇧K, ⌘⏎, ⌘B, ⌘J, ⌘\\ | generic Ctrl translation (Phases 3, 4, 7) | verify chords: ⌘K ⌘S → Ctrl+K Ctrl+S |
| ⌃Space suggest | physical Ctrl+Space | fcitx5's default trigger is Ctrl+Space and may eat it. Document |
| ⌥ menu focus | none needed | S5 passed for ⌥←/→ (§9 F2). Recheck only if another ⌥ chord shows the problem |

**6d — Nautilus** (`org.gnome.Nautilus`; ideas from Kinto and xremap; verify each)

| Mac | Action |
| --- | --- |
| ⌘↑ | `Alt+Up` (parent folder) |
| ⌘↓ | `Return` (open) |
| ⌘⌫ | `Delete` (move to trash; overrides the Phase 2 line delete) |
| ⌘⇧. | `Ctrl+H` (hidden files) |
| ⌘⇧G | `Ctrl+L` (go to location) |
| ⌘[ / ⌘] | `Alt+Left/Right` |
| ⌘I | properties (verify: `Ctrl+I` or `Alt+Return`) |
| ⌘1 / ⌘2 | icon / list view (verify Nautilus's `Ctrl+1/2` mapping; it is likely the reverse of Finder's) |
| ⌘D, ⌘⇧⌫, ⏎-to-rename | unmapped (§7) |

**6e — Obsidian** (class `obsidian`, Electron; verify)
- ⌘⌥← / ⌘⌥→ → `Ctrl+Alt+Left/Right` (navigate back/forward, overriding the
  tab-switch rule).
- Tab switching via ⌘⇧[ ] stays generic.
- Check ⌘P, ⌘O, ⌘E, ⌘, and ⌘⇧F through the generic rules.
- ⌥ menu focus: checked in Phase 2 (S5). A bare ⌥ does nothing in Obsidian
  here, so there is nothing to work around.

**6f — LibreOffice** (classes `libreoffice-*` / `soffice`; verify)
- ⌘⇧Z → `Ctrl+Y` (redo).
- ⌘, → `Alt+F12` (options).
- ⌘G / ⌘⇧G → repeat search (verify `Ctrl+Shift+F`; F3 is AutoText!).
- ⌘⇧V → `Ctrl+Alt+Shift+V` (paste unformatted).
- ⌘⌥V → `Ctrl+Shift+V` (paste special).
- Check ⌥ menu focus.

### Phase 7 — Catch-all & the rest

- [ ] **7a Catch-all.** Every ⌘ / ⌘⇧ + letter, digit or punctuation (`` ` - =
  [ ] \ ; ' , . / ``, ⏎) not claimed by Phases 2–6 sends Ctrl / Ctrl+Shift +
  the same key.
  - Generate the binds from the registry so the catch-all only fills gaps.
  - Terminals: consume. Option: `pass`, so kitty-protocol apps such as nvim can
    map `<D-…>`.
  - Decide with the user whether catch-all entries get help-menu descriptions
    (that's clutter) or appear only in `docs/KEYBINDINGS.md`.
  - Review risky outcomes: ⌘⇧Q is never translated (Phase 5); also check ⌘J,
    ⌘E, ⌘Y, ⌘⇧X and ⌘⏎ → `Ctrl+Return`.
- [ ] **7b** ⌘. → `Escape` in GUI apps. In terminals it sends `Ctrl+C`; in
  VS Code `Ctrl+period`.
- [ ] **7c** Opt-in Emacs-style ⌃ keys in GUI text fields (⌃A/⌃E line
  start/end, ⌃K kill to end, ⌃D/⌃H delete, ⌃F/⌃B/⌃N/⌃P). Terminals pass
  through.
- [ ] **7d** Mac-mode toggle: turn OMacKey off and on without uninstalling, so
  Omarchy's defaults come back. For example a state file read at load plus
  `hyprctl reload`, wrapped in a small script.
- [ ] **7e** PC keyboards: opt-in `altwin:swap_lalt_lwin` (puts ⌘ next to the
  space bar), documented and applied through `config.lua` or the README. Never
  edit the user's `input.lua` silently.
- [ ] **7f** Option-key characters: evaluate the `us(mac)` xkb variant. Most
  likely just documented.
- [ ] **7g** ⌘-click: confirm it's impossible without an input-level remapper,
  then document it.
- [ ] **7h** Trackpad gestures (3-/4-finger swipes, as on a Mac) for laptop
  users: documentation only, since this machine is a desktop.

### Phase 8 — Docs generator, README, maintenance

- [ ] 8.1 `scripts/gen-docs.lua`: load the config under a mocked `hl` and `o`
  and read the registry. Write `docs/KEYBINDINGS.md` with:
  - per-category tables (Mac key, action, per-app variants);
  - the relocated-Omarchy table;
  - the unmapped list.
- [ ] 8.2 README: what OMacKey is, the modifier model (D1), install and
  uninstall, the PC-keyboard option, troubleshooting, and links to the
  generated docs. Include the D12 recipe for turning a default off:
  `hl.unbind("<exact key string>")` in `~/.config/hypr/bindings.lua`.
- [ ] 8.3 Conflict and drift check for `omarchy update`:
  - snapshot hashes of `/usr/share/omarchy/default/hypr/bindings/*.lua`;
  - warn when they change;
  - re-run the duplicate detector;
  - list Omarchy binds that are new since the snapshot.
- [ ] 8.4 Optional: a syntax/lint pass over every module under the mock (and
  `luacheck` if installed).

---

## 6. Omarchy relocation table

Source of truth for the original keys:
`/usr/share/omarchy/default/hypr/bindings/*.lua` (Omarchy 4.0.4). Descriptions
stay Omarchy's own.

Rule (D9): a bind moves only if it collides with a Mac shortcut, or with a key
another relocation needs. Everything not listed here stays unchanged (§6.5).

### 6.1 Window management → ⌃⌥ (Phase 1a)

| Omarchy key | Action | Mac collision | New key |
| --- | --- | --- | --- |
| `SUPER + W` | Close window | ⌘W close tab | `CTRL + ALT + W` |
| `SUPER + J` | Toggle window split | ⌘J | `CTRL + ALT + J` |
| `SUPER + P` | Pseudo window | ⌘P | `CTRL + ALT + P` |
| `SUPER + T` | Toggle floating/tiling | ⌘T | `CTRL + ALT + T` |
| `SUPER + F` | Full screen | ⌘F find | `CTRL + SUPER + F` (Mac ⌃⌘F) |
| `SUPER + CTRL + F` | Tiled full screen | needed for ⌃⌘F | `CTRL + ALT + F` |
| `SUPER + ALT + F` | Full width (maximize) | ⌘⌥F replace | `CTRL + ALT + RETURN` (Rectangle "maximize") |
| `SUPER + O` | Pop window out | ⌘O | `CTRL + ALT + O` |
| `SUPER + L` | Toggle workspace layout | ⌘L | `CTRL + ALT + L` |
| `SUPER + LEFT/RIGHT/UP/DOWN` | Focus window | ⌘arrows | `CTRL + arrows`. It was `CTRL + ALT + arrows` until Phase 1b swapped it with workspaces (§6.2) |
| `SUPER + SHIFT + arrows` | Swap window | ⌘⇧arrows select | `CTRL + SHIFT + arrows` (was `CTRL + ALT + SHIFT`, same swap) |
| `SUPER + ALT + arrows` | Move window into group | ⌘⌥←/→ tabs, ⌘⌥↑/↓ cursors | `CTRL + ALT + SUPER + arrows` |
| `SUPER + SHIFT + ALT + arrows` | Move workspace to monitor | ⌘⇧⌥arrows column select | `CTRL + ALT + SUPER + SHIFT + arrows` |
| `SUPER + G` | Toggle grouping | ⌘G find next | `CTRL + ALT + G` |
| `SUPER + ALT + G` | Move out of group | ⌘⌥G | `CTRL + ALT + SHIFT + G` |
| `SUPER + S` | Toggle scratchpad | ⌘S | `CTRL + ALT + S` |
| `SUPER + ALT + S` | Move window to scratchpad | ⌘⌥S | `CTRL + ALT + SHIFT + S` |
| `SUPER + code:20` / `code:21` | Resize horizontally ±100 | ⌘- / ⌘= zoom | `CTRL + ALT + minus` / `equal` |
| `SUPER + SHIFT + code:20/21` | Resize vertically ±100 | ⌘⇧- / ⌘+ | `CTRL + ALT + SHIFT + minus/equal` |
| `SUPER + CTRL + code:20/21` | Resize horizontally ±300 | (frees space) | `CTRL + ALT + SUPER + minus/equal` |
| `SUPER + CTRL + SHIFT + code:20/21` | Resize vertically ±300 | (frees space) | `CTRL + ALT + SUPER + SHIFT + minus/equal` |
| `SUPER + ALT + code:20/21`, `SUPER + SHIFT + ALT + code:20/21` | Resize ±25 | none: no Mac binding uses ⌘⌥-/=, so it stays (D9; changed from "unmapped" in Phase 1a) | unchanged |
| `SUPER + SLASH` | Monitor scaling up | ⌘/ comment | `CTRL + ALT + slash` |
| `SUPER + ALT + SLASH` | Monitor scaling down | ⌘⌥/ | `CTRL + ALT + SHIFT + slash` |
| `SUPER + BACKSPACE` | Toggle transparency | ⌘⌫ delete line | `CTRL + ALT + BACKSPACE` |
| `SUPER + SHIFT + BACKSPACE` | Toggle gaps | ⌘⇧⌫ (Chrome clear data, Finder empty trash) | `CTRL + ALT + SHIFT + BACKSPACE` |
| `SUPER + ALT + code:34` / `code:35` | Webcam overlay smaller/larger | ⌘⌥[ / ] fold | `CTRL + ALT + bracketleft/bracketright` |
| new | Toggle minimized windows view | — | `CTRL + ALT + M` (Phase 4) |

### 6.2 Spaces → ⌃ (Phase 1b)

| Omarchy key | Action | Mac collision | New key |
| --- | --- | --- | --- |
| `SUPER + code:10..19` | Switch to workspace 1–10 | ⌘1–9 tabs, ⌘0 zoom | `CTRL + code:10..19` (Mac "Switch to Desktop N") |
| `SUPER + SHIFT + code:10..19` | Move window to workspace | ⌘⇧3/4/5 screenshots | `CTRL + SHIFT + code:10..19` |
| `SUPER + SHIFT + ALT + code:10..19` | Move window silently | (frees ⌘⇧⌥) | `CTRL + ALT + SHIFT + code:10..19` |
| `SUPER + TAB` | Next workspace | ⌘Tab | `CTRL + ALT + RIGHT` |
| `SUPER + SHIFT + TAB` | Previous workspace | ⌘⇧Tab | `CTRL + ALT + LEFT` |
| new | Previous / next workspace (vertical pair) | — | `CTRL + ALT + UP` / `CTRL + ALT + DOWN` |
| new | Move window to previous / next workspace | — | `CTRL + ALT + SHIFT + LEFT` and `UP` / `CTRL + ALT + SHIFT + RIGHT` and `DOWN` |

**The arrow rule** (user's decision, 2026-10-02): ⌃ + arrows move focus
between windows, and ⌃⇧ + arrows take the window along within the
workspace. Focus is the most frequent tiling action, so it gets one modifier;
in scrolling, ⌃→ slides to the next column, which looks like a Mac Space
switch. ⌥ steps up a level: ⌃⌥ + arrows switch workspace, and ⌃⌥⇧ + arrows
take the window there. Numbers only mean workspaces, so they stay on ⌃ like
macOS. Deviation from macOS: ⌃←/→ switch windows, not Spaces.
| new | Mission Control / App Exposé (Mac ⌃↑ / ⌃↓) | — | Unmapped (§7). ⌃↑/↓ switch workspaces instead |

### 6.3 Launchers → ⌃⌥⌘ (Phase 1c)

| Omarchy key | Action | New key |
| --- | --- | --- |
| `SUPER + RETURN` | Terminal | `CTRL + ALT + SUPER + RETURN` (frees ⌘⏎) |
| `SUPER + SHIFT + RETURN` | Browser (duplicate) | `CTRL + ALT + SUPER + SHIFT + RETURN` |
| `SUPER + SHIFT + F` / `SUPER + ALT + SHIFT + F` | File manager / (cwd) | `CTRL + ALT + SUPER + F` / `+ SHIFT + F` |
| `SUPER + SHIFT + B` / `SUPER + SHIFT + ALT + B` | Browser / private | `CTRL + ALT + SUPER + B` / `+ SHIFT + B` |
| `SUPER + SHIFT + N` | Editor | `CTRL + ALT + SUPER + N` |
| `SUPER + SHIFT + M` / `+ ALT + M` | Music / Music TUI | `CTRL + ALT + SUPER + M` / `+ SHIFT + M` |
| `SUPER + SHIFT + D` | Docker | `CTRL + ALT + SUPER + D` |
| `SUPER + SHIFT + G` / `+ ALT + G` | Signal / WhatsApp | `CTRL + ALT + SUPER + G` / `+ SHIFT + G` |
| `SUPER + SHIFT + O` | Obsidian | `CTRL + ALT + SUPER + O` |
| `SUPER + SHIFT + W` | Omawrite | `CTRL + ALT + SUPER + W` |
| `SUPER + SHIFT + SLASH` | Passwords | `CTRL + ALT + SUPER + slash` (frees ⌘?) |
| `SUPER + SHIFT + A` / `+ ALT + A` | ChatGPT / Grok | `CTRL + ALT + SUPER + A` / `+ SHIFT + A` |
| `SUPER + SHIFT + C` | Calendar | `CTRL + ALT + SUPER + C` |
| `SUPER + SHIFT + E` / `+ ALT + E` | Email / New email | `CTRL + ALT + SUPER + E` / `+ SHIFT + E` |
| `SUPER + SHIFT + Y` | YouTube | `CTRL + ALT + SUPER + Y` |
| `SUPER + SHIFT + P` | Google Photos | `CTRL + ALT + SUPER + P` |
| `SUPER + SHIFT + S` | Google Maps | `CTRL + ALT + SUPER + S` |
| `SUPER + SHIFT + X` / `+ ALT + X` | X / X Post | `CTRL + ALT + SUPER + X` / `+ SHIFT + X` |
| `SUPER + CTRL + ALT + B` | Show battery remaining | `CTRL + SUPER + SHIFT + B` (collides with the browser launcher) |
| `SUPER + CTRL + ALT + W` | Toggle weather | `CTRL + SUPER + SHIFT + W` (collides with Omawrite) |
| `SUPER + CTRL + ALT + D` | Calendar panel | `CTRL + SUPER + SHIFT + D` (collides with Docker) |
| `SUPER + CTRL + ALT + T` | Show time | `CTRL + SUPER + SHIFT + T` (no collision; moved to keep the info popups together, user's choice) |

Unchanged (no collision): `SUPER + ALT + RETURN` (Tmux), `SUPER + CTRL +
RETURN` (Herdr), `SUPER + SHIFT + CTRL + G` (Google Messages), and `SUPER +
CTRL + ALT + R/Z/Delete`. Those three are Omarchy's ⌥-variants of ⌃⌘R/Z/Delete
(show reminders, reset zoom, mirroring), so they stay next to their siblings.
`⌃⌘⇧R` is already "Clear reminders".

Keep the conditions Omarchy uses (`o.preinstalled_bindings_enabled()`,
`o.cmd_present`). Approach A preserves them automatically. Rows for
conditional Omarchy binds carry `optional = true`, so `omackey.status()`
doesn't report them as unused when the condition is off. Verified with
`omarchy_preinstalled_bindings = false`: 85 rows applied, none reported.

### 6.4 Utilities & help (Phase 1d)

| Omarchy key | Action | Mac collision | New key |
| --- | --- | --- | --- |
| `SUPER + K` | Keybindings (help) | ⌘K | `SUPER + SHIFT + slash` (⌘?) |
| `SUPER + comma` | Dismiss last notification | ⌘, preferences | `CTRL + SUPER + SHIFT + comma` (user's choice: next to ⌘⇧, dismiss all and the ⌃⌘⇧ info popups; the whole notification family stays on ⌘ + comma) |
| `SUPER + CTRL + Q` | Calculator | ⌃⌘Q lock | `CTRL + ALT + SUPER + Q` |
| `SUPER + CTRL + SPACE` | Background switcher | ⌃⌘Space emoji | `CTRL + ALT + SUPER + SPACE` |
| `SUPER + C` / `V` / `X` | Universal copy/paste/cut | none (already Mac-like) | stay until Phase 3 replaces them with terminal-aware ⌘C/V/X |

### 6.5 Unchanged Omarchy binds (no collision)

- `SUPER + SPACE` (launcher, which equals ⌘Space)
- `SUPER + ALT + SPACE`, `SUPER + SHIFT + SPACE`, `SUPER + ESCAPE`
- `SUPER + Home` / `SUPER + ALT + Home` (window width)
- `SUPER + CTRL + TAB` (former workspace), `ALT + TAB` / `ALT + SHIFT + TAB`,
  `CTRL + ALT + TAB` / `+ SHIFT` (monitor focus), `CTRL + ALT + DELETE`
- `SUPER + ALT + TAB` / `+ SHIFT` (group next/prev), `SUPER + CTRL +
  LEFT/RIGHT` (group focus), `SUPER + ALT + code:10..14` (group window N)
- `SUPER + mouse_up/down`, `SUPER + ALT + mouse_up/down`, `SUPER +
  mouse:272/273`
- All `SUPER + CTRL + …` utilities, panels and toggles except F, Q, SPACE and
  the ±300 resize keys `code:20/21` (moved above). That includes:
  - `SUPER + CTRL + 1..9` (bar panels)
  - `SUPER + CTRL + BACKSPACE`, `SUPER + CTRL + L` (lock)
  - `SUPER + CTRL + V` (clipboard manager), `SUPER + CTRL + E` (emoji)
  - `SUPER + CTRL + C` (capture menu)
- `SUPER + SHIFT + comma`, `SUPER + ALT + comma`, `SUPER + SHIFT + ALT + comma`,
  `SUPER + CTRL + comma`
- `SUPER + SHIFT + CTRL + SPACE/R/A`
- `SUPER + SHIFT + code:201` (Copilot key), `SUPER + ALT + K`, `SUPER + CTRL +
  K`
- `PRINT`, `ALT + PRINT`, `SUPER + PRINT`, `SUPER + CTRL + PRINT`
- All XF86 media, brightness and power keys, lid switches, and voxtype
  (`SUPER + CTRL + X`, `F9`)

---

## 7. Unmapped & limitations (living list)

| Item | Why | Workaround |
| --- | --- | --- |
| ⌃↑ Mission Control, ⌃↓ App Exposé | Hyprland has no built-in overview and Omarchy ships none. ⌃↑/↓ switch workspaces instead (1b) | ⌘\` cycles the active app's windows (Phase 4) |
| ⌘Tab as MRU *app* switcher | `cycle_next` cycles windows; there's no app grouping and no MRU overlay | ⌘\` for the same app's windows |
| ⌘⌥H hide others, ⌥⌘M minimize all | no simple equivalent | — |
| ⌘-click (open link in new tab, go to definition, multi-select) | compositor binds can't add Ctrl to a pointer click | physical ⌃-click (on a Mac, ⌃-click is right-click) |
| ⌥ + letter special characters (å ß ∂ …) | ⌥ stays Meta for terminals | Omarchy's compose key (Caps Lock) |
| Mac Home/End (scroll to document top/bottom) | Linux semantics kept | ⌘↑/⌘↓ |
| ⌘←/⌘→ as browser back/forward outside text fields | focus inside the page can't be detected | ⌘[ / ⌘] |
| Physical ⌃←/⌃→ word jump in Linux apps | ⌃←/→ now switch Spaces (as on a Mac) | ⌥←/⌥→ |
| Nautilus ⌘D duplicate, ⌘⇧⌫ empty trash, ⏎ to rename | no direct Nautilus action | F2 renames |
| Browser ⌘, (settings) | no Linux shortcut | pending 6b |

---

## 8. Testing & recovery

### 8.1 Test bench

- **`scripts/keylog.py`** (GTK4, nothing to install) is the test app. It has
  an editable sample text and logs every press, release and modifier change
  the app receives: keysym, keycode, modifiers, and the cursor and selection
  after the event. `--log FILE` also writes the log to a file. Its window class
  is `omackey.keylog`. (`wev` would also work, but needs installing.)
- **Automated handler tests** (no key presses): focus keylog with
  `hyprctl dispatch 'hl.dsp.focus({ window = "class:omackey.keylog" })'`,
  run `hyprctl repl 'return omackey.trigger("<id>")'`, then read the log.
  - Check focus in the same command: focus tends to jump back to VS Code
    between commands.
  - `omackey.fired("<id>")` counts real presses since the last reload.
  - `wtype` can't test binds: virtual-keyboard input never triggers Hyprland
    binds (§9 F1).
  - `keylog.py` is single-instance, so a second launch only focuses a running
    one and logs nothing (§9 F2 has a private-copy recipe).
- A plain text field:
  `data:text/html,<textarea autofocus style="width:100%;height:95vh"></textarea>`
  opened in Brave Origin and in Chromium.
- VS Code with a scratch file, and foot running bash.
- For Phase 6: Ghostty (`omarchy pkg add ghostty`), Google Chrome, Nautilus,
  Obsidian, LibreOffice Writer.
- Inspection commands:
  - `hyprctl binds`
  - `omarchy menu keybindings --print`
  - `scripts/check.sh` (from Phase 0)
- **Persian:** ask the user how they type Persian.
  - xkb: `kb_layout = "us,ir"` with `grp:alts_toggle` in
    `~/.config/hypr/input.lua`. That is the user's file, so ask before editing
    it.
  - fcitx5: the `keyboard-ir` input method.

### 8.2 Per-key protocol

The agent can't press keys, so the user runs steps 2–7 and reports back.

1. `hyprctl reload && hyprctl configerrors` is clean, and `scripts/check.sh`
   reports no duplicate binds.
2. In `scripts/keylog.py`, the app receives exactly the target key and
   modifiers: no SUPER/ALT leaking through, and exactly one press and release
   per tap.
3. Real apps: browser textarea, VS Code, foot+bash, plus the profiles the key
   touches.
4. Hold the key (repeating binds) and release: repeat stops immediately.
5. Press the chord 20× fast, then type normally: no stuck modifier or key.
6. (Deferred, D11.) With Persian active, repeat steps 2–3 for one GUI app and
   the terminal.
7. The help menu (SUPER+K until 1d, then ⌘?) finds the bind by its
   description. Relocated Omarchy binds show their new keys.
8. For WM and workspace items: repeat on both `dwindle` and `scrolling`.

### 8.3 Recovery

- **Key stuck or repeating:** press and release the same key, then
  `hyprctl reload`.
- **Config error:** check `hyprctl configerrors`. An error in a required module
  stops the rest of `hyprland.lua` from loading, including the user's own
  bindings. That's why the guarded loader in 0.2 matters.
- **Disable OMacKey:** run `./uninstall.sh`, or delete the marker lines in
  `~/.config/hypr/hyprland.lua` and run `hyprctl reload`. If the desktop is
  unusable, use a TTY (Ctrl+Alt+F3).
- **Stuck in a submap:** `hyprctl dispatch 'hl.dsp.submap("reset")'`.
- **Reset Omarchy's Hyprland config:** `omarchy refresh hyprland`. It makes a
  backup, but always ask the user first. It also removes the OMacKey lines, so
  `install.sh` has to be re-run.

---

## 9. Findings

Sessions append facts learned here: spike results, app quirks, surprises.

**F0 — Pre-spike facts (planning session, 2026-10-01)**

- **Help menu internals** (`omarchy-menu-keybindings`):
  - It parses `hyprctl binds`.
  - It also replays `~/.config/hypr/hyprland.lua` under system `lua` with a
    mocked `hl`, to recover keys and dispatchers for Lua binds. In the mock,
    only `bind`, `dsp` and `get_config` are real; everything else is a no-op.
  - Binds without a description whose dispatcher is `__lua` are hidden.
  - Unbound defaults disappear automatically, because the menu reads live
    binds.
- **Omarchy's universal clipboard** (`bindings/clipboard.lua`):
  - It uses `send_key_state` down, then a 50 ms timer for up, with no `window`,
    so the event reaches layer-shell surfaces too.
  - It chooses the terminal variant via the `terminal` tag.
  - It **discards the timer handle** (GC risk), and it sends Ctrl+X to
    terminals too.
- **r/omarchy "macOS like bindings" snippet** (agents can't fetch Reddit; the
  user pasted it):
  - Binds and sends by physical keycode (`code:N`, evdev+8), "so it keeps
    working under Cyrillic".
  - Keeps every timer handle in a `pending` table: "drop it and Lua collects
    the timer before it fires, the release never happens, and the key repeats
    forever".
  - Uses a 5 ms release, and `window = "activewindow"`.
  - Unbinds Omarchy's `SUPER + W/T/J/K/L/O/P/S/G/SLASH/X`, binds ⌘Q to close
    the window and ⌘L to lock, then forwards ⌘ + most letters to Ctrl in a
    loop. ⌘C, ⌘F and ⌘V are left to Omarchy.
- **`auto_consuming`** (Hyprland wiki, flags): the key passes to the window if
  the dispatcher fails. Signal failure with `return { ok = false }`.
- **Hyprland Lua rules:**
  - Bind handlers run on the compositor event loop and must not block: no
    `io.popen`, `wl-paste` or sleeps.
  - Conditions belong inside the bind function, not at load time.
  - `hl.unbind` is an exact, case-sensitive match and removes all earlier binds
    of that key.
  - Multiple binds on one key all fire, top to bottom.
- **`send_shortcut` stuck-key bug** (Hyprland discussion #14099) was reported
  from 0.54.3 through 0.56.0. Workaround: `send_key_state` down/up.
- **Scrolling layout** messages via `hl.dsp.layout("…")`: `focus l/r`,
  `colresize ±x / +conf`, `swapcol l/r`, `move ±col`, `consume`, `expel`,
  `promote`, `fit …`, `center`.
  - When a fullscreen window has focus, `hl.dsp.focus({direction})` looks for
    other monitors instead. Use the layout's `focus` message or
    `binds.movefocus_cycles_fullscreen`.
- **Browser classes:** Omarchy's `chromium-based-browser` tag regex covers
  `google-chrome`, `chromium`, `brave-browser`, Edge, Vivaldi and Helium. It
  does **not** cover `brave-origin` (the user's default browser). Open windows
  seen: `brave-origin`, `code`, `foot`.
- **Terminals:**
  - Omarchy's `foot.ini`: copy `Control+Insert`/`Control+Shift+c`, paste
    `Shift+Insert`/`Control+Shift+v`.
  - Omarchy's Ghostty config: `shift+insert` paste, `control+insert` copy, plus
    the Ghostty defaults.
  - `/etc/inputrc` binds `\e[1;5C`/`\e[1;5D` (Ctrl+Right/Left) to word motion.
- **Lua environment:**
  - System `lua` is 5.5.1, which the help-menu mock uses. In 5.5, for-loop
    control variables are read-only.
  - Keep the code 5.4/5.5-compatible. Hyprland's embedded version is
    unverified (S10).
  - Lua patterns have no `|` alternation.
- **Screenshot CLI:** `omarchy capture screenshot [smart|region|windows|fullscreen] [slurp|copy|save] [--editor=<name>]`.
- **Omarchy has no window switcher or overview.**
  `omarchy hyprland focus app <name>` exists.
- **Kinto ideas worth keeping:**
  - In VS Code and Firefox, releasing a bare Alt focuses the menu bar. Kinto
    sends Alt+F19 first; the alternatives are app settings.
  - ⌘. → Esc, except VS Code and terminals.
  - Terminal ⌘⌫ → Ctrl+U, ⌘⌦ → Ctrl+K.
  - Browser ⌘⌥I/J → devtools.
  - File-manager ⌘↑/↓/⌫ and ⌘⇧. (show hidden files).
- **Hardware:** NuPhy Air75 V2 (Mac/Win mode switch), Logitech G305, desktop
  PC with no trackpad or lid. Layout `us`; fcitx5 runs as
  `hl-virtual-keyboard-fcitx5`.

**F1 — Phase 0 spike results (2026-10-01)**

- **S10.** Hyprland embeds **Lua 5.5**, the same as the system `lua` used by the
  help-menu replay.
- **REPL.** `hyprctl repl '<lua>'` (and `hyprctl eval`) runs Lua in the live
  config state and prints the return values. This is the main tool for
  automated checks.
- **Reloads** create a fresh Lua state: globals are gone and `hl` is a new
  table. So there's no double-wrapping or leaking across reloads.
- **S7 (approach A works).**
  - `hl` is a plain table with no metatable, so `hl.bind` can be replaced.
  - The wrapped Omarchy bind registers as `CTRL ALT + LEFT → Focus on left
    window`, both live and in the help menu (whose mock `hl.bind` gets wrapped
    the same way).
  - After `load.init()`, `debug.getinfo(hl.bind).what == "C"`: the native
    function is back.
- **S8.** `omarchy menu keybindings --print` shows `SUPER + LEFT → Line start`
  and `CTRL ALT + LEFT → Focus on left window`.
- **S6 (partial).** `auto_consuming` is accepted although the type stubs don't
  list it: `hyprctl binds` shows the flag letters `bindead` (repeating,
  auto-consuming, described), and the returned `Keybind.auto_consuming` is
  `true`. Physical pass-through is still untested.
- **S1/S2/S3 (partial).** `omackey.trigger("line-start")` with keylog focused
  logged `press Home code=110 mods=-`, then `release` 20 ms later, and the
  cursor moved from column 12 to 0.
  - So keycode sending, `mods = ""`, the omitted `window`, and timer retention
    all work.
  - Not covered yet: a physically held ⌘, and layer-shell surfaces.
- **S11.** Input from `wtype`'s virtual keyboard **never triggers Hyprland
  binds**. A probe bind on ⌃⌥⌘⇧Y got 0 hits from
  `wtype -M logo -M ctrl -M alt -M shift -k y`.
  - wtype also uploads its own keymap: End arrived as keycode 9. So it can't
    test keycode-based sends either.
- **The `hyprctl binds` key field** holds just the key (`LEFT`); modifiers are
  in `modmask`. Flag letters follow `bind`.
- **install.sh pitfall:** `awk -v` processes backslash escapes, which broke the
  anchor regex. Pass regexes through `ENVIRON`.
- **S9.** No XWayland clients are running; retest when one is available.

**F2 — Phase 2 findings (2026-10-02)**

- **S5 (answered).** Releasing ⌥ after ⌥←/→ does not focus a menu bar.
  - VS Code: a bare ⌥ tap still highlights the menu (normal), and ⌥←/→ moves
    by word without it.
  - LibreOffice: fine.
  - Obsidian: word movement works, and a bare ⌥ does nothing at all. It shows
    no menu bar here (the user suspects Hyprland's missing window
    decorations), so there is nothing to focus.
  - Firefox (installed and tested later by the user): a bare ⌥ tap shows the
    menu, and ⌥←/→ moves by word without it.
  - Presumably the synthetic arrow between the physical ⌥ press and release
    counts as another key, which cancels the menu activation.
- **Synthetic keys with ⌥ held.** In keylog, `word-left` arrives as `Left`
  with `mods=CTRL` and no ALT, as explicit `mods` replace the held ⌥. The
  cursor moved by a word.
- **`ALT + LEFT/RIGHT` were free:** no Omarchy bind and no relocation used
  them.
- **keylog is single-instance** (GApplication id `omackey.keylog`). If one is
  already open (the user often leaves one), a second launch only focuses it
  and writes nothing to `--log`. For an automated test, run a private copy
  and focus it by pid:
  - `DBUS_SESSION_BUS_ADDRESS=disabled: scripts/keylog.py --log FILE &`
    (no session bus, so it doesn't forward to the running instance);
  - `hyprctl dispatch 'hl.dsp.focus({ window = "pid:<pid>" })'`;
  - check `hyprctl activewindow -j` for that pid right before each
    `omackey.trigger`, so stray keys can't land in another window.

---

## 10. References

| Reference | Use it for |
| --- | --- |
| Omarchy hotkeys manual: <https://omarchy.org/manual/hotkeys/> | human-readable defaults. The real source is `/usr/share/omarchy/default/hypr/bindings/*.lua` |
| Hyprland binds: <https://wiki.hypr.land/Configuring/Basics/Binds/> | bind syntax and flags. WebFetch truncates the rendered wiki, so fetch the raw markdown from `https://raw.githubusercontent.com/hyprwm/hyprland-wiki/main/content/configuring/` + `core/binds/_index.md`, `core/binds/flags.md`, `core/binds/submaps.md`, `core/binds/keyboard-layouts.md`, `core/dispatchers.md`, `layouts/scrolling-layout.md`, `layouts/dwindle-layout.md`, `core/advanced-configuration/lua-utilities.md` |
| Hyprland Lua API stubs: `/usr/share/hypr/stubs/hl.meta.lua` | authoritative function, option and event names for the installed version |
| Hyprland `send_shortcut` bug: <https://github.com/hyprwm/Hyprland/discussions/14099> | why the down/up timer pattern exists |
| Apple keyboard shortcuts: <https://support.apple.com/en-au/102650> | the Mac behaviour being mimicked |
| Kinto: <https://github.com/rbreaves/kinto/blob/master/linux/kinto.py> | per-app tables (browsers, file managers, VS Code Alt hack, terminal Ctrl+Shift conversions). Maximalist; borrow ideas only |
| xremap macOS config: <https://github.com/petrstepanov/gnome-macos-remap-wayland/blob/main/config.yml> | Nautilus mappings, terminal handling |
| Omarchy + keyd discussion: <https://github.com/omacom/omarchy/discussions/175> | the minimal "must work" set; terminal copy/paste pitfalls |
| r/omarchy "macOS like bindings": <https://www.reddit.com/r/omarchy/comments/1vyvd41/macos_like_bindings/> | keycodes, timer retention, Ctrl forwarding. Blocked for agents; summarized in F0 |
| Local Omarchy sources | `default/hypr/helpers.lua` (`o.*` helpers), `bindings/clipboard.lua`, `apps/terminals.lua`, `apps/browser.lua`, `bootstrap.lua`, `$(which omarchy-menu-keybindings)` |

---

## 11. Session log

Append one entry per session, newest last: date, what changed, test results,
and the next step.

- **2026-10-01 — Planning.**
  - Researched Omarchy 4.0.4 and Hyprland 0.56.2 bindings, the help-menu
    internals, the Lua API, and the references.
  - Confirmed with the user: ⌃⌥ for window management, ⌃⌥⌘ for launchers,
    curated-then-catch-all, the app scope (D10), and Persian support (D11).
  - Wrote PLAN.md and CLAUDE.md.
  - **Next:** Phase 0.1–0.3 (scaffold, installer, check script), then spikes
    S1–S11 with ⌘← as the first key.
- **2026-10-01 — Phase 0 build.**
  - Built the libraries, loader, relocation hook (approach A),
    install/uninstall, `check.sh` and `keylog.py`.
  - Tested install in a scratch HOME (including the help-menu replay), then
    installed live. `check.sh` is clean: `bindings=1 relocated=1`, no
    duplicates.
  - Live changes: ⌘← → Home; Omarchy's focus-left moved to ⌃⌥←.
  - Automated spikes done: S7, S8, S10, S11; S1/S2/S3/S6 partially (F1).
  - The user's physical tests all passed: ⌘← in keylog, Brave, VS Code and
    foot; repeat and rapid taps; ⌃⌥← focus; the pass-through probe; the help
    menu.
  - The Omarchy launcher has no cursor movement at all, so S3 is inconclusive
    for layer shell and is retested with ⌘C/⌘V in Phase 3.
  - The user deferred Persian testing (D11). Phase 0 is done.
  - **Next:** Phase 1a, relocating window management to ⌃⌥ (§6.1).
- **2026-10-01 — Phase 1a.**
  - Moved all of §6.1 into `relocations.lua`: 43 rows, all applied, no
    duplicates.
  - Deviation: Omarchy's ±25 px resize stays on ⌘⌥-/= (D9: no Mac
    collision) instead of being dropped.
  - The user tested every key on scrolling and dwindle; the help menu is
    updated.
  - **Next:** Phase 1b, Spaces on ⌃ (§6.2).
- **2026-10-02 — Phase 1b.**
  - Workspaces: 32 more relocations (⌃1–0, ⌃⇧1–0, ⌃⌥⇧1–0, Omarchy's
    SUPER+TAB pair). New `spaces.lua` with the vertical pair and the
    move-window-to-adjacent-workspace keys, via a new `action{}` helper.
  - D12 agreed: opt out of a default with `hl.unbind`; flags only for opt-in
    extras.
  - After first testing, the user switched to the **arrow rule**: arrows with
    ⌃ / ⌃⇧ focus and swap windows (taken from 1a's ⌃⌥ / ⌃⌥⇧), and arrows
    with ⌃⌥ / ⌃⌥⇧ handle workspaces. Numbers stay on ⌃.
  - The user retested on both layouts. 75 relocations, 7 bindings, no
    duplicates.
  - **Next:** Phase 1c, launchers → ⌃⌥⌘ (§6.3).
- **2026-10-02 — Phase 1c.**
  - 29 more relocations, 104 in total: launchers ⌘⇧/⌘⇧⌥ + letter → ⌃⌥⌘ /
    ⌃⌥⌘⇧ + the same letter; terminal ⌘⏎ → ⌃⌥⌘⏎.
  - The info popups time, battery, weather and calendar → ⌃⌘⇧ T/B/W/D. Time
    moved by the user's choice, to keep the group together.
  - New `optional = true` rows for conditional Omarchy binds. With
    preinstalled apps off: 85 applied, none reported unused.
  - Considered ⌃⌘⇧ for launchers instead: 2 clashes (Agent, Google
    Messages) and a spread-out grip. Kept ⌃⌥⌘.
  - Tested by the user.
  - **Next:** Phase 1d, utilities and help (§6.4): help → ⌘?, dismiss
    notification → ⌃⌘⇧, (changed from ⌃⌥, in 1d), calculator → ⌃⌥⌘Q,
    background switcher → ⌃⌥⌘Space.
- **2026-10-02 — Phase 1d. Phase 1 complete.**
  - 4 more relocations, 108 in total: keybindings help ⌘K → ⌘?; dismiss last
    notification ⌘, → ⌃⌘⇧, (the user's choice, so the notification family
    stays on ⌘ + comma); calculator ⌃⌘Q → ⌃⌥⌘Q; background switcher
    ⌃⌘Space → ⌃⌥⌘Space.
  - The sweep of the remaining ⌘ / ⌘⇧ / ⌘⌥ / ⌘⌥⇧ binds matches the "after
    Phase 1" list.
  - Tested by the user.
  - **Next:** Phase 2, cursor movement, selection and deletion. Starts with ⌘→
    and includes spike S5 (⌥ menu-bar focus) with the first ⌥ key.
- **2026-10-02 — Phase 2: ⌘→.**
  - Added `line-end` in `text.lua`: ⌘→ sends `End` in all apps, terminals
    included, `repeating`. `SUPER + RIGHT` was already free (focus right moved
    to ⌃→ in 1b). 8 bindings, 108 relocations, no duplicates.
  - Handler test in keylog: one `End` press and release, `mods=-`.
  - The user's physical tests (§8.2) passed.
  - **Next:** ⌘⇧←/→ (select to line start/end; consume in terminals), then the
    ⌥ word keys, which include spike S5.
- **2026-10-02 — Phase 2: ⌘⇧←/→.**
  - Added `select-line-start` / `select-line-end` in `text.lua`: `Shift+Home` /
    `Shift+End` in GUI apps, consumed in terminals, `repeating`. Both keys were
    free (swap window moved to ⌃⇧ in 1b). 10 bindings, 108 relocations, no
    duplicates.
  - No automated keylog run: the user's keylog instance was already open and
    the app is single-instance, so my copy only focused it.
  - The user's physical tests (§8.2) passed.
  - **Next:** ⌥←/→ (word left/right) and ⌥⇧←/→, which include spike S5.
- **2026-10-02 — Phase 2: ⌥←/→ and spike S5.**
  - Added `word-left` / `word-right` in `text.lua`: ⌥← / ⌥→ send `Ctrl+Left`
    / `Ctrl+Right` in all apps. Terminals use the same keys through
    `/etc/inputrc` (`backward-word` / `forward-word`). `repeating`.
    12 bindings, 108 relocations, no duplicates.
  - Handler test in a private keylog copy: `Left` / `Right` with `mods=CTRL`,
    no ALT; the cursor moved by a word.
  - The user's physical tests (§8.2) passed in keylog, Brave, VS Code, foot
    and LibreOffice, and Obsidian's word movement works.
  - **S5 answered:** no menu-bar workaround is needed (§9 F2). A bare ⌥ does
    nothing in Obsidian, which has no menu bar here. Firefox, tested afterwards by
    the user, is fine too.
  - **Next:** ⌥⇧←/→ (select word left/right; consume in terminals), then the
    ⌘↑/↓ document keys.
- **2026-10-02 — Phase 2: ⌥⇧←/→.**
  - Added `select-word-left` / `select-word-right` in `text.lua`:
    `Ctrl+Shift+Left` / `Ctrl+Shift+Right` in GUI apps, consumed in terminals,
    `repeating`. `ALT + SHIFT + LEFT/RIGHT` were free. 14 bindings, 108
    relocations, no duplicates.
  - Handler test in a private keylog copy: `mods=CTRL+SHIFT`, no ALT; the
    selection grew and shrank by word.
  - The user's physical tests (§8.2) passed. Firefox also passes S5 (§9 F2).
  - **Next:** ⌘↑/↓ and ⌘⇧↑/↓ (document start/end and selecting to them).
