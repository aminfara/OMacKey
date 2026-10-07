# OMacKey — Keybindings

Generated from the code by `scripts/gen-docs.lua`: do not edit by hand. Run
`lua5.5 scripts/gen-docs.lua` after changing a shortcut, an app or a relocation.

- ⌘ = `SUPER`, ⌥ = `ALT`, ⌃ = `CTRL`, ⇧ = `SHIFT`. Glyphs are in Apple's order (`⇧⌘[`).
- The **Key** column is the exact string for `hl.unbind("…")` in
  `~/.config/hypr/bindings.lua`, which switches that shortcut off (case-sensitive).
- A key with no action in the app you are using passes through to the app unchanged.
- What is not mapped, and why: [LIMITATIONS.md](LIMITATIONS.md). The modifier model:
  [ARCHITECTURE.md](ARCHITECTURE.md) §2.

Contents: [Shortcuts](#shortcuts) · [Per-app actions](#per-app-actions) ·
[Opt-in keys](#opt-in-keys) · [Relocated Omarchy binds](#relocated-omarchy-binds) ·
[Settings](#settings)

## Shortcuts

**Action** is what the key does in a generic app. **Differs in** lists the apps that do
something else (see [Per-app actions](#per-app-actions)).

### Text

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘← | `SUPER + LEFT` | Line start | Home |  | repeats |
| ⌘→ | `SUPER + RIGHT` | Line end | End |  | repeats |
| ⇧⌘← | `SUPER + SHIFT + LEFT` | Select to line start | Shift+Home | terminal | repeats |
| ⇧⌘→ | `SUPER + SHIFT + RIGHT` | Select to line end | Shift+End | terminal | repeats |
| ⌥← | `ALT + LEFT` | Word left | Ctrl+Left |  | repeats |
| ⌥→ | `ALT + RIGHT` | Word right | Ctrl+Right |  | repeats |
| ⌥⇧← | `ALT + SHIFT + LEFT` | Select word left | Ctrl+Shift+Left | terminal | repeats |
| ⌥⇧→ | `ALT + SHIFT + RIGHT` | Select word right | Ctrl+Shift+Right | terminal | repeats |
| ⌘↑ | `SUPER + UP` | Document start | Ctrl+Home | ghostty, kitty, nautilus, terminal | repeats |
| ⌘↓ | `SUPER + DOWN` | Document end | Ctrl+End | ghostty, kitty, nautilus, terminal | repeats |
| ⇧⌘↑ | `SUPER + SHIFT + UP` | Select to document start | Ctrl+Shift+Home | terminal | repeats |
| ⇧⌘↓ | `SUPER + SHIFT + DOWN` | Select to document end | Ctrl+Shift+End | terminal | repeats |
| ⌥⌫ | `ALT + BACKSPACE` | Delete word left | Ctrl+Backspace | terminal | repeats |
| ⌥⌦ | `ALT + DELETE` | Delete word right | Ctrl+Delete | terminal | repeats |
| ⌘⌫ | `SUPER + BACKSPACE` | Delete to line start | Shift+Home, then Backspace | nautilus, terminal | repeats |
| ⌘⌦ | `SUPER + DELETE` | Delete to line end | Shift+End, then Delete | terminal | repeats |

### Editing

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘C | `SUPER + C` | Copy | Ctrl+C | terminal, vscode |  |
| ⌘V | `SUPER + V` | Paste | Ctrl+V | terminal, vscode |  |
| ⌘X | `SUPER + X` | Cut | Ctrl+X | terminal |  |
| ⇧⌘V | `SUPER + SHIFT + V` | Paste without formatting | Ctrl+Shift+V | libreoffice, terminal |  |
| ⌥⌘V | `SUPER + ALT + V` | Paste special (LibreOffice) | The key reaches the app unchanged | libreoffice |  |
| ⌘Z | `SUPER + Z` | Undo | Ctrl+Z | terminal | repeats |
| ⇧⌘Z | `SUPER + SHIFT + Z` | Redo | Ctrl+Shift+Z | terminal | repeats |
| ⇧⌘U | `SUPER + SHIFT + U` | Redo selection (Obsidian) | Nothing: the key does nothing | obsidian, terminal |  |
| ⌘A | `SUPER + A` | Select all | Ctrl+A | ghostty, terminal |  |
| ⌘S | `SUPER + S` | Save | Ctrl+S | terminal |  |
| ⇧⌘S | `SUPER + SHIFT + S` | Save as | Ctrl+Shift+S | terminal |  |
| ⌘B | `SUPER + B` | Bold | Ctrl+B | terminal |  |
| ⌘I | `SUPER + I` | Italic | Ctrl+I | terminal |  |
| ⌘U | `SUPER + U` | Underline | Ctrl+U | terminal |  |
| ⌘. | `SUPER + period` | Cancel (Escape) | Esc | terminal, vscode |  |

### Find

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘F | `SUPER + F` | Find | Ctrl+F | foot, ghostty, kitty, terminal |  |
| ⌘G | `SUPER + G` | Find next | F3 | libreoffice, terminal | repeats |
| ⇧⌘G | `SUPER + SHIFT + G` | Find previous | Shift+F3 | libreoffice, nautilus, terminal | repeats |
| ⌥⌘F | `SUPER + ALT + F` | Replace | The key reaches the app unchanged | obsidian, vscode |  |
| ⌥⌘W | `SUPER + ALT + W` | Find: match whole word | The key reaches the app unchanged | vscode |  |
| ⌥⌘R | `SUPER + ALT + R` | Find: use regular expression | The key reaches the app unchanged | vscode |  |
| ⌥⌘L | `SUPER + ALT + L` | Find: in selection | The key reaches the app unchanged | vscode |  |
| ⌥⌘P | `SUPER + ALT + P` | Replace: preserve case | The key reaches the app unchanged | vscode |  |

### Code editing

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘/ | `SUPER + slash` | Toggle comment | Ctrl+/ | terminal |  |
| ⌥⇧A | `ALT + SHIFT + A` | Toggle block comment | The key reaches the app unchanged | vscode |  |
| ⌥⌘↑ | `SUPER + ALT + UP` | Add cursor above | The key reaches the app unchanged | obsidian, vscode | repeats |
| ⌥⌘↓ | `SUPER + ALT + DOWN` | Add cursor below | The key reaches the app unchanged | obsidian, vscode | repeats |
| ⌥⇧↑ | `ALT + SHIFT + UP` | Copy line up | The key reaches the app unchanged | vscode | repeats |
| ⌥⇧↓ | `ALT + SHIFT + DOWN` | Copy line down | The key reaches the app unchanged | vscode | repeats |
| ⌥⌘[ | `SUPER + ALT + bracketleft` | Fold code | The key reaches the app unchanged | vscode |  |
| ⌥⌘] | `SUPER + ALT + bracketright` | Unfold code | The key reaches the app unchanged | vscode |  |
| ⌃⇧⌘← | `SUPER + CTRL + SHIFT + LEFT` | Shrink selection | The key reaches the app unchanged | vscode | repeats |
| ⌃⇧⌘→ | `SUPER + CTRL + SHIFT + RIGHT` | Expand selection | The key reaches the app unchanged | vscode | repeats |

### Tabs

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘T | `SUPER + T` | New tab | Ctrl+T | ghostty, kitty, terminal |  |
| ⇧⌘T | `SUPER + SHIFT + T` | Reopen closed tab | Ctrl+Shift+T | terminal |  |
| ⌘W | `SUPER + W` | Close tab or window | Ctrl+W | ghostty, kitty, no-tabs, terminal |  |
| ⌘1 | `SUPER + code:10` | Go to tab 1 | Ctrl+1 | ghostty, nautilus, terminal |  |
| ⌘2 | `SUPER + code:11` | Go to tab 2 | Ctrl+2 | ghostty, nautilus, terminal |  |
| ⌘3 | `SUPER + code:12` | Go to tab 3 | Ctrl+3 | ghostty, nautilus, terminal |  |
| ⌘4 | `SUPER + code:13` | Go to tab 4 | Ctrl+4 | ghostty, nautilus, terminal |  |
| ⌘5 | `SUPER + code:14` | Go to tab 5 | Ctrl+5 | ghostty, nautilus, terminal |  |
| ⌘6 | `SUPER + code:15` | Go to tab 6 | Ctrl+6 | ghostty, nautilus, terminal |  |
| ⌘7 | `SUPER + code:16` | Go to tab 7 | Ctrl+7 | ghostty, nautilus, terminal |  |
| ⌘8 | `SUPER + code:17` | Go to tab 8 | Ctrl+8 | ghostty, nautilus, terminal |  |
| ⌘9 | `SUPER + code:18` | Go to tab 9 | Ctrl+9 | ghostty, nautilus, terminal |  |
| ⇧⌘[ | `SUPER + SHIFT + bracketleft` | Previous tab | Ctrl+Page Up | ghostty, kitty, terminal |  |
| ⇧⌘] | `SUPER + SHIFT + bracketright` | Next tab | Ctrl+Page Down | ghostty, kitty, terminal |  |
| ⌥⌘← | `SUPER + ALT + LEFT` | Previous tab | Ctrl+Page Up | ghostty, kitty, obsidian, terminal |  |
| ⌥⌘→ | `SUPER + ALT + RIGHT` | Next tab | Ctrl+Page Down | ghostty, kitty, obsidian, terminal |  |

### Windows and apps

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘N | `SUPER + N` | New window | Ctrl+N | terminal |  |
| ⇧⌘N | `SUPER + SHIFT + N` | New private window or folder | Ctrl+Shift+N | firefox, terminal |  |
| ⇧⌘W | `SUPER + SHIFT + W` | Close window | Close the window |  |  |
| ⌘Q | `SUPER + Q` | Quit app (close all its windows) | Close every window of the app |  |  |
| ⌘⇥ | `SUPER + TAB` | Switch app | Switch to the next app, most recently used first |  |  |
| ⇧⌘⇥ | `SUPER + SHIFT + TAB` | Switch app backwards | Switch to the previous app in the recency list |  |  |
| ⌘\` | `SUPER + grave` | Next window of this app | Focus the next window of the app |  |  |
| ⇧⌘\` | `SUPER + SHIFT + grave` | Previous window of this app | Focus the previous window of the app |  |  |

### Navigation

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘O | `SUPER + O` | Open | Ctrl+O | terminal |  |
| ⌘P | `SUPER + P` | Print or quick open | Ctrl+P | terminal |  |
| ⌘R | `SUPER + R` | Reload | Ctrl+R | terminal |  |
| ⌘L | `SUPER + L` | Focus address bar | Ctrl+L | terminal |  |
| ⌘[ | `SUPER + bracketleft` | Back or outdent | Ctrl+[ | browser, nautilus, terminal |  |
| ⌘] | `SUPER + bracketright` | Forward or indent | Ctrl+] | browser, nautilus, terminal |  |
| ⌘, | `SUPER + comma` | Preferences | Ctrl+, | firefox, ghostty, kitty, libreoffice, terminal |  |
| ⌘Y | `SUPER + Y` | History | Ctrl+Y | browser, terminal |  |
| ⇧⌘J | `SUPER + SHIFT + J` | Downloads | Ctrl+Shift+J | browser, firefox, terminal |  |
| ⌥⌘B | `SUPER + ALT + B` | Bookmark manager | The key reaches the app unchanged | browser, vscode |  |
| ⇧⌘⌫ | `SUPER + SHIFT + BACKSPACE` | Clear browsing data | The key reaches the app unchanged | browser |  |

### View

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘= | `SUPER + equal` | Zoom in (app) | Ctrl+= | kitty |  |
| ⇧⌘= | `SUPER + SHIFT + equal` | Zoom in (app) | Ctrl+= | kitty |  |
| ⌘- | `SUPER + minus` | Zoom out (app) | Ctrl+- | kitty |  |
| ⇧⌘- | `SUPER + SHIFT + minus` | Zoom out (VS Code) | Ctrl+Shift+- | terminal, vscode |  |
| ⌘0 | `SUPER + code:19` | Actual size (app zoom) | Ctrl+0 | kitty, vscode |  |
| ⇧⌘. | `SUPER + SHIFT + period` | Show hidden files (Files) | Ctrl+Shift+. | nautilus, terminal |  |

### Developer tools

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌥⌘I | `SUPER + ALT + I` | Developer tools | Ctrl+Shift+I | terminal, vscode |  |
| ⌥⌘J | `SUPER + ALT + J` | Developer console | The key reaches the app unchanged | browser |  |
| ⌥⌘C | `SUPER + ALT + C` | Inspect element | The key reaches the app unchanged | browser, vscode |  |
| ⌥⌘U | `SUPER + ALT + U` | View page source | The key reaches the app unchanged | browser |  |

### Terminal

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘K | `SUPER + K` | Clear terminal screen | Ctrl+K | terminal |  |
| ⌘D | `SUPER + D` | Split terminal right | Ctrl+D | ghostty, terminal |  |
| ⇧⌘D | `SUPER + SHIFT + D` | Split terminal down | Ctrl+Shift+D | ghostty, terminal |  |

### Spaces

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌃⌥↑ | `CTRL + ALT + UP` | Previous workspace | Focus the previous workspace |  |  |
| ⌃⌥↓ | `CTRL + ALT + DOWN` | Next workspace | Focus the next workspace |  |  |
| ⌃⌥⇧← | `CTRL + ALT + SHIFT + LEFT` | Move window to previous workspace | Move the window to the previous workspace |  |  |
| ⌃⌥⇧↑ | `CTRL + ALT + SHIFT + UP` | Move window to previous workspace | Move the window to the previous workspace |  |  |
| ⌃⌥⇧→ | `CTRL + ALT + SHIFT + RIGHT` | Move window to next workspace | Move the window to the next workspace |  |  |
| ⌃⌥⇧↓ | `CTRL + ALT + SHIFT + DOWN` | Move window to next workspace | Move the window to the next workspace |  |  |

### System

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌃⌘Q | `SUPER + CTRL + Q` | Lock screen | Lock the screen |  |  |
| ⇧⌘3 | `SUPER + SHIFT + code:12` | Screenshot of the screen to file | Save a screenshot of the screen to a file |  |  |
| ⌃⇧⌘3 | `SUPER + CTRL + SHIFT + code:12` | Screenshot of the screen to clipboard | Copy a screenshot of the screen to the clipboard |  |  |
| ⇧⌘4 | `SUPER + SHIFT + code:13` | Screenshot of a region to file | Save a screenshot of a region to a file |  |  |
| ⌃⇧⌘4 | `SUPER + CTRL + SHIFT + code:13` | Screenshot of a region to clipboard | Copy a screenshot of a region to the clipboard |  |  |
| ⇧⌘5 | `SUPER + SHIFT + code:14` | Capture menu | Open Omarchy's capture menu |  |  |
| ⌥⌘Esc | `SUPER + ALT + ESCAPE` | Force quit the active window | Kill the window's process |  |  |
| ⌃⌘Space | `SUPER + CTRL + SPACE` | Emoji and symbols | Open the emoji picker |  |  |
| ⌥⌘D | `SUPER + ALT + D` | Toggle top bar (Dock) | Show or hide the status bar |  |  |
| F6 | `XF86DoNotDisturb` | Toggle silencing notifications (Do Not Disturb) | Silence or restore notifications |  |  |
| ⌃⇧⌘M | `SUPER + CTRL + SHIFT + M` | OMacKey on/off (Mac mode) | Switch OMacKey on or off, then reload the config |  |  |

### Mouse

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘-click | `SUPER + mouse:272` | ⌘-click sent as Ctrl-click | Left click with Ctrl held instead of ⌘ |  |  |
| ⇧⌘-click | `SUPER + SHIFT + mouse:272` | ⇧⌘-click sent as Ctrl+Shift-click | Left click with Ctrl+Shift held instead of ⌘ |  |  |
| ⌘-click release | `SUPER + mouse:272` | ⌘-click release | End the synthetic click; any other release passes through |  | on release |
| ⇧⌘-click release | `SUPER + SHIFT + mouse:272` | ⇧⌘-click release | End the synthetic click; any other release passes through |  | on release |
| click release after ⌘ | `mouse:272` | Click release after ⌘ was let go | End the synthetic click; any other release passes through |  | on release |
| click release after ⌘ with ⇧ | `SHIFT + mouse:272` | Click release after ⌘ was let go (⇧ held) | End the synthetic click; any other release passes through |  | on release |

### Catch-all

Every ⌘ or ⇧⌘ chord that nothing else claims is sent as Ctrl or Ctrl+Shift with the
same key. A few are deliberately not mapped (see [LIMITATIONS.md](LIMITATIONS.md)).

| Mac | Key | Description | Action | Differs in | Flags |
| --- | --- | --- | --- | --- | --- |
| ⌘E | `SUPER + E` | ⌘E sent as Ctrl+E | Ctrl+E | terminal |  |
| ⌘H | `SUPER + H` | ⌘H not mapped | Nothing: the key does nothing | terminal |  |
| ⌘J | `SUPER + J` | ⌘J sent as Ctrl+J | Ctrl+J | terminal |  |
| ⌘M | `SUPER + M` | ⌘M not mapped | Nothing: the key does nothing | terminal |  |
| ⌘\ | `SUPER + backslash` | ⌘\ sent as Ctrl+\ | Ctrl+\ | terminal |  |
| ⌘; | `SUPER + semicolon` | ⌘; sent as Ctrl+; | Ctrl+; | terminal |  |
| ⌘' | `SUPER + apostrophe` | ⌘' sent as Ctrl+' | Ctrl+' | terminal |  |
| ⌘⏎ | `SUPER + RETURN` | ⌘⏎ sent as Ctrl+Return | Ctrl+Return | terminal |  |
| ⇧⌘A | `SUPER + SHIFT + A` | ⇧⌘A sent as Ctrl+Shift+A | Ctrl+Shift+A | terminal |  |
| ⇧⌘B | `SUPER + SHIFT + B` | ⇧⌘B sent as Ctrl+Shift+B | Ctrl+Shift+B | terminal |  |
| ⇧⌘C | `SUPER + SHIFT + C` | ⇧⌘C sent as Ctrl+Shift+C | Ctrl+Shift+C | terminal |  |
| ⇧⌘E | `SUPER + SHIFT + E` | ⇧⌘E sent as Ctrl+Shift+E | Ctrl+Shift+E | terminal |  |
| ⇧⌘F | `SUPER + SHIFT + F` | ⇧⌘F sent as Ctrl+Shift+F | Ctrl+Shift+F | terminal |  |
| ⇧⌘H | `SUPER + SHIFT + H` | ⇧⌘H not mapped | Nothing: the key does nothing | terminal |  |
| ⇧⌘I | `SUPER + SHIFT + I` | ⇧⌘I not mapped | Nothing: the key does nothing | terminal |  |
| ⇧⌘K | `SUPER + SHIFT + K` | ⇧⌘K sent as Ctrl+Shift+K | Ctrl+Shift+K | terminal |  |
| ⇧⌘L | `SUPER + SHIFT + L` | ⇧⌘L sent as Ctrl+Shift+L | Ctrl+Shift+L | terminal |  |
| ⇧⌘M | `SUPER + SHIFT + M` | ⇧⌘M sent as Ctrl+Shift+M | Ctrl+Shift+M | terminal |  |
| ⇧⌘O | `SUPER + SHIFT + O` | ⇧⌘O sent as Ctrl+Shift+O | Ctrl+Shift+O | terminal |  |
| ⇧⌘P | `SUPER + SHIFT + P` | ⇧⌘P sent as Ctrl+Shift+P | Ctrl+Shift+P | terminal |  |
| ⇧⌘Q | `SUPER + SHIFT + Q` | ⇧⌘Q not mapped | Nothing: the key does nothing | terminal |  |
| ⇧⌘R | `SUPER + SHIFT + R` | ⇧⌘R sent as Ctrl+Shift+R | Ctrl+Shift+R | terminal |  |
| ⇧⌘X | `SUPER + SHIFT + X` | ⇧⌘X sent as Ctrl+Shift+X | Ctrl+Shift+X | terminal |  |
| ⇧⌘Y | `SUPER + SHIFT + Y` | ⇧⌘Y sent as Ctrl+Shift+Y | Ctrl+Shift+Y | terminal |  |
| ⇧⌘\ | `SUPER + SHIFT + backslash` | ⇧⌘\ sent as Ctrl+Shift+\ | Ctrl+Shift+\ | terminal |  |
| ⇧⌘; | `SUPER + SHIFT + semicolon` | ⇧⌘; sent as Ctrl+Shift+; | Ctrl+Shift+; | terminal |  |
| ⇧⌘' | `SUPER + SHIFT + apostrophe` | ⇧⌘' sent as Ctrl+Shift+' | Ctrl+Shift+' | terminal |  |
| ⇧⌘⏎ | `SUPER + SHIFT + RETURN` | ⇧⌘⏎ sent as Ctrl+Shift+Return | Ctrl+Shift+Return | terminal |  |

## Per-app actions

Apps are matched in this order; the first whose class or tag matches the active window
wins, then its family, then the generic action. An app entry replaces the generic action
for that key only.

| App | Family | Matches |
| --- | --- | --- |
| ghostty | terminal | class `com.mitchellh.ghostty` |
| kitty | terminal | class `kitty` |
| foot | terminal | class `foot`, class `org.codeberg.dnkl.foot` |
| terminal |  | tag `terminal` |
| firefox | browser | tag `firefox-based-browser` |
| browser |  | class `brave-origin`, tag `chromium-based-browser`, tag `firefox-based-browser` |
| vscode |  | class `com.microsoft.VSCode`, class `code`, class `code-oss`, class `Code` |
| libreoffice |  | class `libreoffice-writer`, class `libreoffice-calc`, class `libreoffice-impress`, class `libreoffice-draw`, class `libreoffice-math`, class `libreoffice-base`, class `libreoffice-startcenter`, class `soffice` |
| obsidian |  | class `md.obsidian.Obsidian`, class `obsidian` |
| nautilus |  | class `org.gnome.Nautilus` |
| no-tabs |  | set by a setting (`close_window_classes`) |

### ghostty

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⌘↑ | `SUPER + UP` | Ctrl+Shift+Page Up | Ctrl+Home |
| ⌘↓ | `SUPER + DOWN` | Ctrl+Shift+Page Down | Ctrl+End |
| ⌘A | `SUPER + A` | Ctrl+Shift+A | Ctrl+A |
| ⌘F | `SUPER + F` | Ctrl+Shift+F | Ctrl+F |
| ⌘T | `SUPER + T` | Ctrl+Shift+T | Ctrl+T |
| ⌘W | `SUPER + W` | Ctrl+Shift+W | Ctrl+W |
| ⌘1 | `SUPER + code:10` | Alt+1 | Ctrl+1 |
| ⌘2 | `SUPER + code:11` | Alt+2 | Ctrl+2 |
| ⌘3 | `SUPER + code:12` | Alt+3 | Ctrl+3 |
| ⌘4 | `SUPER + code:13` | Alt+4 | Ctrl+4 |
| ⌘5 | `SUPER + code:14` | Alt+5 | Ctrl+5 |
| ⌘6 | `SUPER + code:15` | Alt+6 | Ctrl+6 |
| ⌘7 | `SUPER + code:16` | Alt+7 | Ctrl+7 |
| ⌘8 | `SUPER + code:17` | Alt+8 | Ctrl+8 |
| ⌘9 | `SUPER + code:18` | Alt+9 | Ctrl+9 |
| ⇧⌘[ | `SUPER + SHIFT + bracketleft` | Ctrl+Page Up | Ctrl+Page Up |
| ⇧⌘] | `SUPER + SHIFT + bracketright` | Ctrl+Page Down | Ctrl+Page Down |
| ⌥⌘← | `SUPER + ALT + LEFT` | Ctrl+Page Up | Ctrl+Page Up |
| ⌥⌘→ | `SUPER + ALT + RIGHT` | Ctrl+Page Down | Ctrl+Page Down |
| ⌘, | `SUPER + comma` | Open Ghostty's config file in Omarchy's editor | Ctrl+, |
| ⌘D | `SUPER + D` | Ctrl+Shift+O | Ctrl+D |
| ⇧⌘D | `SUPER + SHIFT + D` | Ctrl+Shift+E | Ctrl+Shift+D |

### kitty

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⌘↑ | `SUPER + UP` | Ctrl+Shift+Page Up | Ctrl+Home |
| ⌘↓ | `SUPER + DOWN` | Ctrl+Shift+Page Down | Ctrl+End |
| ⌘F | `SUPER + F` | Ctrl+Shift+/ | Ctrl+F |
| ⌘T | `SUPER + T` | Ctrl+Shift+T | Ctrl+T |
| ⌘W | `SUPER + W` | Ctrl+Shift+W | Ctrl+W |
| ⇧⌘[ | `SUPER + SHIFT + bracketleft` | Ctrl+Shift+Left | Ctrl+Page Up |
| ⇧⌘] | `SUPER + SHIFT + bracketright` | Ctrl+Shift+Right | Ctrl+Page Down |
| ⌥⌘← | `SUPER + ALT + LEFT` | Ctrl+Shift+Left | Ctrl+Page Up |
| ⌥⌘→ | `SUPER + ALT + RIGHT` | Ctrl+Shift+Right | Ctrl+Page Down |
| ⌘, | `SUPER + comma` | Ctrl+Shift+F2 | Ctrl+, |
| ⌘= | `SUPER + equal` | Ctrl+Shift+= | Ctrl+= |
| ⇧⌘= | `SUPER + SHIFT + equal` | Ctrl+Shift+= | Ctrl+= |
| ⌘- | `SUPER + minus` | Ctrl+Shift+- | Ctrl+- |
| ⌘0 | `SUPER + code:19` | Ctrl+Shift+Backspace | Ctrl+0 |

### foot

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⌘F | `SUPER + F` | Ctrl+Shift+R | Ctrl+F |

### terminal

Every catch-all key: Nothing: the key does nothing.

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⇧⌘← | `SUPER + SHIFT + LEFT` | Nothing: the key does nothing | Shift+Home |
| ⇧⌘→ | `SUPER + SHIFT + RIGHT` | Nothing: the key does nothing | Shift+End |
| ⌥⇧← | `ALT + SHIFT + LEFT` | Nothing: the key does nothing | Ctrl+Shift+Left |
| ⌥⇧→ | `ALT + SHIFT + RIGHT` | Nothing: the key does nothing | Ctrl+Shift+Right |
| ⌘↑ | `SUPER + UP` | Shift+Page Up | Ctrl+Home |
| ⌘↓ | `SUPER + DOWN` | Shift+Page Down | Ctrl+End |
| ⇧⌘↑ | `SUPER + SHIFT + UP` | Nothing: the key does nothing | Ctrl+Shift+Home |
| ⇧⌘↓ | `SUPER + SHIFT + DOWN` | Nothing: the key does nothing | Ctrl+Shift+End |
| ⌥⌫ | `ALT + BACKSPACE` | Nothing: the key reaches the app unchanged | Ctrl+Backspace |
| ⌥⌦ | `ALT + DELETE` | Alt+D | Ctrl+Delete |
| ⌘⌫ | `SUPER + BACKSPACE` | Ctrl+U | Shift+Home, then Backspace |
| ⌘⌦ | `SUPER + DELETE` | Ctrl+K | Shift+End, then Delete |
| ⌘C | `SUPER + C` | Ctrl+Insert | Ctrl+C |
| ⌘V | `SUPER + V` | Shift+Insert | Ctrl+V |
| ⌘X | `SUPER + X` | Nothing: the key does nothing | Ctrl+X |
| ⇧⌘V | `SUPER + SHIFT + V` | Shift+Insert | Ctrl+Shift+V |
| ⌘Z | `SUPER + Z` | Nothing: the key does nothing | Ctrl+Z |
| ⇧⌘Z | `SUPER + SHIFT + Z` | Nothing: the key does nothing | Ctrl+Shift+Z |
| ⇧⌘U | `SUPER + SHIFT + U` | Nothing: the key does nothing | Nothing: the key does nothing |
| ⌘A | `SUPER + A` | Nothing: the key does nothing | Ctrl+A |
| ⌘S | `SUPER + S` | Nothing: the key does nothing | Ctrl+S |
| ⇧⌘S | `SUPER + SHIFT + S` | Nothing: the key does nothing | Ctrl+Shift+S |
| ⌘B | `SUPER + B` | Nothing: the key does nothing | Ctrl+B |
| ⌘I | `SUPER + I` | Nothing: the key does nothing | Ctrl+I |
| ⌘U | `SUPER + U` | Nothing: the key does nothing | Ctrl+U |
| ⌘. | `SUPER + period` | Ctrl+C | Esc |
| ⌘F | `SUPER + F` | Nothing: the key does nothing | Ctrl+F |
| ⌘G | `SUPER + G` | Nothing: the key does nothing | F3 |
| ⇧⌘G | `SUPER + SHIFT + G` | Nothing: the key does nothing | Shift+F3 |
| ⌘/ | `SUPER + slash` | Nothing: the key does nothing | Ctrl+/ |
| ⌘T | `SUPER + T` | Ctrl+Shift+N | Ctrl+T |
| ⇧⌘T | `SUPER + SHIFT + T` | Nothing: the key does nothing | Ctrl+Shift+T |
| ⌘W | `SUPER + W` | Close the window | Ctrl+W |
| ⌘1 | `SUPER + code:10` | Nothing: the key does nothing | Ctrl+1 |
| ⌘2 | `SUPER + code:11` | Nothing: the key does nothing | Ctrl+2 |
| ⌘3 | `SUPER + code:12` | Nothing: the key does nothing | Ctrl+3 |
| ⌘4 | `SUPER + code:13` | Nothing: the key does nothing | Ctrl+4 |
| ⌘5 | `SUPER + code:14` | Nothing: the key does nothing | Ctrl+5 |
| ⌘6 | `SUPER + code:15` | Nothing: the key does nothing | Ctrl+6 |
| ⌘7 | `SUPER + code:16` | Nothing: the key does nothing | Ctrl+7 |
| ⌘8 | `SUPER + code:17` | Nothing: the key does nothing | Ctrl+8 |
| ⌘9 | `SUPER + code:18` | Nothing: the key does nothing | Ctrl+9 |
| ⇧⌘[ | `SUPER + SHIFT + bracketleft` | Nothing: the key does nothing | Ctrl+Page Up |
| ⇧⌘] | `SUPER + SHIFT + bracketright` | Nothing: the key does nothing | Ctrl+Page Down |
| ⌥⌘← | `SUPER + ALT + LEFT` | Nothing: the key does nothing | Ctrl+Page Up |
| ⌥⌘→ | `SUPER + ALT + RIGHT` | Nothing: the key does nothing | Ctrl+Page Down |
| ⌘N | `SUPER + N` | Ctrl+Shift+N | Ctrl+N |
| ⇧⌘N | `SUPER + SHIFT + N` | Nothing: the key does nothing | Ctrl+Shift+N |
| ⌘O | `SUPER + O` | Nothing: the key does nothing | Ctrl+O |
| ⌘P | `SUPER + P` | Nothing: the key does nothing | Ctrl+P |
| ⌘R | `SUPER + R` | Nothing: the key does nothing | Ctrl+R |
| ⌘L | `SUPER + L` | Nothing: the key does nothing | Ctrl+L |
| ⌘[ | `SUPER + bracketleft` | Nothing: the key does nothing | Ctrl+[ |
| ⌘] | `SUPER + bracketright` | Nothing: the key does nothing | Ctrl+] |
| ⌘, | `SUPER + comma` | Nothing: the key does nothing | Ctrl+, |
| ⌘Y | `SUPER + Y` | Nothing: the key does nothing | Ctrl+Y |
| ⇧⌘J | `SUPER + SHIFT + J` | Nothing: the key does nothing | Ctrl+Shift+J |
| ⇧⌘- | `SUPER + SHIFT + minus` | Nothing: the key does nothing | Ctrl+Shift+- |
| ⇧⌘. | `SUPER + SHIFT + period` | Nothing: the key does nothing | Ctrl+Shift+. |
| ⌥⌘I | `SUPER + ALT + I` | Nothing: the key does nothing | Ctrl+Shift+I |
| ⌘K | `SUPER + K` | Ctrl+L | Ctrl+K |
| ⌘D | `SUPER + D` | Nothing: the key does nothing | Ctrl+D |
| ⇧⌘D | `SUPER + SHIFT + D` | Nothing: the key does nothing | Ctrl+Shift+D |
| ⌃A | `CTRL + A` | Nothing: the key reaches the app unchanged | Home |
| ⌃E | `CTRL + E` | Nothing: the key reaches the app unchanged | End |
| ⌃F | `CTRL + F` | Nothing: the key reaches the app unchanged | Right |
| ⌃B | `CTRL + B` | Nothing: the key reaches the app unchanged | Left |
| ⌃N | `CTRL + N` | Nothing: the key reaches the app unchanged | Down |
| ⌃P | `CTRL + P` | Nothing: the key reaches the app unchanged | Up |
| ⌃D | `CTRL + D` | Nothing: the key reaches the app unchanged | Delete |
| ⌃H | `CTRL + H` | Nothing: the key reaches the app unchanged | Backspace |
| ⌃K | `CTRL + K` | Nothing: the key reaches the app unchanged | Shift+End, then Delete |

### firefox

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⇧⌘N | `SUPER + SHIFT + N` | Ctrl+Shift+P | Ctrl+Shift+N |
| ⌘, | `SUPER + comma` | Open about:preferences in Firefox | Ctrl+, |
| ⇧⌘J | `SUPER + SHIFT + J` | Ctrl+Shift+Y | Ctrl+Shift+J |

### browser

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⌘[ | `SUPER + bracketleft` | Alt+Left | Ctrl+[ |
| ⌘] | `SUPER + bracketright` | Alt+Right | Ctrl+] |
| ⌘Y | `SUPER + Y` | Ctrl+H | Ctrl+Y |
| ⇧⌘J | `SUPER + SHIFT + J` | Ctrl+J | Ctrl+Shift+J |
| ⌥⌘B | `SUPER + ALT + B` | Ctrl+Shift+O | passes through |
| ⇧⌘⌫ | `SUPER + SHIFT + BACKSPACE` | Ctrl+Shift+Delete | passes through |
| ⌥⌘J | `SUPER + ALT + J` | Ctrl+Shift+J | passes through |
| ⌥⌘C | `SUPER + ALT + C` | Ctrl+Shift+C | passes through |
| ⌥⌘U | `SUPER + ALT + U` | Ctrl+U | passes through |

### vscode

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⌘C | `SUPER + C` | Ctrl+Insert | Ctrl+C |
| ⌘V | `SUPER + V` | Shift+Insert | Ctrl+V |
| ⌘. | `SUPER + period` | Ctrl+. | Esc |
| ⌥⌘F | `SUPER + ALT + F` | Ctrl+H | passes through |
| ⌥⌘W | `SUPER + ALT + W` | Alt+W | passes through |
| ⌥⌘R | `SUPER + ALT + R` | Alt+R | passes through |
| ⌥⌘L | `SUPER + ALT + L` | Alt+L | passes through |
| ⌥⌘P | `SUPER + ALT + P` | Alt+P | passes through |
| ⌥⇧A | `ALT + SHIFT + A` | Ctrl+Shift+A | passes through |
| ⌥⌘↑ | `SUPER + ALT + UP` | Ctrl+Shift+Up | passes through |
| ⌥⌘↓ | `SUPER + ALT + DOWN` | Ctrl+Shift+Down | passes through |
| ⌥⇧↑ | `ALT + SHIFT + UP` | Ctrl+Shift+Alt+Up | passes through |
| ⌥⇧↓ | `ALT + SHIFT + DOWN` | Ctrl+Shift+Alt+Down | passes through |
| ⌥⌘[ | `SUPER + ALT + bracketleft` | Ctrl+Shift+[ | passes through |
| ⌥⌘] | `SUPER + ALT + bracketright` | Ctrl+Shift+] | passes through |
| ⌃⇧⌘← | `SUPER + CTRL + SHIFT + LEFT` | Shift+Alt+Left | passes through |
| ⌃⇧⌘→ | `SUPER + CTRL + SHIFT + RIGHT` | Shift+Alt+Right | passes through |
| ⌥⌘B | `SUPER + ALT + B` | Ctrl+Alt+B | passes through |
| ⇧⌘- | `SUPER + SHIFT + minus` | Ctrl+- | Ctrl+Shift+- |
| ⌘0 | `SUPER + code:19` | Ctrl+Keypad 0 | Ctrl+0 |
| ⌥⌘I | `SUPER + ALT + I` | Nothing: the key does nothing | Ctrl+Shift+I |
| ⌥⌘C | `SUPER + ALT + C` | Alt+C | passes through |
| ⌃D | `CTRL + D` | Nothing: the key reaches the app unchanged | Delete |

### libreoffice

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⇧⌘V | `SUPER + SHIFT + V` | Ctrl+Alt+Shift+V | Ctrl+Shift+V |
| ⌥⌘V | `SUPER + ALT + V` | Ctrl+Shift+V | passes through |
| ⌘G | `SUPER + G` | Ctrl+F, then Return, then Esc | F3 |
| ⇧⌘G | `SUPER + SHIFT + G` | Ctrl+F, then Shift+Return, then Esc | Shift+F3 |
| ⌘, | `SUPER + comma` | Alt+F12 | Ctrl+, |

### obsidian

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⇧⌘U | `SUPER + SHIFT + U` | Alt+U | Nothing: the key does nothing |
| ⌥⌘F | `SUPER + ALT + F` | Ctrl+H | passes through |
| ⌥⌘↑ | `SUPER + ALT + UP` | Ctrl+Alt+Up | passes through |
| ⌥⌘↓ | `SUPER + ALT + DOWN` | Ctrl+Alt+Down | passes through |
| ⌥⌘← | `SUPER + ALT + LEFT` | Ctrl+Alt+Left | Ctrl+Page Up |
| ⌥⌘→ | `SUPER + ALT + RIGHT` | Ctrl+Alt+Right | Ctrl+Page Down |

### nautilus

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⌘↑ | `SUPER + UP` | Alt+Up | Ctrl+Home |
| ⌘↓ | `SUPER + DOWN` | Return | Ctrl+End |
| ⌘⌫ | `SUPER + BACKSPACE` | Delete | Shift+Home, then Backspace |
| ⇧⌘G | `SUPER + SHIFT + G` | Ctrl+L | Shift+F3 |
| ⌘1 | `SUPER + code:10` | Ctrl+2 | Ctrl+1 |
| ⌘2 | `SUPER + code:11` | Ctrl+1 | Ctrl+2 |
| ⌘3 | `SUPER + code:12` | Nothing: the key does nothing | Ctrl+3 |
| ⌘4 | `SUPER + code:13` | Nothing: the key does nothing | Ctrl+4 |
| ⌘5 | `SUPER + code:14` | Nothing: the key does nothing | Ctrl+5 |
| ⌘6 | `SUPER + code:15` | Nothing: the key does nothing | Ctrl+6 |
| ⌘7 | `SUPER + code:16` | Nothing: the key does nothing | Ctrl+7 |
| ⌘8 | `SUPER + code:17` | Nothing: the key does nothing | Ctrl+8 |
| ⌘9 | `SUPER + code:18` | Nothing: the key does nothing | Ctrl+9 |
| ⌘[ | `SUPER + bracketleft` | Alt+Left | Ctrl+[ |
| ⌘] | `SUPER + bracketright` | Alt+Right | Ctrl+] |
| ⇧⌘. | `SUPER + SHIFT + period` | Ctrl+H | Ctrl+Shift+. |

### no-tabs

| Mac | Key | Action here | Generic action |
| --- | --- | --- | --- |
| ⌘W | `SUPER + W` | Close the window | Ctrl+W |

## Opt-in keys

Bound only when their condition holds, at the time the config loads.

| Mac | Key | Description | Action | Condition |
| --- | --- | --- | --- | --- |
| F5 | `XF86VoiceCommand` | Start dictation (push-to-talk) | Start voxtype recording | needs voxtype on PATH |
| F5 (release) | `XF86VoiceCommand` | Stop dictation (push-to-talk) | Stop voxtype recording and type the text | needs voxtype on PATH |
| ⇧F5 | `SHIFT + XF86VoiceCommand` | Toggle dictation | Start or stop voxtype recording | needs voxtype on PATH |
| ⌘-scroll up | `SUPER + mouse_up` | ⌘-scroll up sent as Ctrl-scroll | Scroll with Ctrl held (zooms in apps that zoom on Ctrl + wheel) | needs wtype on PATH |
| ⌘-scroll down | `SUPER + mouse_down` | ⌘-scroll down sent as Ctrl-scroll | Scroll with Ctrl held (zooms in apps that zoom on Ctrl + wheel) | needs wtype on PATH |
| ⌃A | `CTRL + A` | Line start (Emacs key) | Home | setting emacs_keys |
| ⌃E | `CTRL + E` | Line end (Emacs key) | End | setting emacs_keys |
| ⌃F | `CTRL + F` | Cursor right (Emacs key) | Right | setting emacs_keys |
| ⌃B | `CTRL + B` | Cursor left (Emacs key) | Left | setting emacs_keys |
| ⌃N | `CTRL + N` | Cursor down (Emacs key) | Down | setting emacs_keys |
| ⌃P | `CTRL + P` | Cursor up (Emacs key) | Up | setting emacs_keys |
| ⌃D | `CTRL + D` | Delete right (Emacs key) | Delete | setting emacs_keys |
| ⌃H | `CTRL + H` | Delete left (Emacs key) | Backspace | setting emacs_keys |
| ⌃K | `CTRL + K` | Delete to line end (Emacs key) | Shift+End, then Delete | setting emacs_keys |

## Relocated Omarchy binds

Omarchy binds that collided with a Mac shortcut. They keep their action; only the key
changed. A dropped bind is replaced by an OMacKey shortcut.

| Omarchy key | Was | New key | Now | Description |
| --- | --- | --- | --- | --- |
| `SUPER + C` | ⌘C | dropped |  | Universal copy |
| `SUPER + V` | ⌘V | dropped |  | Universal paste |
| `SUPER + X` | ⌘X | dropped |  | Universal cut |
| `SUPER + W` | ⌘W | `CTRL + ALT + W` | ⌃⌥W | Close window |
| `SUPER + J` | ⌘J | `CTRL + ALT + J` | ⌃⌥J | Toggle window split |
| `SUPER + P` | ⌘P | `CTRL + ALT + P` | ⌃⌥P | Pseudo window |
| `SUPER + T` | ⌘T | `CTRL + ALT + T` | ⌃⌥T | Toggle window floating/tiling |
| `SUPER + F` | ⌘F | `SUPER + CTRL + F` | ⌃⌘F | Full screen |
| `SUPER + CTRL + F` | ⌃⌘F | `CTRL + ALT + F` | ⌃⌥F | Tiled full screen |
| `SUPER + ALT + F` | ⌥⌘F | `CTRL + ALT + RETURN` | ⌃⌥⏎ | Full width |
| `SUPER + O` | ⌘O | `CTRL + ALT + O` | ⌃⌥O | Pop window out (float & pin) |
| `SUPER + L` | ⌘L | `CTRL + ALT + L` | ⌃⌥L | Toggle workspace layout |
| `SUPER + mouse:272` | nil | `CTRL + ALT + mouse:272` | nil | Move window |
| `SUPER + mouse:273` | nil | `CTRL + ALT + mouse:273` | nil | Resize window |
| `SUPER + mouse_down` | nil | `CTRL + ALT + mouse_down` | nil | Scroll active workspace forward |
| `SUPER + mouse_up` | nil | `CTRL + ALT + mouse_up` | nil | Scroll active workspace backward |
| `SUPER + ALT + mouse_down` | nil | `SUPER + CTRL + ALT + mouse_down` | nil | Next window in group |
| `SUPER + ALT + mouse_up` | nil | `SUPER + CTRL + ALT + mouse_up` | nil | Previous window in group |
| `SUPER + LEFT` | ⌘← | `CTRL + LEFT` | ⌃← | Focus on left window |
| `SUPER + RIGHT` | ⌘→ | `CTRL + RIGHT` | ⌃→ | Focus on right window |
| `SUPER + UP` | ⌘↑ | `CTRL + UP` | ⌃↑ | Focus on above window |
| `SUPER + DOWN` | ⌘↓ | `CTRL + DOWN` | ⌃↓ | Focus on below window |
| `SUPER + SHIFT + LEFT` | ⇧⌘← | `CTRL + SHIFT + LEFT` | ⌃⇧← | Swap window to the left |
| `SUPER + SHIFT + RIGHT` | ⇧⌘→ | `CTRL + SHIFT + RIGHT` | ⌃⇧→ | Swap window to the right |
| `SUPER + SHIFT + UP` | ⇧⌘↑ | `CTRL + SHIFT + UP` | ⌃⇧↑ | Swap window up |
| `SUPER + SHIFT + DOWN` | ⇧⌘↓ | `CTRL + SHIFT + DOWN` | ⌃⇧↓ | Swap window down |
| `SUPER + ALT + LEFT` | ⌥⌘← | `SUPER + CTRL + ALT + LEFT` | ⌃⌥⌘← | Move window to group on left |
| `SUPER + ALT + RIGHT` | ⌥⌘→ | `SUPER + CTRL + ALT + RIGHT` | ⌃⌥⌘→ | Move window to group on right |
| `SUPER + ALT + UP` | ⌥⌘↑ | `SUPER + CTRL + ALT + UP` | ⌃⌥⌘↑ | Move window to group on top |
| `SUPER + ALT + DOWN` | ⌥⌘↓ | `SUPER + CTRL + ALT + DOWN` | ⌃⌥⌘↓ | Move window to group on bottom |
| `SUPER + SHIFT + ALT + LEFT` | ⌥⇧⌘← | `SUPER + CTRL + ALT + SHIFT + LEFT` | ⌃⌥⇧⌘← | Move workspace to left monitor |
| `SUPER + SHIFT + ALT + RIGHT` | ⌥⇧⌘→ | `SUPER + CTRL + ALT + SHIFT + RIGHT` | ⌃⌥⇧⌘→ | Move workspace to right monitor |
| `SUPER + SHIFT + ALT + UP` | ⌥⇧⌘↑ | `SUPER + CTRL + ALT + SHIFT + UP` | ⌃⌥⇧⌘↑ | Move workspace to up monitor |
| `SUPER + SHIFT + ALT + DOWN` | ⌥⇧⌘↓ | `SUPER + CTRL + ALT + SHIFT + DOWN` | ⌃⌥⇧⌘↓ | Move workspace to down monitor |
| `SUPER + G` | ⌘G | `CTRL + ALT + G` | ⌃⌥G | Toggle window grouping |
| `SUPER + ALT + G` | ⌥⌘G | `CTRL + ALT + SHIFT + G` | ⌃⌥⇧G | Move active window out of group |
| `SUPER + S` | ⌘S | `CTRL + ALT + S` | ⌃⌥S | Toggle scratchpad |
| `SUPER + ALT + S` | ⌥⌘S | `CTRL + ALT + SHIFT + S` | ⌃⌥⇧S | Move window to scratchpad |
| `SUPER + code:20` | ⌘- | `CTRL + ALT + code:20` | ⌃⌥- | Expand window left |
| `SUPER + code:21` | ⌘= | `CTRL + ALT + code:21` | ⌃⌥= | Shrink window left |
| `SUPER + SHIFT + code:20` | ⇧⌘- | `CTRL + ALT + SHIFT + code:20` | ⌃⌥⇧- | Shrink window up |
| `SUPER + SHIFT + code:21` | ⇧⌘= | `CTRL + ALT + SHIFT + code:21` | ⌃⌥⇧= | Expand window down |
| `SUPER + CTRL + code:20` | ⌃⌘- | `SUPER + CTRL + ALT + code:20` | ⌃⌥⌘- | Expand window left a lot |
| `SUPER + CTRL + code:21` | ⌃⌘= | `SUPER + CTRL + ALT + code:21` | ⌃⌥⌘= | Shrink window left a lot |
| `SUPER + CTRL + SHIFT + code:20` | ⌃⇧⌘- | `SUPER + CTRL + ALT + SHIFT + code:20` | ⌃⌥⇧⌘- | Shrink window up a lot |
| `SUPER + CTRL + SHIFT + code:21` | ⌃⇧⌘= | `SUPER + CTRL + ALT + SHIFT + code:21` | ⌃⌥⇧⌘= | Expand window down a lot |
| `SUPER + SLASH` | ⌘/ | `CTRL + ALT + slash` | ⌃⌥/ | Monitor scaling up |
| `SUPER + ALT + SLASH` | ⌥⌘/ | `CTRL + ALT + SHIFT + slash` | ⌃⌥⇧/ | Monitor scaling down |
| `SUPER + BACKSPACE` | ⌘⌫ | `CTRL + ALT + BACKSPACE` | ⌃⌥⌫ | Toggle window transparency |
| `SUPER + SHIFT + BACKSPACE` | ⇧⌘⌫ | `CTRL + ALT + SHIFT + BACKSPACE` | ⌃⌥⇧⌫ | Toggle window gaps |
| `SUPER + ALT + code:34` | ⌥⌘[ | `CTRL + ALT + code:34` | ⌃⌥[ | Make webcam overlay smaller |
| `SUPER + ALT + code:35` | ⌥⌘] | `CTRL + ALT + code:35` | ⌃⌥] | Make webcam overlay larger |
| `SUPER + TAB` | ⌘⇥ | `CTRL + ALT + RIGHT` | ⌃⌥→ | Next workspace |
| `SUPER + SHIFT + TAB` | ⇧⌘⇥ | `CTRL + ALT + LEFT` | ⌃⌥← | Previous workspace |
| `SUPER + RETURN` | ⌘⏎ | `SUPER + CTRL + ALT + RETURN` | ⌃⌥⌘⏎ | Terminal |
| `SUPER + SHIFT + RETURN` | ⇧⌘⏎ | `SUPER + CTRL + ALT + SHIFT + RETURN` | ⌃⌥⇧⌘⏎ | Browser |
| `SUPER + SHIFT + F` | ⇧⌘F | `SUPER + CTRL + ALT + F` | ⌃⌥⌘F | File manager |
| `SUPER + ALT + SHIFT + F` | ⌥⇧⌘F | `SUPER + CTRL + ALT + SHIFT + F` | ⌃⌥⇧⌘F | File manager (cwd) |
| `SUPER + SHIFT + B` | ⇧⌘B | `SUPER + CTRL + ALT + B` | ⌃⌥⌘B | Browser |
| `SUPER + SHIFT + ALT + B` | ⌥⇧⌘B | `SUPER + CTRL + ALT + SHIFT + B` | ⌃⌥⇧⌘B | Browser (private) |
| `SUPER + SHIFT + N` | ⇧⌘N | `SUPER + CTRL + ALT + N` | ⌃⌥⌘N | Editor |
| `SUPER + SHIFT + M` | ⇧⌘M | `SUPER + CTRL + ALT + M` | ⌃⌥⌘M | Music |
| `SUPER + SHIFT + ALT + M` | ⌥⇧⌘M | `SUPER + CTRL + ALT + SHIFT + M` | ⌃⌥⇧⌘M | Music TUI |
| `SUPER + SHIFT + D` | ⇧⌘D | `SUPER + CTRL + ALT + D` | ⌃⌥⌘D | Docker |
| `SUPER + SHIFT + G` | ⇧⌘G | `SUPER + CTRL + ALT + G` | ⌃⌥⌘G | Signal |
| `SUPER + SHIFT + ALT + G` | ⌥⇧⌘G | `SUPER + CTRL + ALT + SHIFT + G` | ⌃⌥⇧⌘G | WhatsApp |
| `SUPER + SHIFT + O` | ⇧⌘O | `SUPER + CTRL + ALT + O` | ⌃⌥⌘O | Obsidian |
| `SUPER + SHIFT + W` | ⇧⌘W | `SUPER + CTRL + ALT + W` | ⌃⌥⌘W | Omawrite |
| `SUPER + SHIFT + SLASH` | ⇧⌘/ | `SUPER + CTRL + ALT + slash` | ⌃⌥⌘/ | Passwords |
| `SUPER + SHIFT + A` | ⇧⌘A | `SUPER + CTRL + ALT + A` | ⌃⌥⌘A | ChatGPT |
| `SUPER + SHIFT + ALT + A` | ⌥⇧⌘A | `SUPER + CTRL + ALT + SHIFT + A` | ⌃⌥⇧⌘A | Grok |
| `SUPER + SHIFT + C` | ⇧⌘C | `SUPER + CTRL + ALT + C` | ⌃⌥⌘C | Calendar |
| `SUPER + SHIFT + E` | ⇧⌘E | `SUPER + CTRL + ALT + E` | ⌃⌥⌘E | Email |
| `SUPER + SHIFT + ALT + E` | ⌥⇧⌘E | `SUPER + CTRL + ALT + SHIFT + E` | ⌃⌥⇧⌘E | New email |
| `SUPER + SHIFT + Y` | ⇧⌘Y | `SUPER + CTRL + ALT + Y` | ⌃⌥⌘Y | YouTube |
| `SUPER + SHIFT + P` | ⇧⌘P | `SUPER + CTRL + ALT + P` | ⌃⌥⌘P | Google Photos |
| `SUPER + SHIFT + S` | ⇧⌘S | `SUPER + CTRL + ALT + S` | ⌃⌥⌘S | Google Maps |
| `SUPER + SHIFT + X` | ⇧⌘X | `SUPER + CTRL + ALT + X` | ⌃⌥⌘X | X |
| `SUPER + SHIFT + ALT + X` | ⌥⇧⌘X | `SUPER + CTRL + ALT + SHIFT + X` | ⌃⌥⇧⌘X | X Post |
| `SUPER + CTRL + ALT + T` | ⌃⌥⌘T | `SUPER + CTRL + SHIFT + T` | ⌃⇧⌘T | Show time |
| `SUPER + CTRL + ALT + B` | ⌃⌥⌘B | `SUPER + CTRL + SHIFT + B` | ⌃⇧⌘B | Show battery remaining |
| `SUPER + CTRL + ALT + W` | ⌃⌥⌘W | `SUPER + CTRL + SHIFT + W` | ⌃⇧⌘W | Toggle weather |
| `SUPER + CTRL + ALT + D` | ⌃⌥⌘D | `SUPER + CTRL + SHIFT + D` | ⌃⇧⌘D | Calendar |
| `SUPER + K` | ⌘K | `SUPER + SHIFT + slash` | ⇧⌘/ | Keybindings |
| `SUPER + comma` | ⌘, | `SUPER + CTRL + SHIFT + comma` | ⌃⇧⌘, | Dismiss last notification |
| `SUPER + CTRL + Q` | ⌃⌘Q | `SUPER + CTRL + ALT + Q` | ⌃⌥⌘Q | Calculator |
| `SUPER + CTRL + SPACE` | ⌃⌘Space | `SUPER + CTRL + ALT + SPACE` | ⌃⌥⌘Space | Background switcher |
| `SUPER + code:10` | ⌘1 | `CTRL + code:10` | ⌃1 | Switch to workspace 1 |
| `SUPER + SHIFT + code:10` | ⇧⌘1 | `CTRL + SHIFT + code:10` | ⌃⇧1 | Move window to workspace 1 |
| `SUPER + SHIFT + ALT + code:10` | ⌥⇧⌘1 | `CTRL + ALT + SHIFT + code:10` | ⌃⌥⇧1 | Move window silently to workspace 1 |
| `SUPER + code:11` | ⌘2 | `CTRL + code:11` | ⌃2 | Switch to workspace 2 |
| `SUPER + SHIFT + code:11` | ⇧⌘2 | `CTRL + SHIFT + code:11` | ⌃⇧2 | Move window to workspace 2 |
| `SUPER + SHIFT + ALT + code:11` | ⌥⇧⌘2 | `CTRL + ALT + SHIFT + code:11` | ⌃⌥⇧2 | Move window silently to workspace 2 |
| `SUPER + code:12` | ⌘3 | `CTRL + code:12` | ⌃3 | Switch to workspace 3 |
| `SUPER + SHIFT + code:12` | ⇧⌘3 | `CTRL + SHIFT + code:12` | ⌃⇧3 | Move window to workspace 3 |
| `SUPER + SHIFT + ALT + code:12` | ⌥⇧⌘3 | `CTRL + ALT + SHIFT + code:12` | ⌃⌥⇧3 | Move window silently to workspace 3 |
| `SUPER + code:13` | ⌘4 | `CTRL + code:13` | ⌃4 | Switch to workspace 4 |
| `SUPER + SHIFT + code:13` | ⇧⌘4 | `CTRL + SHIFT + code:13` | ⌃⇧4 | Move window to workspace 4 |
| `SUPER + SHIFT + ALT + code:13` | ⌥⇧⌘4 | `CTRL + ALT + SHIFT + code:13` | ⌃⌥⇧4 | Move window silently to workspace 4 |
| `SUPER + code:14` | ⌘5 | `CTRL + code:14` | ⌃5 | Switch to workspace 5 |
| `SUPER + SHIFT + code:14` | ⇧⌘5 | `CTRL + SHIFT + code:14` | ⌃⇧5 | Move window to workspace 5 |
| `SUPER + SHIFT + ALT + code:14` | ⌥⇧⌘5 | `CTRL + ALT + SHIFT + code:14` | ⌃⌥⇧5 | Move window silently to workspace 5 |
| `SUPER + code:15` | ⌘6 | `CTRL + code:15` | ⌃6 | Switch to workspace 6 |
| `SUPER + SHIFT + code:15` | ⇧⌘6 | `CTRL + SHIFT + code:15` | ⌃⇧6 | Move window to workspace 6 |
| `SUPER + SHIFT + ALT + code:15` | ⌥⇧⌘6 | `CTRL + ALT + SHIFT + code:15` | ⌃⌥⇧6 | Move window silently to workspace 6 |
| `SUPER + code:16` | ⌘7 | `CTRL + code:16` | ⌃7 | Switch to workspace 7 |
| `SUPER + SHIFT + code:16` | ⇧⌘7 | `CTRL + SHIFT + code:16` | ⌃⇧7 | Move window to workspace 7 |
| `SUPER + SHIFT + ALT + code:16` | ⌥⇧⌘7 | `CTRL + ALT + SHIFT + code:16` | ⌃⌥⇧7 | Move window silently to workspace 7 |
| `SUPER + code:17` | ⌘8 | `CTRL + code:17` | ⌃8 | Switch to workspace 8 |
| `SUPER + SHIFT + code:17` | ⇧⌘8 | `CTRL + SHIFT + code:17` | ⌃⇧8 | Move window to workspace 8 |
| `SUPER + SHIFT + ALT + code:17` | ⌥⇧⌘8 | `CTRL + ALT + SHIFT + code:17` | ⌃⌥⇧8 | Move window silently to workspace 8 |
| `SUPER + code:18` | ⌘9 | `CTRL + code:18` | ⌃9 | Switch to workspace 9 |
| `SUPER + SHIFT + code:18` | ⇧⌘9 | `CTRL + SHIFT + code:18` | ⌃⇧9 | Move window to workspace 9 |
| `SUPER + SHIFT + ALT + code:18` | ⌥⇧⌘9 | `CTRL + ALT + SHIFT + code:18` | ⌃⌥⇧9 | Move window silently to workspace 9 |
| `SUPER + code:19` | ⌘0 | `CTRL + code:19` | ⌃0 | Switch to workspace 10 |
| `SUPER + SHIFT + code:19` | ⇧⌘0 | `CTRL + SHIFT + code:19` | ⌃⇧0 | Move window to workspace 10 |
| `SUPER + SHIFT + ALT + code:19` | ⌥⇧⌘0 | `CTRL + ALT + SHIFT + code:19` | ⌃⌥⇧0 | Move window silently to workspace 10 |

## Settings

Optional file `${XDG_CONFIG_HOME:-~/.config}/omackey/settings.lua`, returning a table of
options to change. Nothing creates it. Reload Hyprland after editing.

| Option | Default | Meaning |
| --- | --- | --- |
| `emacs_keys` | `true` | Mac text-field editing keys on physical ⌃: ⌃A / ⌃E line start / end, ⌃F / ⌃B / ⌃N / ⌃P arrows, ⌃D / ⌃H delete, ⌃K delete to line end. Terminals keep the raw key, and so does ⌃D in VS Code. They take ⌃A, ⌃F, ⌃H … away from GUI apps (select all, find, history): set this to false to get those back. |
| `release_ms` | `20` | How long a synthetic key stays down before its release is sent (Omarchy uses 50 ms). |
| `close_window_classes` | `{}` | Window classes of GUI apps where Ctrl+W doesn't close the window, so ⌘W closes it instead. Add a class (see hyprctl clients) when ⌘W does nothing. |
