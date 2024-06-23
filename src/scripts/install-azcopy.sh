#!/bin/bash

# Detect architecture and set download URL
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    AZCOPY_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    AZCOPY_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Get the latest release info from GitHub API
echo "Fetching latest AzCopy release info..."
RELEASE_INFO=$(curl -s https://api.github.com/repos/Azure/azure-storage-azcopy/releases/latest)
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -o "https://[^\"]*azcopy_linux_${AZCOPY_ARCH}_[^\"]*\.tar\.gz" | head -1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Failed to find download URL for architecture: $AZCOPY_ARCH"
    exit 1
fi

echo "Downloading AzCopy from: $DOWNLOAD_URL"
wget -O azcopy.tar.gz "$DOWNLOAD_URL"

# Extract directly to /usr/local/bin
tar zxf azcopy.tar.gz --strip-components=1 -C /usr/local/bin --wildcards "*/azcopy"
chmod +x /usr/local/bin/azcopy
ln -sf /usr/local/bin/azcopy /usr/local/bin/azcopy10

# Cleanup
rm -f azcopy.tar.gz

# Verify installation
echo "Verifying AzCopy installation..."
if ! command -v azcopy &> /dev/null; then
    echo "ERROR: azcopy command not found after installation"
    exit 1
fi

if ! command -v azcopy10 &> /dev/null; then
    echo "ERROR: azcopy10 symlink not created properly"
    exit 1
fi

echo "AzCopy version:"
azcopy --version
azcopy10 --version

echo "AzCopy installation completed successfully!"