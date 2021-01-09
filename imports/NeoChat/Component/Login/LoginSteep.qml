// SPDX-FileCopyrightText: 2020 Carl Schwan <carlschwan@kde.org>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

/// Step for the login/registration flow
ColumnLayout {
    id: abstractSteep
    property string title: i18n("Welcome")
    property bool showContinueButton: false
    property bool acceptable: false
    property url nextUrl: null
    property Button continueButton: Button {
        text: i18nc("@action:button", "Continue")
        enabled: abstractSteep.acceptable
        visible: abstractSteep.showContinueButton
        Layout.alignment: Qt.AlignHCenter
        onClicked: {
            abstractSteep.process()
            module.source = module.item.nextUrl
        }
    }

    /// Process this module, this is called by the continue button.
    /// Should call \sa processed when it finish successfully.
    property Action action: null

    /// This signal emitted when the the flow should move to the next
    /// ui part.
    signal next();

    /// Called when the process function finished.
    signal processed(url nextUrl);

    signal errorOccured(string message);

    Layout.alignment: Qt.AlignHCenter
}
