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
        text: Backend.BrightnessData.brightness >= 0
              ? "󰃠 " + Backend.BrightnessData.brightness + "%"
              : "󰃠 --"
    }

    MouseArea {
	id: mouseArea
	hoverEnabled: true
        anchors.fill: parent

        onWheel: event => {
            var current = Backend.BrightnessData.brightness
            if (current < 0)
                return

            var step = 5

            if (event.angleDelta.y > 0)
                Backend.BrightnessData.setBrightness(current + step)
            else
                Backend.BrightnessData.setBrightness(current - step)
        }

        onPressed: mouse => {
            var current = Backend.BrightnessData.brightness
            if (current < 0)
                return

            if (mouse.button === Qt.MiddleButton)
                Backend.BrightnessData.setBrightness(50)

            if (mouse.button === Qt.RightButton)
                Backend.BrightnessData.setBrightness(5)
        }
    }
}
