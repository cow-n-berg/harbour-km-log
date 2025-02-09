import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Dialog {
    id: dialog

    property var callback

    property var cache1Adding : false
    property var cache2Adding : false

    onAccepted: {
        Database.setSetting( "coverShowAppName", generic.coverShowAppName )
        Database.setSetting( "showDialogHints" , generic.showDialogHints  )
        Database.setSetting( "nightCacheMode"  , generic.nightCacheMode   )
        Database.setSetting( "deleteDatabase"  , generic.deleteDatabase   )
        Database.setSetting( "formulaCopyMode" , generic.formulaCopyMode  )
        Database.setSetting( "calculationMenu" , generic.calculationMenu  )
        Database.setSetting( "xySystemIsRd"    , generic.xySystemIsRd     )
        Database.setSetting( "provideLatLon"   , generic.provideLatLon    )

        if (cache1Adding) {
            Database.addStd1Cache()
        }
        if (cache2Adding) {
            Database.addStd2Cache()
        }

        dialog.callback(cache1Adding || cache2Adding)
    }

    onRejected: {
        dialog.callback(false)
    }

    SilicaFlickable {
        id: settings

        anchors.fill: parent
        anchors.margins: Theme.paddingMedium
        contentHeight: column.height + Theme.itemSizeMedium
        quickScroll : true

        PageHeader {
            id: pageHeader
            title: qsTr("Settings" )
        }

        VerticalScrollDecorator { flickable: settings }

        Column {
            id: column
            width: parent.width
            anchors {
                top: pageHeader.bottom
                margins: 0
            }

            SectionHeader {
                text: qsTr("General settings")
                color: generic.highlightColor
            }

            IconTextSwitch {
                text: qsTr("Provide Lat/Lon pattern for new waypoint")
                description: qsTr("Or leave formula area empty")
                icon.source: "image://theme/icon-m-wizard"
                checked: generic.provideLatLon
                onClicked: generic.provideLatLon = !generic.provideLatLon
            }
            IconTextSwitch {
                text: qsTr("Copy evaluated formula for geocaching app")
                description: qsTr("Normal behaviour: entire string, GC-mode: three parts of entire/Lat/Lon minutes")
                icon.source: "image://theme/icon-m-clipboard"
                checked: generic.formulaCopyMode
                onClicked: generic.formulaCopyMode = !generic.formulaCopyMode
            }
            IconTextSwitch {
                text: qsTr("Show hints on dialogs")
                description: qsTr("Explanations of entry fields")
                icon.source: "image://theme/icon-m-annotation"
                checked: generic.showDialogHints
                onClicked: generic.showDialogHints = !generic.showDialogHints
            }
            IconTextSwitch {
                text: qsTr("Show Calculations in menu")
                description: qsTr("Partly Vincenty, partly Cartesian system used")
                icon.source: Qt.resolvedUrl("../images/icon-pentagon.svg")
                checked: generic.calculationMenu
                onClicked: generic.calculationMenu = !generic.calculationMenu
            }
            IconTextSwitch {
                text: qsTr("Use Dutch RD instead of UTM")
                description: qsTr("RD = Rijksdriehoek system,\nCartesian system of The Netherlands")
                icon.source: "image://theme/icon-m-region"
                checked: generic.xySystemIsRd
                onClicked: generic.xySystemIsRd = !generic.xySystemIsRd
            }

            SectionHeader {
                text: qsTr("Appearance")
                color: generic.highlightColor
            }

            IconTextSwitch {
                text: qsTr("Dark mode")
                description: qsTr("Red characters on black background")
                icon.source: "image://theme/icon-m-moon"
                checked: generic.nightCacheMode
                onClicked: generic.nightCacheMode = !generic.nightCacheMode
            }
            IconTextSwitch {
                text: qsTr("Show app name on cover")
                description: qsTr("'GMFS' for better recognition of app tiles")
                icon.source: "image://theme/icon-m-about"
                checked: generic.coverShowAppName
                onClicked: generic.coverShowAppName = !generic.coverShowAppName
            }

            SectionHeader {
                text: qsTr("Database actions")
                color: generic.highlightColor
            }

            IconTextSwitch {
                text: qsTr("Clear database next start-up")
                description: qsTr("Will be executed only once")
                icon.source: "image://theme/icon-m-levels"
                checked: generic.deleteDatabase
                onClicked: generic.deleteDatabase = !generic.deleteDatabase
            }

            IconTextSwitch {
                text: qsTr("(Re-)create Multi GC3A7RC")
                description: qsTr("'where it started' from Seattle")
                icon.source: "image://theme/icon-m-location"
                checked: cache1Adding
                onClicked: cache1Adding = !cache1Adding
            }

            IconTextSwitch {
                text: qsTr("(Re-)create Multi GC83QV1")
                description: qsTr("'Het Utrechts zonnestelsel...' from The Netherlands")
                icon.source: "image://theme/icon-m-location"
                checked: cache2Adding
                onClicked: cache2Adding = !cache2Adding
            }
        }
    }
}
