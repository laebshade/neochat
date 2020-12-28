/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "login.h"
#include "connection.h"
#include "controller.h"

#include <QUrl>

#include <KLocalizedString>

Login::Login(QObject *parent)
    : QObject(parent)
{
}

void Login::setHomeserverReachable(bool reachable)
{
    m_homeserverReachable = reachable;
    Q_EMIT homeserverReachableChanged();
}

bool Login::homeserverReachable() const
{
    return m_homeserverReachable;
}

void Login::testHomeserver(QString matrixId)
{
    setHomeserverReachable(false);
    if (m_currentTestJob) {
        m_currentTestJob->abandon();
    }
    if (!matrixId.startsWith('@')) {
        matrixId.prepend('@');
    }

    Connection *c = new Connection(this);
    c->resolveServer(matrixId);
    auto job = c->callApi<GetWellknownJob>();
    m_currentTestJob = job;
    connect(job, &BaseJob::result, this, [=]() {
        c->setHomeserver(job->data().homeserver.baseUrl);
        connect(c, &Connection::loginFlowsChanged, this, [=]() {
            setHomeserverReachable(c->isUsable());
            c->deleteLater();
            m_currentTestJob = nullptr;
        });
    });
}

QString Login::matrixId() const
{
    return m_matrixId;
}

void Login::setMatrixId(const QString &matrixId)
{
    m_matrixId = matrixId;
    Q_EMIT matrixIdChanged();
}

QString Login::password() const
{
    return m_password;
}

void Login::setPassword(const QString &password)
{
    m_password = password;
    Q_EMIT passwordChanged();
}

QString Login::deviceName() const
{
    return m_deviceName;
}

void Login::setDeviceName(const QString &deviceName)
{
    m_deviceName = deviceName;
    Q_EMIT deviceNameChanged();
}

void Login::login()
{
    setDeviceName("NeoChat " + QSysInfo::machineHostName() + " " + QSysInfo::productType() + " " + QSysInfo::productVersion() + " " + QSysInfo::currentCpuArchitecture());

    auto conn = new Connection(this);
    conn->resolveServer(m_matrixId);

    connect(conn, &Connection::loginFlowsChanged, this, [=]() {
        conn->loginWithPassword(m_matrixId, m_password, m_deviceName, "");
        connect(conn, &Connection::connected, this, [=] {
            AccountSettings account(conn->userId());
            account.setKeepLoggedIn(true);
            account.clearAccessToken(); // Drop the legacy - just in case
            account.setHomeserver(conn->homeserver());
            account.setDeviceId(conn->deviceId());
            account.setDeviceName(m_deviceName);
            if (!Controller::instance().saveAccessTokenToKeyChain(account, conn->accessToken())) {
                qWarning() << "Couldn't save access token";
            }
            account.sync();
            Controller::instance().addConnection(conn);
            Controller::instance().setActiveConnection(conn);
        });
        connect(conn, &Connection::networkError, [=](QString error, const QString &, int, int) {
            Q_EMIT Controller::instance().globalErrorOccured(i18n("Network Error"), std::move(error));
        });
        connect(conn, &Connection::loginError, [=](QString error, const QString &) {
            Q_EMIT Controller::instance().errorOccured(i18n("Login Failed"), std::move(error));
        });
    });

    connect(conn, &Connection::resolveError, this, [=](QString error) {
        Q_EMIT Controller::instance().globalErrorOccured(i18n("Network Error"), std::move(error));
    });

    connect(conn, &Connection::syncDone, this, [=]() {
        Q_EMIT initialSyncFinished();
        disconnect(conn, &Connection::syncDone, this, nullptr);
    });
}
