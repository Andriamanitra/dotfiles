import QtQuick

// One panel of a cascading menu: a scrollable list of Menu95Rows.
Bevel {
    id: lvl

    property var model: null            // ObjectModel (tray) or JS array
    property int maxHeight: 600
    property int openIndex: -1          // row whose submenu is currently open
    property string resetKey: ""        // scroll back to top when this changes

    // y is the row's top edge in window coordinates
    signal rowHovered(int index, bool hasChildren, real y)
    signal rowClicked(var entry, int index, bool hasChildren, real y)

    height: Math.min(Math.max(col.height, 24) + 6, maxHeight)
    onResetKeyChanged: flick.contentY = 0

    Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        interactive: false              // scrolled with the wheel, below
        contentWidth: width
        contentHeight: col.height + 2
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            x: 1
            y: 1
            width: flick.width - 2

            Repeater {
                model: lvl.model

                Menu95Row {
                    id: row
                    required property var modelData
                    required property int index

                    width: col.width
                    separator: modelData.isSeparator === true
                    label: modelData.text ?? ""
                    enabled: modelData.enabled !== false
                    iconSource: modelData.icon ?? ""
                    hasChildren: modelData.hasChildren === true
                    checked: (modelData.buttonType ?? 0) !== 0 && modelData.checkState === Qt.Checked
                    active: lvl.openIndex === index

                    onEntered: lvl.rowHovered(index, hasChildren, row.mapToItem(null, 0, 0).y)
                    onClicked: lvl.rowClicked(modelData, index, hasChildren, row.mapToItem(null, 0, 0).y)
                }
            }
        }
    }

    WheelHandler {
        onWheel: event => {
            const maxY = Math.max(0, flick.contentHeight - flick.height)
            flick.contentY = Math.max(0, Math.min(maxY, flick.contentY - event.angleDelta.y / 3))
        }
    }
}
