-- Entry points called from ~/.config/hypr/hyprland.lua (lines added by
-- install.sh):
--
--   pre()  right before require("default.hypr.omarchy"): start relocating
--   init() right after it: stop relocating, add the Mac bindings
--
-- Each stage is guarded, so an OMacKey error is reported as a notification
-- and Omarchy's defaults and the user's own config still load. Nothing is
-- printed: Omarchy's keybindings menu replays this config and parses stdout.

local M = {}

-- Global for introspection: hyprctl repl 'return omackey.status()'
-- (lib/introspect.lua defines its functions).
omackey = omackey or { errors = {} }

local function report(stage, err)
  local message = "OMacKey " .. stage .. " failed: " .. tostring(err)
  table.insert(omackey.errors, message)
  pcall(hl.notification.create, { text = message, timeout = 15000 })
end

local function guarded(stage, fn)
  local ok, err = pcall(fn)
  if not ok then
    report(stage, err)
  end
end

-- Loading is declare, build, bind (lib/bind.lua): the stages below declare
-- shortcuts and apps, then bind_declared() builds and binds them in one pass.

-- The Mac-mode switch (lib/mode.lua) is a state file, read once per load by
-- whichever stage asks first. If the check itself fails, OMacKey stays on.
local mode_on
local function enabled()
  if mode_on == nil then
    local ok, on = pcall(function()
      return require("hypr.omackey.lib.mode").enabled()
    end)
    mode_on = not ok or on
  end
  return mode_on
end

-- Validates and binds everything declared so far. Configuration errors go to
-- omackey.status() and one notification; the valid shortcuts are bound anyway.
local function bind_declared()
  local bind = require("hypr.omackey.lib.bind")
  local errors = bind.build()

  if #errors > 0 then
    for _, message in ipairs(errors) do
      table.insert(omackey.errors, "OMacKey config: " .. message)
    end
    pcall(hl.notification.create, {
      text = "OMacKey: " .. #errors .. " config error(s), see omackey.status(): " .. errors[1],
      timeout = 15000,
    })
  end

  bind.apply()
end

-- The toggle is declared in both modes, last, so it is the only shortcut
-- there is while OMacKey is off.
local function bind_toggle()
  guarded("mode", function()
    require("hypr.omackey.lib.mode").declare()
  end)
  guarded("bind", bind_declared)
end

function M.pre()
  if not enabled() then
    return
  end

  guarded("pre", function()
    require("hypr.omackey.lib.relocate").hook()
  end)
end

function M.init()
  if not enabled() then
    omackey.off = true
    bind_toggle()
    return
  end

  guarded("unhook", function()
    require("hypr.omackey.lib.relocate").unhook()
  end)

  guarded("init", function()
    require("hypr.omackey.init")
  end)

  bind_toggle()

  -- ⌘Tab's recency list follows focus changes from now on.
  guarded("switcher", function()
    require("hypr.omackey.lib.switcher").start()
  end)
end

guarded("introspect", function()
  require("hypr.omackey.lib.introspect").install(omackey)
end)

return M
