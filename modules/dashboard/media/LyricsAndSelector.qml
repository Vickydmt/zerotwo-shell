pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Caelestia.Config
import Caelestia.I18n
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    property string mode: "dance"
    readonly property bool isLyricsMode: mode === "lyrics"

    function toggleMode() {
        mode = isLyricsMode ? "dance" : "lyrics";
        storage.setText(mode);
    }

    ServiceRef {
        service: Audio.beatTracker
    }

    FileView {
        id: storage

        path: `${Paths.state}/media_view_mode.txt`
        printErrors: false

        onLoaded: {
            const val = text().trim();
            if (val === "lyrics" || val === "dance") {
                root.mode = val;
            }
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                Qt.callLater(() => storage.setText("dance"));
            }
        }
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.leftMargin: Tokens.padding.medium
        spacing: Tokens.spacing.medium

        RowLayout {
            Layout.bottomMargin: -Tokens.spacing.medium
            spacing: Tokens.spacing.small
            z: 1

            MouseArea {
                id: titleClickArea

                Layout.fillWidth: true
                implicitHeight: titleRow.implicitHeight
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.toggleMode()

                RowLayout {
                    id: titleRow

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Tokens.spacing.small

                    MaterialIcon {
                        Layout.topMargin: Math.round(fontInfo.pointSize * 0.12)
                        text: root.isLyricsMode ? "lyrics" : "animated_images"
                        fontStyle: Tokens.font.icon.medium
                        color: titleClickArea.containsMouse ? Colours.palette.m3primary : Colours.palette.m3onSurface

                        Behavior on color {
                            CAnim {}
                        }
                    }

                    StyledText {
                        text: root.isLyricsMode ? Tr.tr("Lyrics") : Tr.tr("Dance")
                        font: Tokens.font.title.medium
                        color: titleClickArea.containsMouse ? Colours.palette.m3primary : Colours.palette.m3onSurface

                        Behavior on color {
                            CAnim {}
                        }
                    }
                }
            }

            IconButton {
                type: IconButton.Tonal
                icon: root.isLyricsMode ? "animated_images" : "lyrics"
                isRound: true
                onClicked: root.toggleMode()
            }

            LyricsInfo {
                visible: root.isLyricsMode
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: danceView

                anchors.fill: parent
                opacity: root.isLyricsMode ? 0 : 1
                visible: opacity > 0

                Behavior on opacity {
                    Anim {
                        type: Anim.DefaultEffects
                    }
                }

                AnimatedImage {
                    id: danceGif

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.small
                    playing: true
                    paused: !(Players.active?.isPlaying ?? false)
                    speed: (Audio.beatTracker.bpm > 0 && Config.general.mediaGifSpeedAdjustment > 0)
                        ? (Audio.beatTracker.bpm / Config.general.mediaGifSpeedAdjustment)
                        : 1.0
                    source: Paths.absolutePath(Config.paths.mediaGif)
                    asynchronous: true
                    fillMode: AnimatedImage.PreserveAspectFit
                }
            }

            LyricList {
                id: lyricsView

                anchors.fill: parent
                opacity: root.isLyricsMode ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    Anim {
                        type: Anim.DefaultEffects
                    }
                }
            }
        }

        SplitButton {
            Layout.alignment: Qt.AlignHCenter

            type: SplitButton.Tonal
            disabled: !Players.list.length
            active: menuItems.find(m => m.modelData === Players.active) ?? menuItems[0] ?? null
            menu.onItemSelected: item => Players.manualActive = (item as PlayerItem).modelData

            menuItems: playerList.instances
            fallbackIcon: "music_off"
            fallbackText: Tr.trCtx("No players", "no media players active")

            minLeftWidth: layout.width - expandBtn.implicitWidth - spacing
            label.Layout.maximumWidth: minLeftWidth - iconLabel.implicitWidth - textRow.spacing - textRow.anchors.horizontalCenterOffset / 2 - horizontalPadding * 2
            label.elide: Text.ElideRight

            stateLayer.disabled: true
            menuOnTop: true

            Variants {
                id: playerList

                model: Players.list

                PlayerItem {}
            }
        }
    }

    component PlayerItem: MenuItem {
        required property MprisPlayer modelData

        icon: modelData === Players.active ? "check" : ""
        text: Players.getIdentity(modelData)
        activeIcon: "animated_images"
    }
}
