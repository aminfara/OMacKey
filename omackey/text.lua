-- Phase 2: cursor movement, selection and deletion (PLAN.md §5).

local mac = require("hypr.omackey.lib.bind").mac
local tap = require("hypr.omackey.lib.send").tap

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
    terminal = "consume",
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
    terminal = "consume",
  },
})
