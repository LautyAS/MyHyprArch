import QtQuick
import "../../backend/" as Backend

Item {
    width: Backend.BatteryData.percent > 0 ? 40 : 0
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter
    visible: Backend.BatteryData.percent > 0

    Text {
        anchors.centerIn: parent
        font.family: "Maple Mono NF"
        font.pixelSize: 12
	color: Backend.Theme.fg
	
        text: {
            if (Backend.BatteryData.status === "Charging")
                return "󰂄 " + Backend.BatteryData.percent + "%"
            else
                return "󰁹 " + Backend.BatteryData.percent + "%"
        }
    }
}
