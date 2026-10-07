# OMacKey — Testing

How a change is proven. There are four layers, cheapest first:

1. **The snapshot.** It presses every bind under a fake Hyprland. No
   Hyprland is needed, and no judgment.
2. **Live validation** of the installed config.
3. **Handler tests.** A bind's handler runs in the live session, with no key
   pressed.
4. **Physical tests** by the user. Only these prove that a bind fires and that
   held modifiers don't leak.

## 1. The snapshot (`scripts/snapshot.sh`)

It loads Omarchy's defaults plus an OMacKey tree under a fake Hyprland. Then
it presses every bind in every test app, runs scripted scenarios, and compares
the result with `tests/snapshot/expected/`.

```bash
scripts/snapshot.sh                 # working tree vs tests/snapshot/expected
scripts/snapshot.sh --update        # rewrite expected/ (only after the diff was reviewed and approved)
scripts/snapshot.sh --against REV   # compare with REV's omackey/ instead of expected/
scripts/snapshot.sh --tree DIR      # test DIR/omackey instead of the working tree
scripts/snapshot.sh --out DIR       # also keep the rendered files
scripts/snapshot.sh --live          # compare the main variant's binds with live `hyprctl binds`
tests/snapshot/selftest.sh          # prove the harness can see changes (about two minutes)
```

- **Exit status:** 0 means the frozen files match, 1 means they differ (shown
  as a unified diff), 2 means the harness itself failed.
- **Requirements:** it needs `lua5.5` and Omarchy's files; it takes about 10 s.
- **Only `--live` talks to Hyprland.** It is an optional cross-check of the
  mock, and it lists binds from the user's own files apart.
- **`--against dc3b0a9`** compares with the last commit before the refactor
  (ARCHITECTURE.md §13).

**Files** (`tests/snapshot/`):

- `mock.lua` is the fake Hyprland:
  - `hl.bind` / `hl.unbind` record binds;
  - `hl.dsp.*` returns printable descriptors, and `hl.dispatch` appends to an
    event log with a virtual time;
  - `hl.timer` runs on a virtual clock, so release timings are exact;
  - window queries read a small fake world, which focus, close and kill
    change;
  - `hl.on` subscriptions can be fed events (the ⌘ release, keycode 133);
  - notifications and `print` are captured;
  - everything else is a callable no-op, as in Omarchy's help-menu replay.
- `fixtures.lua` holds one fake window per case:
  - no window, an empty class, a plain GTK app (keylog);
  - terminals: foot (both app ids), Ghostty, kitty, Alacritty, an Omarchy TUI;
  - browsers: Brave Origin, Chromium, Chrome, Firefox;
  - VS Code (two classes), Obsidian, Nautilus, LibreOffice Writer, `soffice`,
    an Omarchy web app.

  They carry tags as Hyprland reports them and are written independently of
  OMacKey's app rules, so app matching is under test too.
- `scenarios.lua` scripts the stateful features, each in a fresh load:
  - ⌘Tab sessions;
  - ⌘Q and ⌘\`;
  - ⌘-click press and release orders;
  - ⌘-scroll tick timings;
  - the Mac-mode toggle;
  - dictation.
- `render.lua` loads one variant and writes the output files. `live.lua` reads
  `hyprctl binds` for `--live`.

**Variants:**

- `main` — this machine: `wtype` and `voxtype` present, Emacs keys on, Mac
  mode on.
- `bare` — `wtype` and `voxtype` hidden.
- `emacs-off` — a user settings file with `emacs_keys = false`.
- `mode-off` — the off state file exists.
- `no-preinstalls` — `omarchy_preinstalled_bindings = false`, so no optional
  relocation row may show up as unused.

**Output** (`tests/snapshot/expected/`):

- **Frozen**: any difference fails.
  - `binds-<variant>.txt`: every chord (normalized), its flags, description and
    dispatcher.
  - `behaviour-<variant>.txt`: for every Lua bind, the fixtures grouped by
    identical outcome: the events sent, with virtual timings, and whether the
    key was consumed or passed through.
  - `scenarios.txt`.
  - `load-<variant>.txt`: `omackey.status()`, notifications, stdout (must be
    empty), subscriptions.
- **Reported**: differences are shown and allowed, but reviewed.
  - `metadata-<variant>.txt`: catalog data (category, glyph, file, action
    texts).
  - `order-<variant>.txt`: registration order.
  - `strings-<variant>.txt`: the exact key strings.
- **`omarchy.sha256`**: a hash of the Omarchy files the snapshot depends on. If
  Omarchy changed, the runner stops (exit 2) instead of reporting a misleading
  diff. Run `scripts/drift.sh` first: it lists the Omarchy binds that are new,
  changed or gone, and which of them sit on a key OMacKey uses. Then render
  the last good commit with `--against <rev>` to see what the update did to
  OMacKey, and record the new baseline with `--update`.

**A deliberate change** of behaviour or metadata:

1. Run `scripts/snapshot.sh` and review the diff.
2. Describe the diff to the user and get their approval.
3. Record it with `scripts/snapshot.sh --update`.
4. Commit the expected files together with the change.

**The self-test** proves the harness can see changes:

- It applies planted mistakes to a scratch copy of `omackey/` and expects each
  to fail: a changed `tap` modifier, a deleted app entry, a changed
  `release_ms`, a swapped match order, a broken relocation row, a `print` at
  load, an action typo.
- A pure rename must pass.
- Two renders must be byte-identical.

The cases find their target by a text pattern. When code moves, a case reports
"pattern not found": update it so it makes the same kind of change.

## 2. Live validation

After every change:

```bash
scripts/lint.sh                        # syntax, unknown globals, no print at load
scripts/check.sh                       # reload, configerrors, omackey.status(), duplicate binds
scripts/check.sh "line start"          # … plus a help-menu (omarchy menu keybindings) search
scripts/snapshot.sh                    # behaviour snapshot
lua5.5 scripts/gen-docs.lua            # regenerate docs/KEYBINDINGS.md (pre-commit hook blocks a stale one)
hyprctl binds | grep -B8 -A4 'description: Line start'   # flags: e=repeat a=auto_consuming d=desc
```

- `check.sh` must print three ✓ lines. It reloads Hyprland, because edits
  behind the symlink may not trigger the auto-reload.
- `omackey.status()` reports load and validation errors and
  `unused_relocations`. These don't show up in `hyprctl configerrors`.
- **The help menu** (`omarchy menu keybindings --print | sort`) shows what a
  user sees. Compare it before and after a change that touches key strings or
  descriptions.

**Scratch-HOME dry run.** Do this before risky changes to the loader or
relocation:

1. Copy `~/.config/hypr` into a scratch HOME.
2. Run `HOME=<scratch> ./install.sh --no-reload`.
3. Replay the config the way the help menu does. Extract the Lua heredoc from
   `$(which omarchy-menu-keybindings)` and run it with `HOME=<scratch> lua5.5`.

## 3. Handler tests

`hyprctl repl '<lua>'` runs Lua in the live config state and prints the
results:

- `omackey.trigger("<id>")` runs a binding's handler as if pressed;
- `omackey.fired("<id>")` counts real presses since the last reload;
- `omackey.explain("<id>")` prints what the key does, per app;
- `require("hypr.omackey.lib.bind").by_id` gives the spec of a key.

**With keylog** (`scripts/keylog.py`, GTK4, nothing to install, window class
`omackey.keylog`). It logs every press, release and modifier change the app
receives: keysym, keycode, modifiers, cursor and selection.

1. Start a private copy:
   `DBUS_SESSION_BUS_ADDRESS=disabled: scripts/keylog.py --log <scratchpad>/keylog.txt &`.
   keylog is single-instance, so a plain second launch would only focus the
   user's open one and log nothing. The private copy's class is `keylog.py`
   (F3; the single-instance fact is F2).
2. Focus it by pid: `hyprctl dispatch 'hl.dsp.focus({ window = "pid:<pid>" })'`.
3. **Check focus and trigger in one command.** Focus jumps back to VS Code
   between tool calls, and stray keys would land in the user's editor:
   `hyprctl repl "local w = hl.get_active_window(); if w and w.pid == <pid> then return omackey.trigger('<id>') end; return 'wrong window'"`.
4. Read the log.
5. Close it with `kill <pid>`. Don't use `pkill -f keylog.py`: it matches and
   kills your own shell.

**What can't be tested this way:**

- `wtype` input never triggers Hyprland binds, and it uploads its own keymap
  (F1). It can't replace a physical press.
- An app entry is only reached when the window matches the app. To test one in
  keylog, add the keylog's class to that app in memory, and `hyprctl reload`
  afterwards: the in-memory change persists until a reload (F14).

## 4. Physical tests

The agent can't press keys. After the agent's own tests, give the user these
steps for the exact keys that changed, and wait for their results:

1. `scripts/check.sh` is clean (three ✓).
2. In keylog, the app receives exactly the target key and modifiers. No SUPER
   or ALT leaks through, and there is exactly one press and one release per
   tap.
3. Real apps: a browser text field, VS Code, foot with bash, plus the apps the
   key has entries for.
4. Hold the key (for repeating binds) and release it: the repeat stops at
   once.
5. Press the chord 20 times fast, then type normally: no stuck modifier or
   key.
6. (Deferred, D11.) With Persian active, repeat steps 2–3 for one GUI app and
   a terminal.
7. The help menu (⌘?) finds the bind by its description; relocated Omarchy
   binds show their new keys.
8. For window-management and workspace keys: repeat on both the `scrolling`
   and the `dwindle` layout.

**Test bench:**

- keylog;
- a plain text field in Brave Origin and Chromium:
  `data:text/html,<textarea autofocus style="width:100%;height:95vh"></textarea>`;
- VS Code with a scratch file, and foot with bash;
- per app: Ghostty, kitty, Google Chrome, Firefox, Nautilus, Obsidian,
  LibreOffice Writer.

## 5. Recipes

Work only on throwaway windows: launch them yourself, guard every trigger by
pid, and close only what the test launched.

- **A handler that acts on its window** (⌘W, ⌘Q, ⌥⌘Esc): use a throwaway
  `foot -a omackey.<name> …` or a private keylog. Check the pid and trigger in
  the same `repl` call.
- **Throwaway Nautilus** (F5):
  `DBUS_SESSION_BUS_ADDRESS=disabled: nautilus --new-window DIR &`. Use a
  scratch folder and a pid guard. Screenshot its geometry with
  `grim -g "<x>,<y> <w>x<h>"`, taken from `hyprctl clients -j`.
- **Terminals** (F10):
  - Ghostty: `ghostty --gtk-single-instance=false -e bash -c '…'`.
    `printf '\033]2;ONE\a'` sets a tab title you can read from
    `hyprctl clients -j`.
  - The bytes a terminal sends: `stty raw -echo; dd bs=1 count=1 of=FILE`,
    then `od -An -tx1 FILE`.
  - Font size: a `trap 'tput cols > FILE' WINCH` loop.
  - A terminal action that spawns another program also needs `ps` and the
    window list watched, not only a "handled" result.
  - Ghostty is D-Bus activated: a test launch can reach the user's own
    instance, so check the pid.
- **Browsers** (F11):
  - Chromium:
    `chromium --user-data-dir=DIR --no-first-run --remote-debugging-port=PORT`.
    `curl localhost:PORT/json` lists tabs and targets.
  - Firefox: `firefox --no-remote --profile DIR`.
  - Close extra windows by address between keys, because a new window takes
    focus.
- **What an app received from a physical press** (F19, F21): a throwaway page
  that logs key, mouse and wheel events with timestamps and POSTs them to a
  local listener. Ask the user to keep their hands off during synthetic runs.
- **VS Code**: a throwaway instance with its own `--user-data-dir`.
- **LibreOffice**: synthetic keys may do nothing for a while after a dialog or
  the find bar had focus. Plain letters sent by keycode don't type. Test with
  cut / undo / redo on a selection (F17).
- **The ⌘Tab session** can't see a ⌘ release from a script. End it with
  `switcher.finish()`, and wait until a closed window is gone from
  `hyprctl clients` before the next step.

## 6. Recovery

- **Stuck or repeating key:** press and release that key, then
  `hyprctl reload`.
- **Bad config:** check `hyprctl configerrors`. A Lua error in a required
  module stops the rest of `hyprland.lua` from loading, including the user's
  bindings; OMacKey's loader lines are guarded against this. For OMacKey
  errors, see `hyprctl repl 'return omackey.status()'`.
- **Disable OMacKey:**
  - ⌃⇧⌘M or `scripts/omackey-mode off` switches it off and keeps it
    installed;
  - `./uninstall.sh` removes it;
  - or delete the marker lines in `~/.config/hypr/hyprland.lua` and run
    `hyprctl reload`.

  If the desktop is unusable, use a TTY (Ctrl+Alt+F3).
- **Stuck in a submap:** `hyprctl dispatch 'hl.dsp.submap("reset")'`.
- **`omarchy refresh hyprland`** resets the user's Hyprland config, with a
  backup. Ask the user first. It removes OMacKey's lines, so re-run
  `install.sh` afterwards.
