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
    init();
}

void Login::init()
{
    m_homeserverReachable = false;
    m_currentTestJob = nullptr;
    m_connection = nullptr;
    m_matrixId = QString();
    m_password = QString();
    m_deviceName = QString();
    m_supportsSso = false;
    m_supportsPassword = false;
    m_ssoUrl = QUrl();
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
        m_currentTestJob = nullptr;
    }
    if (!matrixId.startsWith('@')) {
        matrixId.prepend('@');
    }
    if (m_connection) {
        delete m_connection;
        m_connection = nullptr;
    }
    m_connection = new Connection(this);
    m_connection->resolveServer(matrixId);
    auto job = m_connection->callApi<GetWellknownJob>();
    m_currentTestJob = job;
    connect(job, &BaseJob::result, this, [=]() {
        m_connection->setHomeserver(job->data().homeserver.baseUrl);
        connect(m_connection, &Connection::loginFlowsChanged, this, [=]() {
            setHomeserverReachable(m_connection->isUsable());
            m_currentTestJob = nullptr;
            m_supportsSso = m_connection->supportsSso();
            m_supportsPassword = m_connection->supportsPasswordAuth();
            Q_EMIT loginFlowsChanged();
            Q_EMIT testHomeserverFinished();
        });
    });
    connect(job, &BaseJob::failure, this, [=]() {
        Q_EMIT testHomeserverFinished();
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

    m_connection = new Connection(this);
    m_connection->resolveServer(m_matrixId);

    connect(m_connection, &Connection::loginFlowsChanged, this, [=]() {
        m_connection->loginWithPassword(m_matrixId, m_password, m_deviceName, "");
        connect(m_connection, &Connection::connected, this, [=] {
            AccountSettings account(m_connection->userId());
            account.setKeepLoggedIn(true);
            account.clearAccessToken(); // Drop the legacy - just in case
            account.setHomeserver(m_connection->homeserver());
            account.setDeviceId(m_connection->deviceId());
            account.setDeviceName(m_deviceName);
            if (!Controller::instance().saveAccessTokenToKeyChain(account, m_connection->accessToken())) {
                qWarning() << "Couldn't save access token";
            }
            account.sync();
            Controller::instance().addConnection(m_connection);
            Controller::instance().setActiveConnection(m_connection);
        });
        connect(m_connection, &Connection::networkError, [=](QString error, const QString &, int, int) {
            Q_EMIT Controller::instance().globalErrorOccured(i18n("Network Error"), std::move(error));
        });
        connect(m_connection, &Connection::loginError, [=](QString error, const QString &) {
            Q_EMIT errorOccured(i18n("Login Failed"));
        });
    });

    connect(m_connection, &Connection::resolveError, this, [=](QString error) {
        Q_EMIT Controller::instance().globalErrorOccured(i18n("Network Error"), std::move(error));
    });

    connect(m_connection, &Connection::syncDone, this, [=]() {
        Q_EMIT initialSyncFinished();
        disconnect(m_connection, &Connection::syncDone, this, nullptr);
    });
}

bool Login::supportsPassword() const
{
    return m_supportsPassword;
}

bool Login::supportsSso() const
{
    return m_supportsSso;
}

QUrl Login::ssoUrl() const
{
    return m_ssoUrl;
}

void Login::loginWithSso()
{
    SsoSession *session = m_connection->prepareForSso("NeoChat " + QSysInfo::machineHostName() + " " + QSysInfo::productType() + " " + QSysInfo::productVersion() + " " + QSysInfo::currentCpuArchitecture());
    m_ssoUrl = session->ssoUrl();
    Q_EMIT ssoUrlChanged();
    connect(m_connection, &Connection::connected, [=](){
        Q_EMIT connected();
        AccountSettings account(m_connection->userId());
            account.setKeepLoggedIn(true);
            account.clearAccessToken(); // Drop the legacy - just in case
            account.setHomeserver(m_connection->homeserver());
            account.setDeviceId(m_connection->deviceId());
            account.setDeviceName(m_deviceName);
            if (!Controller::instance().saveAccessTokenToKeyChain(account, m_connection->accessToken())) {
                qWarning() << "Couldn't save access token";
            }
            account.sync();
            Controller::instance().addConnection(m_connection);
            Controller::instance().setActiveConnection(m_connection);
    });
    connect(m_connection, &Connection::syncDone, this, [=]() {
        Q_EMIT initialSyncFinished();
        disconnect(m_connection, &Connection::syncDone, this, nullptr);
    });
}
