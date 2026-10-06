# OMacKey — Refactoring Plan

A restructure of the existing code before Phase 8. It is separate from
`PLAN.md`, which stays frozen while this runs and is replaced in the last
phase (R8). Phases are called **R0–R8** so they can't be confused with
PLAN.md's Phases 0–8.

Notation as in CLAUDE.md: ⌘ = `SUPER`, ⌥ = `ALT`, ⌃ = `CTRL`, ⇧ = `SHIFT`.

Contents:

1. Goal and ground rules
2. Decisions (2026-10-06)
3. What "same behaviour" means
4. Target architecture
5. Rules for every phase
6. Phases R0–R8
7. What Phase 8.1 gets from this
8. Open questions
9. Progress log

---

## 1. Goal and ground rules

Make the code consistent and easy to follow after nine phases of incremental
growth, without changing what the user sees:

- **No observable behaviour change**, with no exceptions. ⌘C / ⌘V keep
  OMacKey's own binds (RD2).
- **No new functionality.** Developer tooling (the snapshot harness, load-time
  validation, `omackey.explain`) is allowed; it changes nothing on a key press.
- **Ready for Phase 8.1** (generated key documentation). The data the docs
  generator needs (per key, per app, per relocation, per setting) becomes
  readable from one place (§7).
- **Every phase is proven by the snapshot (R0)** before it is committed. Physical
  tests are needed only where a phase changes how a bind is registered or what
  a key does (listed per phase).

## 2. Decisions (2026-10-06, confirmed with the user)

- **RD1 — Apps are overlays.** Key files declare each Mac shortcut once, with
  its behaviour in a generic app (`default`). Everything app-specific (match
  rules, families, per-app actions) lives in one file per app under `apps/`.
  The same layering is used by xremap ("first matching definition wins"),
  keyd's application mapper ("application specific masks applied over the
  global rules") and Toshy/Kinto (per-app keymaps before the general ones).
  Hyprland still sees one bind per key (D6); overlays are data merged at load.
- **RD2 — OMacKey keeps its own ⌘C / ⌘V / ⌘X.** Omarchy's universal
  copy/paste sends `Ctrl+C` / `Ctrl+V` to VS Code, which breaks its integrated
  terminal (Findings F12), so OMacKey's `Ctrl+Insert` / `Shift+Insert` there
  stay. Omarchy's universal cut sends `Ctrl+X` to terminals too. All three
  Omarchy binds stay displaced; R1 only moves how (relocation rows instead of
  `hl.unbind`).
- **RD5 — Specific apps override their family.** A specific app's entry wins
  over its family's entry, which wins over `default`: Firefox over the generic
  browser entry, Ghostty / kitty / foot over the generic terminal entry. This is
  today's chain (app → family → default), kept and stated as a rule.
- **RD6 — Glyph order and key strings are fixed together in R7.**
- **RD3 — Optional user settings file.** Internal defaults live in the repo. A
  user file overrides them **only if it exists**. Nothing creates it:
  `install.sh` doesn't, and a user who keeps the defaults never has one.
- **RD4 — PLAN.md is split up and retired** (R8): an architecture document plus
  a few focused documents. The session log and the per-phase key tables are not
  carried over (git history keeps the log; 8.1 generates the key tables).

## 3. What "same behaviour" means

The snapshot (R0) freezes everything a user can observe, and reports internal
metadata separately so that intended changes to it can be reviewed.

**Frozen (any diff fails a phase):**

- The bind table after load, per config variant: every chord (normalized, so
  `SUPER + 1` and `SUPER + code:10` are the same key), its release flag, its
  other flags (`repeating`, `auto_consuming` …), its description, and its
  dispatcher (native dispatcher with arguments, or `lua`).
- For every Lua-function bind, and every app fixture (§6 R0): the events it
  emits (`send_key_state` mods / key / state with virtual timings, `exec_cmd`
  strings, window actions) and its result (consumed / passed through / error).
- Scripted scenarios for the stateful features: ⌘Tab sessions, ⌘Q, ⌘\`,
  ⌘-click press/release, ⌘-scroll ticks, the Mac-mode toggle, dictation.
- Load output: `omackey.status()`, notifications, anything printed to stdout
  (must stay empty), event subscriptions.
- Binding ids: they are the test hooks (`omackey.trigger`) and future docs
  anchors, so they keep their names, the catch-all's `catchall-⌘…` ids included.

**Reported, allowed to change when the phase says so:**

- Metadata: category, Mac glyph string, source file, action description text.
- Registration order (Omarchy's help menu sorts its entries, and the order only
  matters for two binds on the same chord, which the frozen table would show).
- The exact key strings (only R7 changes them).

## 4. Target architecture

```text
omackey/
  load.lua            entry points pre() / init() (names fixed: install.sh writes them into hyprland.lua)
  init.lua            manifest: key modules in load order, apps in match order; loads them
  settings.lua        internal defaults for user-facing options, merged with the optional user file
  relocations.lua     every displaced Omarchy bind: moved (`to`) or dropped (`drop`)
  lib/
    keys.lua          the one key table: name ↔ keycode ↔ glyph; normalize(); glyph()
    send.lua          tap / seq / button: self-describing actions (R6)
    bind.lua          mac{} declarations; build (expand, merge, validate); one bind loop; registry
    profiles.lua      app{} overlays; match index and chains built once at load
    relocate.lua      hl.bind hook; moved and dropped Omarchy binds; claimed keys
    windows.lua       window queries shared by ⌘Q, ⌘` and ⌘Tab (app_of, visible windows)
    switcher.lua  click.lua  ctrl_hold.lua  mode.lua     stateful features, started explicitly
    catalog.lua       the data model for docs and introspection (R6)
    introspect.lua    omackey.status / fired / trigger / explain
  shortcuts.lua       every Mac shortcut, declared once, generic behaviour only, one section per group (R5)
  apps/               one file per app or family: match rules, family, sources, overrides by id
    ghostty.lua kitty.lua foot.lua terminal.lua firefox.lua browser.lua
    vscode.lua libreoffice.lua obsidian.lua nautilus.lua no-tabs.lua
tests/snapshot/       the R0 harness (mock hl, fixtures, scenarios, expected output)
docs/                 R8: ARCHITECTURE.md, TESTING.md, FINDINGS.md, LIMITATIONS.md, ROADMAP.md
```

**Layering rules**

1. `lib/` holds mechanics and knows no keys or apps.
2. `shortcuts.lua` declares every shortcut. It says what each Mac shortcut does in a
   generic GUI app (`default`) and nothing app-specific. A key that only means
   something in some apps has no `default`: the raw key passes through, as today.
3. `apps/` owns app knowledge. An app file adds actions to existing keys by
   id. Validation rejects unknown ids and the same app setting the same key
   twice (overriding the app's family is allowed, RD5).
4. The catch-all covers only chords nobody claimed and never edits another
   key's actions. An app can declare how it treats catch-all keys
   (`apps/terminal.lua`: consumed, D5).
5. **Declare, build, bind (three steps, in this order, during `load.init()`):**
   1. *Declare.* `shortcuts.lua` and `apps/*` (in match order, from the
      manifest in `init.lua`) only fill tables. `mac{}`, `app{}` and the
      catch-all group call nothing in Hyprland. The catch-all group is a
      declaration too: the chords it covers and the ones it consumes.
   2. *Build* (`bind.build()`), on the complete set:
      - expand the catch-all against everything claimed (every declared
        shortcut and every Omarchy key, `relocate.claimed`) and mark the specs
        it generates;
      - merge the app overlays into each spec's actions, including an app's
        `catchall` rule on every marked spec;
      - build the profile match index and chains;
      - validate everything (the checks in R2); an invalid spec or entry is reported and
        left out, never half-applied.
   3. *Bind* (`bind.apply()`): one loop calls `hl.bind` for every valid,
      enabled spec, the Mac-mode toggle included. Nothing changes the table
      afterwards.

   No shortcut is ever bound before the whole set is known, and nothing is
   bound twice. The table that was bound is the registry that `omackey.status()`,
   `omackey.explain()` and the 8.1 catalog read.

**Key spec (shortcuts.lua)**

```lua
mac({
  id = "find-next",
  keys = "SUPER + G",
  desc = "Find next",            -- frozen: the help menu shows it
  repeating = true,
  actions = { default = tap("", "F3") },   -- apps/*.lua add per-app entries
})

mac({
  id = "close-window",
  keys = "SUPER + SHIFT + W",
  desc = "Close window",
  action = hl.dsp.window.close(),  -- one action in every app: bound natively, no Lua per press
})
```

- `category` comes from the section the spec sits in (`group("Find", { … })`,
  R5); the Mac glyph (`⌘G`) is derived from
  `keys`, with an explicit `mac =` only where no key chord exists ("⌘-click").
- `action` (one action everywhere, apps can't override it) or `actions` (per
  app), never both. Registration in the bind loop stays what it is today: a dispatcher binds natively, a function
  binds with `auto_consuming`.
- `enabled = settings.emacs_keys` / `requires = "wtype"`: the spec is declared
  either way, so validation and the docs know it, but the bind loop skips it
  when it is disabled.

**App overlay (apps/*.lua)**

```lua
-- apps/libreoffice.lua — accelerators from share/registry/main.xcd (Findings F17)
app({
  name = "libreoffice",
  classes = {
    "libreoffice-writer", "libreoffice-calc", "libreoffice-impress", "libreoffice-draw",
    "libreoffice-math", "libreoffice-base", "libreoffice-startcenter", "soffice",
  },
  actions = {
    ["find-next"] = tap("CTRL + SHIFT", "F"), -- F3 is AutoText there
    ["find-previous"] = CONSUME, -- Shift+F3 changes case; no key finds the previous match
    ["paste-plain"] = tap("CTRL + ALT + SHIFT", "V"),
    ["paste-special"] = tap("CTRL + SHIFT", "V"),
    ["preferences"] = tap("ALT", "F12"), -- Tools > Options
  },
})
```

The chain stays as it is: the app, then its `family`, then `default`; nothing
found means the raw key passes through.

**Settings (RD3)**

- `omackey/settings.lua`: documented defaults (`emacs_keys = true`,
  `release_ms = 20`, `close_window_classes = {}`, the former empty `no-tabs`
  profile).
- `${XDG_CONFIG_HOME:-$HOME/.config}/omackey/settings.lua`, if it exists, returns
  a table with the options to change. It is loaded as data (`loadfile` with an
  empty environment, so it can't call `hl`). Unknown keys or wrong types are
  reported in `omackey.status()` and ignored, and a broken file leaves the
  defaults in place.
- Not created by `install.sh`, not removed by `uninstall.sh` (it is the user's).

## 5. Rules for every phase

**Before starting:** read the phase here, run `scripts/snapshot.sh` (must be
clean) and `scripts/check.sh` (three ✓).

**Definition of done:**

1. `for f in $(find omackey -name '*.lua'); do luac5.5 -p "$f"; done`
2. `scripts/snapshot.sh`: no diff in the frozen files. Metadata, order and
   string diffs match what the phase declares, and the user approves them before
   `scripts/snapshot.sh --update`.
3. `scripts/check.sh` on the live system: three ✓.
4. `omarchy menu keybindings --print | sort` is identical before and after
   (R7 compares it too: no change is expected there either).
5. Loader and relocation phases (R1, R4, R6) also run the CLAUDE.md scratch-HOME
   dry run, including the help-menu replay.
6. Physical tests only where the phase lists them.
7. CLAUDE.md is updated in the same phase for any path or API it mentions.
8. Every file a phase touches gets its comments rewritten to explain the code:
   no phase numbers, no history, no stale cross-references.
9. A short entry in §9 (Progress log). Commit only when the user says so; one
   or more commits per phase, each snapshot-clean.

**PLAN.md during the refactor:** frozen. One line at its top points here. New
facts go to §9 of this file and move to the new docs in R8.

**Rollback:** each phase is its own commits on `main`; `git revert` of a phase
plus `hyprctl reload` restores the previous state. The snapshot shows whether
the rollback is complete.

---

## 6. Phases

### R0 — Snapshot harness (tests only; nothing under `omackey/` changes)

**Goal:** test scripts, run like any test suite, that render everything §3
freezes for the working tree or for any git revision and diff the two. They
pass or fail on their own: no agent judgment, no live windows, no key presses,
and nothing to read by eye except a failing diff. Anyone can run them
(`scripts/snapshot.sh`), and every later phase is gated on them.

- Plain Lua 5.5 (system `lua5.5`) and bash; nothing to install.
- Exit code 0 = identical, 1 = differences (printed as a unified diff), 2 = the
  harness itself failed.
- Hermetic: the mock world replaces Hyprland, so the scripts run anywhere
  Omarchy's files exist, even with Hyprland not running. Only `--live` talks to
  Hyprland, and it is an optional cross-check, not part of the gate.

**Files**

- `tests/snapshot/mock.lua` — a fake `hl` and a small fake world:
  - `hl.bind` records keys, dispatcher, options and description; `hl.unbind`
    removes earlier binds of the same normalized chord.
  - `hl.dsp.*` is a proxy that returns printable descriptors (the help-menu
    trick); `hl.dispatch` appends to an event log with the virtual time.
  - `hl.timer` queues callbacks on a virtual clock; the harness advances the
    clock and runs them, so `+20ms up` timings are exact and deterministic.
  - `hl.get_active_window` / `hl.get_windows` / `hl.get_active_workspace` read
    the fake world. Dispatched focus, close and kill change it, and focus
    changes fire `window.active` subscribers and update `focus_history_id`.
  - `hl.on` records subscriptions and returns a removable handle; scenarios
    can emit `input.keyboard.key` (e.g. the ⌘ release, keycode 133).
  - `hl.notification.create` and `print` are captured.
  - Everything else is a callable no-op, as in Omarchy's help-menu mock.
- `tests/snapshot/fixtures.lua` — one fake window per case, with tags in the
  form Hyprland reports them (`terminal*`, `default-opacity*`): no window, an
  empty class, a plain GTK app (keylog), foot (both app ids), Ghostty, kitty,
  Alacritty, an Omarchy TUI (`org.omarchy.btop`), Brave Origin, Chromium,
  Google Chrome, Firefox, VS Code (`com.microsoft.VSCode`, `code-oss`),
  Obsidian, Nautilus, LibreOffice Writer, `soffice`, an Omarchy web app
  (`chrome-…__-Default`). The fixtures are written independently of
  OMacKey's profiles, so profile matching itself is under test.
- `tests/snapshot/scenarios.lua` — scripted sequences, each in a fresh load:
  - ⌘Tab: tap and release (flip back), three steps with ⌘ held, ⌘⇧Tab from the
    front app, a click on another app mid-session, an app closing mid-session,
    and the recency order after each session.
  - ⌘Q with two windows of one class and one of another; ⌘\` / ⌘⇧\` over three
    windows on different workspaces plus a scratchpad window.
  - ⌘-click: press and release with ⌘; ⌘ let go before the button; ⌘⇧-click;
    a plain release with nothing pending (must pass through).
  - ⌘-scroll: ticks at 0, 30, 80, 250, 500 and 1200 ms (warm-up, pass, overlap,
    end of hold).
  - The Mac-mode toggle command, in both modes; dictation press and release.
- `tests/snapshot/render.lua` — loads one variant and writes the output files.
- `tests/snapshot/selftest.sh` — proves the harness can see changes (below).
- `scripts/snapshot.sh` — the runner:
  - `scripts/snapshot.sh` renders the working tree and diffs it against
    `tests/snapshot/expected/`;
  - `--update` rewrites `expected/` (only after a declared diff was approved);
  - `--against <rev>` renders `omackey/` from a git revision (`git archive` into
    a scratch directory) as the baseline instead, for an end-to-end check
    against the pre-refactor commit, or after an Omarchy update;
  - `--live` compares the `main` variant's bind table with the live
    `hyprctl binds` (parsed as text like `check.sh` does; Omarchy's menu notes
    that 0.56's `-j` output for binds is not valid JSON).

**How a variant is loaded**

- A minimal entry script mirrors `~/.config/hypr/hyprland.lua` without the
  user's own files: bootstrap, `load.pre()`, `require("default.hypr.omarchy")`,
  `load.init()`. Omarchy's defaults come from `/usr/share/omarchy`, so both
  sides of a diff use the same Omarchy.
- A package searcher placed first maps `hypr.omackey.*` to the tree under test
  (working tree or archived revision), never to the live symlink.
- `XDG_STATE_HOME` and `XDG_CONFIG_HOME` point to scratch directories (mode
  file, future settings file); the real `HOME` is only read.
- Variants:
  - `main` — as this machine: wtype and voxtype present, Emacs keys on, mode on.
  - `bare` — wtype and voxtype hidden (the mock's `io.open` refuses those
    paths, which covers both `o.cmd_present` and `mouse.lua`'s own PATH scan).
  - `emacs-off` — the old tree gets a patched `config.lua` copy; from R4 on, a
    user settings file in the scratch config directory.
  - `mode-off` — the `off` state file exists.
  - `no-preinstalls` — `omarchy_preinstalled_bindings = false`
    (optional relocation rows must not show up as unused).
- Each bind is exercised in a freshly loaded config (bootstrap clears the
  `hypr.*` modules on every load), with the fixtures in fixed order and the
  fake world reset between them, so state can't leak from one key to another.

**Output (`tests/snapshot/expected/`)**

- `binds-<variant>.txt` — frozen: chord, release, flags, description, dispatcher.
- `behaviour-<variant>.txt` — frozen: for each Lua bind, the fixtures grouped
  by identical outcome, e.g.
  ```text
  SUPER+g  "Find next"  [repeating auto_consuming]
    default, keylog, brave-origin, chromium, firefox, vscode, obsidian, nautilus …
      +0  send_key_state mods="" key=code:69 state=down
      +20 send_key_state mods="" key=code:69 state=up   → consumed
    foot, foot-alt, ghostty, kitty, alacritty, btop        → consumed (nothing sent)
    libreoffice-writer, soffice
      +0  send_key_state mods="CTRL + SHIFT" key=code:41 state=down …
  ```
- `scenarios.txt`, `load-<variant>.txt` — frozen.
- `metadata.txt`, `order-<variant>.txt`, `strings-<variant>.txt` — reported.
- `omarchy.sha256`: a hash of the Omarchy files the snapshot depends on
  (`bootstrap.lua`, `helpers.lua`, `omarchy.lua`, `bindings/*.lua`). If it
  differs from the current Omarchy, the runner stops (exit 2) and points to
  `--against <rev>` instead of reporting a misleading diff.

**Proving the harness (exit criteria, all scripted)**

1. `tests/snapshot/selftest.sh` applies each mutation to a scratch copy of
   `omackey/` and checks that `snapshot.sh` fails (exit 1) for each of: a
   changed `tap` modifier; a deleted app entry; `release_ms` changed; two
   modules swapped where order matters; a broken relocation row; a `print` at
   load; an action string typo (`"consme"`). A pure rename of a local variable
   must pass (exit 0). The self-test exits non-zero if any case behaves
   otherwise.
2. The self-test also renders the tree twice and checks the outputs are
   byte-identical. A snapshot run takes about 10 s; the self-test about 2 min.
   When a phase moves the text a case edits, the case reports "pattern not
   found" and is updated in that phase (rule 2 of §5 then includes the
   self-test).
3. `scripts/snapshot.sh --live` matches the live binds, except for binds from
   the user's own files (`hypr.bindings` and friends), which it lists. Run once
   to validate the mock; not needed per phase.
4. `--against dc3b0a9` (the last pre-refactor commit) equals the working-tree
   render: R0 changed nothing under `omackey/`.
5. The expected files are committed with the harness. The pre-refactor commit
   hash is recorded in §9.

**Physical tests:** none.

### R1 — Library consolidation

1. **`lib/keys.lua` becomes the one key table:** keycode, Mac glyph and label per
   key name. `normalize()` moves here from `relocate.lua` and treats keysyms and
   keycodes as the same key (`1` ≡ `code:10`). the catch-all takes its key
   list and labels from it instead of its own table (its descriptions stay word
   for word). Glyph derivation waits for R7.
2. **`lib/windows.lua`:** `app_of`, the visible-window filter, `focus`,
   `quit_app` and `cycle_app_windows`, now duplicated between
   `switcher.lua` and `windows.lua`.
3. **`o.cmd_present`** replaces `mouse.lua`'s own `installed()`.
4. **`send.button`** sends at once instead of returning a closure that
   `click.lua` calls immediately.
5. **Dropped Omarchy binds go through `relocations.lua`:**
   `{ from = "SUPER + C", drop = true }`, the same for `V` and `X` (RD2). The
   hook doesn't register Omarchy's bind (`o.bind` ignores `hl.bind`'s return
   value, checked), the rows count as used for the drift check, and
   `editing.lua` loses its three `hl.unbind` lines. Final bind table identical;
   the help-menu replay no longer sees "Universal copy / paste / cut", which it
   dropped anyway once the live binds were gone.

**Snapshot:** frozen files identical; `metadata.txt` unchanged. Scratch-HOME dry run. **Physical tests:** none.

### R2 — Declare, build, bind; one helper; validation; an explicit catch-all

0. **Declare, build, bind** (§4 rule 5). `mac{}` stops calling `hl.bind`; it only
   records the spec. `init.lua` declares everything, then calls `bind.build()`
   and `bind.apply()`. The catch-all module becomes a declaration expanded in
   the build step, so it no longer needs to be loaded last. Until R3 there are
   no app files, so the build step has no overlays to merge yet.

1. **`action{}` folds into `mac{}`** with `action =` (one action everywhere) or
   `actions =` (per app). Registration flags stay as they are today, and so do
   the press counter and `trigger`. A single-action spec calls its action
   directly, without resolving the app profile. That removes the per-click
   profile lookup from the plain left-click release binds.
2. **Action vocabulary:** `PASS` and `CONSUME` constants exported by `lib/bind.lua`
   (the values stay `"pass"` / `"consume"`). An action is a function, a callable
   object, a dispatcher, `PASS` or `CONSUME`; anything else is a load error.
3. **Load-time validation**, collected into `omackey.status()` errors and a
   notification. The faulty item is skipped and loading continues (today one
   error aborts the rest of `init`). It checks:
   - missing fields and duplicate ids;
   - two OMacKey binds on the same chord and release;
   - an OMacKey bind on a chord Omarchy still holds;
   - unknown profile names in `actions`;
   - invalid action values.
4. **The catch-all stops editing other keys.** Today it gives ⌘K, ⌘D, ⌘⇧D,
   ⌘Y, ⌘⇧J, ⌘⇧., ⌘⇧- and ⌘⇧U a `default` (and `terminal = "consume"`) at
   load. Those values are written into the key specs, and the catch-all only
   binds unclaimed chords.
5. **Conditional specs are declared, bound only when enabled:** Emacs keys
   (`settings.emacs_keys`), ⌘-scroll (`requires = "wtype"`), dictation
   (`requires = "voxtype"`). The registry knows them, so validation can check
   overlays that refer to them, and the docs can list them as opt-in.
   `omackey.status()` keeps counting bound specs only.
The hand-written `mac =` glyph fields stay as they are until R7 (RD6).

**Snapshot:** frozen files identical (in the `bare` and `emacs-off` variants
too). `metadata.txt` gains the declared-but-disabled specs, marked as such.
`order-*.txt` changes: OMacKey's binds are now registered in one loop after
Omarchy's, in declaration order (declared; the help menu sorts its entries, and
no two binds share a chord).

**Physical tests** (the bind path of single-action keys changes): ⌘-click and
⌘⇧-click with ⌘ let go first, a ⌘-scroll burst, ⌘Tab hold-stepping, ⌘Q.

### R3 — Apps as overlays (RD1)

1. **`lib/profiles.lua`** with `app{}`: name, `family`, classes, tags, an optional
   `catchall` rule, and `actions` by key id. `app{}` only declares; the build
   step (R2) merges the overlays and builds the match index and the chains once.
   First match wins in manifest order, exactly as now:
   ghostty, kitty, foot, terminal, firefox, browser, vscode, libreoffice,
   obsidian, nautilus, no-tabs. Specific apps override their family (RD5): a
   window's chain is its app, then the family, then `default`, so an entry in
   `apps/firefox.lua` wins over `apps/browser.lua`, and one in
   `apps/ghostty.lua` over `apps/terminal.lua`. Validation rejects only the same
   app setting the same key twice; an app overriding its family is the point.
2. **Every non-`default` entry moves out of the key modules into `apps/*.lua`**,
   one app per commit, snapshot-clean after each: the terminal family, then
   Ghostty / kitty / foot, the browsers, VS Code, Obsidian, Nautilus,
   LibreOffice. This includes the terminal and browser families: the key
   modules end up describing only the generic app.
   - `apps/terminal.lua` gathers what D5 means in practice, in one place, plus
     `catchall = CONSUME`, applied to every spec the catch-all marked
     (load order rule 5).
   - `apps/vscode.lua` gets match case (⌘⌥C), the secondary side bar (⌘⌥B) and
     ⌘. quick fix, now in `browsers.lua` and `editing.lua`.
   - `apps/obsidian.lua` gets its entries from `vscode.lua` and `windows.lua`.
3. **`apps/no-tabs.lua`** reads its classes from settings (`close_window_classes`,
   R4; until then an empty list as today).
4. Profile definitions leave `config.lua`. Each app file states where its
   shortcuts were read from (Findings F10, F11, F13, F15, F16, F17).
5. The app-only modules disappear (`vscode.lua`, `browsers.lua`,
   `terminals.lua`, `obsidian.lua`, `nautilus.lua`, `libreoffice.lua`). Their
   keys move temporarily into the nearest existing key module; R5 regroups them.

**Snapshot:** frozen files identical after every commit. **Physical tests:** one
key per app as a smoke test: ⌘F in foot, Ghostty and kitty; ⌘⇧N in Firefox; ⌘0
in VS Code; ⌘⌥← in Obsidian; ⌘↑ in Nautilus; ⌘G in LibreOffice.

### R4 — Settings (RD3)

1. `omackey/settings.lua` with the documented defaults; the optional user file
   as described in §4; `config.lua` is gone (its module list became the manifest
   in `init.lua`, its profiles moved in R3).
2. `emacs_keys`, `release_ms` and `close_window_classes` are read from the merged
   settings.
3. The snapshot's `emacs-off` variant now uses a user settings file.

**Snapshot:** frozen files identical in every variant. **Dry runs** in a
scratch HOME:
- no user file → identical to `main`;
- a file with `emacs_keys = false` → identical to `emacs-off`;
- a file with a syntax error, an unknown key and a wrong type → defaults kept,
  three errors in `omackey.status()`.

**Physical tests:** none.

### R5 — All shortcuts in one file, grouped by Mac meaning

`shortcuts.lua` replaces the phase-named modules (`text.lua`, `editing.lua`,
`windows.lua`, `spaces.lua`, `system.lua`, `mouse.lua`, `emacs.lua`, `catchall.lua` and
what R3 left of the app modules). (The file isn't called `keys.lua`,
which would be confusing next to `lib/keys.lua`, the key table.)

- One section per group, in the order of the table below, each a call
  `group("Text", { mac{…}, mac{…} })` that gives its specs their category.
  No module-level "current category" variable.
- The file holds only spec blocks; helper functions and anything stateful stay
  in `lib/`.
- Ids and descriptions don't change. The Emacs section keeps its
  `enabled = settings.emacs_keys`, the scroll keys `requires = "wtype"`, and
  dictation `requires = "voxtype"`.
- Expected size: about 1,300 lines, mostly the explicit spec blocks.

| Section | Keys (ids) |
| --- | --- |
| Text | line-start/-end, select-line-start/-end, word-left/-right, select-word-left/-right, document-start/-end, select-document-start/-end, delete-word-left/-right, delete-line-start/-end |
| Editing | cut, paste-plain, paste-special, undo, redo, redo-selection, select-all, save, save-as, bold, italic, underline, cancel |
| Find | find, find-next, find-previous, replace, find-whole-word, find-regex, find-in-selection, find-preserve-case |
| Code editing | toggle-comment, block-comment, add-cursor-above/-below, copy-line-up/-down, fold, unfold, shrink-selection, expand-selection |
| Tabs | new-tab, reopen-tab, close-tab, tab-1…tab-9, previous-tab, next-tab, previous-tab-arrow, next-tab-arrow |
| Windows and apps | new-window, new-window-private, close-window, quit-app, switch-app, switch-app-back, next-app-window, previous-app-window |
| Navigation | open, print, reload, location, back, forward, preferences, history, downloads, bookmark-manager, clear-browsing-data |
| View | zoom-in, zoom-in-plus, zoom-out, zoom-out-shifted, zoom-reset, show-hidden-files |
| Developer tools | devtools, devtools-console, devtools-inspect, view-source |
| Terminal | clear-screen, split-right, split-down |
| Spaces | as today |
| System | as today, plus the Mac-mode toggle (R6) |
| Mouse | as today |
| Emacs keys (opt-in) | as today |
| Catch-all | last group by convention: a declaration of the ⌘ / ⌘⇧ chords it covers and the ones it consumes; the build step expands it against everything claimed, so its position doesn't matter |

**Snapshot:** frozen files identical; `metadata.txt` shows the new categories
and the file `shortcuts.lua`; `order-*.txt` shows the new registration order. **Physical tests:**
none.

### R6 — Docs-ready data, introspection, loader

1. **Self-describing actions:** `tap` / `seq` / `button` return callable objects
   that carry their text (`"Ctrl+Shift+F"`, `"Shift+Home, then BackSpace"`).
   Function actions are wrapped with a text: `does("Close every window of the
   app", quit_app)`. Dispatchers and `PASS` / `CONSUME` get standard texts.
   Validation requires a text on every action.
2. **`lib/catalog.lua`** builds the data model of §7 from the registry, the
   apps, the relocations and the settings. `metadata.txt` is rendered from it
   (the action-text column appears), and 8.1 reads it.
3. **`lib/introspect.lua`:** `omackey.status`, `fired` and `trigger` move out of
   `load.lua` unchanged (`check.sh` and CLAUDE.md rely on them), plus
   `omackey.explain(id)`: the key's default and every app's action, as text.
4. **Loader:** `load.lua` reads the mode file once. The toggle is declared once
   with `mac{}` and bound by the same loop; in off-mode the loop binds only it. Description unchanged; the toggle now appears in the
   registry and the docs.

**Snapshot:** frozen files identical, except one declared change in
`load-*.txt`: `bindings=` counts the toggle (+1). Scratch-HOME dry run with
mode on and off. **Physical tests:** ⌃⌘⇧M off and on again.

### R7 — Canonical key strings and glyphs (RD6)

One written form for every OMacKey bind and relocation target: modifier order
`SUPER + CTRL + ALT + SHIFT`, uppercase letters and named keys as Omarchy
writes them, xkb lowercase names for punctuation (`comma`, `slash`), and digits
by keycode like Omarchy. This makes D12's `hl.unbind("<exact string>")`
predictable, and the docs show one style.

Glyphs in the same pass: `keys.glyph()` derives the Mac form from the key string
in one fixed modifier order (Apple's ⌃⌥⇧⌘, as on Apple's shortcut page, so
`⇧⌘[` rather than today's mixed `⌘⇧[` / `⌥⌘D` / `⌘⌥Esc`), and the hand-written
`mac =` fields go, except where there is no key chord ("⌘-click", "F5
(release)"). Descriptions in the help menu keep their text.

**Snapshot:** `strings-*.txt` changes, and the glyph column of `metadata.txt`.
The frozen files stay identical (chords are compared normalized). The live
help-menu output is compared before and after; the menu upper-cases punctuation
and maps keycodes to names itself, so no change is expected there; any other
difference is fixed before the phase is done. **Physical tests:** a sample of
changed binds.

### R8 — Documentation split, PLAN.md retired (RD4)

| New file | Takes from PLAN.md / this file |
| --- | --- |
| `docs/ARCHITECTURE.md` | Goal and non-goals (§1, corrected), modifier model (D1), decisions D1–D13 in their current wording plus RD1–RD6, the arrow rule (§6.2), the target architecture (§4 here) as built, load order, how to add a key / an app / a relocation, invariants (CLAUDE.md's "How it works") |
| `docs/TESTING.md` | The snapshot harness, handler tests, the physical per-key protocol (§8.2), test recipes from the findings (throwaway windows, private keylog, browser profiles), recovery (§8.3) |
| `docs/FINDINGS.md` | F0–F21 renumbered in order, F12 as its own entry, plus findings from this refactor |
| `docs/LIMITATIONS.md` | §7, corrected (⌘-click is no longer a non-goal) |
| `docs/ROADMAP.md` | Phase 8 (8.1–8.4) and the optional 7j overlay |

- **Not carried over:** the per-phase key tables (they duplicate the code and
  had drifted; 8.1 generates them, and until then the snapshot's
  `behaviour-main.txt` is the reference), §6's tables (`relocations.lua` is the
  data, and 8.1 renders it), and the session log (git history; its lasting
  lessons go into the findings).
- **CLAUDE.md** is rewritten for the new layout and workflow: "update PLAN.md"
  becomes "update ARCHITECTURE / FINDINGS / LIMITATIONS / ROADMAP as the change
  requires"; the validation section adds `scripts/snapshot.sh`.
- **Final sweep:** comments in every file (no phase numbers), `.luarc.json` set
  to Lua 5.5, `check.sh` mentions the snapshot.
- `PLAN.md` and this file are deleted. A short "History" paragraph in
  ARCHITECTURE.md names the pre-refactor commit.

**Snapshot:** identical (docs only). **Physical tests:** none.

---

## 7. What Phase 8.1 gets from this

`lib/catalog.lua` (R6), loaded under the R0 mock (the generator reuses
`tests/snapshot/mock.lua`), gives:

- **Keys:** id, exact key string (for D12's `hl.unbind`), derived Mac glyph,
  description, category, file, flags, default action text, per-app action texts,
  condition (`emacs_keys`, `requires = "wtype"`), whether it is bound on this
  machine.
- **Apps:** name, family, match rules, source of its shortcuts, and its
  catch-all rule.
- **Relocations:** Omarchy key, new key or dropped, Omarchy's description,
  `optional`.
- **Settings:** name, default, description.

8.1 only renders this into `docs/KEYBINDINGS.md`: per category, per app, the
relocation table, the opt-in keys, and a pointer to LIMITATIONS.md.

## 8. Open questions

None. All answered on 2026-10-06.

## 9. Progress log

One entry per phase: date, commits, snapshot result, tests, anything learned.

- **2026-10-06 — R0 done.** Pre-refactor commit for `omackey/`: `dc3b0a9`
  (the refactor plan is `3182380`).
  - Files: `tests/snapshot/{mock,fixtures,scenarios,render,live}.lua`,
    `tests/snapshot/selftest.sh`, `scripts/snapshot.sh`, and the baseline in
    `tests/snapshot/expected/` (36 files, 748 KB). Nothing under `omackey/`
    changed.
  - Results: `--live` matches all 387 live binds; `--against dc3b0a9` is clean;
    the self-test catches all seven planted mistakes, lets a pure rename pass,
    and two renders are identical. Variant sanity: `main` 161 OMacKey binds, `bare`
    156 (no ⌘-scroll, no dictation), `emacs-off` 152, `mode-off` 229 binds in
    all (Omarchy's own set plus the toggle, as PLAN.md 7d recorded),
    `no-preinstalls` 96 relocations applied, none reported unused.
  - Deviations from the plan above: the Omarchy hash is one `omarchy.sha256`
    file instead of a header in each file; behaviour is rendered for every
    variant, not only `main` (cheap enough).
  - Found while building: a bind with no description must render as `""`
    (Omarchy's lid switches) to match the live output.
- **2026-10-06 — R1 done.**
  - `lib/keys.lua` is the key table (`list`, `by_name`, `by_code`: name,
    keycode, kind, glyph, label) and owns `normalize()`, which maps a keycode
    in the table to its name (`code:10` ≡ `1`). The catch-all takes its keys
    (letters, punctuation, Return, in table order) and labels from it.
  - `lib/windows.lua`: `app_of`, `visible`, `focus`, `close`, `quit_app`,
    `cycle_app_windows`; the switcher and `windows.lua` use it.
    `switcher.focus` is gone.
  - `mouse.lua` uses `o.cmd_present("wtype")`; `send.button` sends at once.
  - `{ from = "SUPER + C" / "V" / "X", drop = true }` rows; the hook records
    them in `relocate.dropped` (not in `applied`, so `relocated=114` and
    `metadata.txt` stay as they were) and doesn't mark them claimed.
    `editing.lua` has no `hl.unbind` left.
  - Results: every rendered file byte-identical to `expected/` (reported files
    included); self-test passes; `check.sh` three ✓; live help menu identical.
    Scratch-HOME replay: the only difference is the three "Universal copy /
    paste / cut" entries gone, as planned.
  - Comments in touched files no longer name phases.
- **2026-10-07 — R2 done.**
  - `lib/bind.lua`: `mac{}` and `catchall{}` only declare; `build()` validates,
    resolves `enabled` / `requires` and expands the catch-all against every
    enabled spec and `relocate.claimed`; `apply()` binds in one loop.
    `action{}` is gone: `mac{ action = … }` (a dispatcher binds natively, as
    before; anything else gets `auto_consuming` and the press counter).
    `bind.PASS` / `bind.CONSUME` replace the strings in every module.
  - `action =` is used where the action is the same in every app: Spaces,
    System, ⌘⇧W, ⌘Q, ⌘Tab / ⌘⇧Tab, ⌘\` / ⌘⇧\`, ⌘-click and its releases,
    ⌘-scroll. The default-only text keys (⌘← ⌘→ ⌥← ⌥→) keep `actions`: they
    are synthetic chords an app may need to override.
  - The catch-all used to write a `default` into eight specs at load; those
    are now written in the specs: clear-screen, split-right, split-down
    (Ctrl / Ctrl+Shift + key), history, downloads, show-hidden-files,
    zoom-out-shifted (same, plus `terminal = CONSUME`), redo-selection
    (`CONSUME`).
  - Conditional specs are declared and marked: Emacs keys
    `enabled = config.emacs_keys`, ⌘-scroll `requires = "wtype"`, dictation
    `requires = "voxtype"`. `omackey.status()` counts `bind.bound`;
    `omackey.trigger` answers "not bound" for a declared, unbound spec.
  - Validation, checked with a planted copy: a duplicate id, the same chord
    twice, a chord Omarchy holds, an unknown profile, an invalid action, a
    missing field, both `action` and `actions`, and a module that throws
    (an unknown key name in `tap`) are each reported in `omackey.status()`
    plus one notification, and skipped; the rest loads. A Lua error inside a
    module skips the rest of that module (`init.lua` requires each module
    under `pcall`), since `tap()` resolves key names when it is declared.
  - Snapshot: frozen files identical in all five variants. `order-*.txt`
    unchanged after all (binds were already registered in declaration order
    with the catch-all last). `metadata-*.txt` changed as declared: the
    single-action specs show `action` instead of `profiles={…}` (render.lua
    prints that column), and unbound declared specs appear marked
    `NOT BOUND` (5 in `bare`, 9 in `emacs-off`). The self-test's typo case
    now edits `terminal = CONSUME`.
  - `check.sh` three ✓; live help menu and help-menu replay identical.
  - Physical tests (user): ⌘-click, ⌘⇧-click (⌘ let go first), ⌘-scroll
    burst, ⌘Tab hold-stepping and ⌘Q all pass.
  - Found while testing: a slow ⌘-scroll-up burst counted only one press of
    `scroll-up`. Expected: once wtype holds Ctrl, the modifier state is ⌃⌘,
    so ⌘ + wheel no longer matches the bind and the ticks reach the app
    directly with Ctrl (which is the point). The bind fires only on the tick
    that starts a hold. This also explains PLAN.md F20's "not understood"
    slow ticks: they never reached the bind.
- **2026-10-07 — R3 (built; see "R3 done" below).**
  - `lib/profiles.lua` (`app{}`, match index by class and tag, chains built
    once) replaces `lib/apps.lua`; `init.lua` holds the `APPS` manifest in
    match order. `bind.build()` overlays app actions by key id and applies an
    app's `catchall` rule to every catch-all spec. Errors: unknown key id, an
    entry on an `action =` spec, an invalid action, a key set twice, an app
    declared twice, an unknown family.
  - Every per-app entry moved out of the key modules, one app per commit,
    each with every rendered file identical: terminal (with
    `catchall = CONSUME`), Ghostty, kitty, foot, browser, Firefox, VS Code,
    Obsidian, Nautilus, LibreOffice, no-tabs. Moved mechanically by a
    throwaway extractor (entries and their comments), then comments rewritten
    by hand. ⌘1–⌘9 entries are loops in the app files (Ghostty, Nautilus,
    terminal).
  - A spec may omit `actions` (no default; the raw key passes through).
  - The app-only modules are gone: VS Code, Obsidian and LibreOffice keys sit
    at the end of `editing.lua`; browser, Nautilus and terminal keys at the
    end of `windows.lua`, until R5 regroups them. Snapshot: frozen files
    identical; `order-*.txt` is the same set of binds in a new order.
  - The self-test's typo case now edits `["undo"] = CONSUME` in
    `apps/terminal.lua`; its match-order case edits the `APPS` manifest.
  - `check.sh` three ✓; live help menu identical; help-menu replay has the
    same entries.
- **2026-10-07 — Fixes found by the R3 smoke tests** (behaviour changes,
  approved by the user, committed apart from the refactor phases).
  - **NumLock and explicit mods.** `send_key_state` with explicit `mods`
    replaces the locked modifiers too, so NumLock (Mod2) is dropped from the
    event: with NumLock on, keycode 90 reached apps as `KP_Insert`, not
    `KP_0`, and VS Code's ⌘0 (reset zoom, Ctrl+Numpad0) did nothing. Sending
    `CTRL + MOD2` gives `KP_0` (keylog) and resets the zoom (throwaway VS Code
    instance with its own `--user-data-dir`). Only keypad keys care; `kp_0`
    is the only one OMacKey sends. For FINDINGS.md in R8.
  - **LibreOffice ⌘G.** Ctrl+Shift+F is `.uno:RepeatSearch` in Writer, but it
    repeats the Find & Replace dialog's search, not one typed in the find bar
    (⌘F), so ⌘G did nothing in the usual workflow.
    Fix: ⌘G / ⌘⇧G drive the find bar: Ctrl+F, then Return / Shift+Return,
    then Escape (25 ms apart). LibreOffice now has a find-previous key, so
    PLAN.md §7's "no key finds the previous match" goes when §7 becomes
    LIMITATIONS.md (R8). Physical test (user): both keys step through the
    find bar's matches in Writer; VS Code ⌘0 resets the zoom.
- **2026-10-07 — R3 done.** Physical smoke tests (user): ⌘F in foot, Ghostty
  and kitty; ⌘⇧N in Firefox; ⌘⌥← in Obsidian; ⌘↑ in Nautilus pass. ⌘0 in
  VS Code and ⌘G / ⌘⇧G in LibreOffice failed and were pre-existing (the
  snapshot equals `dc3b0a9`); both fixed above.
