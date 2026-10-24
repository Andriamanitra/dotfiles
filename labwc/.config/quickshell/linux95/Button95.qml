import QtQuick

// Push button. `checked` renders it sunken (used for active window / open menu).
// Put an icon (or anything) in `leftContent`.
// With `hoverEffect: true` the face lightens slightly under the pointer.
Bevel {
    id: root
    property string text: ""
    property bool bold: false
    property bool checked: false
    property int textAlign: Text.AlignLeft
    property bool hoverEffect: false
    property color checkedFace: "#c0c0c0"
    property alias leftContent: iconSlot.data
    readonly property bool hovered: mouse.containsMouse
    signal clicked()
    signal rightClicked()

    sunken: checked || mouse.pressed
    face: hoverEffect && hovered ? (checked ? Qt.lighter(checkedFace, 1.07) : "#d3d3d3")
                                 : (checked ? checkedFace : "#c0c0c0")

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.sunken ? 1 : 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 4 + (root.sunken ? 1 : 0)
        anchors.rightMargin: 4 - (root.sunken ? 1 : 0)
        spacing: 4

        Item {
            id: iconSlot
            width: childrenRect.width
            height: root.height - 4
            visible: children.length > 0
        }
        Txt {
            text: root.text
            font.bold: root.bold
            elide: Text.ElideRight
            horizontalAlignment: root.textAlign
            width: parent.width - (iconSlot.visible ? iconSlot.width + parent.spacing : 0)
            height: root.height - 4
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.rightClicked()
            else
                root.clicked()
        }
    }
}
