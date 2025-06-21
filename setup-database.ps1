# Setup Cerberus Chain Database on Local PostgreSQL
# Run this to create the database and tables

Write-Host "🐺 Setting up Cerberus Chain Database" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 Using your PostgreSQL installation:" -ForegroundColor Yellow
Write-Host "   Host: localhost" -ForegroundColor White
Write-Host "   Port: 5432" -ForegroundColor White
Write-Host "   User: postgres" -ForegroundColor White
Write-Host "   Password: Il9ARNhYSNnj98xa" -ForegroundColor White
Write-Host ""

# Test connection first
Write-Host "🧪 Testing PostgreSQL connection..." -ForegroundColor Yellow
$env:PGPASSWORD = "Il9ARNhYSNnj98xa"

try {
    $testResult = psql -h localhost -p 5432 -U postgres -d postgres -c "SELECT 1;" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL connection: WORKING" -ForegroundColor Green
    } else {
        Write-Host "❌ PostgreSQL connection: FAILED" -ForegroundColor Red
        Write-Host "💡 Make sure PostgreSQL service is running" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ PostgreSQL connection: FAILED" -ForegroundColor Red
    Write-Host "💡 Make sure PostgreSQL is installed and running" -ForegroundColor Yellow
    exit 1
}

# Create database and tables
Write-Host "🗄️ Creating Cerberus Chain database..." -ForegroundColor Yellow
try {
    psql -h localhost -p 5432 -U postgres -d postgres -f setup-cerberus-database.sql
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database and tables created successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create database" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Failed to create database" -ForegroundColor Red
    exit 1
}

# Update .env for cerberus_hydra database
Write-Host "📝 Updating .env for cerberus_hydra database..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=postgresql://postgres:Il9ARNhYSNnj98xa@localhost:5432/cerberus_hydra"
    $envContent | Set-Content ".env" -NoNewline
    Write-Host "✅ Updated .env file" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Cerberus Chain Database Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Database Details:" -ForegroundColor Cyan
Write-Host "   Database: cerberus_hydra" -ForegroundColor White
Write-Host "   Host: localhost:5432" -ForegroundColor White
Write-Host "   Username: postgres" -ForegroundColor White
Write-Host "   Tables: users, wallets, trades, bot_configs, user_sessions, audit_logs" -ForegroundColor White
Write-Host ""
Write-Host "👤 Default Admin User:" -ForegroundColor Cyan
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: CerberusAdmin2024!" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Yellow
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 No more network issues - everything is local!" -ForegroundColor Magenta