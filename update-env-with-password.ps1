# Update .env with Supabase Database Password
# Run this after you get your password from Supabase

Write-Host "🔐 Update .env with Supabase Password" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor White
Write-Host ""

# Prompt for password
Write-Host "📝 Please enter your Supabase database password:" -ForegroundColor Yellow
Write-Host "   (The one you just copied from the Supabase dashboard)" -ForegroundColor Gray
$password = Read-Host "Password"

if ([string]::IsNullOrWhiteSpace($password)) {
    Write-Host "❌ No password entered. Exiting..." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Updating .env file..." -ForegroundColor Yellow

# Create the correct DATABASE_URL
$databaseUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@aws-0-us-west-1.pooler.supabase.com:6543/postgres"

# Check if .env exists
if (Test-Path ".env") {
    # Read current content
    $envContent = Get-Content ".env" -Raw
    
    # Update or add DATABASE_URL
    if ($envContent -match "DATABASE_URL=") {
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$databaseUrl"
        Write-Host "✅ Updated existing DATABASE_URL" -ForegroundColor Green
    } else {
        $envContent += "`nDATABASE_URL=$databaseUrl"
        Write-Host "✅ Added DATABASE_URL to existing .env" -ForegroundColor Green
    }
    
    # Write back to file
    $envContent | Set-Content ".env" -NoNewline
} else {
    # Create new .env file
    $newEnvContent = @"
# Cerberus Chain: Hydra Environment Configuration

# Database (Supabase with correct password)
DATABASE_URL=$databaseUrl

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
    Write-Host "✅ Created new .env file" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Configuration Updated Successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Connection Details:" -ForegroundColor Cyan
Write-Host "   Host: aws-0-us-west-1.pooler.supabase.com" -ForegroundColor White
Write-Host "   Port: 6543" -ForegroundColor White
Write-Host "   Database: postgres" -ForegroundColor White
Write-Host "   Username: postgres.bervahrnaauhznctodie" -ForegroundColor White
Write-Host "   Password: [HIDDEN]" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Now test the connection:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   cargo run" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 If it still doesn't work, try the direct connection:" -ForegroundColor Yellow
Write-Host "   Run: .\try-direct-connection.ps1" -ForegroundColor Gray