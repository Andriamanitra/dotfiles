import QtQuick

// Classic Win95 3D border. Raised by default, sunken if `sunken: true`.
// `face` is the fill colour. Children are placed inside the border (2px inset).
Item {
    id: root
    property bool sunken: false
    property color face: "#c0c0c0"
    default property alias content: inner.data

    // outer bottom-right, outer top-left, inner bottom-right, inner top-left
    Rectangle { anchors.fill: parent; color: root.sunken ? "#ffffff" : "#000000" }
    Rectangle { x: 0; y: 0; width: root.width - 1; height: root.height - 1
                color: root.sunken ? "#808080" : "#ffffff" }
    Rectangle { x: 1; y: 1; width: root.width - 2; height: root.height - 2
                color: root.sunken ? "#dfdfdf" : "#808080" }
    Rectangle { x: 1; y: 1; width: root.width - 3; height: root.height - 3
                color: root.sunken ? "#000000" : "#dfdfdf" }
    // face
    Rectangle {
        x: 2; y: 2; width: root.width - 4; height: root.height - 4
        color: root.face
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: 2
    }
}
