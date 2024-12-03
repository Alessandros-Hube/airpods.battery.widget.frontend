#!/bin/bash

while true; do
    python3 ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/main.py ~/.local/share/plasma/plasmoids/airpods.battery.widget.frontend/airstatus.out
    sleep 30  # 30 seconds equals 1 minute
done
