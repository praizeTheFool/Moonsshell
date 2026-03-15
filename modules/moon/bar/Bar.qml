pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Scope {
    id: barScope

    Variants {
        model: {
            const screens = Quickshell.screens
            const list = Config.options.bar.screenList
            if (!list || list.length === 0) return screens
            return screens.filter(s => list.includes(s.name))
        }

        PanelWindow {
            id: barRoot
            required property ShellScreen modelData
            screen: barRoot.modelData

            // Full-width strip anchored to top
            anchors {
                top:   true
                left:  true
                right: true
            }

            // Height = gap + capsule + gap
            implicitHeight: 8 + 44 + 8

            color: "transparent"

            // Tell compositor to reserve space at top
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: implicitHeight

            WlrLayershell.namespace: "crescentshell:bar"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Component.onCompleted:   GlobalFocusGrab.addPersistent(barRoot)
            Component.onDestruction: GlobalFocusGrab.removePersistent(barRoot)

            // The floating capsule - centered, explicit size
            BarContent {
                id: barContent
                screen: barRoot.modelData

                // Explicit width so it doesn't stretch full screen
                width: implicitWidth

                // Center horizontally, 8px from top
                x: Math.round((parent.width - width) / 2)
                y: 8
            }
        }
    }

    IpcHandler {
        target: "bar"
        function toggle(): void { GlobalStates.barOpen = !GlobalStates.barOpen }
        function close():  void { GlobalStates.barOpen = false }
        function open():   void { GlobalStates.barOpen = true  }
    }

    GlobalShortcut {
        name: "barToggle"
        description: "Toggle CrescentShell bar"
        onPressed: GlobalStates.barOpen = !GlobalStates.barOpen
    }
}
