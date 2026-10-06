-- Omarchy default binds moved off keys that macOS needs, or dropped where
-- OMacKey's own bind replaces them (PLAN.md §6).
--
-- `from` is Omarchy's key as written in
-- /usr/share/omarchy/default/hypr/bindings/*.lua (matching ignores modifier
-- order and case, and a keycode matches its key name). Each row has either
-- `to`, the new key, where Omarchy's action, description and conditions are
-- kept as they are; or `drop = true`, and Omarchy's bind is not registered.
-- `optional = true` marks binds Omarchy only registers under a condition, so
-- their absence isn't reported as drift.

local relocations = {
  -- Dropped: OMacKey's ⌘C / ⌘V / ⌘X (editing.lua) replace Omarchy's universal
  -- copy, paste and cut, which send Ctrl+C / Ctrl+V to VS Code and break its
  -- integrated terminal, and Ctrl+X to terminals.
  { from = "SUPER + C", drop = true }, -- Universal copy
  { from = "SUPER + V", drop = true }, -- Universal paste
  { from = "SUPER + X", drop = true }, -- Universal cut

  -- Window management → ⌃⌥ (PLAN.md §6.1)
  { from = "SUPER + W", to = "CTRL + ALT + W" }, -- Close window (⌘W: close tab)
  { from = "SUPER + J", to = "CTRL + ALT + J" }, -- Toggle window split
  { from = "SUPER + P", to = "CTRL + ALT + P" }, -- Pseudo window
  { from = "SUPER + T", to = "CTRL + ALT + T" }, -- Toggle window floating/tiling
  { from = "SUPER + F", to = "CTRL + SUPER + F" }, -- Full screen (Mac ⌃⌘F)
  { from = "SUPER + CTRL + F", to = "CTRL + ALT + F" }, -- Tiled full screen
  { from = "SUPER + ALT + F", to = "CTRL + ALT + RETURN" }, -- Full width (Rectangle "maximize")
  { from = "SUPER + O", to = "CTRL + ALT + O" }, -- Pop window out
  { from = "SUPER + L", to = "CTRL + ALT + L" }, -- Toggle workspace layout

  -- Mouse: ⌘ + click and ⌘ + scroll become Ctrl + click / scroll in apps, so
  -- Omarchy's window mouse controls move to ⌃⌥ like its other window management.
  { from = "SUPER + mouse:272", to = "CTRL + ALT + mouse:272" }, -- Move window (drag)
  { from = "SUPER + mouse:273", to = "CTRL + ALT + mouse:273" }, -- Resize window (drag)
  { from = "SUPER + mouse_down", to = "CTRL + ALT + mouse_down" }, -- Scroll workspace forward
  { from = "SUPER + mouse_up", to = "CTRL + ALT + mouse_up" }, -- Scroll workspace backward
  { from = "SUPER + ALT + mouse_down", to = "CTRL + ALT + SUPER + mouse_down" }, -- Next window in group
  { from = "SUPER + ALT + mouse_up", to = "CTRL + ALT + SUPER + mouse_up" }, -- Previous window in group

  -- Arrows: ⌃ moves focus and ⌃⇧ takes the window along, within the
  -- workspace (the most frequent tiling actions get the cheapest chord);
  -- ⌃⌥ / ⌃⌥⇧ do the same one level up, between workspaces (§6.2, spaces.lua).
  { from = "SUPER + LEFT", to = "CTRL + LEFT" }, -- Focus window
  { from = "SUPER + RIGHT", to = "CTRL + RIGHT" },
  { from = "SUPER + UP", to = "CTRL + UP" },
  { from = "SUPER + DOWN", to = "CTRL + DOWN" },

  { from = "SUPER + SHIFT + LEFT", to = "CTRL + SHIFT + LEFT" }, -- Swap window
  { from = "SUPER + SHIFT + RIGHT", to = "CTRL + SHIFT + RIGHT" },
  { from = "SUPER + SHIFT + UP", to = "CTRL + SHIFT + UP" },
  { from = "SUPER + SHIFT + DOWN", to = "CTRL + SHIFT + DOWN" },

  { from = "SUPER + ALT + LEFT", to = "CTRL + ALT + SUPER + LEFT" }, -- Move window into group
  { from = "SUPER + ALT + RIGHT", to = "CTRL + ALT + SUPER + RIGHT" },
  { from = "SUPER + ALT + UP", to = "CTRL + ALT + SUPER + UP" },
  { from = "SUPER + ALT + DOWN", to = "CTRL + ALT + SUPER + DOWN" },

  { from = "SUPER + SHIFT + ALT + LEFT", to = "CTRL + ALT + SUPER + SHIFT + LEFT" }, -- Move workspace to monitor
  { from = "SUPER + SHIFT + ALT + RIGHT", to = "CTRL + ALT + SUPER + SHIFT + RIGHT" },
  { from = "SUPER + SHIFT + ALT + UP", to = "CTRL + ALT + SUPER + SHIFT + UP" },
  { from = "SUPER + SHIFT + ALT + DOWN", to = "CTRL + ALT + SUPER + SHIFT + DOWN" },

  { from = "SUPER + G", to = "CTRL + ALT + G" }, -- Toggle window grouping
  { from = "SUPER + ALT + G", to = "CTRL + ALT + SHIFT + G" }, -- Move active window out of group
  { from = "SUPER + S", to = "CTRL + ALT + S" }, -- Toggle scratchpad
  { from = "SUPER + ALT + S", to = "CTRL + ALT + SHIFT + S" }, -- Move window to scratchpad

  -- Resize (code:20 = minus, code:21 = equal). ⌘-/⌘= are app zoom on a Mac.
  -- The ±25 px "a little" variants on SUPER + ALT stay: nothing Mac uses ⌘⌥-/=.
  { from = "SUPER + code:20", to = "CTRL + ALT + code:20" }, -- ±100 px horizontal
  { from = "SUPER + code:21", to = "CTRL + ALT + code:21" },
  { from = "SUPER + SHIFT + code:20", to = "CTRL + ALT + SHIFT + code:20" }, -- ±100 px vertical
  { from = "SUPER + SHIFT + code:21", to = "CTRL + ALT + SHIFT + code:21" },
  { from = "SUPER + CTRL + code:20", to = "CTRL + ALT + SUPER + code:20" }, -- ±300 px horizontal
  { from = "SUPER + CTRL + code:21", to = "CTRL + ALT + SUPER + code:21" },
  { from = "SUPER + CTRL + SHIFT + code:20", to = "CTRL + ALT + SUPER + SHIFT + code:20" }, -- ±300 px vertical
  { from = "SUPER + CTRL + SHIFT + code:21", to = "CTRL + ALT + SUPER + SHIFT + code:21" },

  { from = "SUPER + SLASH", to = "CTRL + ALT + SLASH" }, -- Monitor scaling up (⌘/: comment)
  { from = "SUPER + ALT + SLASH", to = "CTRL + ALT + SHIFT + SLASH" }, -- Monitor scaling down
  { from = "SUPER + BACKSPACE", to = "CTRL + ALT + BACKSPACE" }, -- Toggle window transparency (⌘⌫)
  { from = "SUPER + SHIFT + BACKSPACE", to = "CTRL + ALT + SHIFT + BACKSPACE" }, -- Toggle window gaps
  { from = "SUPER + ALT + code:34", to = "CTRL + ALT + code:34" }, -- Webcam overlay smaller (⌘⌥[: fold)
  { from = "SUPER + ALT + code:35", to = "CTRL + ALT + code:35" }, -- Webcam overlay larger

  -- Spaces (§6.2): numbers on ⌃ like macOS, arrows on ⌃⌥.
  -- spaces.lua adds ⌃⌥↑/↓ and the ⌃⌥⇧ arrows.
  { from = "SUPER + TAB", to = "CTRL + ALT + RIGHT" }, -- Next workspace (⌘Tab: switch window)
  { from = "SUPER + SHIFT + TAB", to = "CTRL + ALT + LEFT" }, -- Previous workspace

  -- §6.3 Launchers → ⌃⌥⌘ + Omarchy's letter, ⌃⌥⌘⇧ for the SUPER+SHIFT+ALT
  -- variants. Frees ⌘⏎ and ⌘⇧ + letters for apps.
  { from = "SUPER + RETURN", to = "CTRL + ALT + SUPER + RETURN" }, -- Terminal
  { from = "SUPER + SHIFT + RETURN", to = "CTRL + ALT + SUPER + SHIFT + RETURN" }, -- Browser
  { from = "SUPER + SHIFT + F", to = "CTRL + ALT + SUPER + F" }, -- File manager
  { from = "SUPER + ALT + SHIFT + F", to = "CTRL + ALT + SUPER + SHIFT + F" }, -- File manager (cwd)
  { from = "SUPER + SHIFT + B", to = "CTRL + ALT + SUPER + B" }, -- Browser
  { from = "SUPER + SHIFT + ALT + B", to = "CTRL + ALT + SUPER + SHIFT + B" }, -- Browser (private)
  { from = "SUPER + SHIFT + N", to = "CTRL + ALT + SUPER + N" }, -- Editor

  -- Preinstalled apps and web apps (only when omarchy_preinstalled_bindings is on).
  { from = "SUPER + SHIFT + M", to = "CTRL + ALT + SUPER + M", optional = true }, -- Music
  { from = "SUPER + SHIFT + ALT + M", to = "CTRL + ALT + SUPER + SHIFT + M", optional = true }, -- Music TUI
  { from = "SUPER + SHIFT + D", to = "CTRL + ALT + SUPER + D", optional = true }, -- Docker
  { from = "SUPER + SHIFT + G", to = "CTRL + ALT + SUPER + G", optional = true }, -- Signal
  { from = "SUPER + SHIFT + ALT + G", to = "CTRL + ALT + SUPER + SHIFT + G", optional = true }, -- WhatsApp
  { from = "SUPER + SHIFT + O", to = "CTRL + ALT + SUPER + O", optional = true }, -- Obsidian
  { from = "SUPER + SHIFT + W", to = "CTRL + ALT + SUPER + W", optional = true }, -- Omawrite
  { from = "SUPER + SHIFT + SLASH", to = "CTRL + ALT + SUPER + SLASH", optional = true }, -- Passwords (frees ⌘?)
  { from = "SUPER + SHIFT + A", to = "CTRL + ALT + SUPER + A", optional = true }, -- ChatGPT
  { from = "SUPER + SHIFT + ALT + A", to = "CTRL + ALT + SUPER + SHIFT + A", optional = true }, -- Grok
  { from = "SUPER + SHIFT + C", to = "CTRL + ALT + SUPER + C", optional = true }, -- Calendar
  { from = "SUPER + SHIFT + E", to = "CTRL + ALT + SUPER + E", optional = true }, -- Email
  { from = "SUPER + SHIFT + ALT + E", to = "CTRL + ALT + SUPER + SHIFT + E", optional = true }, -- New email
  { from = "SUPER + SHIFT + Y", to = "CTRL + ALT + SUPER + Y", optional = true }, -- YouTube
  { from = "SUPER + SHIFT + P", to = "CTRL + ALT + SUPER + P", optional = true }, -- Google Photos
  { from = "SUPER + SHIFT + S", to = "CTRL + ALT + SUPER + S", optional = true }, -- Google Maps
  { from = "SUPER + SHIFT + X", to = "CTRL + ALT + SUPER + X", optional = true }, -- X
  { from = "SUPER + SHIFT + ALT + X", to = "CTRL + ALT + SUPER + SHIFT + X", optional = true }, -- X Post

  -- Omarchy info popups → ⌃⌘⇧ T/B/W/D. B, W and D collide with launcher
  -- letters; time moves with them to keep the group together. ⌃⌥⌘R/Z/Delete
  -- stay next to their ⌃⌘ siblings (show reminders, reset zoom, mirroring).
  { from = "SUPER + CTRL + ALT + T", to = "CTRL + SUPER + SHIFT + T" }, -- Show time
  { from = "SUPER + CTRL + ALT + B", to = "CTRL + SUPER + SHIFT + B" }, -- Show battery remaining
  { from = "SUPER + CTRL + ALT + W", to = "CTRL + SUPER + SHIFT + W" }, -- Toggle weather
  { from = "SUPER + CTRL + ALT + D", to = "CTRL + SUPER + SHIFT + D" }, -- Calendar panel

  -- Utilities & help (§6.4).
  { from = "SUPER + K", to = "SUPER + SHIFT + SLASH" }, -- Keybindings → ⌘? (Mac Help); ⌘K is for apps
  -- Next to ⌘⇧, (dismiss all) and the ⌃⌘⇧ info popups; ⌘, is preferences.
  -- xkbcommon names the keysym "comma"; upper-case "COMMA" does not match.
  { from = "SUPER + comma", to = "CTRL + SUPER + SHIFT + comma" }, -- Dismiss last notification
  { from = "SUPER + CTRL + Q", to = "CTRL + ALT + SUPER + Q" }, -- Calculator (⌃⌘Q: lock screen)
  { from = "SUPER + CTRL + SPACE", to = "CTRL + ALT + SUPER + SPACE" }, -- Background switcher (⌃⌘Space: emoji)
}

-- Workspaces 1–10 (Omarchy binds digits by keycode: code:10 = 1 … code:19 = 0).
-- ⌘1–9 switch tabs and ⌘⇧3/4/5 take screenshots on a Mac.
for code = 10, 19 do
  local key = "code:" .. code
  table.insert(relocations, { from = "SUPER + " .. key, to = "CTRL + " .. key }) -- Switch to workspace
  table.insert(relocations, { from = "SUPER + SHIFT + " .. key, to = "CTRL + SHIFT + " .. key }) -- Move window
  table.insert(relocations, { from = "SUPER + SHIFT + ALT + " .. key, to = "CTRL + ALT + SHIFT + " .. key }) -- … silently
end

return relocations
