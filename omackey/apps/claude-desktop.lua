-- Claude Desktop (Electron, class com.anthropic.Claude). Its Code tab has a
-- terminal pane (xterm.js over a node-pty shell) in the same window as the chat
-- and the editor panes, so, as with VS Code (F12), Hyprland can't tell which
-- one has focus. Read from the installed app (ion-dist.asar), docs/FINDINGS.md
-- F27: on Linux its own shortcuts are the Ctrl chords of its "cmd+" table, so
-- the generic ⌘ → Ctrl keys already hit them; the terminal pane's key handler
-- sends every other Ctrl chord to the shell.
--
-- That makes ⌘C and ⌘V the keys that break: Ctrl+C is SIGINT and Ctrl+V a
-- literal-next in the shell. Ctrl+Insert / Shift+Insert are the browser engine's
-- own copy / paste (xterm.js leaves both to it), so they work in the chat, the
-- prompt box and the terminal alike.

local app = require("hypr.omackey.lib.profiles").app
local bind = require("hypr.omackey.lib.bind")
local PASS = bind.PASS
local tap = require("hypr.omackey.lib.send").tap

app({
  name = "claude-desktop",
  classes = { "com.anthropic.Claude" },
  actions = {
    -- Editing
    ["copy"] = tap("CTRL", "Insert"),
    ["paste"] = tap("SHIFT", "Insert"),
    -- Emacs keys
    -- ⌃D stays raw: the terminal pane needs it (end of input).
    ["emacs-delete-right"] = PASS,
  },
})
