import os
import tempfile

import terminatorlib.plugin as plugin

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
from gi.repository import Gdk

AVAILABLE = ['SearchPlugin']

class SearchPlugin(plugin.MenuItem):
    capabilities = ['terminal_menu']

    def callback(self, menuitems, menu, terminal):
        if not terminal.vte.get_has_selection():
            return
        self.terminal = terminal
        clip = Gtk.Clipboard.get(Gdk.SELECTION_PRIMARY)
        self.selection = clip.wait_for_text().strip()

        # if selection is long, give an option to open it in an editor,
        # otherwise give an option to google it!
        if len(self.selection) > 50 or "\n" in self.selection:
            item = Gtk.MenuItem("Open in editor")
            item.connect("activate", self.editor)
            menu.insert(item, 2)
        else:
            item = Gtk.MenuItem("Search")
            item.connect("activate", self.search)
            item.set_label(f"Search '{self.selection}'")
            menu.insert(item, 2)

    def search(self, menu):
        url = "https://www.google.com/search?q=" + self.selection
        os.system(f"xdg-open '{url}'")

    def editor(self, menu):
        tempf = tempfile.NamedTemporaryFile(mode="w+t", delete=False)
        tempf.write(self.selection)
        n = tempf.name
        tempf.close()
        os.system(f"xdg-open {n}")

