import QtQuick 6.6
import Minesweeper


Rectangle {
    id: grid

    property int rows: 8
    property int columns: 8
    property int mineCount: 10

    property var cellClickHandler
    property var cellFlaggingHandler

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
}
