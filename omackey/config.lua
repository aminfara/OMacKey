-- OMacKey settings.

return {
  -- Modules that declare the Mac shortcuts (omackey/<name>.lua), loaded in
  -- this order after Omarchy's defaults; they are bound in the same order.
  modules = {
    "spaces", -- workspaces on ⌃ (vertical pair, move window)
    "text", -- cursor movement, selection, deletion
    "editing", -- clipboard, undo/redo, find, save
    "windows", -- window and tab controls
    "system", -- OS controls (lock, screenshots, emoji)
    "terminals", -- terminal-only keys (clear, split)
    "browsers", -- devtools, history, downloads, bookmarks
    "vscode", -- multi-cursor, fold, replace, expand selection
    "nautilus", -- hidden files (other Nautilus keys sit on the keys they extend)
    "obsidian", -- redo selection (other Obsidian keys sit on the keys they extend)
    "libreoffice", -- paste special (other LibreOffice keys sit on the keys they extend)
    "mouse", -- ⌘-click and ⌘-scroll as Ctrl-click and Ctrl-scroll (scroll needs wtype)
    "emacs", -- Emacs ⌃ keys (bound only when emacs_keys is true)
    "catchall", -- every ⌘ / ⌘⇧ key nothing else claims
  },

  -- Emacs keys: Mac text-field editing keys on physical ⌃ — ⌃A / ⌃E line start /
  -- end, ⌃F / ⌃B / ⌃N / ⌃P arrows, ⌃D / ⌃H delete, ⌃K kill to line end. Terminals
  -- keep the raw key, and so does ⌃D in VS Code. They take ⌃A, ⌃F, ⌃H … away from
  -- GUI apps (select all, find, history): set this to false to get those back.
  -- The default is on at the user's request; reload after changing it.
  emacs_keys = true,

  -- How long a synthetic key stays down before its release is sent.
  -- (Omarchy uses 50 ms, the r/omarchy snippet 5 ms.)
  release_ms = 20,

  -- App profiles, checked in order against the active window; the first match
  -- wins. When a binding has no action for a profile, its `family` is tried
  -- next, then "default". Tags are Omarchy's (default/hypr/apps/*.lua).
  profiles = {
    -- Terminals with keys of their own. Each falls back to the
    -- generic "terminal" profile below, which also covers Alacritty, wezterm
    -- and Omarchy's TUI windows.
    { name = "ghostty", family = "terminal", classes = { "com.mitchellh.ghostty" } },
    { name = "kitty", family = "terminal", classes = { "kitty" } },
    { name = "foot", family = "terminal", classes = { "foot", "org.codeberg.dnkl.foot" } },
    { name = "terminal", tags = { "terminal" } },
    -- Firefox differs from the Chromium family in a few shortcuts.
    { name = "firefox", family = "browser", tags = { "firefox-based-browser" } },
    {
      name = "browser",
      tags = { "chromium-based-browser", "firefox-based-browser" },
      -- Omarchy's browser tag regex does not cover Brave Origin.
      classes = { "brave-origin" },
    },
    -- VS Code (class com.microsoft.VSCode here; the others for other installs).
    { name = "vscode", classes = { "com.microsoft.VSCode", "code", "code-oss", "Code" } },
    -- LibreOffice: F3 is AutoText, Redo / Options / Paste Special use other keys.
    {
      name = "libreoffice",
      classes = {
        "libreoffice-writer", "libreoffice-calc", "libreoffice-impress", "libreoffice-draw",
        "libreoffice-math", "libreoffice-base", "libreoffice-startcenter", "soffice",
      },
    },
    -- Obsidian (class md.obsidian.Obsidian here): keys that differ from the Mac's.
    { name = "obsidian", classes = { "md.obsidian.Obsidian", "obsidian" } },
    -- Nautilus (Files): keys that differ from Finder's get an entry of their own.
    { name = "nautilus", classes = { "org.gnome.Nautilus" } },
    -- GUI apps where Ctrl+W doesn't close the window: ⌘W closes it instead.
    -- Add a window class here (hyprctl clients) when ⌘W does nothing.
    { name = "no-tabs", classes = {} },
  },
}
