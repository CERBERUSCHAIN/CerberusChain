# Cerberus Chain: Hydra - Development Readiness Check
# Run this to verify you're ready for the next phase

Write-Host "🐺 Cerberus Chain: Hydra - Development Readiness Check" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor White
Write-Host ""

$allGood = $true

# Check 1: Backend running
Write-Host "🔍 Checking Backend Status..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/" -TimeoutSec 5
    if ($response.status -eq "healthy") {
        Write-Host "✅ Backend is running and healthy" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Backend responded but status is: $($response.status)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Backend is not running on port 8080" -ForegroundColor Red
    Write-Host "   Please start it with: cd backend && cargo run" -ForegroundColor Gray
    $allGood = $false
}

# Check 2: Frontend running
Write-Host "🔍 Checking Frontend Status..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5173/" -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Frontend is running on port 5173" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Frontend is not running on port 5173" -ForegroundColor Red
    Write-Host "   Please start it with: cd frontend && npm run dev" -ForegroundColor Gray
    $allGood = $false
}

# Check 3: Environment file
Write-Host "🔍 Checking Environment Configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✅ .env file exists" -ForegroundColor Green
    
    # Check for critical settings
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "HELIUS_API_KEY=your_helius_api_key_here") {
        Write-Host "⚠️  Helius API key not configured yet" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Helius API key appears to be configured" -ForegroundColor Green
    }
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    $allGood = $false
}

# Check 4: Dependencies
Write-Host "🔍 Checking Dependencies..." -ForegroundColor Yellow
if (Test-Path "backend/Cargo.lock") {
    Write-Host "✅ Rust dependencies installed" -ForegroundColor Green
} else {
    Write-Host "⚠️  Rust dependencies may not be installed" -ForegroundColor Yellow
}

if (Test-Path "frontend/node_modules") {
    Write-Host "✅ Node.js dependencies installed" -ForegroundColor Green
} else {
    Write-Host "⚠️  Node.js dependencies may not be installed" -ForegroundColor Yellow
}

Write-Host ""
if ($allGood) {
    Write-Host "🎉 All systems ready for next development phase!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 You can now choose your next development path:" -ForegroundColor Cyan
    Write-Host "   A) Database Integration (Recommended)" -ForegroundColor White
    Write-Host "   B) Helius Integration" -ForegroundColor White
    Write-Host "   C) Basic Trading Bot" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Run: .\scripts\next-steps.ps1 for detailed options" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  Please fix the issues above before proceeding" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Quick fixes:" -ForegroundColor Yellow
    Write-Host "   • Start backend: cd backend && cargo run" -ForegroundColor White
    Write-Host "   • Start frontend: cd frontend && npm run dev" -ForegroundColor White
    Write-Host "   • Create .env: copy .env.example .env" -ForegroundColor White
}