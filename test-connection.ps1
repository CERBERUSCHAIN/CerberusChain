# Cerberus Chain: Database Connection Troubleshooting Script
# Run this to diagnose and fix connection issues

Write-Host "🔍 Cerberus Chain: Database Connection Diagnostics" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor White

# Test 1: DNS Resolution
Write-Host "🌐 Testing DNS Resolution..." -ForegroundColor Yellow
try {
    $dnsResult = Resolve-DnsName "db.bervahrnaauhznctodie.supabase.co" -ErrorAction Stop
    Write-Host "✅ DNS Resolution: SUCCESS" -ForegroundColor Green
    Write-Host "   IP Address: $($dnsResult.IPAddress)" -ForegroundColor Gray
} catch {
    Write-Host "❌ DNS Resolution: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Trying to flush DNS cache..." -ForegroundColor Yellow
    
    # Flush DNS cache
    ipconfig /flushdns | Out-Null
    Write-Host "✅ DNS cache flushed" -ForegroundColor Green
    
    # Try again
    try {
        $dnsResult = Resolve-DnsName "db.bervahrnaauhznctodie.supabase.co" -ErrorAction Stop
        Write-Host "✅ DNS Resolution after flush: SUCCESS" -ForegroundColor Green
        Write-Host "   IP Address: $($dnsResult.IPAddress)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ DNS still failing. Trying alternative DNS servers..." -ForegroundColor Red
    }
}

# Test 2: Internet Connectivity
Write-Host "🌍 Testing Internet Connectivity..." -ForegroundColor Yellow
try {
    $pingResult = Test-NetConnection "8.8.8.8" -Port 53 -InformationLevel Quiet
    if ($pingResult) {
        Write-Host "✅ Internet Connection: ACTIVE" -ForegroundColor Green
    } else {
        Write-Host "❌ Internet Connection: FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Internet Connection: FAILED" -ForegroundColor Red
}

# Test 3: Supabase Connectivity
Write-Host "🔗 Testing Supabase Connectivity..." -ForegroundColor Yellow
try {
    $supabaseTest = Test-NetConnection "db.bervahrnaauhznctodie.supabase.co" -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($supabaseTest) {
        Write-Host "✅ Supabase Port 5432: REACHABLE" -ForegroundColor Green
    } else {
        Write-Host "❌ Supabase Port 5432: UNREACHABLE" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Supabase Connection: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Alternative connection methods
Write-Host "🔄 Testing Alternative Connection Methods..." -ForegroundColor Yellow

# Try pooler connection
Write-Host "   Testing Pooler Connection..." -ForegroundColor Gray
try {
    $poolerTest = Test-NetConnection "aws-0-us-west-1.pooler.supabase.com" -Port 6543 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($poolerTest) {
        Write-Host "   ✅ Pooler Connection: REACHABLE" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Pooler Connection: UNREACHABLE" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Pooler Connection: FAILED" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔧 Recommended Solutions:" -ForegroundColor Cyan

Write-Host "1. 🌐 Try using Google DNS:" -ForegroundColor Yellow
Write-Host "   - Open Network Settings" -ForegroundColor Gray
Write-Host "   - Change DNS to 8.8.8.8 and 8.8.4.4" -ForegroundColor Gray

Write-Host "2. 🔄 Try the pooler connection instead:" -ForegroundColor Yellow
Write-Host "   - Use: aws-0-us-west-1.pooler.supabase.com:6543" -ForegroundColor Gray
Write-Host "   - Username format: postgres.bervahrnaauhznctodie" -ForegroundColor Gray

Write-Host "3. 🛡️ Check Windows Firewall:" -ForegroundColor Yellow
Write-Host "   - Allow Rust/Cargo through firewall" -ForegroundColor Gray
Write-Host "   - Temporarily disable antivirus" -ForegroundColor Gray

Write-Host "4. 🏠 Try from different network:" -ForegroundColor Yellow
Write-Host "   - Mobile hotspot" -ForegroundColor Gray
Write-Host "   - Different WiFi network" -ForegroundColor Gray

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Green
Write-Host "1. Run this script to see which tests pass" -ForegroundColor White
Write-Host "2. Try the pooler connection if direct connection fails" -ForegroundColor White
Write-Host "3. Check your network/firewall settings" -ForegroundColor White