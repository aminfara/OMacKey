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

-- Emoji & symbols: Omarchy's picker (it also stays on ⌃⌘E).
action({
  id = "emoji-picker",
  category = "System",
  mac = "⌃⌘Space",
  keys = "SUPER + CTRL + SPACE",
  desc = "Emoji and symbols",
  dispatcher = hl.dsp.exec_cmd("omarchy-shell shell toggle omarchy.emojis"),
})

-- Show/hide the Dock: Omarchy's top bar (it also stays on ⌘⇧Space).
action({
  id = "toggle-bar",
  category = "System",
  mac = "⌥⌘D",
  keys = "SUPER + ALT + D",
  desc = "Toggle top bar (Dock)",
  dispatcher = hl.dsp.exec_cmd("omarchy-toggle-bar"),
})

-- Mac F-row keys that Omarchy leaves unbound. The keysyms are what the NuPhy
-- sends in Mac mode (PLAN §9 F9). The rest of the row (brightness, media,
-- volume) already works through Omarchy's XF86 binds.

-- F6: Do Not Disturb.
action({
  id = "do-not-disturb",
  category = "System",
  mac = "F6",
  keys = "XF86DoNotDisturb",
  desc = "Toggle silencing notifications (Do Not Disturb)",
  dispatcher = hl.dsp.exec_cmd("omarchy-toggle-notification-silencing"),
})

-- F5: Dictation, push-to-talk like Omarchy's F9 (record while held), and
-- ⇧F5 toggles. Same condition as Omarchy's own voxtype binds.
if o.cmd_present("voxtype") then
  action({
    id = "dictation-start",
    category = "System",
    mac = "F5",
    keys = "XF86VoiceCommand",
    desc = "Start dictation (push-to-talk)",
    dispatcher = hl.dsp.exec_cmd("voxtype record start"),
  })

  action({
    id = "dictation-stop",
    category = "System",
    mac = "F5 (release)",
    keys = "XF86VoiceCommand",
    desc = "Stop dictation (push-to-talk)",
    dispatcher = hl.dsp.exec_cmd("voxtype record stop"),
    release = true,
  })

  action({
    id = "dictation-toggle",
    category = "System",
    mac = "⇧F5",
    keys = "SHIFT + XF86VoiceCommand",
    desc = "Toggle dictation",
    dispatcher = hl.dsp.exec_cmd("voxtype record toggle"),
  })
end
