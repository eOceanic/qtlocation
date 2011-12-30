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

#include "qdeclarativerecommendationmodel_p.h"
#include "qdeclarativeplace_p.h"

#include <QtDeclarative/QDeclarativeInfo>
#include <QtLocation/QGeoServiceProvider>
#include <QtLocation/QPlaceManager>

#include <qplacesearchreply.h>

QT_USE_NAMESPACE

/*!
    \qmlclass PlaceRecommendationModel QDeclarativeRecommenadationModel
    \inqmlmodule QtLocation 5
    \ingroup qml-QtLocation5-places
    \since QtLocation 5.0

    \brief The PlaceRecommendationModel element provides a model of place recommendations.

    PlaceRecommendationModel provides a model of place recommendation results within the \l searchArea,
    that are similar to the place identified by the \l placeId property.

    The \l offset and \l limit properties can be used to access paged search results.  When the
    \l offset and \l limit properties are set the search results between \l offset and
    (\l offset + \l limit - 1) will be returned.

    The model returns data for the following roles:

    \table
        \header
            \o Role
            \o Type
            \o Description
        \row
            \o distance
            \o real
            \o The distance to the place.
        \row
            \o place
            \o \l Place
            \o The place.
    \endtable

    The following example shows how to use the PlaceRecommendationModel to search for recommendations in
    close proximity of a given position.

    \snippet snippets/declarative/places.qml QtQuick import
    \snippet snippets/declarative/places.qml QtLocation import
    \codeline
    \snippet snippets/declarative/places.qml RecommendationModel

    \sa PlaceSearchModel, CategoryModel, {QPlaceManager}
*/

/*!
    \qmlproperty Plugin PlaceRecommendationModel::plugin

    This property holds the \l Plugin which will be used to perform the search.
*/

/*!
    \qmlproperty BoundingArea PlaceRecommendationModel::searchArea

    This property holds the search area.  Search results returned by the model will be within the
    search area.

    If this property is set to a \l BoundingCircle its \l {BoundingCircle::radius}{radius} property
    may be left unset, in which case the \l Plugin will choose an appropriate radius for the
    search.
*/

/*!
    \qmlproperty int PlaceRecommendationModel::offset

    This property holds the index of the first search result in the model.

    \sa limit
*/

/*!
    \qmlproperty int PlaceRecommendationModel::limit

    This property holds the limit of the number of items that will be returned.

    \sa offset
*/

/*!
    \qmlproperty enum PlaceRecommendationModel::status

    This property holds the status of the model.  It can be one of:

    \table
        \row
            \o PlaceRecommendationModel.Ready
            \o The search query has completed and the result are available.
        \row
            \o PlaceRecommendationModel.Executing
            \o A search query is currently being executed.
        \row
            \o PlaceRecommendationModel.Error
            \o An error occurred when executing the previous search query.
    \endtable
*/

/*!
    \qmlmethod PlaceRecommendationModel::execute()

    Executes a recommendation search query for places similar to the place identified by the
    \l placeId property.  Once the query completes the model items are updated with the search
    results.

    \sa cancel(), status
*/

/*!
    \qmlmethod PlaceRecommendationModel::cancel()

    Cancels an ongoing search query.

    \sa execute(), status
*/

QDeclarativeRecommendationModel::QDeclarativeRecommendationModel(QObject *parent)
:   QDeclarativeSearchModelBase(parent)
{
    QHash<int, QByteArray> roles = roleNames();
    roles.insert(DistanceRole, "distance");
    roles.insert(PlaceRole, "place");
    setRoleNames(roles);
}

QDeclarativeRecommendationModel::~QDeclarativeRecommendationModel()
{
}

/*!
    \qmlproperty string PlaceRecommendationModel::placeId

    This property holds place id used in the recommendation search query.
*/
QString QDeclarativeRecommendationModel::placeId() const
{
    return m_placeId;
}

void QDeclarativeRecommendationModel::setPlaceId(const QString &placeId)
{
    if (m_placeId == placeId)
        return;

    m_placeId = placeId;
    emit placeIdChanged();
}

void QDeclarativeRecommendationModel::clearData()
{
    qDeleteAll(m_places);
    m_places.clear();
    m_results.clear();
}

void QDeclarativeRecommendationModel::updateSearchRequest()
{
    QDeclarativeSearchModelBase::updateSearchRequest();
}

void QDeclarativeRecommendationModel::processReply(QPlaceReply *reply)
{
    QPlaceSearchReply *searchReply = qobject_cast<QPlaceSearchReply *>(reply);
    if (!searchReply)
        return;

    m_results = searchReply->results();

    foreach (const QPlaceSearchResult &result, m_results) {
        QDeclarativePlace *place = new QDeclarativePlace(result.place(), plugin(), this);
        m_places.append(place);
    }

    emit rowCountChanged();
}

/*!
    \qmlproperty string PlaceRecommendationModel::row

    This properties holds the number of rows/results the model has.
*/
int QDeclarativeRecommendationModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return m_results.count();
}

QVariant QDeclarativeRecommendationModel::data(const QModelIndex& index, int role) const
{
    if (index.row() > m_results.count())
        return QVariant();

    const QPlaceSearchResult &result = m_results.at(index.row());

    if (result.type() != QPlaceSearchResult::PlaceResult)
        return QVariant();

    switch (role) {
    case Qt::DisplayRole:
        return result.place().name();
    case DistanceRole:
        return result.distance();
    case PlaceRole:
        return QVariant::fromValue(static_cast<QObject *>(m_places.at(index.row())));
    default:
        return QVariant();
    }

    return QVariant();
}

/*!
    \qmlmethod PlaceRecommendationModel::data(int index, string role)

    Returns the data for a given \a role at the specified row \a index.
*/
QVariant QDeclarativeRecommendationModel::data(int index, const QString &role) const
{
    QModelIndex modelIndex = createIndex(index, 0);
    return data(modelIndex, roleNames().key(role.toLatin1()));
}

QPlaceReply *QDeclarativeRecommendationModel::sendQuery(QPlaceManager *manager,
                                                        const QPlaceSearchRequest &request)
{
    return manager->recommendations(m_placeId, request);
}
