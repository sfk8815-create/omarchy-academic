#!/usr/bin/env python3
"""GTK password prompt used as a sudo askpass helper (中文 sudo 密码弹窗)."""

import sys

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk


class PassDialog(Gtk.Dialog):
    def __init__(self):
        super().__init__(title="sudo 密码", resizable=False)
        self.set_border_width(14)
        self.set_position(Gtk.WindowPosition.CENTER)

        box = self.get_content_area()
        label = Gtk.Label(label="请输入 sudo 密码：")
        box.pack_start(label, False, False, 6)

        self.entry = Gtk.Entry()
        self.entry.set_visibility(False)
        self.entry.set_input_purpose(Gtk.InputPurpose.PASSWORD)
        self.entry.connect("activate", lambda _w: self.response(Gtk.ResponseType.OK))
        box.pack_start(self.entry, False, False, 6)

        self.add_button("取消", Gtk.ResponseType.CANCEL)
        self.add_button("确定", Gtk.ResponseType.OK)
        self.set_default_response(Gtk.ResponseType.OK)
        self.show_all()
        self.entry.grab_focus()


def main() -> None:
    dialog = PassDialog()
    response = dialog.run()
    value = dialog.entry.get_text() if response == Gtk.ResponseType.OK else ""
    dialog.destroy()
    if not value:
        sys.exit(1)
    sys.stdout.write(value + "\n")
    sys.stdout.flush()


if __name__ == "__main__":
    main()
