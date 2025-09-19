import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls 2.15
import org.kde.kirigami 2.15 as Kirigami
import org.kde.plasma.components as PC3

import org.kde.plasma.plasmoid 2.0

import "../../tools/Tools.js"       as Tools

Kirigami.ScrollablePage {
    readonly property var cfg: plasmoid.configuration

    readonly property alias cfg_widgetScript: widgetScript.checked
    readonly property alias cfg_otherScript: otherScript.checked
    readonly property alias cfg_outPutFile: outPutFile.text

    readonly property alias cfg_optimizerOptions: optimizerOptions.checked
    readonly property alias cfg_refRawValue: refRawValue.text

    Kirigami.FormLayout {
        id: root
        anchors.fill: parent

        // Separator to organize sections within the form
        Kirigami.Separator {
            anchors.left: root.left
            anchors.right: root.right
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Widget Setup Instructions")
        }

        // Error message for environment configuration
        Kirigami.InlineMessage {
            visible: !Tools.isEnvSet()
            anchors.left: root.left
            anchors.right: root.right
            text: i18n( "You need to configure the environment to enable QML to read files:"
                    +   "<ol>"
                    +   "<li>Navigate to the folder: <b>~/.config/plasma-workspace/env/</b></li>"
                    +   "<li>If the file <b>set-env.sh</b> does not exist, create it.</li>"
                    +   "<li>Add the following line to the file: <b>'export QML_XHR_ALLOW_FILE_READ=1'</b> .</li>"
                    +   "<li>Log out and log back into your current session, or reboot your system.</li>"
                    +   "</ol>")
            type: Kirigami.MessageType.Error
            font.pixelSize: 13
            actions: [
                Kirigami.Action {
                    text: qsTr("Open folder")
                    icon.name: "document-open-folder"
                    onTriggered: {
                        var folderPath = Qt.resolvedUrl("../../../../../../../../.config/plasma-workspace/env/")
                        Qt.openUrlExternally(folderPath)
                    }
                }
            ]
        }

        // Positive message when environment is configured correctly
        Kirigami.InlineMessage {
            visible: Tools.isEnvSet()
            anchors.left: root.left
            anchors.right: root.right
            text: "Environment is correctly configured."
            type: Kirigami.MessageType.Positive
            icon.source: "dialog-positive"
        }

        // Warning if no backend option is selected
        Kirigami.InlineMessage {
            visible: Tools.isEnvSet() && !Tools.isAutoStartSet() && !widgetScript.checked && !otherScript.checked
            anchors.left: root.left
            anchors.right: root.right
            text: "Please choice your backend option!"
            type: Kirigami.MessageType.Warning
        }

        // Options for selecting backend scripts
        ColumnLayout{
            visible: Tools.isEnvSet()
            Kirigami.FormData.label: i18n("Choice your backend option:")

            // Option to use the widget's backend script
            RadioButton {
                id: widgetScript
                text: i18n("Use the backend script of the widget <br> source folder, which is based on the <br> AirStatus script from GitHub.")
                checked: !otherScript.checked
            }

            // Option to use an alternative backend script
            RadioButton {
                id: otherScript
                text: i18n("Use a alternative backend script for <br> example the original AirStatus from <br> GitHub or your own script.")
            }
        }

        // Warning message for backend script autostart setup
        Kirigami.InlineMessage {
            id: widgetScriptMessage
            visible: Tools.isEnvSet() && !Tools.isAutoStartSet() && widgetScript.checked
            anchors.left: root.left
            anchors.right: root.right
            text: i18n( "Add the backend script to your system's autostart"
                    +   "<ol>"
                    +   "<li>Open <b>System Settings → Autostart</b>.</li>"
                    +   "<li>Click <b>&quot;Add New&quot;</b> and select <b>&quot;Login Script&quot;</b></li>"
                    +   "<li>In the login script select, navigate to the widget source folder:<br>"
                    +   "<b>~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend</b></li>"
                    +   "<li>Select <b>run.sh</b> by double clicking </li>"
                    +   "<li>Log out and log back into your current session, or reboot your system.</li>"
                    +   "</ol>"
                    +   "<b>Note: If you don't trust the script, review it before proceeding.</b>")
            font.pixelSize: 13
            type: Kirigami.MessageType.Warning
            actions: [
                // Button to review the backend script
                Kirigami.Action {
                    text: qsTr("Review script")
                    icon.name: "document-edit"
                    onTriggered: {
                        var scriptPath = Qt.resolvedUrl("../../../run.sh")
                        Qt.openUrlExternally(scriptPath)
                    }
                },
                // Button to open folder widget folder
                Kirigami.Action {
                    text: qsTr("Open source folder")
                    icon.name: "document-open-folder"
                    onTriggered: {
                        var scriptPath = Qt.resolvedUrl("../../../")
                        Qt.openUrlExternally(scriptPath)
                    }
                }
            ]
        }

        // Warning for missing output file path when using alternative script
        Kirigami.InlineMessage {
            id: otherScriptMessage
            visible: Tools.isEnvSet() && !widgetScriptMessage.visible && otherScript.checked && !Tools.fileExists(outPutFile.text)
            anchors.left: root.left
            anchors.right: root.right
            text: "Please enter the path to alternative backend output file!"
            type: Kirigami.MessageType.Warning
        }

        // Positive message when backend is configured correctly
        Kirigami.InlineMessage {
            id: finishBackendSetupMessage
            visible: Tools.isEnvSet() && !widgetScriptMessage.visible && !otherScriptMessage.visible && (widgetScript.checked || otherScript.checked) && (Tools.isAutoStartSet() || Tools.fileExists(outPutFile.text))
            anchors.left: root.left
            anchors.right: root.right
            text: "The backend script is correctly configured."
            type: Kirigami.MessageType.Positive
            icon.source: "dialog-positive"
        }

        // Information to wait for the initial output
        Kirigami.InlineMessage {
            id: wait
            visible: false
            anchors.left: root.left
            anchors.right: root.right
            text: i18n("Please wait a moment while the backend script detects a device and generates the first output!")
            font.pixelSize: 12
        }

        // Information about unknown model
        Kirigami.InlineMessage {
            visible: finishBackendSetupMessage.visible && Tools.getAirPodsModel() == "unknown" && cfg.titleCheck && !cfg.titleCheckText
            anchors.left: root.left
            anchors.right: root.right
            text: i18n( "<b>Why is the title unknown?</b><br>"
                   +    "The AirStatus backend script can distinguish between &quot;AirPods1&quot;, &quot;AirPods2&quot;, &quot;AirPods3&quot;, and &quot;AirPodsPro&quot;. "
                   +    "If your AirPods are AirPodsPro2, AirPods4, or a newer model, the script might not recognize the specific model. However, the battery values are displayed correctly.<br>"
                   +    "You can manually change the title using the custom option in the Appearance category. "
                   +    "Additionally, you can modify the default icon for unknown devices in the Icons category.")
            font.pixelSize: 10
        }

        // Information about the format for your own backend script 
        Kirigami.InlineMessage {
            visible: !finishBackendSetupMessage.visible && Tools.isEnvSet() && otherScript.checked
            anchors.left: root.left
            anchors.right: root.right
            text: i18n( "If you want to write your own backend script, the output must have the following format:<br>"
                    +   "{&quot;charge&quot;: {&quot;left&quot;: 15, &quot;right&quot;: 15, &quot;case&quot;: 95}, &quot;charging_left&quot;: true, &quot;"
                    +   "charging_right&quot;: true, &quot;charging_case&quot;: false, &quot;model&quot;: &quot;unknown&quot;,"
                    +   " &quot;date&quot;: &quot;2020-01-01 12:00:00&quot;, &quot;raw&quot;: &quot;012345678abcdef......&quot;}<br>"
                    +   "<small>model:=&quot;AirPods1&quot;, &quot;AirPods2&quot;, &quot;AirPods3&quot;, &quot;AirPods4&quot;, &quot;AirPodsPro&quot;, &quot;AirPodsPro2&quot;, &quot;unknown&quot;</small>")
            font.pixelSize: 10
        }

        // TextField for specifying the path to an alternative backend output file
        TextField {
            id: outPutFile
            visible: Tools.isEnvSet() && otherScript.checked
            Kirigami.FormData.label: i18n("Path to alternative backend output file:")
            placeholderText: i18n("Enter the file path")            
        }  

        // Error message if the entered output file path doesn't exist
        Kirigami.InlineMessage {
            visible: Tools.isEnvSet() && !widgetScriptMessage.visible && otherScript.checked && outPutFile.text != "" && !Tools.fileExists(outPutFile.text)
            anchors.left: root.left
            anchors.right: root.right
            text: "The path to the output file is does not exist!!!"
            type: Kirigami.MessageType.Error
        }

        // Checkbox for enabling backend optimization
        PC3.CheckBox {
            visible: Tools.isEnvSet()
            id: optimizerOptions
            Kirigami.FormData.label: i18n("Enable backend optimizer:")
        }

        // Information about backend optimization
        Kirigami.InlineMessage {
            visible: Tools.isEnvSet() && optimizerOptions.checked
            anchors.left: root.left
            anchors.right: root.right
            text: i18n("If the backend script receives a different battery level, you can enter the first 8 digits of the raw value. "
                    +  "This widget will display only the battery level that matches the raw value.")
            font.pixelSize: 12
        }

        // TextField for entering a raw value for backend optimization
        TextField {
            id: refRawValue
            visible: Tools.isEnvSet() && optimizerOptions.checked   
            Kirigami.FormData.label: i18n("Enter the first 8 digits of the raw value:")
            placeholderText: i18n("Enter the raw value")
        }
    }

    // Timer to monitor the output generation by the backend script
    Timer {
        id: timer
        interval: 600
        running: true
        repeat: true
        onTriggered: {
            wait.visible = (!Tools.fileExists("../../airstatus.out") && widgetScript.checked && !widgetScriptMessage.visible);
            if (!wait.visible) {
                timer.running = timer.repeat = false;
            }
        }
    }
}
