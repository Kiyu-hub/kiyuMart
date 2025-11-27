#!/usr/bin/env bash
set -euo pipefail

# Build script used in App Platform and CI
# Ensures devDependencies are installed to run Vite & esbuild

export NODE_ENV=development
npm ci
npm run build

# Switch back to production mode for runtime
export NODE_ENV=production
