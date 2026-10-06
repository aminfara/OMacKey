-- Ghostty. Shortcuts from `ghostty +list-keybinds --default` (Linux) and the
-- macOS defaults in Ghostty's src/config/Config.zig (PLAN.md §9 F10).
-- Everything not listed here falls back to apps/terminal.lua.

local app = require("hypr.omackey.lib.profiles").app
local tap = require("hypr.omackey.lib.send").tap

local actions = {
  -- Text navigation and deletion
  -- ⌘↑ / ⌘↓ jump to the previous / next prompt, as Ghostty does on the Mac
  -- (jump_to_prompt, "matches Terminal.app").
  ["document-start"] = tap("CTRL + SHIFT", "Page_Up"),
  ["document-end"] = tap("CTRL + SHIFT", "Page_Down"),
  -- Editing
  ["select-all"] = tap("CTRL + SHIFT", "A"),
  -- Scrollback search. ⌘G / ⌘⇧G stay consumed: they only mean something while
  -- a search is open, which Hyprland can't tell (§9 F10).
  ["find"] = tap("CTRL + SHIFT", "F"),
  -- Windows and tabs
  -- Close the tab (the last one closes the window); it also closes a whole tab
  -- of splits (§9 F10).
  ["close-tab"] = tap("CTRL + SHIFT", "W"),
  ["new-tab"] = tap("CTRL + SHIFT", "T"),
  ["previous-tab"] = tap("CTRL", "Page_Up"),
  ["next-tab"] = tap("CTRL", "Page_Down"),
  ["previous-tab-arrow"] = tap("CTRL", "Page_Up"),
  ["next-tab-arrow"] = tap("CTRL", "Page_Down"),
  -- Ghostty's own Ctrl+, runs xdg-open, which starts nvim without a terminal
  -- and shows nothing (§9 F10), so ⌘, opens the config in Omarchy's editor.
  ["preferences"] = function()
    hl.dispatch(hl.dsp.exec_cmd('omarchy-launch-editor "$HOME/.config/ghostty/config"'))
  end,
  -- Terminal
  ["split-right"] = tap("CTRL + SHIFT", "O"),
  ["split-down"] = tap("CTRL + SHIFT", "E"),
}

-- ⌘1–⌘9: tab N is Alt+N (Alt+9 is the last tab, as ⌘9 on the Mac).
for n = 1, 9 do
  actions["tab-" .. n] = tap("ALT", tostring(n))
end

app({
  name = "ghostty",
  family = "terminal",
  classes = { "com.mitchellh.ghostty" },
  actions = actions,
})
