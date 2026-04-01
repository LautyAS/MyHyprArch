import QtQuick
import Quickshell
import Quickshell.Io
import "../../backend/" as Backend

Item {
    width: 18
    height: parent.height

    Process {
        id: setTheme
        command: []

        function onFinished() {
            Backend.Theme.load()
            Backend.Mode.load()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? Backend.Theme.bg_hover : "transparent"
        radius: 4
    }

    Text {
        anchors.centerIn: parent
        text: Backend.Mode.mode === "dark" ? "" : ""
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        color: Backend.Theme.fg
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            var newMode = Backend.Mode.mode === "dark" ? "light" : "dark"

            setTheme.command = [
                "bash",
                "-c",
                "~/.config/hypr/scripts/set-theme.sh " + newMode
            ]

            setTheme.running = true
        }
    }
}
