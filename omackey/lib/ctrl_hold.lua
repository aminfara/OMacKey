-- Holds a virtual Ctrl for a moment, so a physical ⌘ + scroll tick reaches the
-- app as Ctrl + scroll (browser zoom; docs/FINDINGS.md F19, F20, F24).
--
-- Hyprland can't give a pointer event a modifier of its own, but `wtype -M ctrl
-- -s MS` presses Ctrl on a virtual keyboard for MS milliseconds and releases it
-- itself, and that state does reach clicks and wheel ticks. The catch is that
-- starting `wtype` takes a few milliseconds: the tick that starts a hold, and
-- the ones during the warm-up, are consumed (a plain tick would scroll the
-- page); later ticks pass through carrying Ctrl. A tick halfway through a hold
-- starts the next one before the first ends, so a long burst never drops Ctrl.
-- Every `wtype` releases its own Ctrl, so nothing can stay stuck.

local after = require("hypr.omackey.lib.send").after

local M = {
  hold_ms = 400, -- how long one wtype holds Ctrl
  warm_ms = 60, -- from starting wtype until Ctrl reaches the app
  extend_ms = 200, -- how long into a hold the next one may start

  state = "off", -- "off" | "warming" | "held"
  can_extend = false,
  generation = 0, -- timers from an older hold are ignored
}

local function start_hold()
  M.generation = M.generation + 1
  local generation = M.generation
  M.can_extend = false

  hl.dispatch(hl.dsp.exec_cmd("wtype -M ctrl -s " .. M.hold_ms))

  after(M.extend_ms, function()
    if generation == M.generation then
      M.can_extend = true
    end
  end)
  after(M.hold_ms, function()
    if generation == M.generation then
      M.state = "off"
    end
  end)
end

-- Call on every ⌘ + scroll tick. Returns what a bind handler should return.
function M.tick()
  if M.state == "off" then
    M.state = "warming"
    start_hold()
    after(M.warm_ms, function()
      if M.state == "warming" then
        M.state = "held"
      end
    end)
    return nil -- consumed
  end

  if M.state == "warming" then
    return nil -- Ctrl is not there yet
  end

  if M.can_extend then
    start_hold()
  end
  return { ok = false } -- pass the tick: the app sees Ctrl
end

return M
