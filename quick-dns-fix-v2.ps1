# Quick DNS Fix for Windows (Fixed Version)
# Run this to fix common DNS issues that prevent Supabase connection

Write-Host "🌐 Quick DNS Fix for Supabase Connection" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Applying DNS fixes..." -ForegroundColor Yellow

# 1. Flush DNS cache
Write-Host "1. Flushing DNS cache..." -ForegroundColor Gray
try {
    ipconfig /flushdns | Out-Null
    Write-Host "   ✅ DNS cache flushed" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not flush DNS cache" -ForegroundColor Yellow
}

# 2. Reset Winsock
Write-Host "2. Resetting Winsock..." -ForegroundColor Gray
try {
    netsh winsock reset | Out-Null
    Write-Host "   ✅ Winsock reset" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not reset Winsock (may need admin rights)" -ForegroundColor Yellow
}

# 3. Reset TCP/IP stack
Write-Host "3. Resetting TCP/IP stack..." -ForegroundColor Gray
try {
    netsh int ip reset | Out-Null
    Write-Host "   ✅ TCP/IP stack reset" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not reset TCP/IP stack (may need admin rights)" -ForegroundColor Yellow
}

# 4. Set Google DNS (temporarily)
Write-Host "4. Setting Google DNS servers..." -ForegroundColor Gray
try {
    # Get active network adapter
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Virtual -eq $false} | Select-Object -First 1
    if ($adapter) {
        # Set DNS servers
        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses "8.8.8.8","8.8.4.4" -ErrorAction Stop
        Write-Host "   ✅ DNS servers set to Google DNS (8.8.8.8, 8.8.4.4)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Could not find active network adapter" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Could not set DNS servers automatically (may need admin rights)" -ForegroundColor Yellow
    Write-Host "   💡 Manually set DNS to 8.8.8.8 and 8.8.4.4 in Network Settings" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🧪 Testing DNS resolution..." -ForegroundColor Yellow

$testHostnames = @(
    "db.bervahrnaauhznctodie.supabase.co",
    "aws-0-us-west-1.pooler.supabase.com",
    "google.com"
)

foreach ($testHostname in $testHostnames) {
    try {
        $result = Resolve-DnsName $testHostname -ErrorAction Stop
        Write-Host "   ✅ $testHostname - RESOLVED" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ $testHostname - FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "⚠️  IMPORTANT: You may need to restart your computer for all changes to take effect" -ForegroundColor Yellow
Write-Host ""
Write-Host "🚀 Try the connection now:" -ForegroundColor Green
Write-Host "   .\fix-dns-and-connection-v2.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 If DNS issues persist:" -ForegroundColor Cyan
Write-Host "   1. Restart your computer" -ForegroundColor White
Write-Host "   2. Try a different network (mobile hotspot)" -ForegroundColor White
Write-Host "   3. Use local database: .\try-local-database.ps1" -ForegroundColor White