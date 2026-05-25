#!/bin/bash

WIDGET_DIR="$HOME/.local/share/plasma/plasmoids/airpods.battery.widget.frontend"
        
cd "$WIDGET_DIR"
        
REQUIREMENTS_FILE="requirements.txt"
VENV_DIR="venv"

needs_rebuild() {
    # If venv doesn't exist at all, rebuild
    if [ ! -d "$VENV_DIR" ]; then
        return 0
    fi

    # Check each package in requirements.txt
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue

        # Extract package name and required version (handles ~=, ==, >=, etc.)
        pkg_name=$(echo "$line" | sed 's/[~=<>!].*//' | tr '[:upper:]' '[:lower:]' | tr -d ' ')
        required_version=$(echo "$line" | grep -oP '[\d]+\.[\d]+\.?[\d]*')

        # Get installed version from venv
        installed_version=$("$VENV_DIR/bin/pip3" show "$pkg_name" 2>/dev/null | grep '^Version:' | awk '{print $2}')

        if [ -z "$installed_version" ]; then
            echo "$(date): Package '$pkg_name' not found in venv."
            return 0
        fi

        if [ "$installed_version" != "$required_version" ]; then
            echo "$(date): Version mismatch for '$pkg_name': installed=$installed_version, required=$required_version"
            return 0
        fi
    done < "$REQUIREMENTS_FILE"

    return 1
}

# Copy the widget notifyrc
if [ ! -f "$HOME/.local/share/knotifications6/airPodsBatteryWidget.notifyrc" ]; then
    echo "$(date): Copy the widget notifyrc"
    mkdir -p "$HOME/.local/share/knotifications6/"
    cp airPodsBatteryWidget.notifyrc $HOME/.local/share/knotifications6/
fi

if needs_rebuild; then
    echo "$(date): (Re)creating virtual environment..."
    rm -rf "$VENV_DIR"
    python3 -m venv "$VENV_DIR"
    ./"$VENV_DIR"/bin/pip3 install -r "$REQUIREMENTS_FILE"
else
    echo "$(date): Virtual environment is up to date."
fi
            
# Delete old files from version 1.0.1 (if any)
old_files=("pyvenv.cfg" "bin" "include" "lib" "lib64")
for file in "${old_files[@]}"; do
    if [ -e "$file" ]; then
        rm -rf "$file"
        echo "$(date): Removed old file: $file"
        fi
        done
        
# Running the main script with logging
while true; do
    ./venv/bin/python3 ./main.py ./airstatus.out
    sleep 30
done
