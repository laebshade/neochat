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

    property bool loading: false

    title: i18nc("@title", "Password")

    action: Kirigami.Action {
        enabled: passwordField.text.length > 0
        onTriggered: {
            LoginHelper.login();
            root.loading = true;
        }
    }

    Kirigami.FormLayout {
        Kirigami.PasswordField {
            id: passwordField
            onTextChanged: LoginHelper.password = text
        }

        QQC2.Button {
            id: continueButton
            text: i18nc("@action:button", "Continue")
            action: root.action
        }
    }
}
