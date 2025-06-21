# Get Supabase Database Password and Fix Connection
# Follow these steps to get your password and fix the connection

Write-Host "🔐 Getting Your Supabase Database Password" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 Step 1: Get Your Database Password" -ForegroundColor Yellow
Write-Host "   You're already on the right page! I can see the Database Settings." -ForegroundColor Gray
Write-Host ""
Write-Host "   Option A - If you can see the password:" -ForegroundColor Green
Write-Host "   • Look for a field showing your current password" -ForegroundColor White
Write-Host "   • Copy that password" -ForegroundColor White
Write-Host ""
Write-Host "   Option B - Reset the password:" -ForegroundColor Green
Write-Host "   • Click the green 'Reset database password' button" -ForegroundColor White
Write-Host "   • Generate a new password" -ForegroundColor White
Write-Host "   • Copy the new password" -ForegroundColor White
Write-Host ""

Write-Host "📋 Step 2: Update Your .env File" -ForegroundColor Yellow
Write-Host "   Once you have the password, run this script:" -ForegroundColor Gray
Write-Host ""

# Check if .env exists and show current status
if (Test-Path ".env") {
    Write-Host "✅ .env file found" -ForegroundColor Green
    $envContent = Get-Content ".env" -Raw
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    if ($databaseLine) {
        Write-Host "📋 Current DATABASE_URL:" -ForegroundColor Gray
        Write-Host "   $databaseLine" -ForegroundColor White
    }
} else {
    Write-Host "❌ .env file not found - will create one" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔧 What this script will do when you have the password:" -ForegroundColor Cyan
Write-Host "   1. Update your .env file with the correct connection string" -ForegroundColor White
Write-Host "   2. Use the proper username format: postgres.bervahrnaauhznctodie" -ForegroundColor White
Write-Host "   3. Use the pooler connection for better reliability" -ForegroundColor White
Write-Host ""

Write-Host "💡 Ready to continue? Get your password and then:" -ForegroundColor Green
Write-Host "   1. Come back to this terminal" -ForegroundColor White
Write-Host "   2. Run: .\update-env-with-password.ps1" -ForegroundColor White
Write-Host "   3. Enter your password when prompted" -ForegroundColor White