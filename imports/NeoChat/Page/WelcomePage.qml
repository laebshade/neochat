/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Layouts 1.14

import org.kde.kirigami 2.12 as Kirigami

import org.kde.neochat 1.0

import NeoChat.Component.Login 1.0

Kirigami.ScrollablePage {
    id: welcomePage
    
    title: module.item.title ?? i18n("Welcome")

    ColumnLayout {
        Kirigami.Icon {
            source: "org.kde.neochat"
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 16
        }
        Controls.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 25
            text: module.item.title ?? i18n("Welcome to Matrix")
        }

        Loader {
            id: module
            Layout.alignment: Qt.AlignHCenter
            source: "qrc:/imports/NeoChat/Component/Login/LoginRegister.qml"
        }

        Connections {
            target: module.item
            function onNext() {
                module.item.process()
                module.source = module.item.nextUrl
            }
        }

        Controls.Button {
            text: i18n("Continue")
            enabled: module.item.acceptable
            visible: module.item.showContinueButton
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                module.item.process()
                module.source = module.item.nextUrl
            }
        }
    }
}
