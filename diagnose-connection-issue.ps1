# Comprehensive Connection Diagnostics for Supabase
# This will identify the real cause of the connection timeout

Write-Host "🔍 Cerberus Chain: Connection Diagnostics" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 Analyzing the 'pool timed out' error..." -ForegroundColor Yellow
Write-Host "   This means the connection is being attempted but not completing" -ForegroundColor Gray
Write-Host ""

# Step 1: Check current .env configuration
Write-Host "🔧 Step 1: Verifying .env configuration..." -ForegroundColor Yellow

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    
    if ($databaseLine) {
        Write-Host "✅ DATABASE_URL found" -ForegroundColor Green
        Write-Host "   $databaseLine" -ForegroundColor Gray
        
        # Parse the connection string
        if ($databaseLine -match "postgresql://([^:]+):([^@]+)@([^:]+):(\d+)/(.+)") {
            $username = $matches[1]
            $password = $matches[2]
            $host = $matches[3]
            $port = $matches[4]
            $database = $matches[5]
            
            Write-Host "   Username: $username" -ForegroundColor Gray
            Write-Host "   Host: $host" -ForegroundColor Gray
            Write-Host "   Port: $port" -ForegroundColor Gray
            
            # Validate format
            if ($username -eq "postgres.bervahrnaauhznctodie") {
                Write-Host "   ✅ Username format: CORRECT" -ForegroundColor Green
            } else {
                Write-Host "   ❌ Username format: INCORRECT (should be postgres.bervahrnaauhznctodie)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "❌ No DATABASE_URL found in .env" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Network connectivity tests
Write-Host "🌐 Step 2: Testing network connectivity..." -ForegroundColor Yellow

# Test basic internet connectivity
Write-Host "   Testing basic internet..." -ForegroundColor Gray
try {
    $internetTest = Test-NetConnection "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($internetTest) {
        Write-Host "   ✅ Internet connectivity: WORKING" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Internet connectivity: FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Internet connectivity: FAILED" -ForegroundColor Red
}

# Test DNS resolution
Write-Host "   Testing DNS resolution..." -ForegroundColor Gray
$testHosts = @(
    "db.bervahrnaauhznctodie.supabase.co",
    "aws-0-us-west-1.pooler.supabase.com"
)

$resolvedHosts = @()
foreach ($testHost in $testHosts) {
    try {
        $dnsResult = Resolve-DnsName $testHost -ErrorAction Stop
        Write-Host "   ✅ $testHost: RESOLVED" -ForegroundColor Green
        $resolvedHosts += $testHost
    } catch {
        Write-Host "   ❌ $testHost: DNS FAILED" -ForegroundColor Red
    }
}

# Test port connectivity
Write-Host "   Testing port connectivity..." -ForegroundColor Gray
$connectionTests = @(
    @{ Host = "db.bervahrnaauhznctodie.supabase.co"; Port = 5432; Name = "Direct" },
    @{ Host = "aws-0-us-west-1.pooler.supabase.com"; Port = 6543; Name = "Pooler" }
)

$workingConnections = @()
foreach ($test in $connectionTests) {
    if ($resolvedHosts -contains $test.Host) {
        try {
            $portTest = Test-NetConnection $test.Host -Port $test.Port -InformationLevel Quiet -WarningAction SilentlyContinue
            if ($portTest) {
                Write-Host "   ✅ $($test.Name) ($($test.Host):$($test.Port)): REACHABLE" -ForegroundColor Green
                $workingConnections += $test
            } else {
                Write-Host "   ❌ $($test.Name) ($($test.Host):$($test.Port)): BLOCKED" -ForegroundColor Red
            }
        } catch {
            Write-Host "   ❌ $($test.Name) ($($test.Host):$($test.Port)): FAILED" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  $($test.Name): SKIPPED (DNS failed)" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 3: Analyze results and provide solutions
Write-Host "🔍 Step 3: Analysis and Solutions..." -ForegroundColor Yellow

if ($workingConnections.Count -eq 0) {
    Write-Host "❌ ISSUE IDENTIFIED: Network connectivity problem" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Root Cause: Your network is blocking Supabase connections" -ForegroundColor Yellow
    Write-Host "   This could be due to:" -ForegroundColor Gray
    Write-Host "   • Corporate firewall blocking database ports" -ForegroundColor White
    Write-Host "   • ISP blocking PostgreSQL connections" -ForegroundColor White
    Write-Host "   • Windows Firewall blocking outbound connections" -ForegroundColor White
    Write-Host "   • Antivirus software blocking network access" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 REAL SOLUTIONS (not workarounds):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. 🛡️ Windows Firewall Fix:" -ForegroundColor Green
    Write-Host "   • Open Windows Defender Firewall" -ForegroundColor White
    Write-Host "   • Click 'Allow an app or feature through Windows Defender Firewall'" -ForegroundColor White
    Write-Host "   • Add Rust/Cargo to the allowed list" -ForegroundColor White
    Write-Host ""
    Write-Host "2. 🔧 Network Configuration:" -ForegroundColor Green
    Write-Host "   • Change DNS servers to 8.8.8.8 and 8.8.4.4" -ForegroundColor White
    Write-Host "   • Flush DNS cache: ipconfig /flushdns" -ForegroundColor White
    Write-Host "   • Reset network stack: netsh winsock reset" -ForegroundColor White
    Write-Host ""
    Write-Host "3. 🏠 Local Development Database:" -ForegroundColor Green
    Write-Host "   • Set up PostgreSQL locally with Docker" -ForegroundColor White
    Write-Host "   • This eliminates network issues entirely" -ForegroundColor White
    Write-Host "   • Run: .\setup-local-database.ps1" -ForegroundColor White
    
} elseif ($workingConnections.Count -eq 1) {
    $bestConnection = $workingConnections[0]
    Write-Host "✅ SOLUTION FOUND: Use $($bestConnection.Name) connection" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔧 Updating .env with working connection..." -ForegroundColor Yellow
    
    # Extract password and update .env
    if ($databaseLine -match ":([^@]+)@") {
        $currentPassword = $matches[1]
        $newUrl = "postgresql://postgres.bervahrnaauhznctodie:$currentPassword@$($bestConnection.Host):$($bestConnection.Port)/postgres"
        
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$newUrl"
        $envContent | Set-Content ".env" -NoNewline
        
        Write-Host "✅ Updated .env to use $($bestConnection.Name) connection" -ForegroundColor Green
        Write-Host "   New URL: $newUrl" -ForegroundColor Gray
    }
    
} else {
    Write-Host "✅ Multiple connections available - using best option" -ForegroundColor Green
    $bestConnection = $workingConnections | Where-Object { $_.Name -eq "Pooler" } | Select-Object -First 1
    if (-not $bestConnection) {
        $bestConnection = $workingConnections[0]
    }
    
    Write-Host "🔧 Optimizing .env for $($bestConnection.Name) connection..." -ForegroundColor Yellow
    
    if ($databaseLine -match ":([^@]+)@") {
        $currentPassword = $matches[1]
        $newUrl = "postgresql://postgres.bervahrnaauhznctodie:$currentPassword@$($bestConnection.Host):$($bestConnection.Port)/postgres"
        
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$newUrl"
        $envContent | Set-Content ".env" -NoNewline
        
        Write-Host "✅ Optimized .env for best connection" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan

if ($workingConnections.Count -gt 0) {
    Write-Host "1. Test the backend connection:" -ForegroundColor White
    Write-Host "   cd backend && cargo run" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. If it still times out, the issue is likely:" -ForegroundColor White
    Write-Host "   • Connection pool settings in Rust code" -ForegroundColor Gray
    Write-Host "   • Supabase connection limits" -ForegroundColor Gray
    Write-Host "   • Authentication issues" -ForegroundColor Gray
} else {
    Write-Host "1. Fix network connectivity first:" -ForegroundColor White
    Write-Host "   • Try: .\fix-network-issues.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Or use local database:" -ForegroundColor White
    Write-Host "   • Run: .\setup-local-database.ps1" -ForegroundColor Gray
}

Write-Host ""
Write-Host "💡 This diagnostic identified the real issue, not just symptoms!" -ForegroundColor Magenta