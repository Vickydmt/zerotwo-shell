pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import Caelestia.Services
import qs.utils

Singleton {
    id: root

    readonly property bool hasDgpu: true
    readonly property string dgpuName: "AMD Radeon RX 6700S (8GB)"
    readonly property string igpuName: "AMD Radeon 680M"

    property string selectedGpu: "dgpu"
    readonly property bool isDgpu: selectedGpu === "dgpu"

    property string dgpuPowerStatus: "suspended"
    property real dgpuUsage: 0.0
    property real dgpuTemp: 45.0
    property string dgpuHwmonPath: "/sys/class/drm/card1/device/hwmon/hwmon4/temp1_input"

    readonly property string currentName: isDgpu ? dgpuName : (Gpu.name || igpuName)
    readonly property string currentLabel: isDgpu ? "dGPU" : "iGPU"
    readonly property string chipText: isDgpu ? "dGPU ⮂" : "iGPU ⮂"
    readonly property real currentUsage: isDgpu ? dgpuUsage : Gpu.percentage
    readonly property real currentTemperature: isDgpu ? (dgpuPowerStatus === "suspended" ? 0 : dgpuTemp) : Gpu.temperature
    readonly property string statusText: isDgpu
        ? (dgpuPowerStatus === "suspended"
            ? "Sleep (0W)"
            : (dgpuUsage === 0 && Gpu.percentage > 0.05
                ? "Idle (iGPU: " + Math.round(Gpu.percentage * 100) + "%)"
                : (dgpuUsage === 0 ? "Idle" : "")))
        : "Active (iGPU)"

    function toggle(): void {
        selectedGpu = isDgpu ? "igpu" : "dgpu";
        storage.setText(selectedGpu);
    }

    FileView {
        id: storage
        path: `${Paths.state}/gpu_preference.txt`
        printErrors: false

        onLoaded: {
            const val = text().trim();
            if (val === "dgpu" || val === "igpu") {
                root.selectedGpu = val;
            }
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                Qt.callLater(() => storage.setText("dgpu"));
            }
        }
    }

    FileView {
        id: statusFile
        path: "/sys/class/drm/card1/device/power/runtime_status"
        printErrors: false
        onLoaded: {
            const st = text().trim();
            root.dgpuPowerStatus = st;
            if (st === "suspended") {
                root.dgpuUsage = 0.0;
                busyFile.path = "";
                tempFile.path = "";
            } else {
                busyFile.path = "/sys/class/drm/card1/device/gpu_busy_percent";
                tempFile.path = root.dgpuHwmonPath;
                busyFile.reload();
                tempFile.reload();
            }
        }
    }

    FileView {
        id: busyFile
        path: ""
        printErrors: false
        onLoaded: {
            const val = parseFloat(text().trim());
            if (!isNaN(val)) root.dgpuUsage = val / 100.0;
        }
    }

    FileView {
        id: tempFile
        path: ""
        printErrors: false
        onLoaded: {
            const val = parseFloat(text().trim());
            if (!isNaN(val) && val > 0) root.dgpuTemp = val / 1000.0;
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "find /sys/class/drm/card1/device/hwmon/ -name 'temp1_input' 2>/dev/null | head -n 1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                if (p) {
                    root.dgpuHwmonPath = p;
                }
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            statusFile.reload();
            if (root.dgpuPowerStatus !== "suspended") {
                if (busyFile.path !== "") busyFile.reload();
                if (tempFile.path !== "") tempFile.reload();
            }
        }
    }
}
