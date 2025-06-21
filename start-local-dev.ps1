# Start Local Development Environment
# Quick script to start everything for development

Write-Host "🚀 Starting Cerberus Chain: Hydra Development Environment" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor White
Write-Host ""

# Check if database is running
Write-Host "🗄️ Checking database..." -ForegroundColor Yellow
$dbRunning = docker ps --filter "name=cerberus-postgres" --filter "status=running" --quiet
if ($dbRunning) {
    Write-Host "✅ Database is already running" -ForegroundColor Green
} else {
    Write-Host "🔄 Starting database..." -ForegroundColor Yellow
    docker start cerberus-postgres | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database started" -ForegroundColor Green
        Start-Sleep -Seconds 3
    } else {
        Write-Host "❌ Failed to start database" -ForegroundColor Red
        Write-Host "💡 Run: .\setup-complete-local.ps1 first" -ForegroundColor Yellow
        exit 1
    }
}

# Test database connection
Write-Host "🧪 Testing database connection..." -ForegroundColor Yellow
$null = docker exec cerberus-postgres pg_isready -U cerberus -d cerberus_hydra 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database connection: WORKING" -ForegroundColor Green
} else {
    Write-Host "❌ Database connection: FAILED" -ForegroundColor Red
    exit 1
}

# Start backend in new window
Write-Host "🦀 Starting backend server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; Write-Host 'Starting Cerberus Chain Backend...' -ForegroundColor Cyan; cargo run"

# Wait a moment
Start-Sleep -Seconds 2

# Start frontend in new window
Write-Host "⚛️ Starting frontend server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd frontend; Write-Host 'Starting Cerberus Chain Frontend...' -ForegroundColor Cyan; npm run dev"

Write-Host ""
Write-Host "🎉 Development environment starting!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Services:" -ForegroundColor Cyan
Write-Host "   🗄️ Database:  Running on localhost:5432" -ForegroundColor White
Write-Host "   🦀 Backend:   Starting on http://localhost:8080" -ForegroundColor White
Write-Host "   ⚛️ Frontend:  Starting on http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "💡 Check the new PowerShell windows for server logs" -ForegroundColor Yellow
Write-Host "🌐 Open http://localhost:3000 in your browser" -ForegroundColor Cyan
Write-Host ""
Write-Host "🛑 To stop everything:" -ForegroundColor Red
Write-Host "   • Close the PowerShell windows" -ForegroundColor White
Write-Host "   • Run: docker stop cerberus-postgres" -ForegroundColor White