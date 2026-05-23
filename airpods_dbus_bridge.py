import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib
import logging
from main import get_data

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("AirPodsBattery")

DBUS_DEST = "airpods.battery.widget.frontend"
DBUS_PATH = "/airpods/battery/widget/frontend"
DBUS_IFACE = "airpods.battery.widget.frontend"


class AirPodsService(dbus.service.Object):
    def __init__(self, bus):
        super().__init__(bus, DBUS_PATH)
        self._data = {"status": 0, "model": "AirPods not found"}

    def update(self):
        log.info("Searching device ...")
        try:
            self._data = get_data()
            if self._data["status"] == 1:
                log.info(
                    "Got data: %s | L:%s%% R:%s%% Case:%s%% | date:%s | raw:%s",
                    self._data["model"],
                    self._data["charge"]["left"],
                    self._data["charge"]["right"],
                    self._data["charge"]["case"],
                    self._data["date"],
                    self._data["raw"],
                )
            else:
                log.warning("AirPods not found")
        except Exception as e:
            log.error(e.args)
        return True

    @dbus.service.method(DBUS_IFACE, in_signature="", out_signature="a{sv}")
    def GetBattery(self):
        d = self._data
        if d["status"] == 0:
            return {"status": dbus.String(0), "model": dbus.String(d["model"])}
        ch = d["charge"]
        return {
            "status": dbus.String(d["status"]),
            "model": dbus.String(d["model"]),
            "left": dbus.String(ch["left"]),
            "right": dbus.String(ch["right"]),
            "case": dbus.String(ch["case"]),
            "charging_left": dbus.String(d["charging_left"]),
            "charging_right": dbus.String(d["charging_right"]),
            "charging_case": dbus.String(d["charging_case"]),
            "date": dbus.String(d["date"]),
            "raw": dbus.String(d["raw"]),
        }


if __name__ == "__main__":
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()
    bus_name = dbus.service.BusName(DBUS_DEST, bus)
    service = AirPodsService(bus)

    service.update()
    GLib.timeout_add_seconds(10, service.update)

    GLib.MainLoop().run()
