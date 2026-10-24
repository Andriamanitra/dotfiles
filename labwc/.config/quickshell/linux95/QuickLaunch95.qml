import Quickshell
import QtQuick

// Quick-launch icon button: always a raised Win95 button, lightens on hover,
// sinks when pressed.
Bevel {
    id: root
    property string appId: ""
    property var command: []

    width: 26
    height: 22

    sunken: mouse.pressed
    face: mouse.containsMouse ? "#d3d3d3" : "#c0c0c0"

    AppIcon {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: mouse.pressed ? 1 : 0
        anchors.horizontalCenterOffset: mouse.pressed ? 1 : 0
        appId: root.appId
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(root.command)
    }
}
