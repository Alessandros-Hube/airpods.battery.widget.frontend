import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-desktop-plasma"
        source: "config/ConfigGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Behavior")
        icon: "preferences-desktop"
        source: "config/ConfigBehavior.qml"
    }

    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-display-color"
        source: "config/ConfigAppearance.qml"
    }

    ConfigCategory {
        name: i18n("Icons")
        icon: "preferences-desktop-icons"
        source: "config/ConfigIcons.qml"
    }

    ConfigCategory {
        name: i18n("Notification")
        icon: "preferences-desktop-notification"
        source: "config/ConfigNotification.qml"
    }
}
