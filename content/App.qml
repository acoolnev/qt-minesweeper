import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Minesweeper

Window {
    visible: true
    title: qsTr("Minesweeper")

    SystemPalette { id: systemPalette; colorGroup: SystemPalette.Active }

    width: Constants.width
    height: Constants.height

    color: systemPalette.window

    property bool gameStarted: false

    property int mines: 10
    property int flagged: 0

    function formatMinesCount()
    {
        return String("%1/%2").arg(flagged).arg(mines);
    }

    // 3 sections layout
    //
    // |   | 2 |
    // | 1 |---|
    // |   | 3 |

    GridLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        rows: 2
        columns:2

        rowSpacing: 30
        columnSpacing: 30

        // row: 0-1, col: 0
        Column {
            id: gameGridSection

            Layout.row: 0
            Layout.column: 0
            Layout.rowSpan: 2

            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true

            GameGrid {
                id: gameGrid
            }
        }

        // row: 0, col: 1
        Column {
            id: gameStatsSection

            Layout.row: 0
            Layout.column: 1

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true

            // Extra ColumnLayout to aligh flagGroup and timerGroup at H center
            ColumnLayout {

                ColumnLayout {
                    id: flagGroup

                    Layout.alignment: Qt.AlignHCenter

                    Image {
                        Layout.alignment: Qt.AlignHCenter

                        id: flagIcon
                        source: "images/flag.png"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter

                        id: mineStatsText
                        text: formatMinesCount()
                    }
                }

                ColumnLayout
                {
                    id: timerGroup

                    property real startTime: 0
                    property alias runTimer: gameTimer.running

                    function startTimer()
                    {
                        startTime = Date.now();
                        runTimer = true;
                    }

                    function stopTimer()
                    {
                        runTimer = false;
                    }

                    function getElapsedTime()
                    {
                        return runTimer ? Math.floor((Date.now() - startTime) / 1000) : 0;
                    }

                    function formatElapsedTime()
                    {
                        let time = getElapsedTime();
                        return String("%1:%2").arg(Math.floor(time / 60).toString().padStart(2, '0'))
                                              .arg(Math.floor(time % 60).toString().padStart(2, '0'));
                    }

                    Image {
                        Layout.alignment: Qt.AlignHCenter

                        id: watchIcon
                        source: "images/watch.png"
                    }

                    Text {

                        Layout.alignment: Qt.AlignHCenter

                        id: timerText
                        text: "00:00"
                    }

                    Timer {
                        id: gameTimer

                        interval: 1000
                        running: false
                        repeat: true
                        onTriggered: timerText.text = timerGroup.formatElapsedTime()
                    }
                }
            }
        }

        // row: 1, col: 1
        Column {
            id: buttonsSection

            Layout.row: 1
            Layout.column: 1

            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom

            // fillHeight must be true in above section to allow bottom allignment
            // of this section
            Layout.fillHeight: false

            Button {
                id: startOver

                visible: false

                Layout.alignment: Qt.AlignHCenter
                text: "Start over"
                hoverEnabled: true

                background: Rectangle {
                    color: parent.down ? "#d6d6d6" : (parent.hovered ? "#e8e8e8" : "#f5f5f5")
                    border.color: 'grey'
                    border.width: 1
                    radius: 4
                }
            }
        }

    }

    function getRandom(max)
    {
        return Math.floor(Math.random() * max);
    }

    function getCell(row, column)
    {
        return gameGrid.getCell(row, column);
    }

    function getNearCellOffsets()
    {
        const cellOffsets = [[-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1,-1], [0, -1]];

        return cellOffsets;
    }

    function isInGridBounds(row, column)
    {
        return row >= 0 && row < gameGrid.rows &&
               column >= 0 && column < gameGrid.columns;
    }

    function calculateNearbyMineCount(cell)
    {
        let count = 0;
        for (let cellOffset of getNearCellOffsets())
        {
            let nearRow = cell.row + cellOffset[0];
            let nearColumn = cell.column + cellOffset[1];

            if (!isInGridBounds(nearRow, nearColumn))
                continue;

            if (getCell(nearRow, nearColumn).isMine)
                ++count;
        }

        return count;
    }

    function isVisited(cell)
    {
        return cell.nearbyMineCount >= 0;
    }

    function onCellClick(row, column)
    {
        if (!gameStarted)
        {
            startGame(row, column);
        }

        let queue = [];
        queue.push([row, column]);
        while (queue.length > 0)
        {
            [row, column] = queue.shift();
            let cell = getCell(row, column);

            if (isVisited(cell))
                continue;

            let mineCount = calculateNearbyMineCount(getCell(row, column));
            cell.setNearbyMineCount(mineCount);
            if (mineCount > 0)
                continue;


            for (let cellOffset of getNearCellOffsets())
            {
                let nearRow = row + cellOffset[0];
                let nearColumn = column + cellOffset[1];

                if (!isInGridBounds(nearRow, nearColumn) ||
                    isVisited(getCell(nearRow, nearColumn)))
                    continue;

                queue.push([nearRow, nearColumn]);
            }
        }
    }

    function onCellFlagging(isFlagged)
    {
        flagged += isFlagged ? 1 : -1;
    }

    function init(rowCount, columnCount, mineCount)
    {
        gameStarted = false;

        mines = mineCount;
        flagged = 0;

        gameGrid.rows = rowCount;
        gameGrid.columns = columnCount;
        gameGrid.mineCount = mineCount;

        gameGrid.cellClickHandler = onCellClick;
        gameGrid.cellFlaggingHandler = onCellFlagging;
    }

    function startGame(excludeMineAtRow, excludeMineAtColumn)
    {
        if (gameStarted)
            return;

        gameStarted = true;

        flagged = 0;

        for (let i = 0; i < gameGrid.mineCount; ++i)
        {
            let mineRow
            let mineColumn
            do
            {
                mineRow = getRandom(gameGrid.rows);
                mineColumn =  getRandom(gameGrid.columns);
            }
            while (getCell(mineRow, mineColumn).isMine ||
                   (mineRow === excludeMineAtRow && mineColumn === excludeMineAtColumn));

            getCell(mineRow, mineColumn).isMine = true;
        }

        timerGroup.startTimer();
    }


    Component.onCompleted: init(Constants.gameGridRows, Constants.gameGridColumns,
                                Constants.gameMineCount)
}

