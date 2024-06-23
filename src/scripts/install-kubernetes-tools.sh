#!/bin/bash

# Install kubectl, helm, and kustomize

echo "Installing Kubernetes tools..."

# Install prerequisites
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl

# Detect architecture
ARCH=$(uname -m)
case ${ARCH} in
    x86_64) ARCH_SUFFIX="amd64" ;;
    aarch64) ARCH_SUFFIX="arm64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Install kubectl
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH_SUFFIX}/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install helm
echo "Installing helm..."
HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
if [ -z "$HELM_VERSION" ]; then
    echo "Failed to get Helm version, using fallback"
    HELM_VERSION="3.16.4"
fi
curl -fsSL -o helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH_SUFFIX}.tar.gz"
tar -zxvf helm.tar.gz
mv linux-${ARCH_SUFFIX}/helm /usr/local/bin/helm
rm -rf helm.tar.gz linux-${ARCH_SUFFIX}

# Install kustomize
echo "Installing kustomize..."
KUSTOMIZE_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases | grep '"tag_name":' | grep kustomize | head -1 | sed -E 's/.*"kustomize\/v([^"]+)".*/\1/')
if [ -z "$KUSTOMIZE_VERSION" ]; then
    echo "Failed to get Kustomize version, using fallback"
    KUSTOMIZE_VERSION="5.5.0"
fi
curl -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH_SUFFIX}.tar.gz" | tar xz
mv kustomize /usr/local/bin/kustomize

# Verify installations
echo "Verifying kubectl installation..."
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl command not found after installation"
    exit 1
fi
echo "kubectl version:"
kubectl version --client

echo "Verifying helm installation..."
if ! command -v helm &> /dev/null; then
    echo "ERROR: helm command not found after installation"
    exit 1
fi
echo "helm version:"
helm version --short

echo "Verifying kustomize installation..."
if ! command -v kustomize &> /dev/null; then
    echo "ERROR: kustomize command not found after installation"
    exit 1
fi
echo "kustomize version:"
kustomize version

echo "Kubernetes tools installation completed successfully!"