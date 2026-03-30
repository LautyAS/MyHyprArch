import QtQuick
import Quickshell

Item {
    height: parent.height
    width: 128

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(clock.date, "MMM dd - hh:mm:ss")
        color: "#ffffff"
        font.family: "Maple Mono NF"
        font.pixelSize: 12
    }
}
