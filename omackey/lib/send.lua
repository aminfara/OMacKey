-- Synthetic key chords sent to the focused surface.
--
-- A chord is pressed with send_key_state "down" and released by a timer.
-- Hyprland's send_shortcut leaves keys stuck or repeating
-- (https://github.com/hyprwm/Hyprland/discussions/14099), so it is not used.
-- Explicit `mods` replace the physically held modifiers for the event, and no
-- `window` is given, so layer-shell surfaces (Omarchy menus) receive it too.

local config = require("hypr.omackey.config")
local keys = require("hypr.omackey.lib.keys")

local M = {}

-- Timer handles must stay referenced until they fire: a garbage-collected timer
-- never runs, the release is never sent, and the key repeats in the app.
local pending = {}
local next_id = 0

local function key_state(mods, code, state)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = code, state = state }))
end

local function after(ms, fn)
  next_id = next_id + 1
  local id = next_id
  pending[id] = hl.timer(function()
    pending[id] = nil
    fn()
  end, { timeout = ms, type = "oneshot" })
end

M.after = after

-- send.button("CTRL", "mouse:272", "down") sends one pointer button event with
-- these modifiers now. Explicit `mods` replace the held ⌘ for the event, so the
-- app sees a Ctrl click.
function M.button(mods, button, state)
  key_state(mods, button, state)
end

-- send.tap("CTRL + SHIFT", "Home") → function that presses and releases the
-- chord once. Key names are resolved now, so a typo fails at config load.
function M.tap(mods, key)
  local code = keys.code(key)

  return function()
    key_state(mods, code, "down")
    after(config.release_ms, function()
      key_state(mods, code, "up")
    end)
  end
end

-- send.seq(send.tap(...), send.tap(...)) → function that taps each chord in
-- order, spaced so one is released before the next goes down.
function M.seq(...)
  local steps = { ... }
  local gap = config.release_ms + 5

  return function()
    for i, step in ipairs(steps) do
      if i == 1 then
        step()
      else
        after((i - 1) * gap, step)
      end
    end
  end
end

return M
