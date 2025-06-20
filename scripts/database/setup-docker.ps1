# Cerberus Chain: Hydra - Docker Database Setup
# This script sets up PostgreSQL using Docker for development

Write-Host "🐺 Setting up Cerberus Chain: Hydra Database with Docker..." -ForegroundColor Cyan

# Check if Docker is installed
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not found. Please install Docker first." -ForegroundColor Red
    Write-Host "💡 Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Database configuration
$CONTAINER_NAME = "cerberus-postgres"
$DB_NAME = "cerberus_hydra"
$DB_USER = "cerberus"
$DB_PASSWORD = "CerberusGuard2024!"
$DB_PORT = "5432"

Write-Host "📋 Database Configuration:" -ForegroundColor Yellow
Write-Host "  Container: $CONTAINER_NAME" -ForegroundColor Gray
Write-Host "  Database: $DB_NAME" -ForegroundColor Gray
Write-Host "  User: $DB_USER" -ForegroundColor Gray
Write-Host "  Port: $DB_PORT" -ForegroundColor Gray

# Stop and remove existing container if it exists
Write-Host "🧹 Cleaning up existing container..." -ForegroundColor Yellow
docker stop $CONTAINER_NAME 2>$null
docker rm $CONTAINER_NAME 2>$null

# Start PostgreSQL container
Write-Host "🚀 Starting PostgreSQL container..." -ForegroundColor Yellow
docker run -d `
  --name $CONTAINER_NAME `
  -e POSTGRES_DB=$DB_NAME `
  -e POSTGRES_USER=$DB_USER `
  -e POSTGRES_PASSWORD=$DB_PASSWORD `
  -p "${DB_PORT}:5432" `
  -v cerberus_postgres_data:/var/lib/postgresql/data `
  postgres:15-alpine

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PostgreSQL container started successfully" -ForegroundColor Green
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
    $ready = docker exec $CONTAINER_NAME pg_isready -U $DB_USER -d $DB_NAME 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL is ready!" -ForegroundColor Green
        break
    }
    Write-Host "  Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ PostgreSQL failed to start within timeout" -ForegroundColor Red
    exit 1
}

# Run migrations
Write-Host "📊 Running database migrations..." -ForegroundColor Yellow
$migrationFile = "database/migrations/001_initial_schema.sql"

if (Test-Path $migrationFile) {
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < $migrationFile
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
$databaseUrl = "postgresql://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}"

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
Write-Host "🎉 Docker database setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Connection Details:" -ForegroundColor Yellow
Write-Host "  URL: $databaseUrl" -ForegroundColor White
Write-Host "  Container: $CONTAINER_NAME" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Useful Docker commands:" -ForegroundColor Cyan
Write-Host "  Start:  docker start $CONTAINER_NAME" -ForegroundColor Gray
Write-Host "  Stop:   docker stop $CONTAINER_NAME" -ForegroundColor Gray
Write-Host "  Logs:   docker logs $CONTAINER_NAME" -ForegroundColor Gray
Write-Host "  Shell:  docker exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Ready to start the backend server!" -ForegroundColor Green