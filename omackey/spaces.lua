-- Phase 1b: workspaces (Mac "Spaces"), PLAN.md §6.2.
--
-- Arrow rule: ⌃ moves focus between windows and ⌃⇧ takes the window along
-- (relocations.lua); ⌥ steps up a level to workspaces, so ⌃⌥ switches
-- workspace and ⌃⌥⇧ takes the window to it. Numbers can only mean
-- workspaces, so they stay on ⌃ like macOS: ⌃1–0, ⌃⇧1–0, ⌃⌥⇧1–0 (silent).
--
-- relocations.lua moves Omarchy's SUPER+TAB pair to ⌃⌥→/←. This adds the
-- vertical pair (in scrolling, workspaces sit above and below the columns)
-- and moving the active window. "Previous" and "next" step through existing
-- workspaces, like Omarchy's SUPER+TAB did.

local action = require("hypr.omackey.lib.bind").action

action({
  id = "workspace-previous-up",
  category = "Spaces",
  mac = "⌃⌥↑",
  keys = "CTRL + ALT + UP",
  desc = "Previous workspace",
  dispatcher = hl.dsp.focus({ workspace = "e-1" }),
})

action({
  id = "workspace-next-down",
  category = "Spaces",
  mac = "⌃⌥↓",
  keys = "CTRL + ALT + DOWN",
  desc = "Next workspace",
  dispatcher = hl.dsp.focus({ workspace = "e+1" }),
})

for _, arrow in ipairs({ { "LEFT", "⌃⌥⇧←" }, { "UP", "⌃⌥⇧↑" } }) do
  action({
    id = "window-to-previous-workspace-" .. arrow[1]:lower(),
    category = "Spaces",
    mac = arrow[2],
    keys = "CTRL + ALT + SHIFT + " .. arrow[1],
    desc = "Move window to previous workspace",
    dispatcher = hl.dsp.window.move({ workspace = "e-1" }),
  })
end

for _, arrow in ipairs({ { "RIGHT", "⌃⌥⇧→" }, { "DOWN", "⌃⌥⇧↓" } }) do
  action({
    id = "window-to-next-workspace-" .. arrow[1]:lower(),
    category = "Spaces",
    mac = arrow[2],
    keys = "CTRL + ALT + SHIFT + " .. arrow[1],
    desc = "Move window to next workspace",
    dispatcher = hl.dsp.window.move({ workspace = "e+1" }),
  })
end
