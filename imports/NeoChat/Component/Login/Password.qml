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

Kirigami.FormLayout {

    property bool acceptable: passwordField.text !== ""
    property bool showContinueButton: true
    property string nextUrl: "qrc:/imports/NeoChat/Component/Login/Loading.qml"
    property string title: i18n("Password")

    Kirigami.PasswordField {
        id: passwordField
        onTextChanged: LoginHelper.password = text
    }

    function process() {
        LoginHelper.login()
    }
}
