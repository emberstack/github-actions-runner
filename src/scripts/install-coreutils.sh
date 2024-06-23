#!/bin/bash

# Install/ensure coreutils (GNU Core Utilities)

echo "Installing/verifying GNU coreutils..."

# Install coreutils package (likely already installed, but ensure it's there)
apt-get update
apt-get install -y --no-install-recommends coreutils

# Verify some key coreutils commands
echo "Verifying coreutils installation..."

# Check for some essential coreutils commands
CORE_COMMANDS=(
    "ls"
    "cp"
    "mv"
    "rm"
    "cat"
    "echo"
    "head"
    "tail"
    "sort"
    "uniq"
    "wc"
    "date"
    "whoami"
    "sha256sum"
    "base64"
    "realpath"
    "timeout"
    "stat"
    "dd"
    "tr"
)

echo "Checking essential coreutils commands..."
for cmd in "${CORE_COMMANDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "ERROR: $cmd command not found after installation"
        exit 1
    fi
done

# Display coreutils version
echo ""
echo "Coreutils version:"
ls --version | head -1

# Show package info
echo ""
echo "Coreutils package info:"
dpkg -l | grep coreutils || echo "Package info not available"

echo ""
echo "GNU coreutils installation completed successfully!"
echo "Total commands checked: ${#CORE_COMMANDS[@]}"