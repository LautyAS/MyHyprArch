//@ pragma UseQApplication
// Bar

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import "../../backend/" as Backend
import "../volume/"
import "../brightness/"
import "../battery/"
import "../system/"
import "../style/"
import "../updates/"
import "../power/"
import "../tray/"
import "../workspaces/"
import "../windowtitle/"
import "../clock/"

PanelWindow {
    id: panel

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30

    margins {
        top: 0
        left: 0
        right: 0
    }
    
    PowerMenuWindow {
    	id: powerMenu
    }
    
    Rectangle {
        id: bar
        anchors.fill: parent
        color: Backend.Theme.bg
        opacity: 1
	
	Row {
	    id: leftSide
	    anchors {
		left: parent.left
		verticalCenter: parent.verticalCenter
		leftMargin: 8
	    }

	    spacing: 8

	    Workspaces {}
	    WindowTitle {}
    	}
	
	Item {
	    width: 1
	    height: 1
	    Layout.fillWidth: true
	}

        Row {
            id: rightSide
            spacing: 8

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 10
            }

	    Updates {}

	    Theme {}
	    Wallpaper {}
	    //Mode {}

	    System {}

	    Battery {}

	    Brightness {
    		visible: Backend.BrightnessData.hasBrightness
	    }
	    
	    Item {
		width: 1
		height: 1
	    }

	    Volume {}

	    Item {
		width: 1
		height: 1
	    }

	    Tray {
		panelWindow: panel
	    }

	    Clock {}

	    PowerMenu {
    		onToggleMenu: powerMenu.visible = !powerMenu.visible
	    }
	}
    }
}
