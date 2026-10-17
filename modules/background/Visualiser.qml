pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.services

Item {
    id: root

    required property ShellScreen screen
    required property Item wallpaper

    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property bool isWorkspaceEmpty: {
        if (!monitor?.activeWorkspace)
            return true;
        const toplevels = monitor.activeWorkspace.toplevels?.values ?? [];
        return toplevels.length === 0 || toplevels.every(t => t.lastIpcObject?.floating);
    }

    readonly property bool hasMusic: (Players.active?.isPlaying ?? false) || Players.list.some(p => p.isPlaying)
    readonly property bool shouldBeActive: Config.background.visualiser.enabled && hasMusic && (!Config.background.visualiser.autoHide || isWorkspaceEmpty)
    property real offset: shouldBeActive ? 0 : screen.height * 0.2

    opacity: shouldBeActive ? 1 : 0
    visible: opacity > 0

    Loader {
        asynchronous: true
        anchors.fill: parent
        active: root.opacity > 0 && Config.background.visualiser.blur

        sourceComponent: MultiEffect {
            source: root.wallpaper
            maskSource: wrapper
            maskEnabled: true
            blurEnabled: true
            blur: 1
            blurMax: 32
            autoPaddingEnabled: false
        }
    }

    Item {
        id: wrapper

        anchors.fill: parent
        layer.enabled: true

        Loader {
            asynchronous: true
            anchors.fill: parent
            anchors.topMargin: root.offset
            anchors.bottomMargin: -root.offset

            active: root.opacity > 0

            sourceComponent: Item {
                ServiceRef {
                    service: Audio.cava
                }

                Item {
                    id: content

                    anchors.fill: parent
                    anchors.margins: Config.border.thickness
                    anchors.leftMargin: (ShellState.componentsFor(root.screen)?.bar?.exclusiveZone ?? 0) + Tokens.spacing.small * Config.background.visualiser.spacing

                    Side {
                        content: content
                    }
                    Side {
                        content: content
                        isRight: true
                    }

                    Behavior on anchors.leftMargin {
                        Anim {}
                    }
                }
            }
        }
    }

    Behavior on offset {
        Anim {}
    }

    Behavior on opacity {
        Anim {
            type: Anim.DefaultEffects
        }
    }

    component Side: Repeater {
        id: side

        required property Item content
        property bool isRight

        model: GlobalConfig.services.visualiserBars

        ClippingRectangle {
            id: bar

            required property int modelData
            property real value: Math.max(0, Math.min(1, Audio.cava.values[side.isRight ? modelData : side.count - modelData - 1] ?? 0))

            clip: true
            visible: bar.value > 0.001

            x: modelData * ((side.content.width * 0.5) / GlobalConfig.services.visualiserBars) + (side.isRight ? side.content.width * 0.5 : 0)
            implicitWidth: Math.max(1, (side.content.width * 0.5) / GlobalConfig.services.visualiserBars - Tokens.spacing.small * Config.background.visualiser.spacing)

            y: side.content.height - height
            implicitHeight: bar.value > 0.001 ? Math.max(1, Math.min(1.0, Math.pow(bar.value, 1.35) * 1.1) * side.content.height * 0.35) : 0

            color: "transparent"
            topLeftRadius: Tokens.rounding.small * Config.background.visualiser.rounding
            topRightRadius: Tokens.rounding.small * Config.background.visualiser.rounding

            Rectangle {
                topLeftRadius: parent.topLeftRadius
                topRightRadius: parent.topRightRadius

                gradient: Gradient {
                    orientation: Gradient.Vertical

                    GradientStop {
                        position: 0
                        color: Qt.alpha(Colours.palette.m3primary, 0.75)

                        Behavior on color {
                            CAnim {}
                        }
                    }
                    GradientStop {
                        position: 1
                        color: Qt.alpha(Colours.palette.m3inversePrimary, 0.7)

                        Behavior on color {
                            CAnim {}
                        }
                    }
                }

                anchors.left: parent.left
                anchors.right: parent.right
                y: parent.height - height
                implicitHeight: side.content.height * 0.35
            }

            Behavior on value {
                Anim {
                    duration: Tokens.anim.durations.small
                }
            }
        }
    }
}
