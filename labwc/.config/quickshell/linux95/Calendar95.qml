import QtQuick

// A small Win95-style month calendar with a title bar.
Bevel {
    id: root
    signal closeRequested()

    implicitWidth: 220
    implicitHeight: 220

    property var today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()

    readonly property int weekStart: Qt.locale().firstDayOfWeek % 7
    readonly property int lead: (new Date(year, month, 1).getDay() - weekStart + 7) % 7
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

    function shift(n) {
        const d = new Date(year, month + n, 1)
        year = d.getFullYear()
        month = d.getMonth()
    }

    function reset() {
        today = new Date()
        year = today.getFullYear()
        month = today.getMonth()
    }

    // ---------- Title bar ----------
    Rectangle {
        id: titleBar
        x: 1; y: 1
        width: parent.width - 2
        height: 18
        gradient: Gradient95 {
            orientation: Gradient.Horizontal
        }

        Txt {
            x: 4
            anchors.verticalCenter: parent.verticalCenter
            text: "Calendar"
            color: "#ffffff"
            font.bold: true
        }

        Button95 {
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 14
            text: "x"
            bold: true
            textAlign: Text.AlignHCenter
            onClicked: root.closeRequested()
        }
    }

    // ---------- Month navigation ----------
    Button95 {
        x: 6; y: 24
        width: 22; height: 22
        text: "<"
        bold: true
        textAlign: Text.AlignHCenter
        onClicked: root.shift(-1)
    }
    Txt {
        x: 34; y: 24
        width: parent.width - 68
        height: 22
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
        text: Qt.locale().monthName(root.month, Locale.LongFormat) + " " + root.year
    }
    Button95 {
        x: parent.width - 6 - 22; y: 24
        width: 22; height: 22
        text: ">"
        bold: true
        textAlign: Text.AlignHCenter
        onClicked: root.shift(1)
    }

    // ---------- Day grid ----------
    Bevel {
        x: 6; y: 50
        width: parent.width - 12
        height: 162
        sunken: true

        Rectangle { anchors.fill: parent; color: "#ffffff" }

        Grid {
            x: 2; y: 2
            columns: 7

            // weekday headers
            Repeater {
                model: 7
                Item {
                    width: 28; height: 22
                    Txt {
                        anchors.centerIn: parent
                        font.bold: true
                        text: Qt.locale().dayName((root.weekStart + index) % 7, Locale.ShortFormat).slice(0, 2)
                    }
                }
            }

            // day cells
            Repeater {
                model: 42
                Rectangle {
                    readonly property int day: index - root.lead + 1
                    readonly property bool valid: day >= 1 && day <= root.daysInMonth
                    readonly property bool isToday: valid
                        && root.year === root.today.getFullYear()
                        && root.month === root.today.getMonth()
                        && day === root.today.getDate()

                    width: 28; height: 22
                    color: isToday ? "#000080" : "transparent"

                    Txt {
                        anchors.centerIn: parent
                        text: parent.valid ? parent.day : ""
                        color: parent.isToday ? "#ffffff" : "#000000"
                    }
                }
            }
        }
    }
}
