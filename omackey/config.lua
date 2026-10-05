-- OMacKey settings. See PLAN.md for what each phase adds.

return {
  -- Feature modules loaded after Omarchy's defaults, in this order
  -- (omackey/<name>.lua). Each phase appends its module here.
  modules = {
    "spaces", -- Phase 1b: workspaces on ⌃ (vertical pair, move window)
    "text", -- Phase 2: cursor movement, selection, deletion
    "editing", -- Phase 3: clipboard, undo/redo, find, save
    "windows", -- Phase 4: window and tab controls
    "system", -- Phase 5: OS controls (lock, screenshots, emoji)
    "terminals", -- Phase 6a: terminal-only keys (clear, split)
    "browsers", -- Phase 6b: devtools, history, downloads, bookmarks
    "vscode", -- Phase 6c: multi-cursor, fold, replace, expand selection
  },

  -- How long a synthetic key stays down before its release is sent.
  -- Spike S2 tunes this (Omarchy uses 50 ms, the r/omarchy snippet 5 ms).
  release_ms = 20,

  -- App profiles, checked in order against the active window; the first match
  -- wins. When a binding has no action for a profile, its `family` is tried
  -- next, then "default". Tags are Omarchy's (default/hypr/apps/*.lua).
  profiles = {
    -- Terminals with keys of their own (Phase 6a). Each falls back to the
    -- generic "terminal" profile below, which also covers Alacritty, wezterm
    -- and Omarchy's TUI windows.
    { name = "ghostty", family = "terminal", classes = { "com.mitchellh.ghostty" } },
    { name = "kitty", family = "terminal", classes = { "kitty" } },
    { name = "foot", family = "terminal", classes = { "foot", "org.codeberg.dnkl.foot" } },
    { name = "terminal", tags = { "terminal" } },
    -- Firefox differs from the Chromium family in a few shortcuts (Phase 6b).
    { name = "firefox", family = "browser", tags = { "firefox-based-browser" } },
    {
      name = "browser",
      tags = { "chromium-based-browser", "firefox-based-browser" },
      -- Omarchy's browser tag regex does not cover Brave Origin.
      classes = { "brave-origin" },
    },
    -- VS Code (class com.microsoft.VSCode here; the others for other installs).
    { name = "vscode", classes = { "com.microsoft.VSCode", "code", "code-oss", "Code" } },
    -- Nautilus: Alt+Left/Right go back/forward, so ⌘[ / ⌘] (6d adds the rest).
    { name = "nautilus", classes = { "org.gnome.Nautilus" } },
    -- GUI apps where Ctrl+W doesn't close the window: ⌘W closes it instead.
    -- Add a window class here (hyprctl clients) when ⌘W does nothing.
    { name = "no-tabs", classes = {} },
  },
}
