# Quick Start Guide - KiyuMart

## ✅ Current Status
- **Application**: Running on port 5000
- **Database**: PostgreSQL 16 (running)
- **Environment**: Development mode
- **Build**: Production-ready

## 🚀 Quick Start

### Start the Application
```bash
# Start PostgreSQL (if not running)
sudo service postgresql start

# Start development server
npm run dev
```

The application will be available at:
- **Frontend**: http://localhost:5000
- **API**: http://localhost:5000/api

### Test Accounts

All test accounts use password: `password123`

#### Super Admin
- Email: `super@kiyumart.com`
- Role: Super Admin
- Access: Full system access

#### Admin
- Email: `admin@kiyumart.com`
- Role: Admin
- Access: Administrative features

#### Sellers
- Email: `seller1@example.com` to `seller10@example.com`
- Role: Seller
- Access: Seller dashboard, product management

#### Riders
- Email: `rider1@example.com` to `rider5@example.com`
- Role: Rider
- Access: Delivery management, order tracking

#### Buyers
- Email: `buyer1@example.com` to `buyer20@example.com`
- Role: Buyer
- Access: Shopping, orders, reviews

## 🗄️ Database

### Connection Details
- **Host**: localhost
- **Port**: 5432
- **Database**: kiyumart
- **User**: kiyumart
- **Password**: kiyumart_dev_pass

### Schema Management
```bash
# Push schema changes to database
npm run db:push

# Generate migrations
npm run db:generate

# View database in Drizzle Studio
npm run db:studio
```

## 🛠️ Development Commands

```bash
# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# TypeScript type checking
npm run check

# Database operations
npm run db:push      # Apply schema to database
npm run db:generate  # Generate migration files
npm run db:studio    # Open Drizzle Studio
```

## 📁 Project Structure

```
client/src/          # React frontend
  ├── components/    # Reusable UI components
  ├── contexts/      # React context providers
  ├── hooks/         # Custom React hooks
  ├── lib/           # Utilities and helpers
  └── pages/         # Page components

server/              # Express backend
  ├── routes.ts      # API routes
  ├── storage.ts     # Database queries
  ├── auth.ts        # Authentication logic
  └── services/      # Business logic

db/                  # Database schema (Drizzle)
shared/              # Shared TypeScript types
attached_assets/     # Static assets (logos, images)
```

## 🎨 Theme

**Primary Color**: Green (`#16a34a`)
- HSL: `142.1 76.2% 36.3%`
- CSS Variable: `--primary`

Both light and dark modes are supported.

## 🔑 Environment Variables

Key variables in `.env`:
```env
DATABASE_URL=postgresql://kiyumart:kiyumart_dev_pass@localhost:5432/kiyumart
JWT_SECRET=your_secret_key
SESSION_SECRET=your_session_secret
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
PAYSTACK_SECRET_KEY=your_paystack_key
```

## 📦 Features

### Implemented
- ✅ Multi-vendor marketplace
- ✅ User authentication & authorization
- ✅ Product management
- ✅ Shopping cart & checkout
- ✅ Order management & tracking
- ✅ Real-time notifications (Socket.IO)
- ✅ Video/audio calling (WebRTC)
- ✅ Payment integration (Paystack)
- ✅ Admin dashboard
- ✅ Seller dashboard
- ✅ Rider dashboard
- ✅ Live order tracking with maps
- ✅ Review & rating system
- ✅ Wishlist functionality
- ✅ Delivery zones management
- ✅ Coupon system
- ✅ Branding customization
- ✅ Multi-language support
- ✅ Dark mode

## 🐛 Troubleshooting

### PostgreSQL not starting
```bash
sudo service postgresql start
sudo service postgresql status
```

### Port 5000 already in use
```bash
# Find process using port 5000
lsof -i :5000

# Kill the process
kill -9 <PID>
```

### Database connection failed
```bash
# Check PostgreSQL is running
sudo service postgresql status

# Verify database exists
psql -U kiyumart -d kiyumart -c "SELECT 1"

# Reset database (if needed)
npm run db:push
```

### Missing dependencies
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```

## 📝 Notes

- The codebase has been cleaned and optimized for production
- All temporary files and development artifacts have been removed
- Test data is seeded and ready for use
- Build caches have been cleared and refreshed
- TypeScript compilation is working (with some minor warnings)

## 🚨 Before Production Deployment

1. Change all default passwords
2. Update JWT and session secrets
3. Configure production database
4. Set up SSL/TLS certificates
5. Configure CORS for production domain
6. Review and update environment variables
7. Run security audit: `npm audit`
8. Enable production logging
9. Set up monitoring and error tracking
10. Configure CDN for static assets

## 📞 Support

For issues or questions, refer to:
- `README.md` - Main project documentation
- `CLEANUP_REPORT.md` - Recent changes and cleanup details
- Code comments within source files

---

**Last Updated**: December 10, 2024
**Status**: ✅ Production Ready
