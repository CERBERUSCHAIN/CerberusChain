# Cerberus Chain: Hydra - Development Server Script
# Run this from the project root: .\scripts\dev.ps1

Write-Host "🐺 Starting Cerberus Chain: Hydra Development Servers..." -ForegroundColor Cyan

# Function to start a process in a new window
function Start-DevServer {
    param(
        [string]$Title,
        [string]$Command,
        [string]$WorkingDirectory
    )
    
    Write-Host "🚀 Starting $Title..." -ForegroundColor Yellow
    
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "powershell.exe"
    $startInfo.Arguments = "-NoExit -Command `"cd '$WorkingDirectory'; $Command`""
    $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
    $startInfo.CreateNoWindow = $false
    
    [System.Diagnostics.Process]::Start($startInfo) | Out-Null
}

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env file not found. Please run .\scripts\setup.ps1 first" -ForegroundColor Red
    exit 1
}

# Start backend server
Start-DevServer -Title "Backend (Rust)" -Command "cargo run" -WorkingDirectory "$PWD\backend"

# Wait a moment
Start-Sleep -Seconds 2

# Start frontend server
Start-DevServer -Title "Frontend (SolidJS)" -Command "npm run dev" -WorkingDirectory "$PWD\frontend"

Write-Host ""
Write-Host "🎉 Development servers starting!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Server URLs:" -ForegroundColor Yellow
Write-Host "  Backend:  http://localhost:8080" -ForegroundColor White
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "💡 Check the new PowerShell windows for server logs" -ForegroundColor Cyan
Write-Host "🛑 Press Ctrl+C in each window to stop the servers" -ForegroundColor Yellow