import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: trayRow

    property var panelWindow

    spacing: 8
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
        model: SystemTray.items

	delegate: Image { 
	    required property var modelData 

	    width: 18 
	    height: 18 
	    anchors.verticalCenter: parent.verticalCenter 

	    source: modelData.icon 
	    sourceSize.width: 24 
	    sourceSize.height: 24 
	    fillMode: Image.PreserveAspectFit 

	    MouseArea { 
		anchors.fill: parent 
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton 
		onPressed: mouse => { 
		    if (mouse.button === Qt.LeftButton) { 
			modelData.activate() 
		    } 
		    else if (mouse.button === Qt.MiddleButton) { 
			if (modelData.secondaryActivate) 
			modelData.secondaryActivate() 
		    } 
		    else if (mouse.button === Qt.RightButton && modelData.hasMenu) { 
			var pos = mapToGlobal(mouse.x, mouse.y) 
			modelData.display(trayRow.panelWindow, pos.x, pos.y) 
		    } 
		} 

		onWheel: wheel => { 
		    if (modelData.scroll) modelData.scroll(wheel.angleDelta.y, false) 
	    	} 
	    } 
    	}
    }
}
