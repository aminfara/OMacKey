-- Window queries and actions shared by ⌘Q, ⌘` and ⌘Tab (lib/switcher.lua).
--
-- An "app" is a window class; a window without a class is its own app.

local M = {}

-- The app a window belongs to: its class, or its address when it has none.
function M.app_of(window)
  return window.class ~= "" and window.class or window.address
end

-- Mapped windows a user can switch to: hidden and scratchpad windows don't
-- count. In Hyprland's order.
function M.visible()
  local visible = {}

  for _, window in ipairs(hl.get_windows({ mapped = true })) do
    local workspace = window.workspace
    if not window.hidden and not (workspace and workspace.special) then
      table.insert(visible, window)
    end
  end

  return visible
end

-- Focus a window, and raise it if it floats.
function M.focus(window)
  hl.dispatch(hl.dsp.focus({ window = window }))
  if window.floating then
    hl.dispatch(hl.dsp.window.bring_to_top())
  end
end

-- Close the active window, as Omarchy's "Close window" does.
function M.close()
  hl.dispatch(hl.dsp.window.close())
end

-- Quit like macOS: close every window of the active window's app (the same
-- window class), hidden and scratchpad windows included. Apps with unsaved
-- work still ask before closing.
function M.quit_app()
  local active = hl.get_active_window()
  if not active then
    return
  end

  local class = active.class
  if class == "" then
    M.close() -- nothing to match on: just this window
    return
  end

  for _, window in ipairs(hl.get_windows({ mapped = true })) do
    if window.class == class then
      hl.dispatch(hl.dsp.window.close({ window = window }))
    end
  end
end

-- ⌘` (step 1) and ⇧⌘` (step -1): step through the visible windows of the
-- active app on every workspace, in a fixed order, wrapping around. Not
-- recency: with three windows the ring visits all of them, as on a Mac.
function M.cycle_app_windows(step)
  local active = hl.get_active_window()
  if not active or active.class == "" then
    return
  end

  local windows = {}
  for _, window in ipairs(M.visible()) do
    if window.class == active.class then
      table.insert(windows, window)
    end
  end
  table.sort(windows, function(a, b)
    return a.stable_id < b.stable_id
  end)

  for index, window in ipairs(windows) do
    if window.address == active.address then
      M.focus(windows[(index - 1 + step) % #windows + 1])
      return
    end
  end
end

return M
