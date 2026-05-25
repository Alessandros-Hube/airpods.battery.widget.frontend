import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami 2.15 as Kirigami
import org.kde.plasma.components 3.0 as PC3
import Qt.labs.settings 1.0 

Kirigami.ScrollablePage {

    readonly property alias cfg_autoWidgetIcons: autoWidgetIcons.checked
    readonly property alias cfg_comboBoxDefaultIconSelect: comboBoxDefaultIconSelect.currentText
    readonly property alias cfg_comboBoxSettingsDefaultIconSelect: comboBoxSettingsDefaultIconSelect.lastSelectedIndex

    readonly property alias cfg_iconSelect: iconSelect.currentText
    readonly property alias cfg_iconSelectIndex: comboBoxSettings.lastSelectedIndex

    readonly property alias cfg_iconSizeAverage: iconSizeAverage.value
    readonly property alias cfg_iconSizeLeftRight: iconSizeLeftRight.value
    readonly property alias cfg_iconSizeCase: iconSizeCase.value

    readonly property alias cfg_iconWidthLeftRightFullRep: iconWidthLeftRightFullRep.value
    readonly property alias cfg_iconHeightLeftRightFullRep: iconHeightLeftRightFullRep.value

    readonly property alias cfg_iconWidthCaseFullRep: iconWidthCaseFullRep.value
    readonly property alias cfg_iconHeightCaseFullRep: iconHeightCaseFullRep.value

    Kirigami.FormLayout {
        id: root
        anchors.fill: parent

        // Section: Widget Icons
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Widget Icons")
        }

        // Checkbox for enabling/disabling automatic widget icon selection
        PC3.CheckBox {
            id: autoWidgetIcons
            Kirigami.FormData.label: i18n("Automatically select widget icons:")
        }

        // Row for selecting default icons automatically (when autoWidgetIcons is enabled)
        RowLayout {
            visible: autoWidgetIcons.checked
            Kirigami.FormData.label: i18n("Default icons for unknown models:");
            ComboBox {
                id: comboBoxDefaultIconSelect
                currentIndex: comboBoxSettingsDefaultIconSelect.lastSelectedIndex 
                model: ["CustomIcons", "AirPodsGen1&2Icons", "AirpodsGen3Icons", "AirpodsGen4Icons", "AirPodsPro1&2Icons"]
                onCurrentIndexChanged: {
                    comboBoxSettingsDefaultIconSelect.lastSelectedIndex = currentIndex;
                }
            }
            Settings {
                id: comboBoxSettingsDefaultIconSelect
                property int lastSelectedIndex: 0
            }
        }

        // Row for manually selecting icons (when autoWidgetIcons is disabled)
        RowLayout {
            visible: !autoWidgetIcons.checked
            Kirigami.FormData.label: i18n("Manually select widget icons:");
            ComboBox {
                id: iconSelect
                currentIndex: comboBoxSettings.lastSelectedIndex 
                model: ["CustomIcons", "AirPodsGen1&2Icons", "AirpodsGen3Icons", "AirpodsGen4Icons", "AirPodsPro1&2Icons"]
                onCurrentIndexChanged: {
                    comboBoxSettings.lastSelectedIndex = currentIndex;
                }
            }
            Settings {
                id: comboBoxSettings
                property int lastSelectedIndex: 0
            }
        }
            
        // Inline message for custom icon instructions, visible only if "CustomIcons" is selected
        Kirigami.InlineMessage {
            visible: autoWidgetIcons.checked ?  comboBoxDefaultIconSelect.currentIndex == 0 : iconSelect.currentIndex == 0
            anchors.left: root.left
            anchors.right: root.right
            text: i18n("Add your own custom icons in the CustomIcons folder.<br>"
                    +  "<b>Please name the icons as follows:</b>"
                    +  "<ul>"
                    +  "<li>The average AirPods icon name: airpods.png <small>(Recommended size: 40x26)</small></li>"
                    +  "<li>The left AirPod icon name: airpod-left.png <small>(Recommended size: 30x40)</small></li>"
                    +  "<li>The right AirPod icon name: airpod-right.png <small>(Recommended size: 30x40)</small></li>"
                    +  "<li>The charging case icon name: airpod-case.png <small>(Recommended size: 40x40)</small></li>"
                    +  "</ul>"
                    +  "<b>Path to the folder if the button does not work:</b><br>"
                    +  "~/.local/share/plasma/plasmoids/org.kde.airpods.battery/contents/images/CustomIcons")
            font.pixelSize: 13
            actions: [
                Kirigami.Action {
                    text: qsTr("CustomIcons")
                    icon.name: "document-open-folder"
                    onTriggered: {
                        var folderPath = Qt.resolvedUrl("../../images/CustomIcons")
                        Qt.openUrlExternally(folderPath)
                    }
                }
            ]
        }

        // Section: Control Panel View
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Control Panel View")
        }

        // Row for configuring average icon size
        RowLayout {
            Kirigami.FormData.label: i18n("AirPods average icon size:")
            PC3.SpinBox{
                id:iconSizeAverage
                from: 0
                to: 40
                stepSize: 5
            }
        }

        // Row for configuring left and right icon size
        RowLayout {
            Kirigami.FormData.label: i18n("AirPods left & right icon size:")            
            PC3.SpinBox{
                id:iconSizeLeftRight
                from: 0
                to: 40
                stepSize: 5
            }
        }

        // Row for configuring case icon size
        RowLayout {
            Kirigami.FormData.label: i18n("AirPods case icon size:")
            PC3.SpinBox{
                id:iconSizeCase
                from: 0
                to: 40
                stepSize: 5
            }
        }

        // Section: Full Widget View
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Full Widget View")
        }

        // Row for configuring left & right icon dimensions
        RowLayout {
            Kirigami.FormData.label: i18n("AirPods left & right icon size:")
            RowLayout {
                PC3.SpinBox {
                    id: iconWidthLeftRightFullRep

                    from: 0
                    to: 100
                    stepSize: 5
                }

                PC3.Label{
                    text: "Width"
                }
            }

            RowLayout {
                PC3.SpinBox {
                    id: iconHeightLeftRightFullRep

                    from: 0
                    to: 100
                    stepSize: 5
                }

                PC3.Label{
                    text: "Height"
                }
            }
        }

        // Row for configuring case icon dimensions
        RowLayout {
            Kirigami.FormData.label: i18n("AirPods case icon size:")
            RowLayout {
                PC3.SpinBox {
                    id: iconWidthCaseFullRep

                    from: 0
                    to: 100
                    stepSize: 5
                }

                PC3.Label{
                    text: "Width"
                }
            }

            RowLayout {
                PC3.SpinBox {
                    id: iconHeightCaseFullRep

                    from: 0
                    to: 100
                    stepSize: 5
                }

                PC3.Label{
                    text: "Height"
                }
            }
        }
    }
}