import QtQuick
import Quickshell
import Quickshell.Io

Item {
    width: 12
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter

    Process {
        id: nextWall
        command: ["bash", "-c", "~/.config/hypr/scripts/set-wallpaper.sh next"]
    }

    Process {
        id: prevWall
        command: ["bash", "-c", "~/.config/hypr/scripts/set-wallpaper.sh prev"]
    }

    Text {
        anchors.centerIn: parent
        text: ""
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        color: "white"
    }

    MouseArea {
    	anchors.fill: parent
    	acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    	onPressed: mouse => {
            if (mouse.button === Qt.LeftButton)
            	nextWall.running = true
            else if (mouse.button === Qt.RightButton)
            	prevWall.running = true
    	}

    	onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
            	prevWall.running = true
            else
            	nextWall.running = true
    	}
    }
}
