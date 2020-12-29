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

ColumnLayout {
    id: loginMethod

    property bool showContinueButton: false
    property string nextUrl: ""
    signal next()

    function process() {
    }

    Layout.alignment: Qt.AlignHCenter
    Controls.Button {
        Layout.alignment: Qt.AlignHCenter
        text: i18n("Login with password")
        Layout.preferredWidth: Kirigami.Units.gridUnit * 12
        onClicked: {
            loginMethod.nextUrl = "qrc:/imports/NeoChat/Component/Login/Password.qml";
            next();
        }
    }
    Controls.Button {
        Layout.alignment: Qt.AlignHCenter
        text: i18n("Login with single sign-on")
        Layout.preferredWidth: Kirigami.Units.gridUnit * 12
        onClicked: {
            loginMethod.nextUrl = "qrc:/imports/NeoChat/Component/Login/Sso.qml";
            next();
        }
    }
}
