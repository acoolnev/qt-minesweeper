// Copyright (C) 2024 acoolnev(https://github.com/acoolnev)
// This program is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation, version 3.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program.
// If not, see <https://www.gnu.org/licenses/>.

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
