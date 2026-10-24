import QtQuick

Gradient {
    property bool reversed: false

    GradientStop {
        position: reversed ? 1.0 : 0.0
        color: "#000080"
    }
    GradientStop {
        position: reversed ? 0.0 : 1.0
        color: "#1084d0"
    }
}
