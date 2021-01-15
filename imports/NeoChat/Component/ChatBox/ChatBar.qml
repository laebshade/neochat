/* SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.de>
 * SPDX-FileCopyrightText: 2020 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.14 as Kirigami

import org.kde.neochat 1.0

Loader {
    id: root
    property string replyEventId: ""
    property string editEventId: ""
    property string inputFieldText: currentRoom ? currentRoom.cachedInput : ""

    signal attachTriggered(string localPath)
    signal closeAllTriggered()
    signal emojiPickerToggled()
    signal inputFieldForceActiveFocusTriggered()
    signal messageSent()
    signal pasteImageTriggered()

    active: visible
    sourceComponent: Component {
        ToolBar {
            id: chatBar

            property alias isAutoCompleting: completionMenu.visible
            property alias autoCompleteModel: completionMenu.autoCompleteModel
            property alias autoCompleteBeginPosition: completionMenu.autoCompleteBeginPosition
            property alias autoCompleteEndPosition: completionMenu.autoCompleteEndPosition

            // store each user we autoComplete here, this will be helpful later to generate
            // the matrix.to links.
            // This use an hack to define: https://doc.qt.io/qt-5/qml-var.html#property-value-initialization-semantics
            property var userAutocompleted: ({})

            position: ToolBar.Footer
            Kirigami.Theme.inherit: true

            /* Using a custom background because some styles like Material
            * or Fusion might have ugly colors for a TextArea placed inside
            * of a toolbar. ToolBar is otherwise the closest QQC2 component
            * to what we want because of the padding and spacing values.
            */
            //background: Rectangle {
                //color: Kirigami.Theme.backgroundColor
            //}
            Component.onCompleted: {
                if (chatBar.background.hasOwnProperty("color")) {
                    chatBar.background.color = Qt.binding(() => { return Kirigami.Theme.backgroundColor })
                }
            }

            contentItem: RowLayout {
                spacing: chatBar.spacing

                ScrollView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.minimumHeight: inputField.implicitHeight
                    // lineSpacing is height+leading, so subtract leading once since leading only exists between lines.
                    Layout.maximumHeight: fontMetrics.lineSpacing * 8 - fontMetrics.leading
                                        + inputField.topPadding + inputField.bottomPadding

                    FontMetrics {
                        id: fontMetrics
                        property real emWidth: fontMetrics.boundingRect('M').width
                        font: inputField.font
                    }
                    TextArea {
                        id: inputField
                        focus: true
                        /* Some QQC2 styles will have their own predefined backgrounds for TextAreas.
                        * Make sure there is no background since we are using the ToolBar background.
                        *
                        * This could cause a problem if the QQC2 style was designed around TextArea
                        * background colors being very different from the QPalette::Base color.
                        * Luckily, none of the Qt QQC2 styles do that and neither do KDE's QQC2 styles.
                        */
                        background: null
                        leftPadding: Math.round(fontMetrics.descent * Math.max(fontMetrics.height/fontMetrics.emWidth, 1))
                        topPadding: 0
                        bottomPadding: 0

                        property real progress: 0
                        property bool autoAppeared: false
                        //property int lineHeight: contentHeight / lineCount

                        text: inputFieldText
                        placeholderText: editEventId.length > 0 ? i18n("Edit Message") : i18n("Write your message...")
                        verticalAlignment: TextEdit.AlignVCenter
                        horizontalAlignment: TextEdit.AlignLeft
                        wrapMode: Text.Wrap
                        selectByMouse: true

                        ChatDocumentHandler {
                            id: documentHandler
                            document: inputField.textDocument
                            cursorPosition: inputField.cursorPosition
                            selectionStart: inputField.selectionStart
                            selectionEnd: inputField.selectionEnd
                            room: currentRoom ?? null
                        }

                        Timer {
                            id: timeoutTimer
                            repeat: false
                            interval: 2000
                            onTriggered: {
                                repeatTimer.stop()
                                currentRoom.sendTypingNotification(false)
                            }
                        }

                        Timer {
                            id: repeatTimer
                            repeat: true
                            interval: 5000
                            triggeredOnStart: true
                            onTriggered: currentRoom.sendTypingNotification(true)
                        }

                        Keys.onReturnPressed: {
                            if (isAutoCompleting) {
                                chatBar.autoComplete();

                                isAutoCompleting = false;
                                return;
                            }
                            if (event.modifiers & Qt.ShiftModifier) {
                                inputField.insert(cursorPosition, "\n")
                            } else {
                                chatBar.postMessage()
                            }
                        }

                        Keys.onEscapePressed: {
                            root.closeAllTriggered()
                        }

                        Keys.onPressed: {
                            if (event.key === Qt.Key_PageDown) {
                                switchRoomDown();
                            } else if (event.key === Qt.Key_PageUp) {
                                switchRoomUp();
                            } else if (event.key === Qt.Key_V && event.modifiers & Qt.ControlModifier) {
                                root.pasteImage();
                            }
                        }

                        Keys.onBacktabPressed: {
                            if (event.modifiers & Qt.ControlModifier) {
                                switchRoomUp();
                                return;
                            }
                            if (isAutoCompleting) {
                                autoCompleteListView.decrementCurrentIndex();
                            }
                        }

                        Keys.onTabPressed: {
                            if (event.modifiers & Qt.ControlModifier) {
                                switchRoomDown();
                                return;
                            }
                            if (!isAutoCompleting) {
                                return;
                            }

                            // TODO detect moved cursor

                            // ignore first time tab was clicked so that user can select
                            // first emoji/user
                            if (autoAppeared === false) {
                                autoCompleteListView.incrementCurrentIndex()
                            } else {
                                autoAppeared = false;
                            }

                            chatBar.autoComplete();
                        }

                        Connections {
                            target: root
                            function onInputFieldForceActiveFocusTriggered() {
                                inputField.forceActiveFocus()
                            }
                        }

                        onTextChanged: {
                            timeoutTimer.restart()
                            repeatTimer.start()
                            currentRoom.cachedInput = text
                            autoAppeared = false;

                            const autocompletionInfo = documentHandler.getAutocompletionInfo();

                            if (autocompletionInfo.type === ChatDocumentHandler.Ignore) {
                                return;
                            }
                            if (autocompletionInfo.type === ChatDocumentHandler.None) {
                                isAutoCompleting = false;
                                autoCompleteListView.currentIndex = 0;
                                return;
                            }

                            if (autocompletionInfo.type === ChatDocumentHandler.User) {
                                autoCompleteModel = currentRoom.getUsers(autocompletionInfo.keyword);
                            } else {
                                autoCompleteModel = emojiModel.filterModel(autocompletionInfo.keyword);
                            }

                            if (autoCompleteModel.length === 0) {
                                isAutoCompleting = false;
                                autoCompleteListView.currentIndex = 0;
                                return;
                            }
                            isAutoCompleting = true
                            autoAppeared = true;
                            autoCompleteEndPosition = cursorPosition
                        }
                    }
                }

//                 ToolButton {
//                     visible: editEventId.length > 0
//                     icon.name: "dialog-cancel"
//                     onClicked: clearEditReply();
//                 }

                Item {
                    visible: !isReply && (!hasAttachment || uploadingBusySpinner.running)
                    implicitWidth: uploadButton.implicitWidth
                    implicitHeight: uploadButton.implicitHeight
                    ToolButton {
                        id: uploadButton
                        anchors.fill: parent
                        // Matrix does not allow sending attachments in replies
                        visible: !isReply && !hasAttachment && !uploadingBusySpinner.running
                        icon.name: "mail-attachment"
                        text: i18n("Attach an image or file")
                        display: AbstractButton.IconOnly

                        onClicked: {
                            if (Clipboard.hasImage) {
                                attachDialog.open()
                            } else {
                                var fileDialog = openFileDialog.createObject(ApplicationWindow.overlay)
                                fileDialog.chosen.connect((path) => {
                                    if (!path) { return }
                                    root.attachTriggered(path)
                                })
                                fileDialog.open()
                            }
                        }

                        ToolTip.text: text
                        ToolTip.visible: hovered
                    }
                    BusyIndicator {
                        id: uploadingBusySpinner
                        anchors.fill: parent
                        visible: running
                        running: currentRoom && currentRoom.hasFileUploading
                    }
                }

                ToolButton {
                    id: emojiButton
                    icon.name: "preferences-desktop-emoticons"
                    text: i18n("Add an Emoji")
                    display: AbstractButton.IconOnly
                    checkable: true
                    onToggled: root.emojiPickerToggled()

                    ToolTip.text: text
                    ToolTip.visible: hovered
                }

                ToolButton {
                    id: sendButton
                    icon.name: "document-send"
                    text: i18n("Send message")
                    display: AbstractButton.IconOnly

                    onClicked: {
                        chatBar.postMessage()
                    }

                    ToolTip.text: text
                    ToolTip.visible: hovered
                }
            }

            Action {
                id: pasteAction
                shortcut: StandardKey.Paste
                onTriggered: {
                    if (Clipboard.hasImage) {
                        root.pasteImageTriggered();
                    }
                    activeFocusItem.paste();
                }
            }

            CompletionMenu {
                id: completionMenu
                parent: chatBar // Don't put this in the contentItem
                visible: false
                width: parent.width
                y: root.parent.height > Kirigami.Units.gridUnit * 10 ? -height : Math.min(-height, -root.parent.height + root.height - height)
                Behavior on height {
                    NumberAnimation {
                        property: "height"
                        duration: Kirigami.Units.shortDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }

            function pasteImage() {
                let localPath = Platform.StandardPaths.writableLocation(Platform.StandardPaths.CacheLocation) + "/screenshots/" + (new Date()).getTime() + ".png";
                if (!Clipboard.saveImage(localPath)) {
                    return;
                }
                root.attachTriggered(localPath)
            }

            function postMessage() {
                roomManager.actionsHandler.postMessage(inputField.text.trim(), attachmentPath,
                    replyEventId, editEventId, chatBar.userAutocompleted);
                currentRoom.markAllMessagesAsRead();
                inputField.clear();
                inputField.text = Qt.binding(() => {
                    return currentRoom ? currentRoom.cachedInput : "";
                });
                root.messageSent()
            }

            function autoComplete() {
                documentHandler.replaceAutoComplete(autoCompleteListView.currentItem.displayText)
                // Unfortunally it doesn't
                if (!autoCompleteListView.currentItem.isEmoji) {
                    chatBar.userAutocompleted[completionMenu.contentChildren[completionMenu.currentIndex].displayText] = autoCompleteListView.currentItem.userId;
                }
            }
        }
    }
}
