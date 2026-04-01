import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../backend" as Backend

Row {
    id: workspacesRow
    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            visible: modelData.id > 0

            width: 12
            height: 22
            radius: 3
            color: modelData.focused ? Backend.Theme.bg_hover : Backend.Theme.bg_alt

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }

            Text {
                text: modelData.id
                anchors.centerIn: parent
                color: modelData.focused ? Backend.Theme.fg_dim : Backend.Theme.fg
                font.pixelSize: 10
                font.family: "Maple Mono NF"
            }
        }
    }
}
