-- ⌘ + click and ⌘ + scroll reach apps as Ctrl + click and Ctrl + scroll
-- (⌘-click: new tab, multi-select, go to definition; ⌘ + scroll: zoom), PLAN.md
-- §5. Omarchy's own ⌘ + mouse binds are on ⌃⌥ (relocations.lua).
--
-- Click: the real ⌘ + press and its release are consumed, and the same button
-- events are sent again with explicit Ctrl in `mods` (a synthetic event carries
-- the modifiers it is given, so the app sees Ctrl and not ⌘). A drag works because
-- the press and the release stay apart. If ⌘ is let go before the button, the real
-- release passes through on its own and closes the synthetic press.
--
-- Scroll: a wheel tick can't be re-sent, so it needs a real Ctrl instead:
-- lib/ctrl_hold.lua holds one through `wtype`, and nothing is bound without it.

local mac = require("hypr.omackey.lib.bind").mac
local click = require("hypr.omackey.lib.click")

-- ⌘-click and ⌘⇧-click (Ctrl+Shift-click extends a selection in file managers).
mac({
  id = "click",
  category = "Mouse",
  mac = "⌘-click",
  keys = "SUPER + mouse:272",
  desc = "⌘-click sent as Ctrl-click",
  actions = { default = click.press("CTRL") },
})

mac({
  id = "click-shift",
  category = "Mouse",
  mac = "⌘⇧-click",
  keys = "SUPER + SHIFT + mouse:272",
  desc = "⌘⇧-click sent as Ctrl+Shift-click",
  actions = { default = click.press("CTRL + SHIFT") },
})

-- The release can come with any modifiers still held. These close a pending
-- synthetic press and let every other release through (lib/click.lua).
mac({
  id = "click-release",
  category = "Mouse",
  mac = "⌘-click release",
  keys = "SUPER + mouse:272",
  desc = "⌘-click release",
  release = true,
  actions = { default = click.release },
})

mac({
  id = "click-release-shift",
  category = "Mouse",
  mac = "⌘⇧-click release",
  keys = "SUPER + SHIFT + mouse:272",
  desc = "⌘⇧-click release",
  release = true,
  actions = { default = click.release },
})

mac({
  id = "click-release-after-cmd",
  category = "Mouse",
  mac = "click release after ⌘",
  keys = "mouse:272",
  desc = "Click release after ⌘ was let go",
  release = true,
  actions = { default = click.release },
})

mac({
  id = "click-release-after-cmd-shift",
  category = "Mouse",
  mac = "click release after ⌘ with ⇧",
  keys = "SHIFT + mouse:272",
  desc = "Click release after ⌘ was let go (⇧ held)",
  release = true,
  actions = { default = click.release },
})

if not o.cmd_present("wtype") then
  return
end

local ctrl_hold = require("hypr.omackey.lib.ctrl_hold")

mac({
  id = "scroll-up",
  category = "Mouse",
  mac = "⌘-scroll up",
  keys = "SUPER + mouse_up",
  desc = "⌘-scroll up sent as Ctrl-scroll",
  actions = { default = ctrl_hold.tick },
})

mac({
  id = "scroll-down",
  category = "Mouse",
  mac = "⌘-scroll down",
  keys = "SUPER + mouse_down",
  desc = "⌘-scroll down sent as Ctrl-scroll",
  actions = { default = ctrl_hold.tick },
})
