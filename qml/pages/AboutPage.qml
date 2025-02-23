import QtQuick 2.2
import "../modules/Opal/About"

AboutPageBase {
    appName: qsTr("Kilometer")
    appIcon: Qt.resolvedUrl("../images/harbour-km-log.svg")
    appVersion: APP_VERSION
    appRelease: APP_RELEASE
    description: qsTr("Kilometer is a log for two purposes.\n\n" +
                      "Firstly, kilometers made per car, to be invoiced to a client " +
                      "and/or to be paid to me (you), to cover the costs.\n\n" +
                      "Secondly, my bicycle guy prompted me to show up again with my " +
                      "new bicycle after 300 km - not earlier and certainly not later. " +
                      "And then he said the same for a repaired folding bike.\n\n" +
                      "So here we are.")
    authors: "2025 Rob Kouwenberg"
    licenses: License { spdxId: "GPL-3.0-or-later" }
    attributions: Attribution {}
    sourcesUrl: "https://github.com/Pretty-SFOS/opal"
}
