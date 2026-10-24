import Quickshell
import Quickshell.Widgets
import QtQuick

// Icon for an application, looked up from its Wayland appId.
// Tries the .desktop entry's icon first, then variations of the appId,
// handles absolute icon paths, and finally falls back to a generic icon
// (instead of Quickshell's black/magenta "missing" texture).
IconImage {
    id: root
    property string appId: ""

    // Re-evaluates once the desktop entries have finished loading.
    readonly property var entry: {
        DesktopEntries.applications.values
        return root.appId !== "" ? DesktopEntries.heuristicLookup(root.appId) : null
    }

    implicitSize: 16
    source: root.resolve()

    function resolve() {
        const names = []
        if (root.entry && root.entry.icon)
            names.push(root.entry.icon)
        if (root.appId !== "") {
            names.push(root.appId)
            names.push(root.appId.toLowerCase())
            names.push(root.appId.toLowerCase().replace(/_/g, "-"))
        }

        for (const n of names) {
            if (n.startsWith("/"))
                return "file://" + n
            const p = Quickshell.iconPath(n, true)   // "" if not found
            if (p !== "")
                return p
        }
        return Quickshell.iconPath("application-x-executable", true)
    }
}
