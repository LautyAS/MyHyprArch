import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    width: 600
    height: parent.height

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
        color: "#ffffff"
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        elide: Text.ElideRight
    }
}
