# GitHub Actions Runner Images

[![Docker Hub](https://img.shields.io/docker/pulls/emberstack/github-actions-runner.svg)](https://hub.docker.com/r/emberstack/github-actions-runner)
[![GitHub Container Registry](https://img.shields.io/badge/ghcr.io-emberstack%2Fgithub--actions--runner-blue)](https://github.com/emberstack/github-actions-runner/pkgs/container/github-actions-runner)
[![License](https://img.shields.io/github/license/emberstack/github-actions-runner)](LICENSE)

## Overview

This repository provides enhanced Docker images for GitHub Actions self-hosted runners with a comprehensive suite of pre-installed development and operations tools. Built on top of the official GitHub Actions runner base image, it includes essential tools for CI/CD workflows, making it ideal for enterprise and development environments.

### Key Features
- 🚀 Based on official [GitHub Actions runner](https://github.com/actions/runner) image
- 🏗️ Multi-architecture support (AMD64 and ARM64)
- 📦 Comprehensive tool suite pre-installed
- 🔧 YAML-driven installation system for easy customization
- 🎯 Automated CI/CD pipeline with semantic versioning
- 🐳 Published to both Docker Hub and GitHub Container Registry

## Quick Start

### Pull from Docker Hub
```bash
docker pull emberstack/github-actions-runner:latest
```

### Pull from GitHub Container Registry
```bash
docker pull ghcr.io/emberstack/github-actions-runner:latest
```

### Run as GitHub Actions Runner

#### Using Personal Access Token (PAT)
```bash
docker run -d \
  --name github-runner \
  -e GITHUB_RUNNER_URL="https://github.com/your-org/your-repo" \
  -e GITHUB_RUNNER_PAT="your-personal-access-token" \
  -e GITHUB_RUNNER_NAME="my-runner" \
  -e GITHUB_RUNNER_LABELS="docker,linux" \
  emberstack/github-actions-runner:latest
```

#### Using Registration Token
```bash
docker run -d \
  --name github-runner \
  -e GITHUB_RUNNER_URL="https://github.com/your-org/your-repo" \
  -e GITHUB_RUNNER_TOKEN="your-registration-token" \
  -e GITHUB_RUNNER_NAME="my-runner" \
  emberstack/github-actions-runner:latest
```

#### With Docker Socket Access
```bash
docker run -d \
  --name github-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GITHUB_RUNNER_URL="https://github.com/your-org/your-repo" \
  -e GITHUB_RUNNER_PAT="your-personal-access-token" \
  -e GITHUB_RUNNER_DOCKER_SOCK="true" \
  emberstack/github-actions-runner:latest
```

#### With Custom GID
```bash
docker run -d \
  --name github-runner \
  -e GITHUB_RUNNER_URL="https://github.com/your-org/your-repo" \
  -e GITHUB_RUNNER_PAT="your-personal-access-token" \
  -e GITHUB_RUNNER_GID="1001" \
  emberstack/github-actions-runner:latest
```

#### Ephemeral Mode (Single Job)
```bash
docker run -d \
  --name github-runner \
  -e GITHUB_RUNNER_URL="https://github.com/your-org/your-repo" \
  -e GITHUB_RUNNER_PAT="your-personal-access-token" \
  -e GITHUB_RUNNER_EPHEMERAL="true" \
  emberstack/github-actions-runner:latest
```

#### Dynamic Runner Naming with Environment Variables
The `GITHUB_RUNNER_NAME` supports safe environment variable expansion, allowing dynamic runner names based on any runtime environment variable:

```bash
# Use container hostname (container ID in Docker)
docker run -d \
  --name github-runner \
  -e GITHUB_RUNNER_URL="https://github.com/your-org/your-repo" \
  -e GITHUB_RUNNER_PAT="your-personal-access-token" \
  -e GITHUB_RUNNER_NAME='$HOSTNAME' \
  emberstack/github-actions-runner:latest

# Combine with prefix/suffix
docker run -d \
  --name github-runner \
  -e GITHUB_RUNNER_URL="https://github.com/your-org/your-repo" \
  -e GITHUB_RUNNER_PAT="your-personal-access-token" \
  -e GITHUB_RUNNER_NAME='runner-$HOSTNAME' \
  emberstack/github-actions-runner:latest

# Use in Docker Compose with custom hostname
services:
  runner:
    image: emberstack/github-actions-runner:latest
    hostname: worker-node-1
    environment:
      GITHUB_RUNNER_URL: "https://github.com/your-org/your-repo"
      GITHUB_RUNNER_PAT: "your-personal-access-token"
      GITHUB_RUNNER_NAME: 'runner-$HOSTNAME'  # Will be "runner-worker-node-1"
```

**Examples of Supported Variables:**
- `$HOSTNAME` or `${HOSTNAME}` - The container's hostname (container ID by default in Docker)
- `$USER` or `${USER}` - The current user (typically "runner")
- `$HOME` or `${HOME}` - The user's home directory
- `$PATH` - System PATH
- Any custom environment variable you define

**Note:** Use single quotes (`'`) to prevent variable expansion on the host shell, allowing expansion inside the container. Variable expansion is performed safely using `envsubst`, preventing code injection.

In ephemeral mode, the runner will:
- Process only one job and then automatically deregister
- Provide a clean, isolated environment for each workflow run
- Be ideal for autoscaling scenarios and enhanced security
- Ensure no job state or secrets persist between runs

#### Environment Variables
- `GITHUB_RUNNER_URL` (required): Repository, organization, or enterprise URL
- `GITHUB_RUNNER_PAT` or `GITHUB_RUNNER_TOKEN` (required): Authentication token
- `GITHUB_RUNNER_NAME` (optional): Runner name (defaults to hostname). Supports safe environment variable expansion using standard shell syntax
- `GITHUB_RUNNER_LABELS` (optional): Comma-separated list of labels
- `GITHUB_RUNNER_GROUP` (optional): Runner group name
- `GITHUB_RUNNER_WORKDIR` (optional): Working directory for jobs
- `GITHUB_RUNNER_GID` (optional): Custom GID to create github-actions-runner group
- `GITHUB_RUNNER_DOCKER_SOCK` (optional): Set to "true" to auto-configure Docker socket access
- `GITHUB_RUNNER_DOCKER_SOCK_GID` (optional): Explicit GID for Docker socket group (overrides auto-detection when socket exists)
- `GITHUB_RUNNER_EPHEMERAL` (optional): Set to "true" to configure runner in ephemeral mode (single job only)

##### Pre-configured Environment Variables
The following environment variables are set in the Docker image:
- `DOTNET_INSTALL_DIR`: Set to `/home/runner/.dotnet` to avoid permission issues when using actions/setup-dotnet

#### Graceful Shutdown
The container handles shutdown signals (SIGTERM, SIGINT) gracefully:
- Stops the running job (if any)
- Removes the runner registration from GitHub
- Ensures clean termination

This automatic cleanup prevents orphaned runner registrations when containers are stopped.

## Included Software

### Pre-installed in Base Image
The following tools are already available in the GitHub Actions runner base image:
- **Python 3** - Python interpreter
- **Git** - Version control system
- **Docker** with **Docker Buildx** - Container platform
- **jq** - JSON processor
- **curl** - Data transfer tool
- **SSH/SCP** - Secure shell and copy
- **tar** - Archive utility
- **unzip** - ZIP extraction
- **sudo** - Privilege escalation
- **Core Unix tools** - find, grep, sed, awk, perl, etc.
- **GNU Coreutils** - Essential Unix utilities (ls, cp, mv, cat, etc.)

### File Utilities
- **file** - File type identification
- **findutils** - Find files and directories
- **tree** - Directory tree visualization
- **time** - Time command execution

### Programming Languages & Runtimes
- **PowerShell Core** - Cross-platform PowerShell

### Cloud & Infrastructure Tools
- **Azure CLI** - Azure cloud management
- **AzCopy** - Azure Storage data transfer (latest release)

### Container Tools
- **Docker Compose Plugin** - Multi-container orchestration (latest)
- **Docker Buildx** - Advanced Docker builds (pre-installed in base image)

### Development Tools
- **Git** - Version control (pre-installed in base image)
- **GitHub CLI** (`gh`) - GitHub operations (latest)
- **jq** - JSON processor (pre-installed in base image)
- **yq** - YAML processor (latest)
- **yamllint** - YAML linter (latest from pip)

### Archive & Compression Tools
- **tar** - Tape archive utility (pre-installed in base image)
- **unzip** - ZIP decompression (pre-installed in base image)
- **zip** - ZIP compression
- **p7zip-full** (7z) - 7-Zip archiver

### Network Tools
- **DNS Utilities**
  - `dig` - DNS lookup
  - `nslookup` - Query DNS servers
  - `nsupdate` - Dynamic DNS updates
- **IP Utilities**
  - `ping` - Network connectivity test
  - `tracepath` - Network path discovery
  - `arping` - ARP level ping
  - `ip` - Show/manipulate routing, network devices
  - `ss` - Socket statistics
- **Legacy Network Tools**
  - `ifconfig` - Network interface configuration
  - `netstat` - Network statistics
  - `route` - Routing table manipulation
- **Connection Tools**
  - `ssh` - Secure Shell client (pre-installed in base image)
  - `scp` - Secure copy (pre-installed in base image)
  - `ftp` - File Transfer Protocol client
  - `telnet` - Telnet client
  - `netcat` (`nc`) - Network debugging
  - `sshpass` - Non-interactive SSH authentication

## Architecture

### Build System
The image uses a YAML-driven installation system:
- `src/setup.yaml` - Defines installation steps
- `src/setup.sh` - Orchestrates the installation process
- `src/scripts/` - Individual installation scripts for each tool group

### Multi-Architecture Support
- Automatic architecture detection during build
- Platform-specific binaries for AMD64 and ARM64
- Unified multi-arch manifests in registries

## Building Locally

### Prerequisites
- Docker or Docker Desktop
- Docker Buildx (for multi-platform builds)

### Build for Current Platform
```bash
docker build -t github-actions-runner -f src/Dockerfile src/
```

### Build for Specific Platform
```bash
docker buildx build --platform linux/amd64 -t github-actions-runner -f src/Dockerfile src/
```

### Build Multi-Platform
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t github-actions-runner -f src/Dockerfile src/
```

## Customization

### Adding New Tools

1. Create an installation script in `src/scripts/`:
```bash
#!/bin/bash
# src/scripts/install-newtool.sh
apt-get update
apt-get install -y newtool
# Add verification
if ! command -v newtool &> /dev/null; then
    echo "ERROR: newtool installation failed"
    exit 1
fi
```

2. Add to `src/setup.yaml`:
```yaml
- name: "Install New Tool"
  script: "scripts/install-newtool.sh"
  description: "Description of the tool"
```

3. Make the script executable:
```bash
chmod +x src/scripts/install-newtool.sh
```

## CI/CD Pipeline

The repository uses GitHub Actions for automated building and releasing:

- **Automatic Builds**: Triggered on push to any branch
- **Multi-Architecture Builds**: Parallel builds for AMD64 and ARM64
- **Semantic Versioning**: Using GitVersion
- **Container Registries**: Publishes to Docker Hub and GitHub Container Registry
- **Release Management**: Automatic GitHub releases on main branch

### Version Control
- Commit messages control version bumps:
  - `feat:` - Minor version bump
  - `fix:` - Patch version bump
  - `feat!:` or `+semver:major` - Major version bump

## Repository Structure
```
├── .github/
│   └── workflows/
│       └── pipeline.yaml      # CI/CD pipeline
├── src/
│   ├── Dockerfile            # Main Docker image definition
│   ├── setup.yaml           # Tool installation configuration
│   ├── setup.sh            # Installation orchestrator
│   └── scripts/            # Individual tool installation scripts
├── GitVersion.yaml         # Semantic versioning configuration
├── LICENSE                # Repository license
├── README.md             # This file
└── CLAUDE.md            # AI assistant guidance
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines
1. Follow the existing script patterns
2. Ensure tools work on both AMD64 and ARM64
3. Add verification steps in installation scripts
4. Update documentation for new tools
5. Test builds locally before submitting PR

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 🐛 [Report Issues](https://github.com/emberstack/github-actions-runner/issues)
- 💬 [Discussions](https://github.com/emberstack/github-actions-runner/discussions)

## Acknowledgments

- Built on top of [actions/runner](https://github.com/actions/runner) official images
- Inspired by the need for comprehensive CI/CD environments
- Thanks to all contributors and the open-source community

## Note on Development Tools

While installation scripts for various development tools are available in the `src/_archive/scripts/` directory, we recommend using GitHub Actions' official setup actions or marketplace actions in your workflows:

### Languages & Runtimes
- **Python/pip**: Use [`actions/setup-python`](https://github.com/actions/setup-python) - includes pip by default
- **Node.js**: Use [`actions/setup-node`](https://github.com/actions/setup-node)
- **.NET SDK**: Use [`actions/setup-dotnet`](https://github.com/actions/setup-dotnet)

### Infrastructure Tools
- **kubectl**: Use [`azure/setup-kubectl`](https://github.com/azure/setup-kubectl)
- **Helm**: Use [`azure/setup-helm`](https://github.com/azure/setup-helm)
- **Kustomize**: Use [`imranismail/setup-kustomize`](https://github.com/imranismail/setup-kustomize)
- **Ansible**: Install via pip after setting up Python

These actions provide better caching, version management, and are optimized for CI/CD environments.