-- VS Code (class com.microsoft.VSCode here; the others for other installs).
-- Its Mac keybindings use ⌘ where the Linux ones use Ctrl, so most keys work
-- through the generic entries. These are the keys whose Linux chord differs
-- from the Mac's. Read from the installed workbench.desktop.main.js, Mac and
-- Linux keymaps compared (PLAN.md §9 F13, F15).
--
-- Hyprland sees one window for the editor and its integrated terminal, so
-- keys that would break the terminal use terminal-safe chords or pass (F12).

local app = require("hypr.omackey.lib.profiles").app
local bind = require("hypr.omackey.lib.bind")
local PASS, CONSUME = bind.PASS, bind.CONSUME
local tap = require("hypr.omackey.lib.send").tap

app({
  name = "vscode",
  classes = { "com.microsoft.VSCode", "code", "code-oss", "Code" },
  actions = {
    -- Editing
    -- Ctrl+Insert / Shift+Insert: VS Code's Linux copy / paste, which also work
    -- in the integrated terminal, where Ctrl+C is SIGINT and Ctrl+V a
    -- literal-next.
    ["copy"] = tap("CTRL", "Insert"),
    ["paste"] = tap("SHIFT", "Insert"),
    ["cancel"] = tap("CTRL", "period"), -- ⌘. is Quick Fix in VS Code
    -- Windows and tabs
    ["zoom-reset"] = tap("CTRL", "kp_0"), -- reset zoom is Ctrl+Numpad0, not Ctrl+0
    -- The Mac also zooms out on ⌘⇧-; on Linux Ctrl+Shift+- is Navigate Forward.
    ["zoom-out-shifted"] = tap("CTRL", "minus"),
    -- Browser keys with a VS Code meaning
    -- Ctrl+Shift+I is Format Document whenever the editor has focus, so DevTools
    -- would reformat the file instead (§9 F11).
    ["devtools"] = CONSUME,
    ["devtools-inspect"] = tap("ALT", "C"), -- ⌘⌥C: find widget, match case
    ["bookmark-manager"] = tap("CTRL + ALT", "B"), -- ⌘⌥B: toggle the secondary side bar
    -- Code editing
    -- Add cursor: Shift+Alt+Up is Linux's primary; Ctrl+Shift+Up its secondary.
    ["add-cursor-above"] = tap("CTRL + SHIFT", "Up"),
    ["add-cursor-below"] = tap("CTRL + SHIFT", "Down"),
    ["fold"] = tap("CTRL + SHIFT", "bracketleft"),
    ["unfold"] = tap("CTRL + SHIFT", "bracketright"),
    ["replace"] = tap("CTRL", "H"),
    ["shrink-selection"] = tap("SHIFT + ALT", "Left"),
    ["expand-selection"] = tap("SHIFT + ALT", "Right"),
    -- Mac ⌥⇧↑ / ⌥⇧↓ copy the line; on Linux the same physical chord adds a
    -- cursor, and the copy is Ctrl+Shift+Alt+Up / Down.
    ["copy-line-up"] = tap("CTRL + SHIFT + ALT", "Up"),
    ["copy-line-down"] = tap("CTRL + SHIFT + ALT", "Down"),
    ["block-comment"] = tap("CTRL + SHIFT", "A"), -- Shift+Alt+A on the Mac
    -- Find widget toggles: ⌘⌥ + letter on the Mac, Alt + letter on Linux.
    ["find-whole-word"] = tap("ALT", "W"),
    ["find-regex"] = tap("ALT", "R"),
    ["find-in-selection"] = tap("ALT", "L"),
    ["find-preserve-case"] = tap("ALT", "P"),
    -- Emacs keys
    -- ⌃D stays raw: the integrated terminal needs it (end of input).
    ["emacs-delete-right"] = PASS,
  },
})
