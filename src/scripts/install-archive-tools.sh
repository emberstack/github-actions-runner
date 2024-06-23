#!/bin/bash

# Install archive and compression tools

echo "Installing archive tools..."

# Install archive-related packages
apt-get update
apt-get install -y --no-install-recommends \
    p7zip-full \
    zip

# Note: p7zip-rar is not available in standard Ubuntu repositories
# and requires multiverse repository which may not be available on all architectures
# tar and unzip are already installed in base image

# Verify installations
echo ""
echo "Verifying archive tools installation..."

# Check tar (should already exist)
if ! command -v tar &> /dev/null; then
    echo "ERROR: tar command not found"
    exit 1
fi
echo "tar available:"
tar --version | head -1

# Check zip
if ! command -v zip &> /dev/null; then
    echo "ERROR: zip command not found after installation"
    exit 1
fi
echo "zip available:"
zip -v | head -2 | tail -1

# Check unzip (should already exist)
if ! command -v unzip &> /dev/null; then
    echo "ERROR: unzip command not found"
    exit 1
fi
echo "unzip available:"
unzip -v | head -1

# Check 7z
if ! command -v 7z &> /dev/null; then
    echo "ERROR: 7z command not found after installation"
    exit 1
fi
echo "7z available:"
7z | head -2 | tail -1

# Check if p7zip is available
if command -v p7zip &> /dev/null; then
    echo "p7zip available"
else
    echo "Note: p7zip command not available (7z command is the main interface)"
fi

echo ""
echo "Archive tools installation completed successfully!"