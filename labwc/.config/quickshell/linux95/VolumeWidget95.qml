import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Volume widget for the (dark) tray well.
//   left click   -> open pavucontrol
//   right click  -> toggle mute
//   scroll       -> change volume (5% per wheel notch)
Item {
    id: root
    property color fg: "#dfdfdf"
    property real maxVolume: 1.0

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property real volume: audio ? audio.volume : 0
    readonly property bool muted: audio ? audio.muted : false

    implicitWidth: 58
    implicitHeight: 18

    // keep the sink's volume/mute properties live
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    function adjust(delta) {
        if (!audio) return
        if (delta > 0 && audio.muted)
            audio.muted = false
        const v = Math.round((audio.volume + delta) * 100) / 100
        audio.volume = Math.max(0, Math.min(maxVolume, v))
    }

    function toggleMute() {
        if (audio)
            audio.muted = !audio.muted
    }

    // speaker icon
    Canvas {
        id: icon
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16

        property color ink: root.fg
        property bool isMuted: root.muted
        onInkChanged: requestPaint()
        onIsMutedChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = ink
            ctx.strokeStyle = ink
            ctx.lineWidth = 1
            // speaker body + cone
            ctx.fillRect(2, 6, 3, 4)
            ctx.beginPath()
            ctx.moveTo(5, 6); ctx.lineTo(9, 3); ctx.lineTo(9, 13); ctx.lineTo(5, 10)
            ctx.closePath()
            ctx.fill()
            if (isMuted) {
                ctx.strokeStyle = "#ff6060"
                ctx.beginPath()
                ctx.moveTo(11, 5.5); ctx.lineTo(15, 10.5)
                ctx.moveTo(15, 5.5); ctx.lineTo(11, 10.5)
                ctx.stroke()
            } else {
                ctx.beginPath(); ctx.arc(9, 8, 3.5, -0.9, 0.9); ctx.stroke()
                ctx.beginPath(); ctx.arc(9, 8, 6.5, -0.9, 0.9); ctx.stroke()
            }
        }
    }

    Txt {
        x: 24
        width: 30
        height: parent.height
        text: root.audio ? (root.muted ? "mute" : Math.round(root.volume * 100) + "%") : "--"
        color: root.muted ? "#909090" : root.fg
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.toggleMute()
            else
                Quickshell.execDetached(["pavucontrol"])
        }
        onWheel: wheel => root.adjust(wheel.angleDelta.y / 120 * 0.05)
    }

    Tooltip95 {
        anchors.fill: parent
        text: root.sink.name + "\n" + Pipewire.defaultAudioSource.name
    }
}
