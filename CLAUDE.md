# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains Docker images for GitHub Actions self-hosted runners with additional tools pre-installed. The main image is based on the official GitHub Actions runner image and includes a comprehensive suite of development and operations tools including Python, PowerShell, Node.js, .NET SDK, Azure CLI, AzCopy, Ansible, Kubernetes tools, network utilities, and more.

## Architecture

- **Base Image**: Built on `ghcr.io/actions/actions-runner:2.327.1`
- **Additional Tools**: Multiple tools installed via a YAML-driven setup system
- **Setup System**: Uses `setup.yaml` to define installation steps with `setup.sh` orchestrator
- **Multi-Architecture Support**: Supports both AMD64 and ARM64 architectures
- **CI/CD**: Uses GitHub Actions for automated building and releasing

### Setup System Details

The setup system reads `src/setup.yaml` and executes installation steps sequentially. Each step can either:
- Execute a script file from `src/scripts/` directory
- Run inline commands directly

The orchestrator (`setup.sh`) provides:
- Colored logging with timestamps
- Step execution tracking
- Error handling with proper exit codes
- Support for both `script` and `command` step types

## Key Commands

### Building the Docker Image

```bash
# Build locally
docker build -t github-actions-runner -f src/Dockerfile src/

# Build with specific platform
docker buildx build --platform linux/amd64 -t github-actions-runner -f src/Dockerfile src/

# Build multi-platform image
docker buildx build --platform linux/amd64,linux/arm64 -t github-actions-runner -f src/Dockerfile src/

# Build and load into local Docker (single platform only)
docker buildx build --platform linux/amd64 --load -t github-actions-runner -f src/Dockerfile src/
```

### Testing the Image Locally

```bash
# Run the built image
docker run --rm -it github-actions-runner bash

# Test specific tools
docker run --rm github-actions-runner python3 --version
docker run --rm github-actions-runner pwsh --version
docker run --rm github-actions-runner az --version
```

### Adding New Tools

To add a new tool to the image:

1. **For complex installations**, create a script in `src/scripts/`:
   ```bash
   # src/scripts/install-newtool.sh
   #!/bin/bash
   set -euo pipefail
   
   # Architecture detection if needed
   ARCH=$(uname -m)
   case ${ARCH} in
     x86_64) ARCH_SUFFIX="amd64" ;;
     aarch64) ARCH_SUFFIX="arm64" ;;
   esac
   
   # Installation logic here
   ```

2. Add the step to `src/setup.yaml`:
   ```yaml
   - name: "Install New Tool"
     script: "scripts/install-newtool.sh"
     description: "Description of what this installs"
   ```

3. **For simple installations**, use inline commands:
   ```yaml
   - name: "Install New Tool"
     command: "apt-get update && apt-get install -y newtool"
     description: "Description of what this installs"
   ```

4. Make the script executable:
   ```bash
   chmod +x src/scripts/install-newtool.sh
   ```

### GitHub Actions Workflow

The repository uses GitVersion for semantic versioning. The pipeline is triggered on:
- Push to any branch
- Pull requests
- Manual workflow dispatch

## Project Structure

- `src/Dockerfile`: Main Dockerfile that builds the runner image
- `src/setup.yaml`: YAML configuration defining all installation steps
- `src/setup.sh`: Main orchestrator that reads setup.yaml and executes steps
- `src/scripts/`: Installation scripts for various tools
  - `install-coreutils.sh`: Verifies GNU coreutils (pre-installed)
  - `install-file-tools.sh`: Installs file utilities (file, tree, time)
  - `install-archive-tools.sh`: Installs compression tools (p7zip, zip)
  - `install-python.sh`: Installs pip and Python development tools
  - `install-powershell.sh`: Installs PowerShell Core
  - `install-nodejs.sh`: Installs Node.js and npm
  - `install-azure-cli.sh`: Installs Azure CLI
  - `install-azcopy.sh`: Installs AzCopy with architecture detection
  - `install-ansible.sh`: Installs Ansible via pip
  - `install-docker-tools.sh`: Installs Docker Compose plugin
  - `install-json-tools.sh`: Verifies jq and yq tools
  - `install-kubernetes-tools.sh`: Installs kubectl, helm, kustomize
  - `install-yamllint.sh`: Installs yamllint
  - `install-github-cli.sh`: Installs GitHub CLI
  - `install-dotnet-sdk.sh`: Installs .NET SDK (LTS and latest)
  - `install-network-tools.sh`: Installs comprehensive network utilities
- `.github/workflows/pipeline.yaml`: Main CI/CD pipeline
- `GitVersion.yaml`: Semantic versioning configuration

## Versioning Strategy

The project uses GitVersion with:
- Main branch: Continuous deployment mode
- Develop branch: Minor version increments
- Release branches: RC pre-releases
- Feature branches: Named pre-releases
- Commit messages control version bumps (+semver:major/minor/patch)

## Container Registries

Images are published to:
- Docker Hub: `emberstack/github-actions-runner`
- GitHub Container Registry: `ghcr.io/emberstack/github-actions-runner`

Both registries receive multi-architecture manifests supporting AMD64 and ARM64.

## Development Workflow

### Making Changes

1. **Modify installation scripts**: Edit files in `src/scripts/` for tool-specific changes
2. **Update setup configuration**: Modify `src/setup.yaml` to add/remove/reorder steps
3. **Test locally**: Build and run the image to verify changes
4. **Commit with semantic versioning**: Use commit messages like:
   - `feat: add new tool` (minor version bump)
   - `fix: correct installation issue` (patch version bump)
   - `feat!: breaking change` or `+semver:major` (major version bump)

### CI/CD Pipeline Details

The pipeline (`pipeline.yaml`) consists of:
1. **Discovery**: Determines version and whether to build/release
2. **Build**: Parallel builds for each architecture
3. **Manifest**: Creates multi-arch manifests
4. **Release**: Creates GitHub releases (main branch only)

### Debugging Installation Issues

When debugging tool installations:
1. Check the colored output from `setup.sh` for the specific failing step
2. Run the Docker build with `--progress=plain` for detailed output
3. Test scripts individually inside a running container
4. Verify architecture-specific logic for ARM64 vs AMD64

## Base Image Optimization

The base GitHub Actions runner image already includes many common tools. Before adding new tools, check if they're pre-installed:

### Pre-installed Tools (Do Not Re-install)
- **Core utilities**: curl, wget, git, tar, unzip, sudo
- **Python 3**: Python interpreter (but not pip)
- **Docker**: Docker engine with Docker Buildx
- **JSON processing**: jq
- **SSH tools**: ssh, scp, openssh-client
- **Build essentials**: gcc, make, build-essential

### Verification Scripts
Some scripts only verify pre-installed tools rather than installing them:
- `install-coreutils.sh`: Verifies GNU coreutils
- `install-json-tools.sh`: Verifies jq (pre-installed) and yq (installed in Dockerfile)

### Installation Best Practices
1. Always check if a tool is pre-installed before adding installation logic
2. Use verification-only scripts for pre-installed tools
3. Group related tools in single installation scripts
4. Minimize apt-get update calls by grouping installations
5. Clean package caches after installation to reduce image size