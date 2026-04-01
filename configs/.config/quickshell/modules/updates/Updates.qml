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

    Rectangle {
    	anchors.fill: parent
    	color: mouseArea.containsMouse ? Backend.Theme.bg_hover : "transparent"
    	radius: 4
    }

    Text {
        anchors.centerIn: parent
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        color: Backend.Theme.fg
        text: "󰏗 " + Backend.SystemData.updates
    }

    MouseArea {
	id: mouseArea
	hoverEnabled: true
        anchors.fill: parent
        onClicked: runUpdate.running = true
    }
}
