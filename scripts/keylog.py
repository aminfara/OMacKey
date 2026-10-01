#!/usr/bin/env python3
"""Key event logger for OMacKey tests (a wev alternative with no install).

Opens a window with an editable sample text and logs every key press, release
and modifier change the app receives, with the cursor position after each
event. Focus it, press a Mac chord, and read what an app really got.

    scripts/keylog.py              log to the window and stdout
    scripts/keylog.py --log FILE   also write the log to FILE

The window's app id is "omackey.keylog" (class in `hyprctl clients`).
"""

import argparse
import sys
import time

import gi

gi.require_version("Gdk", "4.0")
gi.require_version("Gtk", "4.0")
from gi.repository import Gdk, GLib, Gtk  # noqa: E402

SAMPLE = (
    "The quick brown fox jumps over the lazy dog.\n"
    "Pack my box with five dozen liquor jugs.\n"
    "How vexingly quick daft zebras jump!\n"
)

MODIFIERS = [
    (Gdk.ModifierType.SUPER_MASK, "SUPER"),
    (Gdk.ModifierType.CONTROL_MASK, "CTRL"),
    (Gdk.ModifierType.ALT_MASK, "ALT"),
    (Gdk.ModifierType.SHIFT_MASK, "SHIFT"),
    (Gdk.ModifierType.META_MASK, "META"),
    (Gdk.ModifierType.HYPER_MASK, "HYPER"),
]


def modifier_names(state):
    names = [name for mask, name in MODIFIERS if state & mask]
    return "+".join(names) if names else "-"


class KeyLog(Gtk.Application):
    def __init__(self, log_path):
        super().__init__(application_id="omackey.keylog")
        self.log_file = open(log_path, "w", buffering=1) if log_path else None
        self.started = time.monotonic()

    def do_activate(self):
        window = Gtk.ApplicationWindow(application=self, title="OMacKey keylog")
        window.set_default_size(900, 600)

        self.text = Gtk.TextView(monospace=True, wrap_mode=Gtk.WrapMode.WORD)
        self.text.get_buffer().set_text(SAMPLE)
        # Start mid-line so line start/end movements are visible.
        buffer = self.text.get_buffer()
        buffer.place_cursor(buffer.get_iter_at_line_offset(1, 12)[1])

        self.log_view = Gtk.TextView(monospace=True, editable=False, cursor_visible=False)

        log_scroll = Gtk.ScrolledWindow(vexpand=True)
        log_scroll.set_child(self.log_view)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        box.append(self.text)
        box.append(Gtk.Separator())
        box.append(log_scroll)
        window.set_child(box)

        keys = Gtk.EventControllerKey()
        keys.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        keys.connect("key-pressed", self.on_key, "press")
        keys.connect("key-released", self.on_key, "release")
        keys.connect("modifiers", self.on_modifiers)
        window.add_controller(keys)

        window.present()
        self.text.grab_focus()
        self.log("ready", "-", 0, 0)

    def on_key(self, _controller, keyval, keycode, state, kind):
        # Log after GTK has handled the key so the cursor position is current.
        name = Gdk.keyval_name(keyval) or hex(keyval)
        GLib.idle_add(self.log, kind, name, keycode, state)
        return False

    def on_modifiers(self, _controller, state):
        GLib.idle_add(self.log, "mods", "-", 0, state)
        return False

    def log(self, kind, name, keycode, state):
        buffer = self.text.get_buffer()
        cursor = buffer.get_iter_at_mark(buffer.get_insert())
        selection = buffer.get_selection_bounds()
        selected = len(buffer.get_text(*selection, False)) if selection else 0

        line = "{:8.3f}  {:<7} {:<14} code={:<4} mods={:<16} cursor={}:{} selected={}".format(
            time.monotonic() - self.started,
            kind,
            name,
            keycode,
            modifier_names(state),
            cursor.get_line() + 1,
            cursor.get_line_offset(),
            selected,
        )

        print(line, flush=True)
        if self.log_file:
            self.log_file.write(line + "\n")

        log_buffer = self.log_view.get_buffer()
        log_buffer.insert(log_buffer.get_end_iter(), line + "\n")
        self.log_view.scroll_to_mark(log_buffer.get_insert(), 0, False, 0, 0)
        return False


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--log", help="also write the log to this file")
    args = parser.parse_args()
    return KeyLog(args.log).run([sys.argv[0]])


if __name__ == "__main__":
    sys.exit(main())
