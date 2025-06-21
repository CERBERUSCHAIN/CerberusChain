# Check and Fix .env Database Connection
# This script will check your current .env and fix the database connection

Write-Host "🔍 Checking .env file..." -ForegroundColor Cyan

if (Test-Path ".env") {
    Write-Host "✅ .env file found" -ForegroundColor Green
    
    # Read current content
    $envContent = Get-Content ".env" -Raw
    Write-Host "📋 Current DATABASE_URL in .env:" -ForegroundColor Yellow
    
    # Extract DATABASE_URL line
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    if ($databaseLine) {
        Write-Host "   $databaseLine" -ForegroundColor Gray
        
        # Check if it has the correct format
        if ($databaseLine -match "postgres\.bervahrnaauhznctodie") {
            Write-Host "✅ Username format is correct" -ForegroundColor Green
        } else {
            Write-Host "❌ Username format is WRONG" -ForegroundColor Red
            Write-Host "🔧 Fixing the username format..." -ForegroundColor Yellow
            
            # Fix the DATABASE_URL
            $fixedContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=postgresql://postgres.bervahrnaauhznctodie:CerberusGuard2024!@aws-0-us-west-1.pooler.supabase.com:6543/postgres"
            
            # Write back to file
            $fixedContent | Set-Content ".env" -NoNewline
            Write-Host "✅ Fixed DATABASE_URL in .env file" -ForegroundColor Green
            Write-Host "📋 New DATABASE_URL:" -ForegroundColor Yellow
            Write-Host "   DATABASE_URL=postgresql://postgres.bervahrnaauhznctodie:CerberusGuard2024!@aws-0-us-west-1.pooler.supabase.com:6543/postgres" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ No DATABASE_URL found in .env" -ForegroundColor Red
        Write-Host "🔧 Adding DATABASE_URL to .env..." -ForegroundColor Yellow
        
        # Add DATABASE_URL to the file
        $envContent += "`nDATABASE_URL=postgresql://postgres.bervahrnaauhznctodie:CerberusGuard2024!@aws-0-us-west-1.pooler.supabase.com:6543/postgres"
        $envContent | Set-Content ".env" -NoNewline
        Write-Host "✅ Added DATABASE_URL to .env file" -ForegroundColor Green
    }
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    Write-Host "🔧 Creating .env file..." -ForegroundColor Yellow
    
    # Create new .env file
    $newEnvContent = @"
# Cerberus Chain: Hydra Environment Configuration

# Database (FIXED - Correct username format for Supabase pooler)
DATABASE_URL=postgresql://postgres.bervahrnaauhznctodie:CerberusGuard2024!@aws-0-us-west-1.pooler.supabase.com:6543/postgres

# JWT Authentication
JWT_SECRET=cerberus_default_secret_change_in_production
JWT_EXPIRATION_HOURS=24

# Helius Configuration (Optional)
HELIUS_API_KEY=your_helius_api_key_here

# Server Configuration
BIND_ADDRESS=0.0.0.0:8080
ENVIRONMENT=development
"@
    
    $newEnvContent | Set-Content ".env"
    Write-Host "✅ Created .env file with correct DATABASE_URL" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎯 Key Fix Applied:" -ForegroundColor Cyan
Write-Host "   Username: postgres.bervahrnaauhznctodie (with dot, not colon)" -ForegroundColor White
Write-Host "   Host: aws-0-us-west-1.pooler.supabase.com" -ForegroundColor White
Write-Host "   Port: 6543 (pooler port)" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Now try running the backend:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   cargo run" -ForegroundColor Gray