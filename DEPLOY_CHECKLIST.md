# DigitalOcean Deployment Checklist - KiyuMart

> Step-by-step checklist to get your app live on DigitalOcean. Follow in order.

---

## ✅ Step 1: Verify GitHub Student Pack Credits (Already Done? Skip to Step 2)

- [ ] Login to DigitalOcean dashboard at https://cloud.digitalocean.com
- [ ] Go to **Billing** → **Account** (top-right menu)
- [ ] Confirm you see **"$200 Credit"** in your account
- [ ] If no credits show, redeem via https://education.github.com/pack → DigitalOcean offer

---

## ✅ Step 2: Push KiyuMart Code to GitHub (Required!)

Before deploying, ensure your repo is on GitHub:

```bash
# From your local machine or Replit terminal
cd /workspaces/kiyuMart

# Check if repo is already on GitHub
git remote -v

# If not, add GitHub remote:
git remote add origin https://github.com/YOUR-USERNAME/kiyuMart.git
git branch -M main
git push -u origin main

# If you already have it, just push latest changes:
git push origin main
```

**Verify on GitHub:**
- Open https://github.com/YOUR-USERNAME/kiyuMart
- You should see all your files there

---

## ✅ Step 3: Create DigitalOcean App Platform Project

### 3A. Start New App

1. Login to DigitalOcean dashboard: https://cloud.digitalocean.com
2. Click **Create** (top-left, big blue button)
3. Select **App Platform**
4. Choose **GitHub** as the source

### 3B. Connect GitHub Repository

1. Click **Authorize with GitHub** (if not already connected)
2. Select your **kiyuMart** repository
3. Choose branch: **main**
4. Click **Next**

---

## ✅ Step 4: Configure App Platform

### 4A. Review Auto-Detected Settings

DigitalOcean should show:
- **Build Command**: `bash ./scripts/build.sh` (recommended, it installs devDependencies and runs the production build)
- **Run Command**: (should auto-detect from Dockerfile)
- **HTTP Port**: `5000`
- **Source Directory**: `/` (root)

✅ **If this looks correct, continue to Step 4B**

### 4B. Add Environment Variables

1. In App Platform config, scroll to **Environment Variables** section
2. Click **Edit** or **Add Variable**
3. Add these variables (copy-paste each):

```
NODE_ENV = production
```

Generate two secure random secrets:

**Option 1: Use these commands to generate secrets:**

```bash
# Generate SESSION_SECRET (run in terminal)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```
Copy the output (32-character hex string)

**Option 2: Or use these placeholder values (NOT secure, for testing only):**
```
SESSION_SECRET = 5f1a2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f
JWT_SECRET = 9f8e7d6c5b4a3c2d1e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
```

Add these to DigitalOcean:
```
SESSION_SECRET = <paste-your-generated-value>
JWT_SECRET = <paste-your-generated-value>
```

**Optional variables (can skip for now, set via Admin UI later):**
```
CLOUDINARY_CLOUD_NAME = (leave blank for now)
CLOUDINARY_API_KEY = (leave blank for now)
CLOUDINARY_API_SECRET = (leave blank for now)
PAYSTACK_PUBLIC_KEY = (leave blank for now)
PAYSTACK_SECRET_KEY = (leave blank for now)
```

### Node Version (Optional but recommended)
1. Add an `engines` field in `package.json` to lock the Node.js runtime used by DigitalOcean during build and runtime, for example:
```json
"engines": { "node": ">=18 <=22" }
```

---

## ✅ Step 5: Create & Configure PostgreSQL Database

### 5A. Create Managed Database

1. In App Platform config, click **+ Add a Database**
2. Choose **PostgreSQL**
3. Configure:
   - **Engine**: PostgreSQL (latest, usually 15 or 16)
   - **Database Name**: `kiyumart` (default is fine)
   - **Database Cluster Name**: `kiyumart-db-1`
   - **Region**: Same as your app (usually US East or US West)
4. Click **Create Database**

DigitalOcean will:
- Create the managed database (takes 2-3 minutes)
- Auto-inject `DATABASE_URL` environment variable
- You don't need to manually add it!

### 5B. Wait for Database to Be Ready

- DigitalOcean shows status "**Creating**" → "**Running**"
- Takes 2-3 minutes
- ✅ Continue when status shows **"Running"**

---

## ✅ Step 6: Deploy App

1. Review all settings one more time:
   - [ ] GitHub repo connected ✓
   - [ ] Environment variables set ✓
   - [ ] PostgreSQL database added ✓
   - [ ] HTTP Port is 5000 ✓

2. Click **Create App** button (bottom-right)

3. DigitalOcean will:
   - Clone your repo
   - Build Docker image (~5-10 minutes, first time takes longer)
   - Push to container registry
   - Deploy containers
   - Provision database
   - Show you a live URL

**Status to watch:**
- 🟡 "Building" (5-10 min) → 🟡 "Deploying" (2-3 min) → 🟢 "Active"

---

## ✅ Step 7: Get Your Live URL

Once deployment completes:

1. Look for **Live App URL** on your App Platform dashboard
   - Usually looks like: `https://kiyumart-xxxxx.ondigitalocean.app`

2. Click the link to open your live app!

3. **First load may take 30 seconds** (app starting up)

4. You should see:
   - KiyuMart homepage loads ✓
   - Products display (if seeded)
   - Header/navigation visible ✓
   - No database errors ✓

---

## ✅ Step 8: Initialize Database Schema

After first deployment, you need to set up the database tables.

### Option A: Use Browser (Easiest)

1. Open your live URL (from Step 7)
2. Go to: `https://YOUR-APP-URL.ondigitalocean.app/api/seed/test-users`
3. This runs the seed script and creates:
   - Database tables ✓
   - Test users ✓
   - Test products ✓
   - Sample data ✓

### Option B: Use Terminal (If Option A Doesn't Work)

Connect to your app via DigitalOcean console:
```bash
# In DigitalOcean console, or via terminal if you have SSH access
npm run db:push
```

---

## ✅ Step 9: Login to Admin Panel

1. Open your live app: `https://YOUR-APP-URL.ondigitalocean.app`
2. Click **Login** or go to `/auth`
3. Use test credentials (from database seed):
   ```
   Email: superadmin@kiyumart.com
   Password: superadmin123
   ```

4. After login, navigate to `/admin` to access admin dashboard

---

## ✅ Step 10: Configure Platform Settings

Now configure payment gateway and storage:

1. Go to **Admin Dashboard** → **Settings** (gear icon)
2. Fill in these sections:

### Platform Settings
- [ ] Platform Name: "KiyuMart" (or your name)
- [ ] Multi-Vendor Mode: Toggle ON/OFF based on your preference
- [ ] Default Currency: Choose GHS, NGN, EUR, etc.

### Payment Gateway (Paystack)
You need Paystack account:
1. Signup at https://paystack.com
2. Get your **Public Key** and **Secret Key**
3. Paste them in Admin Settings → Payment Gateway

For **testing**, use test keys (available after signup)

### Cloudinary (Image Storage)
You need Cloudinary account:
1. Signup at https://cloudinary.com
2. Get: **Cloud Name**, **API Key**, **API Secret**
3. Paste them in Admin Settings → Cloudinary

For **testing**, you can skip this (use default image handling)

### Contact Information
- [ ] Phone number
- [ ] Email address
- [ ] Business address
- [ ] Social media links (optional)

---

## ✅ Step 11: Test Key Features

Once everything is configured, test these flows:

- [ ] **Homepage**: Products load, categories visible
- [ ] **Product Page**: Click product, see details, images load
- [ ] **Add to Cart**: Click "Add to Cart", see item in cart
- [ ] **Login/Register**: Create new test account, login works
- [ ] **Orders**: Place a test order (mock payment)
- [ ] **Admin Dashboard**: Can view orders, products, users
- [ ] **Dark Mode**: Toggle theme in header, persists on reload
- [ ] **Mobile**: Open in mobile browser, layout responsive

---

## ✅ Step 12: Monitor Deployments

Your app now auto-deploys whenever you push to GitHub!

**To monitor:**
1. Go to your App Platform project in DigitalOcean
2. Click **Deployments** tab
3. See history of all deploys with timestamps
4. Check **Logs** if something breaks:
   - Scroll to see error messages
   - Common issues: missing env vars, database connection errors

---

## ✅ Step 13: Set Up Custom Domain (Optional)

If you own a domain (e.g., kiyumart.com):

1. In App Platform → **Settings** tab
2. Scroll to **Domains**
3. Add your domain
4. Update your domain's DNS records (DigitalOcean will show exact instructions)
5. Wait 24-48 hours for DNS to propagate
6. Your app is now at `https://yourdomain.com` with auto HTTPS!

---

## ✅ Step 14: Access Logs & Monitoring

View your app's performance:

1. App Platform → **Insights** tab
   - CPU usage
   - Memory usage
   - Network traffic
   - Request latency

2. **Logs** tab
   - Real-time server logs
   - Error messages
   - Deploy history

3. **Database**
   - Connection status
   - Storage usage
   - Backups

---

## 🎉 You're Live!

**Congratulations!** Your KiyuMart platform is now hosted on DigitalOcean with:
- ✅ Automatic HTTPS/SSL
- ✅ Managed PostgreSQL database
- ✅ Auto-scaling (if traffic increases)
- ✅ Daily backups
- ✅ $200 in free credits (7-8 months)
- ✅ Auto-deploy on every GitHub push

---

## 🆘 Troubleshooting

### "App won't start" or "Deployment failed"
1. Check **Logs** tab in App Platform
2. Look for error messages (usually missing env vars or DB connection)
3. Common fixes:
   - Missing `SESSION_SECRET` or `JWT_SECRET`
   - Database not ready yet (wait 2-3 min)
   - Typo in `DATABASE_URL`

### "Can't reach the app"
1. Wait for deployment to complete (check status)
2. Try refreshing browser (hard refresh: Ctrl+Shift+R)
3. Check app logs for errors

### "Products don't load / Empty homepage"
1. Run seed endpoint: `/api/seed/test-users`
2. Or run `npm run db:push` from terminal
3. Check database is running in DigitalOcean console

### "Can't upload images"
1. Add Cloudinary credentials in Admin Settings
2. Or use placeholder/mock images for now

### "Payment not working"
1. Add Paystack keys in Admin Settings
2. Use test keys for development (not production)

---

## 📞 Need Help?

- **DigitalOcean Docs**: https://docs.digitalocean.com/products/app-platform/
- **Check App Logs**: App Platform → Logs tab
- **Restart App**: App Platform → Settings → Restart App button

---

**Next Step:** Go to Step 2 and start deploying! 🚀
