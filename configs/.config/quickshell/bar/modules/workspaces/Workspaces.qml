import QtQuick
import Quickshell
import Quickshell.Hyprland

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
            color: modelData.focused ? "#4a4a4a" : "#282828"

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }

            Text {
                text: modelData.id
                anchors.centerIn: parent
                color: modelData.focused ? "#ffffff" : "#cccccc"
                font.pixelSize: 10
                font.family: "Maple Mono NF"
            }
        }
    }
}
