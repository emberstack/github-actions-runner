#!/bin/bash

# Install Azure CLI following official documentation
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux

# Update packages and install required dependencies
apt-get update
apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Download and install Microsoft signing key
mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null
chmod go+r /etc/apt/keyrings/microsoft.gpg

# Add Azure CLI repository using the new DEB822 format
AZ_DIST=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | tee /etc/apt/sources.list.d/azure-cli.sources

# Install Azure CLI
apt-get update
apt-get install -y azure-cli

# Verify installation
echo "Verifying Azure CLI installation..."
if ! command -v az &> /dev/null; then
    echo "ERROR: az command not found after installation"
    exit 1
fi

echo "Azure CLI version:"
az --version

echo "Azure CLI installation completed successfully!"