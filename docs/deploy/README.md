# Deploy KiyuMart without Docker (Droplet / VM)

Great question — the easiest path is to use DigitalOcean App Platform’s Node.js buildpack (no Docker). It’s simpler than managing Docker images and still supports CI/CD via GitHub Actions and `app.yaml`.

This folder includes example configuration files and instructions for running KiyuMart without Docker:

Files:
- `pm2_ecosystem.config.js` - PM2 ecosystem file to start and manage app
- `kiyumart.service` - `systemd` service file to use instead of PM2 (example)
- `Makefile` - Helpers for build, deploy, and actions (`make build`, `make build-ci`, `make test`, `make deploy-doctl`)

Quickstart (Ubuntu Droplet):

1. SSH to droplet and install Node.js 18 (NodeSource recommended):

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get update
sudo apt-get install -y nodejs build-essential
```

2. Install PM2 globally (if you want to use pm2):

```bash
sudo npm i -g pm2
```

3. Clone the repo and install dependencies:

```bash
git clone https://github.com/YOUR-USERNAME/kiyuMart.git
cd kiyuMart
make build
```

4. Copy or edit the PM2 ecosystem file and start using pm2:

```bash
# Edit docs/deploy/pm2_ecosystem.config.js and set correct cwd
pm2 start docs/deploy/pm2_ecosystem.config.js
pm2 save
pm2 startup
```

5. (Optional) Use systemd instead of PM2:

```bash
# Copy and edit the systemd file to /etc/systemd/system/kiyumart.service
sudo cp docs/deploy/kiyumart.service /etc/systemd/system/kiyumart.service
# edit environment variables or use /etc/environment or a drop-in file
sudo systemctl daemon-reload
sudo systemctl enable --now kiyumart.service
sudo systemctl status kiyumart.service
```

6. Configure a reverse proxy (Nginx) to forward to `http://127.0.0.1:5000` and set up SSL with certbot.
	- Example Nginx config is available at `docs/deploy/nginx.conf`.
	- Quick firewall setup (UFW): Script available at `docs/deploy/ufw_setup.sh`.
	- Quick SSL (certbot):
	  ```bash
	  sudo apt install -y certbot python3-certbot-nginx
	  sudo certbot --nginx -d kiyumart.example.com -d www.kiyumart.example.com
	  # Follow prompts to auto-setup redirects and renewals
	  ```

7. Add environment variables to the server (e.g. `DATABASE_URL`, `SESSION_SECRET`, `JWT_SECRET`). You can add them system-wide in `/etc/environment` or reference an env file in systemd with `EnvironmentFile=/path/to/.env`.

8. Run migrations and seed once (or as needed):

```bash
npm run db:push
npm run db:seed

Post-deploy script
------------------
There's a small helper script `docs/deploy/postdeploy.sh` that installs dependencies, builds, runs migrations and restarts the service. Be sure to edit the `APP_DIR` and adjust the environment path as needed.

DigitalOcean App Platform (App YAML)
----------------------------------
If you prefer to use the DigitalOcean App Platform without Docker, you can use the included `app.yaml` in the repo root to configure the app using the `doctl` CLI:

```
# Make sure you have doctl authenticated
doctl apps create --spec app.yaml
```

App Platform will run the build command set in `app.yaml` (we recommend `bash ./scripts/build.sh`) and then `npm start` using environment variables you provide.

GitHub Actions
--------------
A sample GitHub Actions workflow is included at `.github/workflows/deploy-digitalocean.yml` to auto-deploy to the App Platform on push to `main`.
To enable it, add a repository secret named `DIGITALOCEAN_ACCESS_TOKEN` containing a DO API token with the required scope.
```

Security and Production Notes:
- Use a non-root user to run the Node app.
- Use an external service for storing images (Cloudinary) or configure persistent storage for `attached_assets`.
- Configure a firewall and monitoring.
- Run regular backups for the database.
