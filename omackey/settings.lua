-- User-facing options: their defaults, and the optional user file that
-- overrides them.
--
--   ${XDG_CONFIG_HOME:-~/.config}/omackey/settings.lua
--
-- If that file exists, it returns a table with the options to change, e.g.
--
--   return { emacs_keys = false, close_window_classes = { "org.gnome.Calculator" } }
--
-- It is read as data: it runs with an empty environment, so it can't call
-- hl or require anything. An unknown option or a value of the wrong type is
-- reported in omackey.status() and ignored; a file that fails to load leaves
-- every default in place. Nothing creates or removes the file. Reload
-- Hyprland after changing it.

local OPTIONS = {
  {
    name = "emacs_keys",
    default = true,
    check = "boolean",
    doc = "Mac text-field editing keys on physical ⌃: ⌃A / ⌃E line start / end, "
      .. "⌃F / ⌃B / ⌃N / ⌃P arrows, ⌃D / ⌃H delete, ⌃K delete to line end. Terminals keep "
      .. "the raw key, and so does ⌃D in VS Code. They take ⌃A, ⌃F, ⌃H … away from GUI "
      .. "apps (select all, find, history): set this to false to get those back.",
  },
  {
    name = "release_ms",
    default = 20,
    check = "milliseconds",
    doc = "How long a synthetic key stays down before its release is sent "
      .. "(Omarchy uses 50 ms).",
  },
  {
    name = "close_window_classes",
    default = {},
    check = "classes",
    doc = "Window classes of GUI apps where Ctrl+W doesn't close the window, so ⌘W "
      .. "closes it instead. Add a class (see hyprctl clients) when ⌘W does nothing.",
  },
}

local CHECKS = {
  boolean = function(value)
    return type(value) == "boolean", "true or false"
  end,
  milliseconds = function(value)
    return math.type(value) == "integer" and value > 0, "a whole number of milliseconds above 0"
  end,
  classes = function(value)
    if type(value) ~= "table" then
      return false, "a list of window classes"
    end
    for key, class in pairs(value) do
      if math.type(key) ~= "integer" or type(class) ~= "string" then
        return false, "a list of window classes"
      end
    end
    return true
  end,
}

local M = {
  options = OPTIONS, -- for the docs: name, default, doc
  errors = {}, -- problems with the user file
}

for _, option in ipairs(OPTIONS) do
  M[option.name] = option.default
end

local config_home = os.getenv("XDG_CONFIG_HOME")
if not config_home or config_home == "" then
  config_home = (os.getenv("HOME") or "") .. "/.config"
end
M.user_file = config_home .. "/omackey/settings.lua"

local function read_user_file(path)
  local handle = io.open(path, "r")
  if not handle then
    return nil -- no file: the defaults apply
  end
  handle:close()

  local chunk, err = loadfile(path, "t", {})
  if not chunk then
    return nil, err
  end
  local ok, result = pcall(chunk)
  if not ok then
    return nil, path .. ": " .. tostring(result)
  end
  if type(result) ~= "table" then
    return nil, path .. ": must return a table of options"
  end
  return result
end

local user, err = read_user_file(M.user_file)
if err then
  table.insert(M.errors, "settings file ignored: " .. err)
end

local by_name = {}
for _, option in ipairs(OPTIONS) do
  by_name[option.name] = option
end

local names = {}
for name in pairs(user or {}) do
  table.insert(names, tostring(name))
end
table.sort(names)

for _, name in ipairs(names) do
  local option = by_name[name]
  local value = user[name]
  if not option then
    table.insert(M.errors, "settings: unknown option '" .. name .. "' ignored")
  else
    local ok, expected = CHECKS[option.check](value)
    if ok then
      M[name] = value
    else
      table.insert(M.errors, "settings: '" .. name .. "' must be " .. expected .. "; default kept")
    end
  end
end

return M
