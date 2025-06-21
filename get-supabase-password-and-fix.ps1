# Get Supabase Password and Fix Connection (Complete Solution)
# This script will help you get the password and fix the connection

Write-Host "🔐 Supabase Password and Connection Fix" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 I can see you're on the Supabase Database Settings page!" -ForegroundColor Green
Write-Host "   Perfect! Now let's get your database password." -ForegroundColor Gray
Write-Host ""

Write-Host "🔍 Step 1: Get Your Database Password" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Look for one of these on your Supabase page:" -ForegroundColor Gray
Write-Host "   • A green button that says 'Reset database password'" -ForegroundColor White
Write-Host "   • A field showing your current password" -ForegroundColor White
Write-Host "   • A 'Generate new password' option" -ForegroundColor White
Write-Host ""

Write-Host "   If you see a password field with dots (••••••••):" -ForegroundColor Cyan
Write-Host "   • Click the 'eye' icon to reveal it" -ForegroundColor White
Write-Host "   • Copy the revealed password" -ForegroundColor White
Write-Host ""

Write-Host "   If you see a 'Reset database password' button:" -ForegroundColor Cyan
Write-Host "   • Click it to generate a new password" -ForegroundColor White
Write-Host "   • Copy the new password that appears" -ForegroundColor White
Write-Host ""

Write-Host "📝 Step 2: Enter Your Password Here" -ForegroundColor Yellow
Write-Host "   Once you have the password, enter it below:" -ForegroundColor Gray
Write-Host ""

$password = Read-Host "Enter your Supabase database password"

if ([string]::IsNullOrWhiteSpace($password)) {
    Write-Host "❌ No password entered. Please run this script again with your password." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Step 3: Testing and Fixing Connection..." -ForegroundColor Yellow

# Test both connection methods
$directUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@db.bervahrnaauhznctodie.supabase.co:5432/postgres"
$poolerUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@aws-0-us-west-1.pooler.supabase.com:6543/postgres"

Write-Host "   Testing direct connection..." -ForegroundColor Gray
$directTest = Test-NetConnection "db.bervahrnaauhznctodie.supabase.co" -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue

Write-Host "   Testing pooler connection..." -ForegroundColor Gray
$poolerTest = Test-NetConnection "aws-0-us-west-1.pooler.supabase.com" -Port 6543 -InformationLevel Quiet -WarningAction SilentlyContinue

# Choose the best connection
if ($poolerTest) {
    $chosenUrl = $poolerUrl
    $connectionType = "Pooler (Recommended)"
    Write-Host "   ✅ Using pooler connection (more reliable)" -ForegroundColor Green
} elseif ($directTest) {
    $chosenUrl = $directUrl
    $connectionType = "Direct"
    Write-Host "   ✅ Using direct connection" -ForegroundColor Green
} else {
    Write-Host "   ❌ Both connections failed - using pooler anyway" -ForegroundColor Red
    $chosenUrl = $poolerUrl
    $connectionType = "Pooler (Fallback)"
}

Write-Host ""
Write-Host "🔧 Step 4: Updating .env file..." -ForegroundColor Yellow

# Update or create .env file
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$chosenUrl"
    $envContent | Set-Content ".env" -NoNewline
    Write-Host "   ✅ Updated existing .env file" -ForegroundColor Green
} else {
    $newEnvContent = @"
# Cerberus Chain: Hydra Environment Configuration

# Database (Supabase with your password)
DATABASE_URL=$chosenUrl

# JWT Authentication
JWT_SECRET=0I9P9CJ75rU/i9GN6OGL7eUq251pcoZUUxqRoHmBWYkYdkS4mQeMkKUbDAAzOHWmqwWqFmXfhbA4/QoBzNbXdg==
JWT_EXPIRATION_HOURS=24

# Helius Configuration (Optional)
HELIUS_API_KEY=your_helius_api_key_here

# Server Configuration
BIND_ADDRESS=0.0.0.0:8080
ENVIRONMENT=development
"@
    $newEnvContent | Set-Content ".env"
    Write-Host "   ✅ Created new .env file" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Configuration Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Connection Details:" -ForegroundColor Cyan
Write-Host "   Type: $connectionType" -ForegroundColor White
Write-Host "   Username: postgres.bervahrnaauhznctodie" -ForegroundColor White
Write-Host "   Password: [HIDDEN]" -ForegroundColor White
Write-Host "   Database: postgres" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   cargo run" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Yellow
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 If it still doesn't work:" -ForegroundColor Cyan
Write-Host "   1. Try: .\quick-dns-fix-v2.ps1" -ForegroundColor Gray
Write-Host "   2. Or use local database: .\try-local-database.ps1" -ForegroundColor Gray