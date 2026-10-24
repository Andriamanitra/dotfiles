import Quickshell
import Quickshell.Io
import QtQuick

// CPU usage widget for the (dark) tray well. Click opens btop in a terminal.
Item {
    id: root
    property color fg: "#dfdfdf"
    property real usage: 0                   // percent, 0..100
    property var prev: null                  // previous /proc/stat sample

    implicitWidth: 56
    implicitHeight: 18

    // ---- sampling /proc/stat every 2s ----
    Process {
        id: proc
        command: ["head", "-n", "1", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: root.update(text)
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: if (!proc.running) proc.running = true
    }

    function update(line) {
        // "cpu  user nice system idle iowait irq softirq steal guest guest_nice"
        const f = line.trim().split(/\s+/).slice(1).map(Number)
        if (f.length < 5) return
        const idle = f[3] + f[4]
        const total = f.slice(0, 8).reduce((a, b) => a + b, 0)
        if (prev) {
            const dt = total - prev.total
            const di = idle - prev.idle
            if (dt > 0)
                usage = Math.max(0, Math.min(100, 100 * (1 - di / dt)))
        }
        prev = { total: total, idle: idle }
    }

    // little CPU chip icon
    Canvas {
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16

        property color ink: root.fg
        onInkChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = ink
            ctx.strokeStyle = ink
            ctx.lineWidth = 1
            ctx.strokeRect(3.5, 3.5, 9, 9)
            ctx.fillRect(6, 6, 4, 4)
            for (const p of [5, 8, 10]) {
                ctx.fillRect(p, 1, 1, 2)
                ctx.fillRect(p, 13, 1, 2)
                ctx.fillRect(1, p, 2, 1)
                ctx.fillRect(13, p, 2, 1)
            }
        }
    }

    Txt {
        x: 24
        width: 30
        height: parent.height
        text: Math.round(root.usage) + "%"
        color: root.fg
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["foot", "-T", "btop", "btop", "--preset", "1"])
    }
}
