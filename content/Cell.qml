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
    id: cell

    width: Constants.cellWidth
    height: Constants.cellHeight

    property int row
    property int column

    property bool isMine: false
    property bool isExploded: false
    property bool isFlagged: false
    property bool isOpened: false
    property int nearbyMineCount: -1

    // Disables mouse event handling on game completion (win or loss)
    property alias isEnabled: mouseArea.enabled

    signal clicked(int row, int column)
    signal flagFlipped(bool isFlagged)

    function setNearbyMineCount(count)
    {
        isOpened = true;
        if (isFlagged)
        {
            isFlagged = false;
            flagFlipped(false);
        }

        nearbyMineCount = count;
        renderState(false);
    }

    function open()
    {
        isOpened = true;
        renderState(false);
    }

    function clear()
    {
        isMine = false;
        isExploded = false;
        isFlagged = false;
        isOpened = false;
        nearbyMineCount = -1;

        renderState(false);
    }

    function getColor(hovered)
    {
        return isOpened ? 'whitesmoke' : (hovered ? 'lightgrey' : 'grey');
    }

    function getMineCountDigit()
    {
        return nearbyMineCount > 0 ? String("%1").arg(nearbyMineCount) : "";
    }

    function getMineCountDigitColor()
    {
        switch (nearbyMineCount)
        {
        case 1:
            return 'blue';
        case 2:
            return 'green';
        case 3:
            return 'red';
        case 4:
            return 'brown';
        case 5:
            return 'darkcyan';
        case 6:
            return 'magenta';
        case 7:
            return 'darkorange';
        case 8:
            return 'blueviolet';
        default:
            return 'black';
        }
    }

    color: getColor(false)

    Text {
        id: minesNearby
        visible: nearbyMineCount > 0

        text: getMineCountDigit()
        color: getMineCountDigitColor()

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font: Constants.font
    }

    Image {
        id: flagIcon
        visible: isFlagged && !isOpened

        source: "images/flag.png"

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Image {
        id: mineIcon
        visible: isMine && isOpened

        source: isExploded ? "images/mine-red.png" : "images/mine-black.png"

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    function renderState(hovered)
    {
        color = getColor(hovered);

        minesNearby.visible = nearbyMineCount > 0;
        if (minesNearby.visible)
        {
            minesNearby.text = getMineCountDigit();
            minesNearby.color = getMineCountDigitColor();
        }

        mineIcon.visible = isMine && isOpened;
        flagIcon.visible = isFlagged && !isOpened;
    }

    function onHover(entered)
    {
        if (!isOpened)
        {
            renderState(entered);
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: {
            onHover(true)
        }

        onExited: {
            onHover(false)
        }

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton)
            {
                if (isFlagged)
                   return;

                isOpened = true;

                if (isMine)
                    isExploded = true;

                cell.clicked(row, column);
            }
            else if (mouse.button === Qt.RightButton)
            {
                if (isOpened)
                    return;

                isFlagged = !isFlagged;

                flagFlipped(isFlagged)
            }

            renderState(true);
        }
    }
}
