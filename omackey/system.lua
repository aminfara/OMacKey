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

-- Screenshots: Omarchy's capture CLI. `save` writes a file, `copy` only fills
-- the clipboard; ⌘⇧3 / ⌃⌘⇧3 are code:12 (digits are bound by keycode).
action({
  id = "screenshot-screen-file",
  category = "System",
  mac = "⌘⇧3",
  keys = "SUPER + SHIFT + code:12",
  desc = "Screenshot of the screen to file",
  dispatcher = hl.dsp.exec_cmd("omarchy-capture-screenshot fullscreen save"),
})

action({
  id = "screenshot-screen-clipboard",
  category = "System",
  mac = "⌃⌘⇧3",
  keys = "SUPER + CTRL + SHIFT + code:12",
  desc = "Screenshot of the screen to clipboard",
  dispatcher = hl.dsp.exec_cmd("omarchy-capture-screenshot fullscreen copy"),
})
