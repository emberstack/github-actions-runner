# Archived Scripts

This directory contains installation scripts that have been archived in favor of using GitHub Actions' official setup actions.

## Archived Scripts

### Node.js Installation (`scripts/install-nodejs.sh`)
- **Replaced by**: [`actions/setup-node`](https://github.com/actions/setup-node)
- **Reason**: The official action provides better caching, version management, and is optimized for CI/CD

### .NET SDK Installation (`scripts/install-dotnet-sdk.sh`)
- **Replaced by**: [`actions/setup-dotnet`](https://github.com/actions/setup-dotnet)
- **Reason**: The official action handles multiple SDK versions, caching, and is maintained by Microsoft

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
```