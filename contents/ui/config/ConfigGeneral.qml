import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts


import Qt.labs.folderlistmodel 2.15

import org.kde.bluezqt 1.0 as BluezQt
import org.kde.kirigami 2.15 as Kirigami
import org.kde.plasma.components as PC3
import org.kde.plasma.plasmoid 2.0

import "../../tools/Tools.js"       as Tools

Kirigami.ScrollablePage {
    property QtObject btManager: BluezQt.Manager
    readonly property var cfg: plasmoid.configuration

    readonly property alias cfg_widgetScript: widgetScript.checked
    readonly property alias cfg_otherScript: otherScript.checked
    readonly property alias cfg_outPutFile: outPutFile.text

    readonly property alias cfg_optimizerOptions: optimizerOptions.checked
    readonly property alias cfg_refRawValue: refRawValue.text

    property string user: "../../../../../../../../.config/systemd/user/"
    
    property bool isDeviceDetects: false;
    property bool isCheckBoxCheck: plasmoid.configuration.isCheckBoxCheck; 
    property string refRaw: plasmoid.configuration.refRaw;
    property int status: plasmoid.configuration.status;
    property var jsonData: JSON.parse(plasmoid.configuration.jsonData);

    id: root
    verticalScrollBarInteractive: !newSetup.visible

    // Function to check if folder exist
    function folderExists(path, parentFolder) {
        var instance = folderListModel.createObject(parent, {
            folder: Qt.resolvedUrl(path)
        });
            
        var exist = String(instance.parentFolder).includes(parentFolder);

        instance.destroy();

        return exist;
    }

    // Function to create dict
    function createDict(data, checkBox) {
        var airPodsModelName = data.model.value;
        var chargeInfo  =   "L: " + data.left.value + "%" + (data.charging_left.value == "True" ? " recharge, " : ", ") 
                        +   "R: " + data.right.value + "% " + (data.charging_right.value == "True" ? " recharge, " : ", ")
                        +   "Case: " + data.case.value +"%" + (data.charging_case.value == "True" ? " recharge" : "");
        var date        =   "Date: " + data.date.value;
        var raw         =   data.raw.value.substring(0, 8);

        return {
            airPodsModelName: airPodsModelName,
            chargeInfo:       chargeInfo,
            date:             date,
            raw:              raw,
            jsonData:         jsonData,
            checkBoxCheck:    checkBox
        }
    }

    // Function to update airpodsModel
    function updateAirPodsModel() {
        jsonData = JSON.parse(plasmoid.configuration.jsonData);
        if (!isDeviceDetects && jsonData.status.value == "1") {
            var raw   = jsonData.raw.value.substring(0, 8);
            var found = false;
            for (var i = 0; i < airPodsModel.count; i++) {
                if (airPodsModel.get(i).raw === raw) {
                    found = true;
                    airPodsModel.set(i, createDict(jsonData, isCheckBoxCheck && refRaw == raw));
                    if (isCheckBoxCheck && refRaw == raw) {
                        plasmoid.configuration.refData = JSON.stringify(jsonData);
                    }
                    airPodsModel.move(i, isCheckBoxCheck ? refRaw == raw ? 0 : 1 : 0, 1);
                    cardsView.currentIndex = 0;
                    break;
                }
            }

            if (!found) {
                airPodsModel.insert(isCheckBoxCheck ? refRaw == raw ? 0 : 1 : 0, createDict(jsonData, false));
                cardsView.currentIndex = 0;
            }
        }
    }

    // Function to uncheck all airpods from list view
    function unCheckAllAirPodsFromListView() {
        for (var i = 0; i < airPodsModel.count; i++) {
            airPodsModel.setProperty(i, "checkBoxCheck", false);
        }
    }

    // Function to get the current index
    function getCurrentIndex(raw) {
        for (var i = 0; i < airPodsModel.count; i++) {
            if (airPodsModel.get(i).raw === raw) {
                return i;
            }
        }
    }

    // Function to update the icons
    function updateIcons(model) {
        var iconBasePath = "../../images/" + cfg.comboBoxDefaultIconSelect;

        switch (model) {
            case "AirPods1":
            case "AirPods2":
                iconBasePath = "../../images/AirPodsGen1&2Icons";
                break;
            case "AirPods3":
                iconBasePath = "../../images/AirpodsGen3Icons";
                break;
            case "AirPods4":
                iconBasePath = "../../images/AirpodsGen4Icons";
                break;
            case "AirPodsPro":
            case "AirPodsPro2":
                iconBasePath = "../../images/AirPodsPro1&2Icons";
                break;
            case "unknown":
                iconBasePath = "../../images/" + cfg.comboBoxDefaultIconSelect;
                break;
            default:
                iconBasePath = "../../images/" + cfg.comboBoxDefaultIconSelect;
                break;
        }
        return iconBasePath + "/airpods.png";
    }

    Kirigami.FormLayout {
        id: infoPage
        anchors.fill: parent

        // Info message for new backend short
        Kirigami.InlineMessage {
            id: infoMessage
            visible: !preparationMessage.visible
            anchors.left: infoPage.left
            anchors.right: infoPage.right
            text: i18n( "<b>New backend available!</b><br/><br/>"
                    +   "The new backend uses a Python GLib service with a DBus connection, "
                    +   "managed by systemd, replacing the previous <i>while-true</i> loop in Autostart.<br/><br/>"
                    +   "The legacy backend also requires the environment variable "
                    +   "<b>QML_XHR_ALLOW_FILE_READ=1</b> to allow QML to read files. "
                    +   "This variable increases RAM usage and poses a security risk.<br/><br/>"
                    +   "You can continue using the old backend as usual, however this is not recommended "
                    +   "and the option will be removed in a future update.<br/><br/>"
                    +   "Selecting <b>Initialize new backend</b> will start the setup process for the new backend. "
                    +   "If you are not satisfied or encounter issues, you can revert by following the "
                    +   "instructions in <b>oldSetup.md</b> (see repository).")
            actions: [
                // Button to continue with the old backend
                Kirigami.Action {
                    text: qsTr("Continue with old backend")
                    onTriggered: {
                        oldSetup.visible = true;
                        plasmoid.configuration.oldSetup = true;
                        infoPage.visible = false;
                        plasmoid.configuration.infoPage = false;
                        timer.running = timer.repeat = true;
                    }
                },
                // Button to initialize the new backend
                Kirigami.Action {
                    text: qsTr("Initialize new backend")
                    onTriggered: {
                        preparationMessage.visible = true;
                    }
                }
            ]
        }

        // Warning message for remove the old backend
        Kirigami.InlineMessage {
            id: preparationMessage
            visible: !infoMessage.visible
            anchors.left: infoPage.left
            anchors.right: infoPage.right
            text: i18n( "Remove the old backend configuration from your system"
                    +   "<ol>"
                    +   "<li>Open <b>System Settings → Autostart</b>.</li>"
                    +   "<li>Remove the entry <b>&quot;run.sh&quot;</b> from <b>&quot;Login Script&quot;</b> section.</li>"
                    +   "<li>Remove the entry <b>&quot;set-env.sh&quot;</b> from <b>&quot;Script before login&quot;</b> section.</li>"
                    +   "<li><b>Log out and log back into your current session</b>, or reboot your system.</li>"
                    +   "</ol>")
            type: Kirigami.MessageType.Warning
            actions: [
                Kirigami.Action {
                    text: qsTr("Cancel")
                    icon.name: "list-remove"
                    onTriggered: {
                        preparationMessage.visible = false;
                    }
                }
            ]
        }
    }

    Kirigami.FormLayout {
        id: newSetup
        visible: false
        anchors.fill: parent

        // Info message to enable backend service
        Kirigami.InlineMessage {
            visible: !finishBackendSetup.visible && !errorMessage.visible
            anchors.left: newSetup.left
            anchors.right: newSetup.right
            text: i18n( "To enable the backend service, follow these steps:"
                    +   "<ol>"
                    +   "<li>Install the required system dependencies by opening a terminal and running the command for your distribution:"
                    +   "<p><p><b>Fedora:</b><br>"
                    +   "<b><code>sudo dnf install -y gcc glib2-devel dbus-devel python3-devel pkg-config cmake make \
                            cairo-devel gobject-introspection-devel gtk3-devel pango-devel python3-virtualenv</code></b></p>"
                    +   "<p><b>Debian/Ubuntu:</b><br>"
                    +   "<b><code>sudo apt install -y gcc libglib2.0-dev libdbus-1-dev python3-dev pkg-config cmake make \
                            libcairo2-dev libgirepository1.0-dev libgtk-3-dev libpango1.0-dev python3-venv</code></b></p>"
                    +   "<p><b>Arch:</b><br>"
                    +   "<b><code>sudo pacman -S --needed gcc glib2 dbus python pkg-config cmake make \
                            cairo gobject-introspection gtk3 pango python-virtualenv</code></b></p></p></li>"
                    +   (!folderExists(user, "/.config") ?
                        ("<li>Open the <b>~/.config</b> folder.</li>"
                    +   "<li>Create a new folder named <b>systemd</b> inside <b>~/.config</b>.</li>"
                    +   "<li>Create a new folder named <b>user</b> inside <b>~/.config/systemd</b>.</li>") :
                        ("<li>Open the <b>user</b> folder:<br>"
                    +   "<b>~/.config/systemd/user</b></li>"))
                    +   "<li>Open the widget <b>source</b> folder:<br>"
                    +   "<b>~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend</b></li>"
                    +   "<li>Copy the <b>airPodsBatteryWidget.service</b> file from the widget <b>source</b> folder into the <b>user</b> folder.</li>"
                    +   "<li>Open a terminal and run the following commands:<br>"
                    +   "<b><code>systemctl --user daemon-reload</code></b><br>"
                    +   "<b><code>systemctl --user enable --now airPodsBatteryWidget.service</code></b></li>"
                    +   "</ol>")
            type: Kirigami.MessageType.Warning
            actions: [
                // Button to open source folder
                Kirigami.Action {
                    text: qsTr("Open source folder")
                    icon.name: "document-open-folder"
                    onTriggered: {
                        var scriptPath = Qt.resolvedUrl("../../../")
                        Qt.openUrlExternally(scriptPath)
                    }
                },
                // Button to ~/.config folder
                Kirigami.Action {
                    visible: !folderExists(user, "/.config")
                    text: qsTr("Open ~/.config")
                    icon.name: "document-open-folder"
                    onTriggered: {
                        var scriptPath = Qt.resolvedUrl("../../../../../../../../.config/")
                        Qt.openUrlExternally(scriptPath)
                    }
                },
                // Button to open user folder
                Kirigami.Action {
                    visible: folderExists(user, "/.config")
                    text: qsTr("Open user folder")
                    icon.name: "document-open-folder"
                    onTriggered: {
                        var folderPath = Qt.resolvedUrl(user)
                        Qt.openUrlExternally(folderPath)
                    }
                }
            ]
        }

        // Positive message when backend has an error
        Kirigami.InlineMessage {
            id: errorMessage
            anchors.left: newSetup.left
            anchors.right: newSetup.right
            text: i18n( "Backend unavailable. To restart it, open a terminal and run:<br><br>"
                    +   "<b><code>systemctl --user restart airPodsBatteryWidget.service</code></b><br>")
            type: Kirigami.MessageType.Error
            icon.source: "dialog-error"
        }

        // Positive message when backend is configured correctly
        Kirigami.InlineMessage {
            id: finishBackendSetup
            anchors.left: newSetup.left
            anchors.right: newSetup.right
            text: "The backend is correctly configured."
            type: Kirigami.MessageType.Positive
            icon.source: "dialog-positive"
        }

        ColumnLayout {
            visible: finishBackendSetup.visible
            anchors.left: newSetup.left
            anchors.right: newSetup.right
            RowLayout {
                Kirigami.Heading {
                    text: i18n("<b>Select a device</b>")
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("If you have multiple AirPods or if there are other AirPods nearby, choose which devices you want this widget to display. It is recommended that you select one device.")
                }
            }

            // Information to wait for the initial detects a device
            Kirigami.InlineMessage {
                visible: isDeviceDetects;
                Layout.fillWidth: true
                text: i18n("Please wait a moment while the backend detects a device!")
                actions: [
                    Kirigami.Action {
                        Kirigami.Theme.inherit: true
                        icon.name: "help-contextual"
                        tooltip: i18n("The backend needs 1–2 minutes to retrieve data. Make sure the AirPods are either out of the case or inside with the lid open.")
                    }
                ]
            }

            // Information to Bluetooth is turned off
            Kirigami.InlineMessage {
                id: bluetoothMessage
                Layout.fillWidth: true
                text: i18n("Bluetooth is turned off.")
                type: Kirigami.MessageType.Warning
                actions:[
                    Kirigami.Action {
                        icon.name: "games-endturn-symbolic"
                        text: i18n("Activate")
                        onTriggered: {
                            BluezQt.Manager.bluetoothBlocked = false;

                            BluezQt.Manager.adapters.forEach(adapter => {
                                adapter.powered = true;
                            });
                        }
                    }
                ]
            }

            FocusScope {
                Layout.fillWidth: true
                height: 345

                Rectangle {
                    anchors.fill: parent
                    color: "#18191D"
                    radius: 4
                    clip: true

                    border.color: airPodsModel.count > 0 
                        ? Kirigami.Theme.highlightColor 
                        : "transparent"
                    border.width: airPodsModel.count > 0 ? 1 : 0


                    BusyIndicator {
                        visible: airPodsModel.count == 0 && btManager.bluetoothOperational
                        anchors.centerIn: parent
                        running: airPodsModel.count == 0
                        width: Kirigami.Units.iconSizes.huge
                        height: width
                    }

                    Kirigami.CardsListView {
                        id: cardsView
                        visible: airPodsModel.count > 0
                        anchors.fill: parent
                        anchors.margins: 4
                        model: airPodsModel
                        delegate: airPodsDelegate
                        clip: true
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                    }
                }
            }

            RowLayout {
                visible: airPodsModel.count > 0 && btManager.bluetoothOperational
                BusyIndicator {
                    running: airPodsModel.count > 0
                }
                Label {
                    text: "Scanning in progress ..."
                    Layout.alignment: Qt.AlignRight
                }
            }
        }

        // ListModel needed for ListView, contains elements to be displayed
        ListModel {
            id: airPodsModel

            property string airPodsModelName: ""
            property string chargeInfo: ""
            property string date: ""
            property string raw: ""
            property var jsonData: "{'status': 0}"
            property bool checkBoxCheck: false
        }

        // Delegate Component used by a ListView to define how each item in the list is displayed
        Component {
            id: airPodsDelegate

            Kirigami.SubtitleDelegate {
                id: delegate
                anchors {
                    left: parent.left
                    right: parent.right
                }

                highlighted: ListView.isCurrentItem

                contentItem: Item {
                    implicitWidth: delegateLayout.implicitWidth
                    implicitHeight: delegateLayout.implicitHeight

                    GridLayout {
                        id: delegateLayout
                        anchors {
                            left: parent.left
                            top: parent.top
                            right: parent.right
                        }
                        rowSpacing: Kirigami.Units.largeSpacing
                        columnSpacing: Kirigami.Units.largeSpacing
                        columns: width > Kirigami.Units.gridUnit * 20 ? 4 : 2

                        Kirigami.Icon {
                            source: Qt.resolvedUrl(updateIcons(airPodsModelName))
                            Layout.fillHeight: true
                            Layout.maximumHeight: Kirigami.Units.iconSizes.huge
                            Layout.preferredWidth: height
                        }

                        ColumnLayout {
                            RowLayout {
                                Kirigami.Heading {
                                    level: 2
                                    text: airPodsModelName
                                }
                                Kirigami.ContextualHelpButton {
                                    visible: airPodsModelName == "unknown"
                                    toolTipText: i18n( "<b>Why is the title unknown?</b><br>"
                                                   +    "The backend service can distinguish between &quot;AirPods1&quot;, &quot;AirPods2&quot;, &quot;AirPods3&quot;, &quot;AirPodsPro&quot; and &quot;AirPodsPro2&quot;. "
                                                   +    "If your AirPods are AirPodsPro3, AirPods4, or a newer model, the script might not recognize the specific model.")
                                }
                            }
                            Kirigami.Separator {
                                Layout.fillWidth: true
                            }
                            Kirigami.SelectableLabel {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: chargeInfo + "<br>" + date
                            }
                        }

                        CheckBox {
                            checked: checkBoxCheck
                            onClicked: {
                                var idx = getCurrentIndex(raw);
                                if (checked) {
                                    unCheckAllAirPodsFromListView();
                                    airPodsModel.setProperty(idx, "checkBoxCheck", true);
                                    airPodsModel.move(idx, 0, 1);
                                    cardsView.currentIndex = 0;
                                    isCheckBoxCheck = plasmoid.configuration.isCheckBoxCheck = true;
                                    plasmoid.configuration.refData = JSON.stringify(jsonData);
                                    refRaw = plasmoid.configuration.refRaw = raw;
                                } else {
                                    airPodsModel.setProperty(idx, "checkBoxCheck", false);
                                    isCheckBoxCheck = plasmoid.configuration.isCheckBoxCheck = false;
                                }
                            }
                        }
                    }
                }
            }
        }

        // Initialize descriptions for each notification in the ListModel
        Component.onCompleted: {
            if (isCheckBoxCheck) {
                var refData = JSON.parse(plasmoid.configuration.refData);
                airPodsModel.insert(0, createDict(refData, true));
                cardsView.currentIndex = 0;
            }
            updateAirPodsModel();
        }
    }

    Kirigami.FormLayout {
        id: oldSetup
        visible: !infoPage.visible && !newSetup.visible
        anchors.fill: parent

        // Info message for new backend short
        Kirigami.InlineMessage {
            visible: true
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: i18n("<b>New backend available!</b>")
            actions: [
                Kirigami.Action {
                    text: qsTr("More Info")
                    icon.name: "list-add"
                    onTriggered: {
                        oldSetup.visible = false;
                        plasmoid.configuration.oldSetup = false;
                        infoPage.visible = true;
                        plasmoid.configuration.infoPage = true;
                        timer.running = timer.repeat = false;
                    }
                }
            ]
        }

        // Separator to organize sections within the form
        Kirigami.Separator {
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Widget Setup Instructions")
        }

        // FolderListModel for env
        FolderListModel {
            id: envModel
            folder: Qt.resolvedUrl("../../../../../../../../.config/plasma-workspace/env")
        }

        // Positive message when environment is configured correctly
        Kirigami.InlineMessage {
            id: envSet
            visible: Tools.isEnvSet()
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: "Environment is correctly configured."
            type: Kirigami.MessageType.Positive
            icon.source: "dialog-positive"
        }

        // Warning if no backend option is selected
        Kirigami.InlineMessage {
            visible: envSet.visible && !Tools.isAutoStartSet() && !widgetScript.checked && !otherScript.checked
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: "Please choice your backend option!"
            type: Kirigami.MessageType.Warning
        }

        // Options for selecting backend scripts
        ColumnLayout{
            visible: envSet.visible
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
            visible: envSet.visible && !Tools.isAutoStartSet() && widgetScript.checked
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
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
            visible: envSet.visible && !widgetScriptMessage.visible && otherScript.checked && !Tools.fileExists(outPutFile.text)
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: "Please enter the path to alternative backend output file!"
            type: Kirigami.MessageType.Warning
        }

        // Positive message when backend is configured correctly
        Kirigami.InlineMessage {
            id: finishBackendSetupMessage
            visible: envSet.visible && !widgetScriptMessage.visible && !otherScriptMessage.visible && (widgetScript.checked || otherScript.checked) && (Tools.isAutoStartSet() || Tools.fileExists(outPutFile.text))
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: "The backend script is correctly configured."
            type: Kirigami.MessageType.Positive
            icon.source: "dialog-positive"
        }

        // Information to wait for the initial output
        Kirigami.InlineMessage {
            id: wait
            visible: false
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: i18n("Please wait a moment while the backend script detects a device and generates the first output!")
            font.pixelSize: 12
        }

        // Information about unknown model
        Kirigami.InlineMessage {
            visible: {
                Tools.updateBatteryStatus(cfg.otherScript ? cfg.outPutFile : cfg.widgetScript ? "../../airstatus.out" : "", cfg.optimizerOptions ? cfg.refRawValue : "-1");
                return finishBackendSetupMessage.visible && Tools.getAirPodsModel() == "unknown" && cfg.titleCheck && !cfg.titleCheckText && !wait.visible
            }
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: i18n( "<b>Why is the title unknown?</b><br>"
                   +    "The AirStatus backend script can distinguish between &quot;AirPods1&quot;, &quot;AirPods2&quot;, &quot;AirPods3&quot;, &quot;AirPodsPro&quot; and &quot;AirPodsPro2&quot;. "
                   +    "If your AirPods are AirPodsPro3, AirPods4, or a newer model, the script might not recognize the specific model. However, the battery values are displayed correctly.<br>"
                   +    "You can manually change the title using the custom option in the Appearance category. "
                   +    "Additionally, you can modify the default icon for unknown devices in the Icons category.")
            font.pixelSize: 10
        }

        // Information about the format for your own backend script 
        Kirigami.InlineMessage {
            visible: !finishBackendSetupMessage.visible && envSet.visible && otherScript.checked
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
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
            visible: envSet.visible && otherScript.checked
            Kirigami.FormData.label: i18n("Path to alternative backend output file:")
            placeholderText: i18n("Enter the file path")            
        }  

        // Error message if the entered output file path doesn't exist
        Kirigami.InlineMessage {
            visible: envSet.visible && !widgetScriptMessage.visible && otherScript.checked && outPutFile.text != "" && !Tools.fileExists(outPutFile.text)
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: "The path to the output file is does not exist!!!"
            type: Kirigami.MessageType.Error
        }

        // Checkbox for enabling backend optimization
        PC3.CheckBox {
            visible: envSet.visible
            id: optimizerOptions
            Kirigami.FormData.label: i18n("Enable backend optimizer:")
        }

        // Information about backend optimization
        Kirigami.InlineMessage {
            visible: envSet.visible && optimizerOptions.checked
            anchors.left: oldSetup.left
            anchors.right: oldSetup.right
            text: i18n("If the backend script receives a different battery level, you can enter the first 8 digits of the raw value. "
                    +  "This widget will display only the battery level that matches the raw value.")
            font.pixelSize: 12
        }

        // TextField for entering a raw value for backend optimization
        TextField {
            id: refRawValue
            visible: envSet.visible && optimizerOptions.checked   
            Kirigami.FormData.label: i18n("Enter the first 8 digits of the raw value:")
            placeholderText: i18n("Enter the raw value")
        }
    }

    // Timer to update the widget settings
    Timer {
        id: timer2
        interval: 1000
        running: true
        repeat: true
        onTriggered: {            
            var backendSetup = folderExists(user + "graphical-session.target.wants/", "/user");
            finishBackendSetup.visible = plasmoid.configuration.finishBackendSetup = backendSetup;
            errorMessage.visible = plasmoid.configuration.isError && backendSetup;
            finishBackendSetup.visible = !errorMessage.visible && backendSetup;
            isDeviceDetects = status != 1 && plasmoid.configuration.status == 0 && btManager.bluetoothOperational;
            bluetoothMessage.visible = !btManager.bluetoothOperational;
            updateAirPodsModel();            
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

    // FolderListModel
    Component {
        id: folderListModel
        FolderListModel {}
    }

    // Initial battery status update when the widget is loaded
    Component.onCompleted: {
        if (plasmoid.configuration.finishBackendSetup) {
            infoPage.visible = false;
            newSetup.visible = true;
            errorMessage.visible = plasmoid.configuration.isError;
            finishBackendSetup.visible = !errorMessage.visible;
            timer.running = timer.repeat = false;
            root.verticalScrollBarPolicy = ScrollBar.AlwaysOff
        } else {
            timer2.running = timer2.repeat = false;
            var isEnvSet = Tools.isEnvSet();
            if (!isEnvSet) {
                infoPage.visible = plasmoid.configuration.infoPage = false;
                newSetup.visible = true;
                timer2.running = timer2.repeat = true;
                timer.running = timer.repeat = false;
                root.verticalScrollBarPolicy = ScrollBar.AlwaysOff
            } else if (isEnvSet && !plasmoid.configuration.infoPage) {
                infoPage.visible = plasmoid.configuration.infoPage = false;
                oldSetup.visible = true;
            } else if (isEnvSet){
                infoPage.visible = true;
            } else {
                infoPage.visible = plasmoid.configuration.infoPage = false;
            }
        }
    }
}
