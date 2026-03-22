#!/bin/bash
# Install script for Spiking Neural Network Screensaver
set -e

INSTALL_DIR="$HOME/.screensavers"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing Spiking Neural Network Screensaver..."

# Check dependencies
echo "Checking dependencies..."
MISSING=""
python3 -c "import tkinter" 2>/dev/null || MISSING="$MISSING python3-tk"
which xscreensaver >/dev/null 2>&1 || MISSING="$MISSING xscreensaver"

if [ -n "$MISSING" ]; then
    echo "Missing packages:$MISSING"
    echo "Install them with: sudo apt-get install -y$MISSING"
    read -p "Install now? [Y/n] " yn
    case $yn in
        [Nn]* ) echo "Please install dependencies manually and re-run."; exit 1;;
        * ) sudo apt-get install -y $MISSING;;
    esac
fi

# Install screensaver script
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/neural-spike" "$INSTALL_DIR/neural-spike"
chmod +x "$INSTALL_DIR/neural-spike"
echo "Installed neural-spike to $INSTALL_DIR/"

# Also install the HTML version
cp "$SCRIPT_DIR/neural_spike.html" "$INSTALL_DIR/neural_spike.html"
echo "Installed neural_spike.html to $INSTALL_DIR/"

# Configure xscreensaver if installed
if which xscreensaver >/dev/null 2>&1; then
    XSCREENSAVER_CFG="$HOME/.xscreensaver"
    ENTRY="\"$INSTALL_DIR/neural-spike\""

    if [ -f "$XSCREENSAVER_CFG" ]; then
        if grep -q "neural-spike" "$XSCREENSAVER_CFG"; then
            echo "xscreensaver already configured."
        else
            echo ""
            echo "To add to xscreensaver, add this line to the 'programs:' section"
            echo "in $XSCREENSAVER_CFG:"
            echo ""
            echo "  $ENTRY  \\n"
            echo ""
        fi
    else
        cat > "$XSCREENSAVER_CFG" << XEOF

# XScreenSaver Preferences
mode:         one
cycle:        0:10:00
timeout:      0:05:00
lock:         False
lockTimeout:  0:00:00
passwdTimeout: 0:00:30
fade:         True
unfade:       True
fadeSeconds:  0:00:03
fadeTicks:    20
dpmsEnabled:  False
grabDesktopImages: False
grabVideoFrames: False
chooseRandomImages: False

programs:                                                                     \\
              "$INSTALL_DIR/neural-spike"                                    \\n

selected:     0

XEOF
        echo "Created $XSCREENSAVER_CFG with neural-spike as default."
    fi

    # Set up autostart
    AUTOSTART_DIR="$HOME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    cat > "$AUTOSTART_DIR/xscreensaver.desktop" << AEOF
[Desktop Entry]
Type=Application
Name=XScreenSaver
Exec=xscreensaver -nosplash
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
AEOF
    echo "Configured xscreensaver autostart."
fi

echo ""
echo "Installation complete!"
echo ""
echo "To test, run:  python3 $INSTALL_DIR/neural-spike"
echo "Press Escape or move mouse to exit."
echo ""
echo "To activate via xscreensaver:"
echo "  xscreensaver -nosplash &"
echo "  xscreensaver-command -activate"
