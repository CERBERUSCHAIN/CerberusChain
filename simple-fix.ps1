# Simple Supabase Connection Fix (No Docker Required)
# Just get your password and fix the connection

Write-Host "🔧 Simple Supabase Connection Fix" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 You're on the Supabase Database Settings page - perfect!" -ForegroundColor Green
Write-Host ""

Write-Host "🔍 Step 1: Get Your Password" -ForegroundColor Yellow
Write-Host "   Look for:" -ForegroundColor Gray
Write-Host "   • Green 'Reset database password' button" -ForegroundColor White
Write-Host "   • Or a password field you can reveal" -ForegroundColor White
Write-Host ""

Write-Host "📝 Step 2: Enter Your Password" -ForegroundColor Yellow
$password = Read-Host "Paste your Supabase database password here"

if ([string]::IsNullOrWhiteSpace($password)) {
    Write-Host "❌ No password entered. Please try again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Step 3: Fixing Connection..." -ForegroundColor Yellow

# The correct connection string (using pooler for reliability)
$databaseUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@aws-0-us-west-1.pooler.supabase.com:6543/postgres"

# Update .env file
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$databaseUrl"
    $envContent | Set-Content ".env" -NoNewline
    Write-Host "✅ Updated .env file" -ForegroundColor Green
} else {
    # Create new .env file
    $newEnv = @"
DATABASE_URL=$databaseUrl
JWT_SECRET=0I9P9CJ75rU/i9GN6OGL7eUq251pcoZUUxqRoHmBWYkYdkS4mQeMkKUbDAAzOHWmqwWqFmXfhbA4/QoBzNbXdg==
JWT_EXPIRATION_HOURS=24
BIND_ADDRESS=0.0.0.0:8080
ENVIRONMENT=development
"@
    $newEnv | Set-Content ".env"
    Write-Host "✅ Created .env file" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Fixed! Now test it:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   cargo run" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 You should see:" -ForegroundColor Yellow
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green