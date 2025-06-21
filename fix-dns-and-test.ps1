# Complete DNS Fix and Connection Test
# This will fix DNS issues and test the connection

Write-Host "🔍 Cerberus Chain: DNS Fix and Connection Test" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor White
Write-Host ""

Write-Host "🌐 Step 1: Fixing DNS Issues..." -ForegroundColor Yellow

# 1. Flush DNS cache
Write-Host "   Flushing DNS cache..." -ForegroundColor Gray
try {
    ipconfig /flushdns | Out-Null
    Write-Host "   ✅ DNS cache flushed" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not flush DNS cache" -ForegroundColor Yellow
}

# 2. Test current DNS resolution
Write-Host "   Testing DNS resolution..." -ForegroundColor Gray
$testHosts = @(
    "google.com",
    "db.bervahrnaauhznctodie.supabase.co",
    "aws-0-us-west-1.pooler.supabase.com"
)

$workingHosts = @()
foreach ($testHost in $testHosts) {
    try {
        $result = Resolve-DnsName $testHost -ErrorAction Stop
        Write-Host "   ✅ $testHost - RESOLVED" -ForegroundColor Green
        $workingHosts += $testHost
    } catch {
        Write-Host "   ❌ $testHost - FAILED" -ForegroundColor Red
    }
}

# 3. If Supabase hosts are not resolving, try changing DNS
if ($workingHosts -notcontains "db.bervahrnaauhznctodie.supabase.co") {
    Write-Host ""
    Write-Host "🔧 Step 2: Changing DNS servers to Google DNS..." -ForegroundColor Yellow
    
    try {
        # Get active network adapter
        $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Virtual -eq $false} | Select-Object -First 1
        if ($adapter) {
            # Set DNS servers to Google DNS
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses "8.8.8.8","8.8.4.4" -ErrorAction Stop
            Write-Host "   ✅ DNS servers changed to Google DNS (8.8.8.8, 8.8.4.4)" -ForegroundColor Green
            
            # Wait a moment and test again
            Start-Sleep -Seconds 3
            Write-Host "   Testing DNS resolution again..." -ForegroundColor Gray
            
            foreach ($testHost in @("db.bervahrnaauhznctodie.supabase.co", "aws-0-us-west-1.pooler.supabase.com")) {
                try {
                    $result = Resolve-DnsName $testHost -ErrorAction Stop
                    Write-Host "   ✅ $testHost - NOW RESOLVED" -ForegroundColor Green
                    $workingHosts += $testHost
                } catch {
                    Write-Host "   ❌ $testHost - STILL FAILED" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "   ⚠️  Could not find active network adapter" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ⚠️  Could not change DNS servers (may need admin rights)" -ForegroundColor Yellow
        Write-Host "   💡 Manually change DNS to 8.8.8.8 and 8.8.4.4 in Network Settings" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "🔗 Step 3: Testing Connection Methods..." -ForegroundColor Yellow

# Test different connection methods
$connectionMethods = @()

if ($workingHosts -contains "db.bervahrnaauhznctodie.supabase.co") {
    Write-Host "   Testing direct connection..." -ForegroundColor Gray
    $directTest = Test-NetConnection "db.bervahrnaauhznctodie.supabase.co" -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($directTest) {
        Write-Host "   ✅ Direct connection: WORKING" -ForegroundColor Green
        $connectionMethods += @{
            Type = "Direct"
            Host = "db.bervahrnaauhznctodie.supabase.co"
            Port = 5432
            Working = $true
        }
    } else {
        Write-Host "   ❌ Direct connection: BLOCKED" -ForegroundColor Red
    }
}

if ($workingHosts -contains "aws-0-us-west-1.pooler.supabase.com") {
    Write-Host "   Testing pooler connection..." -ForegroundColor Gray
    $poolerTest = Test-NetConnection "aws-0-us-west-1.pooler.supabase.com" -Port 6543 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($poolerTest) {
        Write-Host "   ✅ Pooler connection: WORKING" -ForegroundColor Green
        $connectionMethods += @{
            Type = "Pooler"
            Host = "aws-0-us-west-1.pooler.supabase.com"
            Port = 6543
            Working = $true
        }
    } else {
        Write-Host "   ❌ Pooler connection: BLOCKED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🔧 Step 4: Updating .env with working connection..." -ForegroundColor Yellow

# Choose the best working connection
$bestConnection = $connectionMethods | Where-Object { $_.Working -eq $true } | Select-Object -First 1

if ($bestConnection) {
    Write-Host "   ✅ Found working connection: $($bestConnection.Type)" -ForegroundColor Green
    
    # Get current password from .env
    if (Test-Path ".env") {
        $envContent = Get-Content ".env" -Raw
        $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
        
        if ($databaseLine -match ":([^@]+)@") {
            $currentPassword = $matches[1]
            
            # Create the correct DATABASE_URL
            $newDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:$currentPassword@$($bestConnection.Host):$($bestConnection.Port)/postgres"
            
            # Update .env file
            $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$newDatabaseUrl"
            $envContent | Set-Content ".env" -NoNewline
            
            Write-Host "   ✅ Updated .env with working connection" -ForegroundColor Green
            Write-Host "   📋 Using: $($bestConnection.Type) connection" -ForegroundColor Gray
            
        } else {
            Write-Host "   ❌ Could not extract password from .env" -ForegroundColor Red
            Write-Host "   📝 Please enter your Supabase database password:" -ForegroundColor Yellow
            $password = Read-Host "Password"
            
            $newDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@$($bestConnection.Host):$($bestConnection.Port)/postgres"
            $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$newDatabaseUrl"
            $envContent | Set-Content ".env" -NoNewline
            
            Write-Host "   ✅ Updated .env with your password" -ForegroundColor Green
        }
    } else {
        Write-Host "   ❌ .env file not found" -ForegroundColor Red
        exit 1
    }
    
} else {
    Write-Host "   ❌ No working connections found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Alternative Solutions:" -ForegroundColor Yellow
    Write-Host "   1. 📱 Try mobile hotspot (different network)" -ForegroundColor White
    Write-Host "   2. 🛡️ Temporarily disable Windows Firewall" -ForegroundColor White
    Write-Host "   3. 🏠 Use local database: .\try-local-database.ps1" -ForegroundColor White
    Write-Host "   4. 🔄 Restart your computer and try again" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "🎉 DNS and Connection Fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Cyan
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Yellow
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green