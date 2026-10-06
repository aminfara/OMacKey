-- Terminals: every window with Omarchy's `terminal` tag. Ghostty, kitty and
-- foot add their own entries on top (apps/ghostty.lua …); this covers the rest
-- (Alacritty, wezterm, Omarchy's TUI windows) and whatever those leave out.
--
-- A terminal has no ⌘ chords of its own, and most Ctrl chords mean something
-- else there (readline, job control, flow control), so a Mac shortcut either
-- gets the terminal's own equivalent or is consumed (D5). That includes every
-- catch-all key.

local bind = require("hypr.omackey.lib.bind")
local app = require("hypr.omackey.lib.profiles").app
local tap = require("hypr.omackey.lib.send").tap
local windows = require("hypr.omackey.lib.windows")
local PASS, CONSUME = bind.PASS, bind.CONSUME

local actions = {
  -- text.lua
  ["select-line-start"] = CONSUME,
  ["select-line-end"] = CONSUME,
  ["select-word-left"] = CONSUME,
  ["select-word-right"] = CONSUME,
  -- Scrollback up a page. Ghostty does what Terminal.app does and jumps to
  -- the previous prompt; kitty's page-scroll key carries Ctrl (§9 F10).
  ["document-start"] = tap("SHIFT", "Page_Up"),
  ["document-end"] = tap("SHIFT", "Page_Down"),
  ["select-document-start"] = CONSUME,
  ["select-document-end"] = CONSUME,
  ["delete-word-left"] = PASS, -- readline: Alt+BackSpace is backward-kill-word
  ["delete-word-right"] = tap("ALT", "d"), -- readline kill-word
  ["delete-line-start"] = tap("CTRL", "u"), -- readline unix-line-discard
  ["delete-line-end"] = tap("CTRL", "k"), -- readline kill-line
  -- editing.lua
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
  ["cancel"] = tap("CTRL", "C"),
  -- windows.lua
  -- foot, Alacritty and Omarchy's TUIs have no tabs, so close the window.
  -- Ctrl+W is readline's word delete.
  ["close-tab"] = windows.close,
  ["new-window"] = tap("CTRL + SHIFT", "N"),
  ["new-window-private"] = CONSUME,
  ["new-tab"] = tap("CTRL + SHIFT", "N"), -- no tabs: a new window
  ["reopen-tab"] = CONSUME,
  ["open"] = CONSUME,
  ["print"] = CONSUME,
  ["reload"] = CONSUME,
  ["location"] = CONSUME,
  ["back"] = CONSUME,
  ["forward"] = CONSUME,
  ["previous-tab"] = CONSUME,
  ["next-tab"] = CONSUME,
  ["previous-tab-arrow"] = CONSUME,
  ["next-tab-arrow"] = CONSUME,
  ["preferences"] = CONSUME,
  -- terminals.lua
  ["clear-screen"] = tap("CTRL", "L"),
  ["split-right"] = CONSUME,
  ["split-down"] = CONSUME,
  -- browsers.lua
  ["devtools"] = CONSUME,
  ["history"] = CONSUME,
  ["downloads"] = CONSUME,
  -- vscode.lua
  ["zoom-out-shifted"] = CONSUME,
  -- nautilus.lua
  ["show-hidden-files"] = CONSUME,
  -- obsidian.lua
  ["redo-selection"] = CONSUME,
  -- emacs.lua
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
