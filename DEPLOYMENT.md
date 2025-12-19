# KiyuMart Deployment Guide

Complete guide for deploying KiyuMart to production using Supabase (Database), Netlify (Frontend), Cloudinary (Media), and Render (Backend).

## Architecture Overview

- **Frontend**: Netlify (React + Vite)
- **Backend**: Render (Node.js + Express)
- **Database**: Supabase (PostgreSQL)
- **Media Storage**: Cloudinary (Images & Videos)
- **Payment**: Paystack

---

## Prerequisites

1. GitHub account (for code repository)
2. Supabase account
3. Netlify account
4. Render account
5. Cloudinary account
6. Paystack account (for payments)

---

## Step 1: Setup Supabase Database

### 1.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Enter project details:
   - **Name**: kiyumart
   - **Database Password**: (Save this securely!)
   - **Region**: Choose closest to your users
4. Wait for project to be created

### 1.2 Get Database Connection String

1. In your Supabase project, go to **Settings** → **Database**
2. Scroll to **Connection String** section
3. Select **URI** tab
4. Copy the connection string (looks like):
   ```
   postgresql://postgres.[project-ref]:[YOUR-PASSWORD]@aws-0-[region].pooler.supabase.com:6543/postgres
   ```
5. Replace `[YOUR-PASSWORD]` with your actual database password
6. **Save this for later** - you'll need it for Render

### 1.3 Enable Connection Pooler (Recommended)

1. In Supabase Dashboard → **Database** → **Connection Pooler**
2. Enable pooler mode (Transaction or Session mode)
3. Use the pooler connection string for better performance

---

## Step 2: Setup Cloudinary (Media Storage)

### 2.1 Create Cloudinary Account

1. Go to [cloudinary.com](https://cloudinary.com)
2. Sign up for a free account
3. Verify your email

### 2.2 Get API Credentials

1. Go to Cloudinary Dashboard
2. Note down:
   - **Cloud Name**: (visible at top)
   - **API Key**: (in API Keys section)
   - **API Secret**: (in API Keys section, click "Reveal")
3. **Save these for later**

### 2.3 Configure Upload Presets (Optional)

1. Go to **Settings** → **Upload**
2. Create upload presets for better control:
   - `kiyumart-images`: For product images
   - `kiyumart-videos`: For product videos

---

## Step 3: Deploy Backend to Render

### 3.1 Prepare Repository

1. Push your code to GitHub:
   ```bash
   git add .
   git commit -m "Prepare for deployment"
   git push origin main
   ```

### 3.2 Create Render Web Service

1. Go to [render.com](https://render.com)
2. Click **New** → **Web Service**
3. Connect your GitHub repository
4. Select your `kiyuMart` repository
5. Configure service:
   - **Name**: `kiyumart-backend`
   - **Region**: Choose closest to your users
   - **Branch**: `main`
   - **Root Directory**: (leave empty)
   - **Environment**: `Node`
   - **Build Command**: `npm ci --include=dev && npm run build`
   - **Start Command**: `npm run start`
   - **Plan**: Select plan (Free or Starter)

### 3.3 Add Environment Variables

In Render dashboard, add these environment variables:

```bash
# Node Environment
NODE_ENV=production
PORT=5000

# Database (from Supabase)
DATABASE_URL=your_supabase_connection_string_here

# Cloudinary (from Step 2)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Paystack (get from paystack.com)
PAYSTACK_SECRET_KEY=your_paystack_secret_key
PAYSTACK_PUBLIC_KEY=your_paystack_public_key

# Security (generate strong random strings)
JWT_SECRET=your_super_secret_jwt_key_here
SESSION_SECRET=your_super_secret_session_key_here

# Admin Credentials (set strong passwords!)
SUPER_ADMIN_EMAIL=superadmin@kiyumart.com
SUPER_ADMIN_PASSWORD=YourStrongPasswordHere
ADMIN_EMAIL=admin@kiyumart.com
ADMIN_PASSWORD=AnotherStrongPasswordHere
```

**To generate secure secrets:**
```bash
# Run in your terminal to generate random secrets
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 3.4 Deploy

1. Click **Create Web Service**
2. Wait for deployment to complete
3. Note your backend URL (e.g., `https://kiyumart-backend.onrender.com`)
4. Test health endpoint: `https://your-backend-url.onrender.com/api/health`

### 3.5 Run Database Migrations

After first deployment, you need to push database schema to Supabase:

1. In Render dashboard, go to **Shell** tab
2. Run migration:
   ```bash
   npm run db:push
   ```
3. Confirm the migration

---

## Step 4: Deploy Frontend to Netlify

### 4.1 Update API Endpoint

1. Update `netlify.toml` with your Render backend URL:
   ```toml
   [[redirects]]
     from = "/api/*"
     to = "https://your-backend-url.onrender.com/api/:splat"
     status = 200
     force = true
   ```

2. If your frontend has a config file for API URL, update it:
   ```typescript
   // client/src/config.ts or similar
   export const API_URL = import.meta.env.PROD 
     ? 'https://your-backend-url.onrender.com'
     : 'http://localhost:5000';
   ```

3. Commit changes:
   ```bash
   git add netlify.toml
   git commit -m "Update API endpoint for production"
   git push origin main
   ```

### 4.2 Deploy to Netlify

#### Option A: Netlify Dashboard

1. Go to [netlify.com](https://netlify.com)
2. Click **Add new site** → **Import an existing project**
3. Connect to GitHub and select your repository
4. Configure build settings:
   - **Branch**: `main`
   - **Build command**: `npm run build`
   - **Publish directory**: `dist`
5. Click **Deploy site**

#### Option B: Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Initialize (from project root)
netlify init

# Deploy
netlify deploy --prod
```

### 4.3 Configure Custom Domain (Optional)

1. In Netlify dashboard → **Domain settings**
2. Add custom domain
3. Configure DNS records with your domain provider
4. Enable HTTPS (automatic with Netlify)

### 4.4 Add Environment Variables (if needed)

If your frontend needs env vars:

1. In Netlify dashboard → **Site settings** → **Environment variables**
2. Add variables like:
   ```
   VITE_API_URL=https://your-backend-url.onrender.com
   VITE_PAYSTACK_PUBLIC_KEY=your_paystack_public_key
   ```
3. Redeploy site

---

## Step 5: Configure CORS

Update backend CORS settings to allow your Netlify domain:

1. Edit `server/index.ts` or wherever CORS is configured
2. Add your Netlify URL to allowed origins:
   ```typescript
   app.use(cors({
     origin: [
       'http://localhost:5173',
       'https://your-site.netlify.app',
       'https://your-custom-domain.com'
     ],
     credentials: true
   }));
   ```
3. Push changes and redeploy on Render

---

## Step 6: Test Deployment

### 6.1 Test Checklist

- [ ] Frontend loads correctly
- [ ] Backend health endpoint responds
- [ ] User registration works
- [ ] User login works
- [ ] Image upload to Cloudinary works
- [ ] Video upload to Cloudinary works
- [ ] Database queries work
- [ ] Payment integration works

### 6.2 Common Issues

**Issue**: CORS errors
- **Solution**: Add Netlify URL to CORS origins in backend

**Issue**: Database connection fails
- **Solution**: Check DATABASE_URL is correct and Supabase allows connections

**Issue**: Images not uploading
- **Solution**: Verify Cloudinary credentials in Render environment variables

**Issue**: Build fails on Netlify
- **Solution**: Check build logs, ensure all dependencies are in package.json

---

## Step 7: Monitoring & Maintenance

### 7.1 Monitor Services

- **Render**: Check logs in Render dashboard
- **Netlify**: Check deploy logs and function logs
- **Supabase**: Monitor database usage in dashboard
- **Cloudinary**: Monitor storage and bandwidth usage

### 7.2 Database Backups

Supabase automatically backs up your database, but you can also:

1. In Supabase → **Database** → **Backups**
2. Enable point-in-time recovery
3. Download manual backups periodically

### 7.3 Performance Optimization

- Enable Cloudinary auto-optimization for images
- Use Supabase connection pooler
- Monitor Render performance metrics
- Set up CDN caching on Netlify

---

## Environment Variables Summary

### Backend (Render)

```bash
NODE_ENV=production
PORT=5000
DATABASE_URL=postgresql://...
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
PAYSTACK_SECRET_KEY=...
PAYSTACK_PUBLIC_KEY=...
JWT_SECRET=...
SESSION_SECRET=...
SUPER_ADMIN_EMAIL=...
SUPER_ADMIN_PASSWORD=...
ADMIN_EMAIL=...
ADMIN_PASSWORD=...
```

### Frontend (Netlify) - if needed

```bash
VITE_API_URL=https://your-backend-url.onrender.com
VITE_PAYSTACK_PUBLIC_KEY=...
```

---

## Quick Deploy Commands

### Update Backend
```bash
git add .
git commit -m "Update backend"
git push origin main
# Render auto-deploys on push
```

### Update Frontend
```bash
git add .
git commit -m "Update frontend"
git push origin main
# Netlify auto-deploys on push
```

### Manual Deploy Frontend
```bash
npm run build
netlify deploy --prod
```

---

## Support & Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Render Documentation](https://render.com/docs)
- [Netlify Documentation](https://docs.netlify.com)
- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Paystack Documentation](https://paystack.com/docs)

---

## Cost Estimate (Monthly)

- **Supabase Free Tier**: $0 (500MB database, 2GB transfer)
- **Render Free Tier**: $0 (spins down after inactivity) OR Starter: $7/month
- **Netlify Free Tier**: $0 (100GB bandwidth, 300 build minutes)
- **Cloudinary Free Tier**: $0 (25GB storage, 25GB bandwidth)
- **Total**: $0-7/month for starter deployment

For production traffic, expect costs to scale based on usage.

---

## Next Steps

1. Set up monitoring and alerts
2. Configure custom domains
3. Enable SSL certificates (automatic on Netlify/Render)
4. Set up staging environment
5. Configure CI/CD pipeline
6. Add error tracking (Sentry)
7. Set up analytics

---

**Deployment Date**: _____________

**Deployed URLs**:
- Frontend: https://_________________.netlify.app
- Backend: https://_________________.onrender.com
- Database: [Supabase Project Ref]

**Notes**:
_____________________________________________________________________________________
