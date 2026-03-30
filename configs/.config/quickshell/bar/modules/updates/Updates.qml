import QtQuick
import Quickshell
import Quickshell.Io
import "../../backend/" as Backend

Item {
    width: Backend.SystemData.updates > 0 ? 40 : 0
    height: parent.height
    visible: Backend.SystemData.updates > 0

    Process {
        id: runUpdate
        command: ["bash", "-c", "kitty -e paru"]
    }

    Text {
        anchors.centerIn: parent
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        color: "white"
        text: "󰏗 " + Backend.SystemData.updates
    }

    MouseArea {
        anchors.fill: parent
        onClicked: runUpdate.running = true
    }
}
