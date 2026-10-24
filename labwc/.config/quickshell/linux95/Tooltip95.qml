import Quickshell
import QtQuick

// Win95-style tooltip (pale yellow box). Use it as a child of the item it describes:
//
//     SomeItem {
//         Tooltip95 { anchors.fill: parent; text: "Hello" }
//     }
//
// It appears above the taskbar, centred over the item, after the pointer has rested
// on the item for `delay` ms, and hides when the pointer leaves. Bind `suppressed` to
// the item's pressed state to also hide it while the item is being pressed.
// The text is read when the tooltip is shown (so the box never resizes while visible).
// It never takes input, so it can't get in the way of clicks.
// Declare it LAST among the item's children so it sits on top of any MouseArea there.
// It only watches the pointer (non-blocking hover handler, no click handlers), so it
// can't steal clicks or hover from the item.
Item {
    id: root

    property string text: ""
    property int delay: 150
    property bool suppressed: false       // true: don't show, and hide if showing

    property string _shown: ""

    function show() {
        if (suppressed || !root.QsWindow.window || root.text.trim() === "")
            return
        _shown = root.text.trim()
        const p = root.mapToItem(null, 0, 0)
        tip.anchor.rect.x = p.x
        tip.anchor.rect.y = 0                 // top edge of the taskbar
        tip.anchor.rect.width = root.width
        tip.anchor.rect.height = 1
        tip.visible = true
    }

    function hide() {
        timer.stop()
        tip.visible = false
    }

    Timer {
        id: timer
        interval: root.delay
        onTriggered: root.show()
    }

    onSuppressedChanged: if (suppressed) hide()

    HoverHandler {
        blocking: false // don't hide hover from items underneath
        onHoveredChanged: hovered ? timer.restart() : root.hide()
    }

    PopupWindow {
        id: tip
        anchor.window: root.QsWindow.window
        anchor.edges: Edges.Top
        anchor.gravity: Edges.Top

        implicitWidth: label.implicitWidth + 10
        implicitHeight: label.implicitHeight + 6
        color: "#ffffe1"
        mask: Region {} // click-through

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#000000"
            border.width: 1
        }

        Txt {
            id: label
            x: 5
            y: 3
            text: root._shown
            textFormat: Text.PlainText
            verticalAlignment: Text.AlignTop
        }
    }
}
