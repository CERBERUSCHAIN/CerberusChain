# Fix Supabase Connection Script
# This will update your .env with the correct Supabase connection details

Write-Host "🔧 Fixing Supabase Connection..." -ForegroundColor Cyan

# Check if .env exists
if (Test-Path ".env") {
    Write-Host "✅ Found .env file" -ForegroundColor Green
    
    # Read current content
    $envContent = Get-Content ".env" -Raw
    
    # The correct DATABASE_URL based on your Supabase settings
    $correctDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:[YOUR_DB_PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres"
    
    Write-Host "🔍 Current DATABASE_URL issues:" -ForegroundColor Yellow
    Write-Host "   1. Wrong username format (should be postgres.bervahrnaauhznctodie)" -ForegroundColor Red
    Write-Host "   2. Wrong password (need your actual Supabase password)" -ForegroundColor Red
    Write-Host "   3. Wrong host (should use pooler)" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "🎯 CRITICAL: You need to get your database password from Supabase!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Steps to get your password:" -ForegroundColor Yellow
    Write-Host "   1. Go to https://supabase.com/dashboard" -ForegroundColor White
    Write-Host "   2. Select your project: bervahrnaauhznctodie" -ForegroundColor White
    Write-Host "   3. Go to Settings → Database" -ForegroundColor White
    Write-Host "   4. Look for 'Database password' or 'Connection string'" -ForegroundColor White
    Write-Host "   5. Copy the password" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 Then update your .env file with this format:" -ForegroundColor Cyan
    Write-Host "DATABASE_URL=postgresql://postgres.bervahrnaauhznctodie:[YOUR_PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Alternative: Try using the direct connection:" -ForegroundColor Yellow
    Write-Host "DATABASE_URL=postgresql://postgres.bervahrnaauhznctodie:[YOUR_PASSWORD]@db.bervahrnaauhznctodie.supabase.co:5432/postgres" -ForegroundColor Gray
    
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    Write-Host "🔧 Creating template .env file..." -ForegroundColor Yellow
    
    $templateEnv = @"
# Cerberus Chain: Hydra Environment Configuration

# Database - UPDATE WITH YOUR ACTUAL SUPABASE PASSWORD!
DATABASE_URL=postgresql://postgres.bervahrnaauhznctodie:[YOUR_DB_PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres

# JWT Authentication  
JWT_SECRET=0I9P9CJ75rU/i9GN6OGL7eUq251pcoZUUxqRoHmBWYkYdkS4mQeMkKUbDAAzOHWmqwWqFmXfhbA4/QoBzNbXdg==
JWT_EXPIRATION_HOURS=24

# Helius Configuration (Optional)
HELIUS_API_KEY=your_helius_api_key_here

# Server Configuration
BIND_ADDRESS=0.0.0.0:8080
ENVIRONMENT=development
"@
    
    $templateEnv | Set-Content ".env"
    Write-Host "✅ Created template .env file" -ForegroundColor Green
}

Write-Host ""
Write-Host "🚨 ACTION REQUIRED:" -ForegroundColor Red
Write-Host "   1. Get your database password from Supabase Dashboard" -ForegroundColor White
Write-Host "   2. Replace [YOUR_DB_PASSWORD] in the .env file" -ForegroundColor White
Write-Host "   3. Save the file" -ForegroundColor White
Write-Host "   4. Run: cd backend && cargo run" -ForegroundColor White