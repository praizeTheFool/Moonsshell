//@ pragma ShellId crescentshell
//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import "modules/common"
import "services"
import "panelFamilies"

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    id: root

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Hyprsunset.load()
        FirstRunExperience.load()
        ConflictKiller.load()
        Cliphist.refresh()
        Wallpapers.load()
        Updates.load()
    }

    ReloadPopup {}

    MoonsshellFamily {}

    IpcHandler {
        target: "bar"
        function toggle(): void { GlobalStates.barOpen = !GlobalStates.barOpen }
        function close():  void { GlobalStates.barOpen = false }
        function open():   void { GlobalStates.barOpen = true  }
    }

    IpcHandler {
        target: "dashboard"
        function toggle(): void { GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen }
        function open():   void { GlobalStates.dashboardOpen = true  }
        function close():  void { GlobalStates.dashboardOpen = false }
    }






    GlobalShortcut {
        name: "barToggle"
        description: "Toggle the Moonsshell floating bar"
        onPressed: GlobalStates.barOpen = !GlobalStates.barOpen
    }

    GlobalShortcut {
        name: "dashboardToggle"
        description: "Toggle dashboard"
        onPressed: GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen
    }

    GlobalShortcut {
        name: "sidebarRightToggle"
        description: "Toggle right sidebar"
        onPressed: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
    }

    GlobalShortcut {
        name: "overviewToggle"
        description: "Toggle workspace overview"
        onPressed: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
    }

    GlobalShortcut {
        name: "sessionToggle"
        description: "Toggle session / power menu"
        onPressed: GlobalStates.sessionOpen = !GlobalStates.sessionOpen
    }
}
