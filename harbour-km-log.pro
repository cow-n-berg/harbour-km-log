# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-km-log

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-km-log.qml \
    qml/pages/ExportTab.qml \
    qml/pages/InvoiceTab.qml \
    qml/pages/ProjShowPage.qml \
    qml/pages/ReportsPage.qml \
    qml/pages/TargetTab.qml \
    qml/pages/TotalsPage.qml \
    qml/pages/TripShowPage.qml \
    rpm/harbour-km-log.changes.in \
    rpm/harbour-km-log.changes.run.in \
    rpm/harbour-km-log.spec \
    translations/*.ts \
    harbour-km-log.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
#TRANSLATIONS += translations/harbour-km-log-de.ts
