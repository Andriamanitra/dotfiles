import Quickshell.Widgets
import QtQuick

// One row in a Win95 menu: normal item, checked item, submenu item or separator.
Item {
    id: root
    property string label: ""
    property string iconSource: ""
    property bool checked: false
    property bool hasChildren: false
    property bool separator: false
    property bool active: false          // its submenu is open: keep it highlighted
    signal clicked()
    signal entered()

    readonly property bool lit: (mouse.containsMouse || active) && enabled

    height: separator ? 6 : 24

    // ---------- separator ----------
    Rectangle { visible: root.separator; x: 2; y: 2; width: parent.width - 4; height: 1; color: "#808080" }
    Rectangle { visible: root.separator; x: 2; y: 3; width: parent.width - 4; height: 1; color: "#ffffff" }

    // ---------- normal row ----------
    Rectangle {
        visible: !root.separator
        anchors.fill: parent
        color: root.lit ? "#000080" : "transparent"

        readonly property color fg: !root.enabled ? "#808080"
                                  : root.lit ? "#ffffff" : "#000000"

        Txt {
            x: 6
            width: 14
            height: parent.height
            text: root.checked ? "\u2713" : ""
            color: parent.fg
        }

        IconImage {
            visible: root.iconSource !== ""
            x: 4
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 16
            source: root.iconSource
        }

        Txt {
            x: 26
            width: parent.width - 26 - (root.hasChildren ? 20 : 8)
            height: parent.height
            text: root.label
            elide: Text.ElideRight
            color: parent.fg
        }

        Txt {
            visible: root.hasChildren
            anchors.right: parent.right
            anchors.rightMargin: 8
            height: parent.height
            text: ">"
            font.bold: true
            color: parent.fg
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.entered()
            onClicked: root.clicked()
        }
    }
}
