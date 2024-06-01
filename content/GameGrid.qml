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

import QtQuick 6.6
import Minesweeper


Rectangle {
    id: grid

    property int rows: 8
    property int columns: 8
    property int mineCount: 10

    property bool isEnabled: true
    property var cellClickHandler
    property var cellFlaggingHandler

    onIsEnabledChanged: {
        for (let row = 0; row < rows; ++row)
        {
            for (let col = 0; col < columns; ++col)
            {
                getCell(row, col).isEnabled = isEnabled;
            }
        }
    }

    function calculateWidth()
    {
        return Constants.cellWidth * columns + (columns - 1) * Constants.cellGap;
    }

    function calculateHeight()
    {
        return Constants.cellHeight * rows + (rows - 1) * Constants.cellGap;
    }

    width: calculateWidth()
    height: calculateHeight()

    color: 'lightgrey'

    Repeater {
        id: rowRepeater
        model: grid.rows

        Repeater {
            id: columnRepeater
            model: grid.columns

            readonly property int rowIndex: index

            Cell {
                id: cell

                readonly property int rowIndex: columnRepeater.rowIndex
                readonly property int columnIndex: index

                row: rowIndex
                column: columnIndex

                clickHandler: cellClickHandler
                flaggingHandler: cellFlaggingHandler

                x: columnIndex * (Constants.cellWidth + Constants.cellGap)
                y: rowIndex * (Constants.cellHeight + Constants.cellGap)

            }
        }

    }

    property alias cells: rowRepeater

    function getCell(row, column)
    {
        return cells.itemAt(row).itemAt(column);
    }

    function clear()
    {
        for (let row = 0; row < rows; ++row)
        {
            for (let col = 0; col < columns; ++col)
            {
                getCell(row, col).clear();
            }
        }
    }
}
