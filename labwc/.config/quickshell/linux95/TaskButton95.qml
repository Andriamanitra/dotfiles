import QtQuick

// A taskbar button that can be dragged sideways to reorder it.
//
// It is a Button95 inside a "slot" (this Item). The slot keeps its place in the
// positioner (`row`) while the button inside it follows the pointer during a drag.
// The drag is detected by a DragHandler on the slot, which takes over from
// Button95's MouseArea once the drag threshold is passed, so Button95 itself needs
// no drag logic and a drag never produces a click.
//
// The component doesn't reorder anything itself: while dragging it emits
// moveRequested(to) whenever the dragged button crosses into another slot, and the
// owner moves the entry in its model.
Item {
    id: root

    // ---- look (forwarded to the Button95 inside) ----
    property alias text: button.text
    property alias checked: button.checked
    property alias hoverEffect: button.hoverEffect
    property alias checkedFace: button.checkedFace
    property alias leftContent: button.leftContent

    // ---- reordering ----
    property Item row: null            // the Row/positioner that lays the slots out
    property int slotIndex: 0          // this slot's index in the row
    property int slotCount: 1          // number of slots in the row
    property bool dragging: false

    signal clicked()
    signal rightClicked()
    signal dragStarted()
    signal moveRequested(int to)

    property real _dragRowX: 0         // dragged button's left edge, in row coordinates
    property real _grabX: 0            // where in the button the pointer grabbed it

    z: dragging ? 10 : 0

    function _dragTo(sceneX) {
        if (!row) return
        const step = width + row.spacing
        const maxX = Math.max(0, slotCount * step - row.spacing - width)
        _dragRowX = Math.max(0, Math.min(maxX, row.mapFromItem(null, sceneX, 0).x - _grabX))
        const target = Math.max(0, Math.min(slotCount - 1,
                                            Math.floor((_dragRowX + width / 2) / step)))
        if (target !== slotIndex)
            moveRequested(target)
    }

    Button95 {
        id: button
        width: root.width
        height: root.height

        // While dragging the button is placed at the pointer. Because this is a
        // binding on root.x, it keeps tracking correctly when neighbouring slots
        // are shuffled and this slot's x changes.
        x: root.dragging ? root._dragRowX - root.x : 0
        Behavior on x {
            enabled: !root.dragging
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        onClicked: root.clicked()
        onRightClicked: root.rightClicked()
    }

    DragHandler {
        id: dragHandler
        target: null                   // we move the button ourselves
        acceptedButtons: Qt.LeftButton
        yAxis.enabled: false           // horizontal drags only

        onActiveChanged: {
            if (active) {
                root._grabX = centroid.pressPosition.x
                root._dragRowX = root.row ? root.row.mapFromItem(null, centroid.scenePosition.x, 0).x - root._grabX : 0
                root.dragging = true
                root.dragStarted()
            } else {
                root.dragging = false
            }
        }
        onCentroidChanged: if (active) root._dragTo(centroid.scenePosition.x)
    }

    // closed-hand cursor while dragging
    HoverHandler {
        enabled: root.dragging
        cursorShape: Qt.ClosedHandCursor
    }

    Tooltip95 {
        anchors.fill: parent
        text: button.text
    }
}
