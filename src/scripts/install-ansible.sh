#!/bin/bash

# Install Ansible using pip

# Install ansible globally using pip
pip install ansible

# Verify installation
echo "Checking installed ansible executables:"
ls -la /usr/local/bin/ansible* 2>/dev/null || echo "Ansible binaries not in /usr/local/bin"

# Verify installation
echo "Verifying Ansible installation..."
if ! command -v ansible &> /dev/null; then
    echo "ERROR: ansible command not found after installation"
    echo "PATH: $PATH"
    # Try to find where pip installed it
    echo "Searching for ansible executable..."
    find /usr -name "ansible" -type f 2>/dev/null | head -5
    exit 1
fi

# Check for ansible-playbook which is commonly used
if ! command -v ansible-playbook &> /dev/null; then
    echo "ERROR: ansible-playbook command not found after installation"
    exit 1
fi

echo "Ansible version:"
ansible --version

echo "Ansible installation completed successfully!"