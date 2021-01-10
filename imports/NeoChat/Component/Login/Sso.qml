
/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */
import QtQuick 2.15
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.12

import org.kde.neochat 1.0

import NeoChat.Component 1.0

import org.kde.kirigami 2.12 as Kirigami

LoginSteep {
    id: root
    title: i18nc("@title", "Login with single sign-on")

    Kirigami.FormLayout {
        Connections {
            target: LoginHelper
            onSsoUrlChanged: {
                Qt.openUrlExternally(LoginHelper.ssoUrl)
            }
            onConnected: proccessed("qrc:/imports/NeoChat/Component/Login/Loading.qml")
        }

        QQC2.Button {
            text: i18n("Login")
            onClicked: {
                LoginHelper.loginWithSso()
                root.message(i18n("Complete the autentification steeps in your browser"))
            }
        }
    }
}
