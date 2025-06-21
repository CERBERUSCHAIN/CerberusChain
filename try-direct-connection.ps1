# Try Direct Connection to Supabase (Alternative)
# Use this if the pooler connection doesn't work

Write-Host "🔄 Trying Direct Connection to Supabase" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor White
Write-Host ""

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env file not found. Run update-env-with-password.ps1 first." -ForegroundColor Red
    exit 1
}

# Read current .env
$envContent = Get-Content ".env" -Raw
$currentDbUrl = ($envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }) -replace "DATABASE_URL=", ""

if (-not $currentDbUrl) {
    Write-Host "❌ No DATABASE_URL found in .env" -ForegroundColor Red
    exit 1
}

# Extract password from current URL
if ($currentDbUrl -match "postgres\.bervahrnaauhznctodie:([^@]+)@") {
    $password = $matches[1]
    Write-Host "✅ Found password in current .env" -ForegroundColor Green
} else {
    Write-Host "❌ Could not extract password from current DATABASE_URL" -ForegroundColor Red
    Write-Host "📝 Please enter your Supabase database password:" -ForegroundColor Yellow
    $password = Read-Host "Password"
}

# Create direct connection URL
$directUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@db.bervahrnaauhznctodie.supabase.co:5432/postgres"

Write-Host ""
Write-Host "🔧 Updating .env with direct connection..." -ForegroundColor Yellow

# Update DATABASE_URL
$envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$directUrl"
$envContent | Set-Content ".env" -NoNewline

Write-Host "✅ Updated to direct connection" -ForegroundColor Green
Write-Host ""
Write-Host "📋 New Connection Details:" -ForegroundColor Cyan
Write-Host "   Host: db.bervahrnaauhznctodie.supabase.co" -ForegroundColor White
Write-Host "   Port: 5432" -ForegroundColor White
Write-Host "   Database: postgres" -ForegroundColor White
Write-Host "   Username: postgres.bervahrnaauhznctodie" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Test the connection:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   cargo run" -ForegroundColor Gray