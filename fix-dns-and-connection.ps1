# Comprehensive DNS and Connection Fix for Supabase
# This will test and fix DNS issues and find the working connection method

Write-Host "🔍 Cerberus Chain: DNS and Connection Diagnostics" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor White
Write-Host ""

# Test 1: Check current .env configuration
Write-Host "📋 Step 1: Checking current .env configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    if ($databaseLine) {
        Write-Host "✅ Found DATABASE_URL in .env" -ForegroundColor Green
        Write-Host "   Current: $databaseLine" -ForegroundColor Gray
        
        # Extract components
        if ($databaseLine -match "postgresql://([^:]+):([^@]+)@([^:]+):(\d+)/(.+)") {
            $username = $matches[1]
            $password = $matches[2]
            $host = $matches[3]
            $port = $matches[4]
            $database = $matches[5]
            
            Write-Host "   Username: $username" -ForegroundColor Gray
            Write-Host "   Host: $host" -ForegroundColor Gray
            Write-Host "   Port: $port" -ForegroundColor Gray
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

# Test 2: DNS Resolution Tests
Write-Host "📋 Step 2: Testing DNS Resolution..." -ForegroundColor Yellow

$hosts = @(
    "db.bervahrnaauhznctodie.supabase.co",
    "aws-0-us-west-1.pooler.supabase.com"
)

$workingHosts = @()

foreach ($testHost in $hosts) {
    Write-Host "   Testing: $testHost" -ForegroundColor Gray
    try {
        $dnsResult = Resolve-DnsName $testHost -ErrorAction Stop
        Write-Host "   ✅ $testHost - RESOLVED" -ForegroundColor Green
        Write-Host "      IP: $($dnsResult.IPAddress)" -ForegroundColor Gray
        $workingHosts += $testHost
    } catch {
        Write-Host "   ❌ $testHost - FAILED" -ForegroundColor Red
        Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Test 3: Port Connectivity Tests
Write-Host "📋 Step 3: Testing Port Connectivity..." -ForegroundColor Yellow

$connectionTests = @()

if ($workingHosts -contains "db.bervahrnaauhznctodie.supabase.co") {
    Write-Host "   Testing direct connection (port 5432)..." -ForegroundColor Gray
    try {
        $directTest = Test-NetConnection "db.bervahrnaauhznctodie.supabase.co" -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($directTest) {
            Write-Host "   ✅ Direct connection: REACHABLE" -ForegroundColor Green
            $connectionTests += @{
                Type = "Direct"
                Host = "db.bervahrnaauhznctodie.supabase.co"
                Port = 5432
                Working = $true
            }
        } else {
            Write-Host "   ❌ Direct connection: UNREACHABLE" -ForegroundColor Red
            $connectionTests += @{
                Type = "Direct"
                Host = "db.bervahrnaauhznctodie.supabase.co"
                Port = 5432
                Working = $false
            }
        }
    } catch {
        Write-Host "   ❌ Direct connection: FAILED" -ForegroundColor Red
        $connectionTests += @{
            Type = "Direct"
            Host = "db.bervahrnaauhznctodie.supabase.co"
            Port = 5432
            Working = $false
        }
    }
}

if ($workingHosts -contains "aws-0-us-west-1.pooler.supabase.com") {
    Write-Host "   Testing pooler connection (port 6543)..." -ForegroundColor Gray
    try {
        $poolerTest = Test-NetConnection "aws-0-us-west-1.pooler.supabase.com" -Port 6543 -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($poolerTest) {
            Write-Host "   ✅ Pooler connection: REACHABLE" -ForegroundColor Green
            $connectionTests += @{
                Type = "Pooler"
                Host = "aws-0-us-west-1.pooler.supabase.com"
                Port = 6543
                Working = $true
            }
        } else {
            Write-Host "   ❌ Pooler connection: UNREACHABLE" -ForegroundColor Red
            $connectionTests += @{
                Type = "Pooler"
                Host = "aws-0-us-west-1.pooler.supabase.com"
                Port = 6543
                Working = $false
            }
        }
    } catch {
        Write-Host "   ❌ Pooler connection: FAILED" -ForegroundColor Red
        $connectionTests += @{
            Type = "Pooler"
            Host = "aws-0-us-west-1.pooler.supabase.com"
            Port = 6543
            Working = $false
        }
    }
}

Write-Host ""

# Test 4: Find working connection and update .env
Write-Host "📋 Step 4: Finding best connection method..." -ForegroundColor Yellow

$workingConnection = $connectionTests | Where-Object { $_.Working -eq $true } | Select-Object -First 1

if ($workingConnection) {
    Write-Host "✅ Found working connection: $($workingConnection.Type)" -ForegroundColor Green
    Write-Host "   Host: $($workingConnection.Host)" -ForegroundColor Gray
    Write-Host "   Port: $($workingConnection.Port)" -ForegroundColor Gray
    
    # Extract password from current DATABASE_URL
    if ($databaseLine -match ":([^@]+)@") {
        $currentPassword = $matches[1]
        
        # Create new DATABASE_URL
        $newDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:$currentPassword@$($workingConnection.Host):$($workingConnection.Port)/postgres"
        
        Write-Host ""
        Write-Host "🔧 Updating .env with working connection..." -ForegroundColor Yellow
        
        # Update .env file
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$newDatabaseUrl"
        $envContent | Set-Content ".env" -NoNewline
        
        Write-Host "✅ Updated .env file successfully!" -ForegroundColor Green
        Write-Host "📋 New DATABASE_URL:" -ForegroundColor Cyan
        Write-Host "   DATABASE_URL=$newDatabaseUrl" -ForegroundColor Gray
        
    } else {
        Write-Host "❌ Could not extract password from current DATABASE_URL" -ForegroundColor Red
        Write-Host "📝 Please enter your Supabase database password:" -ForegroundColor Yellow
        $password = Read-Host "Password" -AsSecureString
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
        
        $newDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:$plainPassword@$($workingConnection.Host):$($workingConnection.Port)/postgres"
        
        # Update .env file
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$newDatabaseUrl"
        $envContent | Set-Content ".env" -NoNewline
        
        Write-Host "✅ Updated .env file with new password!" -ForegroundColor Green
    }
    
} else {
    Write-Host "❌ No working connections found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting Steps:" -ForegroundColor Yellow
    Write-Host "1. 🌐 Try changing your DNS servers:" -ForegroundColor White
    Write-Host "   - Use Google DNS: 8.8.8.8, 8.8.4.4" -ForegroundColor Gray
    Write-Host "   - Use Cloudflare DNS: 1.1.1.1, 1.0.0.1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. 🛡️ Check your firewall/antivirus:" -ForegroundColor White
    Write-Host "   - Temporarily disable Windows Firewall" -ForegroundColor Gray
    Write-Host "   - Add exception for Rust/Cargo" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. 🏠 Try a different network:" -ForegroundColor White
    Write-Host "   - Mobile hotspot" -ForegroundColor Gray
    Write-Host "   - Different WiFi network" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. 💻 Flush DNS cache:" -ForegroundColor White
    Write-Host "   ipconfig /flushdns" -ForegroundColor Gray
    
    exit 1
}

Write-Host ""
Write-Host "🚀 Ready to test! Run the backend:" -ForegroundColor Green
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   cargo run" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 If it still doesn't work, try:" -ForegroundColor Yellow
Write-Host "   .\try-local-database.ps1" -ForegroundColor Gray