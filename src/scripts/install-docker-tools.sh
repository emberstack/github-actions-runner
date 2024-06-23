#!/bin/bash

# Install Docker Compose plugin
# Note: Docker Buildx is already available in the base image

echo "Installing Docker tools..."

# Install prerequisites
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl

# Docker and Docker Buildx are already installed in the base image
# We only need to install the Docker Compose plugin

# Install Docker Compose plugin
echo "Installing Docker Compose plugin..."
DOCKER_CONFIG=${DOCKER_CONFIG:-/usr/local/lib/docker}
mkdir -p $DOCKER_CONFIG/cli-plugins

# Get latest compose version
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
if [ -z "$COMPOSE_VERSION" ]; then
    echo "Failed to get Docker Compose version, using fallback"
    COMPOSE_VERSION="2.32.4"
fi

# Detect architecture
ARCH=$(uname -m)
case ${ARCH} in
    x86_64) ARCH_SUFFIX="x86_64" ;;
    aarch64) ARCH_SUFFIX="aarch64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Download Docker Compose
curl -SL "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-${ARCH_SUFFIX}" -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Create symlinks for backward compatibility
ln -sf $DOCKER_CONFIG/cli-plugins/docker-compose /usr/local/bin/docker-compose

# Verify installations
echo "Verifying Docker tools installation..."

# Check Docker Compose plugin
if [ -f "$DOCKER_CONFIG/cli-plugins/docker-compose" ]; then
    echo "Docker Compose plugin installed successfully"
    ls -la $DOCKER_CONFIG/cli-plugins/docker-compose
else
    echo "ERROR: Docker Compose plugin not found at $DOCKER_CONFIG/cli-plugins/docker-compose"
    exit 1
fi

# Check the symlink
if [ -L "/usr/local/bin/docker-compose" ]; then
    echo "docker-compose symlink created successfully"
else
    echo "WARNING: docker-compose symlink not created"
fi

# Verify Docker Buildx is available (should be pre-installed)
echo ""
echo "Verifying pre-installed Docker Buildx..."
if command -v docker &> /dev/null && docker buildx version &> /dev/null; then
    echo "Docker Buildx is available (pre-installed in base image):"
    docker buildx version
else
    echo "WARNING: Docker Buildx not found (should be pre-installed)"
fi

echo ""
echo "Docker tools installation completed successfully!"