import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Effects

ShellRoot {
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Variants {
        model: Quickshell.screens.filter(s => s.name === "DP-1")

        Scope {
        id: scope
        required property var modelData

        // Clicking anywhere outside the taskbar/popups closes open popups.
        // Set to false to disable (popups then close only via the taskbar).
        readonly property bool dismissOnOutsideClick: true

        readonly property bool anyMenuOpen:
            startMenu.visible || calendar.visible || trayMenu.visible || taskMenu.visible || gamesMenu.visible

        // Full-screen transparent window used to catch outside clicks.
        // It is created BEFORE the panel and always mapped, so it stays stacked
        // below the panel and its popups. While no popup is open its input
        // region is empty, so clicks pass straight through to your windows.
        PanelWindow {
            id: catcher
            screen: scope.modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            visible: scope.dismissOnOutsideClick
            mask: scope.anyMenuOpen ? null : emptyMask

            Region { id: emptyMask }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: panel.closeAll()
            }
        }

        PanelWindow {
            id: panel
            screen: scope.modelData

            anchors { left: true; right: true; bottom: true }
            implicitHeight: 30
            color: "#c0c0c0"

            // Close every popup. Called before opening one, so clicking the
            // taskbar is how you dismiss things.
            function closeAll() {
                startMenu.visible = false
                calendar.visible = false
                trayMenu.close()
                taskMenu.close()
                gamesMenu.close()
            }

            function openGames(row) {
                closeGamesTimer.stop()
                if (gamesMenu.visible) return
                gamesMenu.alignTop = startMenu.height - row.mapToItem(null, 0, 0).y
                gamesMenu.openAt(startMenu.anchor.rect.x + startMenu.width, 1)
            }

            // Close the submenu after pointer moves to another Start menu row
            Timer {
                id: closeGamesTimer
                interval: 250
                onTriggered: if (!gamesMenu.hovered) gamesMenu.close()
            }

            // ---------- Task list order (drag to rearrange) ----------
            // ToplevelManager gives windows in its own order, so we keep our own
            // list: new windows are appended, closed ones removed, and dragging a
            // button moves its entry.
            ListModel {
                id: taskModel
                dynamicRoles: true
            }

            function syncTasks() {
                const live = ToplevelManager.toplevels.values
                for (let i = taskModel.count - 1; i >= 0; i--) {
                    if (live.indexOf(taskModel.get(i).toplevel) < 0)
                        taskModel.remove(i)
                }
                const have = []
                for (let i = 0; i < taskModel.count; i++)
                    have.push(taskModel.get(i).toplevel)
                for (const t of live) {
                    if (have.indexOf(t) < 0)
                        taskModel.append({ toplevel: t })
                }
            }

            Connections {
                target: ToplevelManager.toplevels
                function onValuesChanged() { panel.syncTasks() }
            }

            Component.onCompleted: syncTasks()

            // ---------- Taskbar background ----------
            Bevel {
                anchors.fill: parent
            }

            // right-click on empty taskbar area
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: event => {
                    const toggleOff = taskMenu.visible && taskMenu.owner === "background"
                    panel.closeAll()
                }
            }

            // ---------- Start button ----------
            Button95 {
                id: startButton
                x: 3
                y: 3
                width: 74
                height: parent.height - 6
                text: "Start"
                bold: true
                checked: startMenu.visible
                hoverEffect: true
                onClicked: {
                    const wasOpen = startMenu.visible
                    panel.closeAll()
                    startMenu.visible = !wasOpen
                }

                leftContent: Image {
                    source: Qt.resolvedUrl("start.png")
                    y: 1
                    width: 16
                    height: 16
                }
            }

            // ---------- Quick launch ----------
            Row {
                id: quickLaunch
                anchors.left: startButton.right
                anchors.leftMargin: 6
                y: 4
                height: parent.height - 8
                spacing: 5

                QuickLaunch95 { appId: "foot";    command: ["foot"] }
                QuickLaunch95 { appId: "firefox"; command: ["firefox"] }
            }

            // thin etched divider after the quick launch icons
            Item {
                id: qlDivider
                anchors.left: quickLaunch.right
                anchors.leftMargin: 5
                y: 4
                width: 2
                height: parent.height - 8
                Rectangle { x: 0; width: 1; height: parent.height; color: "#808080" }
                Rectangle { x: 1; width: 1; height: parent.height; color: "#ffffff" }
            }

            // ---------- Window list (drag buttons to reorder) ----------
            Row {
                id: taskRow
                anchors.left: qlDivider.right
                anchors.leftMargin: 4
                anchors.right: widgets.left
                anchors.rightMargin: 4
                y: 3
                height: parent.height - 6
                spacing: 3

                // neighbours slide out of the way while you drag
                move: Transition {
                    NumberAnimation { properties: "x"; duration: 120; easing.type: Easing.OutCubic }
                }

                Repeater {
                    model: taskModel

                    TaskButton95 {
                        id: taskButton
                        required property var toplevel
                        required property int index

                        row: taskRow
                        slotIndex: index
                        slotCount: taskModel.count
                        width: 225
                        height: taskRow.height

                        text: toplevel ? toplevel.title : ""
                        checked: toplevel ? toplevel.activated : false
                        hoverEffect: true
                        checkedFace: "#d9d9d9"

                        onDragStarted: panel.closeAll()
                        onMoveRequested: to => taskModel.move(index, to, 1)

                        onClicked: {
                            panel.closeAll()
                            const w = toplevel
                            if (!w) return
                            if (w.activated)
                                w.minimized = true
                            else
                                w.activate()
                        }

                        onRightClicked: {
                            const toggleOff = taskMenu.visible && taskMenu.owner === taskButton
                            panel.closeAll()
                            if (toggleOff) return
                            const w = toplevel
                            if (!w) return
                            taskMenu.items = [
                                { text: w.minimized ? "Restore" : "Minimize", trigger: () => {
                                    if (w.minimized) { w.minimized = false; w.activate() }
                                    else w.minimized = true
                                } },
                                { text: w.maximized ? "Restore Size" : "Maximize", trigger: () => {
                                    w.maximized = !w.maximized
                                } },
                                { isSeparator: true },
                                { text: "Close", trigger: () => w.close() }
                            ]
                            taskMenu.owner = taskButton
                            taskMenu.openFor(taskButton)
                        }

                        leftContent: AppIcon {
                            appId: taskButton.toplevel ? taskButton.toplevel.appId : ""
                            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                        }
                    }
                }
            }

            Row {
                id: widgets
                anchors.right: tray.left
                height: parent.height
                width: 130
                CpuWidget95 {
                    y: 6
                    fg: "#000"
                }
                VolumeWidget95 {
                    y: 6
                    fg: "#000"
                }
            }

            // ---------- System tray (dark sunken well) ----------
            // Many tray icons are designed for dark backgrounds (Discord, Steam, ...),
            // so the well is dark. For the classic gray look set `face: "#c0c0c0"` here
            // and `fg: "#000000"` on the two widgets.
            Rectangle {
                id: tray
                anchors.right: clockArea.left
                anchors.rightMargin: 4
                y: 3
                width: trayRow.width + 16
                height: parent.height - 6
                border.color: "#aaa"
                border.width: 1
                radius: 5

                color: "#303040"

                Row {
                    id: trayRow
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: SystemTray.items

                        TrayItem95 {
                            id: trayIcon
                            required property var modelData
                            trayItem: modelData

                            onMenuRequested: {
                                const toggleOff = trayMenu.visible && trayMenu.owner === trayIcon
                                panel.closeAll()
                                if (!toggleOff) {
                                    trayMenu.handle = modelData.menu
                                    trayMenu.owner = trayIcon
                                    trayMenu.openFor(trayIcon)
                                }
                            }
                        }
                    }
                }
            }

            // ---------- Clock (flat, click for calendar) ----------
            Item {
                id: clockArea
                anchors.right: parent.right
                anchors.rightMargin: 6
                y: 4
                width: 64
                height: parent.height - 8

                Txt {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "HH:mm:ss")
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const wasOpen = calendar.visible
                        panel.closeAll()
                        calendar.visible = !wasOpen
                    }
                }

                Tooltip95 {
                    anchors.fill: parent
                    text: Qt.formatDateTime(clock.date, "ddd dd.MM.yyyy")
                }
            }

            // ---------- Context menus ----------
            Menu95 {
                id: trayMenu
                anchor.window: panel
                growLeft: true
            }

            Menu95 {
                id: taskMenu
                anchor.window: panel
            }

            DesktopFolderMenu95 {
                id: gamesMenu
                anchor.window: panel
                folder: Quickshell.env("HOME") + "/.local/share/applications/steam"
                emptyText: "(no games found)"
                onActivated: panel.closeAll()
            }

            // ---------- Calendar popup ----------
            PopupWindow {
                id: calendar
                anchor.window: panel
                anchor.rect.x: panel.width - 6
                anchor.rect.y: 0
                anchor.rect.width: 1
                anchor.rect.height: 1
                anchor.edges: Edges.Top | Edges.Right
                anchor.gravity: Edges.Top | Edges.Left

                implicitWidth: cal.implicitWidth
                implicitHeight: cal.implicitHeight
                color: "#c0c0c0"

                onVisibleChanged: if (visible) cal.reset()

                Calendar95 {
                    id: cal
                    anchors.fill: parent
                    onCloseRequested: calendar.visible = false
                }
            }

            // ---------- Start menu ----------
            PopupWindow {
                id: startMenu
                anchor.window: panel
                anchor.rect.x: 2
                anchor.rect.y: 0
                anchor.rect.width: 1
                anchor.rect.height: 1
                anchor.edges: Edges.Top | Edges.Left
                anchor.gravity: Edges.Top | Edges.Right

                implicitWidth: 200
                implicitHeight: entries.height + 6
                color: "#c0c0c0"

                Bevel {
                    anchors.fill: parent

                    // blue side banner
                    Rectangle {
                        id: banner
                        x: 0
                        y: 0
                        width: 24
                        height: parent.height - 1
                        gradient: Gradient95 { reversed: true }
                        Txt {
                            text: "Linux 95"
                            color: "#c0c0c0"
                            font.bold: true
                            font.pixelSize: 16
                            rotation: -90
                            transformOrigin: Item.TopLeft
                            x: 3
                            y: parent.height - 6
                        }
                    }

                    Column {
                        id: entries
                        anchors.left: banner.right
                        anchors.right: parent.right
                        y: 1

                        MenuEntry {
                            width: parent.width
                            label: "Files"
                            onEntered: closeGamesTimer.restart()
                            onTriggered: { Quickshell.execDetached(["thunar"]); startMenu.visible = false }
                        }
                        MenuEntry {
                            id: gamesEntry
                            width: parent.width
                            label: "Games"
                            hasChildren: true
                            active: gamesMenu.visible
                            onEntered: panel.openGames(gamesEntry)
                            onTriggered: panel.openGames(gamesEntry)
                        }

                        // divider
                        Item {
                            width: parent.width
                            height: 6
                            Rectangle { x: 4; y: 2; width: parent.width - 8; height: 1; color: "#808080" }
                            Rectangle { x: 4; y: 3; width: parent.width - 8; height: 1; color: "#ffffff" }
                        }

                        MenuEntry {
                            width: parent.width
                            label: "Suspend"
                            onEntered: closeGamesTimer.restart()
                            onTriggered: { Quickshell.execDetached(["loginctl", "suspend"]); startMenu.visible = false }
                        }
                    }
                }
            }
        }
        }
    }
}
