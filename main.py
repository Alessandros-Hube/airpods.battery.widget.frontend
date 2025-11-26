from bleak import BleakScanner
from asyncio import new_event_loop, set_event_loop, get_event_loop
from binascii import hexlify
from json import dumps
from sys import argv
from datetime import datetime

# Configure update duration (update after n seconds)
MIN_RSSI = -60
AIRPODS_MANUFACTURER = 76
AIRPODS_DATA_LENGTH = 54


def airpods_filter(device, adv):
    # Check RSSI
    if adv.rssi is None or adv.rssi < MIN_RSSI:
        return False

    # Check ManufacturerData
    man = adv.manufacturer_data
    if AIRPODS_MANUFACTURER not in man:
        return False

    return True


# Getting data with hex format
async def get_device():
    # Scanning for devices
    device = await BleakScanner.find_device_by_filter(airpods_filter, timeout=10)

    if device is None:
        return False

    data_hex = hexlify(
        bytearray(device.details["props"]["ManufacturerData"][AIRPODS_MANUFACTURER])
    )

    if len(data_hex) == AIRPODS_DATA_LENGTH:
        return data_hex

    return False


# Same as get_device() but it's standalone method instead of async
def get_data_hex():
    new_loop = new_event_loop()
    set_event_loop(new_loop)
    loop = get_event_loop()
    a = loop.run_until_complete(get_device())
    loop.close()
    return a


# Getting data from hex string and converting it to dict(json)
def get_data():
    raw = get_data_hex()

    # Return blank data if airpods not found
    if not raw:
        return dict(status=0, model="AirPods not found")

    flip: bool = is_flipped(raw)

    # On 7th position we can get AirPods model, gen1, gen2, Pro or Max
    if chr(raw[7]) == "e":
        model = "AirPodsPro"
    elif chr(raw[7]) == "4":
        model = "AirPodsPro2"
    elif chr(raw[7]) == "3":
        model = "AirPods3"
    elif chr(raw[7]) == "f":
        model = "AirPods2"
    elif chr(raw[7]) == "2":
        model = "AirPods1"
    elif chr(raw[7]) == "a":
        model = "AirPodsMax"
    else:
        model = "unknown"

    # Checking left AirPod for availability and storing charge in variable
    status_tmp = int("" + chr(raw[12 if flip else 13]), 16)
    left_status = (
        100 if status_tmp == 10 else (status_tmp * 10 + 5 if status_tmp <= 10 else -1)
    )

    # Checking right AirPod for availability and storing charge in variable
    status_tmp = int("" + chr(raw[13 if flip else 12]), 16)
    right_status = (
        100 if status_tmp == 10 else (status_tmp * 10 + 5 if status_tmp <= 10 else -1)
    )

    # Checking AirPods case for availability and storing charge in variable
    status_tmp = int("" + chr(raw[15]), 16)
    case_status = (
        100 if status_tmp == 10 else (status_tmp * 10 + 5 if status_tmp <= 10 else -1)
    )

    # On 14th position we can get charge status of AirPods
    charging_status = int("" + chr(raw[14]), 16)
    charging_left: bool = (charging_status & (0b00000010 if flip else 0b00000001)) != 0
    charging_right: bool = (charging_status & (0b00000001 if flip else 0b00000010)) != 0
    charging_case: bool = (charging_status & 0b00000100) != 0

    # Return result info in dict format
    return dict(
        status=1,
        charge=dict(left=left_status, right=right_status, case=case_status),
        charging_left=charging_left,
        charging_right=charging_right,
        charging_case=charging_case,
        model=model,
        date=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        raw=raw.decode("utf-8"),
    )


# Return if left and right is flipped in the data
def is_flipped(raw):
    return (int("" + chr(raw[10]), 16) & 0x02) == 0


def run():
    output_file = argv[-1]

    data = get_data()

    if data["status"] == 1:
        json_data = dumps(data)
        if len(argv) > 1:
            f = open(output_file, "a")
            f.write(json_data + "\n")
            f.close()
        else:
            print(json_data)


if __name__ == "__main__":
    run()
