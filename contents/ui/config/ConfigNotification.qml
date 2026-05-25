import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.folderlistmodel 2.1

import org.kde.kirigami as Kirigami
import org.kde.notification 1.0
import org.kde.plasma.components as PC3
import org.kde.plasma.plasmoid 2.0

import "../../tools/Tools.js"       as Tools

Kirigami.ScrollablePage {
    readonly property var cfg: plasmoid.configuration

    // Define paths for icons
    property string iconBasePath:       "../../images/" + (cfg.autoWidgetIcons ? cfg.comboBoxDefaultIconSelect : cfg.iconSelect)
    property string averageIconPath:    iconBasePath + "/airpods.png"
    property string leftIconPath:       iconBasePath + "/airpod-left.png"
    property string rightIconPath:      iconBasePath + "/airpod-right.png"
    property string caseIconPath:       iconBasePath + "/airpods-case.png"

    readonly property alias cfg_allowNotification: allowNotification.checked

    readonly property alias cfg_firstPodsNotificationSwitch: firstPodsNotificationSwitch.checked
    readonly property alias cfg_firstPodsIconSwitch: firstPodsIconSwitch.checked
    readonly property alias cfg_firstPodsUrgencySwitch: firstPodsUrgencySwitch.checked
    readonly property alias cfg_firstPodsBatteryLowSpin: firstPodsBatteryLowSpin.value

    readonly property alias cfg_secondPodsNotificationSwitch: secondPodsNotificationSwitch.checked
    readonly property alias cfg_secondPodsIconSwitch: secondPodsIconSwitch.checked
    readonly property alias cfg_secondPodsUrgencySwitch: secondPodsUrgencySwitch.checked
    readonly property alias cfg_secondPodsBatteryLowSpin: secondPodsBatteryLowSpin.value

    readonly property alias cfg_firstCaseNotificationSwitch: firstCaseNotificationSwitch.checked
    readonly property alias cfg_firstCaseIconSwitch: firstCaseIconSwitch.checked
    readonly property alias cfg_firstCaseUrgencySwitch: firstCaseUrgencySwitch.checked
    readonly property alias cfg_firstCaseBatteryLowSpin: firstCaseBatteryLowSpin.value

    readonly property alias cfg_secondCaseNotificationSwitch: secondCaseNotificationSwitch.checked
    readonly property alias cfg_secondCaseIconSwitch: secondCaseIconSwitch.checked
    readonly property alias cfg_secondCaseUrgencySwitch: secondCaseUrgencySwitch.checked
    readonly property alias cfg_secondCaseBatteryLowSpin: secondCaseBatteryLowSpin.value    


    // Function to set the description of a notification dynamically
    function setNotificationDescription(id, notificationSwitch, batteryLowSpin, urgencySwitch, iconSwitch) {
        notificationModel.setProperty(id, "description", (notificationSwitch.checked ? "On, below "
                + (batteryLowSpin.value +"%")
                + (notificationSwitch.checked && urgencySwitch.checked ? ", urgent" : "")
                + (notificationSwitch.checked && iconSwitch.checked ? ", show icon" : "")
                : "Off"))
    }

    // Function to send a battery level notification for AirPods or the case
    function sendBatteryNotification(name, batteryLowSpin, iconSwitch, iconPath, urgencySwitch) {
        return sendNotification(name + " battery level low ("+ batteryLowSpin +"%)", "", iconSwitch ? Qt.resolvedUrl(iconPath).toString().split("file://")[1] : "/", urgencySwitch ? "CriticalUrgency" : "NormalUrgency");
    }

    // Generic function to send a notification
    function sendNotification(title = "", text = "", iconName = "/", urgency = "NormalUrgency") {
        var notification = notificationComponent.createObject(parent);
        notification.title = title;
        notification.text = text;
        notification.iconName = iconName;
        notification.urgency = urgency;
        notification.sendEvent();
        return notification;
    }

    Kirigami.FormLayout {
        id: root

        // Separator to organize sections within the form
        Kirigami.Separator {
            anchors.left: root.left
            anchors.right: root.right
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Widget Notification")
        }
   
        // Card container for settings
        Kirigami.AbstractCard {
            anchors.left: root.left
            anchors.right: root.right
            contentItem: Item {
                implicitWidth: settingsLayout.implicitWidth
                implicitHeight: settingsLayout.implicitHeight

                // Layout for settings content
                GridLayout {
                    id: settingsLayout
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.right: parent.right

                    // Section heading
                    Kirigami.Heading {
                        Layout.fillWidth: true
                        level: 1
                        text: i18n("Enable notifications")
                    }

                    // Switch to enable/disable notifications
                    Switch {
                        id: allowNotification   
                        Layout.alignment: Qt.AlignRight
                        Layout.columnSpan: 2
                    }
                }
            }
        }

        // FolderListModel for knotifications6
        FolderListModel {
            id: knotificationsModel
            folder: Qt.resolvedUrl("../../../../../../knotifications6/")
        }

        // Warning message for optional notification configuration
        Kirigami.InlineMessage {
            id: widgetScriptMessage
            visible: allowNotification.checked && !Tools.existsNotifyrc()
            anchors.left: root.left
            anchors.right: root.right
            text: i18n( "The widget uses the Plasma Workspace for the notification frame. "
                    +   "Change the notification frame to the individual widget notification frame for a better look and feel, and to access individual notification settings for this widget in the System Settings menu."
                    +   "<ol>"
                    +   (!String(knotificationsModel.parentFolder).includes("/.local/share") ?
                        ("<li>Open the <b>~/.local/share/</b> folder.</li>"
                    +   "<li>Create a new folder named <b>knotifications6</b> inside <b>~/.local/share/</b>.</li>") :
                        ("<li>Open the existing <b>knotifications6</b> folder:<br>"
                    +   "<b>~/.local/share/knotifications6</b></li>"))
                    +   "<li>Open the widget source folder:<br>"
                    +   "<b>~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend</b></li>"
                    +   "<li>Copy the <b>airPodsBatteryWidget.notifyrc</b> file from the widget source folder into the <b>knotifications6</b> folder.</li>"
                    +   "</ol>")
            font.pixelSize: 13
            type: Kirigami.MessageType.Warning
            actions: [
                // Button to open knotifications6 folder
                Kirigami.Action {
                    visible: String(knotificationsModel.parentFolder).includes("/.local/share")
                    text: qsTr("Open knotifications6")
                    icon.name: "document-open-folder"
                    onTriggered: {
                        var scriptPath = Qt.resolvedUrl("../../../../../../knotifications6")
                        Qt.openUrlExternally(scriptPath)
                    }
                },
                // Button to ~/.local/share folder
                Kirigami.Action {
                    visible: !String(knotificationsModel.parentFolder).includes("/.local/share")
                    text: qsTr("Open ~/.local/share")
                    icon.name: "document-open-folder"
                    onTriggered: {
                        var scriptPath = Qt.resolvedUrl("../../../../../../")
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
    
        Kirigami.ScrollablePage {
            anchors.left: root.left
            anchors.right: root.right
            visible: allowNotification.checked
            
            // Background for a card or container with theme-based color and rounded corners
            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                radius: 12
            }

            // List view for card elements
            Kirigami.CardsListView {
                id: cardsView
                // Model contains info to be displayed
                model: notificationModel
                // Delegate is how the information will be presented in the ListView
                delegate: notificationDelegate
            }

            // ListModel needed for ListView, contains elements to be displayed
            ListModel {
                id: notificationModel

                // Entry for the first AirPods notification
                ListElement {
                    name: "First Airpods notification"
                    description: "" 
                }

                // Entry for the second AirPods notification
                ListElement {
                    name: "Second Airpods notification"
                    description: "" 
                }

                // Entry for the first Case notification
                ListElement {
                    name: "First Case notification"
                    description: "" 
                }

                // Entry for the second Case notification
                ListElement {
                    name: "Second Case notification"
                    description: "" 
                }
            }

            // Delegate Component used by a ListView to define how each item in the list is displayed
            Component {
                id: notificationDelegate

                // Card representing a single notification in the ListView
                Kirigami.AbstractCard {
                    contentItem: Item {
                        implicitWidth: delegateLayoutCard.implicitWidth
                        implicitHeight: delegateLayoutCard.implicitHeight

                        // Layout for the content inside the card
                        GridLayout {
                            id: delegateLayoutCard
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.right: parent.right
                            
                            // Column for text elements
                            ColumnLayout {
                                // Heading for the notification name
                                Kirigami.Heading {
                                    Layout.fillWidth: true
                                    level: 2
                                    text: name
                                }

                                // Horizontal rule
                                Kirigami.Separator {
                                    Layout.fillWidth: true
                                    visible: description.length > 0
                                }

                                // Label displaying the description of the notification
                                Label {
                                    Layout.fillWidth: true
                                    text: description
                                }
                            }

                            // Button to edit the notification
                            Button {
                                Layout.alignment: Qt.AlignRight
                                Layout.columnSpan: 2
                                text: i18n("Edit")

                                // Open the corresponding dialog when clicked
                                onClicked: {
                                    switch(name) {
                                        case "First Airpods notification":
                                            firstPodsDialog.open()
                                        break;
                                        case "Second Airpods notification":
                                            secondPodsDialog.open()
                                        break;
                                        case "First Case notification":
                                            firstCaseDialog.open()
                                        break;
                                        case "Second Case notification":
                                            secondCaseDialog.open()
                                        break;
                                    }
                                }
                            }
                        }   
                    }
                }
            }

            // Initialize descriptions for each notification in the ListModel
            Component.onCompleted: {
                setNotificationDescription(0, firstPodsNotificationSwitch, firstPodsBatteryLowSpin, firstPodsUrgencySwitch, firstPodsIconSwitch)
                setNotificationDescription(1, secondPodsNotificationSwitch, secondPodsBatteryLowSpin, secondPodsUrgencySwitch, secondPodsIconSwitch)
                setNotificationDescription(2, firstCaseNotificationSwitch, firstCaseBatteryLowSpin, firstCaseUrgencySwitch, firstCaseIconSwitch)
                setNotificationDescription(3, secondCaseNotificationSwitch, secondCaseBatteryLowSpin, secondCaseUrgencySwitch, secondCaseIconSwitch)
            }

            // Dialog to configure the first AirPods notification
            Dialog {
                id: firstPodsDialog
                title: "Setup first Airpods notification"
                modal: true
                standardButtons: Dialog.Ok | Dialog.Cancel
                width: 440
                height: 280

                ColumnLayout {
                    spacing: 20
                    Kirigami.FormLayout {
                        // Enable or disable the first AirPods notification
                        Switch {
                            id: firstPodsNotificationSwitch
                            Kirigami.FormData.label: i18n("Enable first Airpods notification")
                        }

                        // Show icon in notification
                        Switch {
                            id: firstPodsIconSwitch
                            enabled: firstPodsNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Show the AirPods icon in the notification")
                        }

                        // Mark notification as urgent
                        Switch {
                            id: firstPodsUrgencySwitch
                            enabled: firstPodsNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Mark notification as urgent")
                        }

                        // SpinBox to set the battery threshold for triggering the notification
                        SpinBox {
                            id: firstPodsBatteryLowSpin
                            enabled: firstPodsNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Trigger notification when battery is below:")
                            from: secondPodsNotificationSwitch.checked ? secondPodsBatteryLowSpin.value : 0
                            to: 100
                            stepSize: 5

                            // Ensure first notification is always higher than the second one
                            onValueModified: {
                                if (secondPodsNotificationSwitch.checked && firstPodsBatteryLowSpin.value <= secondPodsBatteryLowSpin.value) {
                                    errorMessagesLabel1.visible = true;
                                    firstPodsBatteryLowSpin.value = firstPodsBatteryLowSpin.value + 5;
                                } else {
                                    errorMessagesLabel1.visible = false;
                                    startTimer.running = false;
                                }
                            }
                        }

                        // Error message if first notification threshold is not higher than second
                        Label {
                            id: errorMessagesLabel1
                            visible: false
                            anchors.left: parent.left
                            text: i18n("First notification must be higher than the second one.")
                            color: "red"
                            font.bold: true

                            // Start timer when error becomes visible (used for UI feedback)
                            onVisibleChanged: {
                                startTimer.running = true;
                            }
                        }
                    }

                    // Button to send a test notification for the first AirPods
                    Button {
                        text: "Send test notification"
                        enabled: firstPodsNotificationSwitch.checked
                        onClicked: {
                            sendBatteryNotification("AirPods", firstPodsBatteryLowSpin.value, firstPodsIconSwitch.checked, averageIconPath, firstPodsUrgencySwitch.checked);
                        }
                    }
                }

                // Update the ListModel description when the dialog is accepted
                onAccepted: {
                    setNotificationDescription(0, firstPodsNotificationSwitch, firstPodsBatteryLowSpin, firstPodsUrgencySwitch, firstPodsIconSwitch);
                }
            }

            // Dialog to configure the second AirPods notification
            Dialog {
                id: secondPodsDialog
                title: "Setup second Airpods notification"
                modal: true
                standardButtons: Dialog.Ok | Dialog.Cancel
                width: 440
                height: 280

                ColumnLayout {
                    spacing: 20
                    Kirigami.FormLayout {
                        // Enable or disable the second AirPods notification
                        Switch {
                            id: secondPodsNotificationSwitch
                            Kirigami.FormData.label: i18n("Enable second Airpods notification")
                        }

                        // Show icon in notification
                        Switch {
                            id: secondPodsIconSwitch
                            enabled: secondPodsNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Show the AirPods icon in the notification")
                        }            

                        // Mark notification as urgent
                        Switch {
                            id: secondPodsUrgencySwitch
                            enabled: secondPodsNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Mark notification as urgent")
                        }

                        // SpinBox to set the battery threshold for triggering the notification
                        SpinBox {
                            id: secondPodsBatteryLowSpin
                            enabled: secondPodsNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Trigger notification when battery is below:")
                            from: 0
                            to: firstPodsNotificationSwitch.checked ? firstPodsBatteryLowSpin.value : 100
                            stepSize: 5

                            // Ensure second notification is always higher than the second one
                            onValueModified: {
                                if (firstPodsNotificationSwitch.checked && secondPodsBatteryLowSpin.value >= firstPodsBatteryLowSpin.value) {
                                    errorMessagesLabel2.visible = true;
                                    secondPodsBatteryLowSpin.value = secondPodsBatteryLowSpin.value - 5;
                                } else {
                                    errorMessagesLabel2.visible = false;
                                    startTimer.running = false;
                                }
                            }
                        }

                        // Error message if second notification threshold is higher than first
                        Label {
                            id: errorMessagesLabel2
                            visible: false
                            anchors.left: parent.left
                            text: i18n("Second notification must be lower than the first one.")
                            color: "red"
                            font.bold: true

                            // Start timer when error becomes visible (used for UI feedback)
                            onVisibleChanged: {
                                startTimer.running = true;
                            }
                        }
                    }

                    // Button to send a test notification for the second AirPods
                    Button {
                        text: "Send test notification"
                        enabled: secondPodsNotificationSwitch.checked
                        onClicked: {
                            sendBatteryNotification("AirPods", secondPodsBatteryLowSpin.value, secondPodsIconSwitch.checked, averageIconPath, secondPodsUrgencySwitch.checked);
                        }
                    }
                }

                // Update the ListModel description when the dialog is accepted
                onAccepted: {
                    setNotificationDescription(1, secondPodsNotificationSwitch, secondPodsBatteryLowSpin, secondPodsUrgencySwitch, secondPodsIconSwitch);
                }
            }

            // Dialog to configure the first AirPods case notification
            Dialog {
                id: firstCaseDialog
                title: "Setup first Case notification"
                modal: true
                standardButtons: Dialog.Ok | Dialog.Cancel
                width: 440
                height: 280

                ColumnLayout {
                    spacing: 20
                    Kirigami.FormLayout {
                        // Enable or disable the first AirPods case notification
                        Switch {
                            id: firstCaseNotificationSwitch
                            Kirigami.FormData.label: i18n("Enable first Case notification")
                        }
                        
                        // Show icon in notification
                        Switch {
                            id: firstCaseIconSwitch
                            enabled: firstCaseNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Show the Case icon in the notification")
                        }            

                        // Mark notification as urgent
                        Switch {
                            id: firstCaseUrgencySwitch
                            enabled: firstCaseNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Mark notification as urgent")
                        }

                        // SpinBox to set the battery threshold for triggering the notification
                        SpinBox {
                            id: firstCaseBatteryLowSpin
                            enabled: firstCaseNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Trigger notification when battery is below:")
                            from: secondCaseNotificationSwitch.checked ? secondCaseBatteryLowSpin.value : 0
                            to: 100
                            stepSize: 5

                            // Ensure first notification is always higher than the second one
                            onValueModified: {
                                if (secondCaseNotificationSwitch.checked && firstCaseBatteryLowSpin.value <= secondCaseBatteryLowSpin.value) {
                                    errorMessagesLabel3.visible = true;
                                    firstCaseBatteryLowSpin.value = firstCaseBatteryLowSpin.value + 5;
                                } else {
                                    errorMessagesLabel3.visible = false;
                                    startTimer.running = false;
                                }
                            }
                        }
                        
                        // Error message if first notification threshold is not higher than second
                        Label {
                            id: errorMessagesLabel3
                            visible: false
                            anchors.left: parent.left
                            text: i18n("First case notification must be higher than the second one.")
                            color: "red"
                            font.bold: true

                            // Start timer when error becomes visible (used for UI feedback)
                            onVisibleChanged: {
                                startTimer.running = true;
                            }
                        }
                    }

                    // Button to send a test notification for the first AirPods case
                    Button {
                        text: "Send test notification"
                        enabled: firstCaseNotificationSwitch.checked
                        onClicked: {
                            sendBatteryNotification("AirPods Case", firstCaseBatteryLowSpin.value, firstCaseIconSwitch.checked, caseIconPath, firstCaseUrgencySwitch.checked);
                        }
                    }
                }

                // Update the ListModel description when the dialog is accepted
                onAccepted: {
                    setNotificationDescription(2, firstCaseNotificationSwitch, firstCaseBatteryLowSpin, firstCaseUrgencySwitch, firstCaseIconSwitch);
                }
            }

            // Dialog to configure the second AirPods case notification
            Dialog {
                id: secondCaseDialog
                title: "Setup second case notification"
                modal: true
                standardButtons: Dialog.Ok | Dialog.Cancel
                width: 440
                height: 280

                ColumnLayout {
                    spacing: 20
                    Kirigami.FormLayout {
                        // Enable or disable the second AirPods case notification
                        Switch {
                            id: secondCaseNotificationSwitch
                            Kirigami.FormData.label: i18n("Enable second Case notification")
                        }

                        // Show icon in notification
                        Switch {
                            id: secondCaseIconSwitch
                            enabled: secondCaseNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Show the Case icon in the notification")
                        }            

                        // Mark notification as urgent
                        Switch {
                            id: secondCaseUrgencySwitch
                            enabled: secondCaseNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Mark notification as urgent")
                        }

                        // SpinBox to set the battery threshold for triggering the notification
                        SpinBox {
                            id: secondCaseBatteryLowSpin
                            enabled: secondCaseNotificationSwitch.checked
                            Kirigami.FormData.label: i18n("Trigger notification when battery is below:")
                            from: 0
                            to: firstCaseNotificationSwitch.checked ? firstCaseBatteryLowSpin.value : 100
                            stepSize: 5

                            // Ensure second notification is always higher than the second one
                            onValueModified: {
                                if (firstCaseNotificationSwitch.checked && secondCaseBatteryLowSpin.value >= firstCaseBatteryLowSpin.value) {
                                    errorMessagesLabel4.visible = true;
                                    secondCaseBatteryLowSpin.value = secondCaseBatteryLowSpin.value - 5;
                                } else {
                                    errorMessagesLabel4.visible = false;
                                    startTimer.running = false;
                                }
                            }
                        }

                        // Error message if second notification threshold is higher than first
                        Label {
                            id: errorMessagesLabel4
                            visible: false
                            anchors.left: parent.left
                            text: i18n("Second case notification must be lower than the first one.")
                            color: "red"
                            font.bold: true

                            // Start timer when error becomes visible (used for UI feedback)
                            onVisibleChanged: {
                                startTimer.running = true;
                            }
                        }
                    }

                    // Button to send a test notification for the second AirPods case
                    Button {
                        text: "Send test notification"
                        enabled: secondCaseNotificationSwitch.checked
                        onClicked: {
                            sendBatteryNotification("AirPods Case", secondCaseBatteryLowSpin.value, secondCaseIconSwitch.checked, caseIconPath, secondCaseUrgencySwitch.checked);
                        }
                    }
                }

                // Update the ListModel description when the dialog is accepted
                onAccepted: {
                    setNotificationDescription(3, secondCaseNotificationSwitch, secondCaseBatteryLowSpin, secondCaseUrgencySwitch, secondCaseIconSwitch);
                }
            }

            // Component used to create notifications dynamically
            Component {
                id: notificationComponent
                Notification {
                    componentName: Tools.existsNotifyrc() ? "airPodsBatteryWidget" : "plasma_workspace"
                    eventId: "notification"
                    autoDelete: true
                }
            }

            // Timer to hide error messages after a short delay
            Timer {
                id: startTimer
                interval: 3000
                onTriggered: {
                    errorMessagesLabel1.visible = errorMessagesLabel2.visible = errorMessagesLabel3.visible = errorMessagesLabel4.visible = false;
                }
            }
        }
    }  
}