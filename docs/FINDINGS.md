# OMacKey — Findings

Facts learned while building OMacKey: spike results, Hyprland and Omarchy
behaviour, app quirks, and test recipes. Each entry is dated. Phase labels in
the headings (6a, 7g …) are the build phases in ARCHITECTURE.md §13. Code
comments cite entries by number (F10), so numbers are never reused: a new
finding gets the next number.

Contents:

- F0 Pre-spike facts · F1 Phase 0 spikes · F2 ⌥ keys and keylog
- F3 VS Code class, ⌘W, terminal tags · F4 Zoom · F5 ⌘1–⌘9
- F6 App and window switching · F7 Minimize and hide · F8 Screenshot CLI
- F9 NuPhy F-row · F10 Terminal keys · F11 Browser keys
- F12 VS Code's integrated terminal · F13 VS Code keys · F14 Catch-all
- F15 VS Code Mac vs Linux keymap · F16 Obsidian keys · F17 LibreOffice keys
- F18 Mac-mode toggle · F19 ⌘-click spike · F20 Ctrl held by wtype
- F21 Synthetic mouse button · F22 NumLock and explicit mods
- F23 LibreOffice's find bar · F24 ⌘-scroll and the bind
- F25 Keysyms, keycodes and the written key · F26 Refactor details

---

## F0 — Pre-spike facts (planning session, 2026-10-01)

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
  - Keep the code 5.4/5.5-compatible. Hyprland's embedded version is 5.5
    too (F1, S10).
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

## F1 — Phase 0 spike results (2026-10-01)

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

## F2 — Phase 2 findings (2026-10-02)

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

## F3 — Phase 4 findings (2026-10-03)

- **VS Code's window class** here is `com.microsoft.VSCode` (native Wayland,
  installed in `/usr/share/code`), not `code` as first assumed.
  `apps/vscode.lua` matches it (and `code`, `code-oss`, `Code`).
- **⌘W in VS Code** closes the active editor (also inside editor groups). With
  no editor open it does not close the window: that is native Linux behaviour,
  macOS closes it. `Ctrl+Shift+W` closes the window (⌘⇧W, next). VS Code stays
  off the `no-tabs` list, which would close the window with editors open (LIMITATIONS.md).
- **Terminal tag coverage.** Omarchy's `terminal` tag matches `Alacritty`,
  `kitty`, `com.mitchellh.ghostty`, `foot`, `wezterm`, `org.omarchy.*` and
  `TUI.*`, so ⌘W also closes Omarchy's TUI windows (btop and friends).
- **`window.pid`** is readable from Lua, so a test can check the active window
  and fire a handler in one `hyprctl repl` call (TESTING.md).
- **A private keylog copy** (D-Bus disabled) has window class `keylog.py`, not
  `omackey.keylog`. Focus it by pid.

## F4 — Zoom findings (2026-10-03)

- **⌘0 is not "go to tab".** On macOS, ⌘0 resets browser zoom (Safari,
  Chrome and Firefox); ⌘1–⌘8 select tabs 1–8 and ⌘9 the last tab.
- **VS Code has no `Ctrl+0` / ⌘0 zoom reset by default.** The reset command is
  bound to `Ctrl+Numpad0` (⌘Numpad0 on macOS); `Ctrl+0` is not it. So ⌘0 doing
  nothing to VS Code zoom is native behaviour, same as on a Mac without
  customizing. OMacKey maps it anyway: VS Code's ⌘0 sends `Ctrl+KP_0` (F13,
  F22).
- The user confirmed ⌘= ⌘+ ⌘- ⌘0 in keylog, Brave, foot and the rest.

## F5 — ⌘1–⌘9 findings (2026-10-03)

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
  nothing. The user's test saw no tab switching for that reason. `apps/nautilus.lua`
  swaps them back.
- **Throwaway Nautilus for tests.** `DBUS_SESSION_BUS_ADDRESS=disabled:
  nautilus --new-window DIR &` starts a standalone instance (the dconf and
  D-Bus warnings are harmless), class `org.gnome.Nautilus`. Focus it by pid and
  guard each trigger by pid. `grim -g "<x>,<y> <w>x<h>"` takes a screenshot of
  its geometry from `hyprctl clients -j`, and `kill <pid>` closes it.

## F6 — App and window switching (2026-10-03)

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

## F7 — Minimize and hide (2026-10-03)

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

## F8 — Screenshot CLI (2026-10-03)

- `omarchy-capture-screenshot <mode> <processing>`: processing `save` writes
  `screenshot-<date>.png` to `$XDG_PICTURES_DIR` and nothing else, `copy` only
  fills the clipboard, and the default (`slurp`) does both plus a notification
  with an edit action.
- Mode `fullscreen` captures the focused monitor with no interaction, `region`
  shows the picker. Running it again while the picker is open kills it
  (`pkill slurp`).
- Digit keys are bound by keycode: ⌘⇧3 is `SUPER + SHIFT + code:12`; the help
  menu shows it as `SUPER SHIFT + 3`.

## F9 — NuPhy Air75 V2 F-row in Mac mode (2026-10-03)

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
  `voxtype record toggle`. Specs take a `release` flag for this (`dictation-stop`).

## F10 — Terminal keys (6a, 2026-10-03)

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
- **The profile chain** `{ "ghostty", "terminal", "default" }`: Ghostty,
  kitty and foot each have `family = "terminal"` (`lib/profiles.lua`). Omarchy's TUI
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

## F11 — Browser keys (6b, 2026-10-04)

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
- **Test recipes.** Chromium: `chromium --user-data-dir=DIR --no-first-run
  --remote-debugging-port=PORT`; `curl localhost:PORT/json` lists the tabs, so
  history, downloads, bookmarks, view-source, clear data and DevTools show up as
  tabs or targets. Firefox: `firefox --no-remote --profile DIR`, its windows
  from `hyprctl clients`, screenshots for the sidebar and DevTools. Close extra
  windows by address between keys: a new window takes focus. The Brave profile
  needs its own first-run handling, so Brave was not driven.

## F12 — VS Code's integrated terminal (found by the user, 2026-10-05)

Hyprland sees one `com.microsoft.VSCode` window, so a profile can't tell the
editor from the integrated terminal. `Ctrl+C` there is SIGINT and `Ctrl+V` a
literal-next. `Ctrl+Insert` / `Shift+Insert` are VS Code's Windows/Linux
copy/paste defaults in the editor and also work in the terminal, so ⌘C / ⌘V
use them under profile `vscode`. Other ⌘ keys still reach the terminal as
Ctrl chords (LIMITATIONS.md).

## F13 — VS Code keys (6c, 2026-10-05)

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
  plan's 6c row would have duplicated lines (LIMITATIONS.md).
- **Numpad 0 arrives as `KP_Insert`** in keylog (code 90). That turned out to
  matter: with NumLock on, VS Code needs `KP_0`, see F22.

## F14 — Catch-all facts (7a, 2026-10-05)

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

## F15 — VS Code Mac vs Linux keymap (6c-2, 2026-10-05)

- **Extraction.** Every `primary:N` object in `workbench.desktop.main.js`
  (kbOpts, keybinding, registerCommandAndKeybindingRule), with its `mac:{}` and
  `linux:{}` overrides, decoded as in F13 (Cmd 2048, Shift 1024, Alt 512,
  WinCtrl 256; Mac WinCtrl = physical ⌃). About 1,100 bindings (the parser
  also yields the same object twice, and some ids come out as `?`; chord-style
  bindings such as ⌘K ⌘S use another encoding and were not extracted, but
  they are plain Ctrl chords on both platforms). Script kept out of the repo.
- **Result.** 476 of 591 Mac ⌘ chords are the same key with Ctrl on Linux, so
  a plain translation is correct. 115 differ; most are scope-specific (terminal,
  chat, lists, notebooks), the rest became
  `apps/vscode.lua` entries or LIMITATIONS.md rows.
- **Same physical chord, different command** (the dangerous kind, since ⌥ and
  ⌃ pass through): ⌥⇧↑ / ↓ (Mac copy line, Linux add cursor), ⌥⇧A (Mac block
  comment, Linux nothing). The other differing chords were Emacs ⌃ keys (7c).
- **Catch-all gap found by the audit:** keys claimed by a profile-only entry
  passed the raw ⌘ chord outside that profile (⌘K in VS Code, so every ⌘K chord
  failed). Fixed: those specs now have a `default` of their own (Ctrl chord,
  consumed in terminals), written in `shortcuts.lua`; F14 lists the keys.
- **Zoom:** the Mac also zooms out on ⌘⇧-; Linux has `Ctrl+Shift+-` as
  Navigate Forward, which the catch-all would have sent.

## F16 — Obsidian keys (6e, 2026-10-05)

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

## F17 — LibreOffice keys (6f, 2026-10-05)

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

## F18 — Mac-mode toggle (7d, 2026-10-05)

- **`hl.dsp.exec_cmd` runs a shell line**: `&&` and `;` work, so one command
  can create the state file, notify and reload. A first version silently did
  nothing when the message held an apostrophe inside single quotes ("Omarchy's"):
  keep shell-quoted text free of `'`.
- **No reload API** in `hl` (`hyprctl reload` through `exec_cmd`); a reload starts
  a fresh Lua state, which is what makes the file-at-load switch work.
- **Off still loads cleanly under the help-menu replay**: the menu lists Omarchy's
  keys plus the toggle line.

## F19 — ⌘-click spike (7g, 2026-10-05)

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

## F20 — Ctrl held by wtype (7g, 2026-10-05)

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
  Three slow ticks 1 s apart all arrived with Ctrl although a hold only lasts
  400 ms; F24 explains why.
- **No wall clock in Lua** (`os.clock` is CPU time, `os.time` whole seconds), so
  `lib/ctrl_hold.lua` keeps its state with timers and a generation counter.
- **Safety.** Each `wtype` releases its own Ctrl when its sleep ends, so a crash or
  a missed event can leave Ctrl held for at most 400 ms.

## F21 — Synthetic mouse button (7g, 2026-10-05)

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

## F22 — NumLock and explicit mods (2026-10-07)

- `send_key_state` with explicit `mods` replaces the locked modifiers too, so
  NumLock (Mod2) is dropped from the event. With NumLock on, keycode 90
  reached apps as `KP_Insert`, not `KP_0`, and VS Code's ⌘0 (reset zoom,
  `Ctrl+Numpad0`) did nothing.
- Sending `CTRL + MOD2` gives `KP_0` (keylog) and resets the zoom (tested on a
  throwaway VS Code with its own `--user-data-dir`).
- Only keypad keys care, and `kp_0` is the only one OMacKey sends. The action's
  text leaves MOD2 out ("Ctrl+Keypad 0").

## F23 — LibreOffice's find bar (2026-10-07)

- `Ctrl+Shift+F` is `.uno:RepeatSearch` in Writer, but it repeats the Find &
  Replace dialog's search, not a search typed in the find bar (⌘F). So ⌘G did
  nothing in the usual workflow (F17's choice).
- Driving the find bar works:
  1. `Ctrl+F` focuses the bar, which keeps its text;
  2. `Return` / `Shift+Return` find the next / previous match;
  3. `Escape` closes the bar with the match selected.

  These are sent as one `seq`, 25 ms apart. The user's physical test: ⌘G and
  ⇧⌘G step through the matches in Writer.
- So LibreOffice does have a find-previous key, which F17 had missed.

## F24 — ⌘-scroll and the bind (2026-10-07)

- A slow burst of ⌘-scroll-up ticks counted only one press of `scroll-up`
  (`omackey.fired`).
- Once `wtype` holds Ctrl (F20), the modifier state is ⌃⌘, so ⌘ + wheel no
  longer matches the bind. The ticks reach the app directly with Ctrl, which
  is the point. The bind fires only on the tick that starts a hold.
- This is the likely explanation for F20's slow ticks: ticks that arrive while
  Ctrl is held never reach the bind.

## F25 — Keysyms, keycodes and the written key (2026-10-07)

- `input:resolve_binds_by_sym` is off here (Hyprland's default). Binds then
  resolve against the first layout. On a US-first layout `SUPER + slash` and
  `SUPER + code:61` are the same physical key.
- On another first layout (German, say) a key name can sit on a different
  physical key, while a keycode stays put. That is why Omarchy's keycode binds
  (− = [ ] and the digits) stay keycodes in OMacKey's relocation targets.
- `hyprctl binds` and the help menu show a key the way it was written.
  Rewriting the catch-all's `SUPER + e` as `SUPER + E` changed only the case
  in both.
- Together with `hl.unbind`'s exact match (F0), this is why every OMacKey key
  string has one canonical form (ARCHITECTURE.md §6).

## F26 — Refactor details (2026-10-06 to 2026-10-07)

- **Hyprland dispatchers are opaque** (`hl.dsp.*` returns userdata), so no text
  can be derived from one. Actions get theirs from `does()`.
- **A bind without a description** shows as an empty description in
  `hyprctl binds` (Omarchy's lid switches). The snapshot mock renders it as
  `""` to match.
- **`send.tap()` resolves key names when the spec is declared**, so an unknown
  key name is a Lua error at declare time. `init.lua` requires each module
  under `pcall`, so the error skips the rest of that module only.
- **`o.bind` ignores `hl.bind`'s return value**, so the relocation hook can
  return nothing for a dropped bind.
