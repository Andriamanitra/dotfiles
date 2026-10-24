import Quickshell.Widgets
import QtQuick

// One system tray icon (drawn on the dark tray well).
//   left click   -> activate (or request the menu for menu-only items)
//   middle click -> secondary activate
//   right click  -> menuRequested() (the shell shows a Menu95)
Item {
    id: root
    property var trayItem
    signal menuRequested()

    implicitWidth: 18
    implicitHeight: 18

    IconImage {
        anchors.centerIn: parent
        implicitSize: 18
        source: root.trayItem ? root.trayItem.icon : ""
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: event => {
            const t = root.trayItem
            if (!t) return
            if (event.button === Qt.LeftButton) {
                if (t.onlyMenu && t.hasMenu)
                    root.menuRequested()
                else
                    t.activate()
            } else if (event.button === Qt.MiddleButton) {
                t.secondaryActivate()
            } else if (event.button === Qt.RightButton && t.hasMenu) {
                root.menuRequested()
            }
        }
    }

    // tooltip: title (and description, if the app provides one)
    Tooltip95 {
        anchors.fill: parent
        text: {
            const t = root.trayItem
            if (!t) return ""
            const title = t.tooltipTitle || t.title || t.id || ""
            const desc = (t.tooltipDescription || "").replace(/<[^>]*>/g, "").trim()
            return desc ? title + "\n" + desc : title
        }
    }
}
