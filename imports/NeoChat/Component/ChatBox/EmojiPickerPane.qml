import NeoChat.Component.Emoji 1.0

Loader {
    id: root
    active: visible
    visible: false
    width: parent.width
    height: visible ? implicitHeight : 0
    y: emojiAndCompletionSeparator.y - height
    Behavior on height {
        NumberAnimation {
            property: "height"
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.OutCubic
        }
    }
}
