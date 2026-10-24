import QtQuick

// A row in the Start menu.
//   hasChildren: show a ">" arrow (the row opens a submenu rather than doing something)
//   active:      keep the row highlighted (its submenu is open)
//   entered():   emitted when the pointer enters the row
Rectangle {
    id: root
    property string label: ""
    property bool hasChildren: false
    property bool active: false
    signal triggered()
    signal entered()

    readonly property bool lit: mouse.containsMouse || active

    height: 32
    color: lit ? "#000080" : "transparent"

    Txt {
        x: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        font.pixelSize: 13
        color: root.lit ? "#ffffff" : "#000000"
    }

    Txt {
        visible: root.hasChildren
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: ">"
        font.bold: true
        font.pixelSize: 13
        color: root.lit ? "#ffffff" : "#000000"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.entered()
        onClicked: root.triggered()
    }
}
