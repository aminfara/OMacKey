-- macOS-style app switching (⌘Tab): by recency, without an overlay.
--
-- An "app" is a window class, as in ⌘Q; a window without a class is its own
-- app. Apps are ordered by recency here, from focus events, because Hyprland's
-- own focus history counts every stop of a multi-step switch: going A → B → C
-- would leave B ranked above A, and the next ⌘Tab would not flip back to A.
--
-- A switch is a "session" that lasts while ⌘ is held. Its ring holds app names,
-- never windows, and is resolved against the live windows at every step, so
-- apps and windows can come and go in the middle of it.

local M = {}

local KEY_SUPER_L, KEY_SUPER_R = 133, 134 -- XKB keycodes (evdev + 8)

local tracker = {
  order = {}, -- app names, most recently used first
  session = nil, -- { ring = { app, … }, position = n, stop = app, subscription = … }
}

local function app_of(window)
  return window.class ~= "" and window.class or window.address
end

-- Every app with a window, mapped to its most recently focused window.
-- Hidden and scratchpad windows don't count.
local function latest_windows()
  local latest = {}

  for _, window in ipairs(hl.get_windows({ mapped = true })) do
    local workspace = window.workspace
    if not window.hidden and not (workspace and workspace.special) then
      local app = app_of(window)
      local seen = latest[app]
      if not seen or window.focus_history_id < seen.focus_history_id then
        latest[app] = window
      end
    end
  end

  return latest
end

-- The front app first (when there is one), then the others, most recent first.
-- Apps the order has not seen yet (opened before a reload, say) come after the
-- known ones, ranked by Hyprland's focus history.
local function build_ring(front)
  local latest = latest_windows()

  local rank = {}
  for index, app in ipairs(tracker.order) do
    rank[app] = index
  end

  local ring = {}
  for app in pairs(latest) do
    if app ~= front then
      table.insert(ring, app)
    end
  end
  table.sort(ring, function(a, b)
    local rank_a, rank_b = rank[a] or math.huge, rank[b] or math.huge
    if rank_a ~= rank_b then
      return rank_a < rank_b
    end
    return latest[a].focus_history_id < latest[b].focus_history_id
  end)

  if front then
    table.insert(ring, 1, front)
  end

  return ring
end

local function touch(app)
  for index, other in ipairs(tracker.order) do
    if other == app then
      table.remove(tracker.order, index)
      break
    end
  end

  table.insert(tracker.order, 1, app)
end

-- Ends the session. The app we stopped on becomes the most recent one; the apps
-- passed on the way keep their old order.
function M.finish()
  local session = tracker.session
  if not session then
    return
  end

  tracker.session = nil
  session.subscription:remove()

  local active = hl.get_active_window()
  if not active then
    return
  end

  local front = app_of(active)
  local order = { front }
  for _, app in ipairs(session.ring) do
    if app ~= front then
      table.insert(order, app)
    end
  end
  tracker.order = order
end

local function on_key(code, _, state)
  if state == 0 and (code == KEY_SUPER_L or code == KEY_SUPER_R) then
    M.finish()
  end
end

-- Focus a window, and raise it if it floats.
function M.focus(window)
  hl.dispatch(hl.dsp.focus({ window = window }))
  if window.floating then
    hl.dispatch(hl.dsp.window.bring_to_top())
  end
end

-- ⌘Tab (forward) and ⌘⇧Tab (backward). The first press of a session goes to
-- the app used before this one, so tapping flips between two apps; from the
-- front app, going backward reaches the app used longest ago. Pressing again
-- while ⌘ is held steps further along the ring.
function M.step(forward)
  local active = hl.get_active_window()
  local session = tracker.session

  -- A click, ⌥Tab or a closing window moved focus away from our last stop:
  -- start over from where we are.
  if session and not (active and app_of(active) == session.stop) then
    M.finish()
    session = nil
  end

  if not session then
    local front = active and app_of(active)
    local ring = build_ring(front)
    if #ring < 2 then
      return
    end

    session = {
      ring = ring,
      stop = front,
      -- Without a front app, the first step lands on the first (forward) or
      -- last (backward) app of the ring.
      position = front and 1 or (forward and 0 or 1),
      subscription = hl.on("input.keyboard.key", on_key),
    }
    tracker.session = session
  end

  local latest = latest_windows()
  local ring = session.ring
  local direction = forward and 1 or -1

  for _ = 1, #ring do
    session.position = (session.position - 1 + direction) % #ring + 1

    local app = ring[session.position]
    local window = latest[app]
    if window and app ~= session.stop then
      session.stop = app -- before focusing: the focus change is ours
      M.focus(window)
      return
    end
  end
end

-- Follow focus changes outside a session, so clicks and other shortcuts count.
-- Inside a session the stops are not recorded: finish() decides the order.
function M.start()
  hl.on("window.active", function(window)
    if tracker.session or not window then
      return
    end

    touch(app_of(window))
  end)
end

-- A copy of the state, for tests and debugging.
function M.snapshot()
  local session = tracker.session

  return {
    order = { table.unpack(tracker.order) },
    session = session and {
      ring = { table.unpack(session.ring) },
      position = session.position,
      stop = session.stop,
    } or nil,
  }
end

return M
