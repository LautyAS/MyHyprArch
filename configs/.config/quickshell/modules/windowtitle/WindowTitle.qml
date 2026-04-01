import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../backend" as Backend

Item {
    width: 600
    height: parent.height

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
        color: Backend.Theme.fg
        font.family: "Maple Mono NF"
        font.pixelSize: 12
        elide: Text.ElideRight
    }
}
