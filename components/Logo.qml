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
        anchors.fill: parent
        source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/zerotwo.svg`)
        sourceSize.width: Math.max(64, Math.round((root.width > 0 ? root.width : root.implicitWidth) * 2))
        sourceSize.height: Math.max(64, Math.round((root.height > 0 ? root.height : root.implicitHeight) * 2))
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
    }
}
