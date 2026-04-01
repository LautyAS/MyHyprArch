//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Wayland
import "./modules/bar"
import "./backend" as Backend

ShellRoot {
	Component.onCompleted: {
    Backend.Theme.load()
}
    Instantiator {
        model: Quickshell.screens

        delegate: PanelWindow {
            required property var modelData

            screen: modelData
            anchors.top: true
	    implicitHeight: 0
            color: "transparent"

            Bar {
                screen: modelData
            }
        }
    }
}
