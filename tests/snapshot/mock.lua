-- A fake Hyprland `hl` for the snapshot harness: it records binds, renders
-- dispatchers as text, runs timers on a virtual clock and keeps a small window
-- world, so a bind's handler can be pressed and everything it does written down.
--
-- Only what OMacKey and Omarchy's binding files use is modelled; every other
-- `hl` field is a callable no-op, as in Omarchy's help-menu replay.

local M = {}

-- Chords -----------------------------------------------------------------

local MODIFIERS = { SUPER = "SUPER", CTRL = "CTRL", CONTROL = "CTRL", ALT = "ALT", SHIFT = "SHIFT" }
local MODIFIER_ORDER = { "SUPER", "CTRL", "ALT", "SHIFT" }

-- XKB keycodes (evdev + 8) of the US layout → key names, so a bind written by
-- keycode and one written by name compare as the same key.
local CODE_NAMES = {
  [9] = "escape", [20] = "minus", [21] = "equal", [22] = "backspace", [23] = "tab",
  [34] = "bracketleft", [35] = "bracketright", [36] = "return", [47] = "semicolon",
  [48] = "apostrophe", [49] = "grave", [51] = "backslash", [59] = "comma",
  [60] = "period", [61] = "slash", [65] = "space",
}
for _, row in ipairs({ { "1234567890", 10 }, { "qwertyuiop", 24 }, { "asdfghjkl", 38 }, { "zxcvbnm", 52 } }) do
  for i = 1, #row[1] do
    CODE_NAMES[row[2] + i - 1] = row[1]:sub(i, i)
  end
end

-- "SUPER + SHIFT + code:12" and "shift + super + 3" → "SUPER+SHIFT+3"
function M.chord(keys)
  local present, key = {}, ""
  for part in tostring(keys):gmatch("[^+]+") do
    local trimmed = part:match("^%s*(.-)%s*$")
    local modifier = MODIFIERS[trimmed:upper()]
    if modifier then
      present[modifier] = true
    else
      key = trimmed:lower()
    end
  end

  local code = tonumber(key:match("^code:(%d+)$"))
  if code and CODE_NAMES[code] then
    key = CODE_NAMES[code]
  end

  local parts = {}
  for _, modifier in ipairs(MODIFIER_ORDER) do
    if present[modifier] then
      table.insert(parts, modifier)
    end
  end
  table.insert(parts, key)
  return table.concat(parts, "+")
end

-- Rendering --------------------------------------------------------------

local literal

local function render_dispatcher(d)
  local args = {}
  for i = 1, d.n do
    args[i] = literal(d.args[i])
  end
  return (d.path:gsub("^hl%.dsp%.", "")) .. "(" .. table.concat(args, ", ") .. ")"
end

function literal(value, depth)
  depth = depth or 0
  local kind = type(value)
  if kind == "string" then
    return string.format("%q", value)
  elseif kind == "number" or kind == "boolean" or kind == "nil" then
    return tostring(value)
  elseif kind == "function" then
    return "<function>"
  elseif kind ~= "table" then
    return "<" .. kind .. ">"
  elseif value.__window then
    return "<" .. value.label .. ">"
  elseif value.__dsp then
    return render_dispatcher(value)
  elseif depth > 4 then
    return "{…}"
  end

  local keys = {}
  for key in pairs(value) do
    table.insert(keys, key)
  end
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end)

  local parts = {}
  for _, key in ipairs(keys) do
    local prefix = type(key) == "string" and key:match("^[%a_][%w_]*$") and key .. " = "
      or "[" .. literal(key) .. "] = "
    table.insert(parts, prefix .. literal(value[key], depth + 1))
  end
  return #parts == 0 and "{}" or "{ " .. table.concat(parts, ", ") .. " }"
end

M.literal = literal

-- The fake hl --------------------------------------------------------------

local noop
noop = setmetatable({}, {
  __index = function()
    return noop
  end,
  __call = function()
    return noop
  end,
})

local function dsp_proxy(path)
  return setmetatable({}, {
    __index = function(_, key)
      return dsp_proxy(path .. "." .. tostring(key))
    end,
    __call = function(_, ...)
      return { __dsp = true, path = path, args = { ... }, n = select("#", ...) }
    end,
  })
end

-- M.new() → hl, state. `state` holds what the harness reads and drives.
function M.new()
  local state = {
    binds = {}, -- { seq, keys, chord, release, flags, desc, dispatcher }
    bind_seq = 0,
    windows = {},
    active = nil,
    now = 0,
    origin = 0,
    log = {},
    timers = {},
    timer_seq = 0,
    subscriptions = {}, -- event name → list of { fn, removed }
    load_subscriptions = {}, -- event names subscribed while loading
    loading = true,
    notifications = {},
    prints = {},
  }

  function state.write(text)
    table.insert(state.log, string.format("+%d %s", state.now - state.origin, text))
  end

  function state.fire(name, ...)
    local list = {}
    for _, sub in ipairs(state.subscriptions[name] or {}) do
      table.insert(list, sub)
    end
    for _, sub in ipairs(list) do
      if not sub.removed then
        sub.fn(...)
      end
    end
  end

  function state.focus(window)
    if not window or state.active == window then
      return
    end
    local old = window.focus_history_id
    for _, other in ipairs(state.windows) do
      if other ~= window and other.focus_history_id < old then
        other.focus_history_id = other.focus_history_id + 1
      end
    end
    window.focus_history_id = 0
    state.active = window
    state.fire("window.active", window)
  end

  function state.remove(window)
    for i, other in ipairs(state.windows) do
      if other == window then
        table.remove(state.windows, i)
        break
      end
    end
    for _, other in ipairs(state.windows) do
      if other.focus_history_id > window.focus_history_id then
        other.focus_history_id = other.focus_history_id - 1
      end
    end
    if state.active == window then
      state.active = nil
      local next_window
      for _, other in ipairs(state.windows) do
        if not next_window or other.focus_history_id < next_window.focus_history_id then
          next_window = other
        end
      end
      if next_window then
        state.active = next_window
        state.fire("window.active", next_window)
      end
    end
  end

  -- Run timers due up to `limit` (all of them when nil), in time order.
  function state.flush(limit)
    for _ = 1, 10000 do
      local due
      for _, timer in ipairs(state.timers) do
        if not timer.removed and (not limit or timer.at <= limit)
          and (not due or timer.at < due.at or (timer.at == due.at and timer.seq < due.seq)) then
          due = timer
        end
      end
      if not due then
        if limit and limit > state.now then
          state.now = limit
        end
        return
      end
      due.removed = true
      if due.at > state.now then
        state.now = due.at
      end
      due.fn()
      if due.repeating then
        state.timer_seq = state.timer_seq + 1
        table.insert(state.timers, { at = state.now + due.timeout, seq = state.timer_seq, fn = due.fn,
          timeout = due.timeout, repeating = true })
      end
    end
    error("snapshot: timers still due after 10000 runs")
  end

  local function effects(d)
    local args = d.args[1]
    if d.path == "hl.dsp.focus" and type(args) == "table" and type(args.window) == "table" then
      state.focus(args.window)
    elseif d.path == "hl.dsp.window.close" or d.path == "hl.dsp.window.kill" then
      local target = type(args) == "table" and args.window or state.active
      if type(target) == "table" and target.__window then
        state.remove(target)
      end
    end
  end

  local hl = {}

  hl.dsp = dsp_proxy("hl.dsp")

  function hl.bind(keys, dispatcher, opts)
    opts = opts or {}
    local flags = {}
    for key, value in pairs(opts) do
      if key ~= "description" then
        flags[key] = value
      end
    end
    state.bind_seq = state.bind_seq + 1
    table.insert(state.binds, {
      seq = state.bind_seq,
      keys = tostring(keys),
      chord = M.chord(keys),
      release = opts.release == true,
      flags = flags,
      desc = opts.description,
      dispatcher = dispatcher,
    })
    return noop
  end

  function hl.unbind(keys)
    local chord = M.chord(keys)
    for i = #state.binds, 1, -1 do
      if state.binds[i].chord == chord then
        table.remove(state.binds, i)
      end
    end
  end

  function hl.dispatch(d)
    if type(d) == "table" and d.__dsp then
      state.write(render_dispatcher(d))
      effects(d)
    else
      state.write("dispatch " .. literal(d))
    end
  end

  function hl.exec_cmd(command)
    state.write("exec_cmd " .. literal(command))
  end

  function hl.timer(fn, opts)
    opts = opts or {}
    local timeout = opts.timeout or 0
    state.timer_seq = state.timer_seq + 1
    local timer = { at = state.now + timeout, seq = state.timer_seq, fn = fn, timeout = timeout,
      repeating = opts.type == "repeat" }
    table.insert(state.timers, timer)
    return setmetatable({}, {
      __index = function(_, key)
        if key == "remove" or key == "stop" then
          return function()
            timer.removed = true
          end
        end
        return noop
      end,
    })
  end

  function hl.on(name, fn)
    local sub = { fn = fn }
    state.subscriptions[name] = state.subscriptions[name] or {}
    table.insert(state.subscriptions[name], sub)
    if state.loading then
      table.insert(state.load_subscriptions, name)
    end
    return setmetatable({}, {
      __index = function(_, key)
        if key == "remove" then
          return function()
            sub.removed = true
          end
        end
        return noop
      end,
    })
  end

  function hl.get_active_window()
    return state.active
  end

  function hl.get_windows()
    local list = {}
    for _, window in ipairs(state.windows) do
      table.insert(list, window)
    end
    return list
  end

  function hl.get_active_workspace()
    return state.active and state.active.workspace or { id = 1, name = "1", special = false }
  end

  function hl.get_config()
    return nil
  end

  hl.notification = setmetatable({
    create = function(spec)
      table.insert(state.notifications, type(spec) == "table" and tostring(spec.text) or tostring(spec))
    end,
  }, { __index = function()
    return noop
  end })

  setmetatable(hl, {
    __index = function()
      return noop
    end,
  })

  return hl, state
end

return M
