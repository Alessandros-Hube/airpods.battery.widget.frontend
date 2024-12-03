let averageCharge = -1;
let leftCharge = -1;
let isLeftCharging = false;
let rightCharge = -1;
let isRightCharging = false;
let caseCharge = -1;
let isCaseCharging = false;
let airPodsModel = "unknown";
let lastUpdated = "2000-01-01 00:00:00";
let env = true;

// Function to get the average charge of left and right AirPods
function getAverageCharge() {
    return averageCharge;
}

// Function to get the battery percentage of the left AirPod
function getLeftCharge() {
    return leftCharge;
}

// Function to check if the left AirPod is charging
function isChargingLeft() {
    return isLeftCharging;
}

// Function to get the battery percentage of the right AirPod
function getRightCharge() {
    return rightCharge;
}

// Function to check if the right AirPod is charging
function isChargingRight() {
    return isRightCharging;
}

// Function to get the battery percentage of the AirPods case
function getCaseCharge() {
    return caseCharge;
}

// Function to check if the AirPods case is charging
function isChargingCase() {
    return isCaseCharging;
}

// Function to get the AirPods model
function getAirPodsModel() {
    return airPodsModel;
}

// Function to get the timestamp of the last battery status update as raw string from backend
function getLastUpdated() {
    return lastUpdated;
}

// Function to get the timestamp of the last battery status update as date object
function getLastUpdatedDate() {
    var parts = lastUpdated.split(" "); // Split the string
    var dateParts = parts[0].split("-"); // Split the date
    var timeParts = parts[1].split(":"); // Split the time
    return new Date(
        dateParts[0],            // Year
        dateParts[1] - 1,        // Month (0-based)
        dateParts[2],            // Day
        timeParts[0],            // Hours
        timeParts[1],            // Minutes
        timeParts[2]             // Seconds
    );
}

// Function to check if a specified file exists
function fileExists(outPutFile) {
    if (outPutFile) {
        var request = new XMLHttpRequest();
        request.open('GET', outPutFile, false);
        request.send();
        return request.status == 200;
    } else {
        return false;
    }
}

// Function to check if an auto-start configuration is set
function isAutoStartSet() {
    return fileExists('../../../../../../../.config/autostart/run.sh.desktop');
}

// Function to update the AirPods battery status by reading data from a file
function updateBatteryStatus(outPutFile, refRawValue = "-1") {
    try {
        var request = new XMLHttpRequest();
        request.open("GET", outPutFile, false);
        request.send(null);

        // Check if the request was successful
        if (request.status === 200) {
            var lines = request.responseText.trim().split("\n");
            var lastLine = lines[lines.length - 1];

            try {
                var jsonData = JSON.parse(lastLine);

                // Check if the raw value matches the reference (if refRawValue is provided)
                if (refRawValue != "-1") {
                    var firstFourRaw = jsonData.raw.substring(0, 8);
                    if (firstFourRaw != refRawValue) {
                        return; // Exit the function if the raw data doesn't match the reference value
                    }
                }

                // Exit the function if the model is AirPodsMax
                if (jsonData.model == "AirPodsMax") {
                    return;
                }

                var tmpLC = jsonData.charge.left;
                var tmpRC = jsonData.charge.right;

                // Ensure both left and right charges are valid numbers and not -1
                if (isFinite(tmpLC) && isFinite(tmpRC) && tmpLC != -1 && tmpRC != -1) {
                    var average = (jsonData.charge.left + jsonData.charge.right) / 2;

                    averageCharge = Math.round(average);

                    leftCharge = jsonData.charge.left;
                    isLeftCharging = jsonData.charging_left;

                    rightCharge = jsonData.charge.right;
                    isRightCharging = jsonData.charging_right;

                    // Update case charge only if it is a valid value (-1 means no data)
                    caseCharge = jsonData.charge.case == -1 ? caseCharge : jsonData.charge.case;
                    isCaseCharging = jsonData.charging_case;

                    airPodsModel = jsonData.model;

                    lastUpdated = jsonData.date;
                }
            } catch (e) {
                console.log(e);
            }
        } else {
            console.log("Error fetching battery status");
        }
    } catch (e) {
        env = false;
        console.log(e);
    }
}

// Function to determine if the environment is set
function isEnvSet() {
    updateBatteryStatus("../../airstatus.out", "000000");
    return env;
}
