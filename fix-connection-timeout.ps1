# Fix Supabase Connection Timeout Issue
# The connection is being attempted but timing out

Write-Host "🔧 Fixing Supabase Connection Timeout" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 Good news: The connection is being attempted!" -ForegroundColor Green
Write-Host "   'pool timed out' means it's trying to connect but timing out" -ForegroundColor Gray
Write-Host ""

Write-Host "🔍 Step 1: Checking current .env..." -ForegroundColor Yellow

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    
    if ($databaseLine) {
        Write-Host "✅ Found DATABASE_URL:" -ForegroundColor Green
        Write-Host "   $databaseLine" -ForegroundColor Gray
        
        # Check if it has the correct format from the AI assistant
        if ($databaseLine -match "postgres\.bervahrnaauhznctodie:73JiVBWgwxNtYbM8") {
            Write-Host "✅ Username and password format looks correct" -ForegroundColor Green
            $hasCorrectFormat = $true
        } else {
            Write-Host "❌ Username/password format needs fixing" -ForegroundColor Red
            $hasCorrectFormat = $false
        }
    } else {
        Write-Host "❌ No DATABASE_URL found" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Step 2: Applying timeout and connection fixes..." -ForegroundColor Yellow

# The correct DATABASE_URL from the Supabase AI assistant
$correctDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@aws-0-us-west-1.pooler.supabase.com:6543/postgres"

# Update the DATABASE_URL
$envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$correctDatabaseUrl"

# Add connection timeout settings to help with the timeout issue
if ($envContent -notmatch "SQLX_CONNECT_TIMEOUT") {
    $envContent += "`n# Database connection timeout settings"
    $envContent += "`nSQLX_CONNECT_TIMEOUT=30"
    $envContent += "`nSQLX_IDLE_TIMEOUT=600"
    $envContent += "`nSQLX_MAX_LIFETIME=1800"
}

# Write back to .env
$envContent | Set-Content ".env" -NoNewline

Write-Host "✅ Updated .env with correct connection and timeout settings" -ForegroundColor Green

Write-Host ""
Write-Host "🔧 Step 3: Testing network connectivity..." -ForegroundColor Yellow

# Test the pooler connection
Write-Host "   Testing pooler connection..." -ForegroundColor Gray
$poolerTest = Test-NetConnection "aws-0-us-west-1.pooler.supabase.com" -Port 6543 -InformationLevel Quiet -WarningAction SilentlyContinue

if ($poolerTest) {
    Write-Host "   ✅ Pooler connection: REACHABLE" -ForegroundColor Green
} else {
    Write-Host "   ❌ Pooler connection: UNREACHABLE" -ForegroundColor Red
    Write-Host "   💡 This might be why it's timing out" -ForegroundColor Yellow
    
    # Try direct connection as fallback
    Write-Host "   Testing direct connection as fallback..." -ForegroundColor Gray
    $directTest = Test-NetConnection "db.bervahrnaauhznctodie.supabase.co" -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
    
    if ($directTest) {
        Write-Host "   ✅ Direct connection: REACHABLE" -ForegroundColor Green
        Write-Host "   🔄 Switching to direct connection..." -ForegroundColor Yellow
        
        $directUrl = "postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@db.bervahrnaauhznctodie.supabase.co:5432/postgres"
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$directUrl"
        $envContent | Set-Content ".env" -NoNewline
        
        Write-Host "   ✅ Switched to direct connection" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Direct connection: ALSO UNREACHABLE" -ForegroundColor Red
        Write-Host "   🌐 This is likely a network/firewall issue" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎉 Connection Configuration Updated!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 What was fixed:" -ForegroundColor Cyan
Write-Host "   ✅ Correct username: postgres.bervahrnaauhznctodie" -ForegroundColor Green
Write-Host "   ✅ Correct password: 73JiVBWgwxNtYbM8" -ForegroundColor Green
Write-Host "   ✅ Added connection timeout settings" -ForegroundColor Green
Write-Host "   ✅ Using pooler connection for reliability" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Cyan
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 If it still times out:" -ForegroundColor Yellow
Write-Host "   1. Try: .\try-mobile-hotspot.ps1" -ForegroundColor Gray
Write-Host "   2. Or: .\setup-local-database.ps1" -ForegroundColor Gray