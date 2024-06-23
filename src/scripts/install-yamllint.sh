#!/bin/bash

# Install yamllint

echo "Installing yamllint..."

# yamllint is a Python package, so we'll use pip
python3 -m pip install --no-cache-dir yamllint

# Verify installation
echo "Verifying yamllint installation..."
if ! command -v yamllint &> /dev/null; then
    echo "ERROR: yamllint command not found after installation"
    exit 1
fi
echo "yamllint version:"
yamllint --version

echo "yamllint installation completed successfully!"