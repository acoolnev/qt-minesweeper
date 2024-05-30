import QtQuick 6.6
import Minesweeper

Rectangle {
    width: Constants.cellWidth
    height: Constants.cellHeight

    property int row
    property int column

    property bool isMine: false
    property bool isExploded: false
    property bool isFlagged: false
    property bool isOpened: false
    property int nearbyMineCount: -1
    property var clickHandler
    property var flaggingHandler

    function setNearbyMineCount(count)
    {
        isOpened = true;
        nearbyMineCount = count;
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
        flagIcon.visible = isFlagged;
    }

    function onHover(entered)
    {
        if (!isOpened)
        {
            renderState(entered);
        }
    }

    MouseArea {
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

                clickHandler(row, column);
            }
            else if (mouse.button === Qt.RightButton)
            {
                if (isOpened)
                    return;

                isFlagged = !isFlagged;

                flaggingHandler(isFlagged)
            }

            renderState(true);
        }
    }
}