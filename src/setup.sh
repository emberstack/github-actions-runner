#!/bin/bash
set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log with timestamp
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Function to log errors
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to log success
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Change to root directory where setup.yaml is located
cd /

# Check if setup.yaml exists
if [ ! -f "setup.yaml" ]; then
    error "setup.yaml not found in root directory"
    exit 1
fi

log "Starting setup process..."

# Parse and execute each step
# Get the number of steps
step_count=$(yq eval '.setup.steps | length' setup.yaml)

# Iterate through each step by index
for ((i=0; i<$step_count; i++)); do
    # Extract step properties
    name=$(yq eval ".setup.steps[$i].name" setup.yaml)
    script=$(yq eval ".setup.steps[$i].script" setup.yaml)
    command=$(yq eval ".setup.steps[$i].command" setup.yaml)
    description=$(yq eval ".setup.steps[$i].description" setup.yaml)
    
    log "Starting: $name"
    if [ "$description" != "null" ]; then
        log "Description: $description"
    fi
    
    # Execute based on precedence (script > command)
    if [ "$script" != "null" ]; then
        log "Executing script: $script"
        if bash -e "$script"; then
            success "Completed: $name"
        else
            error "Failed: $name (script: $script)"
            exit 1
        fi
    elif [ "$command" != "null" ]; then
        log "Executing command..."
        if bash -e -c "$command"; then
            success "Completed: $name"
        else
            error "Failed: $name"
            exit 1
        fi
    else
        error "Step '$name' has no script or command defined"
        exit 1
    fi
    
    echo ""  # Empty line between steps
done

success "All setup steps completed successfully!"