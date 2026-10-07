-- Renders docs/KEYBINDINGS.md from lib/catalog.lua. The config is loaded under
-- the snapshot's fake Hyprland (tests/snapshot/mock.lua), so Hyprland need not
-- run and the result does not depend on the machine: the optional user
-- settings file and the Mac-mode switch are ignored, and wtype / voxtype count
-- as installed.
--
--   lua5.5 scripts/gen-docs.lua            write docs/KEYBINDINGS.md
--   lua5.5 scripts/gen-docs.lua --check    fail if docs/KEYBINDINGS.md is out of date
--   lua5.5 scripts/gen-docs.lua --stdout   print instead of writing
--
-- Needs lua5.5 and Omarchy's files (OMARCHY_PATH, default /usr/share/omarchy).

local repo = (arg[0]:match("^(.*)/[^/]*$") or ".") .. "/.."
package.path = repo .. "/tests/snapshot/?.lua;" .. package.path

local mock = require("mock")

local omarchy = os.getenv("OMARCHY_PATH") or "/usr/share/omarchy"
local target = repo .. "/docs/KEYBINDINGS.md"

-- Machine-independent: no user settings file, no state file, commands present.
local real_getenv, real_open = os.getenv, io.open
os.getenv = function(name) -- luacheck: ignore 122
  if name == "XDG_CONFIG_HOME" or name == "XDG_STATE_HOME" then
    return "/nonexistent-omackey-gen-docs"
  end
  return real_getenv(name)
end
io.open = function(path, ...) -- luacheck: ignore 122
  if type(path) == "string" and (path:match("/wtype$") or path:match("/voxtype$")) then
    return real_open("/dev/null", ...)
  end
  return real_open(path, ...)
end

-- hypr.omackey.* comes from this repo, not from the live symlink.
table.insert(package.searchers, 2, function(name)
  if name ~= "hypr.omackey" and name:sub(1, 13) ~= "hypr.omackey." then
    return nil
  end
  local path = repo .. "/omackey/" .. name:sub(14):gsub("%.", "/") .. ".lua"
  local chunk, err = loadfile(path)
  if chunk then
    return chunk, path
  end
  return function()
    error("module " .. name .. " is not in " .. repo .. ": " .. tostring(err))
  end, path
end)

-- The config must not print, and nothing here needs to.
print = function() end -- luacheck: ignore 121

local hl, state = mock.new()
_G.hl = hl
dofile(omarchy .. "/default/hypr/bootstrap.lua")
for _, stage in ipairs({ "pre", "init" }) do
  if stage == "init" then
    require("default.hypr.omarchy")
  end
  require("hypr.omackey.load")[stage]()
end
state.loading = false

local status = omackey.status()
if status:find("errors=", 1, true) or status:find("off", 1, true) then
  io.stderr:write("gen-docs: the config did not load cleanly: " .. status .. "\n")
  os.exit(2)
end

local catalog = require("hypr.omackey.lib.catalog")
local keys = require("hypr.omackey.lib.keys")

-- Markdown -----------------------------------------------------------------

-- Table cells: no pipes or newlines; backticks and the like in glyphs.
local function cell(text)
  return (tostring(text):gsub("|", "\\|"):gsub("\n", " "))
end

local function glyph(text)
  return (cell(text):gsub("([`*_<>])", "\\%1"))
end

-- Key strings go in a code span; one with a backtick needs a longer fence.
local function code(text)
  return "`" .. cell(text) .. "`"
end

local out = {}
local function add(line)
  table.insert(out, line or "")
end

local function table_of(header, rows)
  add("| " .. table.concat(header, " | ") .. " |")
  add("|" .. string.rep(" --- |", #header))
  for _, row in ipairs(rows) do
    add("| " .. table.concat(row, " | ") .. " |")
  end
  add()
end

local function sorted_names(map)
  local names = {}
  for name in pairs(map) do
    table.insert(names, name)
  end
  table.sort(names)
  return names
end

-- What a key does when no app-specific action applies.
local function everywhere(row)
  return row.action or row.default or "The key reaches the app unchanged"
end

local function differs_in(row)
  local names = sorted_names(row.apps)
  return #names > 0 and table.concat(names, ", ") or ""
end

local function flags_of(row)
  local flags = {}
  if row.flags.repeating then
    table.insert(flags, "repeats")
  end
  if row.flags.release then
    table.insert(flags, "on release")
  end
  return table.concat(flags, ", ")
end

local all_keys = catalog.keys()

-- Header ---------------------------------------------------------------------

add("# OMacKey — Keybindings")
add()
add("Generated from the code by `scripts/gen-docs.lua`: do not edit by hand. Run")
add("`lua5.5 scripts/gen-docs.lua` after changing a shortcut, an app or a relocation.")
add()
add("- ⌘ = `SUPER`, ⌥ = `ALT`, ⌃ = `CTRL`, ⇧ = `SHIFT`. Glyphs are in Apple's order (`⇧⌘[`).")
add("- The **Key** column is the exact string for `hl.unbind(\"…\")` in")
add("  `~/.config/hypr/bindings.lua`, which switches that shortcut off (case-sensitive).")
add("- A key with no action in the app you are using passes through to the app unchanged.")
add("- What is not mapped, and why: [LIMITATIONS.md](LIMITATIONS.md). The modifier model:")
add("  [ARCHITECTURE.md](ARCHITECTURE.md) §2.")
add()
add("Contents: [Shortcuts](#shortcuts) · [Per-app actions](#per-app-actions) ·")
add("[Opt-in keys](#opt-in-keys) · [Relocated Omarchy binds](#relocated-omarchy-binds) ·")
add("[Settings](#settings)")
add()

-- Shortcuts ------------------------------------------------------------------

local function unconditional(row)
  return row.condition == nil
end

add("## Shortcuts")
add()
add("**Action** is what the key does in a generic app. **Differs in** lists the apps that do")
add("something else (see [Per-app actions](#per-app-actions)).")
add()

local categories, by_category = {}, {}
for _, row in ipairs(all_keys) do
  if unconditional(row) then
    local name = row.category or "Other"
    if not by_category[name] then
      by_category[name] = {}
      table.insert(categories, name)
    end
    table.insert(by_category[name], row)
  end
end

for _, name in ipairs(categories) do
  add("### " .. name)
  add()
  if name == "Catch-all" then
    add("Every ⌘ or ⇧⌘ chord that nothing else claims is sent as Ctrl or Ctrl+Shift with the")
    add("same key. A few are deliberately not mapped (see [LIMITATIONS.md](LIMITATIONS.md)).")
    add()
  end
  local rows = {}
  for _, row in ipairs(by_category[name]) do
    table.insert(rows, {
      glyph(row.mac),
      code(row.keys),
      cell(row.desc),
      cell(everywhere(row)),
      cell(differs_in(row)),
      cell(flags_of(row)),
    })
  end
  table_of({ "Mac", "Key", "Description", "Action", "Differs in", "Flags" }, rows)
end

-- Per-app actions ------------------------------------------------------------

add("## Per-app actions")
add()
add("Apps are matched in this order; the first whose class or tag matches the active window")
add("wins, then its family, then the generic action. An app entry replaces the generic action")
add("for that key only.")
add()

local app_rows = {}
for _, app in ipairs(catalog.apps()) do
  local match = {}
  for _, class in ipairs(app.classes) do
    table.insert(match, "class " .. code(class))
  end
  for _, tag in ipairs(app.tags) do
    table.insert(match, "tag " .. code(tag))
  end
  table.insert(app_rows, {
    cell(app.name),
    app.family and cell(app.family) or "",
    #match > 0 and table.concat(match, ", ") or "set by a setting (`close_window_classes`)",
  })
end
table_of({ "App", "Family", "Matches" }, app_rows)

for _, app in ipairs(catalog.apps()) do
  local rows = {}
  for _, row in ipairs(all_keys) do
    local text = row.apps[app.name]
    if text and not row.catchall then
      table.insert(rows, {
        glyph(row.mac),
        code(row.keys),
        cell(text),
        cell(row.default or (row.action and "(same everywhere)") or "passes through"),
      })
    end
  end
  if #rows > 0 or app.catchall then
    add("### " .. app.name)
    add()
    if app.catchall then
      add("Every catch-all key: " .. cell(app.catchall) .. ".")
      add()
    end
    if #rows > 0 then
      table_of({ "Mac", "Key", "Action here", "Generic action" }, rows)
    end
  end
end

-- Opt-in keys ----------------------------------------------------------------

add("## Opt-in keys")
add()
add("Bound only when their condition holds, at the time the config loads.")
add()

local opt_in = {}
for _, row in ipairs(all_keys) do
  if row.condition then
    table.insert(opt_in, {
      glyph(row.mac),
      code(row.keys),
      cell(row.desc),
      cell(everywhere(row)),
      cell(row.condition),
    })
  end
end
table_of({ "Mac", "Key", "Description", "Action", "Condition" }, opt_in)

-- Relocated Omarchy binds ----------------------------------------------------

add("## Relocated Omarchy binds")
add()
add("Omarchy binds that collided with a Mac shortcut. They keep their action; only the key")
add("changed. A dropped bind is replaced by an OMacKey shortcut.")
add()

local relocated = {}
for _, row in ipairs(catalog.relocations()) do
  local from_glyph = keys.glyph(row.from)
  table.insert(relocated, {
    code(row.from),
    glyph(from_glyph),
    row.dropped and "dropped" or code(row.to),
    row.dropped and "" or glyph(keys.glyph(row.to)),
    cell(row.description or (row.optional and "(only if installed)" or "(not found in Omarchy)")),
  })
end
table_of({ "Omarchy key", "Was", "New key", "Now", "Description" }, relocated)

-- Settings -------------------------------------------------------------------

add("## Settings")
add()
add("Optional file `${XDG_CONFIG_HOME:-~/.config}/omackey/settings.lua`, returning a table of")
add("options to change. Nothing creates it. Reload Hyprland after editing.")
add()

local settings = {}
for _, setting in ipairs(catalog.settings()) do
  local default = mock.literal(setting.default)
  table.insert(settings, { code(setting.name), code(default), cell(setting.doc) })
end
table_of({ "Option", "Default", "Meaning" }, settings)

local text = table.concat(out, "\n"):gsub("\n+$", "\n")

-- Output ---------------------------------------------------------------------

local mode = arg[1]
if mode == "--stdout" then
  io.stdout:write(text)
elseif mode == "--check" then
  local file = real_open(target, "r")
  local current = file and file:read("a")
  if file then
    file:close()
  end
  if current ~= text then
    io.stderr:write("gen-docs: docs/KEYBINDINGS.md is out of date; run lua5.5 scripts/gen-docs.lua\n")
    os.exit(1)
  end
  io.stdout:write("✓ docs/KEYBINDINGS.md is up to date\n")
else
  local file = assert(real_open(target, "w"))
  file:write(text)
  file:close()
  io.stdout:write("gen-docs: wrote docs/KEYBINDINGS.md (" .. #all_keys .. " keys)\n")
end
