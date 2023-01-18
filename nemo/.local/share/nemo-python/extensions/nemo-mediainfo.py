#!/usr/bin/python

import subprocess

from urllib.parse import unquote

from gi.repository import GObject, Gtk, Nemo


class MediainfoPropertyPage(
        GObject.GObject,
        Nemo.PropertyPageProvider,
        Nemo.NameAndDescProvider
):
    def get_property_pages(self, files) -> list[Nemo.PropertyPage]:
        if len(files) != 1:
            return []

        file = files[0]
        if file.get_uri_scheme() != 'file' or file.is_directory():
            return []

        filename = unquote(file.get_uri().removeprefix("file://"))

        self.property_label = Gtk.Label('Media Info')
        self.property_label.show()

        self.builder = Gtk.Builder()
        self.builder.add_from_string(
            """
            <interface>
              <requires lib="gtk+" version="3.0"/>
              <object class="GtkScrolledWindow" id="window">
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <child>
                  <object class="GtkViewport" id="viewport1">
                    <property name="visible">True</property>
                    <property name="can_focus">False</property>
                    <child>
                      <object class="GtkGrid" id="grid">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                        <property name="vexpand">True</property>
                        <property name="row_spacing">4</property>
                        <property name="column_spacing">16</property>
                      </object>
                    </child>
                  </object>
                </child>
              </object>
            </interface>
            """
        )

        self.window = self.builder.get_object("window")
        self.grid = self.builder.get_object("grid")

        mediainfo = subprocess.run(
            ["mediainfo", filename],
            capture_output=True
        ).stdout.decode()

        row = 0
        for section in mediainfo.rstrip().split("\n\n"):
            if row > 0:
                hsep = Gtk.HSeparator()
                hsep.show()
                self.grid.attach(hsep, 0, row, 2, 1)
                row += 1
            section_header, _, infos = section.partition("\n")
            label = Gtk.Label()
            label.set_markup(f"<b>{section_header}</b>")
            label.set_justify(Gtk.Justification.LEFT)
            label.set_halign(Gtk.Align.START)
            label.set_selectable(True)
            label.show()
            self.grid.attach(label, 0, row, 2, 1)
            row += 1
            for info_line in infos.splitlines():
                attribute, _, value = info_line.partition(":")
                label = Gtk.Label()
                label.set_markup(f"{attribute.strip()}")
                label.set_justify(Gtk.Justification.LEFT)
                label.set_halign(Gtk.Align.START)
                label.set_selectable(True)
                label.show()
                self.grid.attach(label, 0, row, 1, 1)

                label = Gtk.Label()
                label.set_markup(f"{value.strip()}")
                label.set_justify(Gtk.Justification.LEFT)
                label.set_halign(Gtk.Align.START)
                label.set_selectable(True)
                label.show()
                self.grid.attach(label, 1, row, 1, 1)
                row += 1

        return [
            Nemo.PropertyPage(
                name="NemoPython::mediainfo",
                label=self.property_label,
                page=self.window,
            )
        ]

    def get_name_and_desc(self):
        return [("Nemo mediainfo:::View mediainfo in properties")]
