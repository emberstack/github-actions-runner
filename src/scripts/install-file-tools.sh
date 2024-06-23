#!/bin/bash

# Install file utilities and analysis tools

echo "Installing file utilities..."

# Install file-related packages
apt-get update
apt-get install -y --no-install-recommends \
    file \
    findutils \
    tree \
    time

# Verify installations
echo ""
echo "Verifying file utilities installation..."

if ! command -v file &> /dev/null; then
    echo "ERROR: file command not found after installation"
    exit 1
fi
echo "file command available:"
file --version | head -1

if ! command -v find &> /dev/null; then
    echo "ERROR: find command not found after installation"
    exit 1
fi
echo "find command available"

if ! command -v tree &> /dev/null; then
    echo "ERROR: tree command not found after installation"
    exit 1
fi
echo "tree command available:"
tree --version

if ! command -v time &> /dev/null; then
    echo "ERROR: time command not found after installation"
    exit 1
fi
echo "time command available"

echo ""
echo "File utilities installation completed successfully!"