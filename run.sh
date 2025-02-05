#!/bin/bash

cd ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend

python3 -m venv .

./bin/pip3 install -r requirements.txt

while true; do
    ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/bin/python3 ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/main.py ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/airstatus.out
    sleep 30  # 30 seconds equals 1 minute
done
