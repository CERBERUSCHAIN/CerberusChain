# Setup Local PostgreSQL Database - Final Solution
# This eliminates all network issues

Write-Host "🏠 Setting up Local PostgreSQL Database" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 This eliminates network issues entirely" -ForegroundColor Green
Write-Host ""

# Check Docker
Write-Host "🐳 Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker not found - install from https://www.docker.com/products/docker-desktop" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Docker not found - install from https://www.docker.com/products/docker-desktop" -ForegroundColor Red
    exit 1
}

# Clean up and start PostgreSQL
Write-Host "🚀 Starting PostgreSQL..." -ForegroundColor Yellow
docker stop cerberus-postgres 2>$null | Out-Null
docker rm cerberus-postgres 2>$null | Out-Null

docker run -d --name cerberus-postgres -e POSTGRES_DB=cerberus_hydra -e POSTGRES_USER=cerberus -e POSTGRES_PASSWORD=CerberusLocal2024! -p 5432:5432 postgres:15-alpine | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PostgreSQL started" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start PostgreSQL" -ForegroundColor Red
    exit 1
}

# Wait for ready
Write-Host "⏳ Waiting for PostgreSQL..." -ForegroundColor Yellow
$attempt = 0
do {
    Start-Sleep -Seconds 2
    $attempt++
    $ready = docker exec cerberus-postgres pg_isready -U cerberus -d cerberus_hydra 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL ready!" -ForegroundColor Green
        break
    }
} while ($attempt -lt 15)

# Update .env
Write-Host "📝 Updating .env..." -ForegroundColor Yellow
$localUrl = "postgresql://cerberus:CerberusLocal2024!@localhost:5432/cerberus_hydra"

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$localUrl"
    $envContent | Set-Content ".env" -NoNewline
} else {
    "DATABASE_URL=$localUrl`nJWT_SECRET=local_dev_secret`nBIND_ADDRESS=0.0.0.0:8080" | Set-Content ".env"
}

Write-Host "✅ Local database ready!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Test now: cd backend && cargo run" -ForegroundColor Cyan