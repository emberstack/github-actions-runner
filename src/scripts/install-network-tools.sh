#!/bin/bash

# Install comprehensive network tools

echo "Installing network tools..."

# Install network packages
# Note: openssh-client (ssh, scp) is already in base image
apt-get update
apt-get install -y --no-install-recommends \
    dnsutils \
    iputils-ping \
    iputils-tracepath \
    iputils-arping \
    iproute2 \
    net-tools \
    netcat \
    ftp \
    telnet \
    sshpass

# Verify DNS tools
echo "Verifying DNS tools installation..."
if ! command -v dig &> /dev/null; then
    echo "ERROR: dig command not found after installation"
    exit 1
fi
echo "dig version:"
dig -v 2>&1 | head -1

if ! command -v nslookup &> /dev/null; then
    echo "ERROR: nslookup command not found after installation"
    exit 1
fi
echo "nslookup available"

if ! command -v nsupdate &> /dev/null; then
    echo "ERROR: nsupdate command not found after installation"
    exit 1
fi
echo "nsupdate available"

# Verify iputils tools
echo ""
echo "Verifying iputils tools installation..."
if ! command -v ping &> /dev/null; then
    echo "ERROR: ping command not found after installation"
    exit 1
fi
echo "ping available:"
ping -V

if ! command -v tracepath &> /dev/null; then
    echo "ERROR: tracepath command not found after installation"
    exit 1
fi
echo "tracepath available"

if ! command -v arping &> /dev/null; then
    echo "ERROR: arping command not found after installation"
    exit 1
fi
echo "arping available"

# Verify iproute2 tools
echo ""
echo "Verifying iproute2 tools installation..."
if ! command -v ip &> /dev/null; then
    echo "ERROR: ip command not found after installation"
    exit 1
fi
echo "ip command available"

if ! command -v ss &> /dev/null; then
    echo "ERROR: ss command not found after installation"
    exit 1
fi
echo "ss command available"

# Verify net-tools
echo ""
echo "Verifying net-tools installation..."
if ! command -v ifconfig &> /dev/null; then
    echo "ERROR: ifconfig command not found after installation"
    exit 1
fi
echo "ifconfig available"

if ! command -v netstat &> /dev/null; then
    echo "ERROR: netstat command not found after installation"
    exit 1
fi
echo "netstat available"

# Verify other network tools
echo ""
echo "Verifying additional network tools..."
if ! command -v nc &> /dev/null; then
    echo "ERROR: netcat (nc) command not found after installation"
    exit 1
fi
echo "netcat (nc) available"

if ! command -v ssh &> /dev/null; then
    echo "ERROR: ssh command not found after installation"
    exit 1
fi
echo "ssh client available"

if ! command -v ftp &> /dev/null; then
    echo "ERROR: ftp command not found after installation"
    exit 1
fi
echo "ftp available"

if ! command -v telnet &> /dev/null; then
    echo "ERROR: telnet command not found after installation"
    exit 1
fi
echo "telnet available"

if ! command -v sshpass &> /dev/null; then
    echo "ERROR: sshpass command not found after installation"
    exit 1
fi
echo "sshpass available"

echo ""
echo "Network tools installation completed successfully!"