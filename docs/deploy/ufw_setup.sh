#!/bin/bash
# Simple UFW setup for a Droplet
# Usage: sudo bash docs/deploy/ufw_setup.sh
set -euo pipefail

# Replace with SSH port if different
SSH_PORT=22

# Allow HTTP, HTTPS and SSH
ufw allow ${SSH_PORT}/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Deny everything else by default
ufw default deny incoming
ufw default allow outgoing

# Enable UFW
ufw --force enable

# Show status
ufw status verbose

echo "UFW configured: incoming default deny, allowed ports: ${SSH_PORT}, 80, 443."