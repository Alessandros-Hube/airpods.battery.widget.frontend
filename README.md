# AirPods Battery Widget Frontend for Plasma

This project is a fully customizable Plasma widget designed to display the battery status of AirPods in the KDE Plasma environment. The widget allows you to configure various aspects, such as the font size, font color, icon size and visibility of different components.

# Features

- Battery Status Display: Shows the battery levels of connected AirPods.
- Fully Customizable: Change font size, colors, icon sizes, and the visibility of various components.
- Clear Feedback Messages: Provides helpful messages and instructions to guide you during setup and configuration.

# Supported Devices

- Fully Supported:
    - AirPods Gen. 1
    - AirPods Gen. 2
    - AirPods Gen. 3
    - AirPods Pro Gen. 1
    - AirPods Pro Gen. 2

- Partially Supported:
    - AirPods Pro Gen. 3 and AirPods Gen. 4:
        - These devices are not fully recognized by the backend script. While the battery levels are displayed correctly, the model name may appear as "unknown."
        - You can manually update the title using the Appearance category in the widget settings.

- Not Supported:
    - AirPods Max and AirPods Max 2: This widget does not support AirPods Max.

# Setup Instructions

- Clone or Download: Clone or download the widget repository.
- Place in Plasma Widgets Folder: Move the widget into your Plasma widgets directory: ~/.local/share/plasma/plasmoids/.
- Add to Plasma Panel or Desktop: Add the widget to your Plasma panel or desktop as you would with any other Plasma widget.
- Open Widget Settings: Right-click on the widget and select Configure to open the settings interface.
- Follow Setup Instructions: Make sure the backend service is set up correctly.

## Backend Service

To enable the backend service, follow these steps:


- Install the required system dependencies by opening a terminal and running the command for your distribution:
### Fedora:
```
sudo dnf install -y gcc glib2-devel dbus-devel python3-devel pkg-config cmake make cairo-devel gobject-introspection-devel gtk3-devel pango-devel python3-virtualenv
```
### Debian/Ubuntu:
```
sudo apt install -y gcc libglib2.0-dev libdbus-1-dev python3-dev pkg-config cmake make libcairo2-dev libgirepository1.0-dev libgtk-3-dev libpango1.0-dev python3-venv
```
### Arch:
```
sudo pacman -S --needed gcc glib2 dbus python pkg-config cmake make cairo gobject-introspection gtk3 pango python-virtualenv
```

- Open the **user** folder:
- **~/.config/systemd/user**
- Open the widget **source** folder:
- **~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend**
- Copy the **airPodsBatteryWidget.service** file from the widget **source** folder into the **user** folder.
- Open a terminal and run the following commands:
```
systemctl --user daemon-reload
systemctl --user enable --now airPodsBatteryWidget.service
```


# Why Might the Title Be Unknown?

If the AirPods model is not recognized (e.g., AirPods Pro Gen. 3 or AirPods Gen. 4), the widget will display the title as "unknown." This is because the backend script (based on AirStatus) currently distinguishes only between the following models:

- AirPods Gen. 1
- AirPods Gen. 2
- AirPods Gen. 3
- AirPods Pro Gen. 1
- AirPods Pro Gen. 2

For newer or unsupported models, the backend script cannot identify the specific model, though battery levels will still be accurate.

To address this:

- Manual Customization: Change the title using the Custom Title option in the Appearance settings category.
- Icon Customization: Modify the default icon for unknown devices in the Icons settings category.


# License

This project is licensed under the GPL License - see the [LICENSE](https://github.com/Alessandros-Hube/airpods.battery.widget.frontend/blob/main/LICENSE) file for details.