-- OS controls, PLAN.md §5.

local mac = require("hypr.omackey.lib.bind").mac

mac({
  id = "lock-screen",
  category = "System",
  mac = "⌃⌘Q",
  keys = "CTRL + SUPER + Q",
  desc = "Lock screen",
  action = hl.dsp.exec_cmd("omarchy-system-lock"),
})

-- Screenshots: Omarchy's capture CLI. `save` writes a file, `copy` only fills
-- the clipboard; ⌘⇧3 / ⌃⌘⇧3 are code:12 (digits are bound by keycode).
mac({
  id = "screenshot-screen-file",
  category = "System",
  mac = "⌘⇧3",
  keys = "SUPER + SHIFT + code:12",
  desc = "Screenshot of the screen to file",
  action = hl.dsp.exec_cmd("omarchy-capture-screenshot fullscreen save"),
})

mac({
  id = "screenshot-screen-clipboard",
  category = "System",
  mac = "⌃⌘⇧3",
  keys = "SUPER + CTRL + SHIFT + code:12",
  desc = "Screenshot of the screen to clipboard",
  action = hl.dsp.exec_cmd("omarchy-capture-screenshot fullscreen copy"),
})

-- Region capture uses Omarchy's picker: Return captures the window under the
-- cursor, which is close to the Mac's Space.
mac({
  id = "screenshot-region-file",
  category = "System",
  mac = "⌘⇧4",
  keys = "SUPER + SHIFT + code:13",
  desc = "Screenshot of a region to file",
  action = hl.dsp.exec_cmd("omarchy-capture-screenshot region save"),
})

mac({
  id = "screenshot-region-clipboard",
  category = "System",
  mac = "⌃⌘⇧4",
  keys = "SUPER + CTRL + SHIFT + code:13",
  desc = "Screenshot of a region to clipboard",
  action = hl.dsp.exec_cmd("omarchy-capture-screenshot region copy"),
})

-- Capture menu: Omarchy's, which also covers screen recording.
mac({
  id = "capture-menu",
  category = "System",
  mac = "⌘⇧5",
  keys = "SUPER + SHIFT + code:14",
  desc = "Capture menu",
  action = hl.dsp.exec_cmd("omarchy-menu toggle capture"),
})

-- Force quit: the Mac asks which app in a dialog; here the active window's
-- process is killed (SIGKILL) at once, with no confirmation.
mac({
  id = "force-quit",
  category = "System",
  mac = "⌘⌥Esc",
  keys = "SUPER + ALT + ESCAPE",
  desc = "Force quit the active window",
  action = hl.dsp.window.kill(),
})

-- Emoji & symbols: Omarchy's picker (it also stays on ⌃⌘E).
mac({
  id = "emoji-picker",
  category = "System",
  mac = "⌃⌘Space",
  keys = "SUPER + CTRL + SPACE",
  desc = "Emoji and symbols",
  action = hl.dsp.exec_cmd("omarchy-shell shell toggle omarchy.emojis"),
})

-- Show/hide the Dock: Omarchy's top bar (it also stays on ⌘⇧Space).
mac({
  id = "toggle-bar",
  category = "System",
  mac = "⌥⌘D",
  keys = "SUPER + ALT + D",
  desc = "Toggle top bar (Dock)",
  action = hl.dsp.exec_cmd("omarchy-toggle-bar"),
})

-- Mac F-row keys that Omarchy leaves unbound. The keysyms are what the NuPhy
-- sends in Mac mode (PLAN §9 F9). The rest of the row (brightness, media,
-- volume) already works through Omarchy's XF86 binds.

-- F6: Do Not Disturb.
mac({
  id = "do-not-disturb",
  category = "System",
  mac = "F6",
  keys = "XF86DoNotDisturb",
  desc = "Toggle silencing notifications (Do Not Disturb)",
  action = hl.dsp.exec_cmd("omarchy-toggle-notification-silencing"),
})

-- F5: Dictation, push-to-talk like Omarchy's F9 (record while held), and
-- ⇧F5 toggles. Bound only with voxtype installed, like Omarchy's own
-- voxtype binds.
mac({
  id = "dictation-start",
  category = "System",
  mac = "F5",
  keys = "XF86VoiceCommand",
  desc = "Start dictation (push-to-talk)",
  requires = "voxtype",
  action = hl.dsp.exec_cmd("voxtype record start"),
})

mac({
  id = "dictation-stop",
  category = "System",
  mac = "F5 (release)",
  keys = "XF86VoiceCommand",
  desc = "Stop dictation (push-to-talk)",
  requires = "voxtype",
  action = hl.dsp.exec_cmd("voxtype record stop"),
  release = true,
})

mac({
  id = "dictation-toggle",
  category = "System",
  mac = "⇧F5",
  keys = "SHIFT + XF86VoiceCommand",
  desc = "Toggle dictation",
  requires = "voxtype",
  action = hl.dsp.exec_cmd("voxtype record toggle"),
})
