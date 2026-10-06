-- Renders one config variant of an OMacKey tree into text files that freeze its
-- behaviour. Run by scripts/snapshot.sh, which sets:
--
--   SNAPSHOT_TREE     directory holding the omackey/ tree under test
--   SNAPSHOT_VARIANT  main | bare | emacs-off | mode-off | no-preinstalls
--   SNAPSHOT_OUT      output directory
--   XDG_STATE_HOME, XDG_CONFIG_HOME   scratch directories for this variant
--
-- Usage: lua5.5 tests/snapshot/render.lua

local here = arg[0]:match("^(.*)/[^/]*$") or "."
package.path = here .. "/?.lua;" .. package.path

local mock = require("mock")
local fixtures = require("fixtures")
local scenarios = require("scenarios")

local tree = assert(os.getenv("SNAPSHOT_TREE"), "SNAPSHOT_TREE not set")
local variant = assert(os.getenv("SNAPSHOT_VARIANT"), "SNAPSHOT_VARIANT not set")
local out = assert(os.getenv("SNAPSHOT_OUT"), "SNAPSHOT_OUT not set")
local omarchy = os.getenv("OMARCHY_PATH") or "/usr/share/omarchy"
local home = os.getenv("HOME") or ""

-- Paths that differ between runs or machines, replaced in every output line.
local placeholders = {
  { tree, "$TREE" },
  { os.getenv("XDG_STATE_HOME") or "\0", "$XDG_STATE_HOME" },
  { os.getenv("XDG_CONFIG_HOME") or "\0", "$XDG_CONFIG_HOME" },
  { home, "$HOME" },
}

-- Longest first, so a path inside another one gets its own name.
table.sort(placeholders, function(a, b)
  return #a[1] > #b[1]
end)

local function sanitize(text)
  text = tostring(text)
  for _, pair in ipairs(placeholders) do
    if pair[1] ~= "" then
      text = text:gsub(pair[1]:gsub("%p", "%%%0"), (pair[2]:gsub("%%", "%%%%")))
    end
  end
  return text
end

-- Loading ----------------------------------------------------------------

-- hypr.omackey.* always comes from the tree under test, never from the live
-- ~/.config/hypr/omackey symlink that bootstrap's package.path would find.
table.insert(package.searchers, 2, function(name)
  if name ~= "hypr.omackey" and name:sub(1, 13) ~= "hypr.omackey." then
    return nil
  end
  local path = tree .. "/omackey/" .. name:sub(14):gsub("%.", "/") .. ".lua"
  local chunk, err = loadfile(path)
  if chunk then
    return chunk, path
  end
  return function()
    error("module " .. name .. " is not in the tree under test: " .. tostring(err))
  end, path
end)

-- Which optional commands exist is part of the variant, not of the machine:
-- wtype (⌘-scroll) and voxtype (dictation) are present except in "bare".
local real_open = io.open
io.open = function(path, ...)
  if type(path) == "string" and (path:match("/wtype$") or path:match("/voxtype$")) then
    if variant == "bare" then
      return nil, path .. ": hidden by the snapshot variant"
    end
    return real_open("/dev/null", ...)
  end
  return real_open(path, ...)
end

local base_path = package.path
local state -- the current load's mock state

print = function(...)
  local parts = {}
  for i = 1, select("#", ...) do
    parts[i] = tostring((select(i, ...)))
  end
  table.insert(state.prints, table.concat(parts, "\t"))
end

-- A fresh config load, like a Hyprland reload: bootstrap clears the hypr.*
-- and default.hypr.* modules, and every global OMacKey keeps is reset here.
local function load()
  local hl
  hl, state = mock.new()
  _G.hl = hl
  _G.omackey = nil
  _G.o = nil
  _G.omarchy_preinstalled_bindings = nil
  if variant == "no-preinstalls" then
    _G.omarchy_preinstalled_bindings = false
  end
  package.path = base_path
  state.notes = {}

  local function loader_stage(stage)
    local ok, loader = pcall(require, "hypr.omackey.load")
    if not ok then
      table.insert(state.notes, "require hypr.omackey.load failed: " .. tostring(loader))
    else
      loader[stage]()
    end
  end

  local ok, err = pcall(function()
    dofile(omarchy .. "/default/hypr/bootstrap.lua")
    loader_stage("pre")
    require("default.hypr.omarchy")
    loader_stage("init")
  end)
  if not ok then
    table.insert(state.notes, "config load failed: " .. tostring(err))
  end
  state.loading = false
  return state
end

-- Output -----------------------------------------------------------------

local function write(name, lines)
  local file = assert(real_open(out .. "/" .. name .. "-" .. variant .. ".txt", "w"))
  for _, line in ipairs(lines) do
    file:write(sanitize(line), "\n")
  end
  file:close()
end

local function flags_text(bind)
  local flags = {}
  for key, value in pairs(bind.flags) do
    if key ~= "release" then
      flags[key] = value
    end
  end
  return mock.literal(flags)
end

local function dispatcher_text(bind)
  if type(bind.dispatcher) == "function" then
    return "lua"
  end
  return mock.literal(bind.dispatcher)
end

local function bind_title(bind)
  return string.format("%s%s %q", bind.chord, bind.release and " (release)" or "", bind.desc or "")
end

local function sorted_binds(binds)
  local list = {}
  for _, bind in ipairs(binds) do
    table.insert(list, bind)
  end
  table.sort(list, function(a, b)
    if a.chord ~= b.chord then
      return a.chord < b.chord
    end
    if a.release ~= b.release then
      return not a.release
    end
    return a.seq < b.seq
  end)
  return list
end

local function result_text(ok, result)
  if not ok then
    -- Drop "file:line:" so an error reads the same wherever the code moved.
    return "→ ERROR " .. tostring(result):gsub("^[^:]*:%d+: ", "")
  elseif result == nil then
    return "→ handled"
  elseif type(result) == "table" and result.ok == false and next(result, next(result)) == nil then
    return "→ pass"
  end
  return "→ returned " .. mock.literal(result)
end

local main = load()

-- binds-*, strings-*, order-*, load-* ----------------------------------

local lines = {}
for _, bind in ipairs(sorted_binds(main.binds)) do
  table.insert(lines, string.format("%s  %s  %s", bind_title(bind), flags_text(bind), dispatcher_text(bind)))
end
write("binds", lines)

lines = {}
for _, bind in ipairs(sorted_binds(main.binds)) do
  table.insert(lines, string.format("%s%s  %q", bind.chord, bind.release and " (release)" or "", bind.keys))
end
write("strings", lines)

lines = {}
for _, bind in ipairs(main.binds) do
  table.insert(lines, bind_title(bind))
end
write("order", lines)

lines = {}
local status_ok, status = pcall(function()
  return omackey and omackey.status and omackey.status() or "omackey.status() missing"
end)
table.insert(lines, "status: " .. tostring(status_ok and status or ("ERROR " .. tostring(status))))
for _, note in ipairs(main.notes) do
  table.insert(lines, "note: " .. note)
end
for _, text in ipairs(main.notifications) do
  table.insert(lines, "notification: " .. text)
end
for _, text in ipairs(main.prints) do
  table.insert(lines, "stdout: " .. text)
end
local subscriptions = {}
for _, name in ipairs(main.load_subscriptions) do
  subscriptions[name] = (subscriptions[name] or 0) + 1
end
local names = {}
for name in pairs(subscriptions) do
  table.insert(names, name)
end
table.sort(names)
for _, name in ipairs(names) do
  table.insert(lines, string.format("subscribed at load: %s ×%d", name, subscriptions[name]))
end
write("load", lines)

-- metadata-* (reported, not frozen) ------------------------------------

lines = {}
local bind_module = package.loaded["hypr.omackey.lib.bind"]
local registry = bind_module and bind_module.registry or {}
local specs = {}
for _, spec in ipairs(registry) do
  table.insert(specs, spec)
end
table.sort(specs, function(a, b)
  return tostring(a.id) < tostring(b.id)
end)
for _, spec in ipairs(specs) do
  local profiles = {}
  for profile in pairs(spec.actions or {}) do
    table.insert(profiles, profile)
  end
  table.sort(profiles)
  table.insert(lines, string.format("key %s  %s%s  category=%q  mac=%q  profiles={%s}", tostring(spec.id),
    mock.chord(spec.keys), spec.release and " (release)" or "", tostring(spec.category), tostring(spec.mac),
    table.concat(profiles, ",")))
end
local relocate = package.loaded["hypr.omackey.lib.relocate"]
for _, row in ipairs(relocate and relocate.applied or {}) do
  table.insert(lines, string.format("relocated %s → %s  %q", mock.chord(row.from), mock.chord(row.to),
    tostring(row.description)))
end
write("metadata", lines)

-- behaviour-* ------------------------------------------------------------

-- Press bind `index` once in every fixture app, each with a fresh world.
local function exercise(index)
  local current = load()
  local bind = current.binds[index]
  assert(bind and bind.chord == main.binds[index].chord, "bind order differs between two loads")

  local groups, order = {}, {}
  for _, app in ipairs(fixtures.apps) do
    local window = fixtures.app_window(app)
    if window then
      window.label = "active" -- the same text in every app, so outcomes group
    end
    current.windows = { window }
    current.active = window
    current.timers = {}
    current.log = {}
    current.origin = current.now

    local ok, result = pcall(bind.dispatcher)
    local result_line = result_text(ok, result)
    current.flush()

    local outcome = table.concat(current.log, "\n") .. "\n" .. result_line
    if not groups[outcome] then
      groups[outcome] = {}
      table.insert(order, outcome)
    end
    table.insert(groups[outcome], app[1])
  end

  local text = { bind_title(bind) .. "  " .. flags_text(bind) }
  for _, outcome in ipairs(order) do
    table.insert(text, "  " .. table.concat(groups[outcome], ", ") .. ":")
    for line in outcome:gmatch("[^\n]+") do
      table.insert(text, "    " .. line)
    end
  end
  return text
end

lines = {}
local by_seq = {}
for index, bind in ipairs(main.binds) do
  by_seq[bind] = index
end
for _, bind in ipairs(sorted_binds(main.binds)) do
  if type(bind.dispatcher) == "function" then
    for _, line in ipairs(exercise(by_seq[bind])) do
      table.insert(lines, line)
    end
  end
end
write("behaviour", lines)

-- scenarios-* --------------------------------------------------------------

local function run_scenario(scenario)
  local current = load()
  current.log = {}
  current.origin = current.now
  local start = current.now
  local by_label = {}
  local S = {}

  function S.windows(list)
    current.windows = {}
    for history, spec in ipairs(list) do
      local window = fixtures.window(spec[1], spec[2], spec.tags, {
        workspace = spec.special and fixtures.workspace(spec.special, true) or fixtures.workspace(spec.ws or 1),
        floating = spec.floating or false,
        focus_history_id = history - 1,
        stable_id = spec.stable_id,
      })
      if window.stable_id == nil then
        window.stable_id = 100 + history
      end
      table.insert(current.windows, window)
      by_label[spec[1]] = window
    end
    current.active = current.windows[1]
  end

  local function find(keys, release)
    local chord = mock.chord(keys)
    for _, bind in ipairs(current.binds) do
      if bind.chord == chord and bind.release == release then
        return bind
      end
    end
  end

  local function press(keys, release)
    local bind = find(keys, release)
    local what = (release and "release " or "press ") .. keys
    if not bind then
      current.write(what .. " → no bind")
    elseif type(bind.dispatcher) == "function" then
      current.write(what)
      local ok, result = pcall(bind.dispatcher)
      current.write(result_text(ok, result))
    else
      current.write(what .. " → native")
      current.write(mock.literal(bind.dispatcher))
    end
  end

  function S.press(keys)
    press(keys, false)
  end

  function S.release(keys)
    press(keys, true)
  end

  function S.key(code, key_state)
    current.write(string.format("key %d %s", code, key_state == 0 and "up" or "down"))
    current.fire("input.keyboard.key", code, current.now, key_state)
  end

  function S.wait(ms)
    current.flush(current.now + ms)
  end

  function S.at(ms)
    current.flush(start + ms)
  end

  function S.click(label)
    current.write("user focuses <" .. label .. ">")
    current.focus(by_label[label])
  end

  function S.close(label)
    current.write("<" .. label .. "> closes")
    current.remove(by_label[label])
  end

  local ok, err = pcall(scenario.run, S)
  if not ok then
    current.write("SCENARIO ERROR " .. tostring(err))
  end
  current.flush()
  local labels = {}
  for _, window in ipairs(current.windows) do
    table.insert(labels, window.label)
  end
  current.write("end: active <" .. (current.active and current.active.label or "none") .. ">, windows "
    .. table.concat(labels, " "))

  local text = { "## " .. scenario.name }
  for _, line in ipairs(current.log) do
    table.insert(text, "  " .. line)
  end
  return text
end

lines = {}
for _, scenario in ipairs(scenarios) do
  for _, line in ipairs(run_scenario(scenario)) do
    table.insert(lines, line)
  end
end
write("scenarios", lines)
