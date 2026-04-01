pragma Singleton
import QtQuick

QtObject {
    id: theme

    property color bg
    property color bg_alt
    property color bg_hover
    property color fg
    property color fg_dim
    property color accent
    property color red
    property color green
    property color yellow
    property color border

    function load() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///home/lauti/.config/quickshell/colors/current.json?t=" + Date.now(), false)
        xhr.send()

        if (xhr.status === 200) {
            var json = JSON.parse(xhr.responseText)

            bg = json.bg
            bg_alt = json.bg_alt
            bg_hover = json.bg_hover
            fg = json.fg
            fg_dim = json.fg_dim
            accent = json.accent
            red = json.red
            green = json.green
            yellow = json.yellow
            border = json.border

            console.log("Theme loaded:", bg)
        } else {
            console.log("Failed to load theme:", xhr.status)
        }
    }

    Component.onCompleted: load()
}
