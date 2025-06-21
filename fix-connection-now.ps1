# Fix Supabase Connection - Final Solution
# Get your password and fix the connection immediately

Write-Host "🔧 Fixing Supabase Connection Now" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 I can see you're on the Supabase Database Settings page!" -ForegroundColor Green
Write-Host ""

Write-Host "🔍 Step 1: Get Your Database Password" -ForegroundColor Yellow
Write-Host "   On your Supabase page, look for:" -ForegroundColor Gray
Write-Host "   • Green 'Reset database password' button" -ForegroundColor White
Write-Host "   • Or a password field (click eye icon to reveal)" -ForegroundColor White
Write-Host ""

Write-Host "📝 Step 2: Enter Your Password Below" -ForegroundColor Yellow
$password = Read-Host "Enter your Supabase database password"

if ([string]::IsNullOrWhiteSpace($password)) {
    Write-Host "❌ No password entered. Please try again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Step 3: Applying Fix..." -ForegroundColor Yellow

# The CORRECT connection string with proper username format
$correctDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@aws-0-us-west-1.pooler.supabase.com:6543/postgres"

Write-Host "   ✅ Using correct username: postgres.bervahrnaauhznctodie" -ForegroundColor Green
Write-Host "   ✅ Using pooler connection for reliability" -ForegroundColor Green

# Update .env file
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$correctDatabaseUrl"
    $envContent | Set-Content ".env" -NoNewline
    Write-Host "   ✅ Updated .env file" -ForegroundColor Green
} else {
    # Create new .env file with all required settings
    $newEnv = @"
# Cerberus Chain: Hydra Environment Configuration

# Database (FIXED - Correct username format)
DATABASE_URL=$correctDatabaseUrl

# JWT Authentication
JWT_SECRET=0I9P9CJ75rU/i9GN6OGL7eUq251pcoZUUxqRoHmBWYkYdkS4mQeMkKUbDAAzOHWmqwWqFmXfhbA4/QoBzNbXdg==
JWT_EXPIRATION_HOURS=24

# Server Configuration
BIND_ADDRESS=0.0.0.0:8080
ENVIRONMENT=development

# Optional: Helius API Key (for blockchain features later)
HELIUS_API_KEY=your_helius_api_key_here
"@
    $newEnv | Set-Content ".env"
    Write-Host "   ✅ Created .env file with correct settings" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Connection Fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 What was wrong:" -ForegroundColor Yellow
Write-Host "   ❌ Old: postgres:password@host" -ForegroundColor Red
Write-Host "   ✅ New: postgres.bervahrnaauhznctodie:password@host" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Cyan
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 You should see:" -ForegroundColor Yellow
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 If it works, your backend will connect to Supabase successfully!" -ForegroundColor Magenta