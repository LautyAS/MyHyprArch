import QtQuick
import Quickshell
import Quickshell.Io

Item {
    width: 12
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter

    property string mode: "dark"

    Process {
        id: getMode
        command: ["bash", "-c", "cat ~/.config/hypr/state/mode"]
        stdout: SplitParser {
            onRead: data => mode = data.trim()
        }
        running: true
    }

    Process {
        id: toggleMode
        command: ["bash", "-c", "~/.config/hypr/scripts/set-mode.sh toggle"]
    }

    Text {
        anchors.centerIn: parent
        text: mode === "dark" ? "" : ""
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        color: "white"
    }

    MouseArea {
    	anchors.fill: parent
    	acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    	onPressed: mouse => {
            toggleMode.running = true
            getMode.running = true
    	}
    }
}
