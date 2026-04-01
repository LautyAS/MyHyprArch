pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: bat
    visible: false

    property int percent: 0
    property string status: ""

    Process {
        id: batProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity"]
        stdout: SplitParser {
            onRead: data => percent = parseInt(data)
        }
    }

    Process {
        id: statProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/status"]
        stdout: SplitParser {
            onRead: data => status = data.trim()
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            batProc.running = true
            statProc.running = true
        }
    }

    Component.onCompleted: {
        batProc.running = true
        statProc.running = true
    }
}
