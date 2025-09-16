import QtQuick 2.12
import QtQuick.Layouts 1.12

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

import org.kde.bluezqt 1.0 as BluezQt

import "../tools/Tools.js"       as Tools

PlasmoidItem {
    id: root
    property QtObject btManager: BluezQt.Manager
    readonly property var cfg: plasmoid.configuration

    // Define paths for icons
    property string iconBasePath:       "../images/" + cfg.autoWidgetIcons ? cfg.comboBoxDefaultIconSelect : cfg.iconSelect
    property string averageIconPath:    iconBasePath + "/airpods.png"
    property string leftIconPath:       iconBasePath + "/airpod-left.png"
    property string rightIconPath:      iconBasePath + "/airpod-right.png"
    property string caseIconPath:       iconBasePath + "/airpods-case.png"

    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 12

    // Tooltip text for the widget
    toolTipMainText: "AirPods Battery Widget"
    toolTipSubText: updateToolTip()

    P5Support.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000
        intervalAlignment: P5Support.Types.AlignToMinute
    }

    // Function to check if the last case update is older than a custom threshold
    function isLastCaseUpdateOld(customTimeThreshold) {
        var currentDateTime = new Date(dataSource.data.Local.DateTime); // First date
        var lastCaseUpdated = Tools.getLastCaseUpdatedDate(); // Second date

        // Convert milliseconds to hours
        var diffInHours = (currentDateTime - lastCaseUpdated) / (1000 * 60 * 60);
        return diffInHours > customTimeThreshold;

        return false;
    }

    // Function to update the icons
    function updateIcons() {
        if (cfg.autoWidgetIcons) {
            switch (Tools.getAirPodsModel()) {
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
        text += "\n \u2022 %1 %2 % %3".arg("Left: ").arg(Tools.getLeftCharge() != -1 ? Tools.getLeftCharge() : "----").arg(Tools.isChargingLeft() ? "recharge" : "")
        text += "\n \u2022 %1 %2 % %3".arg("Right: ").arg(Tools.getRightCharge() != -1 ? Tools.getRightCharge() : "----").arg(Tools.isChargingRight() ? "recharge" : "")
        text += "\n \u2022 %1 %2 % %3".arg("Case: ").arg(Tools.getCaseCharge() != -1 ? Tools.getCaseCharge() : "----").arg(Tools.isChargingCase() ? "recharge" : "")
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

        // Minimum size for the compact view
        Layout.minimumWidth: Kirigami.Units.iconSizes.large * 5.5
        Layout.minimumHeight: Kirigami.Units.iconSizes.large

        // Toggle expanded/collapsed view when clicked
        onClicked: root.expanded = !root.expanded

        // Function to update charge text in the compact view and color if the charge is low
        function updateChargeTextCompRep(textElement, chargeRaw) {
            updateChargeText(textElement, chargeRaw);
            textElement.color = chargeRaw != -1 && chargeRaw < 20 && cfg.diffColorCompRepCheck ? cfg.diffColorCompRep : cfg.colorCompRep;
        }

        ColumnLayout {
            id: setupView
            visible: !(Tools.isEnvSet() && ((cfg.widgetScript && Tools.isAutoStartSet()) || (cfg.otherScript && Tools.fileExists(cfg.outPutFile))))
            anchors.centerIn: parent
            RowLayout {
                spacing: 5
                Row {
                    Kirigami.Icon {
                        source: Qt.resolvedUrl(averageIconPath)
                        height: cfg.iconSizeAverage
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    text: "Setup"
                    visible: true
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Layout for displaying battery charge info
        ColumnLayout {
            id: displayingView
            visible: (Tools.isEnvSet() && ((cfg.widgetScript && Tools.isAutoStartSet()) || (cfg.otherScript && Tools.fileExists(cfg.outPutFile))))
            anchors.centerIn: parent
        
            // Row for average charge and case charge in the compact view
            RowLayout {
                id: averageView
                visible: cfg.averageView || (cfg.autoView && (Math.abs(Tools.getLeftCharge() - Tools.getRightCharge()) <= 10))
                spacing: 5

                // AirPods charge display
                RowLayout {
                    spacing: 5
                    Row {
                        Kirigami.Icon {
                            source: Qt.resolvedUrl(averageIconPath)
                            height: cfg.iconSizeAverage
                            anchors.verticalCenter: parent.verticalCenter
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
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // AirPods case charge display
                RowLayout {
                    id: caseChargeLayout
                    visible: cfg.showCaseBattery || cfg.autoHiddenCaseBattery
                    height: parent.height
                    width: childrenRect.width
                    spacing: 5
                    Kirigami.Icon {
                        source: Qt.resolvedUrl(caseIconPath)
                        height: cfg.iconSizeCase
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: caseCharge
                        text: "----"
                        visible: cfg.percentTextCompRepCheck
                        font.pixelSize: cfg.fontSizeCompRep
                        font.bold: cfg.boldCompRep
                        font.italic: cfg.italicCompRep
                        color: cfg.colorCompRep
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Row for detailed charge view (left and right AirPods)
            RowLayout {
                id: detailedView
                visible: cfg.detailedView || (cfg.autoView && (Math.abs(Tools.getLeftCharge() - Tools.getRightCharge()) > 10))
                spacing: 10

                RowLayout {
                    // Left AirPod
                    Row {  
                        // Left AirPod
                        Kirigami.Icon {
                            source: Qt.resolvedUrl(leftIconPath)
                            height: cfg.iconSizeLeftRight
                            anchors.verticalCenter: parent.verticalCenter
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
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Right AirPod
                    Row {
                        Kirigami.Icon {
                            source: Qt.resolvedUrl(rightIconPath)
                            height: cfg.iconSizeLeftRight
                            anchors.verticalCenter: parent.verticalCenter
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
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // AirPods case in detailed view
                RowLayout {
                    id: caseChargeLayout1
                    visible: cfg.showCaseBattery || cfg.autoHiddenCaseBattery
                    height: parent.height
                    width: childrenRect.width
                    spacing: 5

                    Kirigami.Icon {
                        source: Qt.resolvedUrl(caseIconPath)
                        height: cfg.iconSizeCase
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: caseCharge1
                        text: "----"
                        visible: cfg.percentTextCompRepCheck
                        font.pixelSize: cfg.fontSizeCompRep
                        font.bold: cfg.boldCompRep
                        font.italic: cfg.italicCompRep
                        color: cfg.colorCompRep
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Timer to regularly update the battery status
        Timer {
            interval: 600
            running: true
            repeat: true

            // Triggered function to update the charge values in compact representation
            onTriggered: {
                updateChargeTextCompRep(averageCharge, Tools.getAverageCharge());
                updateChargeTextCompRep(leftCharge, Tools.getLeftCharge());
                updateChargeTextCompRep(rightCharge, Tools.getRightCharge());

                const averageViewValue = cfg.autoView ? (Math.abs(Tools.getLeftCharge() - Tools.getRightCharge()) <= 10) : cfg.averageView;
                averageView.visible = averageViewValue;
                detailedView.visible = !averageViewValue;

                if ((cfg.showCaseBattery && Tools.getCaseCharge() != -1) || (cfg.autoHiddenCaseBattery && !isLastCaseUpdateOld(cfg.customTimeThreshold2))) {
                    let caseChargeValue = Tools.getCaseCharge();
                    if (averageViewValue) {
                        updateChargeTextCompRep(caseCharge, caseChargeValue);
                        caseChargeLayout.visible = true;
                        caseChargeLayout.width = 65;
                        compactRep.Layout.minimumWidth = Kirigami.Units.iconSizes.large * 4;
                    } else {
                        updateChargeTextCompRep(caseCharge1, caseChargeValue);
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

                let isLastUpdateOld = false;

                if (cfg.hiddenWidgetLastUpdate) {
                    const currentDateTime = new Date(dataSource.data.Local.DateTime); // First date
                    const lastUpdated = Tools.getLastUpdatedDate(); // Second date

                    // Convert milliseconds to hours
                    const diffInHours = (currentDateTime - lastUpdated) / (1000 * 60 * 60);

                    isLastUpdateOld = diffInHours > cfg.customTimeThreshold;
                }

                compactRep.visible = !((!btManager.bluetoothOperational && cfg.hiddenWidgetBt) || isLastUpdateOld);

                if (!compactRep.visible) {
                    compactRep.Layout.minimumWidth = 4;
                }

                if (!(Tools.isEnvSet() && ((cfg.widgetScript && Tools.isAutoStartSet()) || (cfg.otherScript && Tools.fileExists(cfg.outPutFile))))) {
                    setupView.visible = true;
                    displayingView.visible = false;
                } else {
                    setupView.visible = false;
                    displayingView.visible = true;
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

        ColumnLayout {
            id: setupView
            visible: !(Tools.isEnvSet() && ((cfg.widgetScript && Tools.isAutoStartSet()) || (cfg.otherScript && Tools.fileExists(cfg.outPutFile))))
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
            visible: (Tools.isEnvSet() && ((cfg.widgetScript && Tools.isAutoStartSet()) || (cfg.otherScript && Tools.fileExists(cfg.outPutFile))))
            spacing: 10
            anchors.centerIn: parent

            // Title row (visible if configured)
            Row {
                visible: cfg.titleCheck
                Text {
                    id: modelTitle
                    text: cfg.titleCheckText ? cfg.titleText : Tools.getAirPodsModel()
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
                    text: "Last updated: " + Qt.locale().toString(Tools.getLastUpdatedDate(), cfg.customDateFormat)
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: cfg.fontSizeFullRepLU
                    font.bold: cfg.boldFullRepLU
                    font.italic: cfg.italicFullRepLU
                    color: cfg.colorFullRepLU
                }
            }
        }

        // Timer to update the widget every 60 seconds
        Timer {
            interval: 600 
            running: true
            repeat: true
            onTriggered: {
                // Update model title text
                modelTitle.text = cfg.titleCheckText ? cfg.titleText : Tools.getAirPodsModel();

                // Update AirPod left charge
                var leftChargeRaw = Tools.getLeftCharge();
                var isLeftCharging = Tools.isChargingLeft();
                updateChargeTextCompFull(leftChargeText, leftChargeRaw);
                renderAirpodCircle(circleCanvas1, leftChargeRaw, leftIconPath, isLeftCharging, cfg.iconWidthLeftRightFullRep, cfg.iconHeightLeftRightFullRep);

                // Update AirPod right charge
                var rightChargeRaw = Tools.getRightCharge();
                var isRightCharging = Tools.isChargingRight();
                updateChargeTextCompFull(rightChargeText, rightChargeRaw);
                renderAirpodCircle(circleCanvas2, rightChargeRaw, rightIconPath, isRightCharging, cfg.iconWidthLeftRightFullRep, cfg.iconHeightLeftRightFullRep);

                // Update AirPods case charge (only if enabled in settings)
                var caseChargeRaw = Tools.getCaseCharge();
                var isCaseCharging = Tools.isChargingCase();
                if (cfg.showAlwaysCaseBatteryFullRep) {
                    caseView.visible = true;
                    fullRep.Layout.minimumWidth = Kirigami.Units.gridUnit * 20
                    updateChargeTextCompFull(caseChargeText, caseChargeRaw);
                    renderAirpodCircle(circleCanvas3, caseChargeRaw, caseIconPath, isCaseCharging, cfg.iconWidthCaseFullRep, cfg.iconHeightCaseFullRep);
                } else if (cfg.showAvailableCaseBatteryFullRep) {
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
                lastUpdated.text = "Last updated: " + Qt.locale().toString(Tools.getLastUpdatedDate(), cfg.customDateFormat);

                toolTipSubText = updateToolTip();
                updateIcons();

                if (!(Tools.isEnvSet() && ((cfg.widgetScript && Tools.isAutoStartSet()) || (cfg.otherScript && Tools.fileExists(cfg.outPutFile))))) {
                    setupView.visible = true;
                    displayingView.visible = false;
                } else {
                    setupView.visible = false;
                    displayingView.visible = true;
                }
            }
        }
    }

    // Timer to periodically check and update battery status
    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: {
            if (Tools.isEnvSet() && (Tools.isAutoStartSet() || Tools.fileExists(cfg.outPutFile))) {
                Tools.updateBatteryStatus(cfg.otherScript ? cfg.outPutFile : cfg.widgetScript ? "../../airstatus.out" : "", cfg.optimizerOptions ? cfg.refRawValue : "-1");
            }
        }
    }

    // Initial battery status update when the widget is loaded
    Component.onCompleted: {
        if (Tools.isEnvSet() && (Tools.isAutoStartSet() || Tools.fileExists(cfg.outPutFile))) {
            Tools.updateBatteryStatus(cfg.otherScript ? cfg.outPutFile : cfg.widgetScript ? "../../airstatus.out" : "", cfg.optimizerOptions ? cfg.refRawValue : "-1");
        }
        updateIcons();
    }
}
