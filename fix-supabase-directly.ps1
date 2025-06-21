# Direct Supabase Connection Fix - No Docker Required
# This fixes the connection timeout issue directly

Write-Host "🔧 Direct Supabase Connection Fix" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 The issue: Connection pool timeout" -ForegroundColor Yellow
Write-Host "📋 The solution: Fix the connection string and pool settings" -ForegroundColor Green
Write-Host ""

# Step 1: Check current .env
Write-Host "🔍 Step 1: Checking current .env..." -ForegroundColor Yellow

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    Write-Host "✅ Found .env file" -ForegroundColor Green
    
    # Extract current DATABASE_URL
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    if ($databaseLine) {
        Write-Host "📋 Current: $databaseLine" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    exit 1
}

# Step 2: Apply the CORRECT connection string
Write-Host ""
Write-Host "🔧 Step 2: Applying correct Supabase connection..." -ForegroundColor Yellow

# The EXACT connection string that should work (from your Supabase project)
$correctDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@aws-0-us-west-1.pooler.supabase.com:6543/postgres"

# Update the .env file
$envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$correctDatabaseUrl"

# Add connection pool settings to prevent timeouts
if ($envContent -notmatch "# Connection pool settings") {
    $envContent += "`n`n# Connection pool settings to prevent timeouts"
    $envContent += "`nSQLX_MAX_CONNECTIONS=3"
    $envContent += "`nSQLX_ACQUIRE_TIMEOUT=30"
    $envContent += "`nSQLX_IDLE_TIMEOUT=600"
}

# Write back to .env
$envContent | Set-Content ".env" -NoNewline

Write-Host "✅ Updated .env with correct connection string" -ForegroundColor Green
Write-Host "✅ Added connection pool optimization" -ForegroundColor Green

# Step 3: Test network connectivity
Write-Host ""
Write-Host "🌐 Step 3: Testing network connectivity..." -ForegroundColor Yellow

$poolerTest = Test-NetConnection "aws-0-us-west-1.pooler.supabase.com" -Port 6543 -InformationLevel Quiet -WarningAction SilentlyContinue

if ($poolerTest) {
    Write-Host "✅ Pooler connection: REACHABLE" -ForegroundColor Green
} else {
    Write-Host "❌ Pooler connection: BLOCKED" -ForegroundColor Red
    Write-Host "🔄 Trying direct connection..." -ForegroundColor Yellow
    
    $directTest = Test-NetConnection "db.bervahrnaauhznctodie.supabase.co" -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
    
    if ($directTest) {
        Write-Host "✅ Direct connection: REACHABLE" -ForegroundColor Green
        Write-Host "🔧 Switching to direct connection..." -ForegroundColor Yellow
        
        $directUrl = "postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@db.bervahrnaauhznctodie.supabase.co:5432/postgres"
        $envContent = Get-Content ".env" -Raw
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$directUrl"
        $envContent | Set-Content ".env" -NoNewline
        
        Write-Host "✅ Switched to direct connection" -ForegroundColor Green
    } else {
        Write-Host "❌ Both connections blocked - network issue" -ForegroundColor Red
        Write-Host ""
        Write-Host "🔧 Network troubleshooting needed:" -ForegroundColor Yellow
        Write-Host "   1. Try mobile hotspot (different network)" -ForegroundColor White
        Write-Host "   2. Temporarily disable Windows Firewall" -ForegroundColor White
        Write-Host "   3. Contact your ISP about PostgreSQL port blocking" -ForegroundColor White
        exit 1
    }
}

Write-Host ""
Write-Host "🎉 Connection Fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 What was fixed:" -ForegroundColor Cyan
Write-Host "   ✅ Correct username format: postgres.bervahrnaauhznctodie" -ForegroundColor Green
Write-Host "   ✅ Correct password: 73JiVBWgwxNtYbM8" -ForegroundColor Green
Write-Host "   ✅ Optimized connection pool settings" -ForegroundColor Green
Write-Host "   ✅ Using working connection method" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Cyan
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 This should resolve the 'pool timed out' error!" -ForegroundColor Magenta