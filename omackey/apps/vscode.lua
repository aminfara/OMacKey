-- VS Code (class com.microsoft.VSCode here; the others for other installs).
-- Shortcuts read from the installed workbench.desktop.main.js, Mac and Linux
-- keymaps compared (PLAN.md §9 F13, F15). Hyprland can't tell the editor from
-- its integrated terminal, so keys that would break the terminal pass or use
-- terminal-safe chords (F12).

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "vscode",
  classes = { "com.microsoft.VSCode", "code", "code-oss", "Code" },
  actions = {},
})
