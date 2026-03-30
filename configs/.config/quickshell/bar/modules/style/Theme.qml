import QtQuick
import Quickshell
import Quickshell.Io

Item {
    width: 12
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter

    Process {
        id: setThemeNext
        command: ["bash", "-c", "~/.config/hypr/scripts/set-theme.sh next"]
    }

    Process {
        id: setThemePrev
        command: ["bash", "-c", "~/.config/hypr/scripts/set-theme.sh prev"]
    }

    Text {
        anchors.centerIn: parent
        text: "󰉼"
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        color: "white"
    }

    MouseArea {
    	anchors.fill: parent
    	acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    	onPressed: mouse => {
            if (mouse.button === Qt.LeftButton)
            	setThemeNext.running = true
            else if (mouse.button === Qt.RightButton)
            	setThemePrev.running = true
    	}

    	onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
            	setThemePrev.running = true
            else
            	setThemeNext.running = true
    	}
    }
}
