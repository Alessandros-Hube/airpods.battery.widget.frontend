import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami 2.15 as Kirigami
import org.kde.plasma.components 3.0 as PC3

Kirigami.ScrollablePage {
    readonly property alias cfg_hiddenWidgetBt: hiddenWidgetBt.checked
    readonly property alias cfg_hiddenWidgetLastUpdate: hiddenWidgetLastUpdate.checked
    readonly property alias cfg_customTimeThreshold: customTimeThreshold.value

    readonly property alias cfg_averageView: averageView.checked
    readonly property alias cfg_detailedView: detailedView.checked
    readonly property alias cfg_showCaseBattery: showCaseBattery.checked
    readonly property alias cfg_doNotShowCaseBattery: doNotShowCaseBattery.checked

    readonly property alias cfg_showAlwaysCaseBatteryFullRep: showAlwaysCaseBatteryFullRep.checked
    readonly property alias cfg_showAvailableCaseBatteryFullRep: showAvailableCaseBatteryFullRep.checked
    readonly property alias cfg_doNotShowCaseBatteryFullRep: doNotShowCaseBatteryFullRep.checked

    Kirigami.FormLayout {
        // Section for general widget behavior settings
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Generale Wight Behavior")
        }

        // Checkbox to hide the widget when Bluetooth is off
        PC3.CheckBox {
            id: hiddenWidgetBt
            Kirigami.FormData.label: i18n("Hide widget when Bluetooth is off:")
        }

        // Checkbox to hide the widget if the last update is too old
        PC3.CheckBox {
            id: hiddenWidgetLastUpdate
            Kirigami.FormData.label: i18n("Hide widget if last update is older than:")
        }

        // Row layout for the custom time threshold slider
        RowLayout {
            Kirigami.FormData.label: i18n("Custom time threshold:")
            enabled: hiddenWidgetLastUpdate.checked
            PC3.Slider {
                id: customTimeThreshold
                from: 1
                to: 24
                stepSize: 1
            }
            PC3.Label {
                text: customTimeThreshold.value + " hours"
            }
        }

        // Section for control panel view settings
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Control Panel View")
        }

        // Column layout for AirPods panel display options
        ColumnLayout {
            Kirigami.FormData.label: i18n("AirPods panel display option:")

            // Radio button for showing the average battery level of both AirPods
            RadioButton {
                id: averageView
                text: i18n("Show average battery level of both AirPods")
                checked: !detailedView.checked
            }

            // Radio button for showing individual battery levels
            RadioButton {
                id: detailedView
                text: i18n("Show individual battery levels")
            }
        }

        // Column layout for AirPods case panel display options
        ColumnLayout{
            Kirigami.FormData.label: i18n("AirPods case panel display option:")

            // Radio button to show the last available battery level of the case
            RadioButton {
                id: showCaseBattery
                text: i18n("Show last available battery level of the case")
                checked: !doNotShowCaseBattery.checked
            }

            // Radio button to hide the case battery level
            RadioButton {
                id: doNotShowCaseBattery
                text: i18n("Don't show case battery level")
            }
        }

        // Section for full widget view settings
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Full Widget View")
        }

        // Column layout for AirPods case full widget display options
        ColumnLayout {
            Kirigami.FormData.label: i18n("AirPods case full widget option:")
      
            // Radio button to always show the case battery level
            RadioButton {
                id: showAlwaysCaseBatteryFullRep
                text: i18n("Always show case battery level")
                checked: !doNotShowCaseBatteryFullRep.checked && !showAvailableCaseBatteryFullRep.checked
            }
        
            // Radio button to show the last available battery level of the case
            RadioButton {
                id: showAvailableCaseBatteryFullRep
                text: i18n("Show last available battery level of the case")
                checked: !doNotShowCaseBatteryFullRep.checked && !showAlwaysCaseBatteryFullRep.checked
            }
        
            // Radio button to hide the case battery level
            RadioButton {
                id: doNotShowCaseBatteryFullRep
                text: i18n("Don't show case battery level")
                checked: !showAlwaysCaseBatteryFullRep.checked && !showAvailableCaseBatteryFullRep.checked
            }
        }
    }
}
