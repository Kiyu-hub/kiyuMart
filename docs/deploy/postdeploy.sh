#!/bin/bash
# postdeploy.sh - Run after the app is deployed or updated
# Usage: sudo bash docs/deploy/postdeploy.sh
set -euo pipefail

# Check if environment file exists. Load it.
if [ -f /etc/kiyumart/kiyumart.env ]; then
  echo "Loading environment from /etc/kiyumart/kiyumart.env"
  export $(grep -v '^#' /etc/kiyumart/kiyumart.env | xargs)
fi

# Navigate to repo root - update if needed
APP_DIR="/home/kiyum/kiyumart"
cd "$APP_DIR"

# Install deps and build
npm ci
npm run build

# Run DB migrations
npm run db:push

# Seed if needed (commented by default - enable only if needed)
# npm run db:seed

# Restart PM2 or systemd service
if command -v pm2 >/dev/null 2>&1; then
  echo "Restarting via PM2"
  pm2 restart kiyumart || pm2 start docs/deploy/pm2_ecosystem.config.js
else
  echo "Restarting systemd service"
  sudo systemctl restart kiyumart.service
fi

echo "Post deploy steps finished."