/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the examples of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import Qt 4.7
import Qt.location 5.0
import "common" as Common

FocusScope {
    anchors.fill: parent
    id: page

    Rectangle {
        anchors.fill: parent
        color: "darkgrey"
        z:2
    }


    Common.TitleBar {
        id: titleBar; z: 4; width: parent.width; height: 40; opacity: 0.9; text: "QML mapviewer example"
        onClicked: { Qt.quit() }
    }

    Common.Slider {
        id: zoomSlider;
        minimum: map.minimumZoomLevel;
        maximum: map.maximumZoomLevel;
        opacity: 1
        z: 4
        anchors {
            bottom: mainMenu.top;
            bottomMargin: 5; rightMargin: 5; leftMargin: 5
            left: parent.left
        }
        width: parent.width - anchors.rightMargin - anchors.leftMargin
        value: map.zoomLevel
        onValueChanged: {
            map.zoomLevel = value
        }
    }

    // Menus
    Common.Menu {
        id: mainMenu
        itemHeight: 40
        itemWidth: page.width / count
        anchors.bottom: parent.bottom
        orientation: ListView.Horizontal
        z: 5
        Component.onCompleted: {
            setModel(["Options","Settings"])
        }
        onClicked: {
            switch (button) {
                case 0: {
                    page.state = "Options"
                    break;
                }
                case 1: {
                    page.state = "Settings"
                    break;
                }
            }
        }

    }

        Common.Menu {
            id: optionsMenu
            orientation: ListView.Vertical
            z: mainMenu.z - 1
            Component.onCompleted: {
                setModel(["Reverse geocode", "Geocode","Search", "Route"])
                disableItem(2)
            }
            itemHeight: 30;
            itemWidth: mainMenu.itemWidth
            anchors.left: mainMenu.left
            y: page.height

            onClicked: {
                switch (button) {
                    case 0: {
                        page.state = "RevGeocode"
                        break;
                    }
                    case 1: {
                        page.state = "Geocode"
                        break;
                    }
                    case 2: {
                        page.state = "Search"
                        break;
                    }
                    case 3: {
                        page.state = "Route"
                        break;
                    }
                }
            }
        }

        Common.Menu {
            id: settingsMenu
            orientation: ListView.Vertical
            z: mainMenu.z - 1
            Component.onCompleted: {
                setModel(["Map type", "Provider"])
                disableItem(0)
                disableItem(1)
            }

            itemHeight: 30;
            itemWidth: mainMenu.itemWidth
            y: page.height
            anchors.right: mainMenu.right

            onClicked: {
                switch (button) {
                    case 0: {
                        console.log("Map type");
                        break;
                    }
                    case 1: {
                        console.log("Provider")
                        break;
                    }
                }
            }
        }

    // Dialogs
    Dialog {
        id: routeDialog
        title: "Routing from map center to"
        z: 5
        opacity: 0

        Component.onCompleted: {
            var obj = [["latitude:", "51.2207"],["and longitude:", "0.1"]]
            setModel(obj)
        }
        Coordinate {
            id: endCoordinate
        }
        onGoButtonClicked: {
            page.state = ""
            endCoordinate.latitude = dialogModel.get(0).inputText
            endCoordinate.longitude = dialogModel.get(1).inputText
            routeQuery.clearWaypoints();
            routeQuery.addWaypoint(map.center)    // Starting coordinate
            routeQuery.addWaypoint(endCoordinate) // Ending coordinate
            routeModel.update();
        }
        onCancelButtonClicked: {
            page.state = ""
        }
    }

    Dialog {
        id: searchDialog
        title: "Search"
        z: 5
        opacity: 0

        onGoButtonClicked: {
            page.state = ""
//            searchModel.searchString = dialogModel.get(0).inputText
//            searchModel.update();
        }
        Component.onCompleted: {
            var obj = [["Please enter thing to search:","53 Brandl St, Eight Mile Plains, Australia"]]
            setModel(obj)
        }
        onCancelButtonClicked: {
            page.state = ""
        }
    }

    Dialog {
        id: geocodeDialog
        title: "Geocode"
        z: 5
        opacity: 0

        Component.onCompleted: {
            var obj = [["Country:","Australia"],["Street:", "Brandl St 53"],["District:","Eight Mile Plains"]]
            setModel(obj)
        }
        onGoButtonClicked: {
            page.state = ""
            geocodeAddress.country = dialogModel.get(0).inputText
            geocodeAddress.street = dialogModel.get(1).inputText
            geocodeAddress.district = dialogModel.get(2).inputText
            geocodeModel.query = geocodeAddress
            geocodeModel.update();
        }
        onCancelButtonClicked: {
            page.state = ""
        }
    }

    Dialog {
        id: reverseGeocodeDialog
        title: "Reverse Geocode"
        z: 5
        opacity: 0

        Component.onCompleted: {
            var obj = [["Latitude:","51"],["Longitude:", "0"]]
            setModel(obj)
        }
        onGoButtonClicked: {
            page.state = ""
            reverseGeocodeCoordinate.latitude = dialogModel.get(0).inputText
            reverseGeocodeCoordinate.longitude = dialogModel.get(1).inputText
            geocodeModel.query = reverseGeocodeCoordinate
            geocodeModel.update();
        }
        onCancelButtonClicked: {
            page.state = ""
        }
    }
    RouteModel {
        id : routeModel
        plugin : Plugin { name : "nokia"}
        query: RouteQuery {
            id: routeQuery
        }
    }

    Address {
        id: geocodeAddress
    }
    Coordinate {
        id: reverseGeocodeCoordinate
    }
    GeocodeModel {
        id: geocodeModel
        plugin : Plugin { name : "nokia"}
        onPlacesChanged: {
            if (geocodeModel.count > 0) {
                console.log('setting the coordinate as places changed in model.')
                map.center = geocodeModel.get(0).coordinate
            }
        }
    }

    Map {
        id: map
        z : 3
        plugin : Plugin {name : "nokia"}
        size.width: parent.width
        size.height: parent.height
        zoomLevel: 9
        focus : true
        center: Coordinate {
            latitude: 51.5
            longitude: -0.11
        }

        MapObjectView {
            model: routeModel
            delegate: Component {
                MapRoute {
                    // TODO this interface is bit unclear
                    route: path
                }
            }
        }

        MapObjectView {
            model: geocodeModel
            delegate: Component {
                MapCircle {
                    radius: 10000
                    color: "red"
                    center: place.coordinate
                }
            }
        }

        MapCircle {
            id : circle
            center : Coordinate {
                        latitude : 51.5
                        longitude : -0.11
                    }
            color : "#80FF0000"
            radius : 1000.0
            MapMouseArea {
                onPositionChanged: {
                    if (mouse.button == Qt.LeftButton)
                        circle.center = mouse.coordinate
                    if (mouse.button == Qt.RightButton)
                        circle.radius = circle.center.distanceTo(mouse.coordinate)
                }
            }
        }

        MapMouseArea {
            property int lastX : -1
            property int lastY : -1

            onPressed : {
                if (page.state != "") page.state =""
                else {
                    lastX = mouse.x
                    lastY = mouse.y
                }
            }
            onReleased : {
                lastX = -1
                lastY = -1
            }
            onPositionChanged: {
                if (mouse.button == Qt.LeftButton) {
                    if ((lastX != -1) && (lastY != -1)) {
                        var dx = mouse.x - lastX
                        var dy = mouse.y - lastY
                        map.pan(-dx, -dy)
                    }
                    lastX = mouse.x
                    lastY = mouse.y
                }
            }
            onDoubleClicked: {
                map.center = mouse.coordinate
                if (mouse.button == Qt.LeftButton){
                    map.zoomLevel += 1
                } else if (mouse.button == Qt.RightButton){
                    map.zoomLevel -= 1
                }
                lastX = -1
                lastY = -1
            }
        }
    } // Map

    Keys.onPressed: {
        if ((event.key == Qt.Key_Plus) || (event.key == Qt.Key_VolumeUp)) {
            map.zoomLevel += 1
        } else if ((event.key == Qt.Key_Minus) || (event.key == Qt.Key_VolumeDown)){
            map.zoomLevel -= 1
        } else if (event.key == Qt.Key_T) {
            if (map.mapType == Map.StreetMap) {
                map.mapType = Map.SatelliteMapDay
            } else if (map.mapType == Map.SatelliteMapDay) {
                map.mapType = Map.StreetMap
            }
        }
    }

    // states of page
    states: [
        State {
            name: "RevGeocode"
            PropertyChanges { target: reverseGeocodeDialog; opacity: 1 }
            PropertyChanges { target: titleBar; hoverEnabled: false }
        },
        State {
            name: "Route"
            PropertyChanges { target: routeDialog; opacity: 1 }
            PropertyChanges { target: titleBar; hoverEnabled: false }
        },
        State {
            name: "Search"
            PropertyChanges { target: searchDialog; opacity: 1 }
            PropertyChanges { target: titleBar; hoverEnabled: false }
        },
        State {
            name: "Geocode"
            PropertyChanges { target: geocodeDialog; opacity: 1 }
            PropertyChanges { target: titleBar; hoverEnabled: false }
        },
        State {
            name : "Options"
            PropertyChanges { target: optionsMenu; y: page.height - optionsMenu.height - mainMenu.height }
        },
        State {
            name : "Settings"
            PropertyChanges { target: settingsMenu; y: page.height - settingsMenu.height - mainMenu.height }
        }
    ]

    // state-transition animations for page
    transitions: [
        Transition {
            NumberAnimation { properties: "opacity" ; duration: 500; easing.type: Easing.Linear }
        },
        Transition {
            to: "Settings"
            NumberAnimation { properties: "y" ; duration: 300; easing.type: Easing.Linear }
        },
        Transition {
            to: "Options"
            NumberAnimation { properties: "y" ; duration: 300; easing.type: Easing.Linear }
        }
    ]
}