-- Cursor movement, selection and deletion (PLAN.md §5).

local bind = require("hypr.omackey.lib.bind")
local mac, PASS, CONSUME = bind.mac, bind.PASS, bind.CONSUME
local send = require("hypr.omackey.lib.send")
local tap, seq = send.tap, send.seq

mac({
  id = "line-start",
  category = "Cursor",
  mac = "⌘←",
  keys = "SUPER + LEFT",
  desc = "Line start",
  repeating = true,
  actions = {
    default = tap("", "Home"), -- terminals too: readline/nvim treat Home as line start
  },
})

mac({
  id = "line-end",
  category = "Cursor",
  mac = "⌘→",
  keys = "SUPER + RIGHT",
  desc = "Line end",
  repeating = true,
  actions = {
    default = tap("", "End"), -- terminals too: readline/nvim treat End as line end
  },
})

mac({
  id = "select-line-start",
  category = "Cursor",
  mac = "⌘⇧←",
  keys = "SUPER + SHIFT + LEFT",
  desc = "Select to line start",
  repeating = true,
  actions = {
    default = tap("SHIFT", "Home"),
  },
})

mac({
  id = "select-line-end",
  category = "Cursor",
  mac = "⌘⇧→",
  keys = "SUPER + SHIFT + RIGHT",
  desc = "Select to line end",
  repeating = true,
  actions = {
    default = tap("SHIFT", "End"),
  },
})

mac({
  id = "word-left",
  category = "Cursor",
  mac = "⌥←",
  keys = "ALT + LEFT",
  desc = "Word left",
  repeating = true,
  actions = {
    default = tap("CTRL", "Left"), -- terminals too: /etc/inputrc maps Ctrl+Left to backward-word
  },
})

mac({
  id = "word-right",
  category = "Cursor",
  mac = "⌥→",
  keys = "ALT + RIGHT",
  desc = "Word right",
  repeating = true,
  actions = {
    default = tap("CTRL", "Right"), -- terminals too: /etc/inputrc maps Ctrl+Right to forward-word
  },
})

mac({
  id = "select-word-left",
  category = "Cursor",
  mac = "⌥⇧←",
  keys = "ALT + SHIFT + LEFT",
  desc = "Select word left",
  repeating = true,
  actions = {
    default = tap("CTRL + SHIFT", "Left"),
  },
})

mac({
  id = "select-word-right",
  category = "Cursor",
  mac = "⌥⇧→",
  keys = "ALT + SHIFT + RIGHT",
  desc = "Select word right",
  repeating = true,
  actions = {
    default = tap("CTRL + SHIFT", "Right"),
  },
})

mac({
  id = "document-start",
  category = "Cursor",
  mac = "⌘↑",
  keys = "SUPER + UP",
  desc = "Document start",
  repeating = true,
  actions = {
    default = tap("CTRL", "Home"),
  },
})

mac({
  id = "document-end",
  category = "Cursor",
  mac = "⌘↓",
  keys = "SUPER + DOWN",
  desc = "Document end",
  repeating = true,
  actions = {
    default = tap("CTRL", "End"),
  },
})

mac({
  id = "select-document-start",
  category = "Cursor",
  mac = "⌘⇧↑",
  keys = "SUPER + SHIFT + UP",
  desc = "Select to document start",
  repeating = true,
  actions = {
    default = tap("CTRL + SHIFT", "Home"),
  },
})

mac({
  id = "select-document-end",
  category = "Cursor",
  mac = "⌘⇧↓",
  keys = "SUPER + SHIFT + DOWN",
  desc = "Select to document end",
  repeating = true,
  actions = {
    default = tap("CTRL + SHIFT", "End"),
  },
})

mac({
  id = "delete-word-left",
  category = "Editing",
  mac = "⌥⌫",
  keys = "ALT + BACKSPACE",
  desc = "Delete word left",
  repeating = true,
  actions = {
    default = tap("CTRL", "BackSpace"),
  },
})

mac({
  id = "delete-word-right",
  category = "Editing",
  mac = "⌥⌦",
  keys = "ALT + DELETE",
  desc = "Delete word right",
  repeating = true,
  actions = {
    default = tap("CTRL", "Delete"),
  },
})

mac({
  id = "delete-line-start",
  category = "Editing",
  mac = "⌘⌫",
  keys = "SUPER + BACKSPACE",
  desc = "Delete to line start",
  repeating = true,
  actions = {
    default = seq(tap("SHIFT", "Home"), tap("", "BackSpace")),
  },
})

mac({
  id = "delete-line-end",
  category = "Editing",
  mac = "⌘⌦",
  keys = "SUPER + DELETE",
  desc = "Delete to line end",
  repeating = true,
  actions = {
    default = seq(tap("SHIFT", "End"), tap("", "Delete")),
  },
})
