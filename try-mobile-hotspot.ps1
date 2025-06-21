# Try Mobile Hotspot for Supabase Connection
# Sometimes corporate/home networks block Supabase

Write-Host "📱 Try Mobile Hotspot for Supabase Connection" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor White
Write-Host ""

Write-Host "🌐 Network connectivity issues can cause timeouts" -ForegroundColor Yellow
Write-Host "   Your home/work network might be blocking Supabase" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 Steps to try mobile hotspot:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 📱 Enable mobile hotspot on your phone" -ForegroundColor White
Write-Host "   • Go to Settings → Mobile Hotspot" -ForegroundColor Gray
Write-Host "   • Turn on hotspot" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 💻 Connect your computer to the hotspot" -ForegroundColor White
Write-Host "   • Look for your phone's hotspot in WiFi settings" -ForegroundColor Gray
Write-Host "   • Connect to it" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 🧪 Test the connection" -ForegroundColor White
Write-Host "   • Run: cd backend && cargo run" -ForegroundColor Gray
Write-Host ""

Write-Host "🔍 Testing current network connectivity..." -ForegroundColor Yellow

# Test basic internet
Write-Host "   Testing basic internet..." -ForegroundColor Gray
try {
    $internetTest = Test-NetConnection "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($internetTest) {
        Write-Host "   ✅ Internet: WORKING" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Internet: NOT WORKING" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Internet: NOT WORKING" -ForegroundColor Red
}

# Test Supabase connectivity
Write-Host "   Testing Supabase connectivity..." -ForegroundColor Gray
$supabaseHosts = @(
    @{ Host = "db.bervahrnaauhznctodie.supabase.co"; Port = 5432; Name = "Direct" },
    @{ Host = "aws-0-us-west-1.pooler.supabase.com"; Port = 6543; Name = "Pooler" }
)

$workingConnections = 0
foreach ($test in $supabaseHosts) {
    try {
        $result = Test-NetConnection $test.Host -Port $test.Port -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($result) {
            Write-Host "   ✅ $($test.Name): REACHABLE" -ForegroundColor Green
            $workingConnections++
        } else {
            Write-Host "   ❌ $($test.Name): BLOCKED" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ $($test.Name): BLOCKED" -ForegroundColor Red
    }
}

Write-Host ""
if ($workingConnections -eq 0) {
    Write-Host "🚨 No Supabase connections working on current network!" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 This confirms it's a network issue. Try:" -ForegroundColor Yellow
    Write-Host "   1. 📱 Mobile hotspot (recommended)" -ForegroundColor White
    Write-Host "   2. 🏠 Different WiFi network" -ForegroundColor White
    Write-Host "   3. 🛡️ Temporarily disable Windows Firewall" -ForegroundColor White
    Write-Host "   4. 💻 Use local database: .\setup-local-database.ps1" -ForegroundColor White
} else {
    Write-Host "✅ Some Supabase connections are working" -ForegroundColor Green
    Write-Host "   The timeout might be a different issue" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Try running the backend again:" -ForegroundColor Yellow
    Write-Host "   cd backend && cargo run" -ForegroundColor White
}

Write-Host ""
Write-Host "🔄 After switching to mobile hotspot, run:" -ForegroundColor Cyan
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White