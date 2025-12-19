#!/bin/bash

# KiyuMart Environment Setup Script
# This script helps you set up your .env file for local development

echo "🚀 KiyuMart Environment Setup"
echo "=============================="
echo ""

# Check if .env already exists
if [ -f .env ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " overwrite
    if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
        echo "❌ Setup cancelled. Your existing .env file is preserved."
        exit 0
    fi
    echo ""
fi

# Create .env file
echo "📝 Creating .env file..."
echo ""

# Database Configuration
echo "1️⃣  DATABASE CONFIGURATION"
echo "Choose your database:"
echo "  1) Local PostgreSQL"
echo "  2) Supabase (Production)"
echo "  3) Neon (Alternative cloud)"
read -p "Enter choice (1-3): " db_choice

case $db_choice in
    1)
        read -p "Enter local PostgreSQL URL [postgresql://postgres:postgres@localhost:5432/kiyumart]: " db_url
        db_url=${db_url:-postgresql://postgres:postgres@localhost:5432/kiyumart}
        ;;
    2)
        echo "Get your Supabase connection string from:"
        echo "  Dashboard → Settings → Database → Connection string (URI)"
        read -p "Enter Supabase DATABASE_URL: " db_url
        ;;
    3)
        echo "Get your Neon connection string from Neon dashboard"
        read -p "Enter Neon DATABASE_URL: " db_url
        ;;
    *)
        echo "Invalid choice. Using default local PostgreSQL."
        db_url="postgresql://postgres:postgres@localhost:5432/kiyumart"
        ;;
esac

echo ""
echo "2️⃣  CLOUDINARY CONFIGURATION (Media Storage)"
echo "Get credentials from: https://cloudinary.com/console"
read -p "Cloudinary Cloud Name: " cloudinary_name
read -p "Cloudinary API Key: " cloudinary_key
read -p "Cloudinary API Secret: " cloudinary_secret

echo ""
echo "3️⃣  PAYSTACK CONFIGURATION (Payments)"
echo "Get credentials from: https://dashboard.paystack.com/#/settings/developer"
read -p "Paystack Secret Key: " paystack_secret
read -p "Paystack Public Key: " paystack_public

echo ""
echo "4️⃣  SECURITY SECRETS"
echo "Generating secure random secrets..."

# Generate secrets using Node.js
jwt_secret=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
session_secret=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")

echo "✅ JWT Secret: Generated"
echo "✅ Session Secret: Generated"

echo ""
echo "5️⃣  ADMIN CREDENTIALS"
read -p "Super Admin Email [superadmin@kiyumart.com]: " super_admin_email
super_admin_email=${super_admin_email:-superadmin@kiyumart.com}
read -p "Super Admin Password [admin123]: " super_admin_password
super_admin_password=${super_admin_password:-admin123}

read -p "Admin Email [admin@kiyumart.com]: " admin_email
admin_email=${admin_email:-admin@kiyumart.com}
read -p "Admin Password [admin123]: " admin_password
admin_password=${admin_password:-admin123}

echo ""
echo "6️⃣  SERVER CONFIGURATION"
read -p "Port [5000]: " port
port=${port:-5000}

read -p "Node Environment [development]: " node_env
node_env=${node_env:-development}

# Write to .env file
cat > .env << EOL
# KiyuMart Environment Configuration
# Generated on: $(date)

# ============================================
# DATABASE CONFIGURATION
# ============================================
DATABASE_URL=$db_url

# ============================================
# CLOUDINARY CONFIGURATION (Media Storage)
# ============================================
CLOUDINARY_CLOUD_NAME=$cloudinary_name
CLOUDINARY_API_KEY=$cloudinary_key
CLOUDINARY_API_SECRET=$cloudinary_secret

# ============================================
# PAYSTACK CONFIGURATION (Payments)
# ============================================
PAYSTACK_SECRET_KEY=$paystack_secret
PAYSTACK_PUBLIC_KEY=$paystack_public

# ============================================
# SECURITY SECRETS
# ============================================
JWT_SECRET=$jwt_secret
SESSION_SECRET=$session_secret

# ============================================
# ADMIN CREDENTIALS
# ============================================
SUPER_ADMIN_EMAIL=$super_admin_email
SUPER_ADMIN_PASSWORD=$super_admin_password
ADMIN_EMAIL=$admin_email
ADMIN_PASSWORD=$admin_password

# ============================================
# SERVER CONFIGURATION
# ============================================
PORT=$port
NODE_ENV=$node_env

# ============================================
# OPTIONAL: SENTRY (Error Tracking)
# ============================================
# NEXT_PUBLIC_SENTRY_DSN=

EOL

echo ""
echo "✅ Environment file created successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Review your .env file"
echo "  2. Install dependencies: npm install"
echo "  3. Push database schema: npm run db:push"
echo "  4. Start development server: npm run dev"
echo ""
echo "🔒 Security reminder:"
echo "  - Never commit .env to git"
echo "  - Use strong passwords in production"
echo "  - Rotate secrets regularly"
echo ""
echo "📖 For deployment, see: DEPLOYMENT.md"
echo ""

# Offer to run database migration
read -p "Would you like to push the database schema now? (y/N): " run_migration
if [ "$run_migration" = "y" ] || [ "$run_migration" = "Y" ]; then
    echo ""
    echo "🗄️  Pushing database schema..."
    npm run db:push
fi

echo ""
echo "✨ Setup complete! Happy coding!"
