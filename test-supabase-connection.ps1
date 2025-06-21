# Test Supabase Connection
# Quick test to see if the connection is working

Write-Host "🧪 Testing Supabase Connection" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor White
Write-Host ""

Write-Host "📋 Testing network connectivity to Supabase..." -ForegroundColor Yellow

# Test DNS resolution
Write-Host "1. Testing DNS resolution..." -ForegroundColor Gray
$hosts = @(
    "db.bervahrnaauhznctodie.supabase.co",
    "aws-0-us-west-1.pooler.supabase.com"
)

foreach ($host in $hosts) {
    try {
        $result = Resolve-DnsName $host -ErrorAction Stop
        Write-Host "   ✅ $host - RESOLVED" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ $host - FAILED" -ForegroundColor Red
    }
}

# Test port connectivity
Write-Host ""
Write-Host "2. Testing port connectivity..." -ForegroundColor Gray
$connections = @(
    @{ Host = "db.bervahrnaauhznctodie.supabase.co"; Port = 5432; Name = "Direct" },
    @{ Host = "aws-0-us-west-1.pooler.supabase.com"; Port = 6543; Name = "Pooler" }
)

foreach ($conn in $connections) {
    try {
        $result = Test-NetConnection $conn.Host -Port $conn.Port -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($result) {
            Write-Host "   ✅ $($conn.Name) ($($conn.Host):$($conn.Port)) - REACHABLE" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $($conn.Name) ($($conn.Host):$($conn.Port)) - UNREACHABLE" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ $($conn.Name) ($($conn.Host):$($conn.Port)) - FAILED" -ForegroundColor Red
    }
}

# Check current .env
Write-Host ""
Write-Host "3. Checking current .env configuration..." -ForegroundColor Gray
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    
    if ($databaseLine) {
        Write-Host "   ✅ DATABASE_URL found in .env" -ForegroundColor Green
        Write-Host "   📋 Current: $databaseLine" -ForegroundColor Gray
        
        if ($databaseLine -match "postgres\.bervahrnaauhznctodie") {
            Write-Host "   ✅ Username format is correct" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Username format needs fixing" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ No DATABASE_URL found in .env" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ .env file not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "🚀 Now try running the backend:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 If it still times out:" -ForegroundColor Cyan
Write-Host "   1. Try mobile hotspot: .\try-mobile-hotspot.ps1" -ForegroundColor Gray
Write-Host "   2. Use local database: .\setup-local-database.ps1" -ForegroundColor Gray