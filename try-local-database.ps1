# Set up local PostgreSQL database as fallback
# Use this if Supabase connection continues to fail

Write-Host "🏠 Setting up Local PostgreSQL Database" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 This will set up a local PostgreSQL database for development" -ForegroundColor Yellow
Write-Host "   Use this if Supabase connection keeps failing" -ForegroundColor Gray
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
    Write-Host "💡 Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔄 Alternative: Install PostgreSQL directly" -ForegroundColor Cyan
    Write-Host "   Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "🚀 Starting local PostgreSQL with Docker..." -ForegroundColor Yellow

# Stop any existing container
docker stop cerberus-postgres 2>$null
docker rm cerberus-postgres 2>$null

# Start PostgreSQL container
$containerCommand = @"
docker run -d \
  --name cerberus-postgres \
  -e POSTGRES_DB=cerberus_hydra \
  -e POSTGRES_USER=cerberus \
  -e POSTGRES_PASSWORD=CerberusLocal2024! \
  -p 5432:5432 \
  postgres:15-alpine
"@

Write-Host "📦 Starting PostgreSQL container..." -ForegroundColor Gray
Invoke-Expression $containerCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PostgreSQL container started successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start PostgreSQL container" -ForegroundColor Red
    exit 1
}

# Wait for PostgreSQL to be ready
Write-Host "⏳ Waiting for PostgreSQL to be ready..." -ForegroundColor Yellow
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
    Write-Host "   Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ PostgreSQL failed to start within timeout" -ForegroundColor Red
    exit 1
}

# Update .env file
Write-Host "📝 Updating .env file for local database..." -ForegroundColor Yellow

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
Write-Host "📋 Local Database Details:" -ForegroundColor Cyan
Write-Host "   Host: localhost" -ForegroundColor White
Write-Host "   Port: 5432" -ForegroundColor White
Write-Host "   Database: cerberus_hydra" -ForegroundColor White
Write-Host "   Username: cerberus" -ForegroundColor White
Write-Host "   Password: CerberusLocal2024!" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Test the local connection:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   cargo run" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Useful Docker commands:" -ForegroundColor Yellow
Write-Host "   Start:  docker start cerberus-postgres" -ForegroundColor Gray
Write-Host "   Stop:   docker stop cerberus-postgres" -ForegroundColor Gray
Write-Host "   Logs:   docker logs cerberus-postgres" -ForegroundColor Gray
Write-Host "   Shell:  docker exec -it cerberus-postgres psql -U cerberus -d cerberus_hydra" -ForegroundColor Gray