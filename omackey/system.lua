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

-- Region capture uses Omarchy's picker: Return captures the window under the
-- cursor, which is close to the Mac's Space.
action({
  id = "screenshot-region-file",
  category = "System",
  mac = "⌘⇧4",
  keys = "SUPER + SHIFT + code:13",
  desc = "Screenshot of a region to file",
  dispatcher = hl.dsp.exec_cmd("omarchy-capture-screenshot region save"),
})

action({
  id = "screenshot-region-clipboard",
  category = "System",
  mac = "⌃⌘⇧4",
  keys = "SUPER + CTRL + SHIFT + code:13",
  desc = "Screenshot of a region to clipboard",
  dispatcher = hl.dsp.exec_cmd("omarchy-capture-screenshot region copy"),
})

-- Capture menu: Omarchy's, which also covers screen recording.
action({
  id = "capture-menu",
  category = "System",
  mac = "⌘⇧5",
  keys = "SUPER + SHIFT + code:14",
  desc = "Capture menu",
  dispatcher = hl.dsp.exec_cmd("omarchy-menu toggle capture"),
})

-- Force quit: the Mac asks which app in a dialog; here the active window's
-- process is killed (SIGKILL) at once, with no confirmation.
action({
  id = "force-quit",
  category = "System",
  mac = "⌘⌥Esc",
  keys = "SUPER + ALT + ESCAPE",
  desc = "Force quit the active window",
  dispatcher = hl.dsp.window.kill(),
})
