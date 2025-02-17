/*
 * Copyright (C) 2020 Rob Kouwenberg <sailfish@cow-n-berg.nl>
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

/*
*  A truncation function for occasions
*  when Silica components won't work
*/
function truncateString(str, num) {
  if (str.length <= num) {
    return str
  }
  return str.slice(0, num) + '...'
}

/*
*  A trim function for strings
*/
function trimString(str) {
  return str.trim()
}

/*
*  A function to check for empty strings,
*  and issue a replacement string
*/
function replString(str, repl) {
  if (str.trim() === "") {
    return repl
  }
  return str
}

/*
*  Building up an icon url
*/
function coverIconUrl(darkTheme, nightMode) {
    var url;
    var filename = "../images/icon-cover-";
    if (nightMode){
        filename += "black.svg";
    }
    else if (darkTheme) {
        filename += "white.svg";
    }
    else {
        filename += "black.svg";
    }
    url = Qt.resolvedUrl(filename)
//    console.log(url);
    return url
}

function copyIconUrl(darkTheme, nightMode) {
    var url;
    var filename = "../images/icon-cover-copy-";
    if (nightMode){
        filename += "white.svg";
    }
    else if (darkTheme) {
        filename += "white.svg";
    }
    else {
        filename += "black.svg";
    }
    url = Qt.resolvedUrl(filename)
//    console.log(url);
    return url
}

function foundIconUrl(found) {
    var url;
    var filename = "../images/icon-";
    if (found) {
        filename += "found-";
    }
    else {
        filename += "blank-";
    }
    filename += "black.svg";
    url = Qt.resolvedUrl(filename)
//    console.log("foundIcon " + filename)
    return url
}

function wayptIconUrl(isWpt) {
    var url;
    var filename = "../images/icon-";
    if (isWpt) {
        filename += "waypt-";
    }
    else {
        filename += "cache-";
    }
    filename += "black.svg";
    url = Qt.resolvedUrl(filename)
//    console.log("wayptIcon " + filename)
    return url
}

/*
*  Building up a button text
*/
function wayptFoundButton(isWpt, isFound) {
    //qsTr("Mark waypoint as Found")
    var text = qsTr("This ");
    if (isWpt) {
        text += qsTr("waypoint is ");
    }
    else {
        text += qsTr("geocache is ");
    }
    if (isFound) {
        text += qsTr("Found");
    }
    else {
        text += qsTr("Not Found");
    }
    return text
}

/*
*  Building up a button text
*/
function coverText(gccode, gcname, wpnumber, showAppName) {
    var text = "";
    if (gccode !== undefined) {
        text += gccode + "\n" + truncateString(gcname,12);
    }
    if (wpnumber !== undefined) {
        text += "\nWP " + wpnumber;
    }
    if (showAppName) {
        if (gccode !== undefined) {
            text += "\n";
        }
        text += qsTr("GMFS");
    }
    return text
}

/*
*  Total abuse of this function :D
*  Write to console, and return an empty string!
*/
function textConsole( str ) {
    console.log( str );
    return ''
}


