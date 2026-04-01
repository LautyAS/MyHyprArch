pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: audio
    visible: false

    property int volume: -1
    property bool muted: false

    function refresh() {
        volProc.running = true
    }

    function setVolume(percent) {
        percent = Math.max(0, Math.min(150, percent))
        volume = percent
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", percent + "%"])
    }

    function toggleMute() {
        muted = !muted
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    }

    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ ; echo"]
        stdout: SplitParser {
            onRead: data => {
                var v = data.match(/Volume:\s([0-9.]+)/)
                if (v)
                    volume = Math.round(parseFloat(v[1]) * 100)

                muted = data.indexOf("MUTED") !== -1
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: refresh()
    }

    Component.onCompleted: refresh()
}
