import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel

// A Menu95 listing the .desktop launchers found in `folder` (not recursive).
//
// The folder is watched, and every launcher file is read and parsed here in QML, so
// the menu stays current when launchers are added, removed or edited.
// Launchers are started with `gio launch`, which handles Exec field codes, Path=,
// Terminal=true and so on.
Menu95 {
    id: root

    property string folder: ""
    property string emptyText: "(no launchers found)"

    menuWidth: 240

    // ---- parsing ----
    // Minimal .desktop parser: only the [Desktop Entry] group, unlocalized Name and Icon.
    function _parse(text) {
        let section = "", name = "", icon = "", hidden = false
        for (const raw of text.split("\n")) {
            const line = raw.trim()
            if (line.startsWith("[")) {
                section = line
                continue
            }
            if (section !== "[Desktop Entry]")
                continue
            if (line.startsWith("Name=") && name === "")
                name = line.slice(5)
            else if (line.startsWith("Icon=") && icon === "")
                icon = line.slice(5)
            else if (/^(nodisplay|hidden)=true$/i.test(line))
                hidden = true
        }
        return { name: name, icon: icon, hidden: hidden }
    }

    // Rebuild the menu entries from all successfully parsed launchers.
    function _rebuild() {
        const list = []
        for (let i = 0; i < files.count; i++) {
            const f = files.objectAt(i)
            if (f && f.entryName !== "" && !f.entryHidden)
                list.push(f)
        }
        list.sort((a, b) => a.entryName.localeCompare(b.entryName, undefined, { sensitivity: "base" }))

        const out = list.map(f => {
            const file = f.path
            const icon = f.entryIcon
            return {
                text: f.entryName,
                icon: icon === "" ? "" : (icon.startsWith("/") ? "file://" + icon
                                                               : Quickshell.iconPath(icon, true)),
                trigger: () => Quickshell.execDetached(["gio", "launch", file])
            }
        })
        items = out.length > 0 ? out : [{ text: emptyText, enabled: false }]
    }

    Component.onCompleted: _rebuild()

    // One FileView per launcher file in the folder.
    Instantiator {
        id: files

        model: FolderListModel {
            folder: root.folder === "" ? "" : "file://" + encodeURI(root.folder)
            nameFilters: ["*.desktop"]
            showDirs: false
            showDotAndDotDot: false
        }

        delegate: FileView {
            required property string filePath

            property string entryName: ""
            property string entryIcon: ""
            property bool entryHidden: false

            path: filePath
            watchChanges: true
            onFileChanged: reload()
            onLoaded: {
                const d = root._parse(text())
                entryName = d.name
                entryIcon = d.icon
                entryHidden = d.hidden
                root._rebuild()
            }
        }

        onObjectAdded: root._rebuild()
        onObjectRemoved: root._rebuild()
    }
}
