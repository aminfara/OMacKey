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
