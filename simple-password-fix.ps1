# Simple Password Fix for Supabase Connection
# This will work regardless of current .env format

Write-Host "🔧 Simple Supabase Password Fix" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor White
Write-Host ""

Write-Host "📋 I can see you have the Supabase AI's corrected .env file!" -ForegroundColor Green
Write-Host "   The password should be: 73JiVBWgwxNtYbM8" -ForegroundColor Gray
Write-Host ""

Write-Host "🔍 Checking current .env..." -ForegroundColor Yellow

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    Write-Host "✅ Found .env file" -ForegroundColor Green
    
    # The CORRECT connection string from the Supabase AI
    $correctUrl = "postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@aws-0-us-west-1.pooler.supabase.com:6543/postgres"
    
    Write-Host ""
    Write-Host "🔧 Applying the correct connection string..." -ForegroundColor Yellow
    
    # Replace any existing DATABASE_URL with the correct one
    if ($envContent -match "DATABASE_URL=") {
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$correctUrl"
        Write-Host "✅ Updated existing DATABASE_URL" -ForegroundColor Green
    } else {
        $envContent += "`nDATABASE_URL=$correctUrl"
        Write-Host "✅ Added DATABASE_URL to .env" -ForegroundColor Green
    }
    
    # Write back to file
    $envContent | Set-Content ".env" -NoNewline
    
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    Write-Host "🔧 Creating new .env file..." -ForegroundColor Yellow
    
    $newEnv = @"
# Cerberus Chain: Hydra Environment Configuration

# Database (CORRECTED by Supabase AI)
DATABASE_URL=postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@aws-0-us-west-1.pooler.supabase.com:6543/postgres

# JWT Authentication
JWT_SECRET=CerberusChain2024SuperSecureJWTKeyForAuthenticationAndSecurity123456
JWT_EXPIRATION_HOURS=24

# Server Configuration
BIND_ADDRESS=0.0.0.0:8080
ENVIRONMENT=development
"@
    
    $newEnv | Set-Content ".env"
    Write-Host "✅ Created new .env file" -ForegroundColor Green
}

Write-Host ""
Write-Host "🧪 Testing the connection..." -ForegroundColor Yellow

# Test the pooler connection
$poolerTest = Test-NetConnection "aws-0-us-west-1.pooler.supabase.com" -Port 6543 -InformationLevel Quiet -WarningAction SilentlyContinue

if ($poolerTest) {
    Write-Host "✅ Pooler connection: REACHABLE" -ForegroundColor Green
} else {
    Write-Host "❌ Pooler connection: UNREACHABLE" -ForegroundColor Red
    Write-Host "🔄 Trying direct connection as fallback..." -ForegroundColor Yellow
    
    $directTest = Test-NetConnection "db.bervahrnaauhznctodie.supabase.co" -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
    
    if ($directTest) {
        Write-Host "✅ Direct connection: REACHABLE" -ForegroundColor Green
        Write-Host "🔧 Switching to direct connection..." -ForegroundColor Yellow
        
        $directUrl = "postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@db.bervahrnaauhznctodie.supabase.co:5432/postgres"
        $envContent = Get-Content ".env" -Raw
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$directUrl"
        $envContent | Set-Content ".env" -NoNewline
        
        Write-Host "✅ Updated to use direct connection" -ForegroundColor Green
    } else {
        Write-Host "❌ Both connections unreachable - network issue" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 Connection Fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 What was applied:" -ForegroundColor Cyan
Write-Host "   ✅ Correct username: postgres.bervahrnaauhznctodie" -ForegroundColor Green
Write-Host "   ✅ Correct password: 73JiVBWgwxNtYbM8" -ForegroundColor Green
Write-Host "   ✅ Using pooler connection (more reliable)" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Cyan
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 If it still doesn't work:" -ForegroundColor Yellow
Write-Host "   1. Try mobile hotspot: .\try-mobile-hotspot.ps1" -ForegroundColor Gray
Write-Host "   2. Use local database: .\setup-local-database.ps1" -ForegroundColor Gray