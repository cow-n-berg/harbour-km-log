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
//.import "TextFunctions.js" as TF

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
            console.log("initDatabase " + err);
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
                tripId TEXT DEFAULT CURRENT_TIMESTAMP PRIMARY KEY, \
                tripDate TEXT NOT NULL, \
                descriptn TEXT DEFAULT '', \
                kilometer NUMERIC DEFAULT 0, \
                project TEXT DEFAULT NULL \
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
                project TEXT PRIMARY KEY, \
                invoiced INTEGER DEFAULT 1, \
                price NUMBER DEFAULT 0.25, \
                kmTarget NUMERIC DEFAULT 300, \
                isTarget INTEGER DEFAULT 1, \
                bgColor TEXT DEFAULT '#666666' \
            );");
        tx.executeSql("\
            CREATE INDEX IF NOT EXISTS proj ON km_proj ( \
                invoiced, \
                project \
            );");

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
                   p.project, \
                   p.price, \
                   p.isTarget, \
                   p.bgColor \
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

function getProjects(liveProjs) {
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

function addTrip(tripId, tripDate, descriptn, kilometer, project)
{
    console.log("addTrip ");
    var db = databaseHandler || openDatabase();
    var rs;
    var km = parseInt(kilometer);

    console.log(JSON.stringify([tripId, tripDate, descriptn, kilometer, project]))
    db.transaction(function(tx) {
        tx.executeSql('\
                UPDATE km_trip \
                SET isActive = 0 \
                WHERE isActive = 1;');
        rs = tx.executeSql('\
                INSERT OR REPLACE INTO km_trip \
                (tripId, tripDate, descriptn, kilometer, project) \
                VALUES (?,?,?,?,?);', [tripId, tripDate, descriptn, km, project]);
        var id = rs.insertId;
        console.log("Trip inserted, id=" + id);
    } );
    return 1;
}

function addProj(project, invoiced, price, kmTarget, isTarget, isArchived, bgColor)
{
    console.log("addProj");
    var db = databaseHandler || openDatabase();
    var rs;
    console.log(JSON.stringify([project, invoiced, price, kmTarget, isTarget, bgColor]))
    db.transaction(function(tx) {
        rs = tx.executeSql('\
                INSERT OR REPLACE INTO km_proj \
                (project, invoiced, price, kmTarget, isTarget, bgColor) \
                VALUES (?,?,?,?,?,?,?);', [project, invoiced, price, kmTarget, isTarget, bgColor]);
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
            SELECT p.project, \
                   p.invoiced, \
                   p.price, \
                   p.isTarget, \
                   p.bgColor, \
                   SUM(t.kilometer) AS kmTotal, \
                   substr(t.tripDate, 1, 7) AS tripMonth, \
                   CASE WHEN NOT p.isTarget THEN SUM(t.kilometer) * p.price ELSE 0 END AS amount \
              FROM km_proj p \
              LEFT OUTER JOIN km_trip t ON p.project = t.project \
             GROUP BY p.project, tripMonth \
             ORDER BY p.project, tripMonth DESC \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            totals.push(rs.rows.item(i));
        }
    });

    return totals;
}

function showInvoices() {
    var totals = [];
    console.log("showTotals");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT p.project, \
                   p.project, \
                   p.invoiced, \
                   p.price, \
                   p.isTarget, \
                   p.bgColor, \
                   SUM(t.kilometer) AS kmTotal, \
                   substr(t.tripDate, 1, 7) AS tripMonth, \
                   CASE WHEN p.isTarget THEN 0 ELSE SUM(t.kilometer) * p.price END AS amount \
              FROM km_proj p \
              LEFT OUTER JOIN km_trip t on p.project = t.project \
             GROUP BY p.isTarget, p.project, tripMonth \
             ORDER BY p.isTarget DESC, tripMonth DESC, p.project \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            totals.push(rs.rows.item(i));
        }
    });

    return totals;
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
                rs = tx.executeSql("ALTER TABLE geo_letters ADD COLUMN remark TEXT DEFAULT ''");
                console.log(rs);
                console.log("Tables altered 1.0");
                db.version = "1.0";
            }
            if (db.version < "1.2") {
                /#
                 # Enables remarks with geo_letters, and a (formula) rawtext with geo_waypts.
                 #/
                rs = tx.executeSql("DROP INDEX IF EXISTS trip_letter;");
                rs = tx.executeSql("DROP INDEX IF EXISTS waypt_letter;");
                tx.executeSql("\
                    CREATE UNIQUE INDEX IF NOT EXISTS trip_letter ON geo_letters ( \
                        tripId, \
                        letter \
                    );");
                tx.executeSql("\
                    CREATE UNIQUE INDEX IF NOT EXISTS waypt_letter ON geo_letters ( \
                        wayptid, \
                        letter \
                    );");
                db.version = "1.2";
                console.log("Tables altered 1.2");
            }
            // Version 1.3 and 1.4 got lost in upgrade problems
            if (db.version < "1.5") {
                /#
                 # Adds new column to geotrips.
                 #/
                rs = tx.executeSql("ALTER TABLE geotrips ADD COLUMN isActive INTEGER DEFAULT 0");
                console.log(rs);
                rs = tx.executeSql("\
                    CREATE INDEX isActive ON geotrips ( \
                        isActive, \
                        found, \
                        name \
                    );");
                console.log(rs);
                db.version = "1.5";
                rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', ["databaseVersion",15]);
                console.log("Tables altered " + db.version);
            }
            if (db.version < "1.6") {
                /#
                 # Adds new column to geotrips.
                 #/
                rs = tx.executeSql("ALTER TABLE geotrips ADD COLUMN isActive TEXT DEFAULT ''");
                console.log(rs);
                db.version = "1.6";
                rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', ["databaseVersion",16]);
                console.log("Tables altered " + db.version);
            }
            /#
             # Upgrade complete.
             #/
        });
    }
 */
}

/*
function getWaypts(tripId, hideFound) {
    var waypts = [];
    console.log("getWaypts ");
    var db = databaseHandler || openDatabase();
    var i;

    db.transaction(function(tx) {
        tx.executeSql('\
                UPDATE km_trip \
                SET isActive = 0 \
                WHERE isActive = 1;');
        tx.executeSql('\
            UPDATE km_trip \
            SET isActive = 1 \
            WHERE tripId = ? \
            ;', [tripId]);
    });

    if (hideFound) {
        db.transaction(function(tx) {
            var rs = tx.executeSql("\
                SELECT tripId, \
                    wayptid, \
                    waypoint, \
                    formula, \
                    '' AS calculated, \
                    note, \
                    is_waypoint, \
                    found \
                FROM geo_waypts \
                WHERE tripId = ? \
                  AND found = 0\
                ORDER BY tripId, waypoint \
                ;", [tripId]);
            for (i = 0; i < rs.rows.length; ++i) {
                waypts.push(rs.rows.item(i));
            }
        });
    }
    else {
        db.transaction(function(tx) {
            var rs = tx.executeSql("\
                SELECT tripId, \
                    wayptid, \
                    waypoint, \
                    formula, \
                    '' AS calculated, \
                    note, \
                    is_waypoint, \
                    found \
                    FROM geo_waypts \
                    WHERE tripId = ? \
                    ORDER BY tripId, waypoint \
                ;", [tripId]);
            for (i = 0; i < rs.rows.length; ++i) {
                waypts.push(rs.rows.item(i));
            }
        });
    }
    var allLetters = getLetters(tripId);
    for (i = 0; i < waypts.length; ++i) {
        waypts[i].calculated = TF.evalFormula(waypts[i].formula, allLetters) ;
    }
    console.log(JSON.stringify(waypts));
    return waypts;
}

function getLetters(tripId) {
    var letters = [];
    console.log("getLetters ");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT # \
                FROM geo_letters \
                WHERE tripId = ? \
                ORDER BY letter \
            ;", [tripId]);
        for (var i = 0; i < rs.rows.length; ++i) {
            letters.push(rs.rows.item(i));
        }
    });
    console.log(JSON.stringify(letters));
    return letters;
}

function getLettersWP(wayptid) {
    var letters = [];
    console.log("getLettersWP ");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT # \
                FROM geo_letters \
                WHERE wayptid = ? \
                ORDER BY letter \
            ;", [wayptid]);
        for (var i = 0; i < rs.rows.length; ++i) {
            letters.push(rs.rows.item(i));
        }
    });

    return letters;
}

function allLettersWpFound(wayptid) {
    var found = true;
    console.log("allLettersWpFound ");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT COUNT(#) AS nr \
                FROM geo_letters \
                WHERE wayptid = ? \
                AND lettervalue = '' \
            ;", [wayptid]);
        if (rs.rows.item(0).nr === 1)
            found = false;
    });

    return found;
}

function getOneWaypt(wayptid) {
    var waypt
    console.log("getOneWaypt ");
    var db = databaseHandler || openDatabase();
    var letters = []
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT waypoint, \
                rawtext, \
                formula, \
                note, \
                is_waypoint, \
                found \
                FROM geo_waypts \
                WHERE wayptid = ? \
            ;", [wayptid]);
        waypt = { waypoint  : rs.rows.item(0).waypoint,
                  rawtext   : rs.rows.item(0).rawtext,
                  formula   : rs.rows.item(0).formula,
                  note      : rs.rows.item(0).note,
                  iswp      : rs.rows.item(0).is_waypoint,
                  found     : rs.rows.item(0).found,
                  letterstr : undefined,
                  letters   : undefined };
        rs = tx.executeSql("\
            SELECT letterid, \
                letter,\
                lettervalue \
                FROM geo_letters \
                WHERE wayptid = ? \
                ORDER BY letter \
            ;", [wayptid]);
        var str = "";
        for (var i = 0; i < rs.rows.length; ++i) {
            str += (rs.rows.item(i).letter) + " ";
            letters.push(rs.rows.item(i));
        }
        waypt.letterstr = str.trim();
        waypt.letters = letters;
//        console.log(JSON.stringify(waypt));
    });

    return waypt;

}

function getOneLetter(letterid) {
    var letters = [];
    console.log("getOneLetter ");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT letter, \
                lettervalue, \
                remark \
                FROM geo_letters \
                WHERE letterid = ? \
            ;", [letterid]);
        for (var i = 0; i < rs.rows.length; ++i) {
            letters.push(rs.rows.item(i));
        }
    });

    return letters;
}

function showAllData() {
    var rs
    console.log("showAllData ");
    var db = databaseHandler || openDatabase();

    db.transaction(function(tx) {
        rs = tx.executeSql("\
            SELECT # \
                FROM km_trip \
                ORDER BY found ASC, updatd DESC \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            console.log(JSON.stringify(rs.rows.item(i)));
        }
    });

    console.log("Waypoints");
    db.transaction(function(tx) {
        rs = tx.executeSql("\
            SELECT # \
                FROM geo_waypts \
                ORDER BY tripId, waypoint \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            console.log(JSON.stringify(rs.rows.item(i)));
        }
    });

    console.log("Letters");
    db.transaction(function(tx) {
        rs = tx.executeSql("\
            SELECT # \
                FROM geo_letters \
                ORDER BY tripId, letter \
            ;");
        for (var i = 0; i < rs.rows.length; ++i) {
            console.log(JSON.stringify(rs.rows.item(i)));
        }
    });

    return 1
}

/#
#  Function to show all waypoints and letters
#/
function showtripLetters( tripId ) {
    var result = "";
    var oldWpt = "";
    console.log("showtripLetters ");
    var db = databaseHandler || openDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("\
            SELECT w.waypoint, \
                l.letter \
                FROM geo_waypts AS w
                INNER JOIN geo_letters AS l ON w.wayptid = l.wayptid\
                WHERE w.tripId=? \
                ORDER BY w.waypoint, l.letter \
            ;", [tripId]);
        for (var i = 0; i < rs.rows.length; ++i) {
            if (rs.rows.item(i).waypoint === oldWpt) {
                result += ", '" + rs.rows.item(i).letter + "'";
            }
            else {
                oldWpt = rs.rows.item(i).waypoint;
                result += (i === 0 ? "" : "\n") + "WP " + oldWpt + qsTr(", requires: '") + rs.rows.item(i).letter + "'";
            }
        }
    });
    return result
}

/#
 # Adds a new geotrip.
 #/
function addStd1trip() {
    var geotrip = 'GC3A7RC';
    var name = 'where it started';
    var found = false;
    var defaultWpts =
        [
            { waypt: "1", is_waypt: "1", found: "0", formula: "N 47 36.600 W 122 20.555",                 letters: ["A", "B"], note: "green wooden boards = A, bolts under awning = B" },
            { waypt: "2", is_waypt: "1", found: "0", formula: "N 47 36.[580+A] W 122 20.[507+B]",         letters: ["C", "D"], note: "red seat holes (even) = C and green seat holes (odd) = D" },
            { waypt: "3", is_waypt: "1", found: "0", formula: "N 47 36.[547+C] W 122 20.[494+D]",         letters: ["E", "F"], note: "number of letters in the first word = E and the second word = F, both are even numbers" },
            { waypt: "4", is_waypt: "0", found: "0", formula: "N 47 36.[589+A+B+C] W 122 20.[542+D+E+F]", letters: [],         note: "PLEASE WATCH OUT FOR MUGGLES" }
        ];

    console.log("addStd1trip ");
    var db = databaseHandler || openDatabase();

    db.transaction(function(tx) {
        var rs = tx.executeSql("\
                    INSERT OR REPLACE INTO km_trip \
                    (geotrip, name, found) \
                    VALUES (?,?,?);", [geotrip,name,found]);
        console.log(JSON.stringify(rs));
        var tripId = rs.insertId;
        console.log(tripId);
        for (var i = 0; i < defaultWpts.length; ++i) {
            var lt = defaultWpts[i].letters;
            rs = tx.executeSql("\
                    INSERT OR REPLACE INTO geo_waypts \
                    (tripId, waypoint, formula, rawtext, note, is_waypoint, found) \
                    VALUES (?,?,?,?,?,?,?);", [tripId, defaultWpts[i].waypt, defaultWpts[i].formula, defaultWpts[i].formula, defaultWpts[i].note, defaultWpts[i].is_waypt, defaultWpts[i].found]);
            var wayptId = rs.insertId;
            for (var j = 0; j < lt.length; ++j) {
                tx.executeSql("\
                    INSERT OR REPLACE INTO geo_letters \
                    (wayptid, tripId, letter) \
                    VALUES (?,?,?);", [wayptId, tripId, lt[j]]);
            }
        }
    });
    return 1
}

function addStd2trip() {
    var geotrip = 'GC83QV1';
    var name = 'Het Utrechts zonnestelsel (op zoek naar Pluto)';
    var found = false;
    var defaultWpts =
        [
            { waypt: "0", is_waypt: "1", found: "0", formula: "N 52 05.417 E 005 07.330",              letters: [],    note: "De Zon." },
            { waypt: "1", is_waypt: "1", found: "0", formula: "58 mln. km / 58 meter",                 letters: ["A"], note: "Mercurius. Welke letter komt hier op beide blauwe bordjes voor? Neem de letterwaarde. = A" },
            { waypt: "2", is_waypt: "1", found: "0", formula: "108 mln. km / 108 meter",               letters: ["B"], note: "Venus. Neem hier het huisnummer. = B" },
            { waypt: "3", is_waypt: "1", found: "0", formula: "150 mln. km / 150 meter",               letters: ["C"], note: "Aarde/maan. Neem het nummer van de 'Pijke Koch' (zwarte lantaarnpaal). = C" },
            { waypt: "4", is_waypt: "1", found: "0", formula: "228 mln. km / 228 meter",               letters: ["D"], note: "Mars. Hoeveel maagden worden hier genoemd (stapeltellen)? = D" },
            { waypt: "5", is_waypt: "1", found: "0", formula: "778 mln. km / 778 meter",               letters: ["E"], note: "Jupiter. Wie verzorgt hier de verwarming (even teruglopen naar de NW hoek vanaf Jupiter)? Het aantal letters. = E" },
            { waypt: "6", is_waypt: "1", found: "0", formula: "1427 mln. km / 1427 meter",             letters: ["F"], note: "Saturnus. Met hoeveel grote bouten zit het stootblok op het ijzer vast? = F" },
            { waypt: "7", is_waypt: "1", found: "0", formula: "2871 mln. km / 2871 meter",             letters: ["G"], note: "Uranus. Hoeveel lampen zitten er ter hoogte van Uranus naast het fietspad onder de brug? =G" },
            { waypt: "8", is_waypt: "1", found: "0", formula: "4498 mln. km / 4498 meter",             letters: ["H"], note: "Neptunus. Aan de overkant van het water zie je een zwarte letter op een geel bord. Neem de letterwaarde (stapeltellen). = H" },
            { waypt: "9", is_waypt: "0", found: "0", formula: "N52 0[A+3].[B-9][C-8][D-2] E005 1[E-4].[F+2][G-1][H-5]", letters: [], note: " " }
        ];

    console.log("AddStd2trip ");
    var db = databaseHandler || openDatabase();

    db.transaction(function(tx) {
        var rs = tx.executeSql("\
                    INSERT OR REPLACE INTO km_trip \
                    (geotrip, name, found) \
                    VALUES (?,?,?);", [geotrip,name,found]);
        console.log(JSON.stringify(rs));
        var tripId = rs.insertId;
        console.log(tripId);
        for (var i = 0; i < defaultWpts.length; ++i) {
            var lt = defaultWpts[i].letters;
            rs = tx.executeSql("\
                    INSERT OR REPLACE INTO geo_waypts \
                    (tripId, waypoint, formula, rawtext, note, is_waypoint, found) \
                    VALUES (?,?,?,?,?,?,?);", [tripId, defaultWpts[i].waypt, defaultWpts[i].formula, defaultWpts[i].formula, defaultWpts[i].note, defaultWpts[i].is_waypt, defaultWpts[i].found]);
            var wayptId = rs.insertId;
            for (var j = 0; j < lt.length; ++j) {
                tx.executeSql("\
                    INSERT OR REPLACE INTO geo_letters \
                    (wayptid, tripId, letter) \
                    VALUES (?,?,?);", [wayptId, tripId, lt[j]]);
            }
        }
    });
    return 1
}


function addWaypt(tripId, wpid, number, formula, rawtext, note, is_waypoint, is_found, letters)
{
    var db = openDatabase();
    var rs, i, j;
    var wayptId = wpid || "";

    var nr = parseInt(number);
    var iswp  = is_waypoint ? 1 : 0;
    var found = is_found    ? 1 : 0;
    var letterstr = "";
    var currLett = [];

    db.transaction(function(tx) {
        // Save waypoint
        rs = tx.executeSql("\
            INSERT OR REPLACE INTO geo_waypts \
            (tripId, wayptid, waypoint, formula, rawtext, note, is_waypoint, found) \
            VALUES (?,?,?,?,?,?,?,?);", [tripId, wayptId, nr, formula, rawtext, note, iswp, found]);
        wayptId = rs.insertId;
        console.log("Waypoint inserted, id=" + wayptId);

        // Format of letters is 'A B C DEF', to be splitted by space
        var arrLett = letters.split(" ");
        if (arrLett.length === 0) {
            arrLett = [letters];
        }

        // Let's see what letters we have right now at this waypoint
        rs = tx.executeSql("\
            SELECT # \
                FROM geo_letters \
                WHERE wayptid = ? \
                ORDER BY letter \
            ;", [wayptId]);
        for (i = 0; i < rs.rows.length; ++i) {
            currLett.push(rs.rows.item(i));
        }

        // Match existing records with newly entered letters
        for (i = 0; i < currLett.length; ++i) {
            var foundLett = false;
            for (j = 0; j < arrLett.length; ++j) {
                if (currLett[i].letter === arrLett[j]) {
                    foundLett = true;
                    // Existing record, so new insert isnot appropriate
                    arrLett[j] = "";
                }
            }
            if (!foundLett) {
                // Fill 'letterstr' as preparation for deletion from geo-letters
                letterstr += (letterstr.length === 0 ? "" : ",") + currLett[i].letter;
            }
        }

        // Inserting letters into geo_letters
        for (i = 0; i < arrLett.length; ++i) {
            if (arrLett[i]) {
                rs = tx.executeSql("\
                    INSERT OR REPLACE INTO geo_letters \
                    (tripId, wayptid, letter) \
                    VALUES (?,?,?);", [tripId, wayptId, arrLett[i]]);
                var lettId = rs.insertId;
            }
        }

        // Deleting superfluous letters
        console.log("Delete from letters, not in: " + letterstr)
        rs = tx.executeSql("\
            DELETE FROM geo_letters \
            WHERE tripId = ? \
              AND wayptid = ? \
              AND letter IN (?);", [tripId, wayptId, letterstr]);
        console.log(JSON.stringify(rs));
    } );
    return 1;
}

function addLetters(tripId, wpid, letters) {
}

function settripFound(tripId, found)
{
    var sqlFound = found ? 1 : 0
    var db = openDatabase();
    var rs;
    db.transaction(function(tx) {
        rs = tx.executeSql('\
            UPDATE km_trip \
            SET found = ?, \
                updatd = CURRENT_TIMESTAMP, \
                isActive = 1 \
            WHERE tripId = ?;', [sqlFound,tripId]);
    } )
}

function setWayptFound(tripId, wayptid, found)
{
    var sqlFound = found ? 1 : 0
    var db = openDatabase();
    var rs;
    db.transaction(function(tx) {
        rs = tx.executeSql('\
            UPDATE km_trip \
            SET updatd = CURRENT_TIMESTAMP \
            WHERE tripId = ?;', [tripId]);
        rs = tx.executeSql('\
            UPDATE geo_waypts \
            SET found = ? \
            WHERE wayptid = ?;', [sqlFound,wayptid]);
        rs = tx.executeSql('\
            SELECT # FROM geo_waypts \
            WHERE tripId = ?;', [tripId]);
    } )
}

function setLetter(tripId, wayptId, letterid, letter, value, remark)
{
    var valuestr = value.toString();
    var db = openDatabase();
    db.transaction(function(tx) {
        tx.executeSql("\
            UPDATE geo_letters \
            SET lettervalue = ?,
                remark = ? \
            WHERE letterid = ? \
        ;", [value,remark,letterid]);
    } )
}

function deletetrip(tripId)
{
    var db = openDatabase();
    db.transaction(function(tx) {
        tx.executeSql("\
            DELETE FROM km_trip \
                WHERE tripId=? \
            ;", [tripId]);
        tx.executeSql("\
            DELETE FROM geo_waypts \
                WHERE tripId=? \
            ;", [tripId]);
        tx.executeSql("\
            DELETE FROM geo_letters \
                WHERE tripId=? \
            ;", [tripId]);
    });

    return 1;
}

function deleteWaypt(wayptid, tripId)
{
    var db = openDatabase();
    db.transaction(function(tx) {
        tx.executeSql('\
            UPDATE km_trip \
            SET updatd = CURRENT_TIMESTAMP \
            WHERE tripId = ?;', [tripId]);
        tx.executeSql("\
            DELETE FROM geo_waypts \
                WHERE wayptid=? \
            ;", [wayptid]);
        tx.executeSql("\
            DELETE FROM geo_letters \
                WHERE wayptid=? \
            ;", [wayptid]);
    });

    return 1;
}

function deleteLetters(wayptid)
{
    var db = openDatabase();
    db.transaction(function(tx) {
        tx.executeSql("\
            DELETE FROM geo_letters \
                WHERE wayptid=? \
            ;", [wayptid]);
    });

    return 1;
}

function clearValues(tripId)
{
    var db = openDatabase();
    db.transaction(function(tx) {
        tx.executeSql("\
            UPDATE geo_letters \
                SET lettervalue = '',
                    remark = '' \
                WHERE tripId=? \
            ;", [tripId]);
    });

    return 1;
}
*/

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

