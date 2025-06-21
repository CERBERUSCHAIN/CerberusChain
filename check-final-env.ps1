# Check Final .env Configuration
# Verify the .env file has the correct settings

Write-Host "🔍 Checking Final .env Configuration" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor White
Write-Host ""

if (Test-Path ".env") {
    Write-Host "✅ .env file found" -ForegroundColor Green
    Write-Host ""
    
    $envContent = Get-Content ".env" -Raw
    $lines = $envContent -split "`n"
    
    Write-Host "📋 Current .env contents:" -ForegroundColor Yellow
    foreach ($line in $lines) {
        if ($line -match "^DATABASE_URL=") {
            Write-Host "   $line" -ForegroundColor Green
        } elseif ($line -match "^[A-Z_]+=") {
            Write-Host "   $line" -ForegroundColor Gray
        } elseif ($line.Trim() -ne "") {
            Write-Host "   $line" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "🔍 Validation:" -ForegroundColor Yellow
    
    # Check DATABASE_URL
    $databaseLine = $lines | Where-Object { $_ -match "^DATABASE_URL=" }
    if ($databaseLine) {
        if ($databaseLine -match "postgres\.bervahrnaauhznctodie:73JiVBWgwxNtYbM8") {
            Write-Host "   ✅ DATABASE_URL: Correct format and password" -ForegroundColor Green
        } else {
            Write-Host "   ❌ DATABASE_URL: Incorrect format" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ DATABASE_URL: Missing" -ForegroundColor Red
    }
    
    # Check JWT_SECRET
    $jwtLine = $lines | Where-Object { $_ -match "^JWT_SECRET=" }
    if ($jwtLine) {
        Write-Host "   ✅ JWT_SECRET: Present" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  JWT_SECRET: Missing (will use default)" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    Write-Host "💡 Run: .\simple-password-fix.ps1" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 Ready to test? Run:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White