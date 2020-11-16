/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QSortFilterProxyModel>

class SortFilterRoomListModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(RoomSortOrder roomSortOrder READ roomSortOrder WRITE setRoomSortOrder NOTIFY roomSortOrderChanged)
    Q_PROPERTY(QString filterText READ filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)

public:
    enum RoomSortOrder {
        Alphabetical,
        LastActivity,
        Categories,
    };
    Q_ENUM(RoomSortOrder)

    SortFilterRoomListModel(QObject *parent = nullptr);

    void setRoomSortOrder(RoomSortOrder sortOrder);
    RoomSortOrder roomSortOrder() const;

    void setFilterText(const QString &text);
    QString filterText() const;

    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

Q_SIGNALS:
    void roomSortOrderChanged();
    void filterTextChanged();

private:
    RoomSortOrder m_sortOrder;
    QString m_filterText;
};