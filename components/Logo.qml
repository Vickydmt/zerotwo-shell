import QtQuick
import Quickshell
import qs.services

Item {
    id: root

    property alias fillMode: image.fillMode
    property color topColour: Colours.palette.m3primary
    property color bottomColour: Colours.palette.m3onSurface

    implicitWidth: 32
    implicitHeight: 32

    Image {
        id: image
        anchors.centerIn: parent
        width: root.width > 0 ? root.width : root.implicitWidth
        height: root.height > 0 ? root.height : root.implicitHeight
        source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/zerotwo.svg`)
        sourceSize.width: Math.round(width * 2)
        sourceSize.height: Math.round(height * 2)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
    }
}
