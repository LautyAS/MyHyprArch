pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: sys
    visible: false

    property int cpu: 0
    property int ram: 0
    property int updates: 0

    property int _prevIdle: 0
    property int _prevTotal: 0

    property int ramUsedMB: 0
    property int ramTotalMB: 0
    property string ramText: ""

    // CPU
    Process {
        id: cpuProc
        command: ["bash", "-c", "grep 'cpu ' /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/)

                var idle = parseInt(parts[4])
                var total = 0
                for (var i = 1; i < parts.length; i++)
                    total += parseInt(parts[i])

                var diffIdle = idle - _prevIdle
                var diffTotal = total - _prevTotal

                if (diffTotal > 0)
                    cpu = Math.round((1 - diffIdle / diffTotal) * 100)

                _prevIdle = idle
                _prevTotal = total
            }
        }
    }

    // RAM
    Process {
    id: ramProc
    command: ["bash", "-c", "free -m | grep Mem"]
    stdout: SplitParser {
        onRead: data => {
            var parts = data.trim().split(/\s+/)

            ramTotalMB = parseInt(parts[1])
            ramUsedMB = parseInt(parts[2])

            function format(mb) {
                if (mb >= 1024)
                    return (mb / 1024).toFixed(1) + "G"
                else
                    return mb + "M"
            }

            ramText = format(ramUsedMB) + "/" + format(ramTotalMB)
        }
    }
}
    // Updates
    Process {
        id: updOfficial
        command: ["bash", "-c", "checkupdates | wc -l"]
        stdout: SplitParser {
            onRead: data => updates = parseInt(data)
        }
    }

    Process {
        id: updAur
        command: ["bash", "-c", "paru -Qua | wc -l"]
        stdout: SplitParser {
            onRead: data => updates += parseInt(data)
        }
    }

    // Timers
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
        }
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: {
            updates = 0
            updOfficial.running = true
            updAur.running = true
        }
    }

    Component.onCompleted: {
        cpuProc.running = true
        ramProc.running = true
        updOfficial.running = true
        updAur.running = true
    }
}
