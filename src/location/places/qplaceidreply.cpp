/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtLocation module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation and
** appearing in the file LICENSE.LGPL included in the packaging of this
** file. Please review the following information to ensure the GNU Lesser
** General Public License version 2.1 requirements will be met:
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights. These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU General
** Public License version 3.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of this
** file. Please review the following information to ensure the GNU General
** Public License version 3.0 requirements will be met:
** http://www.gnu.org/copyleft/gpl.html.
**
** Other Usage
** Alternatively, this file may be used in accordance with the terms and
** conditions contained in a signed written agreement between you and Nokia.
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "qplaceidreply.h"
#include "qplacereply_p.h"

QT_BEGIN_NAMESPACE
class QPlaceIdReplyPrivate : public QPlaceReplyPrivate
{
public:
    QPlaceIdReplyPrivate() {}
    ~QPlaceIdReplyPrivate() {}
    QString id;
    QPlaceIdReply::OperationType operationType;
};

QT_END_NAMESPACE

QT_USE_NAMESPACE

/*!
    \class QPlaceIdReply

    \brief The QPlaceIdReply class manages operations which return an id such as
           saving and removal operations of places and categories.

    \inmodule QtLocation

    \ingroup places-main
*/

/*!
    Constructs an id reply with a given \a operationType and \a parent.
*/
QPlaceIdReply::QPlaceIdReply(QPlaceIdReply::OperationType operationType, QObject *parent)
    : QPlaceReply(new QPlaceIdReplyPrivate, parent)
{
    Q_D(QPlaceIdReply);
    d->operationType = operationType;
}

/*!
    Destroys the reply.
*/
QPlaceIdReply::~QPlaceIdReply()
{
}

/*!
    Returns the type of reply.  This is an indication of the content
    of the reply.
*/
QPlaceReply::Type QPlaceIdReply::type() const
{
    return QPlaceReply::IdReply;
}

/*!
    Returns the operation type of the reply.
*/
QPlaceIdReply::OperationType QPlaceIdReply::operationType() const
{
    Q_D(const QPlaceIdReply);
    return d->operationType;
}

/*!
    Returns the relevant id for the opeation. Eg for a save place operation,
    the id is that of the saved place.  For a category removal operation,
    it is the category id.
*/
QString QPlaceIdReply::id() const
{
    Q_D(const QPlaceIdReply);
    return d->id;
}

/*!
    Sets the \a id of the reply.
*/
void QPlaceIdReply::setId(const QString &id)
{
    Q_D(QPlaceIdReply);
    d->id = id;
}