import os
import tempfile
import webbrowser
from urllib.parse import quote

import terminatorlib.plugin as plugin

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk  # noqa: E402
from gi.repository import Gdk  # noqa: E402


AVAILABLE = ['SearchPlugin']
SEARCH_URL = "https://kagi.com/search?q=%s"


class SearchPlugin(plugin.MenuItem):
    capabilities = ['terminal_menu']

    def callback(self, menuitems, menu, terminal):
        if not terminal.vte.get_has_selection():
            return
        self.terminal = terminal
        clip = Gtk.Clipboard.get(Gdk.SELECTION_PRIMARY)
        self.selection = clip.wait_for_text().strip()

        # if selection is long, give an option to open it in an editor
        if len(self.selection) > 150 or "\n" in self.selection:
            item = Gtk.MenuItem("Open in editor")
            item.connect("activate", self.editor)
            menu.insert(item, 2)

        # if selection is short enough, give an option to search for it
        if len(self.selection) <= 200:
            item = Gtk.MenuItem("Search")
            item.connect("activate", self.search)
            search_text = self.cleaned_selection
            if len(search_text) > 50:
                search_text = search_text[:48] + "..."
            item.set_label(f"Search '{search_text}'")
            menu.insert(item, 2)

    @property
    def cleaned_selection(self):
        """Returns selection without extra whitespace"""
        return " ".join(self.selection.split())

    def search(self, menu):
        webbrowser.open(SEARCH_URL % quote(self.cleaned_selection))

    def editor(self, menu):
        tempf = tempfile.NamedTemporaryFile(mode="w+t", delete=False)
        tempf.write(self.selection)
        n = tempf.name
        tempf.close()
        os.system(f"xdg-open {n}")
