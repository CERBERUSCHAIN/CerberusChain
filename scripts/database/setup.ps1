# Cerberus Chain: Hydra - Database Setup Script
# This script sets up PostgreSQL database for development

Write-Host "🐺 Setting up Cerberus Chain: Hydra Database..." -ForegroundColor Cyan

# Check if PostgreSQL is installed
try {
    $pgVersion = psql --version
    Write-Host "✅ PostgreSQL found: $pgVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ PostgreSQL not found. Please install PostgreSQL first." -ForegroundColor Red
    Write-Host "💡 Download from: https://www.postgresql.org/download/" -ForegroundColor Yellow
    exit 1
}

# Database configuration
$DB_NAME = "cerberus_hydra"
$DB_USER = "cerberus"
$DB_PASSWORD = "CerberusGuard2024!"
$DB_HOST = "localhost"
$DB_PORT = "5432"

Write-Host "📋 Database Configuration:" -ForegroundColor Yellow
Write-Host "  Database: $DB_NAME" -ForegroundColor Gray
Write-Host "  User: $DB_USER" -ForegroundColor Gray
Write-Host "  Host: $DB_HOST" -ForegroundColor Gray
Write-Host "  Port: $DB_PORT" -ForegroundColor Gray

# Create database user
Write-Host "👤 Creating database user..." -ForegroundColor Yellow
$createUserCmd = "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
echo $createUserCmd | psql -U postgres -h $DB_HOST -p $DB_PORT

# Create database
Write-Host "🗄️ Creating database..." -ForegroundColor Yellow
$createDbCmd = "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
echo $createDbCmd | psql -U postgres -h $DB_HOST -p $DB_PORT

# Grant privileges
Write-Host "🔐 Granting privileges..." -ForegroundColor Yellow
$grantCmd = "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
echo $grantCmd | psql -U postgres -h $DB_HOST -p $DB_PORT

# Run migrations
Write-Host "📊 Running database migrations..." -ForegroundColor Yellow
$migrationFile = "database/migrations/001_initial_schema.sql"

if (Test-Path $migrationFile) {
    psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -f $migrationFile
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database migrations completed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Database migrations failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️ Migration file not found: $migrationFile" -ForegroundColor Yellow
}

# Update .env file
Write-Host "📝 Updating .env file..." -ForegroundColor Yellow
$databaseUrl = "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

if (Test-Path ".env") {
    # Update existing .env file
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "DATABASE_URL=") {
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$databaseUrl"
    } else {
        $envContent += "`nDATABASE_URL=$databaseUrl"
    }
    $envContent | Set-Content ".env"
    Write-Host "✅ .env file updated with database URL" -ForegroundColor Green
} else {
    Write-Host "⚠️ .env file not found. Please create it manually with:" -ForegroundColor Yellow
    Write-Host "DATABASE_URL=$databaseUrl" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🎉 Database setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Connection Details:" -ForegroundColor Yellow
Write-Host "  URL: $databaseUrl" -ForegroundColor White
Write-Host ""
Write-Host "🧪 Test the connection:" -ForegroundColor Cyan
Write-Host "  psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Ready to start the backend server!" -ForegroundColor Green