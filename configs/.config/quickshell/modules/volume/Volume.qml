import QtQuick
import Quickshell
import "../../backend/" as Backend

Item {
    width: 40
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter
	
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

        text: {
            if (Backend.AudioData.muted)
                return "󰖁 " + Backend.AudioData.volume + "%"

            if (Backend.AudioData.volume < 30)
                return " " + Backend.AudioData.volume + "%"

            if (Backend.AudioData.volume < 70)
                return " " + Backend.AudioData.volume + "%"

            return " " + Backend.AudioData.volume + "%"
        }
    }

    MouseArea {
	id: mouseArea
        anchors.fill: parent
	acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
	hoverEnabled: true

        onPressed: mouse => {
            if (mouse.button === Qt.RightButton) {
                Backend.AudioData.toggleMute()
            }

            if (mouse.button === Qt.LeftButton) {
                Quickshell.execDetached(["pavucontrol"])
            }

            if (mouse.button === Qt.MiddleButton) {
                Backend.AudioData.setVolume(50)
            }
        }

        onWheel: wheel => {
            var step = 5
            var current = Backend.AudioData.volume

            if (wheel.angleDelta.y > 0)
                Backend.AudioData.setVolume(current + step)
            else
                Backend.AudioData.setVolume(current - step)
	}
    }
}
