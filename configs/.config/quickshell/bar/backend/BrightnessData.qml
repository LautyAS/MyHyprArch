pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: bright
    visible: false

    property int brightness: -1
    property int _current: 0
    property int _max: 1
    property bool hasBrightness: false

    Process {
    	id: detectProc
    	command: ["/usr/bin/bash", "-c", "brightnessctl -l | grep backlight"]
    	stdout: SplitParser {
            onRead: data => {
            	if (data.length > 0) {
                    hasBrightness = true
                    refresh()
            	} else {
                    hasBrightness = false
            	}
            }
    	}
    }

    function updateBrightness() {
        if (_max > 0 && _current >= 0) {
            var percent = Math.round((_current / _max) * 100)
            if (!isNaN(percent))
                brightness = percent
        }
    }

    function refresh() {
        getProc.running = true
    }

    function setBrightness(percent) {
    	if (!hasBrightness || !ready)
            return
        
	if (percent < 0)
            return

        percent = Math.max(5, Math.min(100, percent))

        // Actualizamos UI primero (instantáneo)
        brightness = percent

        // Aplicamos brillo real
        setProc.command = ["/usr/bin/brightnessctl", "set", percent + "%"]
        setProc.running = true
    }

    // Obtener brillo actual
    Process {
        id: getProc
        command: ["/usr/bin/brightnessctl", "get"]
        stdout: SplitParser {
            onRead: data => {
                var val = parseInt(data)
                if (!isNaN(val)) {
                    _current = val
                    maxProc.running = true
                }
            }
        }
    }

    // Obtener brillo máximo
    Process {
        id: maxProc
        command: ["/usr/bin/brightnessctl", "max"]
        stdout: SplitParser {
            onRead: data => {
                var val = parseInt(data)
                if (!isNaN(val)) {
                    _max = val
                    updateBrightness()
                }
            }
        }
    }

    // Aplicar brillo
    Process {
        id: setProc
    }

    // Sync cada 5s (por si cambian con teclas del teclado)
    Timer {
        interval: 5000
        running: hasBrightness
        repeat: true
        onTriggered: refresh()
    }

    Component.onCompleted: {
    	detectProc.running = true
    }
}
