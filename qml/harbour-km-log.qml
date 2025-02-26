import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "pages"
import "scripts/Database.js" as DB

ApplicationWindow
{
    id: generic

    property string version    : "0.3-3"
    property string dbversion  : "0.1"
    property var    dbhandler  : DB.openDatabase(dbversion)
    property bool   debug      : false

    // Tzt verwijderen ook uit Database.js
    property bool tempDelDB    : false


    // Settings
    property bool coverShowAppName        : DB.getSetting( "coverShowAppName" , false )
    property bool deleteDatabase          : DB.getSetting( "deleteDatabase"   , false ) || tempDelDB
    property bool hideArchivedTrips       : DB.getSetting( "hideArchivedTrips", false )
    property string csvSeparator          : DB.getSetting( "csvSeparator"     , ',' )
    property string csvDecimal            : DB.getSetting( "csvDecimal"       , '.' )

    Component.onCompleted: { DB.openDatabase() }

    initialPage: Component { TripsPage { } }
    cover: Qt.resolvedUrl("pages/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

}
