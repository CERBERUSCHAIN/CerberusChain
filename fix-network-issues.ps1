# Fix Network Issues for Supabase Connection
# This addresses the root cause of connection timeouts

Write-Host "🔧 Fixing Network Issues for Supabase" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor White
Write-Host ""

Write-Host "🛡️ Step 1: Windows Firewall Configuration..." -ForegroundColor Yellow

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if ($isAdmin) {
    Write-Host "✅ Running as Administrator - can make system changes" -ForegroundColor Green
    
    # Add firewall rules for Rust/Cargo
    Write-Host "   Adding firewall rules for Rust..." -ForegroundColor Gray
    try {
        netsh advfirewall firewall add rule name="Rust Cargo Outbound" dir=out action=allow program="cargo.exe" | Out-Null
        netsh advfirewall firewall add rule name="Rust Backend Outbound" dir=out action=allow protocol=TCP remoteport=5432,6543 | Out-Null
        Write-Host "   ✅ Firewall rules added" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Could not add firewall rules automatically" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Not running as Administrator" -ForegroundColor Yellow
    Write-Host "   Manual firewall configuration needed:" -ForegroundColor Gray
    Write-Host "   1. Open Windows Defender Firewall" -ForegroundColor White
    Write-Host "   2. Click 'Allow an app or feature through Windows Defender Firewall'" -ForegroundColor White
    Write-Host "   3. Click 'Change Settings' then 'Allow another app...'" -ForegroundColor White
    Write-Host "   4. Browse to your Rust installation and add cargo.exe" -ForegroundColor White
}

Write-Host ""
Write-Host "🌐 Step 2: DNS Configuration..." -ForegroundColor Yellow

# Change DNS to Google DNS
Write-Host "   Setting DNS servers to Google DNS..." -ForegroundColor Gray
try {
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Virtual -eq $false} | Select-Object -First 1
    if ($adapter) {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses "8.8.8.8","8.8.4.4" -ErrorAction Stop
        Write-Host "   ✅ DNS changed to Google DNS (8.8.8.8, 8.8.4.4)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Could not find active network adapter" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Could not change DNS automatically" -ForegroundColor Yellow
    Write-Host "   Manual DNS change needed:" -ForegroundColor Gray
    Write-Host "   1. Open Network & Internet Settings" -ForegroundColor White
    Write-Host "   2. Click 'Change adapter options'" -ForegroundColor White
    Write-Host "   3. Right-click your connection → Properties" -ForegroundColor White
    Write-Host "   4. Select 'Internet Protocol Version 4 (TCP/IPv4)' → Properties" -ForegroundColor White
    Write-Host "   5. Use these DNS servers: 8.8.8.8 and 8.8.4.4" -ForegroundColor White
}

Write-Host ""
Write-Host "🔄 Step 3: Network Stack Reset..." -ForegroundColor Yellow

# Flush DNS cache
Write-Host "   Flushing DNS cache..." -ForegroundColor Gray
try {
    ipconfig /flushdns | Out-Null
    Write-Host "   ✅ DNS cache flushed" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not flush DNS cache" -ForegroundColor Yellow
}

# Reset Winsock
if ($isAdmin) {
    Write-Host "   Resetting Winsock..." -ForegroundColor Gray
    try {
        netsh winsock reset | Out-Null
        Write-Host "   ✅ Winsock reset (restart required)" -ForegroundColor Green
        $restartRequired = $true
    } catch {
        Write-Host "   ⚠️  Could not reset Winsock" -ForegroundColor Yellow
    }
    
    # Reset TCP/IP stack
    Write-Host "   Resetting TCP/IP stack..." -ForegroundColor Gray
    try {
        netsh int ip reset | Out-Null
        Write-Host "   ✅ TCP/IP stack reset (restart required)" -ForegroundColor Green
        $restartRequired = $true
    } catch {
        Write-Host "   ⚠️  Could not reset TCP/IP stack" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️  Administrator rights needed for network stack reset" -ForegroundColor Yellow
    Write-Host "   Run this script as Administrator for full network reset" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🧪 Step 4: Testing fixes..." -ForegroundColor Yellow

# Test DNS resolution after changes
Start-Sleep -Seconds 2
$testHosts = @(
    "db.bervahrnaauhznctodie.supabase.co",
    "aws-0-us-west-1.pooler.supabase.com"
)

foreach ($testHost in $testHosts) {
    try {
        $result = Resolve-DnsName $testHost -ErrorAction Stop
        Write-Host "   ✅ $testHost: NOW RESOLVED" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ $testHost: STILL FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 Network Fixes Applied!" -ForegroundColor Green
Write-Host ""

if ($restartRequired) {
    Write-Host "⚠️  RESTART REQUIRED" -ForegroundColor Yellow
    Write-Host "   Some network changes require a restart to take effect" -ForegroundColor Gray
    Write-Host "   After restart, test with: cd backend && cargo run" -ForegroundColor White
} else {
    Write-Host "🚀 Test the connection now:" -ForegroundColor Cyan
    Write-Host "   cd backend && cargo run" -ForegroundColor White
}

Write-Host ""
Write-Host "💡 If issues persist after these fixes:" -ForegroundColor Yellow
Write-Host "   1. The problem is likely ISP/corporate network blocking" -ForegroundColor White
Write-Host "   2. Use local database: .\setup-local-database.ps1" -ForegroundColor White
Write-Host "   3. Contact your network administrator" -ForegroundColor White