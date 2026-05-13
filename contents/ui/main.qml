import QtQuick 2.12
import QtQuick.Layouts 1.12

import org.kde.bluezqt 1.0 as BluezQt
import org.kde.kirigami 2.20 as Kirigami
import org.kde.notification 1.0
import org.kde.plasma.plasmoid 2.0

import "../tools/Tools.js"       as Tools

PlasmoidItem {
    id: root

    signal updateCompact();
    signal updateFull();

    property QtObject btManager: BluezQt.Manager
    readonly property var cfg: plasmoid.configuration

    // Define paths for icons
    property string iconBasePath:       "../images/" + cfg.autoWidgetIcons ? cfg.comboBoxDefaultIconSelect : cfg.iconSelect
    property string averageIconPath:    iconBasePath + "/airpods.png"
    property string leftIconPath:       iconBasePath + "/airpod-left.png"
    property string rightIconPath:      iconBasePath + "/airpod-right.png"
    property string caseIconPath:       iconBasePath + "/airpods-case.png"

    property bool isWidgetInit: false

    property bool isWidgetVisible: false

    property bool sendFirstAirPodsNotification: false
    property bool sendSecondAirPodsNotification: false

    property bool sendFirstLeftPodNotification: false
    property bool sendSecondLeftPodNotification: false

    property bool sendFirstRightPodNotification: false
    property bool sendSecondRightPodNotification: false

    property bool sendFirstCaseNotification: false
    property bool sendSecondCaseNotification: false

    property var airpodsNotification: null
    property var leftPodNotification: null
    property var rightPodNotification: null
    property var caseNotification: null

    property int    leftBat:        -1
    property int    rightBat:       -1
    property int    averageBat:     -1
    property int    caseBat:        -1
    property bool   chargingLeft:   false
    property bool   chargingRight:  false
    property bool   chargingCase:   false
    property string model:          "unknown"
    property var lastUpdate:     new Date(2000, 0, 1, 0, 0, 0)
    property var lastUpdateCase: new Date(2000, 0, 1, 0, 0, 0)
    property string raw:            "-"

    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 12

    // Tooltip text for the widget
    toolTipMainText: "AirPods Battery Widget"
    toolTipSubText: updateToolTip()

    // Function to update the widget
    function updateWidget() {
        updateNotificationManager();
        updateCompact();
        updateFull();
    }

    // Function to load AirPods data
    function loadData() {
        root.model          = Tools.getAirPodsModel();
        root.averageBat     = Tools.getAverageCharge();
        root.leftBat        = Tools.getLeftCharge();
        root.rightBat       = Tools.getRightCharge();
        root.caseBat        = Tools.getCaseCharge();
        root.chargingLeft   = Tools.isChargingLeft();
        root.chargingRight  = Tools.isChargingRight();
        root.chargingCase   = Tools.isChargingCase();
        root.lastUpdate     = new Date(Tools.getLastUpdated());
        root.lastUpdateCase = new Date(Tools.getLastCaseUpdated());
    }

    // Function to manages and handles notification logic for AirPods battery alerts
    function updateNotificationManager() {
        if (cfg.allowNotification && isWidgetVisible) {
            if ((Math.abs(root.leftBat - root.rightBat) > 10)) {
                if (airpodsNotification) {
                    airpodsNotification.destroy();
                    airpodsNotification = null;
                    sendFirstAirPodsNotification = sendSecondAirPodsNotification = false;
                }
                
                // Left Pod Notifications
                var podResult = handleNotification(sendSecondLeftPodNotification, cfg.secondPodsBatteryLowSpin, root.leftBat, cfg.secondPodsNotificationSwitch, cfg.secondPodsUrgencySwitch, cfg.secondPodsIconSwitch, leftIconPath, "Left AirPod", leftPodNotification);
                sendSecondLeftPodNotification = podResult.flag;
                leftPodNotification = podResult.notification;

                if (!sendSecondLeftPodNotification) {
                    podResult = handleNotification(sendFirstLeftPodNotification, cfg.firstPodsBatteryLowSpin, root.leftBat, cfg.firstPodsNotificationSwitch, cfg.firstPodsUrgencySwitch, cfg.firstPodsIconSwitch, leftIconPath, "Left AirPod", leftPodNotification);
                    sendFirstLeftPodNotification = podResult.flag;
                    leftPodNotification = podResult.notification;
                }
                    
                // Right Pod Notifications
                var podResult = handleNotification(sendSecondRightPodNotification, cfg.secondPodsBatteryLowSpin, root.rightBat, cfg.secondPodsNotificationSwitch, cfg.secondPodsUrgencySwitch, cfg.secondPodsIconSwitch, rightIconPath, "Right AirPod", rightPodNotification);
                sendSecondRightPodNotification = podResult.flag;
                rightPodNotification = podResult.notification;

                if (!sendSecondRightPodNotification) {
                    podResult = handleNotification(sendFirstRightPodNotification, cfg.firstPodsBatteryLowSpin, root.rightBat, cfg.firstPodsNotificationSwitch, cfg.firstPodsUrgencySwitch, cfg.firstPodsIconSwitch, rightIconPath, "Right AirPod", rightPodNotification);
                    sendFirstRightPodNotification = podResult.flag;
                    rightPodNotification = podResult.notification;
                }
            } else {
                if (leftPodNotification) {
                    leftPodNotification.destroy();
                    leftPodNotification = null;
                    sendFirstLeftPodNotification = sendSecondLeftPodNotification = false;
                }
                    
                if (rightPodNotification) {
                    rightPodNotification.destroy();
                    rightPodNotification = null;
                    sendFirstRightPodNotification = sendSecondRightPodNotification = false;
                }

                // AirPods Notifications
                var podResult = handleNotification(sendSecondAirPodsNotification, cfg.secondPodsBatteryLowSpin, root.averageBat, cfg.secondPodsNotificationSwitch, cfg.secondPodsUrgencySwitch, cfg.secondPodsIconSwitch, averageIconPath, "AirPods", airpodsNotification);
                sendSecondAirPodsNotification = podResult.flag;
                airpodsNotification = podResult.notification;

                if (!sendSecondAirPodsNotification) {
                    podResult = handleNotification(sendFirstAirPodsNotification, cfg.firstPodsBatteryLowSpin, root.averageBat, cfg.firstPodsNotificationSwitch, cfg.firstPodsUrgencySwitch, cfg.firstPodsIconSwitch, averageIconPath, "AirPods", airpodsNotification);
                    sendFirstAirPodsNotification = podResult.flag;
                    airpodsNotification = podResult.notification;
                }
            }
                    
            // Case Notifications
            var caseResult = handleNotification(sendSecondCaseNotification, cfg.secondCaseBatteryLowSpin, root.caseBat, cfg.secondCaseNotificationSwitch, cfg.secondCaseUrgencySwitch, cfg.secondCaseIconSwitch, caseIconPath, "AirPods Case", caseNotification);
            sendSecondCaseNotification = caseResult.flag;
            caseNotification = caseResult.notification;

            if (!sendSecondCaseNotification) {
                caseResult = handleNotification(sendFirstCaseNotification, cfg.firstCaseBatteryLowSpin, root.caseBat, cfg.firstCaseNotificationSwitch, cfg.firstCaseUrgencySwitch, cfg.firstCaseIconSwitch, caseIconPath, "AirPods Case", caseNotification);
                sendFirstCaseNotification = caseResult.flag;
                caseNotification = caseResult.notification;
            }
        }
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

    // Function to handle notification
    function handleNotification(currentFlag, threshold, charge, enabled, urgencySwitch, iconSwitch, iconPath, name, currentNotification) {
        if (!enabled || charge === -1) return { flag: currentFlag, notification: currentNotification };

        if (!currentFlag && charge <= threshold) {
            if (currentNotification) currentNotification.destroy();
            currentNotification = sendBatteryNotification(name, charge, iconSwitch, iconPath, urgencySwitch);
            currentFlag = true;
        } else if (currentFlag && charge > threshold) {
            currentFlag = false;
            if (currentNotification) currentNotification.destroy();
            currentNotification = null;
        }

        return { flag: currentFlag, notification: currentNotification };
    }

    // Function to check if the last update is older than a custom threshold
    function isLastUpdateOlderThanThreshold(lastUpdated, customTimeThreshold) {
        var diffInHours = (new Date() - lastUpdated) / (1000 * 60 * 60);
        return diffInHours > customTimeThreshold;
    }

    // Function to update the icons
    function updateIcons() {
        if (cfg.autoWidgetIcons) {
            switch (root.model) {
                case "AirPods1":
                case "AirPods2":
                    iconBasePath = "../images/AirPodsGen1&2Icons";
                    break;
                case "AirPods3":
                    iconBasePath = "../images/AirpodsGen3Icons";
                    break;
                case "AirPods4":
                    iconBasePath = "../images/AirpodsGen4Icons";
                    break;
                case "AirPodsPro":
                case "AirPodsPro2":
                    iconBasePath = "../images/AirPodsPro1&2Icons";
                    break;
                case "unknown":
                    iconBasePath = "../images/" + cfg.comboBoxDefaultIconSelect;
                    break;
                default:
                    iconBasePath = "../images/" + cfg.comboBoxDefaultIconSelect;
                    break;
            }
        } else {
            iconBasePath = "../images/" + cfg.iconSelect
        }
        averageIconPath = iconBasePath + "/airpods.png"
        leftIconPath = iconBasePath + "/airpod-left.png"
        rightIconPath = iconBasePath + "/airpod-right.png"
        caseIconPath = iconBasePath + "/airpods-case.png"
    }

    // Function to update the tooltip information
    function updateToolTip() {
        let text = "";
        text += "\n \u2022 %1 %2 % %3".arg("Left: ").arg(root.leftBat != -1 ? root.leftBat : "----").arg(root.chargingLeft ? "recharge" : "")
        text += "\n \u2022 %1 %2 % %3".arg("Right: ").arg(root.rightBat != -1 ? root.rightBat : "----").arg(root.chargingRight ? "recharge" : "")
        text += "\n \u2022 %1 %2 % %3".arg("Case: ").arg(root.caseBat != -1 ? root.caseBat : "----").arg(root.chargingCase ? "recharge" : "")
        return text;
    }

    // Helper function to update charge percentage text
    function updateChargeText(textElement, chargeRaw, defaultText = "----") {
        textElement.text = chargeRaw != -1 ? chargeRaw + "%" : defaultText;
    }

    // Compact representation of the widget (when minimized)
    compactRepresentation: MouseArea {
        id: compactRep

        visible: !btManager.bluetoothOperational && cfg.hiddenWight

        states: [
            State{
                name: "editMode"
                // This state is active when the Plasmoid is in edit mode
                when:  Plasmoid.containment.corona?.editMode?true:false
                changes: [
                    PropertyChanges {
                        target: editModeView
                        visible: {
                            if (!isWidgetVisible && !setupView.visible) {
                                compactRep.Layout.minimumWidth = Kirigami.Units.iconSizes.large * 2.5;
                                displayingView.visible = false;
                                return true;
                            } if(setupView.visible) {
                                return false;
                            }else {
                                displayingView.visible = true;
                                return false;
                            }
                        }
                    }
                ]
            }
        ]

        // Minimum size for the compact view
        Layout.minimumWidth: !isWidgetInit ? Kirigami.Units.iconSizes.large * 2 : Kirigami.Units.iconSizes.large * 5.5
        Layout.minimumHeight: Kirigami.Units.iconSizes.large

        // Toggle expanded/collapsed view when clicked
        onClicked: root.expanded = !root.expanded

        // Function to update charge text in the compact view and color if the charge is low
        function updateChargeTextCompRep(textElement, chargeRaw) {
            updateChargeText(textElement, chargeRaw);
            textElement.color = chargeRaw != -1 && chargeRaw < 20 && cfg.diffColorCompRepCheck ? cfg.diffColorCompRep : cfg.colorCompRep;
        }

        // Function to update the compact representation 
        function updateCompactRepresentation(){
            if(!editModeView.visible){
                updateChargeTextCompRep(averageCharge, root.averageBat);
                updateChargeTextCompRep(leftCharge, root.leftBat);
                updateChargeTextCompRep(rightCharge, root.rightBat);

                const averageViewValue = cfg.autoView ? (Math.abs(root.leftBat - root.rightBat) <= 10) : cfg.averageView;
                averageView.visible = averageViewValue;
                detailedView.visible = !averageViewValue;

                if ((cfg.showCaseBattery && root.caseBat != -1) || (cfg.autoHiddenCaseBattery && !isLastUpdateOlderThanThreshold(root.lastUpdateCase, cfg.customTimeThreshold2))) {
                    if (averageViewValue) {
                        updateChargeTextCompRep(caseCharge, root.caseBat);
                        caseChargeLayout.visible = true;
                        caseChargeLayout.width = 65;
                        compactRep.Layout.minimumWidth = Kirigami.Units.iconSizes.large * 4;
                    } else {
                        updateChargeTextCompRep(caseCharge1, root.caseBat);
                        caseChargeLayout1.visible = true;
                        caseChargeLayout1.width = 70;
                        compactRep.Layout.minimumWidth = Kirigami.Units.iconSizes.large * 5.5;
                    }
                } else {
                    caseChargeLayout.visible = averageViewValue ? false : caseChargeLayout1.visible = false;
                    caseChargeLayout.width = 0;
                    compactRep.Layout.minimumWidth = averageViewValue ? Kirigami.Units.iconSizes.large * 2 : Kirigami.Units.iconSizes.large * 3.5;
                }

                toolTipSubText = updateToolTip();
                updateIcons();

                displayingView.visible = isWidgetVisible = !((!btManager.bluetoothOperational && cfg.hiddenWidgetBt) || (isLastUpdateOlderThanThreshold(root.lastUpdate, cfg.customTimeThreshold) && cfg.hiddenWidgetLastUpdate));

                if (!displayingView.visible) {
                    compactRep.Layout.minimumWidth = 4;
                }
            }
        }

        Connections {
            target: root
            function onUpdateCompact() {
                compactRep.updateCompactRepresentation();
            }
        }

        // Layout for edit mode view
        ColumnLayout {
            id: editModeView
            visible: false
            anchors.centerIn: parent
            RowLayout {
                spacing: 5
                Row {
                    Kirigami.Icon {
                        source: Qt.resolvedUrl(averageIconPath)
                        height: cfg.iconSizeAverage
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
                Text {
                    text: "Edit Mode"
                    visible: true
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        ColumnLayout {
            id: setupView
            visible: !isWidgetInit
            anchors.centerIn: parent
            RowLayout {
                spacing: 5
                Row {
                    Kirigami.Icon {
                        source: Qt.resolvedUrl(averageIconPath)
                        height: cfg.iconSizeAverage
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
                Text {
                    text: "Setup"
                    visible: true
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        // Layout for displaying battery charge info
        ColumnLayout {
            id: displayingView
            visible: isWidgetInit
            anchors.centerIn: parent
        
            // Row for average charge and case charge in the compact view
            RowLayout {
                id: averageView
                visible: cfg.averageView || (cfg.autoView && (Math.abs(root.leftBat - root.rightBat) <= 10))
                spacing: 5

                // AirPods charge display
                RowLayout {
                    spacing: 5
                    Row {
                        Kirigami.Icon {
                            source: Qt.resolvedUrl(averageIconPath)
                            height: cfg.iconSizeAverage
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                    Text {
                        id: averageCharge
                        text: "----"
                        visible: cfg.percentTextCompRepCheck
                        font.pixelSize: cfg.fontSizeCompRep
                        font.bold: cfg.boldCompRep
                        font.italic: cfg.italicCompRep
                        color: cfg.colorCompRep
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // AirPods case charge display
                RowLayout {
                    id: caseChargeLayout
                    visible: cfg.showCaseBattery || cfg.autoHiddenCaseBattery
                    height: parent.height
                    spacing: 5
                    Kirigami.Icon {
                        source: Qt.resolvedUrl(caseIconPath)
                        height: cfg.iconSizeCase
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        id: caseCharge
                        text: "----"
                        visible: cfg.percentTextCompRepCheck
                        font.pixelSize: cfg.fontSizeCompRep
                        font.bold: cfg.boldCompRep
                        font.italic: cfg.italicCompRep
                        color: cfg.colorCompRep
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            // Row for detailed charge view (left and right AirPods)
            RowLayout {
                id: detailedView
                visible: cfg.detailedView || (cfg.autoView && (Math.abs(root.leftBat - root.rightBat) > 10))
                spacing: 10

                RowLayout {
                    // Left AirPod
                    Row {  
                        // Left AirPod
                        Kirigami.Icon {
                            source: Qt.resolvedUrl(leftIconPath)
                            height: cfg.iconSizeLeftRight
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                    Text {
                        id: leftCharge
                        text: "----"
                        visible: cfg.percentTextCompRepCheck
                        font.pixelSize: cfg.fontSizeCompRep
                        font.bold: cfg.boldCompRep
                        font.italic: cfg.italicCompRep
                        color: cfg.colorCompRep
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Right AirPod
                    Row {
                        Kirigami.Icon {
                            source: Qt.resolvedUrl(rightIconPath)
                            height: cfg.iconSizeLeftRight
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                    Text {
                        id: rightCharge
                        text: "----"
                        visible: cfg.percentTextCompRepCheck
                        font.pixelSize: cfg.fontSizeCompRep
                        font.bold: cfg.boldCompRep
                        font.italic: cfg.italicCompRep
                        color: cfg.colorCompRep
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // AirPods case in detailed view
                RowLayout {
                    id: caseChargeLayout1
                    visible: cfg.showCaseBattery || cfg.autoHiddenCaseBattery
                    height: parent.height
                    spacing: 5

                    Kirigami.Icon {
                        source: Qt.resolvedUrl(caseIconPath)
                        height: cfg.iconSizeCase
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        id: caseCharge1
                        text: "----"
                        visible: cfg.percentTextCompRepCheck
                        font.pixelSize: cfg.fontSizeCompRep
                        font.bold: cfg.boldCompRep
                        font.italic: cfg.italicCompRep
                        color: cfg.colorCompRep
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }

    // Full representation of the widget (when expanded)
    fullRepresentation: Item {
        id: fullRep

        // Set layout size boundaries for the expanded view
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        Layout.maximumHeight: Kirigami.Units.gridUnit * 10

        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 10
        

        // Function to update charge text in full representation
        function updateChargeTextCompFull(textElement, chargeRaw) {
            updateChargeText(textElement, chargeRaw);
            textElement.color = chargeRaw != -1 && chargeRaw < 20 && cfg.diffColorCompFullCheck ? cfg.diffColorCompFull : cfg.colorFullRepPC;
        }

        // Generic function to render AirPod charge with a circle representation
        function renderAirpodCircle(canvas, chargeRaw, iconPath, isCharging, imgWidth = 30, imgHeight = 40) {
            var chargeValue = parseFloat(chargeRaw) / 100;
            drawCircle(canvas, (chargeRaw != -1 ? chargeValue : 0), iconPath, isCharging, imgWidth, imgHeight);
        }

        // Function to draw a circle showing the charge level with an image in the center
        function drawCircle(canvas, chargeValue, imagefile, charging = false, imgWidth = 30, imgHeight = 40) {
            var ctx = canvas.getContext("2d");
            ctx.clearRect(0, 0, canvas.width, canvas.height);
                    
            if (cfg.percentageCircleCheck) {
                // Outer circle (gray background)
                ctx.beginPath();
                ctx.arc(canvas.width / 2, canvas.height / 2, canvas.width / 2 - 10, 0, Math.PI * 2, false);
                ctx.lineWidth = cfg.circleWidth;
                ctx.strokeStyle = "gray";
                ctx.stroke();

                // Progress circle (indicates battery level)
                ctx.beginPath();
                ctx.arc(canvas.width / 2, canvas.height / 2, canvas.width / 2 - 10, -Math.PI / 2, (-Math.PI / 2) + (Math.PI * 2 * chargeValue), false);
                ctx.lineWidth = cfg.circleWidth;
                ctx.strokeStyle = chargeValue < 0.2 ? cfg.colorFullRepCircleU : cfg.colorFullRepCircleO;
                ctx.stroke();
            }

            // Draw the image (AirPod or case) in the center of the circle      
            var x = (canvas.width / 2) - (imgWidth / 2);  
            var y = (canvas.height / 2) - (imgHeight / 2);
            ctx.drawImage(Qt.resolvedUrl(imagefile), x, y, imgWidth, imgHeight);
                
            // If charging, show a lightning bolt icon
            if (charging) {
                var radius = canvas.width / 2 - 10;
                var lightningX = canvas.width / 2 + radius * Math.cos((-Math.PI / 2)) - 7; 
                var lightningY = canvas.height / 2 + radius * Math.sin((-Math.PI / 2)) - 7;
                ctx.drawImage(Qt.resolvedUrl("../images/thunderbolt.png"), lightningX, lightningY, 15, 15);  
            }

            canvas.requestPaint();
        }

        // Function to update the full representation 
        function updateFullRepresentation(){
            // Update model title text
            modelTitle.text = cfg.titleCheckText ? cfg.titleText : root.model;

            // Update AirPod left charge
            var leftChargeRaw = root.leftBat;
            var isLeftCharging = root.chargingLeft;
            updateChargeTextCompFull(leftChargeText, leftChargeRaw);
            renderAirpodCircle(circleCanvas1, leftChargeRaw, leftIconPath, isLeftCharging, cfg.iconWidthLeftRightFullRep, cfg.iconHeightLeftRightFullRep);

            // Update AirPod right charge
            var rightChargeRaw = root.rightBat;
            var isRightCharging = root.chargingRight;
            updateChargeTextCompFull(rightChargeText, rightChargeRaw);
            renderAirpodCircle(circleCanvas2, rightChargeRaw, rightIconPath, isRightCharging, cfg.iconWidthLeftRightFullRep, cfg.iconHeightLeftRightFullRep);

            // Update AirPods case charge (only if enabled in settings)
            var caseChargeRaw = root.caseBat;
            var isCaseCharging = root.chargingCase;
            if (cfg.showAlwaysCaseBatteryFullRep) {
                caseView.visible = true;
                fullRep.Layout.minimumWidth = Kirigami.Units.gridUnit * 20
                updateChargeTextCompFull(caseChargeText, caseChargeRaw);
                renderAirpodCircle(circleCanvas3, caseChargeRaw, caseIconPath, isCaseCharging, cfg.iconWidthCaseFullRep, cfg.iconHeightCaseFullRep);
            } else if (cfg.showAvailableCaseBatteryFullRep || (cfg.autoHiddenCaseBatteryFullRep && !isLastUpdateOlderThanThreshold(root.lastUpdateCase, cfg.customTimeThreshold3))) {
                if (caseChargeRaw != -1) {
                    caseView.visible = true;
                    fullRep.Layout.minimumWidth = Kirigami.Units.gridUnit * 20
                    updateChargeTextCompFull(caseChargeText, caseChargeRaw);
                    renderAirpodCircle(circleCanvas3, caseChargeRaw, caseIconPath, isCaseCharging, cfg.iconWidthCaseFullRep, cfg.iconHeightCaseFullRepp);
                } else {
                    caseView.visible = false;
                    fullRep.Layout.minimumWidth = Kirigami.Units.gridUnit * 14
                }
            } else {
                caseView.visible = false;
                fullRep.Layout.minimumWidth = Kirigami.Units.gridUnit * 14
            }

            if (cfg.circleSize > 84) {
                fullRep.Layout.maximumWidth = Kirigami.Units.gridUnit * 200
                fullRep.Layout.maximumHeight = Kirigami.Units.gridUnit * 100
            }

            // Update last update text
            lastUpdated.text = "Last updated: " + Qt.locale().toString(root.lastUpdate, cfg.customDateFormat);

            toolTipSubText = updateToolTip();
            updateIcons();
        }

        Connections {
            target: root
            function onUpdateFull() {
                fullRep.updateFullRepresentation();
            }
        }

        ColumnLayout {
            id: setupView
            visible: !isWidgetInit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: {
                    if (!Tools.isEnvSet()) {
                        return "Please open the Widget setting <br> and follow setup instruction."
                    } else {
                        return "Please open the Widget setting <br> and follow setup instruction.<br><br> Step 1 of 2 done."
                    }
                }
                font.pixelSize: 15
                font.bold: true
                color: "white"
            }
        }

        Column {
            id: displayingView
            visible: isWidgetInit
            spacing: 10
            anchors.centerIn: parent

            // Title row (visible if configured)
            Row {
                visible: cfg.titleCheck
                Text {
                    id: modelTitle
                    text: cfg.titleCheckText ? cfg.titleText : root.model
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: cfg.fontSizeFullRepTitle
                    font.bold: cfg.boldFullRepTitle
                    font.italic: cfg.italicFullRepTitle
                    color: cfg.colorFullRepTitle
                }
            }

            // Battery charge display (AirPods left, right, and case)
            Row {
                id: center
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    Row {
                        spacing: 20
                         
                        // Left AirPod circle and text
                        Column {
                            Canvas {
                                id: circleCanvas1
                                width: cfg.circleSize
                                height: cfg.circleSize
                            }
                            Text {
                                id: leftChargeText
                                text: "----"
                                visible: cfg.percentTextFullRepCheck
                                font.pixelSize: cfg.fontSizeFullRepPC
                                font.bold: cfg.boldFullRepPC
                                font.italic: cfg.italicFullRepPC
                                color: cfg.colorFullRepPC
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        // Right AirPod circle and text
                        Column {
                            Canvas {
                                id: circleCanvas2
                                width: cfg.circleSize
                                height: cfg.circleSize
                            }
                            Text {
                                id: rightChargeText
                                text: "----"
                                visible: cfg.percentTextFullRepCheck
                                font.pixelSize: cfg.fontSizeFullRepPC
                                font.bold: cfg.boldFullRepPC
                                font.italic: cfg.italicFullRepPC
                                color: cfg.colorFullRepPC
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        // AirPods case circle and text
                        Column {
                            id: caseView
                            Canvas {
                                id: circleCanvas3
                                width: cfg.circleSize
                                height: cfg.circleSize
                            }
                            Text {
                                id: caseChargeText
                                text: "----"
                                visible: cfg.percentTextFullRepCheck
                                font.pixelSize: cfg.fontSizeFullRepPC
                                font.bold: cfg.boldFullRepPC
                                font.italic: cfg.italicFullRepPC
                                color: cfg.colorFullRepPC
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            // Last updated timestamp
            Row {
                visible: cfg.lastUpdateTextCheck
                Text {
                    id: lastUpdated
                    text: "Last updated: " + Qt.locale().toString(root.lastUpdate, cfg.customDateFormat)
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: cfg.fontSizeFullRepLU
                    font.bold: cfg.boldFullRepLU
                    font.italic: cfg.italicFullRepLU
                    color: cfg.colorFullRepLU
                }
            }
        }
    }

    // Timer to periodically check and update battery status and send notification
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            isWidgetInit = (Tools.isEnvSet() && ((cfg.widgetScript && Tools.isAutoStartSet()) || (cfg.otherScript && Tools.fileExists(cfg.outPutFile))))
            if (isWidgetInit) {
                Tools.updateBatteryStatus(cfg.otherScript ? cfg.outPutFile : cfg.widgetScript ? "../../airstatus.out" : "", cfg.optimizerOptions ? cfg.refRawValue : "-1");    
                loadData();
                updateWidget();
            }
        }
    }

    // Component used to create notifications dynamically
    Component {
        id: notificationComponent
        Notification {
            componentName: "airPodsBatteryWidget"
            eventId: "notification"
            autoDelete: true
        }
    }

    // Initial battery status update when the widget is loaded
    Component.onCompleted: {
        isWidgetInit = (Tools.isEnvSet() && ((cfg.widgetScript && Tools.isAutoStartSet()) || (cfg.otherScript && Tools.fileExists(cfg.outPutFile))))
        if (isWidgetInit) {
            Tools.updateBatteryStatus(cfg.otherScript ? cfg.outPutFile : cfg.widgetScript ? "../../airstatus.out" : "", cfg.optimizerOptions ? cfg.refRawValue : "-1");
            loadData();
            updateWidget();
        }
        updateIcons();
    }
}
