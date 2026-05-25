# Setup Instructions (old)

This is the instruction for the old backend, however this is not recommended and the option will be removed in a future update.

## Environment Setup (Required)

To enable QML to read files, set up your environment as follows:

- Navigate to **~/.config/plasma-workspace/env/**
- Create a new file called **set-env.sh** if it does not exist.
- Add the following line to the file: **export QML_XHR_ALLOW_FILE_READ=1**
- Log out and log back into your current session, or reboot your system.

## Backend Options

You can choose between two backend options for the widget:

- Default Widget Script: This script is based on the [AirStatus](https://github.com/delphiki/AirStatus) GitHub repository and is located in the widget’s source folder.
- Alternative Script: You can provide the path to your own script, which should output battery data in a specific JSON format. You can also specify a custom output file.

To automatically run the default backend script upon login:

- Open **System Settings → Autostart**.
- Click **Add New** and choose **Login Script**.
- Navigate to the widget's source folder: **~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend**
- Select **run.sh** and double-click it.
- Log out and log back in, or reboot your system.