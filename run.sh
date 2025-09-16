#!/bin/bash

cd ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend

python3 -m venv venv

# In version 1.0.1, the backend environment was created in the widget's root directory.
# In the latest version, the environment is located inside the "venv" folder instead.
# The following lines remove old environment files from the previous version.
# These cleanup lines will be removed in future releases.

old_venv_stuff=$(find ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/pyvenv.cfg 2>/dev/null)
if [ -n "$old_venv_stuff" ]; then
    rm -r bin
    rm -r include
    rm -r lib
    rm -r lib64
    rm -f pyvenv.cfg
    echo "Remove old venv">&2 
else
    echo "fine">&2 
fi

./venv/bin/pip3 install -r requirements.txt

while true; do
    ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/venv/bin/python3 ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/main.py ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/airstatus.out
    sleep 30  # 30 seconds equals 1 minute
done
