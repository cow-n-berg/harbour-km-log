import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import "../modules/Opal/Delegates"
import "../modules/Opal/Tabs"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

TabItem {
    id: exportTab

    property string filePath     : StandardPaths.download
    property string csvSeparator : generic.csvSeparator
    property string csvDecimal   : generic.csvDecimal
    property string copyMessage  : ""
    property string csv          : ""
    property int    listLength

    ListModel {
        id: listExport

        // Available csvTrips
        // csvLine

        function update()
        {
            listExport.clear();
            csv = ";"
            var csvTrips = Database.showCsvTrips(csvSeparator, csvDecimal);
            listLength = csvTrips.length;
            for (var i = 0; i < listLength; ++i) {
                listExport.append(csvTrips[i]);
                csv += csvTrips[i].csvLine + "\n";
                console.log( JSON.stringify(csvTrips[i]));
            }
            console.log( "listExport updated");
        }
    }

    Component.onCompleted: listExport.update()

    Timer {
        id: highlightTimer
        interval: 500
        running: false
        onTriggered: {
            iconClipboard.icon.color = Theme.secondaryColor
        }
    }

    Notification {
        id: notification

        summary: copyMessage
        body: "Kilometer"
        expireTimeout: 500
        urgency: Notification.Low
        isTransient: true
    }

    SilicaFlickable {
        id: flick
        anchors {
            fill: parent
        }
        contentHeight: listLength * Theme.itemSizeMedium
        flickableDirection: Flickable.VerticalFlick

        VerticalScrollDecorator {
            flickable: flick
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            ButtonLayout {
                Button {
                    id: iconClipboard

                    text: qsTr("Click to copy csv to clipboard")
                    icon.source: "image://theme/icon-m-clipboard"
                    icon.color: Theme.primaryColor
                    onClicked: {
                        Clipboard.text = csv
                        copyMessage = qsTr("csv text copied to clipboard")
                        iconClipboard.icon.color = Theme.highlightColor
                        highlightTimer.start()
                        notification.publish()
                    }
                }
                Button {
                    id: iconSave

                    text: qsTr("Click to save to Downloads")
                    icon.source: "image://theme/icon-m-cloud-download"
                    icon.color: Theme.primaryColor
                    onClicked: {
                        var dt = new Date()
                        var str = dt.toISOString()
                        var csvPath = filePath + "/km-log-" + str + ".csv"
                        console.log( csvPath )
                        writeToFile(csvPath, csv)
                        copyMessage = qsTr("csv text saved to Downloads")
                        iconSave.icon.color = Theme.highlightColor
                        highlightTimer.start()
                        notification.publish()
                    }
                }
            }

            ViewPlaceholder {
                id: placehTot
                enabled: listExport.count === 0
                text: "No trips yet"
                hintText: "Add some trips,\nand/or create some projects"
            }

            DelegateColumn {
                model: listExport
                delegate: OneLineDelegate {
                    text: csvLine
                }
            }
        }
    }

    // Copied from https://codeberg.org/aerique/pusfofefe

    // The BSD License
    //
    // Copyright (c) 2020, 2021, Erik Winkels
    // All rights reserved.
    //
    // Redistribution and use in source and binary forms, with or without
    // modification, are permitted provided that the following conditions are
    // met:
    //
    //     * Redistributions of source code must retain the above copyright
    //       notice, this list of conditions and the following disclaimer.
    //
    //     * Redistributions in binary form must reproduce the above
    //       copyright notice, this list of conditions and the following
    //       disclaimer in the documentation and/or other materials provided
    //       with the distribution.
    //
    //     * The name of its contributor may not be used to endorse or
    //       promote products derived from this software without specific
    //       prior written permission.
    //
    // THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    // "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    // LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    // A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    // HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    // SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    // LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    // DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    // THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    // (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    // OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    function writeToFile(file, str) {
        var req = new XMLHttpRequest();
        req.open('PUT', 'file://' + file, false);
        req.send(str);
        return req.status;
    }
}
