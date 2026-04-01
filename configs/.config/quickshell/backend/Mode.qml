pragma Singleton
import QtQuick

QtObject {
    id: modeObj
    property string mode: "dark"

    function load() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///home/lauti/.config/quickshell/colors/.current_mode?t=" + Date.now(), false)
        xhr.send()

        if (xhr.status === 200) {
            mode = xhr.responseText.trim()
            console.log("Mode loaded:", mode)
        }
    }

    Component.onCompleted: load()
}
