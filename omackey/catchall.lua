-- The catch-all (PLAN.md §5). Every ⌘ / ⌘⇧ + letter, punctuation or Return key
-- that no other spec and no Omarchy default claims sends Ctrl / Ctrl+Shift +
-- the same key, so a Mac shortcut that has no entry of its own still does what
-- it does on the Mac. Terminals consume them (D5).
--
-- This only declares a spec for every chord it covers; lib/bind.lua keeps the
-- ones nobody else claimed once everything is declared, so the module's
-- position in the manifest (init.lua) doesn't matter. A key you rebind in
-- ~/.config/hypr/bindings.lua still wins, since that file loads later.

local bind = require("hypr.omackey.lib.bind")
local keys = require("hypr.omackey.lib.keys")
local tap = require("hypr.omackey.lib.send").tap
local CONSUME = bind.CONSUME

-- The keys covered, in key-table order: A–Z, the punctuation keys, Return.
local covered_keys = {}
for _, key in ipairs(keys.list) do
  if key.kind == "letter" or key.kind == "punctuation" or key.name == "return" then
    table.insert(covered_keys, key)
  end
end

-- Consumed everywhere: nothing is sent.
--   ⌘H, ⌘M: no hide or minimize on Omarchy (D13), and Ctrl+H / Ctrl+M are
--           browser history and Enter in a terminal.
--   ⌘⇧Q:    Ctrl+Shift+Q quits Chrome.
--   ⌘⇧I:    Ctrl+Shift+I is Format Document in VS Code; DevTools has ⌘⌥I.
--   ⌘⇧U:    Ctrl+Shift+U starts Unicode input in GTK and fcitx5.
--   ⌘⇧H:    Ctrl+Shift+H is not Chrome's home page (user's choice).
local consumed = {
  ["SUPER + h"] = true,
  ["SUPER + m"] = true,
  ["SUPER + SHIFT + q"] = true,
  ["SUPER + SHIFT + i"] = true,
  ["SUPER + SHIFT + u"] = true,
  ["SUPER + SHIFT + h"] = true,
}

local variants = {
  { keys = "SUPER", ctrl = "CTRL", glyph = "⌘", text = "Ctrl+" },
  { keys = "SUPER + SHIFT", ctrl = "CTRL + SHIFT", glyph = "⌘⇧", text = "Ctrl+Shift+" },
}

local specs = {}
for _, variant in ipairs(variants) do
  for _, key in ipairs(covered_keys) do
    local name = key.name
    local chord = variant.keys .. " + " .. name

    local desc = variant.glyph .. key.glyph .. " sent as " .. variant.text .. key.label
    local default = tap(variant.ctrl, name)
    if consumed[keys.normalize(chord)] then
      desc = variant.glyph .. key.glyph .. " not mapped"
      default = CONSUME
    end

    table.insert(specs, {
      id = "catchall-" .. variant.glyph .. name,
      category = "Catch-all",
      mac = variant.glyph .. key.glyph,
      keys = chord,
      desc = desc,
      actions = {
        default = default,
      },
    })
  end
end

bind.catchall(specs)
