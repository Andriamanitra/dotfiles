import Quickshell
import QtQuick

// Win95-style cascading context menu. Two ways to fill it:
//   * handle: a QsMenuHandle (e.g. trayItem.menu) -> entries come from the app
//   * items:  a JS array like
//       [ { text: "Close", trigger: () => doSomething() },
//         { isSeparator: true },
//         { text: "Disabled", enabled: false } ]
// Set `anchor.window` from the outside, then call openFor(item) or openAt(x, w).
//
// Hover a row with a ">" to open its submenu beside it (to the right if there is room
// on screen, otherwise to the left); click leaf rows to activate.
//
// Everything (all levels) is drawn inside ONE popup window that spans the full width of
// the screen, is tall and transparent, and is sized on every open, so the window is
// never resized while mapped. The input mask keeps transparent parts click-through.
PopupWindow {
    id: root

    property var handle: null
    property var owner: null           // whatever opened the menu (used for toggling)
    property var items: []
    property bool growLeft: false      // true: align the menu's right edge with the opener's
    property int menuWidth: 190
    property int maxHeight: 600        // set on every open to fit the screen
    // If >= 0, the menu's first row lines up with a point this many px above the taskbar's
    // top edge (used to open a submenu beside a row of another popup). Otherwise the
    // menu sits right on top of the taskbar.
    property real alignTop: -1
    readonly property bool hovered: hover.hovered
    signal activated()                 // a leaf entry was activated
    property int hoverDelay: 120       // ms before a hovered row opens/closes submenus
    property bool wantOpen: false
    property double openedAt: 0

    readonly property int maxDepth: 3                    // deepest level index (4 levels)

    property int screenW: 1000         // set on every open
    property real anchorX: 0           // opener's x / width in window coordinates
    property real anchorW: 0
    readonly property real rootX: {
        const x = growLeft ? anchorX + anchorW - menuWidth : anchorX
        return Math.max(0, Math.min(x, screenW - menuWidth))
    }

    // Submenu path as child INDICES from the root menu, e.g. [3, 0].
    // Apps rebuild their menu tree at will (invalidating entry objects), so we
    // re-resolve the path through a chain of openers instead of holding entries.
    property var path: []
    property var rowY: []              // window-y of the row that opened each level

    function entryAt(op, level) {
        if (path.length <= level || !op.children)
            return null
        const vals = op.children.values
        const i = path[level]
        return i < vals.length ? vals[i] : null
    }

    QsMenuOpener { id: o0; menu: root.handle }
    QsMenuOpener { id: o1; menu: root.entryAt(o0, 0) }
    QsMenuOpener { id: o2; menu: root.entryAt(o1, 1) }
    QsMenuOpener { id: o3; menu: root.entryAt(o2, 2) }

    readonly property var openers: [o0, o1, o2, o3]

    function countAt(k) {
        const c = openers[k].children
        return c ? c.values.length : 0
    }
    // entries in the root menu (tray menus load asynchronously)
    readonly property int count: countAt(0)

    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right

    implicitWidth: screenW
    implicitHeight: maxHeight
    color: "transparent"

    mask: Region {
        Region { x: lvl0.x; y: lvl0.y; width: lvl0.visible ? lvl0.width : 0; height: lvl0.visible ? lvl0.height : 0 }
        Region { x: lvl1.x; y: lvl1.y; width: lvl1.visible ? lvl1.width : 0; height: lvl1.visible ? lvl1.height : 0 }
        Region { x: lvl2.x; y: lvl2.y; width: lvl2.visible ? lvl2.width : 0; height: lvl2.visible ? lvl2.height : 0 }
        Region { x: lvl3.x; y: lvl3.y; width: lvl3.visible ? lvl3.width : 0; height: lvl3.visible ? lvl3.height : 0 }
    }

    // ---------- opening / closing ----------
    function openAt(x, w) {
        const w0 = anchor.window
        if (w0 && w0.screen) {
            maxHeight = Math.max(160, w0.screen.height - w0.height - 80)
            screenW = w0.screen.width
        }
        anchorX = x
        anchorW = w
        anchor.rect.x = 0              // the window spans the screen from its left edge
        anchor.rect.y = 0              // top edge of the taskbar
        anchor.rect.width = 1
        anchor.rect.height = 1
        path = []
        rowY = []
        wantOpen = true
        // Tray menus: wait until the entries have arrived.
        if (!handle || count > 0)
            visible = true
    }

    function openFor(item) {
        const p = item.mapToItem(null, 0, 0)
        openAt(p.x, item.width)
    }

    function close() {
        wantOpen = false
        visible = false
    }

    function activateEntry(e) {
        if (typeof e.triggered === "function")
            e.triggered()              // QsMenuEntry
        else if (typeof e.trigger === "function")
            e.trigger()                // plain JS item
    }

    onCountChanged: if (wantOpen && count > 0 && !visible) visible = true
    onVisibleChanged: {
        hoverTimer.stop()
        pendingHover = null
        if (visible) {
            openedAt = Date.now()
        } else {
            path = []
            rowY = []
            wantOpen = false
            owner = null
        }
    }

    // ---------- hover / click handling ----------
    property var pendingHover: null

    function openRow(level, index, y) {
        if (level >= maxDepth) return
        if (path.length > level && path[level] === index) return   // already open
        rowY = rowY.slice(0, level).concat([y])
        path = path.slice(0, level).concat([index])
    }

    function hoverRow(level, index, hasChildren, y) {
        pendingHover = { level: level, index: index, hasChildren: hasChildren, y: y }
        hoverTimer.restart()
    }

    function applyHover() {
        const h = pendingHover
        pendingHover = null
        if (!h) return
        if (h.hasChildren)
            openRow(h.level, h.index, h.y)
        else if (path.length > h.level)
            path = path.slice(0, h.level)      // hovering a plain row closes deeper levels
    }

    function clickRow(level, entry, index, hasChildren, y) {
        if (Date.now() - openedAt < 250) return
        if (hasChildren) {
            hoverTimer.stop()
            openRow(level, index, y)
        } else {
            activateEntry(entry)
            activated()
            close()
        }
    }

    Timer {
        id: hoverTimer
        interval: root.hoverDelay
        onTriggered: root.applyHover()
    }

    // ---------- layout ----------
    // Each submenu goes to the right of its parent if it fits on screen, else to its left.
    function levelX(k) {
        let x = rootX
        for (let i = 1; i <= k; i++)
            x = (x + 2 * menuWidth <= screenW) ? x + menuWidth : Math.max(0, x - menuWidth)
        return x
    }
    // Submenus line their first row up with the row that opened them (3px = border + padding).
    function subY(k, h) {
        const wanted = (rowY[k - 1] ?? 0) - 3
        return Math.max(0, Math.min(wanted, stage.height - h))
    }

    Item {
        id: stage
        anchors.fill: parent

        HoverHandler {
            id: hover
            blocking: false
        }

        MenuLevel95 {
            id: lvl0
            width: root.menuWidth
            maxHeight: root.maxHeight
            x: root.levelX(0)
            y: root.alignTop >= 0
               ? Math.max(0, Math.min(stage.height - root.alignTop - 3, stage.height - height))
               : stage.height - height            // default: right on top of the taskbar
            visible: root.handle ? root.countAt(0) > 0 : root.items.length > 0
            model: root.handle ? root.openers[0].children : root.items
            openIndex: root.path.length > 0 ? root.path[0] : -1
            onRowHovered: (i, hc, y) => root.hoverRow(0, i, hc, y)
            onRowClicked: (e, i, hc, y) => root.clickRow(0, e, i, hc, y)
        }

        MenuLevel95 {
            id: lvl1
            width: root.menuWidth
            maxHeight: root.maxHeight
            x: root.levelX(1)
            y: root.subY(1, height)
            visible: root.path.length >= 1 && root.countAt(1) > 0
            model: root.openers[1].children
            openIndex: root.path.length > 1 ? root.path[1] : -1
            resetKey: root.path.slice(0, 1).join(",")
            onRowHovered: (i, hc, y) => root.hoverRow(1, i, hc, y)
            onRowClicked: (e, i, hc, y) => root.clickRow(1, e, i, hc, y)
        }

        MenuLevel95 {
            id: lvl2
            width: root.menuWidth
            maxHeight: root.maxHeight
            x: root.levelX(2)
            y: root.subY(2, height)
            visible: root.path.length >= 2 && root.countAt(2) > 0
            model: root.openers[2].children
            openIndex: root.path.length > 2 ? root.path[2] : -1
            resetKey: root.path.slice(0, 2).join(",")
            onRowHovered: (i, hc, y) => root.hoverRow(2, i, hc, y)
            onRowClicked: (e, i, hc, y) => root.clickRow(2, e, i, hc, y)
        }

        MenuLevel95 {
            id: lvl3
            width: root.menuWidth
            maxHeight: root.maxHeight
            x: root.levelX(3)
            y: root.subY(3, height)
            visible: root.path.length >= 3 && root.countAt(3) > 0
            model: root.openers[3].children
            openIndex: -1
            resetKey: root.path.slice(0, 3).join(",")
            onRowHovered: (i, hc, y) => root.hoverRow(3, i, hc, y)
            onRowClicked: (e, i, hc, y) => root.clickRow(3, e, i, hc, y)
        }
    }
}
