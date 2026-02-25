FROM ghcr.io/actions/actions-runner:2.332.0

USER root

# Install required dependencies
# Note: curl is already in base image, but wget is needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Install yq with architecture detection
RUN ARCH=$(uname -m) && \
    YQ_ARCH=$([ "$ARCH" = "x86_64" ] && echo "amd64" || echo "arm64") && \
    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${YQ_ARCH} && \
    chmod +x /usr/local/bin/yq

WORKDIR /install

COPY /scripts /scripts
COPY setup.yaml /
COPY setup.sh /

# Run setup script with proper error handling
RUN bash -e /setup.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch back to runner user
USER runner

# Set working directory
WORKDIR /home/runner

# Set .NET install directory to avoid permission issues
ENV DOTNET_INSTALL_DIR=/home/runner/.dotnet

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]