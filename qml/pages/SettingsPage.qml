import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Dialog {
    id: dialog

    property var callback

    onAccepted: {
        generic.csvDecimal   = txtDec.text;
        generic.csvSeparator = txtSep.text;

        Database.setSetting( "coverShowAppName", generic.coverShowAppName )
        Database.setSetting( "deleteDatabase"  , generic.deleteDatabase   )
        Database.setSetting( "csvDecimal"      , generic.csvDecimal       )
        Database.setSetting( "csvSeparator"    , generic.csvSeparator     )

        dialog.callback(true)
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
                text: qsTr("Data settings for csv export")
                color: Theme.highlightColor
            }

            TextField {
                id: txtDec
                focus: true
                width: parent.width
                text: generic.csvDecimal
                label: qsTr("Decimal character (. or ,)")
                placeholderText: qsTr("One decimal character only")
                placeholderColor: Theme.secondaryColor
                color: Theme.primaryColor
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: txtSep.focus = true
            }

            TextField {
                id: txtSep
                width: parent.width
                text: generic.csvSeparator
                label: qsTr("CSV separation character (, or ;)")
                placeholderText: qsTr("One csv separation character only")
                placeholderColor: Theme.secondaryColor
                color: Theme.primaryColor
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: checkCover.focus = true
            }

            SectionHeader {
                text: qsTr("Appearance")
                color: Theme.highlightColor
            }

            IconTextSwitch {
                id: checkCover
                text: qsTr("Show app name on cover")
                description: qsTr("'Kilometer' for better recognition of app tiles")
                icon.source: "image://theme/icon-m-about"
                checked: generic.coverShowAppName
                onClicked: generic.coverShowAppName = !generic.coverShowAppName
            }

            SectionHeader {
                text: qsTr("Database actions")
                color: Theme.highlightColor
            }

            IconTextSwitch {
                text: qsTr("Clear database next start-up")
                description: qsTr("Will be executed only once")
                icon.source: "image://theme/icon-m-levels"
                checked: generic.deleteDatabase
                onClicked: generic.deleteDatabase = !generic.deleteDatabase
            }

        }
    }
}
