-- Terminals: every window with Omarchy's `terminal` tag. Ghostty, kitty and
-- foot add their own entries on top (apps/ghostty.lua …); this covers the rest
-- (Alacritty, wezterm, Omarchy's TUI windows) and whatever those leave out.
--
-- A terminal has no ⌘ chords of its own, and most Ctrl chords mean something
-- else there (readline, job control, flow control), so a Mac shortcut either
-- gets the terminal's own equivalent (⌘←/→ Home/End, ⌥←/→ Ctrl+←/→, ⌘=/-/0
-- Ctrl+=/-/0) or is consumed (D5). Every catch-all key is consumed.

local bind = require("hypr.omackey.lib.bind")
local app = require("hypr.omackey.lib.profiles").app
local tap = require("hypr.omackey.lib.send").tap
local windows = require("hypr.omackey.lib.windows")
local PASS, CONSUME = bind.PASS, bind.CONSUME

local actions = {
  -- Text navigation and deletion
  ["select-line-start"] = CONSUME,
  ["select-line-end"] = CONSUME,
  ["select-word-left"] = CONSUME,
  ["select-word-right"] = CONSUME,
  -- ⌘↑ / ⌘↓: scrollback up / down a page (Ghostty and kitty have their own).
  ["document-start"] = tap("SHIFT", "Page_Up"),
  ["document-end"] = tap("SHIFT", "Page_Down"),
  ["select-document-start"] = CONSUME,
  ["select-document-end"] = CONSUME,
  ["delete-word-left"] = PASS, -- readline: Alt+BackSpace is backward-kill-word
  ["delete-word-right"] = tap("ALT", "d"), -- readline kill-word
  ["delete-line-start"] = tap("CTRL", "u"), -- readline unix-line-discard
  ["delete-line-end"] = tap("CTRL", "k"), -- readline kill-line
  -- Editing
  ["copy"] = tap("CTRL", "Insert"), -- Ctrl+C is SIGINT in a terminal
  ["paste"] = tap("SHIFT", "Insert"), -- Ctrl+V is a literal-next in a terminal
  ["cut"] = CONSUME, -- Ctrl+X is a readline prefix; a terminal has nothing to cut
  ["paste-plain"] = tap("SHIFT", "Insert"), -- terminals paste plain text already
  ["undo"] = CONSUME, -- Ctrl+Z would suspend the foreground job
  ["redo"] = CONSUME,
  ["select-all"] = CONSUME, -- Ctrl+A is readline's line start
  ["save"] = CONSUME, -- Ctrl+S freezes terminal output (XOFF)
  ["save-as"] = CONSUME,
  ["find"] = CONSUME, -- Ctrl+F is readline's forward-char
  ["find-next"] = CONSUME,
  ["find-previous"] = CONSUME,
  ["bold"] = CONSUME, -- Ctrl+B is readline's backward-char (and tmux's prefix)
  ["italic"] = CONSUME, -- Ctrl+I is Tab
  ["underline"] = CONSUME, -- Ctrl+U deletes the line (⌘⌫ owns that)
  ["toggle-comment"] = CONSUME,
  ["cancel"] = tap("CTRL", "C"), -- interrupt, like Terminal.app
  -- Windows and tabs
  -- foot, Alacritty and Omarchy's TUIs have no tabs, so close the window.
  -- Ctrl+W is readline's word delete.
  ["close-tab"] = bind.does("Close the window", windows.close),
  -- foot, Ghostty, kitty and Alacritty open a new window on Ctrl+Shift+N.
  ["new-window"] = tap("CTRL + SHIFT", "N"),
  ["new-window-private"] = CONSUME,
  ["new-tab"] = tap("CTRL + SHIFT", "N"), -- no tabs: a new window
  ["reopen-tab"] = CONSUME,
  -- Ctrl+O/P/R/L are readline keys (history, reverse search, clear screen),
  -- and terminals have nothing matching ⌘O/⌘P/⌘R/⌘L.
  ["open"] = CONSUME,
  ["print"] = CONSUME,
  ["reload"] = CONSUME,
  ["location"] = CONSUME,
  ["back"] = CONSUME, -- Ctrl+[ is Escape
  ["forward"] = CONSUME,
  ["previous-tab"] = CONSUME,
  ["next-tab"] = CONSUME,
  ["previous-tab-arrow"] = CONSUME,
  ["next-tab-arrow"] = CONSUME,
  ["preferences"] = CONSUME, -- the config file; Ghostty and kitty open theirs
  -- Terminal
  ["clear-screen"] = tap("CTRL", "L"),
  ["split-right"] = CONSUME,
  ["split-down"] = CONSUME,
  -- Browser
  ["devtools"] = CONSUME,
  ["history"] = CONSUME,
  ["downloads"] = CONSUME,
  -- Code editing
  ["zoom-out-shifted"] = CONSUME,
  -- Files
  ["show-hidden-files"] = CONSUME,
  -- Obsidian
  ["redo-selection"] = CONSUME,
  -- Emacs keys: readline already has them
  ["emacs-line-start"] = PASS,
  ["emacs-line-end"] = PASS,
  ["emacs-char-right"] = PASS,
  ["emacs-char-left"] = PASS,
  ["emacs-line-down"] = PASS,
  ["emacs-line-up"] = PASS,
  ["emacs-delete-right"] = PASS,
  ["emacs-delete-left"] = PASS,
  ["emacs-kill-line"] = PASS,
}

-- ⌘1–⌘9: no tabs.
for n = 1, 9 do
  actions["tab-" .. n] = CONSUME
end

app({
  name = "terminal",
  tags = { "terminal" },
  catchall = CONSUME,
  actions = actions,
})
