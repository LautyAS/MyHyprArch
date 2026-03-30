import QtQuick

Item {
    width: 20
    height: parent.height

    signal toggleMenu

    Text {
        anchors.centerIn: parent
        text: "⏻"
        font.pixelSize: 14
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: toggleMenu()
    }
}
