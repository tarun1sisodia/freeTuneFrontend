#!/bin/bash
# Install dependencies for just_audio_media_kit on Linux using apt (Debian/Ubuntu)

echo "Installing dependencies for just_audio_media_kit..."

if [ -f /etc/debian_version ]; then
    sudo apt-get update
    sudo apt-get install -y libmpv-dev mpv
    echo "Dependencies installed successfully."
else
    echo "Unsupported distribution. Please install 'libmpv-dev' and 'mpv' manually."
    exit 1
fi
