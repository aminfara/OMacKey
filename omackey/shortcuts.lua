-- Every Mac shortcut OMacKey adds, declared once, one section per group of
-- Mac meaning. Each spec says what the key does in a generic app
-- (`default`, or `action` when it is the same in every app); apps/*.lua add
-- per-app entries by id. The section a spec sits in is its category.
--
-- Declaring binds nothing: lib/bind.lua validates the complete set and binds
-- it in one pass (load.lua). Helpers and state live in lib/.

local bind = require("hypr.omackey.lib.bind")
local click = require("hypr.omackey.lib.click")
local ctrl_hold = require("hypr.omackey.lib.ctrl_hold")
local send = require("hypr.omackey.lib.send")
local switcher = require("hypr.omackey.lib.switcher")
local windows = require("hypr.omackey.lib.windows")

local mac, group, catchall, does = bind.mac, bind.group, bind.catchall, bind.does
local CONSUME = bind.CONSUME
local tap, seq = send.tap, send.seq

-- Text ------------------------------------------------------------------------
-- Cursor movement, selection and deletion, as in a Mac text field.

group("Text", {
  mac({
    id = "line-start",
    keys = "SUPER + LEFT",
    desc = "Line start",
    repeating = true,
    actions = {
      default = tap("", "Home"), -- terminals too: readline/nvim treat Home as line start
    },
  }),

  mac({
    id = "line-end",
    keys = "SUPER + RIGHT",
    desc = "Line end",
    repeating = true,
    actions = {
      default = tap("", "End"), -- terminals too: readline/nvim treat End as line end
    },
  }),

  mac({
    id = "select-line-start",
    keys = "SUPER + SHIFT + LEFT",
    desc = "Select to line start",
    repeating = true,
    actions = {
      default = tap("SHIFT", "Home"),
    },
  }),

  mac({
    id = "select-line-end",
    keys = "SUPER + SHIFT + RIGHT",
    desc = "Select to line end",
    repeating = true,
    actions = {
      default = tap("SHIFT", "End"),
    },
  }),

  mac({
    id = "word-left",
    keys = "ALT + LEFT",
    desc = "Word left",
    repeating = true,
    actions = {
      default = tap("CTRL", "Left"), -- terminals too: /etc/inputrc maps Ctrl+Left to backward-word
    },
  }),

  mac({
    id = "word-right",
    keys = "ALT + RIGHT",
    desc = "Word right",
    repeating = true,
    actions = {
      default = tap("CTRL", "Right"), -- terminals too: /etc/inputrc maps Ctrl+Right to forward-word
    },
  }),

  mac({
    id = "select-word-left",
    keys = "ALT + SHIFT + LEFT",
    desc = "Select word left",
    repeating = true,
    actions = {
      default = tap("CTRL + SHIFT", "Left"),
    },
  }),

  mac({
    id = "select-word-right",
    keys = "ALT + SHIFT + RIGHT",
    desc = "Select word right",
    repeating = true,
    actions = {
      default = tap("CTRL + SHIFT", "Right"),
    },
  }),

  mac({
    id = "document-start",
    keys = "SUPER + UP",
    desc = "Document start",
    repeating = true,
    actions = {
      default = tap("CTRL", "Home"),
    },
  }),

  mac({
    id = "document-end",
    keys = "SUPER + DOWN",
    desc = "Document end",
    repeating = true,
    actions = {
      default = tap("CTRL", "End"),
    },
  }),

  mac({
    id = "select-document-start",
    keys = "SUPER + SHIFT + UP",
    desc = "Select to document start",
    repeating = true,
    actions = {
      default = tap("CTRL + SHIFT", "Home"),
    },
  }),

  mac({
    id = "select-document-end",
    keys = "SUPER + SHIFT + DOWN",
    desc = "Select to document end",
    repeating = true,
    actions = {
      default = tap("CTRL + SHIFT", "End"),
    },
  }),

  mac({
    id = "delete-word-left",
    keys = "ALT + BACKSPACE",
    desc = "Delete word left",
    repeating = true,
    actions = {
      default = tap("CTRL", "BackSpace"),
    },
  }),

  mac({
    id = "delete-word-right",
    keys = "ALT + DELETE",
    desc = "Delete word right",
    repeating = true,
    actions = {
      default = tap("CTRL", "Delete"),
    },
  }),

  mac({
    id = "delete-line-start",
    keys = "SUPER + BACKSPACE",
    desc = "Delete to line start",
    repeating = true,
    actions = {
      default = seq(tap("SHIFT", "Home"), tap("", "BackSpace")),
    },
  }),

  mac({
    id = "delete-line-end",
    keys = "SUPER + DELETE",
    desc = "Delete to line end",
    repeating = true,
    actions = {
      default = seq(tap("SHIFT", "End"), tap("", "Delete")),
    },
  }),
})

-- Editing ---------------------------------------------------------------------
-- Clipboard, undo and redo, saving and text styles. Omarchy's universal copy, paste
-- and cut are dropped in relocations.lua.

group("Editing", {
  mac({
    id = "copy",
    keys = "SUPER + C",
    desc = "Copy",
    actions = {
      default = tap("CTRL", "C"),
    },
  }),

  mac({
    id = "paste",
    keys = "SUPER + V",
    desc = "Paste",
    actions = {
      default = tap("CTRL", "V"),
    },
  }),

  mac({
    id = "cut",
    keys = "SUPER + X",
    desc = "Cut",
    actions = {
      default = tap("CTRL", "X"),
    },
  }),

  mac({
    id = "paste-plain",
    keys = "SUPER + SHIFT + V",
    desc = "Paste without formatting",
    actions = {
      default = tap("CTRL + SHIFT", "V"),
    },
  }),

  -- Paste Special (LibreOffice). ⇧⌘V pastes unformatted text everywhere, so this
  -- is the way to the dialog. Elsewhere ⌥⌘V reaches the app as a raw chord.
  mac({
    id = "paste-special",
    keys = "SUPER + ALT + V",
    desc = "Paste special (LibreOffice)",
  }),

  mac({
    id = "undo",
    keys = "SUPER + Z",
    desc = "Undo",
    repeating = true,
    actions = {
      default = tap("CTRL", "Z"),
    },
  }),

  mac({
    id = "redo",
    keys = "SUPER + SHIFT + Z",
    desc = "Redo",
    repeating = true,
    actions = {
      default = tap("CTRL + SHIFT", "Z"), -- LibreOffice uses Ctrl+Y
    },
  }),

  -- Redo selection (Obsidian). Elsewhere ⇧⌘U is consumed, as in the catch-all
  -- (Ctrl+Shift+U starts Unicode input in GTK and fcitx5).
  mac({
    id = "redo-selection",
    keys = "SUPER + SHIFT + U",
    desc = "Redo selection (Obsidian)",
    actions = {
      default = CONSUME,
    },
  }),

  mac({
    id = "select-all",
    keys = "SUPER + A",
    desc = "Select all",
    actions = {
      default = tap("CTRL", "A"),
    },
  }),

  mac({
    id = "save",
    keys = "SUPER + S",
    desc = "Save",
    actions = {
      default = tap("CTRL", "S"),
    },
  }),

  mac({
    id = "save-as",
    keys = "SUPER + SHIFT + S",
    desc = "Save as",
    actions = {
      default = tap("CTRL + SHIFT", "S"),
    },
  }),

  mac({
    id = "bold",
    keys = "SUPER + B",
    desc = "Bold",
    actions = {
      default = tap("CTRL", "B"),
    },
  }),

  mac({
    id = "italic",
    keys = "SUPER + I",
    desc = "Italic",
    actions = {
      default = tap("CTRL", "I"),
    },
  }),

  mac({
    id = "underline",
    keys = "SUPER + U",
    desc = "Underline",
    actions = {
      default = tap("CTRL", "U"),
    },
  }),

  -- ⌘. cancels: Escape in GUI apps (dialogs, menus, search bars). Terminals
  -- interrupt (Ctrl+C, like Terminal.app); in VS Code it is Quick Fix.
  mac({
    id = "cancel",
    keys = "SUPER + period",
    desc = "Cancel (Escape)",
    actions = {
      default = tap("", "Escape"),
    },
  }),
})

-- Find ------------------------------------------------------------------------
-- Find and replace. The find-widget toggles (⌥⌘W, ⌥⌘R, ⌥⌘L, ⌥⌘P) act only in apps
-- with an entry (VS Code); elsewhere the raw chord reaches the app.

group("Find", {
  mac({
    id = "find",
    keys = "SUPER + F",
    desc = "Find",
    actions = {
      default = tap("CTRL", "F"),
    },
  }),

  -- F3 / Shift+F3 work in Chromium, Firefox, VS Code and GTK.
  mac({
    id = "find-next",
    keys = "SUPER + G",
    desc = "Find next",
    repeating = true,
    actions = {
      default = tap("", "F3"),
    },
  }),

  mac({
    id = "find-previous",
    keys = "SUPER + SHIFT + G",
    desc = "Find previous",
    repeating = true,
    actions = {
      default = tap("SHIFT", "F3"),
    },
  }),

  -- Omarchy's "Full width" is on ⌃⌥⏎.
  mac({
    id = "replace",
    keys = "SUPER + ALT + F",
    desc = "Replace",
  }),

  -- Find widget toggles (VS Code). Match case is ⌥⌘C, which is also the
  -- browsers' inspect key (Developer tools).
  mac({
    id = "find-whole-word",
    keys = "SUPER + ALT + W",
    desc = "Find: match whole word",
  }),

  mac({
    id = "find-regex",
    keys = "SUPER + ALT + R",
    desc = "Find: use regular expression",
  }),

  mac({
    id = "find-in-selection",
    keys = "SUPER + ALT + L",
    desc = "Find: in selection",
  }),

  mac({
    id = "find-preserve-case",
    keys = "SUPER + ALT + P",
    desc = "Replace: preserve case",
  }),
})

-- Code editing ----------------------------------------------------------------
-- Editor keys. Those without a default act only in the apps that have an entry
-- (VS Code, Obsidian) and reach other apps as raw chords.

group("Code editing", {
  mac({
    id = "toggle-comment",
    keys = "SUPER + slash",
    desc = "Toggle comment",
    actions = {
      default = tap("CTRL", "slash"),
    },
  }),

  mac({
    id = "block-comment",
    keys = "ALT + SHIFT + A",
    desc = "Toggle block comment",
  }),

  mac({
    id = "add-cursor-above",
    keys = "SUPER + ALT + UP",
    desc = "Add cursor above",
    repeating = true,
  }),

  mac({
    id = "add-cursor-below",
    keys = "SUPER + ALT + DOWN",
    desc = "Add cursor below",
    repeating = true,
  }),

  mac({
    id = "copy-line-up",
    keys = "ALT + SHIFT + UP",
    desc = "Copy line up",
    repeating = true,
  }),

  mac({
    id = "copy-line-down",
    keys = "ALT + SHIFT + DOWN",
    desc = "Copy line down",
    repeating = true,
  }),

  -- Omarchy's webcam size binds for these keys are on ⌃⌥.
  mac({
    id = "fold",
    keys = "SUPER + ALT + bracketleft",
    desc = "Fold code",
  }),

  mac({
    id = "unfold",
    keys = "SUPER + ALT + bracketright",
    desc = "Unfold code",
  }),

  mac({
    id = "shrink-selection",
    keys = "SUPER + CTRL + SHIFT + LEFT",
    desc = "Shrink selection",
    repeating = true,
  }),

  mac({
    id = "expand-selection",
    keys = "SUPER + CTRL + SHIFT + RIGHT",
    desc = "Expand selection",
    repeating = true,
  }),
})

-- Tabs ------------------------------------------------------------------------

group("Tabs", {
  mac({
    id = "new-tab",
    keys = "SUPER + T",
    desc = "New tab",
    actions = {
      default = tap("CTRL", "T"),
    },
  }),

  mac({
    id = "reopen-tab",
    keys = "SUPER + SHIFT + T",
    desc = "Reopen closed tab",
    actions = {
      default = tap("CTRL + SHIFT", "T"),
    },
  }),

  -- Omarchy's "Close window" is on ⌃⌥W (relocations.lua).
  mac({
    id = "close-tab",
    keys = "SUPER + W",
    desc = "Close tab or window",
    actions = {
      default = tap("CTRL", "W"),
    },
  }),

  -- ⌘1–⌘9: tab N (⌘9 is the last tab in browsers, as on a Mac). Omarchy's
  -- workspace binds are on ⌃1–0.
  mac({
    id = "tab-1",
    keys = "SUPER + code:10",
    desc = "Go to tab 1",
    actions = {
      default = tap("CTRL", "1"),
    },
  }),

  mac({
    id = "tab-2",
    keys = "SUPER + code:11",
    desc = "Go to tab 2",
    actions = {
      default = tap("CTRL", "2"),
    },
  }),

  mac({
    id = "tab-3",
    keys = "SUPER + code:12",
    desc = "Go to tab 3",
    actions = {
      default = tap("CTRL", "3"),
    },
  }),

  mac({
    id = "tab-4",
    keys = "SUPER + code:13",
    desc = "Go to tab 4",
    actions = {
      default = tap("CTRL", "4"),
    },
  }),

  mac({
    id = "tab-5",
    keys = "SUPER + code:14",
    desc = "Go to tab 5",
    actions = {
      default = tap("CTRL", "5"),
    },
  }),

  mac({
    id = "tab-6",
    keys = "SUPER + code:15",
    desc = "Go to tab 6",
    actions = {
      default = tap("CTRL", "6"),
    },
  }),

  mac({
    id = "tab-7",
    keys = "SUPER + code:16",
    desc = "Go to tab 7",
    actions = {
      default = tap("CTRL", "7"),
    },
  }),

  mac({
    id = "tab-8",
    keys = "SUPER + code:17",
    desc = "Go to tab 8",
    actions = {
      default = tap("CTRL", "8"),
    },
  }),

  mac({
    id = "tab-9",
    keys = "SUPER + code:18",
    desc = "Go to tab 9",
    actions = {
      default = tap("CTRL", "9"),
    },
  }),

  -- Previous and next tab on both Mac chords: Ctrl+Page_Up/Down, which browsers,
  -- VS Code and Nautilus take. Omarchy's group moves (⌥⌘←/→) are on ⌃⌥⌘.
  mac({
    id = "previous-tab",
    keys = "SUPER + SHIFT + bracketleft",
    desc = "Previous tab",
    actions = {
      default = tap("CTRL", "Page_Up"),
    },
  }),

  mac({
    id = "next-tab",
    keys = "SUPER + SHIFT + bracketright",
    desc = "Next tab",
    actions = {
      default = tap("CTRL", "Page_Down"),
    },
  }),

  mac({
    id = "previous-tab-arrow",
    keys = "SUPER + ALT + LEFT",
    desc = "Previous tab",
    actions = {
      default = tap("CTRL", "Page_Up"),
    },
  }),

  mac({
    id = "next-tab-arrow",
    keys = "SUPER + ALT + RIGHT",
    desc = "Next tab",
    actions = {
      default = tap("CTRL", "Page_Down"),
    },
  }),
})

-- Windows and apps ------------------------------------------------------------

group("Windows and apps", {
  mac({
    id = "new-window",
    keys = "SUPER + N",
    desc = "New window",
    actions = {
      default = tap("CTRL", "N"),
    },
  }),

  -- Private window in browsers, new folder in file managers.
  mac({
    id = "new-window-private",
    keys = "SUPER + SHIFT + N",
    desc = "New private window or folder",
    actions = {
      default = tap("CTRL + SHIFT", "N"),
    },
  }),

  -- The compositor's close request is what an app's own "close window" shortcut
  -- ends in, so one action covers every app (Ctrl+Shift+W for
  -- browsers and VS Code would do the same). Omarchy's Omawrite launcher is on
  -- ⌃⌥⌘W.
  mac({
    id = "close-window",
    keys = "SUPER + SHIFT + W",
    desc = "Close window",
    action = does("Close the window", hl.dsp.window.close()),
  }),

  mac({
    id = "quit-app",
    keys = "SUPER + Q",
    desc = "Quit app (close all its windows)",
    action = does("Close every window of the app", windows.quit_app), -- terminals too, as Terminal.app does
  }),

  -- ⌘Tab flips between the last two apps and, with ⌘ held, steps further along
  -- the recency list (lib/switcher.lua). Omarchy's workspace switching on these
  -- keys is on ⌃⌥← / ⌃⌥→; ⌥Tab still cycles windows in layout order.
  mac({
    id = "switch-app",
    keys = "SUPER + TAB",
    desc = "Switch app",
    action = does("Switch to the next app, most recently used first", function()
      switcher.step(true)
    end),
  }),

  mac({
    id = "switch-app-back",
    keys = "SUPER + SHIFT + TAB",
    desc = "Switch app backwards",
    action = does("Switch to the previous app in the recency list", function()
      switcher.step(false)
    end),
  }),

  -- Fixed-order ring of the active app's windows, across workspaces. With one
  -- window nothing happens.
  mac({
    id = "next-app-window",
    keys = "SUPER + grave",
    desc = "Next window of this app",
    action = does("Focus the next window of the app", function()
      windows.cycle_app_windows(1)
    end),
  }),

  mac({
    id = "previous-app-window",
    keys = "SUPER + SHIFT + grave",
    desc = "Previous window of this app",
    action = does("Focus the previous window of the app", function()
      windows.cycle_app_windows(-1)
    end),
  }),
})

-- Navigation ------------------------------------------------------------------
-- Open, print, reload, the address bar, back and forward, preferences, and the
-- browser pages (history, downloads, bookmarks, clearing data).

group("Navigation", {
  -- ⌘O/⌘P/⌘R/⌘L: Omarchy's pop, pseudo and layout binds are on ⌃⌥.
  mac({
    id = "open",
    keys = "SUPER + O",
    desc = "Open",
    actions = {
      default = tap("CTRL", "O"),
    },
  }),

  mac({
    id = "print",
    keys = "SUPER + P",
    desc = "Print or quick open",
    actions = {
      default = tap("CTRL", "P"),
    },
  }),

  mac({
    id = "reload",
    keys = "SUPER + R",
    desc = "Reload",
    actions = {
      default = tap("CTRL", "R"),
    },
  }),

  mac({
    id = "location",
    keys = "SUPER + L",
    desc = "Focus address bar",
    actions = {
      default = tap("CTRL", "L"),
    },
  }),

  -- Outdent and indent in editors (VS Code and Obsidian use Ctrl+[ / Ctrl+]);
  -- back and forward in browsers and Nautilus. Omarchy's webcam binds are on ⌃⌥.
  mac({
    id = "back",
    keys = "SUPER + bracketleft",
    desc = "Back or outdent",
    actions = {
      default = tap("CTRL", "bracketleft"),
    },
  }),

  mac({
    id = "forward",
    keys = "SUPER + bracketright",
    desc = "Forward or indent",
    actions = {
      default = tap("CTRL", "bracketright"),
    },
  }),

  -- Preferences. Omarchy's "dismiss last notification" is on ⌃⇧⌘,. VS Code,
  -- Obsidian and Nautilus open their settings on Ctrl+, . The Chromium family has
  -- no settings key and turns a chrome:// URL given on the command line into a
  -- blank tab, so there ⌘, sends the generic Ctrl+, (some web apps use it) and
  -- settings stay unmapped (docs/LIMITATIONS.md).
  mac({
    id = "preferences",
    keys = "SUPER + comma",
    desc = "Preferences",
    actions = {
      default = tap("CTRL", "comma"),
    },
  }),

  mac({
    id = "history",
    keys = "SUPER + Y",
    desc = "History",
    actions = {
      default = tap("CTRL", "Y"),
    },
  }),

  -- Chrome's downloads page; Firefox follows the same key (user's choice).
  mac({
    id = "downloads",
    keys = "SUPER + SHIFT + J",
    desc = "Downloads",
    actions = {
      default = tap("CTRL + SHIFT", "J"),
    },
  }),

  mac({
    id = "bookmark-manager",
    keys = "SUPER + ALT + B",
    desc = "Bookmark manager",
  }),

  -- Omarchy's "Toggle window gaps" is on ⌃⌥⇧⌫.
  mac({
    id = "clear-browsing-data",
    keys = "SUPER + SHIFT + BACKSPACE",
    desc = "Clear browsing data",
  }),
})

-- View ------------------------------------------------------------------------

group("View", {
  -- Zoom. Omarchy's resize binds for these keys are on ⌃⌥. foot and Ghostty take
  -- the same chords for font size. ⌘+ is ⇧⌘= and zooms in like ⌘=.
  mac({
    id = "zoom-in",
    keys = "SUPER + equal",
    desc = "Zoom in (app)",
    actions = {
      default = tap("CTRL", "equal"),
    },
  }),

  mac({
    id = "zoom-in-plus",
    keys = "SUPER + SHIFT + equal",
    desc = "Zoom in (app)",
    actions = {
      default = tap("CTRL", "equal"),
    },
  }),

  mac({
    id = "zoom-out",
    keys = "SUPER + minus",
    desc = "Zoom out (app)",
    actions = {
      default = tap("CTRL", "minus"),
    },
  }),

  -- ⇧⌘- zooms out in VS Code, as on the Mac; elsewhere it sends Ctrl+Shift+-,
  -- like the catch-all.
  mac({
    id = "zoom-out-shifted",
    keys = "SUPER + SHIFT + minus",
    desc = "Zoom out (VS Code)",
    actions = {
      default = tap("CTRL + SHIFT", "minus"),
    },
  }),

  mac({
    id = "zoom-reset",
    keys = "SUPER + code:19",
    desc = "Actual size (app zoom)",
    actions = {
      default = tap("CTRL", "0"),
    },
  }),

  -- Show hidden files (⇧⌘. in Finder). Elsewhere it sends Ctrl+Shift+., like the
  -- catch-all.
  mac({
    id = "show-hidden-files",
    keys = "SUPER + SHIFT + period",
    desc = "Show hidden files (Files)",
    actions = {
      default = tap("CTRL + SHIFT", "period"),
    },
  }),
})

-- Developer tools -------------------------------------------------------------
-- Mac Chrome and Firefox put these on ⌥⌘ + a letter; the Linux builds use
-- Ctrl+Shift + the same letter.

group("Developer tools", {
  -- DevTools. Obsidian toggles its on Ctrl+Shift+I too, so every GUI app gets it.
  mac({
    id = "devtools",
    keys = "SUPER + ALT + I",
    desc = "Developer tools",
    actions = {
      default = tap("CTRL + SHIFT", "I"),
    },
  }),

  -- Chrome's JavaScript console; Firefox's Browser Console, same key on Linux.
  mac({
    id = "devtools-console",
    keys = "SUPER + ALT + J",
    desc = "Developer console",
  }),

  mac({
    id = "devtools-inspect",
    keys = "SUPER + ALT + C",
    desc = "Inspect element",
  }),

  mac({
    id = "view-source",
    keys = "SUPER + ALT + U",
    desc = "View page source",
  }),
})

-- Terminal --------------------------------------------------------------------
-- Terminal keys. Outside terminals they send Ctrl / Ctrl+Shift + the same key,
-- like the catch-all.

group("Terminal", {
  -- Clear screen. Ghostty on the Mac clears the screen and all scrollback; Ctrl+L
  -- only clears the visible screen, so the scrollback stays
  -- (docs/LIMITATIONS.md).
  mac({
    id = "clear-screen",
    keys = "SUPER + K",
    desc = "Clear terminal screen",
    actions = {
      default = tap("CTRL", "K"),
    },
  }),

  -- Split panes exist only in Ghostty here (kitty's layouts are not a split
  -- command, foot has none).
  mac({
    id = "split-right",
    keys = "SUPER + D",
    desc = "Split terminal right",
    actions = {
      default = tap("CTRL", "D"),
    },
  }),

  mac({
    id = "split-down",
    keys = "SUPER + SHIFT + D",
    desc = "Split terminal down",
    actions = {
      default = tap("CTRL + SHIFT", "D"),
    },
  }),
})

-- Spaces ----------------------------------------------------------------------
-- Workspaces (Mac "Spaces"). The same in every app.
--
-- Arrow rule: ⌃ moves focus between windows and ⌃⇧ takes the window along
-- (relocations.lua); ⌥ steps up a level to workspaces, so ⌃⌥ switches
-- workspace and ⌃⌥⇧ takes the window to it. Numbers can only mean
-- workspaces, so they stay on ⌃ like macOS: ⌃1–0, ⌃⇧1–0, ⌃⌥⇧1–0 (silent).
--
-- relocations.lua moves Omarchy's SUPER+TAB pair to ⌃⌥→/←. This adds the
-- vertical pair (in scrolling, workspaces sit above and below the columns)
-- and moving the active window. "Previous" and "next" step through existing
-- workspaces, like Omarchy's SUPER+TAB did.

group("Spaces", {
  mac({
    id = "workspace-previous-up",
    keys = "CTRL + ALT + UP",
    desc = "Previous workspace",
    action = does("Focus the previous workspace", hl.dsp.focus({ workspace = "e-1" })),
  }),

  mac({
    id = "workspace-next-down",
    keys = "CTRL + ALT + DOWN",
    desc = "Next workspace",
    action = does("Focus the next workspace", hl.dsp.focus({ workspace = "e+1" })),
  }),

  mac({
    id = "window-to-previous-workspace-left",
    keys = "CTRL + ALT + SHIFT + LEFT",
    desc = "Move window to previous workspace",
    action = does("Move the window to the previous workspace", hl.dsp.window.move({ workspace = "e-1" })),
  }),

  mac({
    id = "window-to-previous-workspace-up",
    keys = "CTRL + ALT + SHIFT + UP",
    desc = "Move window to previous workspace",
    action = does("Move the window to the previous workspace", hl.dsp.window.move({ workspace = "e-1" })),
  }),

  mac({
    id = "window-to-next-workspace-right",
    keys = "CTRL + ALT + SHIFT + RIGHT",
    desc = "Move window to next workspace",
    action = does("Move the window to the next workspace", hl.dsp.window.move({ workspace = "e+1" })),
  }),

  mac({
    id = "window-to-next-workspace-down",
    keys = "CTRL + ALT + SHIFT + DOWN",
    desc = "Move window to next workspace",
    action = does("Move the window to the next workspace", hl.dsp.window.move({ workspace = "e+1" })),
  }),
})

-- System ----------------------------------------------------------------------
-- OS controls. The same in every app.

group("System", {
  mac({
    id = "lock-screen",
    keys = "SUPER + CTRL + Q",
    desc = "Lock screen",
    action = does("Lock the screen", hl.dsp.exec_cmd("omarchy-system-lock")),
  }),

  -- Screenshots: Omarchy's capture CLI. `save` writes a file, `copy` only fills
  -- the clipboard; ⇧⌘3 / ⌃⇧⌘3 are code:12 (digits are bound by keycode).
  mac({
    id = "screenshot-screen-file",
    keys = "SUPER + SHIFT + code:12",
    desc = "Screenshot of the screen to file",
    action = does(
      "Save a screenshot of the screen to a file",
      hl.dsp.exec_cmd("omarchy-capture-screenshot fullscreen save")
    ),
  }),

  mac({
    id = "screenshot-screen-clipboard",
    keys = "SUPER + CTRL + SHIFT + code:12",
    desc = "Screenshot of the screen to clipboard",
    action = does(
      "Copy a screenshot of the screen to the clipboard",
      hl.dsp.exec_cmd("omarchy-capture-screenshot fullscreen copy")
    ),
  }),

  -- Region capture uses Omarchy's picker: Return captures the window under the
  -- cursor, which is close to the Mac's Space.
  mac({
    id = "screenshot-region-file",
    keys = "SUPER + SHIFT + code:13",
    desc = "Screenshot of a region to file",
    action = does("Save a screenshot of a region to a file", hl.dsp.exec_cmd("omarchy-capture-screenshot region save")),
  }),

  mac({
    id = "screenshot-region-clipboard",
    keys = "SUPER + CTRL + SHIFT + code:13",
    desc = "Screenshot of a region to clipboard",
    action = does(
      "Copy a screenshot of a region to the clipboard",
      hl.dsp.exec_cmd("omarchy-capture-screenshot region copy")
    ),
  }),

  -- Capture menu: Omarchy's, which also covers screen recording.
  mac({
    id = "capture-menu",
    keys = "SUPER + SHIFT + code:14",
    desc = "Capture menu",
    action = does("Open Omarchy's capture menu", hl.dsp.exec_cmd("omarchy-menu toggle capture")),
  }),

  -- Force quit: the Mac asks which app in a dialog; here the active window's
  -- process is killed (SIGKILL) at once, with no confirmation.
  mac({
    id = "force-quit",
    keys = "SUPER + ALT + ESCAPE",
    desc = "Force quit the active window",
    action = does("Kill the window's process", hl.dsp.window.kill()),
  }),

  -- Emoji & symbols: Omarchy's picker (it also stays on ⌃⌘E).
  mac({
    id = "emoji-picker",
    keys = "SUPER + CTRL + SPACE",
    desc = "Emoji and symbols",
    action = does("Open the emoji picker", hl.dsp.exec_cmd("omarchy-shell shell toggle omarchy.emojis")),
  }),

  -- Show/hide the Dock: Omarchy's top bar (it also stays on ⇧⌘Space).
  mac({
    id = "toggle-bar",
    keys = "SUPER + ALT + D",
    desc = "Toggle top bar (Dock)",
    action = does("Show or hide the status bar", hl.dsp.exec_cmd("omarchy-toggle-bar")),
  }),

  -- Mac F-row keys that Omarchy leaves unbound. The keysyms are what the NuPhy
  -- sends in Mac mode (docs/FINDINGS.md F9). The rest of the row (brightness,
  -- media, volume) already works through Omarchy's XF86 binds.

  -- F6: Do Not Disturb.
  mac({
    id = "do-not-disturb",
    mac = "F6",
    keys = "XF86DoNotDisturb",
    desc = "Toggle silencing notifications (Do Not Disturb)",
    action = does("Silence or restore notifications", hl.dsp.exec_cmd("omarchy-toggle-notification-silencing")),
  }),

  -- F5: Dictation, push-to-talk like Omarchy's F9 (record while held), and
  -- ⇧F5 toggles. Bound only with voxtype installed, like Omarchy's own
  -- voxtype binds.
  mac({
    id = "dictation-start",
    mac = "F5",
    keys = "XF86VoiceCommand",
    desc = "Start dictation (push-to-talk)",
    requires = "voxtype",
    action = does("Start voxtype recording", hl.dsp.exec_cmd("voxtype record start")),
  }),

  mac({
    id = "dictation-stop",
    mac = "F5 (release)",
    keys = "XF86VoiceCommand",
    desc = "Stop dictation (push-to-talk)",
    requires = "voxtype",
    action = does("Stop voxtype recording and type the text", hl.dsp.exec_cmd("voxtype record stop")),
    release = true,
  }),

  mac({
    id = "dictation-toggle",
    mac = "⇧F5",
    keys = "SHIFT + XF86VoiceCommand",
    desc = "Toggle dictation",
    requires = "voxtype",
    action = does("Start or stop voxtype recording", hl.dsp.exec_cmd("voxtype record toggle")),
  }),
})

-- Mouse -----------------------------------------------------------------------
-- ⌘ + click and ⌘ + scroll reach apps as Ctrl + click and Ctrl + scroll
-- (⌘-click: new tab, multi-select, go to definition; ⌘ + scroll: zoom).
-- Omarchy's own ⌘ + mouse binds are on ⌃⌥ (relocations.lua).
--
-- Click: the real ⌘ + press and its release are consumed, and the same button
-- events are sent again with explicit Ctrl in `mods` (a synthetic event carries
-- the modifiers it is given, so the app sees Ctrl and not ⌘). A drag works because
-- the press and the release stay apart. If ⌘ is let go before the button, the real
-- release passes through on its own and closes the synthetic press.
--
-- Scroll: a wheel tick can't be re-sent, so it needs a real Ctrl instead:
-- lib/ctrl_hold.lua holds one through `wtype`, and the scroll keys are bound only
-- with wtype installed.

group("Mouse", {
  -- ⌘-click and ⇧⌘-click (Ctrl+Shift-click extends a selection in file managers).
  mac({
    id = "click",
    mac = "⌘-click",
    keys = "SUPER + mouse:272",
    desc = "⌘-click sent as Ctrl-click",
    action = click.press("CTRL"),
  }),

  mac({
    id = "click-shift",
    mac = "⇧⌘-click",
    keys = "SUPER + SHIFT + mouse:272",
    desc = "⌘⇧-click sent as Ctrl+Shift-click",
    action = click.press("CTRL + SHIFT"),
  }),

  -- The release can come with any modifiers still held. These close a pending
  -- synthetic press and let every other release through (lib/click.lua).
  mac({
    id = "click-release",
    mac = "⌘-click release",
    keys = "SUPER + mouse:272",
    desc = "⌘-click release",
    release = true,
    action = click.release,
  }),

  mac({
    id = "click-release-shift",
    mac = "⇧⌘-click release",
    keys = "SUPER + SHIFT + mouse:272",
    desc = "⌘⇧-click release",
    release = true,
    action = click.release,
  }),

  mac({
    id = "click-release-after-cmd",
    mac = "click release after ⌘",
    keys = "mouse:272",
    desc = "Click release after ⌘ was let go",
    release = true,
    action = click.release,
  }),

  mac({
    id = "click-release-after-cmd-shift",
    mac = "click release after ⌘ with ⇧",
    keys = "SHIFT + mouse:272",
    desc = "Click release after ⌘ was let go (⇧ held)",
    release = true,
    action = click.release,
  }),

  mac({
    id = "scroll-up",
    mac = "⌘-scroll up",
    keys = "SUPER + mouse_up",
    desc = "⌘-scroll up sent as Ctrl-scroll",
    requires = "wtype",
    action = does("Scroll with Ctrl held (zooms in apps that zoom on Ctrl + wheel)", ctrl_hold.tick),
  }),

  mac({
    id = "scroll-down",
    mac = "⌘-scroll down",
    keys = "SUPER + mouse_down",
    desc = "⌘-scroll down sent as Ctrl-scroll",
    requires = "wtype",
    action = does("Scroll with Ctrl held (zooms in apps that zoom on Ctrl + wheel)", ctrl_hold.tick),
  }),
})

-- Emacs keys ------------------------------------------------------------------
-- Emacs-style ⌃ keys for text fields, as in every Mac text field.
-- Controlled by the `emacs_keys` setting (settings.lua): declared either way,
-- bound only when it is on.
--
-- Terminals pass the raw key (readline already has all of these), and so does
-- ⌃D in VS Code (apps/terminal.lua, apps/vscode.lua).

group("Emacs keys", {
  mac({
    id = "emacs-line-start",
    keys = "CTRL + A",
    desc = "Line start (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = tap("", "Home"),
    },
  }),

  mac({
    id = "emacs-line-end",
    keys = "CTRL + E",
    desc = "Line end (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = tap("", "End"),
    },
  }),

  mac({
    id = "emacs-char-right",
    keys = "CTRL + F",
    desc = "Cursor right (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = tap("", "Right"),
    },
  }),

  mac({
    id = "emacs-char-left",
    keys = "CTRL + B",
    desc = "Cursor left (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = tap("", "Left"),
    },
  }),

  mac({
    id = "emacs-line-down",
    keys = "CTRL + N",
    desc = "Cursor down (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = tap("", "Down"),
    },
  }),

  mac({
    id = "emacs-line-up",
    keys = "CTRL + P",
    desc = "Cursor up (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = tap("", "Up"),
    },
  }),

  mac({
    id = "emacs-delete-right",
    keys = "CTRL + D",
    desc = "Delete right (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = tap("", "Delete"),
    },
  }),

  mac({
    id = "emacs-delete-left",
    keys = "CTRL + H",
    desc = "Delete left (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = tap("", "BackSpace"),
    },
  }),

  mac({
    id = "emacs-kill-line",
    keys = "CTRL + K",
    desc = "Delete to line end (Emacs key)",
    repeating = true,
    setting = "emacs_keys",
    actions = {
      default = seq(tap("SHIFT", "End"), tap("", "Delete")),
    },
  }),
})

-- Catch-all -------------------------------------------------------------------
-- Every ⌘ / ⇧⌘ + letter, punctuation or Return key that no other spec and no
-- Omarchy default claims sends Ctrl / Ctrl+Shift + the same key, so a Mac
-- shortcut that has no entry of its own still does what it does on the Mac.
-- Terminals consume them (apps/terminal.lua, D5). A key you rebind in
-- ~/.config/hypr/bindings.lua still wins, since that file loads later.

catchall({
  category = "Catch-all",
  covers = { "letter", "punctuation", "return" },
  variants = {
    { keys = "SUPER", sends = "CTRL", glyph = "⌘", text = "Ctrl+" },
    { keys = "SUPER + SHIFT", sends = "CTRL + SHIFT", glyph = "⌘⇧", text = "Ctrl+Shift+" },
  },
  -- Consumed everywhere: nothing is sent.
  consumed = {
    "SUPER + H", -- ⌘H, ⌘M: no hide or minimize on Omarchy (D13), and Ctrl+H /
    "SUPER + M", -- Ctrl+M are browser history and Enter in a terminal.
    "SUPER + SHIFT + Q", -- Ctrl+Shift+Q quits Chrome.
    "SUPER + SHIFT + I", -- Ctrl+Shift+I is Format Document in VS Code; DevTools has ⌥⌘I.
    "SUPER + SHIFT + U", -- Ctrl+Shift+U starts Unicode input in GTK and fcitx5.
    "SUPER + SHIFT + H", -- Ctrl+Shift+H is not Chrome's home page (user's choice).
  },
})
