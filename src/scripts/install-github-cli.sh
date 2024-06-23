#!/bin/bash

# Install GitHub CLI (gh)

echo "Installing GitHub CLI..."

# Install prerequisites
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg

# Add GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Update and install gh
apt-get update
apt-get install -y gh

# Verify installation
echo "Verifying GitHub CLI installation..."
if ! command -v gh &> /dev/null; then
    echo "ERROR: gh command not found after installation"
    exit 1
fi
echo "GitHub CLI version:"
gh --version

echo "GitHub CLI installation completed successfully!"