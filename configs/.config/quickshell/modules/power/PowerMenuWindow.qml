import QtQuick
import Quickshell
import Quickshell.Io
import "../../backend" as Backend

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
        color: "#000000aa"

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
        color: Backend.Theme.bg
        //border.color: "#333"
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
                    color: Backend.Theme.bg_alt

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: Backend.Theme.fg
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: parent.color = Backend.Theme.bg_hover
                        onExited: parent.color = Backend.Theme.bg_alt

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
