# Archived Scripts

This directory contains installation scripts that have been archived in favor of using GitHub Actions' official setup actions.

## Archived Scripts

### Python/pip Installation (`scripts/install-python.sh`)
- **Replaced by**: [`actions/setup-python`](https://github.com/actions/setup-python)
- **Reason**: The official action includes pip by default and provides Python version management

### Node.js Installation (`scripts/install-nodejs.sh`)
- **Replaced by**: [`actions/setup-node`](https://github.com/actions/setup-node)
- **Reason**: The official action provides better caching, version management, and is optimized for CI/CD

### .NET SDK Installation (`scripts/install-dotnet-sdk.sh`)
- **Replaced by**: [`actions/setup-dotnet`](https://github.com/actions/setup-dotnet)
- **Reason**: The official action handles multiple SDK versions, caching, and is maintained by Microsoft

### Kubernetes Tools Installation (`scripts/install-kubernetes-tools.sh`)
- **Replaced by**: 
  - kubectl: [`azure/setup-kubectl`](https://github.com/azure/setup-kubectl)
  - Helm: [`azure/setup-helm`](https://github.com/azure/setup-helm)
  - Kustomize: [`imranismail/setup-kustomize`](https://github.com/imranismail/setup-kustomize)
- **Reason**: These actions provide version management, caching, and are maintained by the community

### Ansible Installation (`scripts/install-ansible.sh`)
- **Replaced by**: pip install after `actions/setup-python`
- **Reason**: Ansible is a Python package best installed via pip in workflows

## Usage

These scripts are preserved for reference and can still be used if you need to install these tools directly in the Docker image. However, for GitHub Actions workflows, we recommend using the official setup actions.

### Example workflow usage:

```yaml
steps:
  - uses: actions/checkout@v4
  
  - name: Setup Node.js
    uses: actions/setup-node@v4
    with:
      node-version: '20'
      cache: 'npm'
  
  - name: Setup .NET
    uses: actions/setup-dotnet@v4
    with:
      dotnet-version: |
        8.0.x
        9.0.x
        
  - name: Setup kubectl
    uses: azure/setup-kubectl@v4
    with:
      version: 'latest'
      
  - name: Setup Helm
    uses: azure/setup-helm@v4
    with:
      version: 'latest'
      
  - name: Setup Python
    uses: actions/setup-python@v5
    with:
      python-version: '3.x'
      cache: 'pip'
      
  - name: Install Ansible
    run: |
      python -m pip install --upgrade pip
      pip install ansible
```