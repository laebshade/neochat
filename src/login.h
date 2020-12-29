/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

#include "csapi/wellknown.h"
#include "connection.h"

using namespace Quotient;

class Login : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool homeserverReachable READ homeserverReachable NOTIFY homeserverReachableChanged)
    Q_PROPERTY(QString matrixId READ matrixId WRITE setMatrixId NOTIFY matrixIdChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString deviceName READ deviceName WRITE setDeviceName NOTIFY deviceNameChanged)
    Q_PROPERTY(bool supportsSso READ supportsSso NOTIFY loginFlowsChanged STORED false)
    Q_PROPERTY(bool supportsPassword READ supportsPassword NOTIFY loginFlowsChanged STORED false)
    Q_PROPERTY(QUrl ssoUrl READ ssoUrl NOTIFY ssoUrlChanged)

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

    bool supportsPassword() const;
    bool supportsSso() const;

    QUrl ssoUrl() const;

    Q_INVOKABLE void login();
    Q_INVOKABLE void loginWithSso();

Q_SIGNALS:
    void homeserverReachableChanged();
    void matrixIdChanged();
    void passwordChanged();
    void deviceNameChanged();
    void initialSyncFinished();
    void loginFlowsChanged();
    void ssoUrlChanged();
    void connected();

private:
    void setHomeserverReachable(bool reachable);

    bool m_homeserverReachable;
    BaseJob *m_currentTestJob = nullptr;
    QString m_matrixId;
    QString m_password;
    QString m_deviceName;
    bool m_supportsSso = false;
    bool m_supportsPassword = false;
    Connection *m_connection = nullptr;
    QUrl m_ssoUrl;
};
