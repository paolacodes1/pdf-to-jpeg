#!/bin/bash

# Get the directory where this app is located
APP_DIR="$(dirname "$(dirname "$(dirname "$0")")")"
SCRIPT_DIR="$APP_DIR/Contents/Resources"

# Apps opened from Finder don't get Homebrew on PATH (needed for poppler)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Private Python environment for this app, created on first run
VENV="$HOME/Library/Application Support/PDF to JPEG/venv"
if [ ! -x "$VENV/bin/python" ] || ! "$VENV/bin/python" -c "import pdf2image" 2>/dev/null; then
    osascript -e 'display notification "Setting up for first use…" with title "PDF to JPEG"'
    mkdir -p "$(dirname "$VENV")"
    python3 -m venv "$VENV" && "$VENV/bin/python" -m pip install --quiet pdf2image
    if ! "$VENV/bin/python" -c "import pdf2image" 2>/dev/null; then
        osascript -e 'display alert "PDF to JPEG" message "Could not install pdf2image. Check your internet connection and try again." as warning'
        exit 1
    fi
fi

# Use AppleScript to show file picker
PDF_FILE=$(osascript -e 'tell application "System Events"
    activate
    set theFile to choose file with prompt "Select a PDF to convert to JPEG" of type {"pdf"}
    return POSIX path of theFile
end tell' 2>/dev/null)

# Exit if user cancelled
if [ -z "$PDF_FILE" ]; then
    exit 0
fi

# Ask where to save the images
OUTPUT_DIR=$(osascript -e 'tell application "System Events"
    activate
    set theFolder to choose folder with prompt "Select folder to save JPEG images"
    return POSIX path of theFolder
end tell' 2>/dev/null)

# If cancelled, save in same folder as PDF
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR=$(dirname "$PDF_FILE")
fi

# Run the Python script
cd "$SCRIPT_DIR"
"$VENV/bin/python" pdf_to_jpeg.py "$PDF_FILE" "$OUTPUT_DIR" 2>&1

# Show completion message
RESULT=$?
if [ $RESULT -eq 0 ]; then
    osascript -e "display notification \"PDF converted successfully!\" with title \"PDF to JPEG\""
    # Open the output folder
    open "$OUTPUT_DIR"
else
    osascript -e "display alert \"Error\" message \"Failed to convert PDF. Check if the file is valid.\" as warning"
fi
