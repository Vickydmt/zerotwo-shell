import QtQuick
import Caelestia.Config
import qs.components
import qs.components.effects
import qs.services
import qs.utils

Item {
    id: root

    implicitWidth: Math.round(Tokens.font.body.large.pointSize * 1.6)
    implicitHeight: Math.round(Tokens.font.body.large.pointSize * 1.6)

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const screenState = ShellState.forActive();
            screenState.launcher = !screenState.launcher;
        }
    }

    Loader {
        asynchronous: true
        anchors.centerIn: parent
        sourceComponent: SysInfo.isDefaultLogo ? zerotwoLogo : distroIcon
    }

    Component {
        id: zerotwoLogo

        Logo {
            implicitWidth: root.implicitWidth
            implicitHeight: root.implicitHeight
            width: root.implicitWidth
            height: root.implicitHeight
        }
    }

    Component {
        id: distroIcon

        Image {
            source: SysInfo.osLogo
            width: Math.round(Tokens.font.body.large.pointSize * 1.5)
            height: Math.round(Tokens.font.body.large.pointSize * 1.5)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }
    }
}
