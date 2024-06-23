#!/bin/bash

# Install .NET SDK (both LTS and Latest versions)

echo "Installing .NET SDK..."

# Install prerequisites
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl

# Detect architecture
ARCH=$(uname -m)
case ${ARCH} in
    x86_64) ARCH_SUFFIX="x64" ;;
    aarch64) ARCH_SUFFIX="arm64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Download the installation script
curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh

# Install LTS version (Long Term Support)
echo "Installing .NET SDK LTS version..."
/tmp/dotnet-install.sh --channel LTS --install-dir /usr/share/dotnet

# Install STS version (Standard Term Support - latest)
echo "Installing .NET SDK STS (latest) version..."
/tmp/dotnet-install.sh --channel STS --install-dir /usr/share/dotnet

# Add dotnet to PATH and create symlinks
ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet

# Export DOTNET_ROOT
export DOTNET_ROOT=/usr/share/dotnet
echo "export DOTNET_ROOT=/usr/share/dotnet" >> /etc/environment

# Enable .NET CLI telemetry opt-out
export DOTNET_CLI_TELEMETRY_OPTOUT=1
echo "export DOTNET_CLI_TELEMETRY_OPTOUT=1" >> /etc/environment

# Clean up
rm -f /tmp/dotnet-install.sh

# Verify installation
echo "Verifying .NET SDK installation..."
if ! command -v dotnet &> /dev/null; then
    echo "ERROR: dotnet command not found after installation"
    exit 1
fi

echo "Default .NET SDK version:"
dotnet --version

echo ""
echo "All installed .NET SDKs:"
dotnet --list-sdks

echo ""
echo "All installed .NET Runtimes:"
dotnet --list-runtimes

echo ""
echo ".NET SDK installation completed successfully!"