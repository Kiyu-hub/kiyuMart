# KiyuMart Deployment Checklist

Use this checklist to ensure all steps are completed for a successful deployment.

## Pre-Deployment

- [ ] Code is tested locally
- [ ] All features working correctly
- [ ] No console errors in development
- [ ] Environment variables documented
- [ ] Database schema is finalized
- [ ] Git repository is up to date

## Supabase Setup

- [ ] Supabase project created
- [ ] Database password saved securely
- [ ] Connection string obtained
- [ ] Connection pooler enabled (optional but recommended)
- [ ] SSL mode configured

## Cloudinary Setup

- [ ] Cloudinary account created
- [ ] Cloud name noted
- [ ] API key obtained
- [ ] API secret obtained (and kept secure)
- [ ] Upload folders planned (kiyumart/products, kiyumart/profiles, etc.)

## Backend Deployment (Render)

- [ ] GitHub repository connected to Render
- [ ] Web service created
- [ ] Build command configured: `npm ci --include=dev && npm run build`
- [ ] Start command configured: `npm run start`
- [ ] All environment variables added:
  - [ ] NODE_ENV=production
  - [ ] PORT=5000
  - [ ] DATABASE_URL
  - [ ] CLOUDINARY_CLOUD_NAME
  - [ ] CLOUDINARY_API_KEY
  - [ ] CLOUDINARY_API_SECRET
  - [ ] PAYSTACK_SECRET_KEY
  - [ ] PAYSTACK_PUBLIC_KEY
  - [ ] JWT_SECRET (generated securely)
  - [ ] SESSION_SECRET (generated securely)
  - [ ] SUPER_ADMIN_EMAIL
  - [ ] SUPER_ADMIN_PASSWORD
  - [ ] ADMIN_EMAIL
  - [ ] ADMIN_PASSWORD
- [ ] First deployment completed
- [ ] Database migrations run (`npm run db:push`)
- [ ] Health endpoint tested (https://your-backend.onrender.com/api/health)
- [ ] Backend URL noted for frontend configuration

## Frontend Deployment (Netlify)

- [ ] netlify.toml updated with backend URL
- [ ] API endpoint configuration updated
- [ ] GitHub repository connected to Netlify
- [ ] Build settings configured:
  - [ ] Build command: `npm run build`
  - [ ] Publish directory: `dist`
  - [ ] Base directory: `/`
- [ ] Environment variables added (if any)
- [ ] Site deployed successfully
- [ ] Custom domain configured (optional)
- [ ] HTTPS enabled
- [ ] Frontend URL noted

## Post-Deployment Configuration

- [ ] CORS configured with Netlify URL in backend
- [ ] Backend redeployed with CORS changes
- [ ] API proxy tested (frontend → backend)

## Testing

- [ ] Frontend loads without errors
- [ ] User can register new account
- [ ] User can login
- [ ] Image upload works
- [ ] Video upload works
- [ ] Product creation works
- [ ] Payment integration works (test mode)
- [ ] All major features tested
- [ ] Mobile responsiveness verified
- [ ] Different browsers tested (Chrome, Firefox, Safari)

## Monitoring Setup

- [ ] Render logs accessible
- [ ] Netlify deploy logs checked
- [ ] Supabase dashboard accessible
- [ ] Cloudinary usage dashboard accessible
- [ ] Error tracking configured (optional - Sentry)
- [ ] Analytics configured (optional - Google Analytics)

## Security

- [ ] All secrets stored securely
- [ ] Environment variables never committed to git
- [ ] Strong passwords set for admin accounts
- [ ] HTTPS enabled on all endpoints
- [ ] CORS properly configured
- [ ] Rate limiting configured
- [ ] SQL injection protection verified (using Drizzle ORM)
- [ ] XSS protection headers set

## Documentation

- [ ] README.md updated with deployment info
- [ ] DEPLOYMENT.md reviewed
- [ ] Environment variables documented
- [ ] API endpoints documented
- [ ] Admin credentials stored securely
- [ ] Deployment URLs recorded

## Backup & Recovery

- [ ] Supabase automatic backups enabled
- [ ] Manual database backup taken
- [ ] Cloudinary backup strategy understood
- [ ] Recovery plan documented

## Performance

- [ ] Cloudinary auto-optimization enabled
- [ ] Image formats optimized (WebP)
- [ ] Lazy loading implemented
- [ ] Database indexes reviewed
- [ ] API response times acceptable
- [ ] Frontend bundle size optimized

## Final Checks

- [ ] All checklist items completed
- [ ] Stakeholders notified of deployment
- [ ] Support team briefed
- [ ] Known issues documented
- [ ] Rollback plan prepared

---

## Deployment Information

**Deployment Date**: _____________

**Deployed By**: _____________

**Deployment URLs**:
- Frontend: https://_________________.netlify.app
- Backend: https://_________________.onrender.com

**Services Used**:
- Database: Supabase - Project Ref: _____________
- Media: Cloudinary - Cloud Name: _____________
- Payment: Paystack - Mode: [Test/Live]

**Admin Credentials**:
- Super Admin: (stored in password manager)
- Admin: (stored in password manager)

**Notes**:
_____________________________________________________________________________________
_____________________________________________________________________________________
_____________________________________________________________________________________

---

## Post-Deployment Tasks

- [ ] Monitor for 24 hours
- [ ] Check error logs daily for first week
- [ ] Gather user feedback
- [ ] Plan next iteration
- [ ] Schedule security audit
- [ ] Review performance metrics
