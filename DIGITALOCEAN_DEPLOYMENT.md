# DigitalOcean Deployment Guide - KiyuMart Platform

> **Complete guide to deploy KiyuMart (frontend + backend + database) on DigitalOcean App Platform using $200 GitHub Student Pack credits.**

---

## 📋 Prerequisites

- GitHub account with Student Developer Pack activated
- KiyuMart repository pushed to GitHub (public or private)
- DigitalOcean account (free signup)

---

## 🎓 Step 1: Redeem GitHub Student Pack Credits on DigitalOcean

1. **Visit GitHub Student Pack**
   - Go to https://education.github.com/pack
   - Sign in with your GitHub account
   - Search for "DigitalOcean"

2. **Redeem DigitalOcean Offer**
   - Click "Get DigitalOcean" or "Redeem" button
   - You'll be redirected to DigitalOcean signup
   - Create account or sign in (use GitHub login for convenience)
   - **You'll receive $200 in platform credits** (valid for 1 year)

3. **Verify Credits Applied**
   - Login to DigitalOcean dashboard
   - Go to Billing → Account
   - You should see "$200 Credit" in your account

---

## 🚀 Step 2: Deploy to DigitalOcean App Platform

### Option A: Deploy via DigitalOcean Console (Recommended)

1. **Create New App**
   - In DigitalOcean dashboard, click **Create** (top-left)
   - Select **App Platform**

2. **Connect GitHub Repository**
   - Click **GitHub** to authenticate
   - Select your KiyuMart repository
   - Choose branch: `main`
   - Click **Next**

3. **Configure Application**
   - DigitalOcean will auto-detect `Dockerfile`
   - Set the following:
     - **Build Command**: `npm run build` (already in Dockerfile)
     - **Run Command**: Already configured in Dockerfile
     - **HTTP Port**: `5000`

4. **Add Environment Variables**
   - Click **Edit** → **Environmental variables**
   - Add the following variables:

   ```env
   NODE_ENV=production
   DATABASE_URL=postgresql://user:password@db-host/kiyumart
   # (Get DATABASE_URL from managed DB step below)
   
   SESSION_SECRET=your-secure-random-string-32-chars-minimum
   JWT_SECRET=your-different-secure-random-string-32-chars-minimum
   
   # Cloudinary (optional, can be configured via Admin UI)
   CLOUDINARY_CLOUD_NAME=your-cloud-name
   CLOUDINARY_API_KEY=your-api-key
   CLOUDINARY_API_SECRET=your-api-secret
   
   # Paystack (optional, can be configured via Admin UI)
   PAYSTACK_PUBLIC_KEY=your-paystack-public-key
   PAYSTACK_SECRET_KEY=your-paystack-secret-key
   ```

5. **Generate Secure Secrets** (in your terminal):
   ```bash
   # Generate SESSION_SECRET
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   
   # Generate JWT_SECRET (different value)
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```
   - Copy each output and paste into DigitalOcean console

6. **Add Managed Database**
   - In the App Platform config, click **+ Add a Database**
   - Choose **PostgreSQL** (latest version)
   - Name: `kiyumart-db`
   - Engine: PostgreSQL 15+ (recommended)
   - DigitalOcean will auto-create and link to your app
   - Copy the connection string and paste as `DATABASE_URL`

7. **Deploy**
   - Click **Create App**
   - DigitalOcean builds and deploys (usually 5-10 minutes)
   - You'll get a live URL: `https://kiyumart-xxxxx.ondigitalocean.app`

### Option B: Deploy via DigitalOcean CLI (Advanced)

```bash
# Install doctl (DigitalOcean CLI)
brew install doctl  # macOS
# or from https://docs.digitalocean.com/reference/doctl/how-to/install/

# Authenticate
doctl auth init

# Create App from app.yaml
doctl apps create --spec app.yaml
```

**Sample `app.yaml` (create in repo root):**
```yaml
name: kiyumart
services:
  - name: web
    github:
      repo: YOUR-GITHUB-USERNAME/kiyuMart
      branch: main
    build_command: npm run build
    run_command: node --loader=tsx server/index.ts
    http_port: 5000
    envs:
      - key: NODE_ENV
        value: production
      - key: DATABASE_URL
        scope: RUN_TIME
      - key: SESSION_SECRET
        scope: RUN_TIME
      - key: JWT_SECRET
        scope: RUN_TIME

databases:
  - name: kiyumart-db
    engine: PG
    version: "15"
    production: true
```

---

## 🗄️ Step 3: Set Up PostgreSQL Database

### If Using Managed Database (Recommended)

1. **Create Managed Database**
   - In DigitalOcean dashboard: **Create** → **Databases**
   - Choose **PostgreSQL**
   - Region: Select closest to your users
   - Name: `kiyumart-db`
   - Version: 15+ (latest)
   - Cluster configuration: Starter ($15/month) or higher
   
2. **Get Connection String**
   - After creation, click the database
   - Go to **Connection Details** tab
   - Copy the connection string (looks like):
     ```
     postgresql://doadmin:pw_xxxxx@db-postgresql-xxx-do-user-12345-0.b.databases.digitalocean.com:25060/defaultdb?sslmode=require
     ```
   - Add to DigitalOcean App Platform environment variables as `DATABASE_URL`

3. **Initialize Database Schema**
   ```bash
   # Run migrations on your app after deployment
   # Access app via SSH or use npm scripts
   npm run db:push
   ```

### Alternative: PostgreSQL in Same Droplet

If using Droplet instead of App Platform:
```bash
# SSH into droplet
ssh root@your-droplet-ip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone repo and run
git clone https://github.com/YOUR-USERNAME/kiyuMart.git
cd kiyuMart
docker-compose up -d
```

**Sample `docker-compose.yml` (Droplet):**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: kiyumart
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: kiyumart
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      DATABASE_URL: postgresql://kiyumart:${DB_PASSWORD}@postgres:5432/kiyumart
      NODE_ENV: production
      SESSION_SECRET: ${SESSION_SECRET}
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - postgres

volumes:
  postgres_data:
```

---

## 🔒 Step 4: Production Security & Configuration

### 1. Enable HTTPS (Automatic on App Platform)
- DigitalOcean App Platform provides **free SSL certificates** automatically
- Your app is accessible at `https://your-app.ondigitalocean.app`
- Add custom domain: **App Settings** → **Domains**

### 2. Configure Custom Domain
```
1. In DigitalOcean App Platform settings
2. Add your domain (e.g., kiyumart.com)
3. Update domain DNS records (provided by DigitalOcean)
4. SSL certificate auto-renews
```

### 3. Set Up Admin Account
After deployment, initialize your admin account:
```bash
# Access app via browser:
https://your-app.ondigitalocean.app/api/seed/test-users

# Or create via API:
curl -X POST https://your-app.ondigitalocean.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@yourdomain.com",
    "password": "strong-password-here",
    "name": "Admin Name",
    "phone": "+1234567890",
    "role": "super_admin"
  }'
```

### 4. Configure Admin Settings
1. Login to app: `https://your-app.ondigitalocean.app/admin`
2. Navigate to **Settings** → **Platform Settings**
3. Configure:
   - Paystack API keys (payment gateway)
   - Cloudinary credentials (image uploads)
   - Contact information
   - Delivery zones

---

## 📊 Step 5: Monitoring & Scaling

### Monitor App Performance
- **DigitalOcean Dashboard**
  - Go to **Apps** → Your App
  - View **Logs**, **Metrics**, **Deployments**
  - Check CPU, Memory, and Network usage

### Auto-Scaling Configuration
```yaml
# In app.yaml, set resource limits:
services:
  - name: web
    http_port: 5000
    instance_count: 1  # Start with 1
    # or auto-scale:
    instance_size_slug: basic-xs  # Upgrade if needed
```

### Database Backups
- DigitalOcean automatically backs up managed databases daily
- Retention: 7 days (free), 30 days (paid)
- **Backup Settings** → **Backup** in database console

---

## 🔄 Step 6: Continuous Deployment

### Auto-Deploy on GitHub Push (Default)
- Configured automatically if you used GitHub in Step 2
- Push to `main` branch → App Platform auto-builds and deploys
- No additional configuration needed!

### Manual Deployment (if needed)
```bash
# Redeploy latest code:
doctl apps create-deployment YOUR-APP-ID
```

---

## 💰 Estimated Costs (After $200 Credits)

| Component | Cost/Month | Notes |
|---|---|---|
| App Platform (web) | $12 | Basic-S instance, perfect for startups |
| PostgreSQL Database | $15 | Starter plan (1GB RAM, 1 Core, 10GB storage) |
| **Total** | **$27** | $200 credits last ~7-8 months |

**Pro Tip:** With $200 credits, you get **7-8 months free hosting**. Upgrade components as you scale!

---

## ✅ Verification Checklist

After deployment:

- [ ] App loads at `https://your-app.ondigitalocean.app`
- [ ] Admin login works
- [ ] Products display on homepage
- [ ] Cart functionality works
- [ ] Payment initialization works (Paystack mock or real)
- [ ] Real-time tracking (Socket.IO) connects
- [ ] Database logs show schema was created
- [ ] HTTPS is enabled (browser shows green lock)
- [ ] Deployed app logs are accessible in DigitalOcean console

---

## 🆘 Troubleshooting

### App Won't Start
```
Check logs in DigitalOcean console:
Apps → Your App → Logs

Common issues:
- Missing environment variables
- DATABASE_URL incorrect format
- Port 5000 already in use
```

### Database Connection Failed
```
Check DATABASE_URL:
- Ensure format: postgresql://user:password@host:port/dbname?sslmode=require
- Verify database is in same VPC as app
- Check firewall rules allow connection
```

### Slow Performance
```
1. Increase instance size: Apps → Your App → Settings
2. Enable database connection pooling (built-in)
3. Check CPU/Memory usage in Metrics tab
4. Add CDN for static assets (optional)
```

### SSL/HTTPS Issues
```
- DigitalOcean handles automatically
- Custom domain: Update DNS records per instructions
- Certificate renews automatically
```

---

## 📚 Useful Resources

- **DigitalOcean App Platform Docs**: https://docs.digitalocean.com/products/app-platform/
- **Managed Database Docs**: https://docs.digitalocean.com/products/databases/
- **doctl CLI Reference**: https://docs.digitalocean.com/reference/doctl/
- **GitHub Student Pack**: https://education.github.com/pack

---

## 🎯 Next Steps

1. ✅ Redeem GitHub Student Pack credits
2. ✅ Connect GitHub repository to App Platform
3. ✅ Create PostgreSQL database
4. ✅ Deploy app (automatically builds and deploys)
5. ✅ Initialize database schema (`npm run db:push`)
6. ✅ Create super admin account
7. ✅ Configure payment and storage in admin panel
8. ✅ Test end-to-end workflows
9. ✅ Set up custom domain (optional)
10. ✅ Monitor logs and metrics

---

## 🚀 Quick Deploy Command (If Using doctl CLI)

```bash
# One-line deployment (requires doctl auth setup)
doctl apps create-deployment YOUR-APP-ID --force-build
```

---

**Deployment Complete! 🎉**

Your KiyuMart platform is now live on DigitalOcean with automatic HTTPS, managed PostgreSQL, and auto-scaling ready.

For questions, refer to the **DigitalOcean documentation** or check your app logs in the console.

---

*Last Updated: November 26, 2025*
