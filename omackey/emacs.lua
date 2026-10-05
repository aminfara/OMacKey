-- Phase 7c: Emacs-style ⌃ keys for text fields (PLAN.md §5), as in every Mac text
-- field. Controlled by `emacs_keys` in config.lua: nothing is bound when it is false.
--
-- Terminals pass the raw key (readline already has all of these). VS Code gets
-- the translation like any GUI app, except ⌃D: its integrated terminal can't be
-- told from the editor (§9 F12), and a ⌃D that sent Delete would no longer end a
-- shell.

local config = require("hypr.omackey.config")

if not config.emacs_keys then
  return
end

local mac = require("hypr.omackey.lib.bind").mac
local send = require("hypr.omackey.lib.send")
local tap, seq = send.tap, send.seq

mac({
  id = "emacs-line-start",
  category = "Emacs",
  mac = "⌃A",
  keys = "CTRL + A",
  desc = "Line start (Emacs key)",
  repeating = true,
  actions = {
    default = tap("", "Home"),
    terminal = "pass",
  },
})

mac({
  id = "emacs-line-end",
  category = "Emacs",
  mac = "⌃E",
  keys = "CTRL + E",
  desc = "Line end (Emacs key)",
  repeating = true,
  actions = {
    default = tap("", "End"),
    terminal = "pass",
  },
})

mac({
  id = "emacs-char-right",
  category = "Emacs",
  mac = "⌃F",
  keys = "CTRL + F",
  desc = "Cursor right (Emacs key)",
  repeating = true,
  actions = {
    default = tap("", "Right"),
    terminal = "pass",
  },
})

mac({
  id = "emacs-char-left",
  category = "Emacs",
  mac = "⌃B",
  keys = "CTRL + B",
  desc = "Cursor left (Emacs key)",
  repeating = true,
  actions = {
    default = tap("", "Left"),
    terminal = "pass",
  },
})

mac({
  id = "emacs-line-down",
  category = "Emacs",
  mac = "⌃N",
  keys = "CTRL + N",
  desc = "Cursor down (Emacs key)",
  repeating = true,
  actions = {
    default = tap("", "Down"),
    terminal = "pass",
  },
})

mac({
  id = "emacs-line-up",
  category = "Emacs",
  mac = "⌃P",
  keys = "CTRL + P",
  desc = "Cursor up (Emacs key)",
  repeating = true,
  actions = {
    default = tap("", "Up"),
    terminal = "pass",
  },
})

mac({
  id = "emacs-delete-right",
  category = "Emacs",
  mac = "⌃D",
  keys = "CTRL + D",
  desc = "Delete right (Emacs key)",
  repeating = true,
  actions = {
    default = tap("", "Delete"),
    terminal = "pass",
    vscode = "pass", -- the integrated terminal needs the raw ⌃D (end of input)
  },
})

mac({
  id = "emacs-delete-left",
  category = "Emacs",
  mac = "⌃H",
  keys = "CTRL + H",
  desc = "Delete left (Emacs key)",
  repeating = true,
  actions = {
    default = tap("", "BackSpace"),
    terminal = "pass",
  },
})

mac({
  id = "emacs-kill-line",
  category = "Emacs",
  mac = "⌃K",
  keys = "CTRL + K",
  desc = "Delete to line end (Emacs key)",
  repeating = true,
  actions = {
    default = seq(tap("SHIFT", "End"), tap("", "Delete")),
    terminal = "pass",
  },
})
