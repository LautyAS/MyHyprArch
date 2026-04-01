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

    // Detectar si hay dispositivo de brillo
    Process {
        id: detectProc
        command: ["/usr/bin/brightnessctl", "get"]

        onExited: {
            if (exitCode === 0) {
                hasBrightness = true
                refresh()
            } else {
                hasBrightness = false
                console.log("No brightness device")
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
        if (!hasBrightness)
            return
        getProc.running = true
    }

    function setBrightness(percent) {
        if (!hasBrightness)
            return

        percent = Math.max(5, Math.min(100, percent))
        brightness = percent

        setProc.command = ["/usr/bin/brightnessctl", "set", percent + "%"]
        setProc.running = true
    }

    // Valor actual
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

    // Valor máximo
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

    // Sync cada 5s
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
