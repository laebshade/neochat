/**
 * SPDX-FileCopyrightText: 2019 Black Hat <bhat@encom.eu.org>
 * SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
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

    title: i18nc("@title", "Login")

    Kirigami.FormLayout {
        QQC2.TextField {
            id: matrixIdField
            Kirigami.FormData.label: i18n("Matrix ID:")
            placeholderText: "@user:matrix.org"
            onTextChanged: {
                if (acceptableInput) {
                    LoginHelper.testHomeserver(text);
                    root.loading = true;
                }
            }

            validator: RegularExpressionValidator {
                regularExpression: /^\@?[a-zA-Z0-9\._=\-/]+\:[a-zA-Z0-9]+\.[a-zA-Z]+(:[0-9]+)?$/
            }
        }

        QQC2.Button {
            id: continueButton
            text: root.loading ? i18n("Loading") : i18nc("@action:button", "Continue")
            action: root.action
        }
    }

    Connections {
        target: LoginHelper
        onTestHomeserverFinished: {
            root.loading = false;
        }
        onHomeserverReachableChanged: if (LoginHelper.homeserverReachable) {
            continueButton.forceActiveFocus();
        }
    }

    action: Kirigami.Action {
        onTriggered: {
            LoginHelper.matrixId = matrixIdField.text
            if (LoginHelper.supportsSso && LoginHelper.supportsPassword) {
                processed("qrc:/imports/NeoChat/Component/Login/LoginMethod.qml");
            } else if (LoginHelper.supportsPassword) {
                processed("qrc:/imports/NeoChat/Component/Login/Password.qml");
            } else {
                processed("qrc:/imports/NeoChat/Component/Login/Sso.qml");
            }
        }
        enabled: matrixIdField.acceptableInput && LoginHelper.homeserverReachable
    }
}
