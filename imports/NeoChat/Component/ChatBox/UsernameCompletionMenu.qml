/* SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.de>
 * SPDX-FileCopyrightText: 2020 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.14 as Kirigami

Loader {
    id: root
    property bool isCompletingEmoji: false
    property var model
    property int beginPosition
    property int endPosition
    property string currentDisplayName
    property string currentUserId

    signal autoCompleteTriggered()

    active: visible
    sourceComponent: Component {
        Menu {
            id: completionMenu

            delegate: usernameDelegate

            Component {
                id: usernameDelegate
                MenuItem {
                    id: usernameToolButton
                    indicator: Kirigami.Avatar {
                        implicitWidth: implicitHeight
                        source: modelData.avatarMediaId ? ("image://mxc/" + modelData.avatarMediaId) : ""
                        color: modelData.color ? Qt.darker(modelData.color, 1.1) : null
                    }
                    arrow: null
                    text: modelData.displayName
                    onClicked: {
                        inputField.autoComplete();
                    }
                }
            }

            Component {
                id: emojiDelegate
                MenuItem {
                    indicator: null
                    arrow: null
                    font.wordSpacing: parent.spacing > 0 ? parent.spacing - textMetrics.width : 0
                    TextMetrics {
                        id: textMetrics
                        text: " "
                    }
                    onClicked: {
                        inputField.autoComplete();
                    }
                }
            }
        }
    }
}


/*
ListView {
    Layout.fillWidth: true
    Layout.preferredHeight: 36
    Layout.margins: 8

    id: autoCompleteListView

    visible: false

    model: autoCompleteModel

    clip: true
    spacing: 4
    orientation: ListView.Horizontal
    highlightFollowsCurrentItem: true
    keyNavigationWraps: true

    delegate: Control {
        readonly property string userId: modelData.id ?? ""
        readonly property string displayText: modelData.displayName ?? modelData.unicode
        readonly property bool isEmoji: modelData.unicode != null
        readonly property bool highlighted: autoCompleteListView.currentIndex == index

        padding: Kirigami.Units.smallSpacing

        contentItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing

            Label {
                width: Kirigami.Units.gridUnit
                height: Kirigami.Units.gridUnit
                visible: isEmoji
                text: displayText
                font.family: "Emoji"
                font.pointSize: 20
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Kirigami.Avatar {
                Layout.preferredWidth: Kirigami.Units.gridUnit
                Layout.preferredHeight: Kirigami.Units.gridUnit
                source: modelData.avatarMediaId ? ("image://mxc/" + modelData.avatarMediaId) : ""
                color: modelData.color ? Qt.darker(modelData.color, 1.1) : null
                visible: !isEmoji
            }
            Label {
                Layout.fillHeight: true

                visible: !isEmoji
                text: displayText
                color: highlighted ? Kirigami.Theme.highlightTextColor : Kirigami.Theme.textColor
                font.underline: highlighted
                verticalAlignment: Text.AlignVCenter
                rightPadding: Kirigami.Units.largeSpacing
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                autoCompleteListView.currentIndex = index
                inputField.autoComplete();
            }
        }
    }
}
*/
