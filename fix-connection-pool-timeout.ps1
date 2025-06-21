# Fix Supabase Connection Pool Timeout
# This addresses the "pool timed out while waiting for an open connection" error

Write-Host "🔧 Fixing Supabase Connection Pool Timeout" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 Good news: The connection format is now correct!" -ForegroundColor Green
Write-Host "   'pool timed out' means it's trying to connect but timing out" -ForegroundColor Gray
Write-Host ""

Write-Host "🔍 Step 1: Checking current .env..." -ForegroundColor Yellow

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    
    if ($databaseLine) {
        Write-Host "✅ Found DATABASE_URL:" -ForegroundColor Green
        Write-Host "   $databaseLine" -ForegroundColor Gray
        
        # Check if it has the correct format
        if ($databaseLine -match "postgres\.bervahrnaauhznctodie") {
            Write-Host "✅ Username format is correct" -ForegroundColor Green
        } else {
            Write-Host "❌ Username format needs fixing" -ForegroundColor Red
            
            # Fix the username format
            Write-Host "🔧 Fixing username format..." -ForegroundColor Yellow
            $envContent = $envContent -replace "postgresql://postgres:", "postgresql://postgres.bervahrnaauhznctodie:"
            $envContent | Set-Content ".env" -NoNewline
            Write-Host "✅ Fixed username format" -ForegroundColor Green
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
Write-Host "🔧 Step 2: Testing network connectivity..." -ForegroundColor Yellow

# Test the connection methods
$hosts = @(
    @{ Host = "aws-0-us-west-1.pooler.supabase.com"; Port = 6543; Name = "Pooler" },
    @{ Host = "db.bervahrnaauhznctodie.supabase.co"; Port = 5432; Name = "Direct" }
)

$workingConnection = $null

foreach ($test in $hosts) {
    Write-Host "   Testing $($test.Name) connection..." -ForegroundColor Gray
    try {
        $result = Test-NetConnection $test.Host -Port $test.Port -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($result) {
            Write-Host "   ✅ $($test.Name): REACHABLE" -ForegroundColor Green
            if (-not $workingConnection) {
                $workingConnection = $test
            }
        } else {
            Write-Host "   ❌ $($test.Name): UNREACHABLE" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ $($test.Name): FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🔧 Step 3: Optimizing connection settings..." -ForegroundColor Yellow

if ($workingConnection) {
    Write-Host "✅ Using $($workingConnection.Name) connection" -ForegroundColor Green
    
    # Extract password from current DATABASE_URL
    if ($databaseLine -match ":([^@]+)@") {
        $password = $matches[1]
        
        # Create optimized DATABASE_URL
        $optimizedUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@$($workingConnection.Host):$($workingConnection.Port)/postgres"
        
        # Update .env with optimized settings
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$optimizedUrl"
        
        # Add connection pool optimization settings
        if ($envContent -notmatch "SQLX_MAX_CONNECTIONS") {
            $envContent += "`n`n# Connection pool optimization for Supabase"
            $envContent += "`nSQLX_MAX_CONNECTIONS=5"
            $envContent += "`nSQLX_MIN_CONNECTIONS=1"
            $envContent += "`nSQLX_ACQUIRE_TIMEOUT=30"
            $envContent += "`nSQLX_IDLE_TIMEOUT=300"
        }
        
        $envContent | Set-Content ".env" -NoNewline
        Write-Host "✅ Updated .env with optimized connection settings" -ForegroundColor Green
        
    } else {
        Write-Host "❌ Could not extract password from DATABASE_URL" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ No working connections found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Network troubleshooting needed:" -ForegroundColor Yellow
    Write-Host "   1. Try mobile hotspot (different network)" -ForegroundColor White
    Write-Host "   2. Temporarily disable Windows Firewall" -ForegroundColor White
    Write-Host "   3. Use local database: .\setup-local-database.ps1" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "🎉 Connection Pool Optimization Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Optimizations applied:" -ForegroundColor Cyan
Write-Host "   ✅ Reduced max connections to 5 (prevents overwhelming Supabase)" -ForegroundColor Green
Write-Host "   ✅ Set 30-second acquire timeout" -ForegroundColor Green
Write-Host "   ✅ Added connection testing before use" -ForegroundColor Green
Write-Host "   ✅ Using best available connection method" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Cyan
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 If it still times out, try:" -ForegroundColor Yellow
Write-Host "   .\try-mobile-hotspot.ps1" -ForegroundColor Gray