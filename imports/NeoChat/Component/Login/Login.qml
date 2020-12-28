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

Kirigami.FormLayout {

    property bool acceptable: matrixIdField.acceptableInput && LoginHelper.homeserverReachable
    property bool showContinueButton: true
    property string nextUrl: "qrc:/imports/NeoChat/Component/Login/Password.qml"
    property string title: i18n("Login")

    QQC2.TextField {
        id: matrixIdField
        Kirigami.FormData.label: i18n("Matrix ID:")
        placeholderText: "@user:matrix.org"
        onTextChanged: {
            if(matrixIdField.acceptableInput) {
                LoginHelper.testHomeserver(text);
            }
        }
        validator: RegularExpressionValidator {
              regularExpression: /^\@?[a-zA-Z0-9\._=\-/]+\:[a-zA-Z0-9]+\.[a-zA-Z]+(:[0-9]+)?$/
        }
    }

    function process() {
        LoginHelper.matrixId = matrixIdField.text
    }
}
