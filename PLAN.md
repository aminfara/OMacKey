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
| 2 | Cursor movement, selection, deletion | [x] |
| 3 | Core editing (clipboard, undo/redo, select all, find, save) | [x] |
| 4 | Window & tab controls | [x] |
| 5 | OS controls (lock, screenshots, help, emoji, force quit) | [x] |
| 6 | App-specific: 6a terminals ✅ · 6b browsers ✅ · 6c VS Code ✅ (6c-2 ✅) · 6d Nautilus ✅ · 6e Obsidian ✅ · 6f LibreOffice ✅ | [x] |
| 7 | Catch-all ⌘→Ctrl & the rest: 7a ✅ · 7b ✅ · 7c ✅ · 7d ✅ · 7e skipped · 7f closed · 7g ✅ · 7h noted | [x] |
| 8 | Docs generator, README, maintenance tooling | [ ] |

**Order change (2026-10-05).** 7a, the catch-all, is built before 6c-2 and
6d–6f: those per-app audits become a diff against what the catch-all already
sends, instead of guessing which keys work. The rest of Phase 7 stays after
Phase 6.

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

**D13 — No minimize or hide (confirmed with the user, 2026-10-03).** ⌘M
(minimize), ⌘H (hide app), ⌘⌥H (hide others) and ⌥⌘M (minimize all) are not
mapped.
- Neither Omarchy nor Hyprland has minimize or hide: no bind or mention in
  Omarchy (bindings, manual), nothing in the Hyprland Lua API, only a wiki
  workaround that parks the window on a special workspace (§9 F7).
- There is no dock or taskbar to see or click minimized windows, so a hidden
  window is easy to lose, and tiling layouts re-flow around it. It is not
  natural on Omarchy.
- Omarchy's scratchpad is the native equivalent: ⌃⌥⇧S moves a window there
  and ⌃⌥S shows it (relocated in Phase 1a).
- Built and discarded in Phase 4: a `special:minimized` workspace, ⌘Tab
  bringing hidden apps back, and a ⌃⌥M view. Not worth the code.
- Phase 7a must consume ⌘M and ⌘H, not translate them to Ctrl+M / Ctrl+H.

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
│   │   (lib/mode.lua: Phase 7d on/off switch and its ⌃⌘⇧M bind)
│   ├── lib/
│   │   ├── keys.lua          key name → "code:N" (XKB keycode = evdev + 8)
│   │   ├── send.lua          tap(), seq() with retained timers
│   │   ├── apps.lua          active window → profile chain, e.g. { "terminal", "default" }
│   │   ├── bind.lua          mac{} helper: per-profile dispatch, auto_consuming, registry, press counter
│   │   ├── switcher.lua      ⌘Tab app switching (Phase 4): recency list from focus events, one session while ⌘ is held
│   │   └── relocate.lua      hl.bind hook/unhook + key normalization (approach A, 4.3)
│   ├── spaces.lua            Phase 1b: ⌃↑/↓ and ⌃⇧ arrows (workspaces), via action{}
│   ├── text.lua              Phase 2 (⌘← added in Phase 0.6)
│   ├── editing.lua           (Phase 3)
│   ├── windows.lua           (Phase 4)
│   ├── system.lua            (Phase 5)
│   ├── browsers.lua          Phase 6b: DevTools, history, downloads, bookmarks, clear data (Firefox entries sit on the keys they extend)
│   ├── nautilus.lua          Phase 6d: ⌘⇧. show hidden files (other Nautilus entries sit on the keys they extend)
│   ├── libreoffice.lua       Phase 6f: ⌘⌥V paste special (other LibreOffice entries sit on the keys they extend)
│   ├── obsidian.lua          Phase 6e: ⌘⇧U redo selection (other Obsidian entries sit on the keys they extend)
│   ├── vscode.lua            Phase 6c: multi-cursor, fold, replace, expand/shrink selection, quick fix (VS Code only)
│   ├── terminals.lua         Phase 6a: ⌘K clear, ⌘D / ⌘⇧D splits (other terminal entries sit on the keys they extend)
│   ├── apps/                 (Phase 6) profile overrides
│   └── catchall.lua          (Phase 7)
├── scripts/
│   ├── check.sh              reload, configerrors, omackey.status(), duplicate-bind detector, help-menu grep
│   ├── omackey-mode          Phase 7d: on / off / toggle / status from a terminal
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
- A `no-tabs` profile (empty at first) lists GUI window classes where ⌘W closes
  the window instead of sending `Ctrl+W`.

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
| S3 | Should we omit `window` (focused surface) or pass `window = "activewindow"`? Does text navigation work inside Omarchy's launcher/menu search field (layer shell)? | ✅ omitted `window` reaches normal windows. The Omarchy launcher's search field has no cursor movement at all (not even arrows or Home), so it can't show anything; not an OMacKey issue. Layer-shell delivery retested in Phase 3: ⌘V pastes into the launcher's search field ✅ |
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
- ⌘C/V/X (Omarchy's universal clipboard until Phase 3; replaced there)
- ⌘Home and ⌘⌥Home
- ⌘⇧, ⌘⌥, ⌘⇧⌥, (notifications), ⌘⌥Tab, ⌘⌥1–5 (groups), ⌘⌥-/= and
  ⌘⌥⇧-/= (±25 px resize)
- mouse binds (moved in Phase 7g, §6.6) and PRINT variants

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
| [x] | ⌘↑ | document start | `Ctrl+Home` | consume | 6a may map scrollback |
| [x] | ⌘↓ | document end | `Ctrl+End` | consume | |
| [x] | ⌘⇧↑ | select to doc start | `Ctrl+Shift+Home` | consume | |
| [x] | ⌘⇧↓ | select to doc end | `Ctrl+Shift+End` | consume | |
| [x] | ⌥⌫ | delete word left | `Ctrl+BackSpace` | pass | Alt+BackSpace is readline backward-kill-word |
| [x] | ⌥⌦ | delete word right | `Ctrl+Delete` | `Alt+d` | |
| [x] | ⌘⌫ | delete to line start | `seq(Shift+Home, BackSpace)` | `Ctrl+U` | Nautilus overrides this in 6d |
| [x] | ⌘⌦ | delete to line end | `seq(Shift+End, Delete)` | `Ctrl+K` | |

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
| [x] | ⌘C | copy | `Ctrl+C` | `Ctrl+Insert` (terminals and VS Code) | replaces Omarchy's universal copy (unbind `SUPER + C`); fixes the dropped timer handle. VS Code uses the terminal chord too, because Hyprland can't tell the editor from its integrated terminal (§9 F12) |
| [x] | ⌘V | paste | `Ctrl+V` | `Shift+Insert` (terminals and VS Code) | replaces Omarchy's universal paste. VS Code: same reason as ⌘C (§9 F12) |
| [x] | ⌘X | cut | `Ctrl+X` | consume | Omarchy currently sends Ctrl+X to terminals as well |
| [x] | ⌘⇧V | paste plain | `Ctrl+Shift+V` | `Shift+Insert` | LibreOffice override in 6f |
| [x] | ⌘Z | undo | `Ctrl+Z` | consume | never send Ctrl+Z to a terminal |
| [x] | ⌘⇧Z | redo | `Ctrl+Shift+Z` | consume | LibreOffice → `Ctrl+Y` (6f) |
| [x] | ⌘A | select all | `Ctrl+A` | consume | Ghostty select-all in 6a |
| [x] | ⌘F | find | `Ctrl+F` | consume | terminal search in 6a |
| [x] | ⌘G | find next | `F3` | consume | F3 works in Chromium, Firefox, VS Code and GTK. LibreOffice: F3 is AutoText, so override in 6f |
| [x] | ⌘⇧G | find previous | `Shift+F3` | consume | Nautilus: go to location (6d) |
| [x] | ⌘S | save | `Ctrl+S` | consume | |
| [x] | ⌘⇧S | save as | `Ctrl+Shift+S` | consume | |
| [x] | ⌘B / ⌘I / ⌘U | bold / italic / underline | `Ctrl+B/I/U` | consume | |
| [x] | ⌘/ | toggle comment | `Ctrl+/` | consume | |

Acceptance extra: ⌘C/⌘V also work inside Omarchy's menus (layer shell, see
S3) and the clipboard manager (⌃⌘V) is unaffected.

### Phase 4 — Window & tab controls

| ✓ | Mac | Meaning | GUI apps | Term | Notes |
| --- | --- | --- | --- | --- | --- |
| [x] | ⌘W | close tab / window | `Ctrl+W` | `hl:close` in every terminal (foot, Alacritty, Omarchy TUIs); Ghostty/kitty `Ctrl+Shift+W` (done in 6a) | `no-tabs` profile in `config.lua` (empty): ⌘W → `hl:close` for the classes listed there, grown from findings. VS Code with no editor open ignores ⌘W (§7) |
| [x] | ⌘⇧W | close window | `hl:close` in every app | `hl:close` | one action everywhere: the compositor close ends in the same path as an app's own shortcut, so the planned `Ctrl+Shift+W` for browsers/VS Code (and a VS Code profile) wasn't needed |
| [x] | ⌘Q | quit app | close every window of the active class (`hl.get_windows`, then close each) | same | Mac semantics: all windows of the app, no confirmation (foot has no close prompt). Apps with unsaved work still ask |
| [x] | ⌘N | new window | `Ctrl+N` | `Ctrl+Shift+N` | |
| [x] | ⌘⇧N | new folder / private window | `Ctrl+Shift+N` | consume | Firefox → `Ctrl+Shift+P` (6b) |
| [x] | ⌘T | new tab | `Ctrl+T` | `Ctrl+Shift+N` (new window) in every terminal; Ghostty/kitty `Ctrl+Shift+T` (done in 6a) | |
| [x] | ⌘⇧T | reopen closed tab | `Ctrl+Shift+T` | consume | |
| [x] | ⌘O / ⌘P / ⌘R / ⌘L | open / print or quick-open / reload / location | `Ctrl+O/P/R/L` | consume | ids `open`, `print`, `reload`, `location`; Omarchy's O/P/L were relocated in Phase 1a |
| [x] | ⌘1–⌘9 | tab N | `Ctrl+1–9` | Ghostty `Alt+1–9` (6a); else consume | ids `tab-1`…`tab-9`, a loop over digits (like `spaces.lua`) with its own `actions` table. ⌘9 is the last tab in browsers. The synthetic `Ctrl+N` does not trigger the physical ⌃N workspace binds. VS Code: ⌘N focuses editor group N, as on a Mac (§9 F5). Nautilus keeps `Ctrl+N` until 6d: ⌘1 is list view and ⌘2 grid view, the reverse of Finder, and ⌘3–9 do nothing |
| [x] | ⌘= ⌘+ ⌘- ⌘0 | zoom in / in / out / reset | `Ctrl+equal`, `Ctrl+equal`, `Ctrl+minus`, `Ctrl+0` | same (foot and Ghostty font size) | ids `zoom-in` (`SUPER + equal`), `zoom-in-plus` (`SUPER + SHIFT + equal`), `zoom-out`, `zoom-reset`. Descriptions end in "(app)" so the help menu tells them from Omarchy's desktop zoom (⌃⌘Z). Not `repeating` |
| [x] | ⌘[ / ⌘] | back / forward (browser, files); outdent / indent (editors) | default `Ctrl+[` / `Ctrl+]`; browser & Nautilus profiles `Alt+Left/Right` | consume | ids `back`, `forward`. New `nautilus` profile (class `org.gnome.Nautilus`) in `config.lua`; 6d adds its other overrides. Descriptions have no comma: the help menu cuts them there |
| [x] | ⌘⇧[ / ⌘⇧] | previous / next tab | `Ctrl+Page_Up` / `Ctrl+Page_Down` | consume (Ghostty and kitty done in 6a) | ids `previous-tab`, `next-tab` |
| [x] | ⌘⌥← / ⌘⌥→ | previous / next tab | `Ctrl+Page_Up` / `Ctrl+Page_Down` | consume (Ghostty and kitty done in 6a) | ids `previous-tab-arrow`, `next-tab-arrow`. Obsidian: back/forward (6e) |
| [x] | ⌘Tab / ⌘⇧Tab | switch app (most recently used) | ⌘Tab: next app in recency order, so a tap flips between the last two apps; pressing it again while ⌘ is held steps deeper. ⌘⇧Tab steps back (from the front app: the app used longest ago). Each stop focuses that app's latest window, crossing workspaces | same | ids `switch-app`, `switch-app-back`. An app is a window class, as in ⌘Q. The session ends when ⌘ is released, or when focus moves to another app (§9 F6). Code in `lib/switcher.lua`. No overlay (§7). Changed from the plan's window cycling at the user's request |
| [x] | ⌘\` / ⌘⇧\` | cycle the active app's windows | windows of the active class on every workspace, ordered by `stable_id`, focus next / previous (wraps) | same | ids `next-app-window`, `previous-app-window`. Fixed ring, not recency. A one-window app does nothing |
| [-] | ⌘M | minimize | not mapped (D13) | same | Hyprland and Omarchy have no minimize and there is no dock to restore from. Use Omarchy's scratchpad (⌃⌥⇧S moves a window in, ⌃⌥S shows it). Consumed once the catch-all exists (7a) |
| [-] | ⌘H | hide app | not mapped (D13) | same | as ⌘M; ⌘⌥H (hide others) is unmapped too |
| [x] | ⌘, | preferences | `Ctrl+comma` | consume | id `preferences`. VS Code, Obsidian and Nautilus open their settings on `Ctrl+,`. Browsers and LibreOffice have no such shortcut (6b, 6f); Ghostty's open-config `Ctrl+comma` comes in 6a. Omarchy's dismiss-last-notification left ⌘, in 1d |

`[-]` marks a key deliberately left unmapped (§7).

Phase 4 is complete (2026-10-03). What it left for later is already in the 6a–6f
tables below, §7 and 7a (§11 has the list).

### Phase 5 — OS controls

| ✓ | Mac | Meaning | Action | Notes |
| --- | --- | --- | --- | --- |
| [x] | ⌘Space | Spotlight | Omarchy launcher, `SUPER + SPACE` (unchanged) | already Mac-like, verify only |
| [x] | ⌘⌥Space | Finder search | Omarchy apps menu (unchanged) | verified by the user, 2026-10-03 |
| [x] | ⌃⌘Q | lock screen | `omarchy-system-lock` | id `lock-screen` in `system.lua`. The calculator moved off ⌃⌘Q in 1d; ⌃⌘L still locks too |
| [-] | ⌘⇧Q | log out | not mapped (user's choice, 2026-10-03): the system menu is not an instant logout and ⌘Esc already opens it | Ctrl+Shift+Q quits Chrome on Linux, so the catch-all must never send it, and consumes ⌘⇧Q (7a) |
| [x] | ⌘⌥Esc | force quit | `hl.dsp.window.kill()` on the active window | Mac shows a dialog; this kills directly. Confirmed with the user (2026-10-03): map it, direct kill. id `force-quit`, `SUPER + ALT + ESCAPE` |
| [x] | ⌘⇧3 | screenshot of screen to file | `omarchy-capture-screenshot fullscreen save` | id `screenshot-screen-file`, key `SUPER + SHIFT + code:12`. Focused monitor only, file only (§9 F8). Relies on 1b having moved ⌘⇧1–0 |
| [x] | ⌃⌘⇧3 | screen to clipboard | `omarchy-capture-screenshot fullscreen copy` | id `screenshot-screen-clipboard` |
| [x] | ⌘⇧4 | region to file | `omarchy-capture-screenshot region save` | id `screenshot-region-file`, `SUPER + SHIFT + code:13`. Omarchy's picker: ⏎ captures the window under the cursor, ≈ Mac's Space |
| [x] | ⌃⌘⇧4 | region to clipboard | `omarchy-capture-screenshot region copy` | id `screenshot-region-clipboard` |
| [x] | ⌘⇧5 | capture menu | `omarchy-menu toggle capture` | id `capture-menu`, `SUPER + SHIFT + code:14`. Also covers screen recording; Omarchy's own `SUPER + CTRL + C` opens the same menu |
| [x] | ⌘? (⌘⇧/) | help | `omarchy-menu-keybindings` | added in 1d, verify here |
| [x] | ⌃⌘Space | emoji & symbols | `omarchy-shell shell toggle omarchy.emojis` | id `emoji-picker`. The background switcher moved off ⌃⌘Space in 1d; Omarchy's ⌃⌘E opens the same picker |
| [x] | ⌥⌘D | show/hide Dock | `omarchy-toggle-bar` (top bar) | id `toggle-bar`, `SUPER + ALT + D`. ⌘⇧Space still works |
| [x] | ⌃⌘F | full screen | moved in 1a, verify only | verified by the user, 2026-10-03 |
| [x] | F-row in Mac mode | brightness / volume / media | Omarchy's XF86 binds (unchanged) | keysyms found with a key-event probe (§9 F9). F6 Do Not Disturb → Omarchy's silencing toggle (id `do-not-disturb`); F5 Dictation is push-to-talk like Omarchy's F9 (ids `dictation-start`, and `dictation-stop` on release) and ⇧F5 toggles (`dictation-toggle`), all only when voxtype is installed (user's choice); F3 Mission Control (`XF86LaunchA`) left unbound (§7). F4 sends ⌘Space (Spotlight) |

### Phase 6 — App-specific

One sub-phase per session. Every value marked "verify" must be checked against
the app's own Linux keybindings before implementing. Record app quirks in §9.

**6a — Terminals** (foot, Ghostty and kitty; Alacritty and the Omarchy TUIs use
the generic terminal rules) — done 2026-10-03

Scope confirmed with the user: kitty is included (D10 widened: it is installed
and in use, and Phase 4's zoom keys did not reach it); ⌘↑/⌘↓ jump prompts in
Ghostty and scroll a page elsewhere; ⌘K clears the screen; no edits to the
terminals' config files. Profiles `ghostty`, `kitty` and `foot` in
`config.lua`, each with family `terminal`. Keys were checked against each
terminal's real defaults (§9 F10). `—` means the generic terminal action is
used.

| Mac | foot | Ghostty | kitty | generic terminal |
| --- | --- | --- | --- | --- |
| ⌘T | — | `Ctrl+Shift+T` | `Ctrl+Shift+T` | `Ctrl+Shift+N` (new window) |
| ⌘N | — | — | — | `Ctrl+Shift+N` |
| ⌘W | — | `Ctrl+Shift+W` | `Ctrl+Shift+W` | `hl:close` |
| ⌘1–9 | — | `Alt+1–9` (⌘9 last tab) | — | consume (kitty has no key for tab N) |
| ⌘⇧[ ⌘⇧] / ⌘⌥← ⌘⌥→ | — | `Ctrl+Page_Up/Down` | `Ctrl+Shift+Left/Right` | consume |
| ⌘F | `Ctrl+Shift+R` | `Ctrl+Shift+F` | `Ctrl+Shift+/` | consume |
| ⌘G / ⌘⇧G | — | — | — | consume (§9 F10) |
| ⌘A | — | `Ctrl+Shift+A` | — | consume |
| ⌘K (new) | — | — | — | `Ctrl+L` |
| ⌘D / ⌘⇧D (new) | — | `Ctrl+Shift+O` / `Ctrl+Shift+E` | — | consume |
| ⌘↑ / ⌘↓ | — | `Ctrl+Shift+Page_Up/Down` (previous / next prompt) | `Ctrl+Shift+Page_Up/Down` (scroll page) | `Shift+Page_Up/Down` (scroll page) |
| ⌘, | — | `omarchy-launch-editor ~/.config/ghostty/config` (Ghostty's own `Ctrl+comma` shows nothing here, §9 F10) | `Ctrl+Shift+F2` (edit config) | consume |
| ⌘= ⌘+ ⌘- ⌘0 | — | — (`Ctrl+=` …) | `Ctrl+Shift+=` / `-` / `BackSpace` | — (`Ctrl+=` …) |
| ⌘. (interrupt) | `Ctrl+C` | `Ctrl+C` | `Ctrl+C` | `Ctrl+C` (7b) |

- [x] Profiles `ghostty`, `kitty`, `foot` (`config.lua`).
- [x] Entries on existing keys: ⌘T, ⌘W, ⌘1–9, tab switching (`windows.lua`);
  ⌘F, ⌘A (`editing.lua`); ⌘↑, ⌘↓ (`text.lua`); zoom and ⌘, (`windows.lua`).
- [x] New module `terminals.lua`: ⌘K, ⌘D, ⌘⇧D.
- [x] Physical tests by the user (§8.2) in foot, Ghostty and kitty passed.

tmux: Hyprland can't tell that tmux is running, so tmux is treated as a plain
terminal (confirmed as the default).

**6b — Browsers** (Brave, Brave Origin `brave-origin`, Chromium, Google Chrome;
Firefox best-effort) — done 2026-10-04

Scope confirmed with the user: ⌘⇧⌫ is added (not in the original plan);
Firefox follows the Chrome habit for ⌘⇧J; ⌘, is Firefox-only. New profile
`firefox` (family `browser`) in `config.lua`; new module `browsers.lua`. Keys
checked against Chrome's own Mac/Linux shortcut page and Firefox's DevTools
docs (§9 F11). ⌘[ / ⌘] were done in Phase 4.

| Mac | Chromium family | Firefox | Notes |
| --- | --- | --- | --- |
| ⌘⌥I | `Ctrl+Shift+I` | same | every GUI app (Obsidian toggles DevTools on it too); terminals and VS Code consume (VS Code: Format Document owns that key, §9 F11). id `devtools` |
| ⌘⌥J | `Ctrl+Shift+J` | same (Browser Console) | console. id `devtools-console` |
| ⌘⌥C | `Ctrl+Shift+C` | same | inspect element. id `devtools-inspect` |
| ⌘⌥U | `Ctrl+U` | same | view source. id `view-source` |
| ⌘Y | `Ctrl+H` | same | history. id `history` |
| ⌘⇧J | `Ctrl+J` | `Ctrl+Shift+Y` | downloads; Firefox follows Chrome's key (user's choice). id `downloads` |
| ⌘⌥B | `Ctrl+Shift+O` | same | bookmark manager. id `bookmark-manager` |
| ⌘⇧⌫ | `Ctrl+Shift+Delete` | same | clear browsing data (opens a dialog, deletes nothing until confirmed). id `clear-browsing-data` |
| ⌘⇧N | `Ctrl+Shift+N` | `Ctrl+Shift+P` | private window (Phase 4's key, new Firefox entry) |
| ⌘, | generic `Ctrl+,` | runs `firefox about:preferences` | Chromium family: no settings shortcut and the CLI route fails (§7, §9 F11) |
| ⌘←/→ outside text fields | not emulated (Mac: back/forward) | | §7 |

- [x] Profile `firefox`, module `browsers.lua`, Firefox entries on ⌘⇧N and ⌘,
  (`windows.lua`).
- [-] ⌘⌥K (Firefox web console): Omarchy's tmux-keybindings bind owns
  `SUPER + ALT + K` (§6.5); not worth a relocation.
- [x] Physical tests by the user (§8.2) in Brave Origin, Chromium, Firefox and
  Obsidian passed. VS Code ⌘⌥I did nothing: fixed, see F11.
- [x] Profile `vscode` (`config.lua`), created here because ⌘⌥I needs it; 6c
  adds the VS Code entries.

**6c — VS Code** (class `com.microsoft.VSCode` on this machine, native
Wayland; also `code`, `code-oss` / `Code` elsewhere) — done 2026-10-05

Linux VS Code defaults mostly mirror the Mac ones with Ctrl in place of ⌘, so
the generic rules cover most of it. Chords were read from the installed
`workbench.desktop.main.js` (§9 F13). Scope confirmed with the user: column
select dropped, ⌘0 mapped, physical ⌃- / ⌃⇧- not mapped. New module
`vscode.lua` (ids in the table); ⌘0 sits on `zoom-reset` in `windows.lua`.

| Mac | Action | Notes |
| --- | --- | --- |
| ⌘⌥↑ / ⌘⌥↓ | `Ctrl+Shift+Up/Down` | add cursor above/below (Linux's secondary key; its primary is `Shift+Alt+Up`). ids `add-cursor-above`, `add-cursor-below`, `repeating` |
| ⌘⌥[ / ⌘⌥] | `Ctrl+Shift+[` / `Ctrl+Shift+]` | fold / unfold. ids `fold`, `unfold`. Webcam keys moved in 1a |
| ⌘⌥F | `Ctrl+H` | replace. id `replace`. Omarchy's "Full width" moved in 1a |
| ⌃⇧⌘← / → | `Shift+Alt+Left/Right` | shrink / expand selection. ids `shrink-selection`, `expand-selection`, `repeating` |
| ⌘. | `Ctrl+period` | quick fix. Now the `vscode` action of the generic `cancel` entry (7b, `editing.lua`); the id `quick-fix` is gone |
| ⌘0 | `Ctrl+KP_0` (numpad 0) | reset zoom; VS Code has no `Ctrl+0` default for it (§9 F4). `kp_0` (keycode 90) added to `lib/keys.lua` |
| ⌘K chords, ⌘P, ⌘⇧P, ⌘D, ⌘⇧L, ⌘⇧K, ⌘⏎, ⌘B, ⌘J, ⌘\\ | generic Ctrl translation (Phases 3, 4, 7) | verify chords: ⌘K ⌘S → Ctrl+K Ctrl+S (7a) |
| ⌘C / ⌘V | `Ctrl+Insert` / `Shift+Insert` | done in `editing.lua` (profile `vscode`): both work in the editor and in the integrated terminal (§9 F12) |
| ⌃Space suggest | physical Ctrl+Space | fcitx5's default trigger is Ctrl+Space and may eat it. Documentation only (8.2) |
| ⌥ menu focus | none needed | S5 passed for ⌥←/→ (§9 F2). Recheck only if another ⌥ chord shows the problem |

- [-] ⌘⇧⌥ arrows (column select): dropped, §7 and §9 F13.
- [-] Physical ⌃- / ⌃⇧- (navigate back/forward): not mapped (user's choice,
  it would intercept physical Ctrl in one app). Opt-out is not needed; opt in
  with a `bindings.lua` bind if wanted.
- [x] Handler tests and `scripts/check.sh` clean.
- [x] Physical tests by the user (§8.2) in VS Code passed: ⌘⌥↑/↓, ⌘⌥[ / ], ⌘⌥F,
  ⌃⇧⌘←/→, ⌘., ⌘0.

**6c-2 — VS Code Mac keymap audit** (done 2026-10-05, after 7a)

Method (§9 F15): every keybinding registered in the installed
`workbench.desktop.main.js` (about 1,100) was extracted with its `primary`,
`mac` and `linux` chords and diffed two ways: Mac ⌘ chords against the Ctrl
chord the catch-all sends, and Mac chords without ⌘ (⌥, ⌃, ⇧) against the same
physical chord on Linux.

- [x] ⌘ chords with the same key on Linux (476 of 591): covered by the
  catch-all or by an explicit entry (⌘K chords, ⌘D, ⌘P, ⌘⇧P, ⌘B, ⌘J, ⌘⏎, ⌘⇧E / F /
  X / M / L / K, ⌘\\ …). The audit found that keys another module claimed for
  some apps only (⌘K, ⌘D, ⌘⇧D, ⌘Y, ⌘⇧J, ⌘.) got no action elsewhere, so VS Code
  received the raw ⌘ chord: fixed in `catchall.lua`, which now gives those specs
  the default (§9 F14).
- [x] Differences added to `vscode.lua` (user's choices): `copy-line-up` /
  `copy-line-down` (⌥⇧↑ / ⌥⇧↓ → `Ctrl+Shift+Alt+Up/Down`; the plain Linux
  chord adds a cursor), `block-comment` (⌥⇧A → `Ctrl+Shift+A`),
  `zoom-out-shifted` (⌘⇧- → `Ctrl+minus`), `find-whole-word` / `find-regex` /
  `find-in-selection` / `find-preserve-case` (⌘⌥W / R / L / P → `Alt+W/R/L/P`).
  ⌘⌥C (match case, `Alt+C`) and ⌘⌥B (secondary side bar, `Ctrl+Alt+B`) are
  `vscode` actions on the existing `devtools-inspect` and `bookmark-manager`
  entries in `browsers.lua`. ⌘E stays `Ctrl+E` (Quick Open; the Mac key has no
  Linux counterpart).
- [x] Handler tests (keylog copy with its class in the `vscode` profile): all
  ten new entries sent the right chord; ⌘K, ⌘D, ⌘⇧D, ⌘Y, ⌘⇧J, ⌘. sent
  `Ctrl` / `Ctrl+Shift` chords after the catch-all fix.
- [-] Left alone, §7: ⌘↑ / ⌘↓ in lists, other ⌘⌥ + key and ⌘ + F-key chords,
  Emacs ⌃ keys (7c).
- [x] Physical tests by the user (§8.2) in VS Code passed (⌘K ⌘S, ⌘D, ⌘⇧E, ⌘B,
  ⌘J, ⌥⇧↑ / ↓, ⌥⇧A, ⌘⇧-, ⌘⌥W / R / C / L / P, ⌘⌥B): "works similar to Mac".

**6d — Nautilus** (`org.gnome.Nautilus`, 50.3.1; ideas from Kinto and xremap) —
done 2026-10-05

Profile `nautilus` already existed (Phase 4). Entries sit on the keys they
extend; only ⌘⇧. is new (`nautilus.lua`, id `show-hidden-files`).

| Mac | Action | Where |
| --- | --- | --- |
| ⌘↑ | `Alt+Up` (parent folder) | `document-start` |
| ⌘↓ | `Return` (open selection) | `document-end` |
| ⌘⌫ | `Delete` (move to trash; overrides the line delete) | `delete-line-start` |
| ⌘⇧. | `Ctrl+H` (hidden files) | new `show-hidden-files` |
| ⌘⇧G | `Ctrl+L` (go to location) | `find-previous` |
| ⌘[ / ⌘] | `Alt+Left/Right` | Phase 4 |
| ⌘1 / ⌘2 | `Ctrl+2` (icons) / `Ctrl+1` (list): Nautilus's views are the reverse of Finder's (§9 F5) | `tab-1`, `tab-2` |
| ⌘3–⌘9 | consume (no such views or tab keys) | `tab-3`…`tab-9` |
| ⌘I | properties: the generic `Ctrl+I` already opens it, no entry needed | `italic` |
| ⌘D, ⌘⇧⌫, ⏎-to-rename | unmapped (§7); ⌘D reaches Nautilus as `Ctrl+D` (add bookmark) via the catch-all | |

- [x] Handler tests on a throwaway Nautilus (own D-Bus, scratch folder, pid
  guard): ⌘↑ went to the parent, ⌘↓ opened the folder again, ⌘⇧G opened the
  location bar, ⌘1 / ⌘2 switched to icon / list view, ⌘3 sent nothing, ⌘I
  opened the Properties dialog. Closed afterwards, scratch folder removed.
- [x] ⌘⇧. confirmed by the user's physical test: it toggles hidden files, like
  physical ⌃H. The throwaway instance did not show dotfiles after `Ctrl+H`
  (likely it does not keep the setting), so a handler test can't confirm this
  key.
- [x] Physical tests by the user (§8.2) in Nautilus passed: ⌘↓ / ⌘↑, ⌘⇧., ⌘⇧G,
  ⌘1 / ⌘2 / ⌘3, ⌘I, ⌘⌫ (moved a file to the trash), ⌘[ / ⌘], rapid presses.

**6e — Obsidian** (class `md.obsidian.Obsidian` here, `obsidian` elsewhere;
Electron, 1.13.7) — done 2026-10-05

Chords read from the installed `app.js` (§9 F16). Obsidian's hotkeys use "Mod"
(Ctrl on Linux), so ⌘ → Ctrl already covers them; these are the ones that differ.
New profile `obsidian` (`config.lua`); entries sit on existing keys, plus new
`obsidian.lua`.

| Mac | Action | Where |
| --- | --- | --- |
| ⌘⌥← / ⌘⌥→ | `Ctrl+Alt+Left/Right` (navigate back / forward; overrides the tab-switch rule) | `previous-tab-arrow`, `next-tab-arrow` |
| ⌘⌥↑ / ⌘⌥↓ | `Ctrl+Alt+Up/Down` (add cursor above / below) | `add-cursor-above/below` |
| ⌘⌥[ / ⌘⌥] | not mapped: Obsidian has no default fold hotkey on either platform (§9 F16) | |
| ⌘⌥F | `Ctrl+H` (search and replace) | `replace` |
| ⌘⇧U | `Alt+U` (redo selection; Linux's chord for it) | new `redo-selection` |
| ⌘⇧[ / ⌘⇧] | `Ctrl+Page_Up/Down`, generic (Obsidian's own Linux keys) | |
| ⌘P, ⌘O, ⌘E, ⌘, ⌘⇧F, ⌘K, ⌘N, ⌘T, ⌘W, ⌘⇧W, ⌘1–9, ⌘G, ⌘⇧G … | generic (all "Mod" hotkeys; `F3` is Obsidian's find-next too) | |
| ⌘U | nothing to fix: undo selection (CodeMirror `Mod-u`) on both platforms | |

- [x] The ⌘U "oddity" from Phase 3 is not one: ⌘U is undo-selection on the Mac
  as well, and the user saw the cursor jump back.
- [x] ⌥ menu focus: checked in Phase 2 (S5), nothing to work around.
- [x] Handler tests in a private keylog copy matched to the `obsidian` profile:
  `Left` / `Right` / `Up` / `Down` with `CTRL+ALT`, `[` / `]` with `CTRL+SHIFT`,
  `h` with `CTRL`, `u` with `ALT`.
- [x] Physical tests by the user (§8.2) in Obsidian passed: ⌘⌥← / ⌘⌥→ (within one
  tab's history), ⌘⌥↑ / ↓, ⌘⌥F, ⌘U / ⌘⇧U, rapid presses. ⌘⌥[ / ⌘⌥] did nothing, and
  neither did a physical `Ctrl+Shift+[`: the entries were removed.

**6f — LibreOffice** (classes `libreoffice-writer`, `-calc`, `-impress`, `-draw`,
`-math`, `-base`, `-startcenter`, and `soffice` for its dialogs; 26.8.0) — done
2026-10-05

Chords read from the installed registry (`share/registry/main.xcd`, §9 F17).
New profile `libreoffice` (`config.lua`); entries sit on existing keys, plus new
`libreoffice.lua`.

| Mac | Action | Where |
| --- | --- | --- |
| ⌘⇧Z | generic `Ctrl+Shift+Z`: it is already Redo in LibreOffice, so the planned `Ctrl+Y` override is not needed | `redo` |
| ⌘, | `Alt+F12` (Tools > Options) | `preferences` |
| ⌘G | `Ctrl+Shift+F` (Repeat Search, Writer and Calc; the generic `F3` is AutoText there) | `find-next` |
| ⌘⇧G | consume: the generic `Shift+F3` changes case, and no key finds the previous match (§7) | `find-previous` |
| ⌘⇧V | `Ctrl+Alt+Shift+V` (paste unformatted text; `Ctrl+Shift+V` is the Paste Special dialog) | `paste-plain` |
| ⌘⌥V | `Ctrl+Shift+V` (Paste Special dialog) | new `paste-special` |
| ⌥ menu focus | checked in Phase 2 (S5): ⌥←/→ move by word without focusing the menu | |

- [x] Handler tests in a private keylog copy matched to the profile: `F` with
  `CTRL+SHIFT`, `V` with `CTRL+ALT+SHIFT` and `CTRL+SHIFT`, `F12` with `ALT`;
  ⌘⇧G sent nothing.
- [x] Tests on a throwaway Writer (own profile, scratch file, address guard):
  ⌘, opened Options, ⌘X / ⌘Z / ⌘⇧Z cut, restored and cut again (redo works with
  the generic chord), ⌘⌥V opened the Paste Special dialog, ⌘⇧V pasted without
  the dialog. ⌘G was not driven (needs a search term typed in; chord checked in
  keylog). The test put its sample text on the user's clipboard.
- [x] Physical tests by the user (§8.2) in LibreOffice passed (all keys above).

### Phase 7 — Catch-all & the rest

- [x] **7a Catch-all** (2026-10-05). New `catchall.lua`, last in
  `config.modules`: every ⌘ / ⌘⇧ + letter or `` ` - = [ ] \ ; ' , . / `` or ⏎
  that no other module and no Omarchy default claimed sends `Ctrl` /
  `Ctrl+Shift` + the same key (by keycode). Digits: ⌘1–⌘9 and ⌘0 are
  claimed; ⌘⇧ digits are not covered (⌘⇧3/4/5 are screenshots).
  - **How "claimed" is known.** `lib/relocate.lua` records every key Omarchy
    registers while it wraps `hl.bind` (`relocate.claimed`, after relocation);
    the registry has OMacKey's own. `hl` has no way to list binds at load time.
    A key the user rebinds in `bindings.lua` still wins (loads later).
  - **Terminals:** consume (user's choice, D5), not pass-through.
  - **Consumed everywhere, nothing sent** (ids show "not mapped" in the help
    menu): ⌘H, ⌘M (D13), ⌘⇧Q (Phase 5), and, by the user's choice, ⌘⇧I
    (Format Document in VS Code), ⌘⇧U (Unicode input in GTK / fcitx5) and ⌘⇧H.
  - **Help menu:** each bind has a short description, "⌘E sent as Ctrl+E"
    (user's choice; about 30 more lines). Ids are `catchall-<glyph><key>`,
    category "Catch-all".
  - Reviewed risky outcomes: ⌘J (Ctrl+J: VS Code panel, browser downloads),
    ⌘E, ⌘⇧X (VS Code extensions) and ⌘⏎ (`Ctrl+Return`) are translated.
  - Free keys at the time: ⌘ E H J M \ ; ' ⏎; ⌘⇧ A B C E F H I K L M O P Q R
    U X Y - . \ ; ' ⏎ (the rest were already claimed, §9 F14).
- [x] **7b** ⌘. (2026-10-05). id `cancel` in `editing.lua`: `Escape` in GUI apps,
  `Ctrl+C` in every terminal (interrupt, like Terminal.app), `Ctrl+period` in VS
  Code (quick fix; it replaces the `quick-fix` entry in `vscode.lua`). Not
  `repeating`. Handler tests in a private keylog copy: `Escape`, `c` with `CTRL`
  (terminal profile), `period` with `CTRL` (vscode profile).
- [x] **7c** Emacs-style ⌃ keys (2026-10-05). New `emacs.lua`, controlled by the
  `emacs_keys` flag in `config.lua` (D12: a flag because it takes ⌃A / ⌃F / ⌃H …
  away from GUI apps; **on by default at the user's request**, `false` binds
  nothing; reload after changing it). Physical ⌃ + A / E line start / end, F / B / N / P right / left / down /
  up, D / H delete right / left, K delete to line end (`Shift+End`, `Delete`),
  all `repeating`, ids `emacs-<name>`, category "Emacs", descriptions end in
  "(Emacs key)". Terminals pass the raw key (readline has them). VS Code gets the
  translation too (user's choice), except ⌃D, which passes: the integrated
  terminal can't be told from the editor (§9 F12), and a ⌃D that sent Delete
  would no longer end a shell (§7). One block per key, no loop. Not done: ⌃T / ⌃O / ⌃V / ⌃Y.
  Synthetic chords don't re-trigger these binds (§9 F1), so ⌘A → `Ctrl+A` is safe.
  Handler tests in a private keylog copy: `Home`, `End`, `Right`, `Left`, `Down`,
  `Up`, `Delete`, `BackSpace`, `Shift+End` then `Delete`, none with a modifier.
- [x] **7d** Mac-mode toggle (2026-10-05; the user's physical test of ⌃⌘⇧M passed). The switch is
  the state file `${XDG_STATE_HOME:-~/.local/state}/omackey/off`, read once at
  load by `lib/mode.lua`. While it exists, `load.lua` skips the relocations and
  every module, so Omarchy's defaults load as they ship (checked: ⌘K Keybindings,
  ⌘W Close window, ⌘C Universal copy, ⌘← Focus left all back, 229 binds), and
  registers only the toggle bind. Toggle key **⌃⌘⇧M** (free in Omarchy; bound in
  both modes, help-menu line "OMacKey on/off (Mac mode)"). It runs
  `mkdir`/`touch` or `rm`, a `notify-send`, and `hyprctl reload` as one external
  command (no file or process calls inside the callback). Terminal:
  `scripts/omackey-mode on|off|toggle|status`. `omackey.status()` reports
  "off (…)" and `scripts/check.sh` flags it as ✗ so a forgotten switch-off shows.
  `./install.sh` and `./uninstall.sh` don't touch the state file.
- [-] **7e** (skipped: the user does not need it, 2026-10-05) PC keyboards: opt-in `altwin:swap_lalt_lwin` (puts ⌘ next to the
  space bar), documented and applied through `config.lua` or the README. Never
  edit the user's `input.lua` silently.
- [-] **7f** Option-key characters (closed 2026-10-05, nothing to build): the
  Linux way is Omarchy's Compose key, Caps Lock (`compose:caps`), which already
  works here. Not mapped on ⌥, so ⌥ stays Meta for terminals. The user chose a
  pointer to Omarchy's documentation over a cheat sheet in this repo (§7, §10).
  A Mac-style layout (`us(mac)` with `lv3:ralt_switch`) was considered and not
  taken: it would edit the user's `input.lua` for characters Compose covers.
- [x] **7g** Mouse (2026-10-05). Three parts:
  - **Omarchy's ⌘ + mouse binds moved to ⌃⌥** (§6.6): ⌃⌥-drag moves, ⌃⌥-right-drag
    resizes, ⌃⌥-scroll switches workspace, ⌃⌥⌘-scroll steps through a group. ⌘-click
    no longer moves windows; physical ⌃-click and ⌃-scroll stay free for apps (the
    user first suggested ⌃, but that would have taken Ctrl-click from apps).
  - **⌘-scroll → Ctrl-scroll** (browser zoom; the user's "very necessary" key), new
    `mouse.lua` + `lib/ctrl_hold.lua`, ids `scroll-up` / `scroll-down`. A
    consuming bind starts `wtype -M ctrl -s 400` (a virtual Ctrl that releases
    itself); the first tick of a burst and the 60 ms warm-up are consumed, later
    ticks pass with Ctrl, and a tick 200 ms into a hold starts an overlapping one.
    Needs `wtype` (installed; without it nothing is bound). Physical test by the
    user passed ("seems working"); the page log showed every tick as Ctrl. In
    other apps it zooms Nautilus and LibreOffice; VS Code, Obsidian and foot do
    nothing because Ctrl + scroll is off there by default (VS Code
    `editor.mouseWheelZoom`, Obsidian's Ctrl + scroll font-size setting, foot has
    no mouse zoom), the same as on a Mac. ⌃⌥⌘-scroll steps through a group.
  - **⌘-click → Ctrl-click** (added after the user asked again once ⌘-scroll
    worked), in `mouse.lua` + `lib/click.lua`, ids `click`, `click-shift` and four
    release binds. The first attempt (a synthetic Ctrl key beside the real click)
    failed (§9 F19); what works is to consume the real ⌘ + press and send the
    button myself: `send_key_state` accepts `key = "mouse:272"`, and a synthetic
    event carries the explicit `mods` it is given (`CTRL`, or `CTRL + SHIFT` for
    ⌘⇧-click), so the app sees a Ctrl click (§9 F21). Hyprland drops the real
    release of a press it never saw, so `lib/click.lua` remembers the open press
    and release binds on none / ⇧ / ⌘ / ⌘⇧ close it whichever modifiers are held
    (they pass ordinary releases through).
- [-] **7h** Trackpad gestures (closed 2026-10-05, documentation only, user's
  choice): 3- and 4-finger swipes as on a Mac are not mapped. This machine is a
  desktop with no trackpad, so nothing could be tested; Hyprland's own gesture
  config is left to laptop users (§7).
- [x] **7i** ⌘Tab hold-⌘ stepping (user's wish, 2026-10-03): done in Phase 4,
  see `lib/switcher.lua` and §9 F6. Only the overlay is left (7j, §7).
- [ ] **7j** (optional, later) ⌘Tab overlay: a QuickShell indicator that shows
  the app icons while ⌘ is held, like the Mac switcher (user's idea,
  2026-10-03).
  - Omarchy's shell is QuickShell 0.3.1 (`/usr/share/omarchy/shell`, the
    process is `quickshell -n -p /usr/share/omarchy/shell`). Its plugins have
    kinds `overlay`, `panel`, `bar-widget`, `service` and `menu`; the emojis,
    clipboard, image picker and reminders are overlays, so this would be an
    overlay. `~/.config/omarchy/plugins` exists (not looked into). IPC is
    `omarchy-shell [-q] <target> <method> [args]`, where `-q` is best-effort.
  - Data is ready: `switcher.snapshot()` has the ring (app classes), the
    position and the stop. `switcher.step` and `switcher.finish` are the
    hooks: show or refresh on each step, hide at the end. Bind callbacks must
    not block, so call out with `hl.dsp.exec_cmd`. Open question: whether a
    process spawn per step is fast enough, or whether the plugin should read the
    state some other way.
  - Icons: map the window class to a desktop entry (QuickShell's
    `DesktopEntries.heuristicLookup`, to verify).
  - It adds a plugin to the user's Omarchy shell, so ask before touching
    `~/.config/omarchy`, and make it an opt-in flag in `config.lua` (D12:
    flags are for opt-in extras).

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
| `SUPER + C` / `V` / `X` | Universal copy/paste/cut | none (already Mac-like) | replaced in Phase 3 by terminal-aware ⌘C/V/X (`hl.unbind`, `editing.lua`) |

### 6.5 Unchanged Omarchy binds (no collision)

- `SUPER + SPACE` (launcher, which equals ⌘Space)
- `SUPER + ALT + SPACE`, `SUPER + SHIFT + SPACE`, `SUPER + ESCAPE`
- `SUPER + Home` / `SUPER + ALT + Home` (window width)
- `SUPER + CTRL + TAB` (former workspace), `ALT + TAB` / `ALT + SHIFT + TAB`,
  `CTRL + ALT + TAB` / `+ SHIFT` (monitor focus), `CTRL + ALT + DELETE`
- `SUPER + ALT + TAB` / `+ SHIFT` (group next/prev), `SUPER + CTRL +
  LEFT/RIGHT` (group focus), `SUPER + ALT + code:10..14` (group window N)
- (mouse binds moved in Phase 7g, §6.6)
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

### 6.6 Mouse (Phase 7g)

| Omarchy key | Action | New key |
| --- | --- | --- |
| `SUPER + mouse:272` | Move window (drag) | `CTRL + ALT + mouse:272` |
| `SUPER + mouse:273` | Resize window (drag) | `CTRL + ALT + mouse:273` |
| `SUPER + mouse_down` / `mouse_up` | Scroll active workspace forward / backward | `CTRL + ALT + mouse_down` / `mouse_up` |
| `SUPER + ALT + mouse_down` / `mouse_up` | Next / previous window in group | `CTRL + ALT + SUPER + mouse_down` / `mouse_up` |

⌃⌥ is the window-management modifier (D1). The user first suggested ⌃ (like ⌃
arrows and ⌃1–0), but ⌘-click can't be translated to Ctrl-click (§9 F19), so that
would have taken Ctrl-click from apps for good. ⌘ + click and ⌘ + scroll are translated
to Ctrl + click and Ctrl + scroll by `mouse.lua` (§9 F20, F21).

---

## 7. Unmapped & limitations (living list)

| Item | Why | Workaround |
| --- | --- | --- |
| ⌃↑ Mission Control, ⌃↓ App Exposé | Hyprland has no built-in overview and Omarchy ships none. ⌃↑/↓ switch workspaces instead (1b) | ⌘\` cycles the active app's windows (Phase 4) |
| ⌘Tab overlay (app icons and names) | Hyprland has no switcher UI; the focus change itself is the feedback, and intermediate stops visibly flip workspaces. A QuickShell overlay is an optional idea, 7j | ⌘Tab / ⌘⇧Tab step through apps while ⌘ is held; ⌥Tab cycles windows in layout order; ⌘\` cycles the active app's windows |
| ⌘M minimize, ⌘H hide app, ⌘⌥H hide others, ⌥⌘M minimize all | D13: Hyprland and Omarchy have no minimize or hide, and with no dock a hidden window is easy to lose | Omarchy's scratchpad (⌃⌥⇧S moves the window there, ⌃⌥S shows it), or park it on a workspace with ⌃⇧1–0 |
| Trackpad gestures (3- and 4-finger swipes, pinch) | not mapped: the user's machine is a desktop with no trackpad, so nothing could be tested (7h). Hyprland has its own gesture config for laptop users | Hyprland's `gesture` options in the user's own config |
| ⌘-right-click, ⌘-middle-click | only the left button is translated (⌘-click and ⌘⇧-click); the right and middle buttons reach apps with ⌘ held as before | physical ⌃-right-click |
| ⌘-click with other modifiers (⌘⌥-click, ⌘⌃-click) | only ⌘ and ⌘⇧ are translated | none |
| ⌘-click: the press is sent about a millisecond late | the real press is consumed and re-sent, so a ⌘-click is a synthetic click; none seen (§9 F21), tell the user's tests if a click ever feels dropped | none needed |
| ⌘-scroll: first tick of each burst | the first tick starts the virtual Ctrl and is consumed, so it does nothing (a plain tick would scroll the page) | none needed |
| ⌥ + letter special characters (å ß ∂ …) | ⌥ stays Meta for terminals | Omarchy's Compose key: tap Caps Lock, then a short sequence (`'` `e` → é, `o` `a` → å, `s` `s` → ß, `-` `-` `.` → –). The sequences are in the system Compose table, Omarchy's `/usr/share/omarchy/default/xcompose` (emoji) and your `~/.XCompose`; see §10 |
| Mac Home/End (scroll to document top/bottom) | Linux semantics kept | ⌘↑/⌘↓ |
| ⌘←/⌘→ as browser back/forward outside text fields | focus inside the page can't be detected | ⌘[ / ⌘] |
| Physical ⌃←/⌃→ word jump in Linux apps | ⌃←/→ now switch Spaces (as on a Mac) | ⌥←/⌥→ |
| Nautilus ⌘D duplicate, ⌘⇧⌫ empty trash, ⏎ to rename | no direct Nautilus action (⌘D arrives as `Ctrl+D`, add bookmark) | F2 renames |
| ⌘⇧Q log out | no instant logout wanted; Omarchy's system menu is not one | ⌘Esc opens the system menu |
| F3 Mission Control key (`XF86LaunchA`) | same reason as ⌃↑ Mission Control: no overview in Hyprland or Omarchy (user's choice, 2026-10-03) | none |
| Chromium-family ⌘, (settings) | no Linux shortcut, and Chromium turns a `chrome://` URL on the command line into a blank tab (§9 F11); a typed-URL key sequence was judged too hacky (user's choice, 2026-10-04) | menu, or type `chrome://settings` / `brave://settings` (Firefox ⌘, works) |
| VS Code ⌘W with no editor open | Linux VS Code ignores `Ctrl+W` on an empty window (macOS closes the window). Listing VS Code under `no-tabs` would close the window while editors are open | ⌘⇧W (`Ctrl+Shift+W` closes the window) |
| Terminal ⌘G / ⌘⇧G (find next / previous) | they only act while a search is open, which Hyprland can't see: foot's keys are `Ctrl+S` / `Ctrl+R` (a stray `Ctrl+S` freezes output outside search) and Ghostty's Linux defaults have none (the Mac's ⌘G is `performable`, so it passes through when no search is open) | optional Ghostty line `keybind = performable:ctrl+g=navigate_search:next` in the Ghostty config, not applied |
| Ghostty ⌘W in a split | Linux Ghostty's `Ctrl+Shift+W` closes the whole tab; closing one split needs a `close_surface` keybind in the user's config | optional, not applied |
| VS Code integrated terminal: every ⌘ key except ⌘C / ⌘V | Hyprland sees one window, so the editor's `Ctrl+X` / `Ctrl+Z` / `Ctrl+A` … reach the terminal as readline control keys. Only ⌘C / ⌘V have a chord that works in both (§9 F12) | the terminal's own `Ctrl+Shift+` keys, or move focus to an editor |
| Terminal ⌘K clears the scrollback | `Ctrl+L` only clears the visible screen (Ghostty on the Mac clears the scrollback too) | `clear` plus `printf '\e[3J'` |
| Terminal ⌘D / ⌘⇧D (split) outside Ghostty | foot has no splits; kitty's splits are layouts, not a split command | Hyprland tiling |
| Terminal ⌘↑ / ⌘↓ prompt jumping outside Ghostty | foot's `Ctrl+Shift+Z/X` need shell integration (OSC 133), not set up here | page scroll instead |
| kitty ⌘1–9 | kitty has no default key for tab N | ⌘⇧[ / ⌘⇧] |
| Chromium-family ⌘⇧P | the catch-all sends `Ctrl+Shift+P`, which Chrome and Brave on Linux bind to "print using system dialog" (Mac: ⌥⌘P; ⌘⇧P does nothing there). Firefox: private window on both (user's choice to leave it, 2026-10-05) | ⌘P for the normal print dialog |
| VS Code ⌘↓ / ⌘↑ open a file / go up in lists (Explorer, search results) | the same key moves the cursor to the document end / start in the editor and Hyprland can't see which has focus (Enter / Left on Linux) | Enter, or the arrow keys |
| VS Code ⌘⌥ + other keys and ⌘ + F-keys (⌘⌥K / T / S / Y, ⌘F2, ⌘F12 …) | the catch-all covers ⌘ and ⌘⇧ only; these are obscure, and ⌘ + F-key needs Fn on the NuPhy in Mac mode | VS Code's own `Ctrl+Alt+…` / `Ctrl+F2` keys |
| VS Code ⌘⇧Space (parameter hints), ⌘Esc | Omarchy owns them (toggle top bar, system menu) | Ctrl+Shift+Space, or ⌃Space for suggestions |
| VS Code ⌘⇧U (toggle output) | no Linux key exists, and the catch-all consumes ⌘⇧U (Unicode input) | Command palette |
| ⌘⇧ + digits (⌘⇧1, 2, 6–9) | the catch-all skips them: ⌘⇧3/4/5 are screenshots and Ctrl+Shift+digit means little on Linux | none |
| Obsidian ⌘⌥[ / ⌘⌥] (fold / unfold) | Obsidian has no default fold hotkey on any platform (§9 F16); the keys are not mapped | Set a hotkey for "Toggle fold" in Obsidian's Hotkeys settings |
| LibreOffice ⌘⇧G (find previous) | no key finds the previous match (the Find toolbar has Shift+Enter only while it has focus); the generic `Shift+F3` would change case, so ⌘⇧G is consumed | the arrow button in the Find toolbar |
| Emacs ⌃D (7c) in VS Code | ⌃D passes through: the integrated terminal can't be told from the editor, and readline needs the raw ⌃D (end of input). The other Emacs keys are translated there, so in its terminal ⌃K sends `Shift+End`, `Delete` (deletes one character instead of killing the line) | Delete in the editor; `Ctrl+K` equivalents are not available in the integrated terminal |
| VS Code ⌘⇧⌥ arrows (column select) | Linux VS Code has no keyboard column select (`cursorColumnSelect*` have `linux: { primary: 0 }`), and `Ctrl+Shift+Alt+Up/Down`, the Mac chord with Ctrl, is Copy Line Up/Down there (user's choice, 2026-10-05) | Shift+Alt+mouse drag, or a user keybinding for `cursorColumnSelect*` |

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
  - For a handler that acts on the window itself (⌘W closes it), check and
    trigger in one `repl` call so focus can't change in between:
    `hyprctl repl "local w = hl.get_active_window(); if w and w.pid == <pid> then return omackey.trigger('<id>') end; return 'wrong window'"`.
  - `omackey.fired("<id>")` counts real presses since the last reload.
  - `wtype` can't test binds: virtual-keyboard input never triggers Hyprland
    binds (§9 F1).
  - `keylog.py` is single-instance, so a second launch only focuses a running
    one and logs nothing (§9 F2 has a private-copy recipe). A private copy's
    window class is `keylog.py`, not `omackey.keylog`, so focus it by pid.
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

**F3 — Phase 4 findings (2026-10-03)**

- **VS Code's window class** here is `com.microsoft.VSCode` (native Wayland,
  installed in `/usr/share/code`), not `code` as CLAUDE.md and 6c assumed.
  The 6c profile has to use it.
- **⌘W in VS Code** closes the active editor (also inside editor groups). With
  no editor open it does not close the window: that is native Linux behaviour,
  macOS closes it. `Ctrl+Shift+W` closes the window (⌘⇧W, next). VS Code stays
  off the `no-tabs` list, which would close the window with editors open (§7).
- **Terminal tag coverage.** Omarchy's `terminal` tag matches `Alacritty`,
  `kitty`, `com.mitchellh.ghostty`, `foot`, `wezterm`, `org.omarchy.*` and
  `TUI.*`, so ⌘W also closes Omarchy's TUI windows (btop and friends).
- **`window.pid`** is readable from Lua, so a test can check the active window
  and fire a handler in one `hyprctl repl` call (§8.1).
- **A private keylog copy** (D-Bus disabled) has window class `keylog.py`, not
  `omackey.keylog`. Focus it by pid.

**F4 — Zoom findings (2026-10-03)**

- **⌘0 is not "go to tab".** On macOS, ⌘0 resets browser zoom (Safari,
  Chrome and Firefox); ⌘1–⌘8 select tabs 1–8 and ⌘9 the last tab.
- **VS Code has no `Ctrl+0` / ⌘0 zoom reset by default.** The reset command is
  bound to `Ctrl+Numpad0` (⌘Numpad0 on macOS); `Ctrl+0` is not it. So ⌘0 doing
  nothing to VS Code zoom is native behaviour, same as on a Mac without
  customizing. Listed under 6c as an optional override.
- The user confirmed ⌘= ⌘+ ⌘- ⌘0 in keylog, Brave, foot and the rest.

**F5 — ⌘1–⌘9 findings (2026-10-03)**

- **VS Code:** ⌘1–⌘N focus editor group N, not tab N. That is VS Code's own
  default on a Mac too: `workbench.action.focusFirstEditorGroup` is
  `CtrlCmd+1` (checked in the installed `workbench.desktop.main.js`, keybinding
  `primary:2070`), so ⌘ → Ctrl reproduces the Mac behaviour exactly.
- **Finder:** ⌘1–⌘4 switch the view (icons, list, columns, gallery), per
  Apple's shortcut page. They never select a tab.
- **Nautilus 50.3.1:** the binary binds `Alt+N` to `win.go-to-tab(N)` and
  `Ctrl+1` / `Ctrl+2` to `slot.files-view-mode`. Tested in a private
  instance: from grid view `Ctrl+2` stays on grid and `Ctrl+1` switches to
  list view. So Nautilus is the reverse of Finder's ⌘1 / ⌘2, and ⌘3–⌘9 do
  nothing. The user's test saw no tab switching for that reason. 6d handles
  the swap.
- **Throwaway Nautilus for tests.** `DBUS_SESSION_BUS_ADDRESS=disabled:
  nautilus --new-window DIR &` starts a standalone instance (the dconf and
  D-Bus warnings are harmless), class `org.gnome.Nautilus`. Focus it by pid and
  guard each trigger by pid. `grim -g "<x>,<y> <w>x<h>"` takes a screenshot of
  its geometry from `hyprctl clients -j`, and `kill <pid>` closes it.

**F6 — App and window switching (2026-10-03)**

- **`HL.Window.focus_history_id`** is Hyprland's own focus order: 0 is the
  focused window, 1 the one before, and so on. Readable from Lua. It ranks the
  windows *within* an app, and the apps until OMacKey has seen a focus change.
- **`hl.on("window.active", fn(window))`** fires once per focus change, with an
  `HL.Window`. `lib/switcher.lua` keeps its own app recency list from it. Why:
  stepping through apps with ⌘Tab focuses every stop, and Hyprland's history
  would then rank the stops above the app you came from, so the next ⌘Tab
  would not flip back. Outside a ⌘Tab session every focus change is recorded
  (clicks, launches, other shortcuts). Inside one the stops are not, and when
  it ends the list becomes [stop, then the rest in their old order], which is
  what macOS does.
- **`hl.on("input.keyboard.key", fn(keycode, time, state))`** reports every key
  press (`state` 1) and release (0), physical ones included, with XKB keycodes:
  Super_L is 133 (Super_R 134), Tab 23, Shift_L 50. The user's ⌘ + Tab test
  showed `133:1 23:1 23:0 133:0`. Events can come twice (fcitx5's virtual
  keyboard re-injects keys; consumed binds like Tab are not repeated). This is
  how a ⌘Tab session knows ⌘ was released, so the subscription exists only
  while a session is open. A subscription can remove itself inside its own
  callback (`sub:remove()`), tested with wtype, whose virtual keyboard also
  fires the event but with its own keycodes.
- **The session survives changes it did not make.** Its ring holds app names,
  not windows, and each step looks the windows up again: an app whose windows
  are all gone is skipped, and new apps join at the next session. If focus
  moved to another app since the last stop (a click, ⌥Tab, a window closing or
  opening), the next press starts a new session from where focus is. There is
  no timer: a missed ⌘ release would end at the next ⌘ release, whichever
  shortcut it belongs to.
- **`hl.dsp.focus({ window = <HL.Window> })`** also switches to the window's
  workspace (seen: 2 → 5 → 2 → 1 → 5 on the user's windows).
- **`window.workspace.special`** marks scratchpad windows. ⌘Tab leaves them out.
- **`hl.dsp.window.cycle_next()`** walks a ring of the windows on the current
  workspace (layout order), and `{ next = false }` retraces it. Omarchy's ⌥Tab
  follows each cycle with `bring_to_top`, which reorders that ring, so its
  reverse no longer retraces. Not used by OMacKey.
- **macOS ⌘Tab** switches *apps* by recency: one press flips between the two
  most recent apps (the latest window of each), and holding ⌘ while pressing
  Tab (or ⇧Tab) walks along the list. The first version here cycled windows;
  the user corrected it, then asked for the deeper stepping.

**F7 — Minimize and hide (2026-10-03)**

- **Not native.** `grep -ri minimize /usr/share/omarchy` and the Hyprland Lua
  stubs have no hits. Omarchy's manual lists only the scratchpad ("Toggle
  scratchpad", "Move window to scratchpad"). Hyprland users ask for minimize in
  [discussion #8281](https://github.com/hyprwm/Hyprland/discussions/8281) and
  rely on the wiki's special-workspace trick, which stopped working in 0.54
  ([discussion #13703](https://github.com/hyprwm/Hyprland/discussions/13703)).
  The Omarchy shell plugin
  [omarchy-window-buttons](https://github.com/nichovski/omarchy-window-buttons)
  adds a minimize button that also uses the scratchpad.
- **What building it showed** (Hyprland 0.56.2; the code was discarded, D13):
  - `hl.dsp.window.move({ workspace = "special:x", follow = false, window = w })`
    sends any window to a special workspace, and focus falls to another window
    on the workspace.
  - `window.workspace.name` / `.special` identify such windows; they report
    `mapped = true` and `hidden = false` while parked.
  - `hl.dsp.workspace.toggle_special("x")` shows and hides the workspace.
  - Moving a window out with `workspace = hl.get_active_workspace()` works
    on 0.56.2 and focuses it.
- **Scratchpad key clash to watch.** The online Omarchy manual also lists
  `Super + Grave` and `Super + Shift + Grave` for the scratchpad. The installed
  4.0.4 has only `SUPER + S` / `SUPER + ALT + S` (checked in `tiling.lua`).
  If a later Omarchy adds the Grave binds they collide with ⌘\` / ⌘⇧\` and need
  a relocation (the drift check in 8.3 should flag it).

**F8 — Screenshot CLI (2026-10-03)**

- `omarchy-capture-screenshot <mode> <processing>`: processing `save` writes
  `screenshot-<date>.png` to `$XDG_PICTURES_DIR` and nothing else, `copy` only
  fills the clipboard, and the default (`slurp`) does both plus a notification
  with an edit action.
- Mode `fullscreen` captures the focused monitor with no interaction, `region`
  shows the picker. Running it again while the picker is open kills it
  (`pkill slurp`).
- Digit keys are bound by keycode: ⌘⇧3 is `SUPER + SHIFT + code:12`; the help
  menu shows it as `SUPER SHIFT + 3`.

**F9 — NuPhy Air75 V2 F-row in Mac mode (2026-10-03)**

- Found with a temporary `hl.on("input.keyboard.key")` probe in the live
  state (removed afterwards); XKB keycode = evdev + 8, keysyms from
  `/usr/share/X11/xkb/symbols/inet`. Bound keys are consumed before an app
  sees them, so keylog can't show them.
- F1 / F2 `XF86MonBrightnessDown` / `Up` (232 / 233). F3 `XF86LaunchA` (128),
  the Mission Control key. F4 looked like Super+Space (Spotlight, so it hits
  the Omarchy menu). F5 `XF86VoiceCommand` (590). F6 `XF86DoNotDisturb` (599).
  F7–F9 previous / play-pause / next (173 / 172 / 171). F10–F12 mute / volume
  down / volume up (121 / 122 / 123).
- Omarchy binds F1, F2 and F7–F12 already. F3, F5, F6 were unbound.
- `omarchy-toggle-notification-silencing` has no state file: it calls
  `omarchy-shell notifications toggleDnd`, which prints `on` or `off`.
- voxtype was not installed at first, so Omarchy skipped its binds; the F5
  binds use the same `o.cmd_present("voxtype")` condition, evaluated at load
  (reload after installing it). F5 maps to push-to-talk like Omarchy's F9
  (`voxtype record start` on press, `stop` on release), and ⇧F5 to
  `voxtype record toggle`. `action{}` got a `release` option for this.

**F10 — Terminal keys (6a, 2026-10-03)**

- **Sources.** Ghostty 1.3.1: `ghostty +list-keybinds --default` for Linux, and
  the macOS defaults in `src/config/Config.zig` (raw GitHub). kitty 0.48.2: the
  effective keymap dumped with `kitty +runpy` (`load_config()`
  `.keyboard_modes[''].keymap`; mods 5 = Ctrl+Shift). foot 1.28: `foot.ini(5)`.
- **Ghostty (Linux).** Tabs `Ctrl+Shift+T` / `Ctrl+Shift+W` (`close_tab:this`),
  `Alt+1–8` and `Alt+9` (last tab), `Ctrl+Page_Up/Down` previous / next tab,
  `Ctrl+Shift+Page_Up/Down` `jump_to_prompt`, `Ctrl+Shift+F` search,
  `Ctrl+Shift+A` select all, `Ctrl+Shift+O` / `E` split right / down,
  `Ctrl+comma` open_config. No default `clear_screen` or `navigate_search`.
- **Ghostty (macOS source).** `cmd+k` clear_screen ("clear the screen and all
  scrollback"), `cmd+up/down` jump_to_prompt ("matches Terminal.app"),
  `cmd+d` / `cmd+shift+d` splits, `cmd+f` start_search, `cmd+g` / `cmd+shift+g`
  navigate_search (marked `performable`, so the key passes through when no
  search is open). The plan's "⌘↑/↓ scroll" row was not the Mac behaviour.
- **kitty.** Tabs `Ctrl+Shift+T`, `Ctrl+Shift+Q` (close tab), `Ctrl+Shift+W`
  (close the pane; the last pane closes its tab), `Ctrl+Shift+Left/Right` and
  `Ctrl+Tab` / `Ctrl+Shift+Tab` switch tabs, `Ctrl+Shift+/` search_scrollback,
  `Ctrl+Shift+Page_Up/Down` scroll a page, `Ctrl+Shift+F2` edit config. Font
  size is `Ctrl+Shift+=` / `-` / `BackSpace`: **Phase 4's zoom keys
  (`Ctrl+=` …) did nothing in kitty**; fixed with a kitty entry. No default
  key for tab N (`Ctrl+Shift+1…` are pane numbers).
- **foot.** Search `Ctrl+Shift+R`; inside it `Ctrl+R` / `Ctrl+S` step between
  matches. `Shift+Page_Up/Down` scroll a page; no tabs, splits or select all.
  `prompt-prev` / `prompt-next` (`Ctrl+Shift+Z/X`) need shell integration.
- **Ghostty ⌘, does nothing visible (found by the user's physical test).**
  `open_config` runs `xdg-open ~/.config/ghostty/config`. The default handler
  for the file is `nvim.desktop` (`Terminal=true`), and `xdg-open` starts `nvim`
  directly with no terminal, so each press leaves a hidden `nvim` process
  (children of Ghostty). It is not an OMacKey fault; the Ghostty entry was
  replaced: ⌘, now runs `omarchy-launch-editor "$HOME/.config/ghostty/config"` (a visible TUI window; user's choice). kitty's `Ctrl+Shift+F2` works: it opens
  Omarchy's editor (`omarchy-launch-editor`) in a second window of the same
  process. Lesson: a terminal action that spawns another program needs a test
  that watches `ps` and the window list, not only a "handled" result.
- **The profile chain** `{ "ghostty", "terminal", "default" }` already worked in
  `lib/apps.lua` (`family`); the three new profiles use it. Omarchy's TUI
  windows (`org.omarchy.*`) run in whichever terminal is the default but keep
  the generic profile.
- **Test recipes** (throwaway windows, pid-guarded, each launched and killed by
  the test):
  - `ghostty --gtk-single-instance=false -e bash -c '…'` is its own process
    with the normal class, so the profile matches. A first command that sets the
    title with `printf '\033]2;ONE\a'` makes the active tab readable from
    `hyprctl clients -j` (a new tab's shell shows its cwd): used for ⌘T, ⌘1–9,
    ⌘⇧[ ], ⌘⌥← →, ⌘W.
  - Bytes a terminal sends: `stty raw -echo; dd bs=1 count=1 of=FILE`, then
    `od -An -tx1 FILE` (`xxd` is not installed). ⌘K gave `0c` in Ghostty and
    kitty.
  - Font size: a `trap 'tput cols > FILE' WINCH` loop; kitty went 202 → 165 →
    140 → 165 → 202 columns for ⌘= ⌘+ ⌘- ⌘0.
  - Terminal-internal features (splits, search, scrolling): `grim -g` of the
    window geometry, read as an image.
  - `kitty` starts its own process by default; `foot` too (class `foot`).

**F11 — Browser keys (6b, 2026-10-04)**

- **Sources.** Chrome's keyboard-shortcut page (Mac and Linux columns; its
  summary listed `Ctrl+Shift+J` for DevTools, but Chrome's DevTools key on Linux
  is `Ctrl+Shift+I`, which the test confirmed), and Firefox's DevTools shortcut
  docs (Mac ⌘⌥I / ⌘⌥K / ⌘⌥C = toolbox / Web Console / Inspector; Linux the
  same letters with `Ctrl+Shift`). The fetched summary also gave ⌘⌥J for the
  Browser Console, but a search result says ⌘⇧J, so treat ⌘⌥J in Firefox as
  unverified (it sends `Ctrl+Shift+J`, which is Firefox's Browser Console on
  Linux). Firefox's general shortcut page would not load.
- **The Mac letters carry over.** ⌘⌥ + I/J/C → `Ctrl+Shift` + the same letter
  in both families. Firefox's ⌘⌥K needs `SUPER + ALT + K`, which Omarchy binds
  to tmux keybindings.
- **Differences per browser.** Chrome Mac: ⌘⌥U source, ⌘Y history, ⌘⇧J downloads,
  ⌘⌥B bookmark manager, ⌘⇧⌫ clear data. Firefox Mac (⌘J downloads and ⌘⇧J
  Browser Console confirmed by a search result; ⌘U source, ⌘⇧H history, ⌘⇧O
  library, ⌘⇧P private from memory, not checked): OMacKey uses
  the Chrome set in both (user's choice for ⌘⇧J), except ⌘⇧N → `Ctrl+Shift+P`
  in Firefox.
- **Firefox 155** shows "Clear browsing data and cookies" as a modal inside
  the window: until it is dismissed (Esc), further shortcuts do nothing. Its
  downloads (`Ctrl+Shift+Y`), bookmarks (`Ctrl+Shift+O`) and private window each
  open a separate window of the same process; the history is a sidebar.
- **Chromium (152) rewrites `chrome://` and `about:` URLs given on the
  command line to a new-tab page**, both for a running instance and on a fresh
  start (`chromium chrome://settings`, `chrome://version`, `about:version`
  all gave `chrome://newtab/`). No policy in `/etc/chromium/policies` causes it.
  Not confirmed for Brave Origin (a fresh profile showed Brave's startup page
  instead), assumed the same. `Alt+F` did not open the Chromium menu through
  synthetic keys. Firefox does accept `firefox about:preferences` (opened the
  Settings tab in the running instance).
- **VS Code ⌘⌥I (found by the user's physical test).** Toggle Developer Tools is
  `Ctrl+Shift+I` on Linux (`primary:3111`; ⌥⌘I on the Mac, `2599`), but so is
  Format Document (`kbExpr: editorTextFocus`, `linux: { primary: 3111 }`), and
  it wins with the editor focused. Read from the installed
  `workbench.desktop.main.js`. So the synthetic key would reformat the file, not
  open DevTools. VS Code now consumes ⌘⌥I (profile `vscode`); DevTools stay on
  the command palette (`Developer: Toggle Developer Tools`) or Help menu.
- **F12 — VS Code's integrated terminal (found by the user, 2026-10-05).**
  Hyprland sees one `com.microsoft.VSCode` window, so a profile can't tell the
  editor from the integrated terminal. `Ctrl+C` there is SIGINT and `Ctrl+V` a
  literal-next. `Ctrl+Insert` / `Shift+Insert` are VS Code's Windows/Linux
  copy/paste defaults in the editor and also work in the terminal, so ⌘C / ⌘V
  use them under profile `vscode`. Other ⌘ keys still reach the terminal as
  Ctrl chords (§7).
- **Test recipes.** Chromium: `chromium --user-data-dir=DIR --no-first-run
  --remote-debugging-port=PORT`; `curl localhost:PORT/json` lists the tabs, so
  history, downloads, bookmarks, view-source, clear data and DevTools show up as
  tabs or targets. Firefox: `firefox --no-remote --profile DIR`, its windows
  from `hyprctl clients`, screenshots for the sidebar and DevTools. Close extra
  windows by address between keys: a new window takes focus. The Brave profile
  needs its own first-run handling, so Brave was not driven.

**F13 — VS Code keys (6c, 2026-10-05)**

- **Method.** Keybindings read from the installed `workbench.desktop.main.js`
  (`kbOpts` with `primary`, `mac` and `linux` fields). Decode: CtrlCmd 2048,
  Shift 1024, Alt 512, WinCtrl 256, plus the key code (arrows 15–18, `[` 92 in
  the shifted fold keys, F 36, H 38).
- **Same chord as the Mac with Ctrl for ⌘:** none of the 6c keys. Each differs:
  add cursor above/below is `Ctrl+Alt+Up/Down` on the Mac and `Shift+Alt+Up/Down`
  on Linux, with `Ctrl+Shift+Up/Down` as the Linux secondary (used). Fold /
  unfold are `⌘⌥[` / `]` on the Mac, `Ctrl+Shift+[` / `]` on Linux. Replace is
  `⌘⌥F` / `Ctrl+H`. Expand / shrink selection is `⌃⇧⌘→` / `←` on the Mac,
  `Shift+Alt+Right` / `Left` on Linux. Reset zoom is `Ctrl+Numpad0` on both.
- **Column select has no Linux key**, and its Mac chord with Ctrl in place of
  ⌘ is Copy Line Up/Down (`copyLinesUpAction`: Linux `Ctrl+Shift+Alt+Up`). The
  plan's 6c row would have duplicated lines (§7).
- **Numpad 0 arrives as `KP_Insert`** in keylog (code 90, NumLock off). VS Code
  reads the key by scancode, so this should match `Ctrl+Numpad0` like a
  physical press; only the user's test can confirm.

**F14 — Catch-all facts (7a, 2026-10-05)**

- **Live claims at the start of 7a** (from `hyprctl binds -j`, modmask Super or
  Super+Shift): ⌘ + A B C D F G I K L N O P Q R S T U V W X Y Z, 0–9, `- = [ ]
  \` `` ` `` `, . /`, Space, Tab, ⌫, ⌦, Esc; ⌘⇧ + D G J N S T V W Z, 3 4 5, `=
  [ ] \` `` ` `` `, /`, Space, Tab, ⌫. Omarchy's own leftovers among them
  (⌘Space, ⌘Esc, ⌘⇧Space, ⌘⇧, ...) are why the catch-all reads Omarchy's keys
  instead of using a fixed list.
- **`hl` has no bind-listing call** at load time (`hl.get_keybinds` is nil),
  so the claimed set comes from the `hl.bind` wrapper.
- **A test trap:** changing a profile in memory (`terminal` classes) persists in
  the live Lua state until `hyprctl reload`. After the "as terminal" check the
  next GUI check silently saw the terminal rules (no keys, "ok"). Reload between
  such tests.
- **Shifted punctuation arrives as the shifted keysym**: ⌘⇧- sent
  `Ctrl+Shift+minus` and keylog logged `underscore`.

**F17 — LibreOffice keys (6f, 2026-10-05)**

- **Source.** `share/registry/main.xcd` holds the accelerators (no
  `soffice.cfg/.../accelerator` files in this package). The second `PrimaryKeys`
  block has the Global set and per-module sets (`com.sun.star.text.TextDocument`,
  `…sheet.SpreadsheetDocument`, …). `MOD1` is Ctrl (⌘ on the Mac), `MOD2` is Alt.
  Redo is `Ctrl+Shift+Z` there (`Z_SHIFT_MOD1`), Repeat Search is `Ctrl+Shift+F`
  in Writer and Calc, Options is `Alt+F12`. `Ctrl+G` is cleared.
- **The generic F3 / Shift+F3 were harmful** in LibreOffice (AutoText, change
  case); they are replaced or consumed.
- **Window classes:** `libreoffice-<module>`; its dialogs (Options, Paste
  Special) use class `soffice`, so the profile lists it too.
- **Test trap:** synthetic keys sometimes did nothing for a while after the find
  bar or a dialog had focus, and plain letters sent by keycode never typed
  (`wtype` did); Ctrl chords worked once the document had focus again. Use cut /
  undo / redo on a selection rather than typed text.

**F19 — ⌘-click spike (7g, 2026-10-05)**

- **Setup.** Non-consuming binds (`bindn`) on `SUPER + mouse:272`, its release,
  `SUPER + mouse_up/down`, whose handler tapped a synthetic `Control_L` with
  `mods = "CTRL"`. A throwaway Chromium page logged `ctrlKey` / `metaKey` and
  timestamps for key, mouse and wheel events and posted them to a local server.
- **Result.** The binds fired (counter) and the key events arrived in order
  (`keydown Control mods=C---` at t=42148, `mousedown` at t=42150, `keyup` 20 ms
  later), yet `mousedown`, `mouseup`, `click` and `wheel` all showed `----`. The
  synthetic key itself carried Ctrl (`keydown mods=C---`). Probably the modifier
  state sent with a synthetic key is applied to that key event only and the
  compositor's real state (⌘ held) is what pointer events use; not verified in
  Hyprland's source. Chromium does not report `metaKey` for the real ⌘ either.
- **Superseded by F20 and F21.** The key-beside-the-click idea can't work, but
  two other routes do: a real Ctrl held by `wtype` (scroll) and a synthetic button
  with explicit `mods` (click). `ydotool`, suggested from a forum snippet whose
  script was missing, was not needed (it would have meant a daemon and
  `/dev/uinput` access).
- **Test recipe.** A page that logs events and POSTs them to
  `python3 -m http.server`-style listener lets the agent read what an app
  received after the user's physical clicks; Chromium needs its own
  `--user-data-dir`, and killing it by profile path (a second launch reuses the
  running instance and old page).

**F21 — Synthetic mouse button (7g, 2026-10-05)**

- **`send_key_state` takes `key = "mouse:272"`** (and `state` "down" / "up"): it
  delivered `mousedown`, `mouseup` and `click` to a throwaway Chromium page with the
  pointer over it (no window argument: the button goes to the pointer focus; the
  test refused to fire unless the cursor was inside the test window).
- **Explicit `mods` apply to the button event.** `mods = ""` gave `----` even
  while `wtype` held Ctrl (the explicit empty value replaces the held state);
  `mods = "CTRL"` gave `C---` and `"CTRL + SHIFT"` gave `C-S-` on `mousedown`,
  `mouseup` and `click`, with no `wtype`. Real ⌘ never shows up (`M` absent).
- **A consumed press leaves Hyprland without a held button**, so it drops the real
  release: with the first version (release bind on ⌘ only) letting go of ⌘ before
  the button left the app with a press and no `mouseup`, and the stray `mouseup`
  arrived at the next click. Release binds for the plausible modifier states
  closed it (user's retest: plain click, ⌘-click, ⌘⇧-click, drag, ⌘ released first,
  double click, a final plain click: all balanced, no strays).
- **Test lesson.** The user's physical clicks mixed into my synthetic ones until I
  asked for hands off; a log with timestamps and the physical Ctrl from `wtype`
  (`C---`) was how to tell them apart.
- **Focus:** `input.follow_mouse = 1`, so the window under the pointer already
  has focus when a ⌘-click is consumed. With `follow_mouse = 0` the consumed press
  would not focus the window.

**F20 — Ctrl held by wtype (7g, 2026-10-05)**

- **`wtype -M ctrl -s MS`** presses Ctrl on a virtual keyboard, sleeps MS and
  releases it. Unlike a synthetic `send_key_state` key it changes the real
  modifier state: a throwaway Chromium page saw `mods=C---` on a physical click
  (`mousedown`, `mouseup`, `click`) and on every wheel tick during the hold, and
  no `keydown` for Ctrl (modifier state only).
- **Overlapping holds don't drop Ctrl.** Five 1500 ms holds started 1 s apart
  covered a continuous 4 s scroll: all 18 ticks `C---`, including at every
  handoff. That is why one burst can be kept alive by starting the next hold
  halfway through.
- **Latency.** Starting `wtype` takes a few ms, longer than the compositor takes
  to forward the tick, so the tick that starts a hold can't carry Ctrl: it is
  consumed (with `auto_consuming` and a nil return) rather than scrolled. Ticks
  during a 60 ms warm-up are consumed too; later ticks pass (`{ ok = false }`).
- **Real run** (user, ⌘ held): every tick of slow, fast and 4 s spins arrived as
  `CM--` (Chromium reports Super as metaKey once Ctrl is up), a plain scroll
  after releasing ⌘ was `----`, ⌘C sent `C---` and typing after it had no Ctrl.
  Not understood: three slow ticks 1 s apart all arrived with Ctrl although a hold
  only lasts 400 ms (a physical notch may send more than one axis event).
- **No wall clock in Lua** (`os.clock` is CPU time, `os.time` whole seconds), so
  `lib/ctrl_hold.lua` keeps its state with timers and a generation counter.
- **Safety.** Each `wtype` releases its own Ctrl when its sleep ends, so a crash or
  a missed event can leave Ctrl held for at most 400 ms.

**F18 — Mac-mode toggle (7d, 2026-10-05)**

- **`hl.dsp.exec_cmd` runs a shell line**: `&&` and `;` work, so one command
  can create the state file, notify and reload. A first version silently did
  nothing when the message held an apostrophe inside single quotes ("Omarchy's"):
  keep shell-quoted text free of `'`.
- **No reload API** in `hl` (`hyprctl reload` through `exec_cmd`); a reload starts
  a fresh Lua state, which is what makes the file-at-load switch work.
- **Off still loads cleanly under the help-menu replay**: the menu lists Omarchy's
  keys plus the toggle line.

**F16 — Obsidian keys (6e, 2026-10-05)**

- **Source.** `/usr/lib/obsidian/obsidian.asar` holds `app.js` (read with a small
  asar extractor; no `asar` tool installed). App commands declare
  `hotkeys:[Yw(["Mod",…],key)]`; the editor (CodeMirror 6) has keymaps with
  `mac:` / `linux:` overrides. `Mod` is Ctrl on Linux and ⌘ on the Mac.
- **Differences found.** Back / forward are `Mod+Alt+Left/Right` on both
  platforms (so ⌘⌥ → Ctrl+Alt). Redo selection is `Mod+Shift+U` on the Mac and
  `Alt+U` on Linux. `Mod+Alt+Up/Down` (add cursor) and `Mod+Alt+F` / `Mod+H` (replace)
  are the same keys. Next / previous tab has the Mac key `Meta+Shift+[` and
  Linux `Ctrl+Page_Up/Down`, which the generic rule already sends.
- **Fold has no Obsidian hotkey.** `Ctrl-Shift-[` / Mac `Cmd-Alt-[` come from
  CodeMirror's bundled `foldKeymap`, which Obsidian does not load; its fold
  commands (`editor:toggle-fold`, `fold-all`, …) have no default hotkey, so the
  user's physical `Ctrl+Shift+[` did nothing. Mapping ⌘⌥[ would invent a Mac
  behaviour that does not exist.
- **Back / forward only act within one tab's history** (`activeLeaf.history`).
- **Mac-only Emacs keys** (`Ctrl-a/e/b/f/…`) are CodeMirror's Mac keymap and a
  7c item; `Ctrl-m` (Mac `Shift-Alt-m`) was left alone.
- **Window class** here is `md.obsidian.Obsidian`, not `obsidian` as the plan
  assumed.

**F15 — VS Code Mac vs Linux keymap (6c-2, 2026-10-05)**

- **Extraction.** Every `primary:N` object in `workbench.desktop.main.js`
  (kbOpts, keybinding, registerCommandAndKeybindingRule), with its `mac:{}` and
  `linux:{}` overrides, decoded as in F13 (Cmd 2048, Shift 1024, Alt 512,
  WinCtrl 256; Mac WinCtrl = physical ⌃). About 1,100 bindings (the parser
  also yields the same object twice, and some ids come out as `?`; chord-style
  bindings such as ⌘K ⌘S use another encoding and were not extracted, but
  they are plain Ctrl chords on both platforms). Script kept out of the repo.
- **Result.** 476 of 591 Mac ⌘ chords are the same key with Ctrl on Linux, so
  a plain translation is correct. 115 differ; most are scope-specific (terminal,
  chat, lists, notebooks), the rest are in the 6c table and the list above.
- **Same physical chord, different command** (the dangerous kind, since ⌥ and
  ⌃ pass through): ⌥⇧↑ / ↓ (Mac copy line, Linux add cursor), ⌥⇧A (Mac block
  comment, Linux nothing). The other differing chords were Emacs ⌃ keys (7c).
- **Catch-all gap found by the audit:** keys claimed by a profile-only entry
  passed the raw ⌘ chord outside that profile (⌘K in VS Code, so every ⌘K chord
  failed). Fixed in `catchall.lua` (§9 F14 lists the keys).
- **Zoom:** the Mac also zooms out on ⌘⇧-; Linux has `Ctrl+Shift+-` as
  Navigate Forward, which the catch-all would have sent.

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
| Omarchy Compose key (typing é å ß – € … and emoji) | The Omarchy manual only mentions it in one sentence, in its Troubleshooting section ("Caps Lock has been designated to be the xcompose key. That's how you get quick emojis", <https://learn.omacom.io/2/the-omarchy-manual/88/troubleshooting>). The real references are local: `/usr/share/omarchy/default/hypr/input.lua` (`compose:caps`), `/usr/share/omarchy/default/xcompose` (Omarchy's sequences), `~/.XCompose` (your own; apply changes with `omarchy-restart-xcompose`), and the system table `/usr/share/X11/locale/en_US.UTF-8/Compose`. The emoji and symbols picker is ⌃⌘Space (Phase 5) |
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
- **2026-10-02 — Phase 2: ⌘↑/↓ and ⌘⇧↑/↓.**
  - Added `document-start` / `document-end` / `select-document-start` /
    `select-document-end` in `text.lua`: `Ctrl+Home`, `Ctrl+End` and the
    `Ctrl+Shift` versions in GUI apps, consumed in terminals, `repeating`.
    The keys were free (focus and swap-window moved to ⌃ / ⌃⇧ in 1b). 18
    bindings, 108 relocations, no duplicates.
  - Handler test in a private keylog copy: `mods=CTRL` / `CTRL+SHIFT`, no
    SUPER; the cursor went to the end and start of the text, and the selection
    covered it.
  - The user's physical tests (§8.2) passed.
  - **Next:** the deletion keys: ⌥⌫, ⌥⌦, ⌘⌫, ⌘⌦.
- **2026-10-02 — Phase 2: deletion keys. Phase 2 complete.**
  - Added `delete-word-left` / `delete-word-right` / `delete-line-start` /
    `delete-line-end` in `text.lua` (category "Editing"), all `repeating`:
    - ⌥⌫: `Ctrl+BackSpace`; terminals pass the raw key (readline
      backward-kill-word).
    - ⌥⌦: `Ctrl+Delete`; terminals `Alt+d`.
    - ⌘⌫: `seq(Shift+Home, BackSpace)`; terminals `Ctrl+U`.
    - ⌘⌦: `seq(Shift+End, Delete)`; terminals `Ctrl+K`.
  - New `send.seq()` taps chords in order, spaced `release_ms + 5` so each is
    released before the next goes down.
  - The keys were free. 22 bindings, 108 relocations, no duplicates.
  - Handler tests: keylog got the expected chords; a foot probe that prints
    raw bytes got `ESC d`, `^U` and `^K`. ⌥⌫ in a terminal is a pass-through,
    so only the physical test covers it.
  - The user's physical tests (§8.2) passed for all four.
  - **Next:** Phase 3, core editing (clipboard, undo/redo, select all, find,
    save). Omarchy's ⌘C/⌘V/⌘X universal clipboard binds are replaced there.
- **2026-10-02 — Phase 3: ⌘C, ⌘V, ⌘X.**
  - New `editing.lua` (added to `config.modules`). It runs `hl.unbind` on
    Omarchy's `SUPER + C/V/X` (universal copy/paste/cut) and declares:
    - ⌘C: `Ctrl+C`; terminals `Ctrl+Insert`.
    - ⌘V: `Ctrl+V`; terminals `Shift+Insert`.
    - ⌘X: `Ctrl+X`; terminals consume (Omarchy sent Ctrl+X there too).
  - Not `repeating`. Our `send.tap` keeps its timer handles, so the dropped
    timer in Omarchy's version is gone. 25 bindings, 108 relocations, no
    duplicates. `SUPER + CTRL + V` (clipboard manager) and `SUPER + CTRL + C`
    (capture menu) are untouched.
  - foot's `foot.ini` binds `Control+Insert` to clipboard-copy, so a raw-byte
    probe sees nothing for ⌘C there; ⌘V arrives as the pasted text.
  - Handler tests: keylog got `c`, `v`, `x` with `mods=CTRL`; ⌘V pasted.
  - The user's physical tests (§8.2) passed, including ⌘V in the Omarchy
    launcher (S3 layer-shell retest) and the clipboard manager.
  - **Next:** ⌘⇧V (paste plain), then ⌘Z / ⌘⇧Z, ⌘A, find and save.
- **2026-10-02 — Phase 3: ⌘⇧V.**
  - Added `paste-plain` in `editing.lua`: `Ctrl+Shift+V` in GUI apps; terminals
    `Shift+Insert`. Not `repeating`. `SUPER + SHIFT + V` was free. 26
    bindings, 108 relocations, no duplicates.
  - Handler tests: keylog got `V` with `mods=CTRL+SHIFT`; a foot probe got the
    pasted text. keylog can't show plain versus rich paste.
  - The user's physical tests (§8.2) passed: rich text pastes plain in Brave,
    Chromium, Obsidian and VS Code. As expected, LibreOffice opens Paste
    Special, which 6f overrides.
  - **Next:** ⌘Z / ⌘⇧Z (undo, redo), then ⌘A, ⌘F, ⌘G / ⌘⇧G, ⌘S / ⌘⇧S.
- **2026-10-02 — Phase 3: ⌘Z / ⌘⇧Z.**
  - Added `undo` / `redo` in `editing.lua`: `Ctrl+Z` / `Ctrl+Shift+Z` in GUI
    apps, consumed in terminals (Ctrl+Z would suspend the foreground job),
    `repeating`. The keys were free (only ⌃⌘Z / ⌃⌥⌘Z zoom binds use Z). 28
    bindings, 108 relocations, no duplicates.
  - Handler tests: keylog got `z` with `mods=CTRL` and `Z` with
    `mods=CTRL+SHIFT`; a foot probe got no bytes.
  - The user's physical tests (§8.2) passed.
  - LibreOffice redo (`Ctrl+Y`) stays a 6f override.
  - **Next:** ⌘A (select all), then ⌘F, ⌘G / ⌘⇧G, ⌘S / ⌘⇧S.
- **2026-10-02 — Phase 3: ⌘A, ⌘S, ⌘⇧S.**
  - Added `select-all`, `save` and `save-as` in `editing.lua`: `Ctrl+A`,
    `Ctrl+S`, `Ctrl+Shift+S` in GUI apps, consumed in terminals (Ctrl+A is
    readline's line start, Ctrl+S freezes output). Not `repeating`. The keys
    were free (Omarchy's scratchpad and the ChatGPT / Google Maps launchers had
    already moved). 31 bindings, 108 relocations, no duplicates.
  - Handler tests: keylog got `a`, `s` with `mods=CTRL` and `S` with
    `mods=CTRL+SHIFT`; ⌘A selected all. A foot probe got no bytes for ⌘A and
    ⌘S; the ⌘⇧S probe lost focus and was skipped, so the physical test covers
    it.
  - The user's physical tests (§8.2) passed.
  - **Next:** find: ⌘F, ⌘G, ⌘⇧G. Then ⌘B / ⌘I / ⌘U and ⌘/.
- **2026-10-02 — Phase 3: find (⌘F, ⌘G, ⌘⇧G).**
  - Added `find`, `find-next` and `find-previous` in `editing.lua`: `Ctrl+F`,
    `F3` and `Shift+F3` in GUI apps, consumed in terminals. ⌘G / ⌘⇧G are
    `repeating`. The keys were free (group toggle and the Signal launcher had
    already moved). 34 bindings, 108 relocations, no duplicates.
  - Handler tests: keylog got `f` with `mods=CTRL`, `F3`, and `F3` with
    `mods=SHIFT`; a foot probe got no bytes.
  - The user's physical tests (§8.2) passed, in every browser tried.
  - LibreOffice (F3 is AutoText) and Nautilus (⌘⇧G is go-to-location) keep
    their overrides in 6f / 6d.
  - **Next:** ⌘B / ⌘I / ⌘U and ⌘/ (toggle comment), which finish Phase 3.
- **2026-10-02 — Phase 3: ⌘B / ⌘I / ⌘U and ⌘/. Phase 3 table complete.**
  - Added `bold`, `italic`, `underline` and `toggle-comment` in `editing.lua`:
    `Ctrl+B`, `Ctrl+I`, `Ctrl+U` and `Ctrl+/` in GUI apps, consumed in
    terminals (readline / Tab / line-kill keys). Not `repeating`. The keys were
    free (monitor scaling up had moved to ⌃⌥/ in 1a). 38 bindings, 108
    relocations, no duplicates.
  - Handler tests: keylog got `b`, `i`, `u` and `slash` with `mods=CTRL`
    (GTK's Ctrl+/ selected all); a foot probe got no bytes.
  - The user's physical tests (§8.2) passed (Brave, VS Code, foot and the
    rest). **One oddity:** ⌘U in Obsidian does something unexpected (looks like
    a jump table). Recorded as an open item under 6e.
  - Phase 3 acceptance extras were covered earlier: ⌘V in the Omarchy
    launcher, and the clipboard manager on ⌃⌘V is unaffected.
  - **Next:** Phase 4, window and tab controls.
- **2026-10-03 — Phase 4: ⌘W.**
  - New `windows.lua` (added to `config.modules`) with `close-tab`: ⌘W sends
    `Ctrl+W` in GUI apps and closes the window (`hl.dsp.window.close()`) in
    every terminal. Not `repeating`. `SUPER + W` was free (Omarchy's close
    moved to ⌃⌥W in 1a). 39 bindings, 108 relocations, no duplicates.
  - New, still empty `no-tabs` profile in `config.lua`: classes listed there
    get the close-window action too. Nothing needs it yet.
  - Deviation: the Ghostty/kitty `Ctrl+Shift+W` variant waits for 6a. Neither
    is installed, and the plan marks Ghostty's defaults "verify".
  - Handler tests: keylog got `w` with `mods=CTRL`. A foot probe window was
    closed (SIGHUP, no `^W` byte). With the keylog's class added to `no-tabs`
    in memory, the window closed and the app received no key. Each trigger
    checked the active window's pid in the same `repl` call.
  - The user's physical tests (§8.2) passed: keylog, Brave Origin, foot, hold
    and rapid presses, the other apps and the help menu. VS Code closes editor
    tabs (also in editor groups) but not the window once every editor is
    closed. That is native behaviour (§7, F3).
  - **Next:** ⌘⇧W (close window), then ⌘Q (quit app: every window of the
    class).
- **2026-10-03 — Phase 4: ⌘⇧W and ⌘Q.**
  - Added to `windows.lua`: `close-window` (⌘⇧W, `action{}` with
    `hl.dsp.window.close()`, same in every app) and `quit-app` (⌘Q, closes every
    mapped window whose class equals the active window's; a window with an
    empty class closes alone). Not `repeating`. Both keys were free (Omawrite
    moved off ⌘⇧W in 1c). 41 bindings, 108 relocations, no duplicates.
  - Deviation: ⌘⇧W uses the compositor close for browsers and VS Code too,
    instead of `Ctrl+Shift+W`. Same result, no VS Code profile needed.
  - Handler tests on throwaway windows (the user's six windows untouched):
    ⌘⇧W closed the focused keylog; ⌘Q closed both keylog windows and spared a
    window of another class; ⌘Q on two terminal-tagged foot windows
    (`-a org.omarchy.omackeytest`) closed both.
  - The user's physical tests (§8.2) passed, including Ghostty and kitty.
    ⌘Q closing every terminal window matches Terminal.app, iTerm2 and
    Ghostty on macOS, minus their close confirmation.
  - **Next:** ⌘N, ⌘⇧N, ⌘T, ⌘⇧T.
- **2026-10-03 — Phase 4: ⌘N, ⌘⇧N, ⌘T, ⌘⇧T.**
  - Added `new-window`, `new-window-private`, `new-tab` and `reopen-tab` to
    `windows.lua`: `Ctrl+N`, `Ctrl+Shift+N`, `Ctrl+T`, `Ctrl+Shift+T` in GUI
    apps. Terminals: ⌘N and ⌘T send `Ctrl+Shift+N` (new window; foot,
    Ghostty, kitty and Alacritty all bind it), ⌘⇧N and ⌘⇧T are consumed. Not
    `repeating`. The keys were free (editor launcher and toggle floating had
    moved). 45 bindings, 108 relocations, no duplicates.
  - Deviation: Ghostty/kitty ⌘T (`Ctrl+Shift+T`) waits for 6a, like ⌘W.
  - Handler tests: keylog got `n`, `N`, `t`, `T` with `CTRL` / `CTRL+SHIFT`;
    in a foot probe ⌘N and ⌘T opened a new window and the other two sent
    nothing. My cleanup of the spawned test windows was denied by the
    permission check, so the user closed them.
  - The user's physical tests (§8.2) passed.
  - **Next:** ⌘O / ⌘P / ⌘R / ⌘L, then zoom (⌘= ⌘+ ⌘- ⌘0).
- **2026-10-03 — Phase 4: ⌘O, ⌘P, ⌘R, ⌘L.**
  - Added `open`, `print`, `reload` and `location` to `windows.lua`:
    `Ctrl+O`, `Ctrl+P`, `Ctrl+R`, `Ctrl+L` in GUI apps, consumed in terminals
    (readline history, reverse search and clear screen). Not `repeating`. The
    keys were free (pop window, pseudo and layout toggle moved in 1a). 49
    bindings, 108 relocations, no duplicates.
  - Each key is its own explicit `mac{}` block, like every other bind, so
    Phase 6 can add per-app entries to any one of them. A first version used a
    shared helper; the user rejected it for that reason.
  - Handler tests: keylog got `o`, `p`, `r`, `l` with `mods=CTRL`; a foot probe
    got no bytes.
  - The user's physical tests (§8.2) passed.
  - **Next:** zoom (⌘= ⌘+ ⌘- ⌘0).
- **2026-10-03 — Phase 4: zoom (⌘=, ⌘+, ⌘-, ⌘0).**
  - Committed ⌘O/⌘P/⌘R/⌘L first (3857d2c).
  - Added `zoom-in`, `zoom-in-plus`, `zoom-out` and `zoom-reset` to
    `windows.lua`: `Ctrl+equal` (both ⌘= and ⌘+), `Ctrl+minus`, `Ctrl+0` in
    every app, terminals included (no terminal entry: foot and Ghostty bind
    these to font size). Not `repeating`. The keys were free (Omarchy's resize
    binds moved to ⌃⌥ in 1a). 53 bindings, 108 relocations, no duplicates.
  - Descriptions carry "(app)": Omarchy's desktop zoom is also called "Zoom in"
    and "Reset zoom" (⌃⌘Z).
  - Handler test in a private keylog copy: `equal` twice, `minus`, `0` with
    `mods=CTRL`, released cleanly. Not tested in foot (font size has no byte
    to probe).
  - The user's physical tests (§8.2) passed. ⌘0 does not reset VS Code zoom;
    that is native (§9 F4), with an optional 6c override.
  - **Next:** ⌘[ / ⌘], then ⌘1–⌘9 and the tab-switching keys.
- **2026-10-03 — Phase 4: ⌘[ and ⌘].**
  - Committed zoom first (3ca4e40).
  - Added `back` and `forward` to `windows.lua`: `Ctrl+[` / `Ctrl+]` by
    default (outdent and indent in VS Code and Obsidian), `Alt+Left/Right` in
    browsers and Nautilus, consumed in terminals (Ctrl+[ is Escape there). Not
    `repeating`. The keys were free (webcam binds moved in 1a). New `nautilus`
    profile in `config.lua`. 55 bindings, 108 relocations, no duplicates.
  - The help menu cut the description "Back, or outdent" at the comma, so
    descriptions avoid commas.
  - Handler tests: keylog got `bracketleft` / `bracketright` with `mods=CTRL`
    (default profile); a foot probe got no bytes. Browser and Nautilus
    profiles resolve to the right chains for the open windows; the `Alt+Left`
    send itself is the same `tap` already tested, so physical tests cover it.
  - The user's physical tests (§8.2) passed.
  - **Next:** ⌘1–⌘9 (tab N).
- **2026-10-03 — Phase 4: ⌘1–⌘9.**
  - Committed ⌘[ / ⌘] first (0077262).
  - Added `tab-1` … `tab-9` to `windows.lua`: `Ctrl+N` in GUI apps (browsers
    and VS Code treat ⌘9 / `Ctrl+9` as the last tab or the ninth), consumed in
    terminals; Ghostty's `Alt+N` comes in 6a. Written as a loop over digits, as
    in `spaces.lua`, each bind with its own `actions` table. Not `repeating`.
    The keys were free (workspace switching moved to ⌃1–0 in 1b). 64
    bindings, 108 relocations, no duplicates.
  - Handler tests: keylog got `1`…`9` with `mods=CTRL` and the workspace did
    not change (synthetic Ctrl+N never reaches the ⌃N workspace binds); a foot
    probe got no bytes.
  - The user's physical tests (§8.2) passed. Two notes: VS Code goes to the
    editor *group* (its own default, same as macOS), and Nautilus seemed to do
    nothing with tabs open. I checked with a throwaway Nautilus: ⌘1 / ⌘2 switch
    list / grid view (Finder's ⌘1 / ⌘2 are icons / list), and Nautilus tabs by
    number are `Alt+N`. Finder has no tab numbers. Findings in §9 F5; the swap
    is a 6d item.
  - **Next:** ⌘⇧[ / ⌘⇧] and ⌘⌥← / ⌘⌥→ (previous / next tab).
- **2026-10-03 — Phase 4: ⌘⇧[ / ⌘⇧] and ⌘⌥← / ⌘⌥→.**
  - Committed ⌘1–⌘9 first (cd9900c).
  - Added `previous-tab`, `next-tab` (⌘⇧[ , ⌘⇧]) and `previous-tab-arrow`,
    `next-tab-arrow` (⌘⌥←, ⌘⌥→) to `windows.lua`: `Ctrl+Page_Up` /
    `Ctrl+Page_Down` in GUI apps (browsers, VS Code and Nautilus all use them),
    consumed in terminals until 6a. Not `repeating`. The keys were free (webcam
    binds and group moves moved in 1a). 68 bindings, 108 relocations, no
    duplicates. Obsidian's ⌘⌥← / ⌘⌥→ become back/forward in 6e.
  - Handler tests: keylog got `Page_Up` / `Page_Down` with `mods=CTRL`, once
    per handler; a foot probe got no bytes.
  - The user's physical tests (§8.2) passed.
  - **Next:** ⌘Tab / ⌘⇧Tab (switch window).
- **2026-10-03 — Phase 4: ⌘Tab and ⌘⇧Tab.**
  - Committed ⌘⇧[ / ⌘⇧] and ⌘⌥← / ⌘⌥→ first (a6a8c40).
  - First version cycled the workspace's windows with `cycle_next`. The user
    pointed out that ⌘Tab on a Mac switches *apps* by recency, so two apps can
    be flipped between. Replaced it.
  - `windows.lua` now has `switch-app` (⌘Tab) and `switch-app-oldest`
    (⌘⇧Tab). An app is a window class, as in ⌘Q. Each app is represented by its
    most recently focused window, ordered by `focus_history_id` (§9 F6).
    ⌘Tab focuses the newest app other than the one in front, and ⌘⇧Tab the
    oldest, so repeating ⌘⇧Tab walks through every app. The window switches
    workspace when needed. A floating target is raised. Scratchpad and hidden
    windows are skipped. Not `repeating`. The keys were free (workspace
    switching moved to ⌃⌥← / ⌃⌥→ in 1b; ⌥Tab still cycles windows). 70
    bindings, 108 relocations, no duplicates.
  - Not supported (§7): the overlay, and holding ⌘ to step deeper.
  - Test on the user's live windows (focus changes only, no keys sent; focus
    restored afterwards): ⌘Tab went from VS Code (workspace 2) to Nautilus
    (5) and back; ⌘⇧Tab went to foot (1), then Obsidian (5). Each target
    matched an independent computation from `hyprctl clients -j`.
  - The user's physical tests (§8.2) passed. They want deeper ⌘Tab stepping
    later: noted as 7i.
  - **Next:** ⌘` / ⌘⇧` (cycle the active app's windows).
- **2026-10-03 — Phase 4: ⌘` and ⌘⇧`.**
  - Committed ⌘Tab / ⌘⇧Tab first (ab4f815). The user's wish to step deeper
    with ⌘ held is recorded as 7i.
  - Added `next-app-window` and `previous-app-window` to `windows.lua`: the
    windows of the active window's class (every workspace, scratchpad and
    hidden ones left out) in `stable_id` order, wrapping; the target gets
    focus, switching workspace if needed, and a floating one is raised. Not
    `repeating`. The keys were free. 72 bindings, 108 relocations, no
    duplicates. `focus_window()` is now shared with ⌘Tab.
  - Tests on the user's live windows (focus changes only; focus restored):
    Brave (4 windows on workspaces 1 and 3), VS Code (2, on 2 and 4) and
    Nautilus (3) were each walked forward and backward past the wrap-around and
    matched the `stableId` order from `hyprctl clients -j`. Obsidian, with one
    window, stayed put.
  - The user's physical tests (§8.2) passed.
- **2026-10-03 — Phase 4: ⌘Tab hold-⌘ stepping (7i brought forward).**
  - Committed ⌘` / ⌘⇧` first (e6a1442).
  - ⌘Tab now runs a session: the first press builds a ring (front app, then
    the others by recency), each press steps along it (⌘Tab forward, ⌘⇧Tab
    back; from the front app ⌘⇧Tab reaches the oldest app), and the focus
    change is the feedback. The session ends when ⌘ is released (keycodes 133 /
    134 on `input.keyboard.key`, subscribed only during a session). The app you
    stopped on becomes the most recent and the rest keep their order. Renamed
    `switch-app-oldest` to `switch-app-back`. 72 bindings, 108 relocations, no
    duplicates.
  - The user tested a first version (it worked) and called it hacky: loose
    module variables reassigned by closures, test hooks bolted onto the bind
    spec, a timer with a generation counter, and a ring of window objects that
    go stale. Rewrote it as `lib/switcher.lua`: one state table, a ring of app
    names looked up again at every step, no timer, and `snapshot()` / `finish()`
    as the test interface. `windows.lua` only binds the keys and `switcher.focus`
    is shared with ⌘`.
  - Tests on the user's live windows (focus changes only, no keys sent; focus
    restored; throwaway `foot -a omackey.*` windows):
    - model of the macOS behaviour: tap, tap back, hold forward ×3, forward ×2
      then back, back ×1, back ×3 and forward ×7 (wrapping) all matched, and so
      did the order after each session;
    - changes outside the keyboard: focus changes outside a session are
      recorded; an app closing mid-session is skipped; closing the current stop
      restarts from where focus landed; a click on another app mid-session and
      a new window opening mid-session restart and flip back to where we came
      from; new apps are in the next ring. The suite passed 6 of 7 runs; the
      one failure was a timing race in the test (the closing window was still
      mapped when the step ran).
    - Sessions ended through `switcher.finish()`, because a script can't
      release ⌘. A self-removing subscription works inside its own callback.
  - The user's physical retest passed ("works perfectly"). An optional QuickShell
    overlay with app icons is noted as 7j.
  - **Next:** ⌘M and ⌘H (minimize and hide); the restore design needs a decision
    with the user first.
- **2026-10-03 — Phase 4: ⌘M and ⌘H dropped (D13).**
  - Asked how hidden windows should come back (⌘Tab restore, chosen), built it
    (a `special:minimized` workspace, `lib/minimized.lua`, ⌘Tab restoring
    minimized apps, ⌃⌥M view, all tested), then the user asked whether Omarchy
    or a tiling window manager has minimize at all.
  - Checked: no minimize in Omarchy or the Hyprland Lua API, and the web agrees
    (§9 F7). Without a dock there is no natural way to see or click a minimized
    window. Decision D13: drop ⌘M, ⌘H, ⌘⌥H and ⌥⌘M; the scratchpad stays the
    native way. The uncommitted work was reverted to `adf3543` (nothing from it
    is in the repo). §6.1's ⌃⌥M row is gone, §7 and 7a updated.
  - Test note: the ⌘Tab case "a dead app in the ring is skipped" had failed in
    2 of about 8 runs with a fixed 0.6 s wait after killing the throwaway
    window. Waiting until the window is gone from `hyprctl clients` made it pass
    6 of 6, so the failures were the closing window still being mapped. In real
    use, pressing ⌘Tab in the instant after closing a window can still target
    that closing window; focus then falls back, which is harmless.
  - **Lesson:** I took the plan's ⌘M and ⌘H rows as settled and asked only how
    to implement them. For keys whose Linux counterpart is doubtful, ask whether
    to map them at all.
  - **Next:** ⌘, (preferences), the last Phase 4 row.
- **2026-10-03 — Phase 4: ⌘,.**
  - Committed the D13 docs first (b21a5ae).
  - Added `preferences` to `windows.lua`: `Ctrl+comma` in GUI apps, consumed in
    terminals. Not `repeating`. `SUPER + comma` was free (Omarchy's dismiss-last
    moved in 1d; the other notification binds use other modifiers). 73 bindings,
    108 relocations, no duplicates.
  - Handler tests: keylog got `comma` with `mods=CTRL`; a foot probe got no
    bytes.
  - The user's physical tests (§8.2) passed. **Phase 4 is complete.**
  - Phase 4 in short: `windows.lua` (73 bindings in total, 108 relocations, no
    duplicates) with ⌘W / ⌘⇧W / ⌘Q, ⌘N / ⌘⇧N / ⌘T / ⌘⇧T, ⌘O / ⌘P / ⌘R / ⌘L,
    ⌘1–⌘9, zoom, ⌘[ / ⌘], tab switching, ⌘Tab app switching (`lib/switcher.lua`),
    ⌘` and ⌘,. ⌘M and ⌘H were dropped (D13).
  - **Carried into later phases** (each is in its own table already):
    - 6a: Ghostty and kitty tab keys (⌘W `Ctrl+Shift+W`, ⌘T `Ctrl+Shift+T`,
      ⌘1–9 `Alt+N`, tab switching `Ctrl+Page_Up/Down`, ⌘, `Ctrl+comma`). For
      now ⌘W closes their window and ⌘T opens a new one.
    - 6b: ⌘, in browsers; Firefox ⌘⇧N → `Ctrl+Shift+P`.
    - 6c: optional VS Code ⌘0 → `Ctrl+KP_0` (§9 F4).
    - 6d: Nautilus ⌘1 / ⌘2 swapped to match Finder, ⌘3 / ⌘4 consumed (§9 F5).
    - 6e: Obsidian ⌘⌥← / ⌘⌥→ back / forward, and the ⌘U oddity.
    - 6f: LibreOffice ⌘, → `Alt+F12`.
    - 7a: consume ⌘M and ⌘H (D13). 7j: optional ⌘Tab overlay. 8.3: watch for
      Omarchy adding `Super + Grave` (§9 F7).
  - **Next:** Phase 5 (OS controls) and Phase 6 (app-specific), in a later
    session. Start with the Status board and this entry.
- **2026-10-03 — Phase 5: ⌃⌘Q.**
  - Asked about the doubtful keys: ⌘⌥Esc is mapped as a direct kill; ⌘⇧Q is not
    mapped (§7).
  - New `system.lua` (added to `config.modules`) with `lock-screen`: ⌃⌘Q runs
    `omarchy-system-lock` through `action{}`. `SUPER + CTRL + Q` was free
    (calculator moved in 1d). 74 bindings, 108 relocations, no duplicates; the
    help menu shows "Lock screen".
  - Not triggered by me, as it would lock the screen. Awaiting the user's
    physical test.
  - **Next:** screenshots (⌘⇧3/4/5 and the ⌃⌘⇧ clipboard variants), then ⌘⌥Esc,
    emoji, ⌥⌘D, and the verify-only items.
- **2026-10-03 — Phase 5: ⌘⇧3 and ⌃⌘⇧3.**
  - Committed ⌃⌘Q first (82fc9e5; the user's test passed).
  - Added `screenshot-screen-file` (`fullscreen save`) and
    `screenshot-screen-clipboard` (`fullscreen copy`) to `system.lua`. Keys were
    free. 76 bindings, 108 relocations, no duplicates; the help menu shows both.
  - Handler test: the file variant wrote a 3840×2160 PNG (deleted afterwards).
    The clipboard variant was not triggered, to keep the user's clipboard.
  - **Next:** ⌘⇧4 / ⌃⌘⇧4 (region), ⌘⇧5 (capture menu).
- **2026-10-03 — Phase 5: ⌘⇧4 and ⌃⌘⇧4.**
  - Committed ⌘⇧3 / ⌃⌘⇧3 first (502d7fe; the user's tests passed).
  - Added `screenshot-region-file` (`region save`) and
    `screenshot-region-clipboard` (`region copy`) to `system.lua`. Keys were
    free. 78 bindings, 108 relocations, no duplicates; the help menu shows both.
  - Handler test: the picker (slurp) starts and I closed it without capturing.
    Dragging a region, Return and the saved file are left to the physical test.
  - **Next:** ⌘⇧5 (capture menu), then ⌘⌥Esc, emoji, ⌥⌘D, verify-only items.
- **2026-10-03 — Phase 5: ⌘⇧5.**
  - Committed ⌘⇧4 / ⌃⌘⇧4 first (8a85649; the user's tests passed).
  - Added `capture-menu` to `system.lua`: ⌘⇧5 runs `omarchy-menu toggle
    capture`. Key was free. 79 bindings, 108 relocations, no duplicates.
  - Not triggered by me (it opens a menu over the user's screen); awaiting the
    physical test.
  - **Next:** ⌘⌥Esc (force quit), then emoji, ⌥⌘D, verify-only items.
- **2026-10-03 — Phase 5: ⌘⌥Esc.**
  - Committed ⌘⇧5 first (44595c3; the user's tests passed).
  - Added `force-quit` to `system.lua`: `hl.dsp.window.kill()` on the active
    window (SIGKILL, no dialog), as agreed with the user. `SUPER + ALT + ESCAPE`
    was free. 80 bindings, 108 relocations, no duplicates.
  - Handler test on a throwaway `foot -a omackey.killtest sleep 300`, focused by
    pid and guarded by pid in the same `repl` call: the process died.
  - **Next:** ⌃⌘Space (emoji), ⌥⌘D (bar toggle), then the verify-only items.
- **2026-10-03 — Phase 5: ⌃⌘Space.**
  - Committed ⌘⌥Esc first (the user's tests passed).
  - Added `emoji-picker` to `system.lua`: ⌃⌘Space runs `omarchy-shell shell
    toggle omarchy.emojis`. `SUPER + CTRL + SPACE` was free (background switcher
    moved in 1d). 81 bindings, 108 relocations, no duplicates.
  - Not triggered by me (opens an overlay on the user's screen); awaiting the
    physical test.
  - **Next:** ⌥⌘D (bar toggle), then the verify-only items.
- **2026-10-03 — Phase 5: ⌥⌘D.**
  - Committed ⌃⌘Space first (af7fe38; the user's tests passed).
  - Added `toggle-bar` to `system.lua`: ⌥⌘D runs `omarchy-toggle-bar`, the same
    command as Omarchy's ⌘⇧Space (`bind_toggle("bar")`), so both toggle the top
    bar. `SUPER + ALT + D` was free. 82 bindings, 108 relocations, no
    duplicates.
  - Handler test: two triggers; the `bar-off` flag appeared, then cleared, so
    the bar ended as it began.
  - **Next:** the verify-only items (⌘Space, ⌘⌥Space, ⌘?, ⌃⌘F, F-row keysyms).
- **2026-10-03 — Phase 5: F-row.**
  - Committed ⌥⌘D first (1ca7004; the user's tests passed).
  - Probed the NuPhy's F-row keycodes (§9 F9). Decisions with the user: F3
    unbound (§7), F6 → Do Not Disturb, F5 → voxtype toggle.
  - Added `do-not-disturb` (F6, `XF86DoNotDisturb`) and `dictation` (F5,
    `XF86VoiceCommand`, present only when `voxtype` exists) to `system.lua`.
    83 bindings (F5 is not registered here), 108 relocations, no duplicates.
  - Handler test: `omarchy-shell notifications toggleDnd` printed `on`, then
    `off`; two triggers of the bind net out to off. F5 is untested (voxtype not
    installed).
  - **Open:** the user's results for the verify-only chords (⌘Space, ⌘⌥Space,
    ⌘?, ⌃⌘F, F4) and the physical F6 test. Then Phase 5 is done, apart from
    those ticks.
- **2026-10-03 — Phase 5: F5 push-to-talk, verify-only items.**
  - The user confirmed ⌘Space (Omarchy menu), ⌘⌥Space (apps menu), ⌘?, ⌃⌘F, and
    F4 (⌘Space) all do their expected action, and F6 silences notifications.
  - The user installed voxtype and asked for F5 = push-to-talk and ⇧F5 = toggle
    (both without Fn, in Mac mode). Replaced `dictation` with
    `dictation-start` / `dictation-stop` (release) / `dictation-toggle`
    (`SHIFT + XF86VoiceCommand`). `action{}` in `lib/bind.lua` now passes
    `release` through. 86 bindings, 108 relocations, no duplicates;
    `hyprctl binds` shows the stop bind with `release=true`.
  - Not triggered by me (it would record the microphone). The user's physical
    tests passed. **Phase 5 is complete.**
  - Phase 5 in short: `system.lua` (86 bindings in total, 108 relocations, no
    duplicates) with ⌃⌘Q lock, ⌘⇧3/4 and ⌃⌘⇧3/4 screenshots, ⌘⇧5 capture menu,
    ⌘⌥Esc force quit, ⌃⌘Space emoji, ⌥⌘D bar, and F5/⇧F5/F6. ⌘⇧Q and F3 are
    unmapped (§7).
  - **Next:** Phase 6, app-specific (6a terminals first), in a later session.
- **2026-10-03 — Phase 6a: terminals.**
  - Read PLAN.md and CLAUDE.md in full, then checked the real keybinds of
    Ghostty 1.3.1, kitty 0.48.2 and foot 1.28 (§9 F10). Findings that changed the
    plan: macOS ⌘↑/⌘↓ jump between prompts (not scroll), kitty's zoom keys carry
    Shift (Phase 4's zoom did nothing in kitty), kitty has no key for tab N, and
    ⌘G only means something inside an open search.
  - Decisions with the user: kitty is included (widens D10); ⌘↑/⌘↓ jump prompts
    in Ghostty and scroll a page elsewhere; ⌘K clears the screen (`Ctrl+L`); no
    edits to the terminals' config files, so the gaps go to §7.
  - Code: profiles `ghostty`, `kitty`, `foot` (family `terminal`) in
    `config.lua`; per-terminal entries on ⌘T, ⌘W, ⌘1–9, the four tab-switch keys,
    zoom ×4 and ⌘, (`windows.lua`), ⌘A and ⌘F (`editing.lua`), ⌘↑ and ⌘↓
    (`text.lua`; the generic terminal action is now `Shift+Page_Up/Down`); new
    `terminals.lua` with ⌘K, ⌘D, ⌘⇧D (added to `config.modules`). 89 bindings,
    108 relocations, no duplicates; the help menu shows the new keys.
  - Handler tests on throwaway windows (pid-guarded, each killed afterwards; the
    user's windows only had focus restored):
    - Ghostty: ⌘T, ⌘1/⌘2/⌘9, ⌘⇧[ ], ⌘⌥← → and ⌘W moved between the right tabs
      (read from the window title); ⌘D split the window and ⌘F opened the find
      bar (screenshot); ⌘⇧D and ⌘A ran; ⌘K sent `0c`.
    - kitty: zoom 202 → 165 → 140 → 165 → 202 columns; ⌘T, ⌘⇧[ ], ⌘⌥← →, ⌘W
      right; ⌘2 and ⌘D consumed; ⌘F opened kitty's search prompt; ⌘K sent `0c`.
    - foot: ⌘↑ scrolled back one page and ⌘F opened the search box
      (screenshots).
    - Not triggered: ⌘, (opens an editor on a config file), and Ghostty's
      ⌘↑/⌘↓ prompt jump (nothing to see in an empty shell). Both are left to
      the physical test.
  - **Fix after the user's test:** Ghostty ⌘, did nothing. Cause and removal are
    in §9 F10: the Ghostty entry is gone, ⌘, is consumed there again. My test had
    only checked that the handler ran ("handled"), and a first retest hit the
    user's own Ghostty by mistake, because it is D-Bus activated and did not show
    up in my launch diff (the second retest used the right pid). Lasting
    effect: about 24 hidden `nvim` processes under the user's Ghostty from their
    own ⌘, presses, left untouched and reported to them.
  - **Ghostty ⌘, rebound (user's choice):** it now runs `omarchy-launch-editor
    "$HOME/.config/ghostty/config"` from a function in the `preferences` entry. Test
    this time watched the window list: one new `org.omarchy.nvim` window (a kitty
    window, the user's TUI terminal) opened with `nvim ~/.config/ghostty/config`;
    I closed it by address, and the throwaway Ghostty by pid.
  - The user's physical tests (§8.2) in foot, Ghostty and kitty passed. **6a is
    complete.** Committed.
  - **Next:** 6b, browsers.
- **2026-10-04 — Phase 6b: browsers.**
  - Committed 6a first (7e800df) after the user's manual tests passed.
  - Checked the keys against Chrome's Mac/Linux shortcut page and Firefox's
    DevTools docs (§9 F11). Decisions with the user: add ⌘⇧⌫ (clear browsing
    data); Firefox ⌘⇧J follows Chrome (`Ctrl+Shift+Y`); ⌘, opens settings
    through the browser CLI. ⌘⌥K dropped: Omarchy owns `SUPER + ALT + K`.
  - Code: profile `firefox` (family `browser`); new `browsers.lua` with
    `devtools` (all GUI apps, terminals consume), `devtools-console`,
    `devtools-inspect`, `view-source`, `history`, `downloads`,
    `clear-browsing-data`, `bookmark-manager`; Firefox entries on ⌘⇧N and ⌘,
    (`windows.lua`). 97 bindings, 108 relocations, no duplicates; the help menu
    lists them.
  - **Deviation from the choice made on ⌘,:** the CLI route does not work in the
    Chromium family (`chrome://` becomes a blank tab, §9 F11), so I came back to
    the user; they chose to leave Chromium-family ⌘, unmapped (§7) and keep the
    CLI for Firefox only. The `browser_settings` map was removed again.
  - Handler tests on throwaway browsers with their own profiles (the user's
    Brave was not touched):
    - Chromium: ⌘Y, ⌘⇧J, ⌘⌥B, ⌘⌥U, ⌘⇧⌫ opened the history, downloads,
      bookmarks, view-source and clear-data pages (tab list from the debugging
      port); ⌘⌥I, ⌘⌥J, ⌘⌥C opened and toggled DevTools.
    - Firefox: ⌘⇧J opened the Library, ⌘⇧⌫ the clear-data dialog, ⌘⇧N a private
      window, ⌘⌥B the Library, ⌘⌥U a view-source tab, ⌘Y the history sidebar,
      ⌘⌥I the toolbox (screenshots/window titles).
    - Not triggered: ⌘, in Firefox (it would start or use the user's own Firefox
      profile; the command itself was run by hand against the throwaway
      profile), and any key in Brave Origin (same `browser` profile as Chromium).
  - **Open:** the user's physical tests (§8.2) in Brave Origin, Chromium and
    Firefox.
  - **Next:** 6c, VS Code.
  - The user's physical tests passed for the browsers and Obsidian. ⌘⌥I did
    nothing in VS Code: Linux VS Code binds `Ctrl+Shift+I` to Format Document
    too, which wins with the editor focused (§9 F11). New `vscode` profile
    (`config.lua`, reused by 6c); ⌘⌥I is consumed there so it can never reformat
    a file. **6b is complete.**
- **2026-10-05 — VS Code ⌘C / ⌘V (the user's change in `editing.lua`).**
  - The user added `vscode` actions to `copy` and `paste`: `Ctrl+Insert` and
    `Shift+Insert`, the terminal chords, because the integrated terminal can't
    be told apart from the editor (§9 F12).
  - PLAN.md only: §5 Phase 3 rows, the 6c table, a §7 row for the other ⌘ keys
    in the integrated terminal, and F12. No code touched in this session.
  - I did not test it. The `vscode` profile and the key names already exist.
    Two things to check: the comment in the code has a typo ("distinguisdh"),
    and the user's physical test is still open (§8.2: ⌘C / ⌘V in a VS Code
    editor and in its integrated terminal).
  - **Next:** 6c, VS Code.
- **2026-10-05 — Phase 6c: VS Code.**
  - Read PLAN.md and CLAUDE.md in full, then checked VS Code's real chords in the
    installed `workbench.desktop.main.js` (§9 F13). The plan's column-select row
    would have sent Copy Line Up/Down, so I asked first. Decisions with the
    user: drop column select (§7), map ⌘0 (`Ctrl+KP_0`), do not map the physical
    ⌃- / ⌃⇧-.
  - Code: new `vscode.lua` (added to `config.modules`) with `add-cursor-above`,
    `add-cursor-below`, `fold`, `unfold`, `replace`, `shrink-selection`,
    `expand-selection`, `quick-fix`, all only for profile `vscode` (other apps
    still get the raw ⌘ chord); `vscode` action on `zoom-reset` in `windows.lua`;
    `kp_0` in `lib/keys.lua`. 105 bindings, 108 relocations, no duplicates; the
    help menu lists them.
  - Handler tests: a private keylog copy with its class added to the `vscode`
    profile in memory got `Up` / `Down` and `braceleft` / `braceright` with
    `CTRL+SHIFT`, `h` with `CTRL`, `Left` / `Right` with `ALT+SHIFT`, `period`
    with `CTRL`, and `KP_Insert` (code 90) with `CTRL`. I did not drive the
    user's VS Code, so the editor effect is left to the physical test.
  - The user's physical tests (§8.2) in VS Code passed. **6c is complete.**
  - **Next:** 6d, Nautilus.
- **2026-10-05 — Phase 7a: catch-all (ahead of 6c-2 / 6d–6f).**
  - Committed 6c first (e560ea6; the user's VS Code tests passed). Asked whether
    VS Code was finished: 6c only covers chords that differ from the Mac's
    Ctrl form. Added 6c-2, then, at the user's question about Obsidian and the
    others having the same gap, moved 7a ahead of the per-app audits (Phase 7's
    other items stay after Phase 6). Catch-all through xkb was ruled out: xkb is
    global and per-app behaviour (terminals, VS Code) is the point.
  - Decisions with the user: consume ⌘⇧I, ⌘⇧U and ⌘⇧H (on top of ⌘H, ⌘M, ⌘⇧Q);
    short descriptions in the help menu; terminals consume.
  - Code: `lib/relocate.lua` records `claimed` keys; new `catchall.lua`
    (last in `config.modules`). 136 bindings, 108 relocations, no duplicates;
    the help menu lists them ("sent as Ctrl+E", "not mapped").
  - Handler tests in a private keylog copy: ⌘E, ⌘⇧P, ⌘⏎, ⌘⇧-, ⌘; arrived as
    `Ctrl` / `Ctrl+Shift` chords with no SUPER; ⌘H, ⌘⇧Q, ⌘⇧I and ⌘⇧U sent
    nothing; with the terminal profile matched, ⌘E and ⌘⇧P sent nothing.
  - **Open:** the user's physical tests (§8.2) of a sample of the new keys in
    Brave, VS Code, foot and Obsidian (e.g. ⌘E, ⌘J, ⌘⇧P, ⌘⇧E, ⌘⏎, ⌘⇧H).
  - **Next:** 6c-2 (VS Code audit against the catch-all), then 6d–6f.
- **2026-10-05 — Phase 6c-2: VS Code keymap audit.**
  - Committed 7a first (e7c7c11; the user said to continue, physical tests of
    the new keys not reported yet).
  - Extracted VS Code's keybindings from the installed `workbench.desktop.main.js`
    and diffed the Mac and Linux keymaps (§9 F15). **Found a 7a bug:** keys
    another module had claimed for specific apps only (⌘K, ⌘D, ⌘⇧D, ⌘Y, ⌘⇧J,
    ⌘.) did nothing outside them, so VS Code got the raw ⌘ chord and every ⌘K
    chord failed. `catchall.lua` now gives those specs the default (Ctrl chord,
    consume in terminals).
  - Decisions with the user: add copy line (⌥⇧↑ / ↓), block comment (⌥⇧A),
    ⌘⇧- zoom out, and the find-widget toggles plus ⌘⌥B; leave ⌘E as Ctrl+E.
  - Code: eight entries in `vscode.lua`, `vscode` actions on `devtools-inspect`
    and `bookmark-manager` in `browsers.lua`. 143 bindings, 108 relocations, no
    duplicates.
  - Handler tests in a private keylog copy matched to the `vscode` profile: all
    sent the right chords (`Up` with `CTRL+ALT+SHIFT`, `A` with `CTRL+SHIFT`,
    `minus` with `CTRL`, `w` / `r` / `l` / `p` / `c` with `ALT`, `b` with
    `CTRL+ALT`), and the claimed-key fix sent `k`, `d`, `D`, `y`, `J`, `period`.
  - The user's physical tests passed in VS Code. The 7a sample keys passed too:
    - Brave: ⌘E focuses the address bar, ⌘J opens downloads, ⌘⇧H does
      nothing and typing is normal afterwards.
    - foot: ⌘E, ⌘J, ⌘⇧P, ⌘⏎ do nothing.
    - Obsidian: ⌘E toggles read / edit; ⌘⇧P and ⌘⏎ do nothing (no Obsidian
      command on those keys); holding ⌘H and ⌘⇧H does nothing and nothing
      repeats.
  - **One difference, left as is (user's choice):** ⌘⇧P in the Chromium family
    opens the system print dialog (`Ctrl+Shift+P` on Linux). On the Mac that
    dialog is ⌥⌘P and ⌘⇧P does nothing in Chrome.
  - **Next:** 6d, Nautilus (a diff against the catch-all, then explicit
    entries).
- **2026-10-05 — Phase 6d: Nautilus (built).**
  - Read PLAN.md and CLAUDE.md in full. Scope as in the 6d table, except ⌘I:
    the generic `Ctrl+I` already opens Properties, so no entry.
  - Code: `nautilus` actions on `document-start` / `document-end` /
    `delete-line-start` (`text.lua`), `find-previous` (`editing.lua`),
    `tab-1`…`tab-9` (`windows.lua`: ⌘1 / ⌘2 swapped, rest consumed); new
    `nautilus.lua` (⌘⇧. → `Ctrl+H`), added to `config.modules`. 143 bindings
    (the catch-all's ⌘⇧. is replaced), 108 relocations, no duplicates; the help
    menu lists "Show hidden files (Files)".
  - Handler tests on a throwaway Nautilus: see 6d. ⌘⇧. is unconfirmed.
  - The user's physical tests (§8.2) in Nautilus passed, ⌘⇧. included. **6d is
    complete.**
  - **Next:** 6e, Obsidian.
- **2026-10-05 — Phase 6e: Obsidian (built).**
  - Committed 6d first (130dc6e; the user's Nautilus tests passed, ⌘⇧. included).
    On the user's question, ⌘⇧[ / ⌘⇧] stay previous / next tab in Nautilus, as in
    Finder.
  - Read Obsidian's keymap from its `app.js` (§9 F16). The plan's class
    `obsidian` is `md.obsidian.Obsidian` here. ⌘U is undo-selection on the Mac
    too, so the Phase 3 "oddity" needs nothing.
  - Code: profile `obsidian` (`config.lua`); `obsidian` actions on
    `previous-tab-arrow` / `next-tab-arrow` (`windows.lua`), `add-cursor-above` /
    `-below`, `replace` (`vscode.lua`); new `obsidian.lua`
    (⌘⇧U → `Alt+U`). 143 bindings, 108 relocations, no duplicates. I added the
    cursor, replace and redo-selection keys beyond the plan's list because
    the audit showed the same gaps as VS Code; say if you'd rather drop them.
  - Handler tests in a private keylog copy: all eight sent the right chords.
  - The user's physical tests passed except ⌘⌥[ / ⌘⌥]: Obsidian has no fold
    hotkey (F16), so those two entries were removed. **6e is complete.**
  - **Next:** 6f, LibreOffice.
- **2026-10-05 — Phase 6f: LibreOffice (built).**
  - Committed 6e first (6020f9b) after the user's tests: back / forward only act
    within one tab's history, and ⌘⌥[ / ⌘⌥] were removed because Obsidian has no
    fold hotkey (F16).
  - Read LibreOffice's accelerators from `main.xcd` (§9 F17). Findings that
    changed the plan: Redo is already `Ctrl+Shift+Z` (no ⌘⇧Z override); the
    generic ⌘G / ⌘⇧G sent `F3` / `Shift+F3` (AutoText, change case): ⌘G now
    sends `Ctrl+Shift+F` and ⌘⇧G is consumed.
  - Code: profile `libreoffice` (`config.lua`); `libreoffice` actions on
    `find-next`, `find-previous`, `paste-plain` (`editing.lua`) and
    `preferences` (`windows.lua`); new `libreoffice.lua` (⌘⌥V paste special).
    144 bindings, 108 relocations, no duplicates.
  - Tests: see 6f.
  - The user's physical tests passed. **6f is complete, and with it Phase 6.**
  - **Next:** Phase 7 leftovers (7b ⌘. → Escape, then 7c–7h) and Phase 8.
- **2026-10-05 — Phase 7b: ⌘. cancel.**
  - Committed 6f first (13fb910; the user's LibreOffice tests passed, which
    completes Phase 6).
  - Replaced VS Code's `quick-fix` entry (`vscode.lua`) with a generic `cancel` on
    ⌘. in `editing.lua`: `Escape` in GUI apps, `Ctrl+C` in terminals,
    `Ctrl+period` in VS Code. 144 bindings, 108 relocations, no duplicates; the
    help menu shows "Cancel (Escape)".
  - Handler tests in a private keylog copy: see 7b. A first run was cut short by
    a `hyprctl reload` in the middle of my own test script, not by the bind; the
    terminal case reran cleanly.
  - The user's physical tests (§8.2) passed (Brave, Nautilus, foot, VS Code).
    **7b is complete.**
  - **Next:** 7c (opt-in Emacs ⌃ keys) or another Phase 7 item, then Phase 8.
- **2026-10-05 — Phase 7c: Emacs ⌃ keys (built).**
  - Committed 7b first (683e505; the user's tests passed).
  - Answered the user's question first: GUI apps only, terminals pass through.
  - New `emacs.lua` and an `emacs_keys` flag in `config.lua` (default false).
    With the flag on: 153 bindings, 108 relocations, no duplicates; the help menu
    lists nine "(Emacs key)" entries. Flag off: 144 bindings, unchanged.
  - First version passed every Emacs key in VS Code; the user wanted the movement
    keys there too and only ⌃D kept raw, and asked for explicit blocks instead of
    a loop (rewritten). ⌃T / ⌃O / ⌃V / ⌃Y are not mapped.
  - Handler tests in keylog: all nine sent the right keys.
  - The user's physical tests (§8.2) passed (Brave, foot, VS Code editor and
    terminal, repeat, rapid presses). They want the keys on: the flag is `true`
    in the repo. **7c is complete.**
  - **Next:** 7d (Mac-mode toggle), then 7e–7h and Phase 8.
- **2026-10-05 — Phase 7d: Mac-mode toggle.**
  - Committed 7c first (8ddc48a; Emacs keys on by default at the user's request).
  - New `lib/mode.lua` (state file, ⌃⌘⇧M bind, toggle), a guard in `load.lua`
    (pre / init skip everything when off; `omackey.status()` says "off"),
    `init.lua` binds the toggle in on-mode, `scripts/omackey-mode`,
    `scripts/check.sh` reports off as ✗. 153 bindings on; 229 binds with
    Omarchy's own set when off.
  - Tests: script off → Omarchy keys back, config clean, status off, help menu
    shows Omarchy defaults plus the toggle; Lua `toggle()` both ways (off → on
    → off → on). Found and fixed the apostrophe bug (F18) on the way. Left on at
    the end.
  - The user's physical test of ⌃⌘⇧M passed in both directions. **7d is complete.**
  - The user skipped 7e (the optional Alt/Super swap): marked `[-]`.
  - **Next:** 7f–7h (documentation items), then Phase 8 (the README should cover
    7d, D12's `hl.unbind` recipe and the `emacs_keys` flag).
- **2026-10-05 — Phase 7f closed (no code).**
  - Committed 7d first (4f4f402) and skipped 7e at the user's request.
  - Checked how Linux types non-ASCII characters here: Omarchy sets Caps Lock as
    the Compose key (`compose:caps`), with the system Compose table, Omarchy's
    `default/xcompose` and the user's `~/.XCompose`. Every example sequence was
    looked up in the table. Alternatives noted: physical `Ctrl+Shift+U` hex input,
    the ⌃⌘Space picker, a `us(mac)` layout (not taken).
  - Decision with the user: close 7f with a pointer to Omarchy's documentation
    instead of a cheat sheet. The manual has only one sentence (Troubleshooting),
    so §10 also lists the local files. §7 updated.
  - **Next:** 7g (⌘-click: spike or document) and 7h (gestures: document), then
    Phase 8.
- **2026-10-05 — Phase 7g: mouse.**
  - The user's request: ⌘-click and ⌘-scroll as Ctrl-click / Ctrl-scroll, and a
    new home for Omarchy's mouse controls (first idea: ⌃ + mouse, like the arrow
    rule).
  - Relocated Omarchy's mouse binds (6 rows, 114 relocations): move / resize drag
    and workspace scroll to ⌃⌥, group scroll to ⌃⌥⌘ (user's choice of ⌃⌥, after the
    ⌃ idea was shown to cost apps Ctrl-click). Tested by the user on the spike
    build.
  - Spike 1, a synthetic Ctrl key from a non-consuming bind: failed (§9 F19), with
    a logging Chromium page and a local collector to read what the app received.
    The user then asked about ydotool (from a forum snippet) and, preferring it, about
    wtype instead: held Ctrl from wtype reaches clicks and wheel (F20).
  - Built ⌘-scroll → Ctrl-scroll (`lib/ctrl_hold.lua`, `mouse.lua`; `bind.lua` now
    returns the action's result so a handler can pass a key through; `send.lua`
    exports `after`). 155 bindings, 114 relocations, no duplicates. The user's
    physical test passed. ⌘-click is left alone (works in many apps; the user
    didn't need it; added later, see the next bullet).
  - More physical tests passed: ⌘-scroll zooms Nautilus and LibreOffice (VS Code,
    Obsidian and foot have no Ctrl + scroll action by default), and ⌃⌥⌘-scroll
    switches between windows in a group.
  - **⌘-click, second round.** The user asked again once ⌘-scroll worked. Found
    that `send_key_state` accepts `mouse:272` and that explicit `mods` apply to
    the button (§9 F21), so ⌘-click and ⌘⇧-click now become Ctrl-click and
    Ctrl+Shift-click (`lib/click.lua`, 6 mouse binds in `mouse.lua`; `bind.lua`'s
    `mac{}` passes `release`; `send.lua` has `button`). 161 bindings, 114
    relocations, no duplicates. First version left an open press when ⌘ was
    released before the button; fixed with release binds on other modifier states.
    The user's retest of plain, ⌘, ⌘⇧, drag, ⌘ released first and double click
    passed (log read after each step).
  - The user's physical tests in real apps passed (Brave new tab, Nautilus
    multi-select, VS Code go to definition, drag-select, repeated ⌘-clicks).
    **7g is complete.**
  - **Next:** 7h (gestures, document only), then Phase 8.
- **2026-10-05 — Phase 7h noted. Phase 7 complete.**
  - Committed ⌘-click first (e7eb61d).
  - 7h (trackpad gestures) closed as documentation only at the user's request: a
    §7 row, no code, nothing to test on a desktop without a trackpad.
  - Phase 7 in short: 7a catch-all, 7b ⌘. cancel, 7c Emacs ⌃ keys (on), 7d
    on/off toggle (⌃⌘⇧M, `scripts/omackey-mode`), 7e skipped, 7f Compose key
    pointer, 7g mouse (Omarchy's binds on ⌃⌥, ⌘-scroll and ⌘-click as Ctrl), 7h
    noted. 161 bindings, 114 relocations, no duplicates.
  - **Next (not started):** Phase 8: docs generator (`docs/KEYBINDINGS.md`), README
    (modifier model, install / uninstall, the toggle, the `emacs_keys` flag, the
    `hl.unbind` opt-out recipe, wtype for ⌘-scroll), and the Omarchy-update drift
    check.
