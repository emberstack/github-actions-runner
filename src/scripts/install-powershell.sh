#!/bin/bash

# Install PowerShell following official documentation
# https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu

# Detect architecture
ARCH=$(uname -m)

if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo "Installing PowerShell for ARM64 architecture..."
    
    # For ARM64, we need to download the tar.gz package directly
    # Get the latest release info
    PWSH_VERSION=$(curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    if [ -z "$PWSH_VERSION" ]; then
        echo "Failed to get PowerShell version, using fallback version"
        PWSH_VERSION="7.4.6"
    fi
    
    echo "Installing PowerShell version: $PWSH_VERSION"
    
    # Download PowerShell for ARM64
    wget -q "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-arm64.tar.gz" -O /tmp/powershell.tar.gz
    
    # Create directory for PowerShell
    mkdir -p /opt/microsoft/powershell/7
    
    # Extract PowerShell
    tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
    
    # Set execute permissions
    chmod +x /opt/microsoft/powershell/7/pwsh
    
    # Create symlinks
    ln -sf /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
    ln -sf /opt/microsoft/powershell/7/pwsh /usr/bin/powershell
    
    # Clean up
    rm /tmp/powershell.tar.gz
    
else
    echo "Installing PowerShell for x86_64 architecture..."
    
    # For x86_64, use the standard repository method
    # Update packages and install required dependencies
    apt-get update
    apt-get install -y --no-install-recommends \
        wget \
        apt-transport-https \
        software-properties-common \
        lsb-release
    
    # Detect Ubuntu version
    UBUNTU_VERSION=$(lsb_release -rs)
    
    # Download the Microsoft repository GPG keys
    wget -q "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VERSION}/packages-microsoft-prod.deb"
    
    # Register the Microsoft repository GPG keys
    dpkg -i packages-microsoft-prod.deb
    
    # Delete the Microsoft repository GPG keys file
    rm packages-microsoft-prod.deb
    
    # Update the list of packages after we added packages.microsoft.com
    apt-get update
    
    # Install PowerShell
    apt-get install -y powershell
fi

# Create a symbolic link for 'powershell' command
ln -sf /usr/bin/pwsh /usr/bin/powershell

# Verify installation
echo "Verifying PowerShell installation..."
if ! command -v pwsh &> /dev/null; then
    echo "ERROR: pwsh command not found after installation"
    exit 1
fi

if ! command -v powershell &> /dev/null; then
    echo "ERROR: powershell symlink not created properly"
    exit 1
fi

echo "PowerShell version:"
pwsh --version

echo "PowerShell installation completed successfully!"