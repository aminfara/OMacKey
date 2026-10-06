-- Fake windows for the snapshot harness. Written independently of OMacKey's
-- app profiles, so matching a window to its profile is under test too. Tags
-- are in the form Hyprland reports them: dynamic tags end in "*".

local M = {}

local TERMINAL = { "default-opacity*", "terminal*" }
local CHROMIUM = { "chromium-based-browser*" }
local FIREFOX = { "firefox-based-browser*" }
local PLAIN = { "default-opacity*" }

-- One window per case the binds are pressed in, in output order. `false`
-- stands for "no active window".
M.apps = {
  { "none" },
  { "empty-class", "" },
  { "keylog", "omackey.keylog", PLAIN },
  { "foot", "foot", TERMINAL },
  { "foot-alt", "org.codeberg.dnkl.foot", TERMINAL },
  { "ghostty", "com.mitchellh.ghostty", TERMINAL },
  { "kitty", "kitty", TERMINAL },
  { "alacritty", "Alacritty", TERMINAL },
  { "omarchy-tui", "org.omarchy.btop", TERMINAL },
  { "brave-origin", "brave-origin", PLAIN },
  { "chromium", "chromium", CHROMIUM },
  { "google-chrome", "google-chrome", CHROMIUM },
  { "firefox", "firefox", FIREFOX },
  { "vscode", "com.microsoft.VSCode", PLAIN },
  { "code-oss", "code-oss", PLAIN },
  { "obsidian", "md.obsidian.Obsidian", PLAIN },
  { "nautilus", "org.gnome.Nautilus", PLAIN },
  { "libreoffice", "libreoffice-writer", PLAIN },
  { "soffice", "soffice", PLAIN },
  { "webapp", "chrome-github.com__-Default", PLAIN },
}

local next_id = 0

-- A window table shaped like HL.Window, with the fields OMacKey reads.
function M.window(label, class, tags, fields)
  next_id = next_id + 1
  local window = {
    __window = true,
    label = label,
    address = string.format("0x%04x", next_id),
    class = class,
    initial_class = class,
    title = label,
    tags = tags or {},
    pid = 1000 + next_id,
    stable_id = next_id,
    focus_history_id = 0,
    workspace = { id = 1, name = "1", special = false },
    hidden = false,
    floating = false,
    fullscreen = false,
    mapped = true,
  }
  for key, value in pairs(fields or {}) do
    window[key] = value
  end
  return window
end

function M.workspace(id, special)
  if special then
    return { id = -98, name = "special:" .. id, special = true }
  end
  return { id = id, name = tostring(id), special = false }
end

-- The fixture's window, or nil for "none".
function M.app_window(app)
  if not app[2] then
    return nil
  end
  return M.window(app[1], app[2], app[3])
end

return M
