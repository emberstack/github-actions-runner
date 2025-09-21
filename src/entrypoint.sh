#!/bin/bash
set -e

# Switch to runner user home directory
cd /home/runner

# Global variable to track if we're shutting down
SHUTTING_DOWN=false

# Signal handler for graceful shutdown
handle_shutdown() {
    local signal=$1
    
    if [ "$SHUTTING_DOWN" = "true" ]; then
        echo "Shutdown already in progress..."
        return
    fi
    
    SHUTTING_DOWN=true
    echo ""
    echo "Received $signal signal, cleaning up..."
    
    # Kill the runner process if it's running
    if [ -n "$RUNNER_PID" ]; then
        echo "Stopping runner process (PID: $RUNNER_PID)..."
        kill -TERM "$RUNNER_PID" 2>/dev/null || true
        
        # Wait for the runner to stop (max 30 seconds)
        local count=0
        while kill -0 "$RUNNER_PID" 2>/dev/null && [ $count -lt 30 ]; do
            sleep 1
            count=$((count + 1))
        done
        
        # Force kill if still running
        if kill -0 "$RUNNER_PID" 2>/dev/null; then
            echo "Force stopping runner process..."
            kill -KILL "$RUNNER_PID" 2>/dev/null || true
        fi
    fi
    
    # Remove runner configuration
    cleanup_runner
    
    echo "Cleanup completed."
    
    # Exit with proper signal code
    case "$signal" in
        INT)
            exit 130  # 128 + 2 (SIGINT)
            ;;
        TERM)
            exit 143  # 128 + 15 (SIGTERM)
            ;;
        *)
            exit 1
            ;;
    esac
}

# Set up signal handlers with proper exit codes
trap 'handle_shutdown INT' INT
trap 'handle_shutdown TERM' TERM

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
    
    # Add runner name (with hostname preference option)
    if [ "${GITHUB_RUNNER_USE_HOSTNAME}" = "true" ]; then
        # When flag is true, always use hostname regardless of GITHUB_RUNNER_NAME
        CONFIG_CMD="${CONFIG_CMD} --name \"$(hostname)\""
    elif [ -n "${GITHUB_RUNNER_NAME}" ]; then
        # Use provided name if flag is not true and name is provided
        CONFIG_CMD="${CONFIG_CMD} --name \"${GITHUB_RUNNER_NAME}\""
    else
        # Fall back to hostname if no name provided and flag is not true
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
    
    # Add ephemeral flag if requested
    if [ "${GITHUB_RUNNER_EPHEMERAL}" = "true" ]; then
        CONFIG_CMD="${CONFIG_CMD} --ephemeral"
        echo "Configuring runner in ephemeral mode (will process only one job)"
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
        sudo usermod -aG github-actions-runner runner || true
        echo "Added runner user to github-actions-runner group"
    fi

    # Handle Docker socket access if requested
    if [ "${GITHUB_RUNNER_DOCKER_SOCK}" = "true" ]; then
        if [ -S /var/run/docker.sock ]; then
            # Socket exists, determine the GID to use
            if [ -n "${GITHUB_RUNNER_DOCKER_SOCK_GID}" ]; then
                # Use explicitly configured GID
                DOCKER_GID="${GITHUB_RUNNER_DOCKER_SOCK_GID}"
                echo "Using configured Docker socket GID ${DOCKER_GID}"
            else
                # Auto-detect GID from socket
                DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
                echo "Docker socket detected with GID ${DOCKER_GID}"
            fi

            # Check if GID is 0 (root)
            if [ "${DOCKER_GID}" = "0" ]; then
                echo "WARNING: Docker socket has GID 0 (root group)."
                echo "Cannot safely add runner to root group."
                echo "Please set GITHUB_RUNNER_DOCKER_SOCK_GID to a non-root GID or handle permissions differently."
            else
                # Create group with the determined GID
                echo "Creating github-actions-runner-dockersock group with GID ${DOCKER_GID}..."
                sudo groupadd -f -g ${DOCKER_GID} github-actions-runner-dockersock || true
                sudo usermod -aG github-actions-runner-dockersock runner || true
                echo "Added runner user to github-actions-runner-dockersock group"
            fi
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
    
    # Start the runner in background to capture PID
    echo "Starting GitHub Actions runner..."

    # Use sudo to start with fresh session that has all groups
    sudo -u runner -i ./run.sh &
    RUNNER_PID=$!

    echo "Runner started with PID: $RUNNER_PID"

    # Wait for the runner process
    wait $RUNNER_PID
    RUNNER_EXIT_CODE=$?

    echo "Runner process exited with code: $RUNNER_EXIT_CODE"

    # Clean up the runner registration
    echo "Performing cleanup..."
    cleanup_runner

    # Exit with the same code as the runner
    exit $RUNNER_EXIT_CODE
}

# Execute main function
main