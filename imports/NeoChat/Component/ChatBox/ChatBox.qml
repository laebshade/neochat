/* SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.de>
 * SPDX-FileCopyrightText: 2020 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import Qt.labs.platform 1.0 as Platform
import org.kde.kirigami 2.14 as Kirigami

import NeoChat.Component.ChatBox 1.0
import org.kde.neochat 1.0

Item {
    id: root
//     property bool isReaction: false

    readonly property bool isReply: replyEventId.length > 0
    property var replyUser
    property string replyEventId: ""
    property string replyContent: ""

    readonly property bool hasAttachment: attachmentPath.length > 0
    property string attachmentPath: ""

    property alias inputFieldText: chatBar.inputFieldText

    readonly property bool isEdit: editEventId.length > 0
    property string editEventId: ""

    readonly property bool hasRoom: Boolean(currentRoom)

    Kirigami.Theme.colorSet: Kirigami.Theme.View

    implicitWidth: {
        let w = 0
        for(let i = 0; i < visibleChildren.length; ++i) {
            w = Math.max(w, Math.ceil(visibleChildren[i].implicitWidth))
        }
        return w
    }
    implicitHeight: {
        let h = 0
        for(let i = 0; i < visibleChildren.length; ++i) {
            h += Math.ceil(visibleChildren[i].implicitHeight)
        }
        return h
    }

    Behavior on height {
        NumberAnimation {
            property: "height"
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.OutCubic
        }
    }

    Kirigami.Separator {
        id: emojiPickerLoaderSeparator
        visible: emojiPickerLoader.visible
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.bottom: emojiPickerLoader.top
        z: 1
    }

    Loader {
        id: emojiPickerLoader
        active: visible
        visible: false
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.bottom: emojiAndReplySeparator.top
        Behavior on height {
            NumberAnimation {
                property: "height"
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Kirigami.Separator {
        id: emojiAndReplySeparator
        visible: replyPane.visible
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.bottom: replyPane.top
    }

    ReplyPane {
        id: replyPane
        visible: isReply || isEdit
        isEdit: root.isEdit
        user: root.replyUser
        content: root.replyContent
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.bottom: replyAndAttachmentSeparator.top
        Behavior on height {
            NumberAnimation {
                property: "height"
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Kirigami.Separator {
        id: replyAndAttachmentSeparator
        visible: attachmentPane.visible
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.bottom: attachmentPane.top
    }

    AttachmentPane {
        id: attachmentPane
        attachmentPath: root.attachmentPath
        visible: hasAttachment
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.bottom: attachmentAndChatBarSeparator.top
        Behavior on height {
            NumberAnimation {
                property: "height"
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Kirigami.Separator {
        id: attachmentAndChatBarSeparator
        visible: chatBar.visible
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.bottom: chatBar.top
    }

    ChatBar {
        id: chatBar
        editEventId: root.editEventId
        visible: hasRoom
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.bottom: parent.bottom

        Behavior on height {
            NumberAnimation {
                property: "height"
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Connections {
        target: replyPane
        function onClearEditReplyTriggered() {
            if (isEdit) {
                clearEdit()
            }
            if (isReply) {
                clearReply()
            }
        }
    }

    Connections {
        target: attachmentPane
        function onClearAttachmentTriggered() {
            clearAttachment()
        }
    }

    Connections {
        target: chatBar
        function onAttachTriggered(localPath) {
            attach(localPath)
        }
//         function onClearAttachmentTriggered() {
//             clearAttachment()
//         }
        function onCloseAllTriggered() {
            closeAll()
        }
        function onMessageSent() {
            closeAll()
        }
    }

    function addText(text) {
        inputFieldText = inputFieldText + text
    }

    function insertText(str) {
        inputFieldText = inputFieldText.substr(0, inputField.cursorPosition) + str + inputFieldText.substr(inputField.cursorPosition)
    }

    function clearText() {
        inputFieldText = Qt.binding(() => { return currentRoom ? currentRoom.cachedInput : "" })
    }

    function focusInputField() {
        chatBar.inputFieldForceActiveFocusTriggered()
    }

    function edit(editContent, editEventId) {
        root.inputFieldText = editContent;
        root.editEventId = editEventId
        root.replyContent = editContent
    }

    function clearEdit() {
        clearText()
        clearReply()
        root.editEventId = "";
    }

    function attach(localPath) {
        attachmentPath = localPath
    }

    function clearAttachment() {
        attachmentPath = ""
    }

    function clearReply() {
        replyUser = null;
        root.replyContent = "";
        root.replyEventId = "";
    }

    function closeAll() {
        if (hasAttachment) {
            clearAttachment()
        }
        if (isEdit) {
            clearEdit()
        }
        if (isReply) {
            clearReply()
        }
        emojiPickerLoader.visible = false
    }
}
