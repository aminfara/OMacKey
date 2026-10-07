# OMacKey — Limitations

Mac shortcuts and behaviours OMacKey does not map, or maps only in part, with
the reason and what to use instead. Add a row whenever a key is left unmapped
or an Omarchy bind can't get a new home (ARCHITECTURE.md §11). FINDINGS.md has
the details behind the F-numbers.

## Desktop and windows

| Item | Why | Instead |
| --- | --- | --- |
| ⌃↑ Mission Control, ⌃↓ App Exposé, and the F3 Mission Control key (`XF86LaunchA`) | Hyprland has no built-in overview and Omarchy ships none. ⌃↑ / ⌃↓ focus windows instead (the arrow rule) | ⌘\` cycles the active app's windows; ⌃⌥ + arrows switch workspace |
| ⌘Tab overlay (app icons and names) | Hyprland has no switcher UI; the focus change is the feedback, and intermediate stops visibly flip workspaces. A QuickShell overlay is an optional idea (ROADMAP.md) | ⌘Tab / ⇧⌘Tab step through apps while ⌘ is held; ⌥Tab cycles windows in layout order; ⌘\` cycles the active app's windows |
| ⌘M minimize, ⌘H hide app, ⌥⌘H hide others, ⌥⌘M minimize all | D13: Hyprland and Omarchy have no minimize or hide, and with no dock a hidden window is easy to lose (F7). The catch-all consumes ⌘M and ⌘H | Omarchy's scratchpad (⌃⌥⇧S moves the window there, ⌃⌥S shows it), or park it on a workspace with ⌃⇧1–0 |
| ⇧⌘Q log out | no instant logout wanted; Omarchy's system menu is not one. The catch-all consumes ⇧⌘Q, because `Ctrl+Shift+Q` quits Chrome | ⌘Esc opens the system menu |
| Physical ⌃← / ⌃→ word jump in Linux apps | ⌃← / ⌃→ focus windows (the arrow rule) | ⌥← / ⌥→ |
| Trackpad gestures (3- and 4-finger swipes, pinch) | the user's machine is a desktop with no trackpad, so nothing could be tested | Hyprland's `gesture` options in the user's own config |
| PC keyboards (Alt next to the space bar) | an xkb Alt/Super swap (`altwin:swap_lalt_lwin`) was considered and skipped; it would edit the user's `input.lua` | set it in `~/.config/hypr/input.lua` yourself |

## Mouse

| Item | Why | Instead |
| --- | --- | --- |
| ⌘-right-click, ⌘-middle-click | only the left button is translated (⌘-click and ⇧⌘-click); the other buttons reach apps with ⌘ held | physical ⌃-right-click |
| ⌘-click with other modifiers (⌥⌘-click, ⌃⌘-click) | only ⌘ and ⇧⌘ are translated | none |
| ⌘-click: the press is sent about a millisecond late | the real press is consumed and re-sent, so a ⌘-click is a synthetic click (F21). No problem seen so far | none needed |
| ⌘-scroll: the first tick of each burst | it starts the virtual Ctrl (F20) and is consumed, so it does nothing (a plain tick would scroll the page) | none needed |
| ⌘-scroll without `wtype` | the held Ctrl comes from `wtype`; without it the scroll binds are not bound | install `wtype` and reload |

## Text and characters

| Item | Why | Instead |
| --- | --- | --- |
| ⌥ + letter special characters (å ß ∂ …) | ⌥ stays Meta for terminals | Omarchy's Compose key: tap Caps Lock, then a short sequence (`'` `e` → é, `o` `a` → å, `s` `s` → ß, `-` `-` `.` → –). Where the sequences live: ARCHITECTURE.md §12. ⌃⌘Space opens the emoji and symbols picker |
| Mac Home / End (scroll to document top / bottom) | Linux semantics kept | ⌘↑ / ⌘↓ |
| Emacs ⌃T, ⌃O, ⌃V, ⌃Y | not mapped; the Emacs keys cover ⌃A / ⌃E, ⌃F / ⌃B / ⌃N / ⌃P, ⌃D / ⌃H, ⌃K | none |
| ⇧⌘ + digits (⇧⌘1, 2, 6–9) | the catch-all skips them: ⇧⌘3/4/5 are screenshots, and Ctrl+Shift+digit means little on Linux | none |

## Browsers

| Item | Why | Instead |
| --- | --- | --- |
| ⌘← / ⌘→ as back / forward outside text fields | focus inside the page can't be detected | ⌘[ / ⌘] |
| Chromium-family ⌘, (settings) | no Linux shortcut, and Chromium turns a `chrome://` URL on the command line into a blank tab (F11); a typed-URL key sequence was judged too hacky | the menu, or type `chrome://settings` / `brave://settings` (Firefox ⌘, works) |
| Chromium-family ⇧⌘P | the catch-all sends `Ctrl+Shift+P`, which Chrome and Brave on Linux bind to "print using system dialog" (Mac: ⌥⌘P; ⇧⌘P does nothing there). Firefox: private window on both. Left as is (user's choice) | ⌘P for the normal print dialog |
| Firefox ⌥⌘K (Web Console) | Omarchy's tmux-keybindings bind owns `SUPER + ALT + K`; not worth a relocation | ⌥⌘J (Browser Console) or ⌥⌘I (toolbox) |

## Terminals

| Item | Why | Instead |
| --- | --- | --- |
| ⌘G / ⇧⌘G (find next / previous) | they only act while a search is open, which Hyprland can't see. foot's keys are `Ctrl+S` / `Ctrl+R` (a stray `Ctrl+S` freezes output outside search), and Ghostty's Linux defaults have none (its Mac ⌘G is `performable`, so it passes through when no search is open) | optional Ghostty line `keybind = performable:ctrl+g=navigate_search:next`, not applied |
| Ghostty ⌘W in a split | Linux Ghostty's `Ctrl+Shift+W` closes the whole tab; closing one split needs a `close_surface` keybind in the user's config | optional, not applied |
| ⌘K clears the scrollback | `Ctrl+L` only clears the visible screen (Ghostty on the Mac clears the scrollback too) | `clear` plus `printf '\e[3J'` |
| ⌘D / ⇧⌘D (split) outside Ghostty | foot has no splits; kitty's splits are layouts, not a split command | Hyprland tiling |
| ⌘↑ / ⌘↓ prompt jumping outside Ghostty | foot's `Ctrl+Shift+Z/X` need shell integration (OSC 133), not set up here | they scroll a page instead |
| kitty ⌘1–9 | kitty has no default key for tab N | ⇧⌘[ / ⇧⌘] |
| tmux | Hyprland can't tell that tmux runs inside a terminal, so it gets the plain terminal rules | tmux's own prefix keys |

## VS Code

| Item | Why | Instead |
| --- | --- | --- |
| The integrated terminal: every ⌘ key except ⌘C / ⌘V | Hyprland sees one window, so the editor's `Ctrl+X` / `Ctrl+Z` / `Ctrl+A` … reach the terminal as readline control keys. Only ⌘C / ⌘V have a chord that works in both (F12) | the terminal's own `Ctrl+Shift+` keys, or move focus to an editor |
| Emacs ⌃D | ⌃D passes through: readline in the integrated terminal needs the raw ⌃D (end of input). The other Emacs keys are translated there, so in its terminal ⌃K sends `Shift+End`, `Delete` (deletes one character instead of killing the line) | Delete in the editor |
| ⌘W with no editor open | Linux VS Code ignores `Ctrl+W` on an empty window (macOS closes the window). Adding VS Code to `close_window_classes` would close the window while editors are open (F3) | ⇧⌘W |
| ⌥⌘I (Toggle Developer Tools) | `Ctrl+Shift+I` is also Format Document on Linux and wins with the editor focused (F11), so ⌥⌘I is consumed in VS Code | the command palette: "Developer: Toggle Developer Tools" |
| ⌘↓ / ⌘↑ open a file / go up in lists (Explorer, search results) | the same key moves to the document end / start in the editor, and Hyprland can't see which has focus | Enter, or the arrow keys |
| ⌥⇧⌘ arrows (column select) | Linux VS Code has no keyboard column select, and `Ctrl+Shift+Alt+Up/Down`, the Mac chord with Ctrl, is Copy Line Up/Down there (F13) | ⇧⌥ + mouse drag, or a user keybinding for `cursorColumnSelect*` |
| ⌥⌘ + other keys and ⌘ + F-keys (⌥⌘K / T / S / Y, ⌘F2, ⌘F12 …) | the catch-all covers ⌘ and ⇧⌘ only; these are obscure, and ⌘ + F-key needs Fn on the NuPhy in Mac mode | VS Code's own `Ctrl+Alt+…` / `Ctrl+F2` keys |
| ⇧⌘Space (parameter hints), ⌘Esc | Omarchy owns them (toggle top bar, system menu) | `Ctrl+Shift+Space`, or ⌃Space for suggestions |
| ⇧⌘U (toggle output) | no Linux key exists, and the catch-all consumes ⇧⌘U (Unicode input) | the command palette |
| Physical ⌃- / ⌃⇧- (navigate back / forward) | not mapped: it would take physical Ctrl from one app | a bind in your own `bindings.lua` |
| ⌃Space (suggest) | fcitx5's default trigger is Ctrl+Space and may take it first | change fcitx5's trigger key |

## Other apps

| Item | Why | Instead |
| --- | --- | --- |
| Nautilus ⌘D duplicate, ⇧⌘⌫ empty trash, ⏎ to rename | no direct Nautilus action (⌘D arrives as `Ctrl+D`, add bookmark) | F2 renames |
| Obsidian ⌥⌘[ / ⌥⌘] (fold / unfold) | Obsidian has no default fold hotkey on any platform (F16) | set a hotkey for "Toggle fold" in Obsidian's Hotkeys settings |
