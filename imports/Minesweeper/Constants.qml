pragma Singleton
import QtQuick 6.6

QtObject {
    readonly property int gameGridRows: 8
    readonly property int gameGridColumns: 8
    readonly property int gameMineCount: 10

    readonly property int width: 640
    readonly property int height: 480

    readonly property int cellWidth: 40
    readonly property int cellHeight: 40
    readonly property int cellGap: 4


    /* Edit this comment to add your custom font */
    readonly property font font: Qt.font({
                                             family: Qt.application.font.family,
                                             pixelSize: Qt.application.font.pixelSize * 1.6,
                                             bold: true
                                         })
}
