# Cerberus Chain: Hydra - Development Setup Script
# Run this from the project root: .\scripts\setup.ps1

Write-Host "🐺 Setting up Cerberus Chain: Hydra Development Environment..." -ForegroundColor Cyan

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow

# Check Rust
try {
    $rustVersion = rustc --version
    Write-Host "✅ Rust: $rustVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Rust not found. Please install Rust from https://rustup.rs/" -ForegroundColor Red
    exit 1
}

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Check Docker
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Docker not found. Install Docker for containerized development." -ForegroundColor Yellow
}

# Setup environment file
if (-not (Test-Path ".env")) {
    Write-Host "📄 Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ Created .env file. Please edit it with your configuration." -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Install backend dependencies
Write-Host "🦀 Installing Rust dependencies..." -ForegroundColor Yellow
Set-Location "backend"
cargo check
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install backend dependencies" -ForegroundColor Red
    Set-Location ".."
    exit 1
}
Set-Location ".."

# Install frontend dependencies
Write-Host "⚛️ Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location "frontend"
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install frontend dependencies" -ForegroundColor Red
    Set-Location ".."
    exit 1
}
Set-Location ".."

Write-Host ""
Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Edit .env file with your Helius API key and other secrets" -ForegroundColor White
Write-Host "  2. Start PostgreSQL and Redis (or use Docker Compose)" -ForegroundColor White
Write-Host "  3. Run backend: cd backend && cargo run" -ForegroundColor White
Write-Host "  4. Run frontend: cd frontend && npm run dev" -ForegroundColor White
Write-Host "  5. Or use Docker: docker-compose up -d" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready to build the future of memecoin trading!" -ForegroundColor Cyan