#!/bin/bash

# Install Node.js and npm
# Uses NodeSource official setup script

# Detect architecture
ARCH=$(uname -m)

echo "Installing Node.js and npm..."

# Install prerequisites
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl

# Use NodeSource's official setup script for Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# Install Node.js (includes npm)
apt-get install -y nodejs

# Verify Node.js installation
echo "Verifying Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "ERROR: node command not found after installation"
    exit 1
fi
echo "Node.js version:"
node --version

# Verify npm installation
echo "Verifying npm installation..."
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm command not found after installation"
    exit 1
fi
echo "npm version:"
npm --version

# Display architecture info
echo "Installed on architecture: $ARCH"

echo "Node.js and npm installation completed successfully!"