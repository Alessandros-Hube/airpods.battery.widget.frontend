# AirPods Battery Widget Frontend for Plasma

This project is a fully customizable Plasma widget designed to display the battery status of AirPods in the KDE Plasma environment. The widget allows you to configure various aspects, such as the backend script, font size, font color, icon size and visibility of different components.

# Features

- Battery Status Display: Shows the battery levels of connected AirPods.
- Fully Customizable: Change font size, colors, icon sizes, and the visibility of various components.
- Multiple Backend Options: Use the default backend script or an alternative script.
- Clear Feedback Messages: Provides helpful messages and instructions to guide you during setup and configuration.

# Supported Devices

- Fully Supported:
    - AirPods Gen. 1
    - AirPods Gen. 2
    - AirPods Gen. 3
    - AirPods Pro Gen. 1

- Partially Supported:
    - AirPods Pro Gen. 2 and AirPods Gen. 4:
        - These devices are not fully recognized by the backend script. While the battery levels are displayed correctly, the model name may appear as "unknown."
        - You can manually update the title using the Appearance category in the widget settings.

    - Not Supported:
        - AirPods Max: This widget does not support AirPods Max.

# Setup Instructions

- Clone or Download: Clone or download the widget repository.
- Place in Plasma Widgets Folder: Move the widget into your Plasma widgets directory: ~/.local/share/plasma/plasmoids/.
- Add to Plasma Panel or Desktop: Add the widget to your Plasma panel or desktop as you would with any other Plasma widget.
- Open Widget Settings: Right-click on the widget and select Configure to open the settings interface.
- Configure Options: Use the settings to select your backend, configure optimization, and adjust appearance settings (font size, color, icons, etc.).
- Follow Setup Instructions: Ensure the environment is configured correctly, and if using the default script, add it to your system’s autostart.

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

## Optimizing Battery Data

Enable the Backend Optimizer to refine how battery data is displayed. If enabled, enter the first 8 digits of the raw value to only show the battery level that matches this value.
Autostart Backend Script (for Default Script)

# Why Might the Title Be Unknown?

If the AirPods model is not recognized (e.g., AirPods Pro Gen. 2 or AirPods Gen. 4), the widget will display the title as "unknown." This is because the backend script (based on AirStatus) currently distinguishes only between the following models:

- AirPods Gen. 1
- AirPods Gen. 2
- AirPods Gen. 3
- AirPods Pro Gen. 1

For newer or unsupported models, the backend script cannot identify the specific model, though battery levels will still be accurate.

To address this:

- Manual Customization: Change the title using the Custom Title option in the Appearance settings category.
- Icon Customization: Modify the default icon for unknown devices in the Icons settings category.

# Troubleshooting

- Environment Not Configured: Ensure you have set the environment variable **QML_XHR_ALLOW_FILE_READ=1** as mentioned in the environment setup instructions.
- Backend Script Missing: Make sure that either the default backend script is added to autostart or that an alternative backend script is properly configured with the correct output file path.
- Output File Path Doesn't Exist: If using an alternative backend script, double-check that the file path to the output file exists and is correct.

# License

This project is licensed under the GPL License - see the [LICENSE](https://github.com/Alessandros-Hube/airpods.battery.widget.frontend/blob/main/LICENSE) file for details.