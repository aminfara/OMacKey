-- Phase 7a: the catch-all (PLAN.md §5). Every ⌘ / ⌘⇧ + letter or punctuation key
-- that no other module and no Omarchy default claimed sends Ctrl / Ctrl+Shift +
-- the same key, so a Mac shortcut that has no entry of its own still does what
-- it does on the Mac. Terminals consume them (D5).
--
-- Keep this module last in config.modules: it reads the registry and the keys
-- Omarchy registered (lib/relocate.lua), then fills the gaps. A key you rebind
-- in ~/.config/hypr/bindings.lua still wins, since that file loads later.

local bind = require("hypr.omackey.lib.bind")
local relocate = require("hypr.omackey.lib.relocate")
local tap = require("hypr.omackey.lib.send").tap

-- Key name → how a Mac keyboard labels it ({ name, glyph, name in descriptions }).
local keys = {
  { "a" }, { "b" }, { "c" }, { "d" }, { "e" }, { "f" }, { "g" }, { "h" }, { "i" }, { "j" }, { "k" }, { "l" }, { "m" },
  { "n" }, { "o" }, { "p" }, { "q" }, { "r" }, { "s" }, { "t" }, { "u" }, { "v" }, { "w" }, { "x" }, { "y" }, { "z" },
  { "minus", "-" }, { "equal", "=" }, { "bracketleft", "[" }, { "bracketright", "]" }, { "backslash", "\\" },
  { "semicolon", ";" }, { "apostrophe", "'" }, { "grave", "`" }, { "comma", "," }, { "period", "." },
  { "slash", "/" }, { "return", "⏎", "Return" },
}

-- Consumed everywhere: nothing is sent.
--   ⌘H, ⌘M: no hide or minimize on Omarchy (D13), and Ctrl+H / Ctrl+M are
--           browser history and Enter in a terminal.
--   ⌘⇧Q:    Ctrl+Shift+Q quits Chrome (Phase 5).
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

-- Chord string → { variant, key entry } for every key this module covers.
local covered = {}
for _, variant in ipairs(variants) do
  for _, entry in ipairs(keys) do
    covered[relocate.normalize(variant.keys .. " + " .. entry[1])] = { variant = variant, entry = entry }
  end
end

local taken = {}
for key in pairs(relocate.claimed) do
  taken[key] = true
end

-- A key another module claimed for some apps only (⌘K and ⌘D in terminals, ⌘Y in
-- browsers) has no action elsewhere, so the raw ⌘ chord would reach the app. Give
-- it the catch-all's default outside its own profiles.
for _, spec in ipairs(bind.registry) do
  local chord = relocate.normalize(spec.keys)
  taken[chord] = true

  local target = covered[chord]
  if target and spec.actions and spec.actions.default == nil then
    spec.actions.default = consumed[chord] and "consume" or tap(target.variant.ctrl, target.entry[1])
    if spec.actions.terminal == nil then
      spec.actions.terminal = "consume"
    end
  end
end

for _, variant in ipairs(variants) do
  for _, entry in ipairs(keys) do
    local name = entry[1]
    local label = entry[2] or name:upper()
    local chord = variant.keys .. " + " .. name

    if not taken[relocate.normalize(chord)] then
      local desc = variant.glyph .. label .. " sent as " .. variant.text .. (entry[3] or label)
      local default = tap(variant.ctrl, name)
      if consumed[relocate.normalize(chord)] then
        desc = variant.glyph .. label .. " not mapped"
        default = "consume"
      end

      bind.mac({
        id = "catchall-" .. variant.glyph .. name,
        category = "Catch-all",
        mac = variant.glyph .. label,
        keys = chord,
        desc = desc,
        actions = {
          default = default,
          terminal = "consume",
        },
      })
    end
  end
end
