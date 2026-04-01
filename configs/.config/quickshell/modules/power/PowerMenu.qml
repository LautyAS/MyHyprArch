import QtQuick
import "../../backend" as Backend

Item {
    width: 20
    height: parent.height

    signal toggleMenu

    Rectangle {
    	anchors.fill: parent
    	color: mouseArea.containsMouse ? Backend.Theme.bg_hover : "transparent"
    	radius: 4
    }

    Text {
        anchors.centerIn: parent
        text: "⏻"
        font.pixelSize: 14
        color: Backend.Theme.fg
    }

    MouseArea {
	id: mouseArea
	hoverEnabled: true
        anchors.fill: parent
        onClicked: toggleMenu()
    }
}
