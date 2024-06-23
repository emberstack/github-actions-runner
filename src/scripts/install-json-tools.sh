#!/bin/bash

# Verify JSON/YAML tools
# Note: Both jq and yq are already available
# - jq is pre-installed in the base image
# - yq is installed in the Dockerfile

echo "Verifying JSON/YAML tools..."

# Verify jq is available (pre-installed in base image)
echo "Checking jq installation..."
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq command not found (should be pre-installed)"
    exit 1
fi
echo "jq version:"
jq --version

# Verify yq is available (installed in Dockerfile)
echo ""
echo "Checking yq installation..."
if ! command -v yq &> /dev/null; then
    echo "ERROR: yq command not found"
    exit 1
fi
echo "yq version:"
yq --version

echo ""
echo "JSON/YAML tools verification completed successfully!"