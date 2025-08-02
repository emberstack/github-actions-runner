#!/bin/bash
set -e

# Switch to runner user home directory
cd /home/runner

# Function to handle runner cleanup
cleanup_runner() {
    echo "Attempting to remove existing runner configuration..."
    if [ -n "${GITHUB_RUNNER_PAT}" ]; then
        ./config.sh remove --pat "${GITHUB_RUNNER_PAT}" || true
    elif [ -n "${GITHUB_RUNNER_TOKEN}" ]; then
        ./config.sh remove --token "${GITHUB_RUNNER_TOKEN}" || true
    else
        echo "No PAT or TOKEN provided for runner removal, skipping cleanup"
    fi
}

# Function to configure runner
configure_runner() {
    echo "Configuring GitHub Actions runner..."
    
    # Build configuration command
    CONFIG_CMD="./config.sh --url \"${GITHUB_RUNNER_URL}\" --unattended --replace"
    
    # Add authentication (prefer PAT over TOKEN)
    if [ -n "${GITHUB_RUNNER_PAT}" ]; then
        CONFIG_CMD="${CONFIG_CMD} --pat \"${GITHUB_RUNNER_PAT}\""
    elif [ -n "${GITHUB_RUNNER_TOKEN}" ]; then
        CONFIG_CMD="${CONFIG_CMD} --token \"${GITHUB_RUNNER_TOKEN}\""
    else
        echo "ERROR: Either GITHUB_RUNNER_PAT or GITHUB_RUNNER_TOKEN must be provided"
        exit 1
    fi
    
    # Add runner name (use hostname as default)
    if [ -n "${GITHUB_RUNNER_NAME}" ]; then
        CONFIG_CMD="${CONFIG_CMD} --name \"${GITHUB_RUNNER_NAME}\""
    else
        CONFIG_CMD="${CONFIG_CMD} --name \"$(hostname)\""
    fi
    
    # Add labels if provided
    if [ -n "${GITHUB_RUNNER_LABELS}" ]; then
        CONFIG_CMD="${CONFIG_CMD} --labels \"${GITHUB_RUNNER_LABELS}\""
    fi
    
    # Add runner group if provided
    if [ -n "${GITHUB_RUNNER_GROUP}" ]; then
        CONFIG_CMD="${CONFIG_CMD} --runnergroup \"${GITHUB_RUNNER_GROUP}\""
    fi
    
    # Add work directory if provided
    if [ -n "${GITHUB_RUNNER_WORKDIR}" ]; then
        CONFIG_CMD="${CONFIG_CMD} --work \"${GITHUB_RUNNER_WORKDIR}\""
    fi
    
    # Execute configuration
    eval ${CONFIG_CMD}
}

# Function to setup groups
setup_groups() {
    # Handle custom GID if specified
    if [ -n "${GITHUB_RUNNER_GID}" ]; then
        echo "Creating github-actions-runner group with GID ${GITHUB_RUNNER_GID}..."
        sudo groupadd -f -g ${GITHUB_RUNNER_GID} github-actions-runner || true
        sudo usermod -aG github-actions-runner runner
        echo "Added runner user to github-actions-runner group"
    fi
    
    # Handle Docker socket access if requested
    if [ "${GITHUB_RUNNER_DOCKER_SOCK}" = "true" ]; then
        if [ -S /var/run/docker.sock ]; then
            DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
            echo "Docker socket detected with GID ${DOCKER_GID}"
            echo "Creating github-actions-runner-dockersock group..."
            sudo groupadd -f -g ${DOCKER_GID} github-actions-runner-dockersock || true
            sudo usermod -aG github-actions-runner-dockersock runner
            echo "Added runner user to github-actions-runner-dockersock group"
        else
            echo "WARNING: GITHUB_RUNNER_DOCKER_SOCK=true but /var/run/docker.sock not found"
        fi
    fi
}

# Main execution
main() {
    # Validate required environment variables
    if [ -z "${GITHUB_RUNNER_URL}" ]; then
        echo "ERROR: GITHUB_RUNNER_URL environment variable is required"
        echo "Example: https://github.com/myorg/myrepo"
        exit 1
    fi
    
    # Setup groups if needed
    setup_groups
    
    # Cleanup any existing runner configuration
    cleanup_runner
    
    # Configure the runner
    configure_runner
    
    # Start the runner
    echo "Starting GitHub Actions runner..."
    exec ./run.sh
}

# Execute main function
main