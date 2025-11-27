# Makefile for KiyuMart
# Usage: make <target>

APP_DIR=$(shell pwd)
DOCTL_APP_ID=YOUR_DO_APP_ID_HERE

.PHONY: build build-ci test start deploy-doctl deploy-local lint

# Build for local dev or Docker build
build:
	bash ./scripts/build.sh

# CI-friendly build (no dev install duplication if needed)
build-ci:
	npm ci
	npm run build

# Run tests
test:
	npm run test

# Start locally
start:
	export NODE_ENV=production && npm start

# Deploy using doctl to DigitalOcean App Platform
deploy-doctl:
	@echo "Deploying to DO using app.yaml (requires doctl logged in)"
	if [ "$(DOCTL_APP_ID)" = "YOUR_DO_APP_ID_HERE" ]; then \
		echo "Please set DOCTL_APP_ID in the Makefile or export it in your env"; exit 1; \
	fi
	doctl apps update $(DOCTL_APP_ID) --spec app.yaml

# Deploy locally using pm2 (useful for Droplet)
deploy-local:
	pm2 startOrReload docs/deploy/pm2_ecosystem.config.js

# Lint and format (if present)
lint:
	npm run check
