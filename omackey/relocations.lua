-- Omarchy default binds moved off keys that macOS needs (PLAN.md §6).
--
-- `from` is Omarchy's key as written in
-- /usr/share/omarchy/default/hypr/bindings/*.lua (matching ignores modifier
-- order and case); `to` is the new key. Omarchy's action, description and
-- conditions are kept as they are.

local relocations = {
  -- §6.1 Window management → ⌃⌥ (Phase 1a)
  { from = "SUPER + W", to = "CTRL + ALT + W" }, -- Close window (⌘W: close tab)
  { from = "SUPER + J", to = "CTRL + ALT + J" }, -- Toggle window split
  { from = "SUPER + P", to = "CTRL + ALT + P" }, -- Pseudo window
  { from = "SUPER + T", to = "CTRL + ALT + T" }, -- Toggle window floating/tiling
  { from = "SUPER + F", to = "CTRL + SUPER + F" }, -- Full screen (Mac ⌃⌘F)
  { from = "SUPER + CTRL + F", to = "CTRL + ALT + F" }, -- Tiled full screen
  { from = "SUPER + ALT + F", to = "CTRL + ALT + RETURN" }, -- Full width (Rectangle "maximize")
  { from = "SUPER + O", to = "CTRL + ALT + O" }, -- Pop window out
  { from = "SUPER + L", to = "CTRL + ALT + L" }, -- Toggle workspace layout

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

  -- §6.2 Spaces (Phase 1b): numbers on ⌃ like macOS, arrows on ⌃⌥.
  -- spaces.lua adds ⌃⌥↑/↓ and the ⌃⌥⇧ arrows.
  { from = "SUPER + TAB", to = "CTRL + ALT + RIGHT" }, -- Next workspace (⌘Tab: switch window)
  { from = "SUPER + SHIFT + TAB", to = "CTRL + ALT + LEFT" }, -- Previous workspace
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
