# OMacKey

macOS keyboard shortcuts for [Omarchy](https://omarchy.org): ⌘C, ⌘V, ⌘T, ⌘W,
⌘Tab, ⌘← and about 160 shortcuts in all, written as plain Hyprland Lua.

It is for people who switch every day between a Mac and an Omarchy machine and
are tired of translating shortcuts in their head.

## What you get

- **⌘ does what it does on a Mac.** Copy, paste, find, new tab, close tab,
  line start and end, app switching with ⌘Tab, screenshots on ⇧⌘3/4/5, ⌘Q
  to quit an app. Terminals are handled with care: ⌘C copies, and the shell
  never sees a stray Ctrl+C.
- **Per-app where it matters.** Browsers, VS Code, Nautilus, Obsidian,
  LibreOffice and the common terminals get their own behaviour. Anywhere
  else, ⌘ + key is sent as Ctrl + key.
- **Omarchy keeps working.** Omarchy shortcuts that collide with a Mac one
  move to a new key. Nothing is silently dropped, and the help menu (⌘?)
  shows the live bindings.

| Mac key | Role here |
| --- | --- |
| ⌘ | app shortcuts and text navigation |
| ⌥ | word navigation (Meta keeps working in bash, tmux and nvim) |
| ⌃ | passes through to apps; ⌃ + arrows move focus, ⌃1–0 pick a workspace |
| ⌃⌥ | window management: resize, float, fullscreen, workspaces |
| ⌃⌘ | Omarchy utilities |
| ⌃⌥⌘ | app launchers, on Omarchy's own letters |

The full list, with the exact key strings, is in
[docs/KEYBINDINGS.md](docs/KEYBINDINGS.md).

**Why not keyd, Kinto or xremap?** They are system-wide remappers: a daemon,
often running as root, rewriting keys before Hyprland sees them. OMacKey is
only Hyprland config. There is no extra process, you can read all of it, and
it goes away with your session. The price is that it only knows what Hyprland
can see, so it is not a general remapper (see [Good to know](#good-to-know)).

## Install

```bash
git clone https://github.com/aminfara/OMacKey.git
cd OMacKey
./install.sh
```

The script links the repo into `~/.config/hypr`, adds two guarded blocks to
`hyprland.lua` (backed up first), reloads Hyprland and runs a self-check. It is
safe to run again. It remaps your keyboard, so read the
[Disclaimer](#disclaimer) first.

<details>
<summary>Manual install</summary>

The script does two things, and you can do them yourself.

1. Link the `omackey/` directory:

   ```bash
   ln -s "$PWD/omackey" ~/.config/hypr/omackey
   ```

2. In `~/.config/hypr/hyprland.lua`, put one block before and one after the
   line `require("default.hypr.omarchy")`:

   ```lua
   -- >>> OMacKey pre (managed by OMacKey install.sh)
   do local ok, loader = pcall(require, "hypr.omackey.load"); if ok then loader.pre() end end
   -- <<< OMacKey pre
   require("default.hypr.omarchy")
   -- >>> OMacKey (managed by OMacKey install.sh)
   do local ok, loader = pcall(require, "hypr.omackey.load"); if ok then loader.init() end end
   -- <<< OMacKey
   ```

3. Reload with `hyprctl reload`, then run `scripts/check.sh`. It should print
   three ✓ lines.

</details>

## What it touches, and how to remove it

- **It adds** one symlink (`~/.config/hypr/omackey`) and the two marker-delimited
  blocks above in `hyprland.lua`.
- **It never edits** anything under `/usr/share/omarchy` or `/usr/share/hypr`,
  and it runs no daemon.
- **Your files win.** Your own `~/.config/hypr/bindings.lua` loads after
  OMacKey, so anything you bind there overrides it.
- **If it fails,** the blocks are guarded: Omarchy and your own config still
  load, and the error shows as a notification.

To switch it off without uninstalling, press ⌃⇧⌘M (or run
`scripts/omackey-mode off`); the same key turns it back on. To remove it, run
`./uninstall.sh`.

`omarchy refresh hyprland` resets your Hyprland config and removes OMacKey's
blocks. Run `./install.sh` again afterwards.

## Customize

**Turn off one shortcut.** Unbind its exact key string (from
[docs/KEYBINDINGS.md](docs/KEYBINDINGS.md)) in `~/.config/hypr/bindings.lua`.
The key then reaches your apps again:

```lua
hl.unbind("SUPER + CTRL + UP")
```

**Settings.** An optional file, `~/.config/omackey/settings.lua`, returns the
options to change. Nothing creates it.

```lua
return { emacs_keys = false, close_window_classes = { "org.gnome.Calculator" } }
```

| Option | Default | Meaning |
| --- | --- | --- |
| `emacs_keys` | `true` | ⌃A / ⌃E / ⌃F / ⌃B / ⌃N / ⌃P / ⌃D / ⌃H / ⌃K edit text as on a Mac |
| `release_ms` | `20` | how long a synthetic key stays down |
| `close_window_classes` | `{}` | apps where ⌘W closes the window |

**Optional tools.** Without them those keys are simply not bound.

- `wtype` enables ⌘-scroll as Ctrl-scroll (zoom). It ships with Omarchy.
- `voxtype` enables the F5 dictation keys. Install it with Omarchy's own
  installer (`omarchy-voxtype-install`).

## Good to know

- Some Omarchy shortcuts moved to make room: window management is on ⌃⌥,
  launchers on ⌃⌥⌘. The full list is in
  [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md#relocated-omarchy-binds).
- ⌘M and ⌘H (minimize, hide) are not mapped: Omarchy has no minimize, and a
  hidden window would be hard to get back. The scratchpad is the native
  equivalent.
- ⌃←/→ switch windows, not Spaces. Mission Control is not mapped.
- Persian and other non-Latin layouts are not tested yet. Keys are sent by
  keycode, so they should work.
- More in [docs/LIMITATIONS.md](docs/LIMITATIONS.md).

## Troubleshooting

<details>
<summary>A key is stuck or repeating</summary>

Press and release it, then run `hyprctl reload`.

</details>

<details>
<summary>A shortcut does nothing</summary>

- Run `scripts/check.sh`: it reports load errors and duplicate binds.
- `hyprctl repl 'return omackey.status()'` shows errors and relocations Omarchy
  no longer has.
- Check that OMacKey is on (⌃⇧⌘M toggles it, `scripts/omackey-mode status`
  tells).

</details>

<details>
<summary>The desktop is unusable</summary>

Switch to a TTY (Ctrl+Alt+F3), run `./uninstall.sh`, and log back in.

</details>

More in [docs/TESTING.md](docs/TESTING.md#6-recovery).

## Tested on

Omarchy 4.0.4 with Hyprland 0.56 (Lua config, scrolling layout), a NuPhy
Air75 V2 in Mac mode (⌘ is Super), foot and Brave. Other Omarchy or Hyprland
versions may differ: after `omarchy update`, `scripts/drift.sh` lists the Omarchy
bindings that changed and which of them sit on a key OMacKey uses, and
`omackey.status()` reports relocations that no longer match.

## Contributing

Issues and pull requests are welcome. Keep changes small: one key or one group
of related keys at a time, with a description on every bind. Before you open a
pull request, run `scripts/check.sh`, `scripts/snapshot.sh` and
`lua5.5 scripts/gen-docs.lua` (`install.sh` enables a pre-commit hook that
checks the generated docs). Say in the pull request which keys you pressed
yourself: synthetic input cannot trigger Hyprland binds, so the last test is
always a human at a keyboard.

**Working with an AI agent is encouraged and recommended, and the repo is set up for it.**
[AGENTS.md](AGENTS.md) (also available as `CLAUDE.md`, for Claude Code) holds
the rules and the session workflow, and the docs below hold the architecture,
the test harness and what is already known about Hyprland, Omarchy and the apps.
The snapshot and handler tests let an agent check its own work. You stay
responsible for what you submit: read the diff and test the keys.

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): goal, decisions, layout, how to
  add a key, an app or a relocation
- [docs/TESTING.md](docs/TESTING.md): the snapshot harness, handler tests,
  physical tests, recovery
- [docs/FINDINGS.md](docs/FINDINGS.md): facts about Hyprland, Omarchy and the apps
- [docs/LIMITATIONS.md](docs/LIMITATIONS.md): what is not mapped, and why
- [docs/ROADMAP.md](docs/ROADMAP.md): what is left
- [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md): every shortcut (generated)

## Acknowledgements

- [Omarchy](https://omarchy.org) and [Hyprland](https://hypr.land), which this
  builds on.
- The **r/omarchy community**, whose "macOS like bindings" thread showed that
  keycodes, retained timers and Ctrl forwarding work in Hyprland's Lua config.
- The **Omarchy + keyd discussion**
  ([#175](https://github.com/omacom/omarchy/discussions/175)), for the minimal
  "must work" set and the terminal copy and paste pitfalls.
- [Kinto](https://github.com/rbreaves/kinto) and the
  [xremap macOS config](https://github.com/petrstepanov/gnome-macos-remap-wayland),
  whose per-app tables we learned from.

## Disclaimer

OMacKey is provided as is, without warranty of any kind, and you use it at your
own risk.

Changing how a keyboard behaves can make it hard or impossible to use until you
undo the change. The effects are easy to reverse (see
[how to switch it off or remove it](#what-it-touches-and-how-to-remove-it)), and
the author uses OMacKey every day on their own machine. Even so, the author
takes no responsibility for any harm, data loss or inconvenience it may cause to
your system or your work. Read what it does before you install it; the code is
short and plain Lua.

## License

[MIT](LICENSE)
