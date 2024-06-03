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

    enum GameStatus
    {
        INITIALIZED,
        IN_PROGRESS,
        WIN,
        LOSS
    }

    property int gameStatus: App.GameStatus.INITIALIZED

    function isGameCompleted()
    {
        return gameStatus === App.GameStatus.WIN || gameStatus === App.GameStatus.LOSS;
    }

    property var mineCells: []
    property int mines: 10
    property int flagged: 0
    property int opened: 0

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

                onCellClicked: (row, column) => onCellClick(row, column)
                onCellFlagFlipped: (isFlagged) => onCellFlagging(isFlagged)
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

                    // The function preserves the timer text to show it on a game completion.
                    function stopTimer()
                    {
                        runTimer = false;
                    }

                    function resetTimer()
                    {
                        timerText.text = formatElapsedTime();
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

            ColumnLayout
            {
                Image {
                    Layout.alignment: Qt.AlignHCenter

                    id: smileyIcon
                    source: gameStatus === App.GameStatus.WIN ? "images/smiley-happy.png" : "images/smiley-sad.png"
                    visible: isGameCompleted()
                }

                Button {
                    id: startOver

                    visible: true
                    enabled: gameStatus !== App.GameStatus.INITIALIZED

                    Layout.alignment: Qt.AlignHCenter
                    text: isGameCompleted() ? qsTr("Play again") : qsTr("Start over")
                    hoverEnabled: true

                    background: Rectangle {
                        color: parent.down ? "#d6d6d6" : (parent.hovered ? "#e8e8e8" : "#f5f5f5")
                        border.color: 'grey'
                        border.width: 1
                        radius: 4
                    }

                    onClicked: {
                        timerGroup.stopTimer();
                        timerGroup.resetTimer();
                        init();
                    }
                }
            }
        }

    }

    function getRandom(max)
    {
        return Math.floor(Math.random() * max);
    }

    function getCellCount()
    {
        return Constants.gameGridRows * Constants.gameGridColumns;
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
        if (gameStatus === App.GameStatus.INITIALIZED)
        {
            startGame(row, column);
        }
        else if (gameStatus !== App.GameStatus.IN_PROGRESS)
        {
            return;
        }

        if (getCell(row, column).isMine)
        {
            onGameLoss();
            return;
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
            onCellOpening();
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

        if (getCellCount() - opened === mines)
        {
            onGameWin();
            return;
        }
    }

    function onCellFlagging(isFlagged)
    {
        if (gameStatus === App.GameStatus.INITIALIZED)
        {
            startGame(-1, -1);
        }

        flagged += isFlagged ? 1 : -1;
    }

    function onCellOpening()
    {
        opened += 1;
    }

    function onGameWin()
    {
        gameStatus = App.GameStatus.WIN;

        timerGroup.stopTimer();

        gameGrid.isEnabled = false;
    }

    function onGameLoss()
    {
        gameStatus = App.GameStatus.LOSS;

        timerGroup.stopTimer();

        for (let mineCell of mineCells)
        {
            mineCell.open();
        }

        gameGrid.isEnabled = false;
    }

    function init(rowCount, columnCount, mineCount)
    {
        gameStatus = App.GameStatus.INITIALIZED;

        mines = Constants.gameMineCount;
        flagged = 0;
        opened = 0;

        gameGrid.rows = Constants.gameGridRows;
        gameGrid.columns = Constants.gameGridColumns;
        gameGrid.mineCount = Constants.gameMineCount;

        gameGrid.clear();
        gameGrid.isEnabled = true;
    }

    function startGame(excludeMineAtRow, excludeMineAtColumn)
    {
        if (gameStatus === App.GameStatus.IN_PROGRESS)
            return;

        gameStatus = App.GameStatus.IN_PROGRESS;

        flagged = 0;
        opened = 0;

        mineCells = [];

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

            let mineCell = getCell(mineRow, mineColumn);
            mineCell.isMine = true;

            mineCells.push(mineCell);
        }

        timerGroup.startTimer();
    }


    Component.onCompleted: init()
}

