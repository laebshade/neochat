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

Kirigami.FormLayout {

    property var homeserver: customHomeserver.visible ? customHomeserver.text : serverCombo.currentText
    property bool acceptable: LoginHelper.homeserverReachable
    property string title: "Homeserver"
    property bool showContinueButton: true

    Component.onCompleted: Controller.testConnection(homeserver)

    onHomeserverChanged: {
        LoginHelper.testConnection("@user:" + homeserver)
    }

    Controls.ComboBox {
        id: serverCombo

        Kirigami.FormData.label: i18n("Homeserver:")
        model: ["matrix.org", "kde.org", "tchncs.de", i18n("Other...")]
        Layout.alignment: Qt.AlignHCenter
    }
    Controls.TextField {
        id: customHomeserver

        Kirigami.FormData.label: i18n("Url:")
        visible: serverCombo.currentIndex === 3
        onTextChanged: {
            Controller.testConnection(text)
        }
    }
}
