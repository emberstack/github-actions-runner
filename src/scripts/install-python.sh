#!/bin/bash

# Install pip and Python development tools
# Note: Python3 is already installed in the base image

# Update packages and install pip and development tools
apt-get update
apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    python3-dev

# Create symbolic links for pip (if not already present)
if [ ! -f /usr/bin/pip ]; then
    ln -s /usr/bin/pip3 /usr/bin/pip
fi

# Upgrade pip to latest version
python3 -m pip install --upgrade pip

# Verify installations
echo "Verifying Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 command not found after installation"
    exit 1
fi
echo "Python version:"
python3 --version

echo "Verifying pip installation..."
if ! command -v pip &> /dev/null; then
    echo "ERROR: pip command not found after installation"
    exit 1
fi
echo "pip version:"
pip --version

echo "Verifying pip3 installation..."
if ! command -v pip3 &> /dev/null; then
    echo "ERROR: pip3 command not found after installation"
    exit 1
fi
echo "pip3 version:"
pip3 --version

echo "Python and pip installation completed successfully!"