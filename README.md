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
```bash
docker run -d \
  --name github-runner \
  -e RUNNER_NAME="my-runner" \
  -e GITHUB_TOKEN="your-github-token" \
  -e RUNNER_REPOSITORY_URL="https://github.com/your-org/your-repo" \
  emberstack/github-actions-runner:latest
```

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

### Core Utilities
- **GNU Coreutils** - Essential Unix utilities (ls, cp, mv, cat, etc.)
- **File Utilities**
  - `file` - File type identification
  - `findutils` - Find files and directories
  - `tree` - Directory tree visualization
  - `time` - Time command execution

### Programming Languages & Runtimes
- **Python 3** with pip - Python interpreter and package manager
- **PowerShell Core** - Cross-platform PowerShell
- **Node.js** (LTS 20.x) with npm - JavaScript runtime and package manager
- **.NET SDK**
  - LTS version - Long Term Support release
  - STS version - Standard Term Support (latest) release

### Cloud & Infrastructure Tools
- **Azure CLI** - Azure cloud management
- **AzCopy** - Azure Storage data transfer (latest release)
- **Ansible** - Infrastructure automation (latest from pip)

### Container Tools
- **Docker Compose Plugin** - Multi-container orchestration (latest)
- **Docker Buildx** - Advanced Docker builds (pre-installed in base image)

### Kubernetes Tools
- **kubectl** - Kubernetes CLI (latest stable)
- **Helm** - Kubernetes package manager (latest)
- **Kustomize** - Kubernetes configuration management (latest)

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