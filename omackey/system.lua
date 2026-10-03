-- Phase 5: OS controls, PLAN.md §5.

local action = require("hypr.omackey.lib.bind").action

action({
  id = "lock-screen",
  category = "System",
  mac = "⌃⌘Q",
  keys = "CTRL + SUPER + Q",
  desc = "Lock screen",
  dispatcher = hl.dsp.exec_cmd("omarchy-system-lock"),
})
