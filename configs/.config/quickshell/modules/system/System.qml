import QtQuick
import "../../backend/" as Backend

Item {
    width: 144
    height: 24

    Text {
        anchors.centerIn: parent
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        color: Backend.Theme.fg
        text: " " + Backend.SystemData.cpu + "%   " + Backend.SystemData.ramText
    }
}
