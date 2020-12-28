/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

#include "csapi/wellknown.h"

using namespace Quotient;

class Login : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool homeserverReachable READ homeserverReachable NOTIFY homeserverReachableChanged)
    Q_PROPERTY(QString matrixId READ matrixId WRITE setMatrixId NOTIFY matrixIdChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString deviceName READ deviceName WRITE setDeviceName NOTIFY deviceNameChanged)

public:
    explicit Login(QObject *parent = nullptr);

    bool homeserverReachable() const;
    Q_INVOKABLE void testHomeserver(QString matrixId);

    QString matrixId() const;
    void setMatrixId(const QString &matrixId);

    QString password() const;
    void setPassword(const QString &password);

    QString deviceName() const;
    void setDeviceName(const QString &deviceName);

    Q_INVOKABLE void login();

Q_SIGNALS:
    void homeserverReachableChanged();
    void matrixIdChanged();
    void passwordChanged();
    void deviceNameChanged();
    void initialSyncFinished();

private:
    void setHomeserverReachable(bool reachable);

    bool m_homeserverReachable;
    BaseJob *m_currentTestJob;
    QString m_matrixId;
    QString m_password;
    QString m_deviceName;
};
