#!/bin/bash

# KiyuMart Deployment Readiness Checker
# Validates that all required configuration is in place before deployment

echo "🔍 KiyuMart Deployment Readiness Check"
echo "======================================="
echo ""

ERRORS=0
WARNINGS=0

# Check if .env exists
echo "1. Checking environment configuration..."
if [ ! -f .env ]; then
    echo "   ❌ ERROR: .env file not found"
    echo "      Run: ./setup-env.sh or copy .env.example to .env"
    ((ERRORS++))
else
    echo "   ✅ .env file exists"
    
    # Check required environment variables
    source .env
    
    REQUIRED_VARS=(
        "DATABASE_URL"
        "CLOUDINARY_CLOUD_NAME"
        "CLOUDINARY_API_KEY"
        "CLOUDINARY_API_SECRET"
        "PAYSTACK_SECRET_KEY"
        "PAYSTACK_PUBLIC_KEY"
        "JWT_SECRET"
        "SESSION_SECRET"
    )
    
    for var in "${REQUIRED_VARS[@]}"; do
        if [ -z "${!var}" ]; then
            echo "   ❌ ERROR: $var is not set in .env"
            ((ERRORS++))
        else
            # Check if it's still the example value
            if [[ "${!var}" == *"your_"* ]] || [[ "${!var}" == *"_here"* ]]; then
                echo "   ⚠️  WARNING: $var appears to be using example value"
                ((WARNINGS++))
            else
                echo "   ✅ $var is configured"
            fi
        fi
    done
fi

echo ""
echo "2. Checking Node.js version..."
NODE_VERSION=$(node -v)
if [[ $NODE_VERSION == v18* ]] || [[ $NODE_VERSION == v20* ]] || [[ $NODE_VERSION == v22* ]]; then
    echo "   ✅ Node.js $NODE_VERSION (compatible)"
else
    echo "   ⚠️  WARNING: Node.js $NODE_VERSION (recommended: 18, 20, or 22)"
    ((WARNINGS++))
fi

echo ""
echo "3. Checking dependencies..."
if [ -d "node_modules" ]; then
    echo "   ✅ node_modules directory exists"
else
    echo "   ❌ ERROR: node_modules not found. Run: npm install"
    ((ERRORS++))
fi

echo ""
echo "4. Checking configuration files..."

CONFIG_FILES=(
    "package.json"
    "drizzle.config.ts"
    "vite.config.ts"
    "tsconfig.json"
    "netlify.toml"
    "render.yaml"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ ERROR: $file not found"
        ((ERRORS++))
    fi
done

echo ""
echo "5. Checking deployment documentation..."

DOCS=(
    "DEPLOYMENT.md"
    "DEPLOYMENT_CHECKLIST.md"
    "README.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo "   ✅ $doc exists"
    else
        echo "   ⚠️  WARNING: $doc not found"
        ((WARNINGS++))
    fi
done

echo ""
echo "6. Checking database connection..."
if command -v psql &> /dev/null; then
    if [ ! -z "$DATABASE_URL" ]; then
        # Try to connect to database (timeout after 5 seconds)
        timeout 5 psql "$DATABASE_URL" -c "SELECT 1;" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "   ✅ Database connection successful"
        else
            echo "   ⚠️  WARNING: Could not connect to database"
            echo "      Make sure your database is running and DATABASE_URL is correct"
            ((WARNINGS++))
        fi
    else
        echo "   ⚠️  WARNING: DATABASE_URL not set, cannot test connection"
        ((WARNINGS++))
    fi
else
    echo "   ℹ️  INFO: psql not installed, skipping database connection test"
fi

echo ""
echo "7. Checking build capability..."
echo "   Running test build..."
npm run build &> /tmp/build-check.log
if [ $? -eq 0 ]; then
    echo "   ✅ Build successful"
else
    echo "   ❌ ERROR: Build failed"
    echo "      Check /tmp/build-check.log for details"
    ((ERRORS++))
fi

echo ""
echo "8. Checking TypeScript compilation..."
npm run check &> /tmp/typecheck.log
if [ $? -eq 0 ]; then
    echo "   ✅ TypeScript check passed"
else
    echo "   ⚠️  WARNING: TypeScript errors found"
    echo "      Check /tmp/typecheck.log for details"
    ((WARNINGS++))
fi

echo ""
echo "9. Checking Git status..."
if git rev-parse --git-dir &> /dev/null; then
    echo "   ✅ Git repository initialized"
    
    # Check if there are uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "   ⚠️  WARNING: You have uncommitted changes"
        echo "      Commit and push before deploying"
        ((WARNINGS++))
    else
        echo "   ✅ No uncommitted changes"
    fi
    
    # Check if connected to remote
    if git remote -v | grep -q origin; then
        echo "   ✅ Git remote 'origin' configured"
    else
        echo "   ⚠️  WARNING: No git remote configured"
        echo "      You'll need a GitHub repo for Netlify/Render deployment"
        ((WARNINGS++))
    fi
else
    echo "   ❌ ERROR: Not a git repository"
    echo "      Initialize with: git init"
    ((ERRORS++))
fi

echo ""
echo "10. Security checks..."

# Check if .env is in .gitignore
if [ -f .gitignore ]; then
    if grep -q "^\.env$" .gitignore; then
        echo "    ✅ .env is in .gitignore"
    else
        echo "    ❌ ERROR: .env is NOT in .gitignore"
        echo "       Add '.env' to .gitignore to prevent committing secrets"
        ((ERRORS++))
    fi
else
    echo "    ⚠️  WARNING: .gitignore not found"
    ((WARNINGS++))
fi

# Check for weak admin passwords
if [ ! -z "$SUPER_ADMIN_PASSWORD" ]; then
    if [[ "$SUPER_ADMIN_PASSWORD" == "admin"* ]] || [[ "$SUPER_ADMIN_PASSWORD" == "123"* ]]; then
        echo "    ⚠️  WARNING: Super admin password appears weak"
        echo "       Use strong passwords for production"
        ((WARNINGS++))
    else
        echo "    ✅ Admin passwords configured"
    fi
fi

echo ""
echo "======================================="
echo "📊 Summary"
echo "======================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED!"
    echo ""
    echo "Your application is ready for deployment! 🚀"
    echo ""
    echo "Next steps:"
    echo "  1. Review DEPLOYMENT.md for deployment instructions"
    echo "  2. Use DEPLOYMENT_CHECKLIST.md to track progress"
    echo "  3. Deploy to Render (backend) and Netlify (frontend)"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  PASSED WITH WARNINGS"
    echo ""
    echo "Warnings: $WARNINGS"
    echo ""
    echo "Your application can be deployed, but please review the warnings above."
    echo ""
    exit 0
else
    echo "❌ CHECKS FAILED"
    echo ""
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"
    echo ""
    echo "Please fix the errors above before deploying."
    echo ""
    exit 1
fi
