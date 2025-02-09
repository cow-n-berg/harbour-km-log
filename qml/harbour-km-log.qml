import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "pages"
import "scripts/Database.js" as DB

ApplicationWindow
{
    id: generic

    property string version    : "0.1"
    property string dbversion  : "0.1"
    property var    dbhandler  : DB.openDatabase(dbversion)
    property bool   debug      : false

    // Settings
    property bool useISO       : DB.getSetting( "coverShowAppName", false )

    Component.onCompleted: { DB.openDatabase() }

    initialPage: Component { TripsPage { } }
    cover: Qt.resolvedUrl("pages/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

}
