# Setup Local PostgreSQL Database (Docker)
# Use this as a fallback if Supabase connection keeps failing

Write-Host "🏠 Setting up Local PostgreSQL Database" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 This will set up a local PostgreSQL database for development" -ForegroundColor Yellow
Write-Host "   Use this if Supabase connection keeps timing out" -ForegroundColor Gray
Write-Host ""

# Check if Docker is available
Write-Host "🐳 Checking for Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
        $useDocker = $true
    } else {
        $useDocker = $false
    }
} catch {
    $useDocker = $false
}

if (-not $useDocker) {
    Write-Host "❌ Docker not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Please install Docker Desktop:" -ForegroundColor Yellow
    Write-Host "   1. Go to: https://www.docker.com/products/docker-desktop" -ForegroundColor White
    Write-Host "   2. Download and install Docker Desktop" -ForegroundColor White
    Write-Host "   3. Start Docker Desktop" -ForegroundColor White
    Write-Host "   4. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "🔄 Alternative: Install PostgreSQL directly" -ForegroundColor Cyan
    Write-Host "   Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "🚀 Starting local PostgreSQL with Docker..." -ForegroundColor Yellow

# Stop any existing container
Write-Host "   Cleaning up existing containers..." -ForegroundColor Gray
docker stop cerberus-postgres 2>$null | Out-Null
docker rm cerberus-postgres 2>$null | Out-Null

# Start PostgreSQL container
Write-Host "   Starting PostgreSQL container..." -ForegroundColor Gray
$dockerCommand = "docker run -d --name cerberus-postgres -e POSTGRES_DB=cerberus_hydra -e POSTGRES_USER=cerberus -e POSTGRES_PASSWORD=CerberusLocal2024! -p 5432:5432 postgres:15-alpine"

Invoke-Expression $dockerCommand | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PostgreSQL container started successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start PostgreSQL container" -ForegroundColor Red
    Write-Host "💡 Make sure Docker Desktop is running" -ForegroundColor Yellow
    exit 1
}

# Wait for PostgreSQL to be ready
Write-Host "   Waiting for PostgreSQL to be ready..." -ForegroundColor Gray
$maxAttempts = 30
$attempt = 0

do {
    Start-Sleep -Seconds 2
    $attempt++
    $ready = docker exec cerberus-postgres pg_isready -U cerberus -d cerberus_hydra 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL is ready!" -ForegroundColor Green
        break
    }
    Write-Host "      Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ PostgreSQL failed to start within timeout" -ForegroundColor Red
    exit 1
}

# Create the database schema
Write-Host "   Creating database schema..." -ForegroundColor Gray
$createSchema = @"
-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP WITH TIME ZONE
);

-- Create wallets table
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    public_key VARCHAR(44) UNIQUE NOT NULL,
    encrypted_private_key TEXT NOT NULL,
    encryption_nonce VARCHAR(32) NOT NULL,
    wallet_type VARCHAR(20) DEFAULT 'trading',
    sol_balance DECIMAL(20,9) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_balance_update TIMESTAMP WITH TIME ZONE
);

-- Create other tables...
CREATE TABLE IF NOT EXISTS trades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    token_address VARCHAR(44) NOT NULL,
    token_symbol VARCHAR(20),
    trade_type VARCHAR(10) NOT NULL,
    sol_amount DECIMAL(20,9) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bot_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bot_type VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT false,
    config_json JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

# Write schema to temp file and execute
$schemaFile = "temp_schema.sql"
$createSchema | Out-File -FilePath $schemaFile -Encoding UTF8

docker exec -i cerberus-postgres psql -U cerberus -d cerberus_hydra < $schemaFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database schema created successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Schema creation had some issues, but continuing..." -ForegroundColor Yellow
}

# Clean up temp file
Remove-Item $schemaFile -ErrorAction SilentlyContinue

# Update .env file
Write-Host "   Updating .env file for local database..." -ForegroundColor Gray

$localDatabaseUrl = "postgresql://cerberus:CerberusLocal2024!@localhost:5432/cerberus_hydra"

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$localDatabaseUrl"
    $envContent | Set-Content ".env" -NoNewline
} else {
    $newEnvContent = @"
# Cerberus Chain: Hydra Environment Configuration (LOCAL DATABASE)

# Local PostgreSQL Database
DATABASE_URL=$localDatabaseUrl

# JWT Authentication
JWT_SECRET=cerberus_local_development_secret_key
JWT_EXPIRATION_HOURS=24

# Server Configuration
BIND_ADDRESS=0.0.0.0:8080
ENVIRONMENT=development
"@
    $newEnvContent | Set-Content ".env"
}

Write-Host "✅ Updated .env file for local database" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 Local Database Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Local Database Details:" -ForegroundColor Cyan
Write-Host "   Host: localhost" -ForegroundColor White
Write-Host "   Port: 5432" -ForegroundColor White
Write-Host "   Database: cerberus_hydra" -ForegroundColor White
Write-Host "   Username: cerberus" -ForegroundColor White
Write-Host "   Password: CerberusLocal2024!" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Cyan
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 Useful Docker commands:" -ForegroundColor Yellow
Write-Host "   Start:  docker start cerberus-postgres" -ForegroundColor Gray
Write-Host "   Stop:   docker stop cerberus-postgres" -ForegroundColor Gray
Write-Host "   Logs:   docker logs cerberus-postgres" -ForegroundColor Gray
Write-Host "   Shell:  docker exec -it cerberus-postgres psql -U cerberus -d cerberus_hydra" -ForegroundColor Gray