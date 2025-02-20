/*
 * Copyright (C) 2015 Markus Mayr <markus.mayr@outlook.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2 only.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

.pragma library
.import QtQuick 2.2 as QtQuick
.import QtQuick.LocalStorage 2.0 as DB
.import "TextFunctions.js" as TF

var databaseHandler = null;
var deleteDatabase
var databaseVersion = ""

function openDatabase( dbversion ) {
    // optional parameter
    console.log("openDatabase started");
    if (dbversion === null) {
        dbversion = databaseVersion
    }
    else {
        databaseVersion = dbversion
    }

    if (databaseHandler === null)
    {
        try {
            databaseHandler = DB.LocalStorage.openDatabaseSync(
                                "km_log-db", "",
                                "km database", 1000000);
            cleanTablesRecs();
            if (deleteDatabase) {
                deleteDatabase = false
                setSetting( "deleteDatabase", deleteDatabase )
            }

            initializeDatabase( databaseHandler );
            upgradeDatabase(dbversion);
        } catch (err) {
            console.log("initDatabase error: " + err);
        };    }
    return databaseHandler;
}

function cleanTablesRecs() {

    deleteDatabase = getSetting( "deleteDatabase" );

    console.log("cleanTablesRecs ");
    var db = databaseHandler || openDatabase();

    db.transaction(function(tx) {
        if (deleteDatabase) {
            tx.executeSql("\
                DROP TABLE IF EXISTS \
                    km_trip \
                ;");
            tx.executeSql("\
                DROP TABLE IF EXISTS \
                    km_proj \
                ;");
        }
    });
}

function initializeDatabase( dbH ) {
    var db = dbH || openDatabase();
    console.log("initializeDatabase started");
    db.transaction(function(tx) {
        /*
         * Set up settings.
         */
        tx.executeSql("\
            CREATE TABLE IF NOT EXISTS settings ( \
                setting TEXT PRIMARY KEY, \
                value INTEGER NOT NULL \
            );");

        /*
         * Set up trips.
         */

        console.log("Set up trips");
        tx.executeSql("\
            CREATE TABLE IF NOT EXISTS km_trip ( \
                tripId TEXT PRIMARY KEY NOT NULL DEFAULT CURRENT_TIMESTAMP, \
                tripDate TEXT NOT NULL, \
                descriptn TEXT NOT NULL DEFAULT '', \
                kilometer NUMERIC NOT NULL DEFAULT 0, \
                project TEXT NOT NULL DEFAULT '' \
            );");
        tx.executeSql("\
            CREATE INDEX IF NOT EXISTS active ON km_trip ( \
                tripDate \
            );");
        tx.executeSql("\
            CREATE INDEX IF NOT EXISTS recent ON km_trip ( \
                project, \
                tripDate \
            );");

        /*
         * Set up projects.
         */
        console.log("Set up projects");
        tx.executeSql("\
            CREATE TABLE IF NOT EXISTS km_proj ( \
                project TEXT PRIMARY KEY NOT NULL, \
                invoiced INTEGER NOT NULL DEFAULT 1, \
                price NUMERIC NOT NULL DEFAULT 0.25, \
                kmTarget NUMERIC NOT NULL DEFAULT 300, \
                isTarget INTEGER NOT NULL DEFAULT 1, \
                projType TEXT NOT NULL DEFAULT 'car', \
                bgColor TEXT NOT NULL DEFAULT '#777777' \
            );");
        tx.executeSql("\
            CREATE INDEX IF NOT EXISTS proj ON km_proj ( \
                invoiced, \
                project \
            );");
        tx.executeSql("\
            CREATE INDEX IF NOT EXISTS proj ON km_proj ( \
                projType, \
                project \
            );");

    });

//    // Temporary
//    db.transaction(function(tx) {
//        var rs = tx.executeSql('\
//                INSERT OR REPLACE INTO km_trip \
//                (tripId, tripDate, descriptn, kilometer, project) \
//                VALUES (?,?,?,?,?);', ['2024-12-29', '2024-12-28', 'Snel > huis', 10, 'Cube 300 km']);
//        var id = rs.insertId;
//        console.log("Trip inserted, id=" + id);
//        rs = tx.executeSql('\
//                INSERT OR REPLACE INTO km_proj \
//                (project, invoiced, price, kmTarget, isTarget, projType, bgColor) \
//                VALUES (?,?,?,?,?,?,?);', ['Cube 300 km', 0, 0, 300, 1, 'bike', '#666666']);
//        id = rs.insertId;
//        console.log("Project inserted, id=" + id);
//    } );

    /*
     * Set up view.
     */
    console.log("Set up views");
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            CREATE VIEW IF NOT EXISTS allTrips AS
            SELECT t.tripId, \
                   t.tripDate, \
                   t.descriptn, \
                   t.kilometer, \
                   t.project, \
                   ifnull(p.price, 0) AS price, \
                   ifnull(p.isTarget, 0) AS isTarget, \
                   ifnull(p.bgColor, '') AS bgColor \
              FROM km_trip t \
              LEFT OUTER JOIN km_proj p ON p.project = t.project \
             ORDER BY t.tripDate DESC, t.tripId \
            ;");
    });
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            CREATE VIEW IF NOT EXISTS showTotals AS
            SELECT p.project, \
                   p.invoiced, \
                   p.price, \
                   p.isTarget, \
                   p.projType, \
                   p.bgColor, \
                   SUM(IFNULL(t.kilometer, 0)) AS kmTotal, \
                   SUM(CASE WHEN p.isTarget THEN 0 ELSE IFNULL(t.kilometer * p.price, 0) END) AS amount \
              FROM km_proj p \
              LEFT OUTER JOIN km_trip t ON p.project = t.project \
             GROUP BY p.project \
             ORDER BY p.project \
            ;");
    });
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            CREATE VIEW IF NOT EXISTS showInvoices AS
            SELECT p.project, \
                   substr(t.tripDate, 1, 7) AS tripMonth, \
                   p.invoiced, \
                   p.price, \
                   p.isTarget, \
                   p.bgColor, \
                   SUM(IFNULL(t.kilometer, 0)) AS kmTotal, \
                   SUM(CASE WHEN p.isTarget THEN 0 ELSE IFNULL(t.kilometer * p.price, 0) END) AS amount \
              FROM km_proj p \
              LEFT OUTER JOIN km_trip t on p.project = t.project \
             GROUP BY p.invoiced, p.project, tripMonth \
             ORDER BY p.invoiced DESC, tripMonth DESC, p.project \
            ;");
    });

    console.log("initialization completed");
}

/*
 * All records.
 */
function getTrips() {
    var trips = [];
    console.log("getTrips ");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT t.tripId, \
                   t.tripDate, \
                   t.descriptn, \
                   t.kilometer, \
                   t.project, \
                   ifnull(p.price, 0) AS price, \
                   ifnull(p.isTarget, 0) AS isTarget, \
                   ifnull(p.bgColor, '') AS bgColor \
              FROM km_trip t \
              LEFT OUTER JOIN km_proj p ON p.project = t.project \
             ORDER BY t.tripDate DESC, t.tripId \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            trips.push(rs.rows.item(i));
        }
    });

    return trips;
}

function getProjects() {
    var projs = [];
    console.log("getProjects ");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT project, \
                   invoiced, \
                   price, \
                   kmTarget, \
                   isTarget, \
                   projType, \
                   bgColor \
              FROM km_proj \
             ORDER BY project \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            projs.push(rs.rows.item(i));
        }
    });

    return projs;
}

function addTrip(addNewTrip, tripId, tripDate, descriptn, kilometer, project)
{
    console.log("addTrip ");
    var db = databaseHandler || openDatabase();
    var rs;
    var km = parseFloat(kilometer);

    console.log(JSON.stringify([tripId, tripDate, descriptn, km, project]))

    db.transaction(function(tx) {
        rs = tx.executeSql('\
                INSERT OR REPLACE INTO km_trip \
                (tripId, tripDate, descriptn, kilometer, project) \
                VALUES (?,?,?,?,?);', [tripId, tripDate, descriptn, km, project]);
        var id = rs.insertId;
        console.log("Trip inserted, id=" + id);
    } );

    return 1;
}

function addProj(addNewProj, project, invoiced, price, kmTarget, isTarget, projType, bgColor)
{
    console.log("addProj");
    var db = databaseHandler || openDatabase();
    var rs;

    var pric = parseFloat(price);
    var targ = parseFloat(kmTarget);

    console.log(JSON.stringify([project, invoiced, pric, targ, isTarget, bgColor]))
    db.transaction(function(tx) {
        rs = tx.executeSql('\
                INSERT OR REPLACE INTO km_proj \
                (project, invoiced, price, kmTarget, isTarget, projType, bgColor) \
                VALUES (?,?,?,?,?,?,?);', [project, invoiced, pric, targ, isTarget, projType, bgColor]);
        var id = rs.insertId;
        console.log("Project inserted, id=" + id);
    } );
    return 1;
}

function showTotals() {
    var totals = [];
    console.log("showTotals");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT * \
              FROM showTotals \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            totals.push(rs.rows.item(i));
        }
    });

    return totals;
}

function showInvoices() {
    var totals = [];
    console.log("showInvoices");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT * \
              FROM showInvoices \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            totals.push(rs.rows.item(i));
        }
    });

    return totals;
}

function showAllData(debugLog) {
    var rs
    console.log("showAllData ");
    var db = databaseHandler || openDatabase();

    db.transaction(function(tx) {
        rs = tx.executeSql("\
            SELECT * \
                FROM km_trip \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            console.log( JSON.stringify(rs.rows.item(i)));
        }
    });

    console.log("Projects");
    db.transaction(function(tx) {
        rs = tx.executeSql("\
            SELECT * \
                FROM km_proj \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            console.log( JSON.stringify(rs.rows.item(i)));
        }
    });

    return 1
}

function getOneTrip(tripId) {
    var trip
    console.log("getOneTrip: " + tripId);
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT tripId, \
                   tripDate, \
                   descriptn, \
                   kilometer, \
                   project \
              FROM km_trip t  \
                WHERE tripId = ? \
            ;", [tripId]);

        trip  = { tripId    : rs.rows.item(0).tripId,
                  tripDate  : rs.rows.item(0).tripDate,
                  descriptn : rs.rows.item(0).descriptn,
                  kilometer : rs.rows.item(0).kilometer,
                  project   : rs.rows.item(0).project
                };
        console.log(JSON.stringify(trip));
    });

    return trip;

}

function getOneProj(project) {
    var projt
    var id = "'" + project + "'"
    console.log("getOneProj: " + id);
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT project, \
                   invoiced, \
                   price, \
                   kmTarget, \
                   isTarget, \
                   projType, \
                   bgColor \
              FROM km_proj   \
             WHERE project = ? \
            ;", [project]);

        projt = { project  : rs.rows.item(0).project,
                  invoiced : rs.rows.item(0).invoiced,
                  price    : rs.rows.item(0).price,
                  kmTarget : rs.rows.item(0).kmTarget,
                  isTarget : rs.rows.item(0).isTarget,
                  projType : rs.rows.item(0).projType,
                  bgColor  : rs.rows.item(0).bgColor
                };
        console.log(JSON.stringify(projt));
    });

    return projt;

}

/*
 * Handles updates of old databases.
 */
function upgradeDatabase( dbversion )
{
 /*
    console.log("upgradeDatabase ");
    var db = databaseHandler || openDatabase();
    var rs;

    console.log("Current version: " + db.version + ", New version: " + dbversion);
    if (db.version < dbversion )
    {
        db.changeVersion(db.version, dbversion, function (tx) {
            if (db.version < "1.0") {
                /#
                 # Enables remarks with geo_letters, and a (formula) rawtext with geo_waypts.
                 #/
                rs = tx.executeSql("ALTER TABLE geo_waypts ADD COLUMN rawtext TEXT DEFAULT ''");
                console.log(rs);
                console.log("Tables altered 1.0");
                db.version = "1.0";
            }
            /#
             # Upgrade complete.
             #/
        });
    }
 */
}

function deleteTrip(tripId)
{
    var db = openDatabase();
    db.transaction(function(tx) {
        tx.executeSql("\
            DELETE FROM km_trip \
                WHERE tripId='?' \
            ;", [tripId]);
    });

    return 1;
}

function deleteProj(project)
{
    var db = openDatabase();
    db.transaction(function(tx) {
        tx.executeSql("\
            DELETE FROM km_proj \
                WHERE project='?' \
            ;", [project]);
    });

    return 1;
}

function getSetting(setting, default_value)
{
    var db = openDatabase();
    var res="";
    try {
        db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT value FROM settings WHERE setting=?;", [setting]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value;
        } else {
            res = default_value;
        }
        })
    } catch (err) {
        console.log("Database " + err);
        res = default_value;
    };
    return res
}

function setSetting(setting, value)
{
    var db = openDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
        }
    } )
    return res;
}

