import QtQuick
import Quickshell
import Quickshell.Io

Window {
    id: menu
    title: "quickshell-powermenu"
    visible: false
    color: "transparent"
    //focus: true

    // Process global
    Process {
        id: proc
    }

    // ESC cierra
    Shortcut {
        sequence: "Escape"
        onActivated: menu.visible = false
    }

    // Fondo oscuro
    Rectangle {
        anchors.fill: parent
        color: "#00000088"

        MouseArea {
            anchors.fill: parent
            onClicked: menu.visible = false
        }
    }

    // Caja del menú
    Rectangle {
        width: 220
        height: 240
        radius: 12
        color: "#1a1a1a"
        border.color: "#333"
        anchors.centerIn: parent
        z: 10

        Column {
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: [
                    { label: "Apagar",    cmd: ["/usr/bin/systemctl","poweroff"] },
                    { label: "Reiniciar", cmd: ["/usr/bin/systemctl","reboot"] },
                    { label: "Suspender", cmd: ["/usr/bin/systemctl","suspend"] },
                    { label: "Cerrar Sesión",     cmd: ["/usr/bin/hyprctl","dispatch","exit"] }
                ]

                delegate: Rectangle {
                    width: 180
                    height: 40
                    radius: 8
                    color: "#2a2a2a"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: parent.color = "#3a3a3a"
                        onExited: parent.color = "#2a2a2a"

                        onClicked: {
                            console.log("CLICK:", modelData.label)

                            proc.running = false
                            proc.command = modelData.cmd
                            proc.running = true

                            menu.visible = false
                        }
                    }
                }
            }
        }
    }
}
